# typed: true
# frozen_string_literal: true

require "json"
require "net/http"
require "uri"

module QQDownload
  SIGN_URL = "https://im.qq.com/http2rpc/gotrpc/noauth/trpc.qqntv2.urlsign.UrlSign/GetSign"

  def self.signed_url(url, http: Net::HTTP)
    original = URI(url)
    if original.scheme != "https" || original.host != "qqdl.gtimg.cn" ||
       !original.path.to_s.start_with?("/qqfile/")
      raise "Unexpected QQ download URL"
    end

    uri = URI(SIGN_URL)
    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request["x-oidb"] = JSON.generate(uint32_command: "0x9b8e", uint32_service_type: 1)
    request.body = JSON.generate(url:)
    response = http.start(uri.hostname, uri.port, use_ssl: true, open_timeout: 15, read_timeout: 30) do |connection|
      connection.request(request)
    end
    raise "QQ download signing failed (HTTP #{response.code})" unless response.is_a?(Net::HTTPSuccess)

    result = JSON.parse(response.body.to_s)
    signed_url = result.dig("data", "url")
    if result["retcode"] != 0 || !signed_url.is_a?(String) || signed_url.empty?
      raise "QQ download signing returned no download URL"
    end

    signed = URI(signed_url)
    if signed.scheme != "https" || signed.host != original.host || signed.path != original.path
      raise "QQ download signing returned an unexpected URL"
    end

    signed_url
  end
end
