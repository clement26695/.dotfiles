#!/usr/bin/env bash

################################################
bot "Setting up >Homebrew Cask<"
################################################
running "checking brew-cask install"
output=$(brew tap | grep cask)
if [[ $? != 0 ]]; then
  filler
  require_brew caskroom/cask/brew-cask
else
  echo -n "already installed "
fi
brew tap caskroom/versions > /dev/null 2>&1
ok; botdone


###############################################################################
bot "Installing >Docker<"
###############################################################################
require_cask dockertoolbox

botdone


################################################
bot "Setting up >VSCode<"
################################################
# Remember: cask already install the shell tools
require_cask visual-studio-code

botdone


###############################################################################
bot "Setting up >iTerm2<"
###############################################################################
require_cask iterm2

botdone


###############################################################################
bot "Setting up >Google Chrome<"
###############################################################################
# checks if google chrome was already installed
firstinstall=`brew cask list | grep "google-chrome" &> /dev/null ; echo $?`

require_cask google-chrome

running "Use the system-native print preview dialog"
defaults write com.google.Chrome DisablePrintPreview -bool true;ok

running "Expand the print dialog by default"
defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true;ok

# if first installation, opens
if [ $firstinstall == 1 ]; then
  open "/Applications/Google Chrome.app"
fi
botdone

###############################################################################
bot "Installing >The Unarchiver<"
###############################################################################
require_cask the-unarchiver

# Work on El Capitan but for YOSEMITE it creates a "special file"
# somehwere the ~/Library/Containers folder
running "Set to extract archives to same folder as the archive"
defaults write cx.c3.theunarchiver extractionDestination -int 1;ok

running "Set the modification date of the created folder to the modification date of the archive file"
defaults write cx.c3.theunarchiver folderModifiedDate -int 2;ok

running "Delete archive after extraction"
defaults write cx.c3.theunarchiver deleteExtractedArchive -bool true;ok

running "Do not open folder afer extraction"
defaults write cx.c3.theunarchiver openExtractedFolder -bool false;ok

botdone


###############################################################################
bot "Installing >Dropbox<"
###############################################################################
require_cask dropbox
running "Remove Dropbox’s green checkmark icons in Finder"
file=/Applications/Dropbox.app/Contents/Resources/emblem-dropbox-uptodate.icns
[ -e "${file}" ] && mv -f "${file}" "${file}.bak";ok
# re-sign the file to avoid firewall popup
sudo codesign --force --deep --sign - /Applications/Dropbox.app &> /dev/null

# always opens Dropbox since if it exists its silent
open "/Applications/Dropbox.app"
botdone


###############################################################################
bot "Installing remaining casks"
###############################################################################
# checks if  was already installed
firstinstall=`brew cask list | grep "spotify" &> /dev/null ; echo $?`
require_cask spotify
# if first installation, opens
if [[ $firstinstall == 1 ]]; then
  open "/Applications/Spotify.app"
fi


require_cask vlc
#require_cask asepsis
require_cask skype
require_cask gimp
require_cask alinof-timer
require_cask java
require_cask slack

require_cask adobe-acrobat-reader
require_cask android-file-transfer
require_cask ccleaner
require_cask filezilla
require_cask spectacle
require_cask sublime-text

botdone


################################################
bot "Installing >Quicklook plugins<"
################################################
require_cask qlcolorcode
require_cask qlstephen
require_cask qlmarkdown
require_cask quicklook-json
require_cask qlprettypatch
require_cask quicklook-csv
require_cask betterzipql
require_cask qlimagesize
botdone
