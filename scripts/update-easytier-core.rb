#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "json"
require "net/http"
require "uri"

REPO = ENV.fetch("EASYTIER_REPO", "EasyTier/EasyTier")
FORMULA_PATH = ENV.fetch("FORMULA_PATH", "Formula/easytier-core.rb")
CORE_ARCHES = {
  "aarch64" => "easytier-macos-aarch64",
  "x86_64" => "easytier-macos-x86_64",
}.freeze
GUI_CASK_PATH = ENV.fetch("GUI_CASK_PATH", "Casks/easytier-gui.rb")
GUI_ARCHES = {
  "aarch64" => "on_arm",
  "x64" => "on_intel",
}.freeze

def request_json(uri)
  request = Net::HTTP::Get.new(uri)
  request["Accept"] = "application/vnd.github+json"
  request["User-Agent"] = "homebrew-tap-updater"
  request["X-GitHub-Api-Version"] = "2022-11-28"
  token = ENV["GITHUB_TOKEN"] || ENV["GH_TOKEN"]
  request["Authorization"] = "Bearer #{token}" if token && !token.empty?

  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
    http.request(request)
  end

  abort "GitHub API request failed: #{response.code} #{response.message}\n#{response.body}" unless response.is_a?(Net::HTTPSuccess)

  JSON.parse(response.body)
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
abort "Latest release tag must start with v: #{tag}" unless tag.start_with?("v")

version = tag.delete_prefix("v")
assets = release.fetch("assets").to_h { |asset| [asset.fetch("name"), asset] }

def asset_update(assets, asset_name)
  asset = assets[asset_name]
  abort "Missing release asset: #{asset_name}" unless asset

  digest = asset["digest"]
  sha256 = if digest&.start_with?("sha256:")
    digest.delete_prefix("sha256:")
  else
    download_sha256(asset.fetch("browser_download_url"))
  end

  {
    url: asset.fetch("browser_download_url"),
    sha256: sha256,
  }
end

core_updates = CORE_ARCHES.transform_values do |prefix|
  asset_name = "#{prefix}-#{tag}.zip"
  asset_update(assets, asset_name)
end

formula = File.read(FORMULA_PATH)
updated = formula.dup

core_updates.each do |arch, metadata|
  escaped_arch = Regexp.escape(arch)
  url_pattern = /url "https:\/\/github\.com\/EasyTier\/EasyTier\/releases\/download\/v[^"]+\/easytier-macos-#{escaped_arch}-v[^"]+\.zip"/
  sha_pattern = /(url "https:\/\/github\.com\/EasyTier\/EasyTier\/releases\/download\/v[^"]+\/easytier-macos-#{escaped_arch}-v[^"]+\.zip"\n\s+)sha256 "[a-f0-9]{64}"/

  abort "Could not find #{arch} URL in #{FORMULA_PATH}" unless updated.match?(url_pattern)
  abort "Could not find #{arch} sha256 in #{FORMULA_PATH}" unless updated.match?(sha_pattern)

  updated = updated.sub(url_pattern, %(url "#{metadata[:url]}"))
  updated = updated.sub(sha_pattern, %(\\1sha256 "#{metadata[:sha256]}"))
end

if updated == formula
  puts "easytier-core is already up to date at #{tag}."
else
  File.write(FORMULA_PATH, updated)
  puts "Updated easytier-core formula to #{tag}."
end

gui_updates = GUI_ARCHES.keys.to_h do |arch|
  asset_name = "easytier-gui_#{version}_#{arch}.dmg"
  [arch, asset_update(assets, asset_name)]
end

cask = File.read(GUI_CASK_PATH)
updated_cask = cask.dup
version_pattern = /version "[^"]+"/
abort "Could not find GUI cask version in #{GUI_CASK_PATH}" unless updated_cask.match?(version_pattern)

updated_cask = updated_cask.sub(version_pattern, %(version "#{version}"))

gui_updates.each do |arch, metadata|
  block_name = GUI_ARCHES.fetch(arch)
  sha_pattern = /(#{block_name} do\n\s+)sha256 "[a-f0-9]{64}"/

  abort "Could not find #{block_name} sha256 in #{GUI_CASK_PATH}" unless updated_cask.match?(sha_pattern)

  updated_cask = updated_cask.sub(sha_pattern, %(\\1sha256 "#{metadata[:sha256]}"))
end

if updated_cask == cask
  puts "easytier-gui cask is already up to date at #{tag}."
else
  File.write(GUI_CASK_PATH, updated_cask)
  puts "Updated easytier-gui cask to #{tag}."
end
