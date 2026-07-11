cask "ztools" do
  arch arm: "arm64", intel: "x64"

  version "2.6.1"
  sha256 arm:   "e264514ace77ce3cb0784e2eb070a92404b20bcb8c310d17f4d041ce822b8ece",
         intel: "432f1ac89a0d74847912c276a6c4716ffa826437f91b5cfed7c75d875d3a0dbb"

  url "https://github.com/ZToolsCenter/ZTools/releases/download/v#{version}/ZTools-#{version}-mac-#{arch}.dmg"
  name "ZTools"
  desc "Extensible application launcher and plugin platform"
  homepage "https://github.com/ZToolsCenter/ZTools"

  auto_updates true
  depends_on macos: :monterey

  app "ZTools.app"

  uninstall quit: "link.eiot.ztools"

  zap trash: [
    "~/Library/Application Support/ZTools",
    "~/Library/Caches/link.eiot.ztools",
    "~/Library/Logs/ZTools",
    "~/Library/Preferences/link.eiot.ztools.plist",
    "~/Library/Saved Application State/link.eiot.ztools.savedState",
  ]

  caveats <<~EOS
    The upstream application is not code-signed. macOS may require approval in
    System Settings > Privacy & Security before the first launch.
  EOS
end
