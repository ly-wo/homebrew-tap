cask "iflytek-ime" do
  version "1.1.1006"
  sha256 "5c335335c333730f0de7b4c20ac1f94cbf923873d8701a4845c6254d867e5f51"

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
