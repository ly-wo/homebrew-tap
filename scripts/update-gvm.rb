#!/usr/bin/env ruby
# frozen_string_literal: true

require "base64"
require "digest"
require "json"
require "net/http"
require "time"
require "uri"

REPO = "moovweb/gvm"
FORMULA_PATH = "Formula/gvm.rb"

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

commit = request_json(URI("https://api.github.com/repos/#{REPO}/commits/master"))
commit_sha = commit.fetch("sha")
committed_at = commit.dig("commit", "committer", "date")
abort "GVM master commit has no committer date" unless committed_at

version_file = request_json(URI("https://api.github.com/repos/#{REPO}/contents/VERSION?ref=#{commit_sha}"))
base_version = Base64.decode64(version_file.fetch("content")).strip
abort "Unexpected GVM version: #{base_version}" unless base_version.match?(/\A\d+(?:\.\d+)+\z/)

timestamp = Time.parse(committed_at).utc.strftime("%Y%m%d%H%M%S")
latest_version = "#{base_version}-#{timestamp}"
source = File.read(FORMULA_PATH)
url_pattern = %r{^  url "https://github\.com/moovweb/gvm/archive/(?<commit>[a-f0-9]{40})\.tar\.gz"$}
version_pattern = /^  version "\d+(?:\.\d+)+-\d{14}"$/
match = source.match(url_pattern)
abort "Could not find GVM URL in #{FORMULA_PATH}" unless match
abort "Could not find GVM version in #{FORMULA_PATH}" unless source.match?(version_pattern)

if match[:commit] == commit_sha && source.match?(/^  version "#{Regexp.escape(latest_version)}"$/)
  puts "gvm is already up to date at #{latest_version} (#{commit_sha[0, 7]})."
  exit
end

url = "https://github.com/#{REPO}/archive/#{commit_sha}.tar.gz"
sha256 = download_sha256(url)
updated = source.sub(url_pattern, %Q(  url "#{url}"))
updated = updated.sub(version_pattern, %Q(  version "#{latest_version}"))
sha_pattern = /^  sha256 "[a-f0-9]{64}"$/
abort "Could not find GVM sha256 in #{FORMULA_PATH}" unless updated.match?(sha_pattern)

updated = updated.sub(sha_pattern, %Q(  sha256 "#{sha256}"))
File.write(FORMULA_PATH, updated)
puts "Updated gvm to #{latest_version}."
