class Gvm < Formula
  desc "Go Version Manager"
  homepage "https://github.com/moovweb/gvm"
  url "https://github.com/moovweb/gvm/archive/dd652539fa4b771840846f8319fad303c7d0a8d2.tar.gz"
  version "1.0.22-20230814081128"
  sha256 "ce884e40b5ac6f72cb690562001d45667a03e07114a0a77b9a3e49c0a43392e4"
  license "MIT"
  head "https://github.com/moovweb/gvm.git", branch: "master"

  def install
    libexec.install Dir["*"]

    (libexec/"scripts/gvm").write <<~SH
      export GVM_ROOT="#{var}/gvm"
      . "$GVM_ROOT/scripts/gvm-default"
    SH

    (bin/"gvm").write <<~SH
      #!/usr/bin/env bash
      export GVM_ROOT="#{var}/gvm"
      . "$GVM_ROOT/scripts/gvm-default"
      exec "#{opt_libexec}/bin/gvm" "$@"
    SH
  end

  def post_install
    gvm_root = var/"gvm"
    gvm_root.mkpath

    {
      "bin"     => opt_libexec/"bin",
      "config"  => opt_libexec/"config",
      "locales" => opt_libexec/"locales",
      "scripts" => opt_libexec/"scripts",
      "VERSION" => opt_libexec/"VERSION",
    }.each do |name, target|
      link = gvm_root/name
      if link.symlink?
        link.unlink
      elsif link.exist?
        opoo "#{link} already exists; leaving it unchanged"
        next
      end
      link.make_symlink(target)
    end
  end

  def caveats
    <<~EOS
      Add GVM to your shell profile:
        [[ -s "#{var}/gvm/scripts/gvm" ]] && source "#{var}/gvm/scripts/gvm"

      Go versions, package sets, and environments are stored in:
        #{var}/gvm

      Update GVM with `brew upgrade gvm`; `gvm get` is not supported by this
      Homebrew-managed installation.
    EOS
  end

  test do
    upstream_version = version.to_s.split("-").first
    assert_match "Go Version Manager v#{upstream_version}", shell_output("#{bin}/gvm version")
  end
end
