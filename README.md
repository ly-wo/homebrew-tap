# homebrew-easytier

Local Homebrew tap for managing the current `easytier-core` binary with `brew services`.

## Install

```bash
brew tap wanglei/easytier /Users/wanglei/Projects/Other/homebrew
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
sudo brew services start easytier-core
sudo brew services restart easytier-core
sudo brew services stop easytier-core
sudo brew services info easytier-core
brew services list
```
