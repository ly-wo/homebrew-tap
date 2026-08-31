cask "ztools" do
  arch arm: "arm64", intel: "x64"

  version "3.2.0"
  sha256 arm:   "837acc417fe02500a00d3f59f4f1c3630a5414d62c411df1bbb98a6a7913ac78",
         intel: "a382dc4deb7e6154a5fe7f005235ff05d8b85d32822d78247e0c083554a5c852"

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
