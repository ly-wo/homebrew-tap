# typed: true
# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require_relative "update-github-casks"

class UpdateGitHubCasksTest < Minitest::Test
  class Updater
    def initialize(release)
      @release = release
    end

    def github_casks_request_json(_uri)
      @release
    end

    def run(config)
      update_github_cask(config)
    end
  end

  def bambu_studio_config
    CASKS.find { |candidate| candidate.fetch(:name) == "bambu-studio" } ||
      raise("Missing Bambu Studio updater configuration")
  end

  def test_bambu_studio_updates_the_build_timestamp_and_checksum
    release = {
      "tag_name" => "v02.08.02.61",
      "assets"   => [
        { "name" => "Bambu_Studio_win-v02.08.02.61.exe" },
        {
          "name"   => "Bambu_Studio_mac-v02.08.02.61-20260820225108.dmg",
          "digest" => "sha256:#{"a" * 64}",
        },
      ],
    }
    Dir.mktmpdir("bambu-studio-test") do |directory|
      path = File.join(directory, "bambu-studio.rb")
      File.write(path, <<~RUBY)
        cask "bambu-studio" do
          version "02.07.01.57,20260601165745"
          sha256 "#{"b" * 64}"
        end
      RUBY
      capture_io { Updater.new(release).run(bambu_studio_config.merge(path:)) }

      assert_equal <<~RUBY, File.read(path)
        cask "bambu-studio" do
          version "02.08.02.61,20260820225108"
          sha256 "#{"a" * 64}"
        end
      RUBY
    end
  end

  def test_bambu_studio_preserves_a_different_release_tag
    version = bambu_studio_config.fetch(:version_from_release).call(
      "tag_name" => "v02.08.02.62",
      "assets"   => [{ "name" => "Bambu_Studio_mac-v02.08.02.61-20260820225108.dmg" }],
    )

    assert_equal "02.08.02.61,20260820225108,02.08.02.62", version
  end

  def test_bambu_studio_rejects_a_release_without_a_macos_package
    capture_io do
      assert_raises(SystemExit) do
        bambu_studio_config.fetch(:version_from_release).call(
          "tag_name" => "v02.08.02.61",
          "assets"   => [{ "name" => "Bambu_Studio_win-v02.08.02.61.exe" }],
        )
      end
    end
  end

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
