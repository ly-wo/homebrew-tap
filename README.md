# homebrew-tap

Homebrew tap for EasyTier, developer tools, and selected macOS desktop applications.

## Install

```bash
brew tap ly-wo/tap
brew install easytier-core
brew install gvm
brew install nvm
brew install --cask easytier-gui
brew install --cask dms
brew install --cask pakeplus
brew install --cask ztools
brew install --cask rubick
brew install --cask tiny-rdm
brew install --cask rustdesk
brew install --cask orbstack
```

`easytier-core` is the Homebrew service wrapper, `gvm` manages Go versions, and
`nvm` manages Node.js versions. The casks install EasyTier GUI, Alibaba Cloud
DMS, PakePlus, ZTools, rubick, Tiny RDM, RustDesk, and OrbStack.

## GVM shell setup

Add the following line to `~/.zshrc` or the appropriate shell profile:

```bash
[[ -s "$(brew --prefix)/var/gvm/scripts/gvm" ]] && \
  source "$(brew --prefix)/var/gvm/scripts/gvm"
```

## NVM shell setup

Create NVM's working directory and add the initialization to your shell profile:

```bash
mkdir -p "$HOME/.nvm"
export NVM_DIR="$HOME/.nvm"
[[ -s "$(brew --prefix)/opt/nvm/nvm.sh" ]] && \
  source "$(brew --prefix)/opt/nvm/nvm.sh"
[[ -s "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm" ]] && \
  source "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm"
```

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
