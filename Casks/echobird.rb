cask "echobird" do
  arch arm: "arm64", intel: "x64"

  version "6.1.0"
  sha256 arm:   "f4f6462cd6421e2fdb805e5adff9b053bc87723ee9fc7ba59e83a14c92ec43e0",
         intel: "a6149ca0f79cb40d06ba782475a17394581c6e2146a1dcb159a6c8c965bb060c"

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
