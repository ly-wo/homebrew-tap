cask "unihub" do
  arch arm: "arm64", intel: "x64"

  version "1.4.0"
  sha256 arm:   "f03f1f1fe7038b557459426b0deec11c8801f2aa8167685dad7b5e3b28fedc9e",
         intel: "04fc6d1196b4c056ca619e802a367a61be2c08b56b8bc1d2456670c93e9b9502"

  url "https://github.com/t8y2/unihub/releases/download/v#{version}/unihub-#{version}-#{arch}.dmg"
  name "UniHub"
  desc "Cross-platform toolkit with plugin system"
  homepage "https://github.com/t8y2/unihub"

  auto_updates true
  depends_on macos: :monterey

  app "Unihub.app"

  uninstall quit: "com.unihub.app"

  zap trash: [
    "~/Library/Application Support/Unihub",
    "~/Library/Caches/com.unihub.app",
    "~/Library/HTTPStorages/com.unihub.app",
    "~/Library/Logs/Unihub",
    "~/Library/Preferences/com.unihub.app.plist",
    "~/Library/Saved Application State/com.unihub.app.savedState",
  ]

  caveats <<~EOS
    UniHub is not signed or notarized. If macOS blocks it from opening, run:
      xattr -dr com.apple.quarantine "/Applications/Unihub.app"
  EOS
end
