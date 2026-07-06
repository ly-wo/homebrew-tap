cask "easytier-gui" do
  arch arm: "aarch64", intel: "x64"

  version "2.6.4"

  on_arm do
    sha256 "29358d4b565f890b872c72092aa6391636700aae229b3a6baedaf9544b1d1407"
  end

  on_intel do
    sha256 "f1ea217767ba88cd1b084d597359fd7e74ab17acb636fa1d8bf1c5441f726036"
  end

  url "https://github.com/EasyTier/EasyTier/releases/download/v#{version}/easytier-gui_#{version}_#{arch}.dmg"
  name "EasyTier GUI"
  desc "GUI client for the EasyTier decentralized mesh VPN"
  homepage "https://github.com/EasyTier/EasyTier"

  depends_on :macos

  app "easytier-gui.app"

  zap trash: [
    "~/Library/Application Support/com.kkrainbow.easytier",
    "~/Library/Caches/com.kkrainbow.easytier",
    "~/Library/Preferences/com.kkrainbow.easytier.plist",
    "~/Library/Saved Application State/com.kkrainbow.easytier.savedState",
  ]
end
