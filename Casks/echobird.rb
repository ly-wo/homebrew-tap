cask "echobird" do
  arch arm: "arm64", intel: "x64"

  version "6.0.6"
  sha256 arm:   "b354d81b8cc250ea4a8a8668767139cb70e289e047a79f73637af645f33fc031",
         intel: "f99e284688723e02121ae54650ec6b01677c37176f62c1dd311d51e273bbe489"

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
