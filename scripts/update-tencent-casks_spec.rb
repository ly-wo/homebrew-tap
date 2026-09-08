# typed: true
# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require_relative "update-tencent-casks"

class UpdateTencentCasksTest < Minitest::Test
  QQNTV2_URL = "https://qqdl.gtimg.cn/qqfile/QQNTV2/9.9.35/release/110ab2aa/QQ_7.0.1_260902_01.dmg"
  QQNT_URL = QQNTV2_URL.sub("/QQNTV2/", "/QQNT/").freeze
  QQNTV2_TEMPLATE = "https://qqdl.gtimg.cn/qqfile/QQNTV2/\#{version.csv.second}" \
                    "/release/\#{version.csv.third}/QQ_\#{version.csv.first}.dmg"
  SIGNED_URL = "#{QQNTV2_URL}?sign=test-signature&t=test-timestamp".freeze
  VERSION = "7.0.1_260902_01,9.9.35,110ab2aa"
  CHECKSUM = "a" * 64

  class Updater
    attr_reader :downloads

    def initialize
      @downloads = []
    end

    def request_body(_url)
      { "macOS" => { "downloadUrl" => QQNTV2_URL } }.to_json
    end

    def tencent_download_sha256(url)
      @downloads << url
      CHECKSUM
    end

    def qq_download_url(url)
      "#{url}?sign=test-signature&t=test-timestamp"
    end

    def run
      update_qq
    end
  end

  class SigningHTTP
    attr_reader :requests

    def initialize(response)
      @response = response
      @requests = []
    end

    def start(*_args, **_options)
      yield self
    end

    def request(request)
      @requests << request
      @response
    end
  end

  class SigningResponse < Net::HTTPOK
    attr_accessor :body
  end

  class FailedUpdater < Updater
    def qq_download_url(_url)
      raise "QQ download signing failed"
    end
  end

  def with_cask(version:, url:)
    Dir.mktmpdir("qq-updater-test") do |directory|
      Dir.chdir(directory) do
        Dir.mkdir("Casks")
        File.write(QQ_PATH, <<~RUBY)
          cask "qq" do
            version "#{version}"
            sha256 "#{"b" * 64}"
            url "#{url}",
                using: QQDownloadStrategy
          end
        RUBY
        yield
      end
    end
  end

  def test_qq_matches_the_current_release_url
    match = QQ_URL_PATTERN.match(QQNTV2_URL)

    refute_nil match
    assert_equal ["9.9.35", "110ab2aa", "7.0.1_260902_01"], match.values_at(:release, :hash, :version)
  end

  def test_qq_accepts_legacy_release_paths
    refute_nil QQ_URL_PATTERN.match(QQNT_URL)
  end

  def test_qq_obtains_a_fresh_signature_from_the_official_api
    response = SigningResponse.new("1.1", "200", "OK")
    response.body = { "retcode" => 0, "data" => { "url" => SIGNED_URL } }.to_json
    http = SigningHTTP.new(response)

    2.times { assert_equal SIGNED_URL, QQDownload.signed_url(QQNTV2_URL, http:) }
    assert_equal 2, http.requests.length
    request = http.requests.first
    assert_instance_of Net::HTTP::Post, request
    assert_equal URI(QQDownload::SIGN_URL).path, request.path
    assert_equal({ "url" => QQNTV2_URL }, JSON.parse(request.body))
    assert_equal({ "uint32_command" => "0x9b8e", "uint32_service_type" => 1 }, JSON.parse(request["x-oidb"]))
  end

  def test_qq_rejects_a_failed_signing_response
    response = SigningResponse.new("1.1", "200", "OK")
    response.body = { "retcode" => 1 }.to_json

    assert_raises(RuntimeError) { QQDownload.signed_url(QQNTV2_URL, http: SigningHTTP.new(response)) }
  end

  def test_qq_rejects_a_signed_url_for_another_download
    response = SigningResponse.new("1.1", "200", "OK")
    response.body = { "retcode" => 0, "data" => { "url" => SIGNED_URL.sub("qqdl.gtimg.cn", "example.com") } }.to_json

    assert_raises(RuntimeError) { QQDownload.signed_url(QQNTV2_URL, http: SigningHTTP.new(response)) }
  end

  def test_qq_does_not_modify_the_cask_when_signing_fails
    with_cask(version: "7.0.0_260812_01,9.9.33,126b7ce6", url: QQNT_URL) do
      updater = FailedUpdater.new
      source = File.read(QQ_PATH)
      assert_raises(RuntimeError) { updater.run }
      assert_empty updater.downloads
      assert_equal source, File.read(QQ_PATH)
    end
  end

  def test_qq_updates_the_version_checksum_and_unsigned_url
    with_cask(version: "7.0.0_260812_01,9.9.33,126b7ce6", url: QQNT_URL) do
      updater = Updater.new
      capture_io { updater.run }
      assert_equal [SIGNED_URL], updater.downloads
      source = File.read(QQ_PATH)
      assert_includes source, %Q(version "#{VERSION}")
      assert_includes source, %Q(sha256 "#{CHECKSUM}")
      assert_includes source, %Q(url "#{QQNTV2_TEMPLATE}")
      refute_includes source, "sign="
    end
  end

  def test_qq_updates_a_changed_url_even_when_the_version_is_unchanged
    with_cask(version: VERSION, url: QQNT_URL) do
      updater = Updater.new
      capture_io { updater.run }
      assert_equal [SIGNED_URL], updater.downloads
      assert_includes File.read(QQ_PATH), %Q(url "#{QQNTV2_TEMPLATE}")
    end
  end

  def test_qq_skips_an_unchanged_release_without_downloading
    with_cask(version: VERSION, url: QQNTV2_TEMPLATE) do
      updater = Updater.new
      source = File.read(QQ_PATH)
      capture_io { updater.run }
      assert_empty updater.downloads
      assert_equal source, File.read(QQ_PATH)
    end
  end
end
