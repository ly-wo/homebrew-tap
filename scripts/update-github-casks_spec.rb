# typed: true
# frozen_string_literal: true

require "minitest/autorun"
require_relative "update-github-casks"

class UpdateGitHubCasksTest < Minitest::Test
  def test_unsloth_uses_the_stable_macos_release_asset_name
    config = CASKS.find { |candidate| candidate.fetch(:name) == "unsloth" }
    raise "Missing Unsloth updater configuration" unless config

    asset_name = config.fetch(:assets).fetch(:arm).call("0.1.804-beta")

    assert_equal "Unsloth-Desktop-MacOS.dmg", asset_name
  end

  def test_unsloth_cask_url_matches_the_release_asset_name
    source = File.read(File.expand_path("../Casks/unsloth.rb", __dir__))

    assert_includes source, "/Unsloth-Desktop-MacOS.dmg"
  end
end
