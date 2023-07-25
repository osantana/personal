#!/bin/bash

# Install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install base packages
packages="
bash
binutils
git
gnupg
go
grep
heroku
htop
llvm
make
mtr
nmap
node
nvm
openssl@1.1
openssl@3
p7zip
python3
pyenv
pyenv-ccache
pyenv-pip-migrate
pyenv-virtualenv
pyenv-virtualenvwrapper
readline
screen
tree
wget
zip
1password-cli
keybase
iterm2
macfuse
raycast
scroll-reverser
visual-studio-code
xquartz
xscreensaver
oracle-jdk
backblaze
"
brew install $packages --force > ~/postinstall.txt

# Change default shell to bash3 provided by Homebrew
chsh -s /opt/homebrew/bin/bash ${USER}

# Install latest version of py3
pyenv install 3:latest

# TODO:
# - Install .secrets
# - Clone osantana/personal
# - Create symlinks for dotfiles -> Work/personal
# - Replace Spotlight with Raycast

# Do not open downloaded files after download on Safari
defaults write com.apple.Safari AutoOpenSafeDownloads -bool NO

# Download PDF instead of open it on Safari
# defaults write com.apple.Safari WebKitOmitPDFSupport -bool YES
