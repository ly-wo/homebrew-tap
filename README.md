# homebrew-easytier

Local Homebrew tap for managing the current `easytier-core` binary with `brew services`.

## Install

```bash
brew tap wanglei/easytier /Users/wanglei/Documents/Codex/2026-07-03/s/outputs/homebrew-easytier
brew install easytier-core
```

## Configure

Edit:

```bash
sudo vi /usr/local/etc/easytier/easytier-core.toml
```

The service runs:

```bash
/usr/local/opt/easytier-core/bin/easytier-core \
  --config-file /usr/local/etc/easytier/easytier-core.toml \
  --file-log-dir /usr/local/var/log/easytier \
  --file-log-level info \
  --console-log-level info
```

## Service commands

```bash
brew services start easytier-core
brew services restart easytier-core
brew services stop easytier-core
brew services info easytier-core
brew services list
```

This starts `easytier-core` as a user LaunchAgent at login. For a root LaunchDaemon at system boot,
keep using `/Library/LaunchDaemons/easytier.core.plist` or run `sudo brew services start easytier-core`.
