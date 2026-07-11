#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "json"
require "net/http"
require "uri"

CASKS = [
  {
    name:        "pakeplus",
    repo:        "Sjj1024/PakePlus",
    path:        "Casks/pakeplus.rb",
    tag_pattern: /\APakePlus-v(?<version>\d+(?:\.\d+)+)\z/,
    assets:      {
      arm:   ->(version) { "PakePlus_#{version}_aarch64.dmg" },
      intel: ->(version) { "PakePlus_#{version}_x64.dmg" },
    },
  },
  {
    name:        "ztools",
    repo:        "ZToolsCenter/ZTools",
    path:        "Casks/ztools.rb",
    tag_pattern: /\Av(?<version>\d+(?:\.\d+)+)\z/,
    assets:      {
      arm:   ->(version) { "ZTools-#{version}-mac-arm64.dmg" },
      intel: ->(version) { "ZTools-#{version}-mac-x64.dmg" },
    },
  },
  {
    name:        "rubick",
    repo:        "rubickCenter/rubick",
    path:        "Casks/rubick.rb",
    tag_pattern: /\Av(?<version>\d+(?:\.\d+)+)\z/,
    assets:      {
      arm:   ->(version) { "rubick-#{version}-arm64.dmg" },
      intel: ->(version) { "rubick-#{version}-x64.dmg" },
    },
  },
  {
    name:        "tiny-rdm",
    repo:        "tiny-craft/tiny-rdm",
    path:        "Casks/tiny-rdm.rb",
    tag_pattern: /\Av(?<version>\d+(?:\.\d+)+)\z/,
    assets:      {
      arm:   ->(version) { "TinyRDM_#{version}_mac_arm64.dmg" },
      intel: ->(version) { "TinyRDM_#{version}_mac_intel.dmg" },
    },
  },
].freeze

def request_json(uri)
  request = Net::HTTP::Get.new(uri)
  request["Accept"] = "application/vnd.github+json"
  request["User-Agent"] = "homebrew-tap-updater"
  request["X-GitHub-Api-Version"] = "2022-11-28"
  token = ENV.fetch("GITHUB_TOKEN", ENV.fetch("GH_TOKEN", nil))
  request["Authorization"] = "Bearer #{token}" if token&.length&.positive?

  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
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

def asset_sha256(asset)
  digest = asset["digest"]
  return digest.delete_prefix("sha256:") if digest&.start_with?("sha256:")

  download_sha256(asset.fetch("browser_download_url"))
end

def update_cask(config)
  release = request_json(URI("https://api.github.com/repos/#{config.fetch(:repo)}/releases/latest"))
  tag = release.fetch("tag_name")
  match = config.fetch(:tag_pattern).match(tag)
  abort "Unexpected #{config.fetch(:name)} release tag: #{tag}" unless match

  version = match[:version]
  assets = release.fetch("assets").to_h { |asset| [asset.fetch("name"), asset] }
  shas = config.fetch(:assets).to_h do |arch, asset_name|
    name = asset_name.call(version)
    asset = assets[name]
    abort "Missing #{config.fetch(:name)} release asset: #{name}" unless asset

    [arch, asset_sha256(asset)]
  end

  path = config.fetch(:path)
  source = File.read(path)
  version_pattern = /^  version "[^"]+"$/
  sha_pattern = /^  sha256 arm:\s+"[a-f0-9]{64}",\n\s+intel: "[a-f0-9]{64}"$/

  abort "Could not find version in #{path}" unless source.match?(version_pattern)
  abort "Could not find architecture checksums in #{path}" unless source.match?(sha_pattern)

  updated = source.sub(version_pattern, %Q(  version "#{version}"))
  updated = updated.sub(
    sha_pattern,
    %Q(  sha256 arm:   "#{shas.fetch(:arm)}",\n         intel: "#{shas.fetch(:intel)}"),
  )

  if updated == source
    puts "#{config.fetch(:name)} is already up to date at #{tag}."
  else
    File.write(path, updated)
    puts "Updated #{config.fetch(:name)} to #{tag}."
  end
end

CASKS.each { |config| update_cask(config) }
