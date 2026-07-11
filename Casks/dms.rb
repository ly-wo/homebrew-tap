cask "dms" do
  version :latest
  sha256 :no_check

  url "https://public-buk.oss-cn-hangzhou.aliyuncs.com/dms/dms-desktop/DMS-mac.dmg",
      verified: "public-buk.oss-cn-hangzhou.aliyuncs.com/dms/dms-desktop/"
  name "DMS"
  desc "Desktop client for Alibaba Cloud Data Management Service"
  homepage "https://help.aliyun.com/zh/dms/"

  depends_on :macos

  app "DMS.app"

  uninstall quit: "com.electron.dms.1.0.0"

  zap trash: [
    "~/Library/Application Support/DMS",
    "~/Library/Caches/com.electron.dms.1.0.0",
    "~/Library/Caches/DMS",
    "~/Library/Logs/DMS",
    "~/Library/Preferences/com.electron.dms.1.0.0.plist",
    "~/Library/Saved Application State/com.electron.dms.1.0.0.savedState",
  ]

  caveats do
    requires_rosetta
  end
end
