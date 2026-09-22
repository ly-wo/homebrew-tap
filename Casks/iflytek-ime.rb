cask "iflytek-ime" do
  version "1.1.1008"
  sha256 "caed7d97a9f8ad50e57cb4c65065a5e59e95a5c23f3304e18c49b2c6552cd178"

  url "https://download.voicecloud.cn/200ime/iFlytekIMEInstaller_#{version}_Mac.zip",
      user_agent: :browser
  name "iFlytek Input Method"
  name "讯飞输入法"
  desc "Chinese input method with voice, handwriting, and Pinyin input"
  homepage "https://srf.xunfei.cn/"

  livecheck do
    url "https://srf.xunfei.cn/mac"
    regex(/iFlytekIMEInstaller[._-]v?(\d+(?:\.\d+)+)[._-]Mac\.zip/i)
    strategy :header_match
  end

  auto_updates true
  depends_on macos: :catalina

  installer manual: "iFlytekIMEInstaller_#{version}.app"

  uninstall quit:   "com.iflytek.inputmethod.iFlytekIME",
            delete: "/Library/Input Methods/iFlytekIME.app"

  zap trash: [
    "~/Library/Application Scripts/com.iflytek.inputmethod.iFlytekIME",
    "~/Library/Application Scripts/QM72BQYUL3.com.iflytek.iFlytekIME",
    "~/Library/Caches/com.iflytek.iFlytekIME.iFlytekIMEInstaller",
    "~/Library/Containers/com.iflytek.inputmethod.iFlytekIME",
    "~/Library/Group Containers/QM72BQYUL3.com.iflytek.iFlytekIME",
    "~/Library/HTTPStorages/com.iflytek.iFlytekIME.iFlytekIMEInstaller",
  ]
end
