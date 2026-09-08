require "#{HOMEBREW_LIBRARY}/Taps/ly-wo/homebrew-tap/lib/qq_download_strategy"

cask "qq" do
  version "7.0.1_260902_01,9.9.35,110ab2aa"
  sha256 "9d162f0a2f9afc336b0cff073746f51f27cb19d5aeac486b6d448e1eabe8eafe"

  url "https://qqdl.gtimg.cn/qqfile/QQNTV2/#{version.csv.second}/release/#{version.csv.third}/QQ_#{version.csv.first}.dmg",
      using: QQDownloadStrategy
  name "QQ"
  desc "Instant messaging tool"
  homepage "https://im.qq.com/index/#/macos"

  livecheck do
    url "https://im.qq.com/proxy/domain/cdn-go.cn/qq-web/im.qq.com_new/latest/rainbow/pcConfig.json"
    regex(%r{/QQNT(?:V\d+)?/(\d+(?:\.\d+)+)/release/(\h+)/QQ[._-]v?(\d+(?:[._]\d+)+)\.dmg}i)
    strategy :json do |json, regex|
      match = json.dig("macOS", "downloadUrl")&.match(regex)
      next if match.blank?

      "#{match[3]},#{match[1]},#{match[2]}"
    end
  end

  auto_updates true
  depends_on :macos

  app "QQ.app"

  uninstall quit: "com.tencent.qq"

  zap trash: [
    "~/Library/Application Scripts/com.tencent.qq",
    "~/Library/Application Scripts/FN2V63AD2J.com.tencent.localserver2",
    "~/Library/Application Scripts/FN2V63AD2J.com.tencent.ScreenCapture2",
    "~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/com.tencent.qq.sfl*",
    "~/Library/Caches/com.tencent.qq",
    "~/Library/Containers/com.tencent.qq",
    "~/Library/Containers/com.tencent.qq.share",
    "~/Library/Containers/FN2V63AD2J.com.tencent.localserver2",
    "~/Library/Containers/FN2V63AD2J.com.tencent.ScreenCapture2",
    "~/Library/Group Containers/FN2V63AD2J.com.tencent",
    "~/Library/Preferences/com.tencent.qq.plist",
    "~/Library/Saved Application State/com.tencent.qq.savedState",
    "~/Library/WebKit/com.tencent.qq",
  ]
end
