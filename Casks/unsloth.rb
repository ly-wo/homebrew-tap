cask "unsloth" do
  version "0.1.815-beta"
  sha256 "ac55b61162389ce5d7004b64807bf16f484eeed885f6e87f0e405dde9ba3929b"

  url "https://github.com/unslothai/unsloth/releases/download/v#{version}/Unsloth-Desktop-MacOS.dmg"
  name "Unsloth"
  name "Unsloth Desktop"
  desc "Run and train AI models locally"
  homepage "https://github.com/unslothai/unsloth"

  livecheck do
    url :url
    regex(/^v?(\d+(?:\.\d+)+-beta)$/i)
    strategy :github_latest do |json, regex|
      json["tag_name"]&.scan(regex)&.map(&:first)
    end
  end

  auto_updates true
  depends_on arch: :arm64
  depends_on macos: :big_sur

  app "Unsloth.app"

  uninstall quit: "ai.unsloth.studio"

  zap trash: [
    "~/.unsloth/studio",
    "~/Library/Application Support/ai.unsloth.studio",
    "~/Library/Caches/ai.unsloth.studio",
    "~/Library/Preferences/ai.unsloth.studio.plist",
    "~/Library/Saved Application State/ai.unsloth.studio.savedState",
    "~/Library/WebKit/ai.unsloth.studio",
  ]

  caveats <<~EOS
    On first launch, Unsloth installs its backend under:
      ~/.unsloth/studio
  EOS
end
