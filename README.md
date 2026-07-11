# homebrew-tap

Homebrew tap for EasyTier and selected macOS desktop applications.

## Install

```bash
brew tap ly-wo/tap
brew install easytier-core
brew install --cask easytier-gui
brew install --cask dms
brew install --cask pakeplus
brew install --cask ztools
brew install --cask rubick
brew install --cask tiny-rdm
```

`easytier-core` is the Homebrew service wrapper. The casks install EasyTier GUI,
Alibaba Cloud DMS, PakePlus, ZTools, rubick, and Tiny RDM.

## Configure

Edit the default config file:

```bash
sudo vi "$(brew --prefix)/etc/easytier/easytier-core.toml"
```

The service loads every `.toml` file from `$(brew --prefix)/etc/easytier` and runs:

```bash
"$(brew --prefix)/opt/easytier-core/bin/easytier-core" \
  --config-dir "$(brew --prefix)/etc/easytier" \
  --file-log-dir "$(brew --prefix)/var/log/easytier" \
  --file-log-level info \
  --console-log-level info
```

## Service commands

```bash
sudo brew services start easytier-core
sudo brew services restart easytier-core
sudo brew services stop easytier-core
sudo brew services info easytier-core
sudo brew services list
```

## Cleanup

If the service was previously started without `sudo`, remove the stale user LaunchAgent before using the root service:

```bash
brew services stop easytier-core
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/homebrew.mxcl.easytier-core.plist
rm ~/Library/LaunchAgents/homebrew.mxcl.easytier-core.plist
sudo brew services restart easytier-core
```
