cask "echobird" do
  arch arm: "arm64", intel: "x64"

  version "6.0.2"
  sha256 arm:   "918b5a64055b208f26bf3e8f10e0b61133d28d41d3d9ed5fb9095e9a4a00ae6d",
         intel: "a4f5047b1088725f9f8c1d0031b7551aebe792d5ca7a8091d90fd667e3ca9201"

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
