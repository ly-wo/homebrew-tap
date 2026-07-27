#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "net/http"
require "uri"

CASK_PATH = "Casks/iflytek-ime.rb"
LATEST_URL = "https://srf.xunfei.cn/mac"
BROWSER_USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) " \
                     "AppleWebKit/605.1.15 (KHTML, like Gecko) " \
                     "Version/18.5 Safari/605.1.15"

def request(uri, user_agent: "homebrew-tap-updater")
  request = Net::HTTP::Get.new(uri)
  request["User-Agent"] = user_agent

  Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
    http.request(request)
  end
end

def download_sha256(url, redirects = 10)
  abort "Too many redirects while downloading #{url}" if redirects <= 0

  uri = URI(url)
  download_request = Net::HTTP::Get.new(uri)
  download_request["User-Agent"] = BROWSER_USER_AGENT

  Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
    http.request(download_request) do |response|
      case response
      when Net::HTTPRedirection
        return download_sha256(URI.join(url, response.fetch("location")).to_s, redirects - 1)
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

response = request(URI(LATEST_URL))
unless response.is_a?(Net::HTTPRedirection)
  abort "Latest release request failed: #{response.code} #{response.message}"
end

download_url = URI.join(LATEST_URL, response.fetch("location")).to_s
match = %r{/iFlytekIMEInstaller_(?<version>\d+(?:\.\d+)+)_Mac\.zip\z}i.match(download_url)
abort "Unexpected iFlytek Input Method release URL: #{download_url}" unless match

version = match[:version]
source = File.read(CASK_PATH)
version_pattern = /^  version "(?<version>\d+(?:\.\d+)+)"$/
current = source.match(version_pattern)
abort "Could not find iFlytek Input Method version in #{CASK_PATH}" unless current

if current[:version] == version
  puts "iflytek-ime is already up to date at #{version}."
  exit
end

sha256 = download_sha256(download_url)
sha_pattern = /^  sha256 "[a-f0-9]{64}"$/
abort "Could not find iFlytek Input Method checksum in #{CASK_PATH}" unless source.match?(sha_pattern)

updated = source.sub(version_pattern, %Q(  version "#{version}"))
updated = updated.sub(sha_pattern, %Q(  sha256 "#{sha256}"))
File.write(CASK_PATH, updated)
puts "Updated iflytek-ime to #{version}."
