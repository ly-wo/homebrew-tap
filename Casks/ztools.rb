cask "ztools" do
  arch arm: "arm64", intel: "x64"

  version "3.0.2"
  sha256 arm:   "532c1bfda71a1845d0f6b6f8cf03f8457bbd258c8303d0a8c6a57cc09ada748c",
         intel: "8e928414c780e259a5167dbe200e90b9644d7f4913cad10873d9a66ba55e9928"

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
