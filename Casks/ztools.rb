cask "ztools" do
  arch arm: "arm64", intel: "x64"

  version "3.0.1"
  sha256 arm:   "5370cc9f118b8bf04141002eb7c9285e1069d19494d6fc65eff3b54750ed76d9",
         intel: "3d742c8004c4ead19b50b23d010135338b4226d4a243127f4d558536b2b3ef75"

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
