#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "net/http"
require "uri"
require "yaml"

CASK_PATH = "Casks/comfy.rb"
UPDATE_URL = "https://download.todesktop.com/241130tqe9q3y/latest-mac.yml"
DOWNLOAD_BASE_URL = "https://download.todesktop.com/241012ess7yxs0e"

def request(uri)
  request = Net::HTTP::Get.new(uri)
  request["User-Agent"] = "homebrew-tap-updater"

  Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
    http.request(request)
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

response = request(URI(UPDATE_URL))
abort "Update manifest request failed: #{response.code} #{response.message}" unless response.is_a?(Net::HTTPSuccess)

manifest = YAML.safe_load(response.body)
version = manifest.fetch("version")
file_pattern = /\AComfy Desktop (?<version>\d+(?:\.\d+)+) - Build (?<build>[^-]+)-arm64-mac\.zip\z/
file_match = manifest.fetch("files").filter_map do |file|
  file.fetch("url").match(file_pattern)
end.first
abort "Comfy Desktop arm64 macOS archive not found in update manifest" unless file_match
abort "Comfy Desktop manifest version does not match archive: #{version}" if file_match[:version] != version

build = file_match[:build]
source = File.read(CASK_PATH)
version_pattern = /^  version "(?<version>\d+(?:\.\d+)+),(?<build>[^"]+)"$/
current = source.match(version_pattern)
abort "Could not find Comfy Desktop version in #{CASK_PATH}" unless current

if [current[:version], current[:build]] == [version, build]
  puts "comfy is already up to date at #{version},#{build}."
  exit
end

url = "#{DOWNLOAD_BASE_URL}/Comfy%20Desktop%20#{version}%20-%20Build%20#{build}-arm64-mac.zip"
sha256 = download_sha256(url)
sha_pattern = /^  sha256 "[a-f0-9]{64}"$/
abort "Could not find Comfy Desktop checksum in #{CASK_PATH}" unless source.match?(sha_pattern)

updated = source.sub(version_pattern, %Q(  version "#{version},#{build}"))
updated = updated.sub(sha_pattern, %Q(  sha256 "#{sha256}"))
File.write(CASK_PATH, updated)
puts "Updated comfy to #{version},#{build}."
