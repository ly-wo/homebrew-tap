class EasytierCore < Formula
  desc "Local Homebrew service wrapper for easytier-core"
  homepage "https://github.com/EasyTier/EasyTier"
  url "file:///Users/wanglei/.cargo/bin/easytier-core", using: :nounzip
  version "2.5.0-73b91a4a"
  sha256 "3c63a86c61f89e644103c5285a0c73a12a1ab74d4c85423662844e02f874f515"

  def install
    bin.install "easytier-core"
  end

  def post_install
    (etc/"easytier").mkpath
    (var/"log/easytier").mkpath

    config = etc/"easytier/easytier-core.toml"
    return if config.exist?

    config.write <<~TOML
      # Fill this file before starting the service.
      # Command-line equivalent:
      #   easytier-core --config-file #{etc}/easytier/easytier-core.toml
      #
      # You can also ignore this file and edit the formula service block to use:
      #   --config-server, --network-name, --network-secret, --ipv4, --dhcp, --peers, etc.
    TOML
  end

  def caveats
    <<~EOS
      Config file:
        #{etc}/easytier/easytier-core.toml

      Start at boot:
        sudo brew services start easytier-core

      Restart:
        sudo brew services restart easytier-core

      Stop:
        sudo brew services stop easytier-core

      Logs:
        #{var}/log/easytier/easytier-core.stdout.log
        #{var}/log/easytier/easytier-core.stderr.log
    EOS
  end

  service do
    run [
      opt_bin/"easytier-core",
      "--config-file", etc/"easytier/easytier-core.toml",
      "--file-log-dir", var/"log/easytier",
      "--file-log-level", "info",
      "--console-log-level", "info",
    ]
    keep_alive true
    require_root true
    log_path var/"log/easytier/easytier-core.stdout.log"
    error_log_path var/"log/easytier/easytier-core.stderr.log"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/easytier-core --version")
  end
end
