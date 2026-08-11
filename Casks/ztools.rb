cask "ztools" do
  arch arm: "arm64", intel: "x64"

  version "3.1.0"
  sha256 arm:   "642471a3a195a7ebac4bf89d2413454d151382ef9addb40c6a66eecef322eb59",
         intel: "3e40630611ceb79fb4d94b1431b4bcbaf43533692f22beac03b114640f088d8c"

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
