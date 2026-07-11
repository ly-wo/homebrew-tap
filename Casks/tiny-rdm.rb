cask "tiny-rdm" do
  arch arm: "arm64", intel: "intel"

  version "1.2.7"
  sha256 arm:   "aaebc58a1f97505743bf05f2ab1cfc5e7c3e5841d90266ad836eaab74435f1a3",
         intel: "3d8e61fa474ae50b61e41a623841fcdd7629615fa105758f2840fff75fe857ad"

  url "https://github.com/tiny-craft/tiny-rdm/releases/download/v#{version}/TinyRDM_#{version}_mac_#{arch}.dmg"
  name "Tiny RDM"
  desc "Lightweight cross-platform Redis desktop manager"
  homepage "https://github.com/tiny-craft/tiny-rdm"

  depends_on macos: :big_sur

  app "Tiny RDM.app"

  uninstall quit: "com.tinycraft.tinyrdm"

  zap trash: [
    "~/Library/Application Support/com.tinycraft.tinyrdm",
    "~/Library/Caches/com.tinycraft.tinyrdm",
    "~/Library/Preferences/com.tinycraft.tinyrdm.plist",
    "~/Library/Preferences/TinyRDM",
    "~/Library/Saved Application State/com.tinycraft.tinyrdm.savedState",
    "~/Library/WebKit/com.tinycraft.tinyrdm",
  ]

  caveats <<~EOS
    The upstream application uses an ad-hoc signature. macOS may require
    approval in System Settings > Privacy & Security before the first launch.
  EOS
end
