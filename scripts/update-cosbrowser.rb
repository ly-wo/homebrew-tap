#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "net/http"
require "uri"

CASK_PATH = "Casks/cosbrowser.rb"
LATEST_URLS = {
  arm:   "https://cosbrowser.cloud.tencent.com/cosbrowser-latest-arm64.dmg",
  intel: "https://cosbrowser.cloud.tencent.com/cosbrowser-latest.dmg",
}.freeze

def request(uri)
  request = Net::HTTP::Get.new(uri)
  request["User-Agent"] = "homebrew-tap-updater"

  Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
    http.request(request)
  end
end

def latest_release(url)
  response = request(URI(url))
  unless response.is_a?(Net::HTTPRedirection)
    abort "Latest release request failed: #{response.code} #{response.message}"
  end

  release_url = URI.join(url, response.fetch("location")).to_s
  match = %r{/cosbrowser-(?<version>\d+(?:\.\d+)+)(?:-arm64)?\.dmg\z}.match(release_url)
  abort "Unexpected COSBrowser release URL: #{release_url}" unless match

  {
    version: match[:version],
    url:     release_url,
  }
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

releases = LATEST_URLS.transform_values { |url| latest_release(url) }
versions = releases.values.map { |release| release.fetch(:version) }.uniq
abort "COSBrowser downloads disagree on the latest version: #{versions.inspect}" unless versions.one?

version = versions.first
source = File.read(CASK_PATH)
version_pattern = /^  version "(?<version>\d+(?:\.\d+)+)"$/
current = source.match(version_pattern)
abort "Could not find COSBrowser version in #{CASK_PATH}" unless current

if current[:version] == version
  puts "cosbrowser is already up to date at #{version}."
  exit
end

shas = releases.transform_values { |release| download_sha256(release.fetch(:url)) }
sha_pattern = /^  sha256 arm:\s+"[a-f0-9]{64}",\n\s+intel: "[a-f0-9]{64}"$/
abort "Could not find COSBrowser checksums in #{CASK_PATH}" unless source.match?(sha_pattern)

updated = source.sub(version_pattern, %Q(  version "#{version}"))
updated = updated.sub(
  sha_pattern,
  %Q(  sha256 arm:   "#{shas.fetch(:arm)}",\n         intel: "#{shas.fetch(:intel)}"),
)
File.write(CASK_PATH, updated)
puts "Updated cosbrowser to #{version}."
