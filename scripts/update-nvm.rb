#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "json"
require "net/http"
require "uri"

REPO = "nvm-sh/nvm"
FORMULA_PATH = "Formula/nvm.rb"

def request_json(uri)
  request = Net::HTTP::Get.new(uri)
  request["Accept"] = "application/vnd.github+json"
  request["User-Agent"] = "homebrew-tap-updater"
  request["X-GitHub-Api-Version"] = "2022-11-28"
  token = ENV.fetch("GITHUB_TOKEN", ENV.fetch("GH_TOKEN", nil))
  request["Authorization"] = "Bearer #{token}" if token&.length&.positive?

  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
    http.request(request)
  end
  return JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)

  abort "GitHub API request failed: #{response.code} #{response.message}\n#{response.body}"
end

def download_sha256(url, redirects = 10)
  abort "Too many redirects while downloading #{url}" if redirects <= 0

  uri = URI(url)
  request = Net::HTTP::Get.new(uri)
  request["User-Agent"] = "homebrew-tap-updater"

  Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
    http.request(request) do |response|
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

release = request_json(URI("https://api.github.com/repos/#{REPO}/releases/latest"))
tag = release.fetch("tag_name")
match = /\Av(?<version>\d+(?:\.\d+)+)\z/.match(tag)
abort "Unexpected NVM release tag: #{tag}" unless match

latest_version = match[:version]
source = File.read(FORMULA_PATH)
url_pattern = %r{^  url "https://github\.com/nvm-sh/nvm/archive/refs/tags/v(?<version>\d+(?:\.\d+)+)\.tar\.gz"$}
url_match = source.match(url_pattern)
abort "Could not find NVM URL in #{FORMULA_PATH}" unless url_match

if url_match[:version] == latest_version
  puts "nvm is already up to date at #{tag}."
  exit
end

url = "https://github.com/#{REPO}/archive/refs/tags/#{tag}.tar.gz"
sha256 = download_sha256(url)
updated = source.sub(url_pattern, %Q(  url "#{url}"))
sha_pattern = /^  sha256 "[a-f0-9]{64}"$/
abort "Could not find NVM sha256 in #{FORMULA_PATH}" unless updated.match?(sha_pattern)

updated = updated.sub(sha_pattern, %Q(  sha256 "#{sha256}"))
File.write(FORMULA_PATH, updated)
puts "Updated nvm to #{tag}."
