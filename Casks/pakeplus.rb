cask "pakeplus" do
  arch arm: "aarch64", intel: "x64"

  version "2.2.8"
  sha256 arm:   "c3a95a224277ade129e5d8477454477093b3aaddecaf44b70549f17a95bfa8d0",
         intel: "52adefed380214f6021ebc4aa3a63342402845f232c397fa424d559bba79d973"

  url "https://github.com/Sjj1024/PakePlus/releases/download/PakePlus-v#{version}/PakePlus_#{version}_#{arch}.dmg"
  name "PakePlus"
  desc "Package websites and web projects as lightweight desktop and mobile apps"
  homepage "https://github.com/Sjj1024/PakePlus/"

  auto_updates true
  depends_on :macos

  app "PakePlus.app"

  uninstall quit: "com.pakeplus.pacbao"

  zap trash: [
    "~/Library/Application Support/com.pakeplus.pacbao",
    "~/Library/Caches/com.pakeplus.pacbao",
    "~/Library/Preferences/com.pakeplus.pacbao.plist",
    "~/Library/Saved Application State/com.pakeplus.pacbao.savedState",
    "~/Library/WebKit/com.pakeplus.pacbao",
  ]
end
