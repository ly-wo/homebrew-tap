#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "net/http"
require "rexml/document"
require "uri"

CASK_PATH = "Casks/orbstack.rb"
APPCASTS = {
  arm:   "https://cdn-updates.orbstack.dev/arm64/appcast.new.xml",
  intel: "https://cdn-updates.orbstack.dev/amd64/appcast.new.xml",
}.freeze

def request(uri)
  request = Net::HTTP::Get.new(uri)
  request["User-Agent"] = "homebrew-tap-updater"

  Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
    http.request(request)
  end
end

def stable_release(url)
  response = request(URI(url))
  abort "Appcast request failed: #{response.code} #{response.message}" unless response.is_a?(Net::HTTPSuccess)

  document = REXML::Document.new(response.body)
  item = document.elements.to_a("rss/channel/item").find do |candidate|
    candidate.elements["sparkle:channel"]&.text == "stable"
  end
  abort "Stable OrbStack release not found in #{url}" unless item

  enclosure_url = item.elements["enclosure"]&.attributes&.fetch("url", nil)
  {
    version: item.elements["sparkle:shortVersionString"]&.text,
    build:   item.elements["sparkle:version"]&.text,
    url:     enclosure_url.to_s,
  }.tap do |release|
    abort "Incomplete stable OrbStack release in #{url}" unless release.values.all? do |value|
      value.is_a?(String) && !value.empty?
    end
  end
end

def download_sha256(url, redirects = 10)
  abort "Too many redirects while downloading #{url}" if redirects <= 0

  uri = URI(url)
  download_request = Net::HTTP::Get.new(uri)
  download_request["User-Agent"] = "homebrew-tap-updater"

  Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
    http.request(download_request) do |response|
      case response
      when Net::HTTPRedirection
        return download_sha256(URI.join(url, response["location"]).to_s, redirects - 1)
      when Net::HTTPSuccess
        digest = Digest::SHA256.new
        response.read_body { |chunk| digest.update(chunk) }
        return digest.hexdigest
      else
        abort "Download failed for #{url}: #{response.code} #{response.message}"
      end
    end
  end
end

releases = APPCASTS.transform_values { |url| stable_release(url) }
versions = releases.values.map { |release| [release.fetch(:version), release.fetch(:build)] }.uniq
abort "OrbStack appcasts disagree on the stable version: #{versions.inspect}" unless versions.one?

version, build = versions.first
source = File.read(CASK_PATH)
version_pattern = /^  version "(?<version>\d+(?:\.\d+)+),(?<build>\d+)"$/
match = source.match(version_pattern)
abort "Could not find OrbStack version in #{CASK_PATH}" unless match

if [match[:version], match[:build]] == [version, build]
  puts "orbstack is already up to date at #{version},#{build}."
  exit
end

shas = releases.transform_values { |release| download_sha256(release.fetch(:url)) }
sha_pattern = /^  sha256 arm:\s+"[a-f0-9]{64}",\n\s+intel: "[a-f0-9]{64}"$/
abort "Could not find OrbStack checksums in #{CASK_PATH}" unless source.match?(sha_pattern)

updated = source.sub(version_pattern, %Q(  version "#{version},#{build}"))
updated = updated.sub(
  sha_pattern,
  %Q(  sha256 arm:   "#{shas.fetch(:arm)}",\n         intel: "#{shas.fetch(:intel)}"),
)
File.write(CASK_PATH, updated)
puts "Updated orbstack to #{version},#{build}."
