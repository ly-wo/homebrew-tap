cask "echobird" do
  arch arm: "arm64", intel: "x64"

  version "6.0.8"
  sha256 arm:   "7af1cab7e59555d9acbfbcf1b5c0e87ca6f64f9d9304fd476f2f2f851ca5ee87",
         intel: "f30242da3567eed0ac451443798471f5948e7baf14d70d1e0e2588cb7f81036b"

  url "https://github.com/edison7009/EchoBird/releases/download/v#{version}/EchoBird_#{version}_macOS_#{arch}.dmg"
  name "EchoBird"
  desc "Manage AI accounts, models and coding tools"
  homepage "https://echobird.ai/"

  livecheck do
    url :url
    regex(/^v?(\d+(?:\.\d+)+)$/i)
    strategy :github_latest do |json, regex|
      json["tag_name"]&.scan(regex)&.map(&:first)
    end
  end

  depends_on :macos

  app "EchoBird.app"

  uninstall quit: "com.echobird.ai"

  zap trash: [
    "~/Library/Application Support/com.echobird.ai",
    "~/Library/Caches/com.echobird.ai",
    "~/Library/HTTPStorages/com.echobird.ai",
    "~/Library/Logs/com.echobird.ai",
    "~/Library/Preferences/com.echobird.ai.plist",
    "~/Library/Saved Application State/com.echobird.ai.savedState",
    "~/Library/WebKit/com.echobird.ai",
  ]

  caveats <<~EOS
    EchoBird is not signed with a Developer ID or notarized. If macOS blocks it
    from opening, run:
      xattr -dr com.apple.quarantine "/Applications/EchoBird.app"
  EOS
end
