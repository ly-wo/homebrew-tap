class EasytierCore < Formula
  desc "Decentralized mesh VPN with WireGuard support"
  homepage "https://github.com/EasyTier/EasyTier"
  license "LGPL-3.0-only"

  depends_on :macos

  on_arm do
    on_macos do
      url "https://github.com/EasyTier/EasyTier/releases/download/v2.6.4/easytier-macos-aarch64-v2.6.4.zip"
      sha256 "4be1882d1aa36d31c1d6ba0596f2cf8a097e371f8da124212324b2e0f8df7e4b"
    end
  end

  on_intel do
    on_macos do
      url "https://github.com/EasyTier/EasyTier/releases/download/v2.6.4/easytier-macos-x86_64-v2.6.4.zip"
      sha256 "89fc28a6e6995259d76ce3f11775220e8a21c760e94df91a6a9db30a69b6982e"
    end
  end

  def install
    core = if (buildpath/"easytier-core").exist?
      buildpath/"easytier-core"
    else
      Dir["easytier-macos-*/easytier-core"].first
    end

    odie "easytier-core binary not found" unless core

    bin.install core
  end

  def post_install
    config_dir = etc/"easytier"
    config_dir.mkpath
    (var/"log/easytier").mkpath

    config = config_dir/"easytier-core.toml"
    return if config.exist?

    config.write <<~TOML
      # Fill this file before starting the service.
      # Command-line equivalent:
      #   easytier-core --config-dir #{config_dir}
      #
      # The service loads every .toml file in this directory. You can also
      # ignore this file and edit the formula service block to use:
      #   --config-server, --network-name, --network-secret, --ipv4, --dhcp, --peers, etc.
    TOML
  end

  def caveats
    <<~EOS
      Config directory:
        #{etc}/easytier

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
      "--config-dir", etc/"easytier",
      "--file-log-dir", var/"log/easytier",
      "--file-log-level", "info",
      "--console-log-level", "info"
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
