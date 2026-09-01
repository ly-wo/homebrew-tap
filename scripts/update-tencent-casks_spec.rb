# typed: true
# frozen_string_literal: true

require "minitest/autorun"
require_relative "update-tencent-casks"

class UpdateTencentCasksTest < Minitest::Test
  QQNTV2_URL = "https://qqdl.gtimg.cn/qqfile/QQNTV2/9.9.33/release/126b7ce6/QQ_7.0.0_260812_01.dmg"
  QQNT_URL = "https://qqdl.gtimg.cn/qqfile/QQNT/9.9.33/release/126b7ce6/QQ_7.0.0_260812_01.dmg"

  def test_qq_matches_the_current_release_url
    match = QQ_URL_PATTERN.match(QQNTV2_URL)

    refute_nil match
    assert_equal ["9.9.33", "126b7ce6", "7.0.0_260812_01"], match.values_at(:release, :hash, :version)
  end

  def test_qq_uses_the_downloadable_release_url
    assert_equal QQNT_URL, qq_download_url(QQNTV2_URL)
  end

  def test_qq_cask_uses_the_downloadable_release_path
    source = File.read(File.expand_path("../Casks/qq.rb", __dir__))

    assert_equal 2, source.scan("/QQNT/").length
  end

  def test_qq_livecheck_matches_the_current_release_path
    source = File.read(File.expand_path("../Casks/qq.rb", __dir__))

    assert_equal 1, source.scan("/QQNTV2/").length
  end
end
