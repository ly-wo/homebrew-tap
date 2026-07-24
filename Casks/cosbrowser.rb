cask "cosbrowser" do
  arch arm: "-arm64", intel: ""

  version "2.12.2"
  sha256 arm:   "b8f20bf471f7c6394f15a0972ba9ca9f4dd724f9c4e4cfeec4556b1a95fb3a06",
         intel: "eaacbb8baccb4efd1ed91ff80721948ffb05bf444103b64f7d28eb80da71e3d3"

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
