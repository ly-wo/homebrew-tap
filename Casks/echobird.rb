cask "echobird" do
  arch arm: "arm64", intel: "x64"

  version "6.1.3"
  sha256 arm:   "12f77bd5b732dceacebf3b65cac47e75d0e38fc748b2b425af044d4366c0004a",
         intel: "524958a6d4ece374f7d898de3813dbb6cf2cd0c4b6094f8a2bbb13b7c4482f2b"

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
