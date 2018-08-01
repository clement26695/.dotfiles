#!/usr/bin/env bash

################################################
bot "Setting up >Homebrew<"
################################################
running "checking homebrew install"
brew_bin=$(which brew) 2>&1 > /dev/null
if [[ $? != 0 ]]; then
  filler
  action "installing homebrew"
  # redirect input so we bypass the prompt: http://stackoverflow.com/a/25535532/1700053
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" </dev/null
  if [[ $? != 0 ]]; then
    error "unable to install homebrew, script $0 abort!"
    exit -1
  fi
else
  echo -n "already installed "
fi
ok

# Make sure we’re using the latest Homebrew
running "updating homebrew"
brew update; ok

question "Upgrade any existing outdated packages? [y|N] " response
if [[ $response =~ ^(y|yes|Y) ]];then
    # Upgrade any already-installed formulae
    action "upgrade brew packages"
    brew upgrade
fi
ok
botdone


################################################
bot "Setting up >Git<"
################################################

# To Be Fixed : path to gitconfig.local
# running "Setting [github.token] parameter"; filler
# config=`git config -f .gitconfig.local github.token > /dev/null 2>&1`
# if [[ $? == 0 ]]; then
#   question "[github.token] configuration already found. Do you want to replace it? [y|N]" response
# else
#   response='Y'
# fi

# if [[ $response =~ ^(yes|y|Y) ]];then
#   running "Opening Github tokens website"
#   open "https://github.com/settings/tokens"; ok
#   question "Please input your github command line token:" githubtoken
#   running "Adding github token to your .gitconfig.local file"
#   git config -f .gitconfig.local github.token "$githubtoken"
# fi
# ok

running "installing git brews"; filler
# skip those GUI clients, git command-line all the way
require_brew git
# yes, yes, use git-flow, please :)
require_brew git-flow
# hub command line tools
require_brew hub
botdone

################################################
bot "Setting up >ZSH<"
################################################
running "installing zsh brews"; filler
require_brew zsh
require_brew zsh-completions

CURRENTSHELL=$(dscl . -read /Users/$USER UserShell | awk '{print $2}')
if [[ "$CURRENTSHELL" != "/usr/local/bin/zsh" ]]; then
  bot "setting newer homebrew zsh (/usr/local/bin/zsh) as your shell (password required)"
  # sudo bash -c 'echo "/usr/local/bin/zsh" >> /etc/shells'
  # chsh -s /usr/local/bin/zsh
  sudo dscl . -change /Users/$USER UserShell $SHELL /usr/local/bin/zsh > /dev/null 2>&1
  ok
fi

botdone

# need fontconfig to install/build fonts
require_brew fontconfig
bot "installing fonts"
./fonts/install.sh
brew tap caskroom/fonts
# require_cask font-fontawesome
# require_cask font-awesome-terminal-fonts
require_cask font-hack
require_cask font-hack-nerd-font
# require_cask font-inconsolata-dz-for-powerline
# require_cask font-inconsolata-g-for-powerline
# require_cask font-inconsolata-for-powerline
# require_cask font-roboto-mono
# require_cask font-roboto-mono-for-powerline
# require_cask font-source-code-pro
ok

if [[ ! -d "./oh-my-zsh/custom/themes/powerlevel9k" ]]; then
  git clone https://github.com/bhilburn/powerlevel9k.git oh-my-zsh/custom/themes/powerlevel9k
fi

if [[ ! -d "./oh-my-zsh/custom/plugins/zsh-autosuggestions" ]]; then
	git clone https://github.com/zsh-users/zsh-autosuggestions oh-my-zsh/custom/plugins/zsh-autosuggestions
fi

if [[ ! -d "./oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]]; then
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git oh-my-zsh/custom/plugins/zsh-syntax-highlighting
fi

################################################
bot "Installing >homebrew command-line tools<"
################################################
# hide output to avoid anoying warning
brew tap homebrew/dupes > /dev/null 2>&1

# Install GNU core utilities (those that come with OS X are outdated)
require_brew coreutils
# Install some other useful utilities like `sponge`
require_brew moreutils
# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed
require_brew findutils --with-default-names
# diff
require_brew diffutils
# Install GNU `sed`, overwriting the built-in `sed`
# so we can do "sed -i 's/foo/bar/' file" instead of "sed -i '' 's/foo/bar/' file"
require_brew gnu-sed --with-default-names
# other tools per: http://apple.stackexchange.com/questions/69223/how-to-replace-mac-os-x-utilities-with-gnu-core-utilities
require_brew gnu-indent --with-default-names
require_brew gnutls
require_brew gnu-tar --with-default-names
require_brew gnu-getopt --with-default-names
require_brew gnu-which --with-default-names
require_brew gawk

# other tools
require_brew gzip
require_brew make
require_brew less
require_brew openssh
require_brew rsync
require_brew unzip
require_brew file-formula

# was missing --default-name it might fix the points below
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
# sudo rm /usr/local/bin/sha256sum
# sudo ln -s /usr/local/bin/gsha256sum /usr/local/bin/sha256sum

# Install Bash 4
# Note: don’t forget to add `/usr/local/bin/bash` to `/etc/shells` before running `chsh`.
#install bash
#install bash-completion

# better, more recent grep
require_brew grep --with-default-names
# Install other useful binaries
require_brew ack
# jq is a JSON grep
# require_brew jq
# better/more recent version of screen
require_brew tree
# better, more recent vim
require_brew vim --override-system-vi
# require_brew watch
# Install wget with IRI support
require_brew wget --with-iri
require_brew rename
# require_brew hardlink-osx
# manage ssh servers
require_brew stormssh

#Start Terminal sessions with a possibly-witty quote
require_brew fortune

botdone
