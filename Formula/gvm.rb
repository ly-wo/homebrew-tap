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

  post_install_steps do
    mkdir_p "gvm", base: :var

    remove "{{var}}/gvm/bin", symlink_target_contains: "opt/gvm/"
    remove "{{var}}/gvm/bin", symlink_target_contains: "Cellar/gvm/"
    if_path_exists "gvm/bin", base: :var do
      warn "{{var}}/gvm/bin already exists; leaving it unchanged"
    end
    unless_path_exists "gvm/bin", base: :var do
      symlink "{{opt_prefix}}/libexec/bin", "{{var}}/gvm/bin"
    end

    remove "{{var}}/gvm/config", symlink_target_contains: "opt/gvm/"
    remove "{{var}}/gvm/config", symlink_target_contains: "Cellar/gvm/"
    if_path_exists "gvm/config", base: :var do
      warn "{{var}}/gvm/config already exists; leaving it unchanged"
    end
    unless_path_exists "gvm/config", base: :var do
      symlink "{{opt_prefix}}/libexec/config", "{{var}}/gvm/config"
    end

    remove "{{var}}/gvm/locales", symlink_target_contains: "opt/gvm/"
    remove "{{var}}/gvm/locales", symlink_target_contains: "Cellar/gvm/"
    if_path_exists "gvm/locales", base: :var do
      warn "{{var}}/gvm/locales already exists; leaving it unchanged"
    end
    unless_path_exists "gvm/locales", base: :var do
      symlink "{{opt_prefix}}/libexec/locales", "{{var}}/gvm/locales"
    end

    remove "{{var}}/gvm/scripts", symlink_target_contains: "opt/gvm/"
    remove "{{var}}/gvm/scripts", symlink_target_contains: "Cellar/gvm/"
    if_path_exists "gvm/scripts", base: :var do
      warn "{{var}}/gvm/scripts already exists; leaving it unchanged"
    end
    unless_path_exists "gvm/scripts", base: :var do
      symlink "{{opt_prefix}}/libexec/scripts", "{{var}}/gvm/scripts"
    end

    remove "{{var}}/gvm/VERSION", symlink_target_contains: "opt/gvm/"
    remove "{{var}}/gvm/VERSION", symlink_target_contains: "Cellar/gvm/"
    if_path_exists "gvm/VERSION", base: :var do
      warn "{{var}}/gvm/VERSION already exists; leaving it unchanged"
    end
    unless_path_exists "gvm/VERSION", base: :var do
      symlink "{{opt_prefix}}/libexec/VERSION", "{{var}}/gvm/VERSION"
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
