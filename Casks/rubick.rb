cask "rubick" do
  arch arm: "arm64", intel: "x64"

  version "4.3.8"
  sha256 arm:   "1c61e3c8f9d44b43026f6c432f6b7e26a4fd56dc8cb496d65ce788708dc90595",
         intel: "69c75de2fcc30da7cb7de85c07e6751ddaf54d242bfaa25cddab0fcf0273e4d0"

  url "https://github.com/rubickCenter/rubick/releases/download/v#{version}/rubick-#{version}-#{arch}.dmg"
  name "rubick"
  desc "Open-source toolbox with a plugin ecosystem"
  homepage "https://github.com/rubickCenter/rubick"

  auto_updates true
  depends_on :macos

  app "rubick.app"

  uninstall quit: "com.muwoo.rubick"

  zap trash: [
    "~/Library/Application Support/rubick",
    "~/Library/Caches/com.muwoo.rubick",
    "~/Library/Logs/rubick",
    "~/Library/Preferences/com.muwoo.rubick.plist",
    "~/Library/Saved Application State/com.muwoo.rubick.savedState",
  ]

  caveats <<~EOS
    The upstream application is not code-signed. macOS may require approval in
    System Settings > Privacy & Security before the first launch.
  EOS
end
