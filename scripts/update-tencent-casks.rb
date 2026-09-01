#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "json"
require "net/http"
require "rexml/document"
require "uri"

WECHAT_PATH = "Casks/wechat.rb"
WECHAT_FEED = "https://dldir1.qq.com/weixin/mac/mac-release.xml"
WECHATWORK_PATH = "Casks/wechatwork.rb"
WECHATWORK_LATEST_URLS = {
  arm:   "https://work.weixin.qq.com/wework_admin/commdownload?platform=mac_arm64",
  intel: "https://work.weixin.qq.com/wework_admin/commdownload?platform=mac",
}.freeze
QQ_PATH = "Casks/qq.rb"
QQ_CONFIG = "https://im.qq.com/proxy/domain/cdn-go.cn/qq-web/im.qq.com_new/latest/rainbow/pcConfig.json"
QQ_URL_PATTERN = %r{/QQNTV2/(?<release>\d+(?:\.\d+)+)/release/(?<hash>[a-f0-9]+)/QQ_(?<version>\d+(?:[._]\d+)+)\.dmg}i

def request(uri)
  request = Net::HTTP::Get.new(uri)
  request["User-Agent"] = "homebrew-tap-updater"

  Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
    http.request(request)
  end
end

def request_body(url)
  response = request(URI(url))
  abort "Request failed for #{url}: #{response.code} #{response.message}" unless response.is_a?(Net::HTTPSuccess)

  response.body
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

def update_wechat
  document = REXML::Document.new(request_body(WECHAT_FEED))
  release = document.elements.to_a("rss/channel/item").filter_map do |item|
    enclosure = item.elements["enclosure"]
    next unless enclosure

    url = enclosure.attributes.fetch("url", nil)&.to_s
    next unless url

    match = %r{/xWeChatMac_universal_(?<version>\d+(?:\.\d+)+)_(?<build>\d+)\.dmg}.match(url)
    next unless match

    {
      version: "#{match[:version]},#{match[:build]}",
      url:     url,
    }
  end.first
  abort "Latest WeChat release not found" unless release

  source = File.read(WECHAT_PATH)
  version_pattern = /^  version "(?<version>\d+(?:\.\d+)+,\d+)"$/
  current = source.match(version_pattern)
  abort "Could not find WeChat version in #{WECHAT_PATH}" unless current

  if current[:version] == release.fetch(:version)
    puts "wechat is already up to date at #{current[:version]}."
    return
  end

  sha256 = download_sha256(release.fetch(:url))
  sha_pattern = /^  sha256 "[a-f0-9]{64}"$/
  abort "Could not find WeChat checksum in #{WECHAT_PATH}" unless source.match?(sha_pattern)

  updated = source.sub(version_pattern, %Q(  version "#{release.fetch(:version)}"))
  updated = updated.sub(sha_pattern, %Q(  sha256 "#{sha256}"))
  File.write(WECHAT_PATH, updated)
  puts "Updated wechat to #{release.fetch(:version)}."
end

def wechatwork_release(url)
  response = request(URI(url))
  unless response.is_a?(Net::HTTPRedirection)
    abort "Latest WeCom release request failed: #{response.code} #{response.message}"
  end

  release_url = URI.join(url, response.fetch("location")).to_s
  match = %r{/WeCom_(?<version>\d+(?:\.\d+)+)_(?:Apple|Intel)\.dmg\z}.match(release_url)
  abort "Unexpected WeCom release URL: #{release_url}" unless match

  {
    version: match[:version],
    url:     release_url,
  }
end

def update_wechatwork
  releases = WECHATWORK_LATEST_URLS.transform_values { |url| wechatwork_release(url) }
  source = File.read(WECHATWORK_PATH)
  current_versions = releases.keys.to_h do |architecture|
    pattern = /  on_#{architecture} do\n    version "(?<version>\d+(?:\.\d+)+)"/
    match = source.match(pattern)
    abort "Could not find WeCom #{architecture} version in #{WECHATWORK_PATH}" unless match

    [architecture, match[:version]]
  end
  latest_versions = releases.transform_values { |release| release.fetch(:version) }

  if current_versions == latest_versions
    puts "wechatwork is already up to date at #{latest_versions.inspect}."
    return
  end

  shas = releases.transform_values { |release| download_sha256(release.fetch(:url)) }
  updated = releases.keys.reduce(source) do |contents, architecture|
    block_pattern = /(  on_#{architecture} do\n    version ")[^"]+("\n    sha256 ")[a-f0-9]{64}("\n  end)/
    abort "Could not find WeCom #{architecture} block in #{WECHATWORK_PATH}" unless contents.match?(block_pattern)

    contents.sub(block_pattern) do
      "#{Regexp.last_match(1)}#{latest_versions.fetch(architecture)}" \
        "#{Regexp.last_match(2)}#{shas.fetch(architecture)}#{Regexp.last_match(3)}"
    end
  end
  File.write(WECHATWORK_PATH, updated)
  puts "Updated wechatwork to #{latest_versions.inspect}."
end

def qq_download_url(url)
  url.sub("/QQNTV2/", "/QQNT/")
end

def update_qq
  json = JSON.parse(request_body(QQ_CONFIG))
  download_url = json.dig("macOS", "downloadUrl")
  match = QQ_URL_PATTERN.match(download_url.to_s)
  abort "Latest QQ release not found" unless match

  version = "#{match[:version]},#{match[:release]},#{match[:hash]}"
  source = File.read(QQ_PATH)
  version_pattern = /^  version "(?<version>[^"]+)"$/
  current = source.match(version_pattern)
  abort "Could not find QQ version in #{QQ_PATH}" unless current

  if current[:version] == version
    puts "qq is already up to date at #{version}."
    return
  end

  sha256 = download_sha256(qq_download_url(download_url))
  sha_pattern = /^  sha256 "[a-f0-9]{64}"$/
  abort "Could not find QQ checksum in #{QQ_PATH}" unless source.match?(sha_pattern)

  updated = source.sub(version_pattern, %Q(  version "#{version}"))
  updated = updated.sub(sha_pattern, %Q(  sha256 "#{sha256}"))
  File.write(QQ_PATH, updated)
  puts "Updated qq to #{version}."
end

if $PROGRAM_NAME == __FILE__
  update_wechat
  update_wechatwork
  update_qq
end
