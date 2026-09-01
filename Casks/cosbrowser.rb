cask "cosbrowser" do
  arch arm: "-arm64", intel: ""

  version "2.13.1"
  sha256 arm:   "00c4dc1dc939da6ca198b909d38761d606f056063df72ca7de244a4cbe089970",
         intel: "7ac3ee97807d7f8a1c0914369b3b0177376b9149b8c437c54761c48cae6c115f"

  url "https://cosbrowser-1253960454.cos.ap-shanghai.myqcloud.com/releases/cosbrowser-#{version}#{arch}.dmg",
      verified: "cosbrowser-1253960454.cos.ap-shanghai.myqcloud.com/releases/"
  name "COSBrowser"
  desc "Desktop client for managing Tencent Cloud Object Storage resources"
  homepage "https://cloud.tencent.com/document/product/436/11366"

  livecheck do
    url "https://cosbrowser.cloud.tencent.com/cosbrowser-latest#{arch}.dmg"
    regex(/cosbrowser[._-]v?(\d+(?:\.\d+)+)(?:-arm64)?\.dmg/i)
    strategy :header_match
  end

  auto_updates true
  depends_on :macos

  app "cosbrowser.app"

  uninstall quit: "com.tencent.cosbrowser"

  zap trash: [
    "~/Library/Application Support/cosbrowser",
    "~/Library/Caches/com.tencent.cosbrowser",
    "~/Library/Logs/cosbrowser",
    "~/Library/Preferences/com.tencent.cosbrowser.plist",
    "~/Library/Saved Application State/com.tencent.cosbrowser.savedState",
  ]
end
