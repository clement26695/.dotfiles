#!/usr/bin/env bash

###########################
# This script installs the dotfiles and runs all other system configuration scripts
# @author Adam Eivy
# @contributor João Loff
###########################
DEFAULT_EMAIL="clement.dessoude@gmail.com"
DEFAULT_GITHUBUSER="clement26695"

# include my library helpers for colorized echo and require_brew, etc
source ./lib.sh
# sourcing shellvars so we can get tools specific pre-loaded settings
source ./homedir/.exports
# we might need the functions
source ./homedir/.functions

# clear stdin from pending input
clean_stdin

caffeinate -i -d &
caff_pid=$!

# make a backup directory for overwritten dotfiles
if [[ ! -e ~/.dotfiles_backup ]]; then
    mkdir ~/.dotfiles_backup
fi

################################################
bot "Hi. I'm here to make your OSX a better system!"
################################################


################################################
bot "Setting up personal info"
################################################

################################################
# Full name
################################################
fullname=`osascript -e "long user name of (system info)"`
if [[ -n "$fullname" ]];then
  lastname=$(echo $fullname | awk '{print $2}');
  firstname=$(echo $fullname | awk '{print $1}');
fi

fullname=`dscl . -read /Users/$(whoami)  | awk 'f {print; exit} /RealName/ {f=1}' | xargs`
if [[ -z $firstname ]]; then
  firstname=$(echo $fullname | awk '{print $1}');
fi
if [[ -z $lastname ]]; then
  lastname=$(echo $fullname | awk '{print $2}');
fi

if [[ ! "$firstname" ]];then
  response='n'
else
  question "Is this your full name '$COL_YELLOW$firstname $lastname$COL_RESET'? [Y|n]" response
fi

if [[ $response =~ ^(no|n|N) ]];then
  question "What is your first name? " firstname
  question "What is your last name? " lastname
fi
fullname="$firstname $lastname"

running "Full name set to '$COL_YELLOW$fullname$COL_RESET'";ok

################################################
# Email
################################################
email=`dscl . -read /Users/$(whoami) | grep RecordName | awk '{print $3}'`
if [[ ! $email ]];then
  response='n'
else
  question "Is this your email '$COL_YELLOW$email$COL_RESET'? [Y|n]" response
fi

if [[ $response =~ ^(no|n|N) ]];then
  question "What is your email? [$DEFAULT_EMAIL] " email
  if [[ ! $email ]];then
    email=$DEFAULT_EMAIL
  fi
fi

running "Email set to '$COL_YELLOW$email$COL_RESET'";ok

################################################
# github username
################################################
githubuser=`awk '/user = /{ print $3 }' ./homedir/.gitconfig`
if [[ ! $githubuser ]];then
  response='n'
else
  question "Is this your github username '$COL_YELLOW$githubuser$COL_RESET'? [Y|n]" response
fi

if [[ $response =~ ^(no|n|N) ]];then
  question "What is your github username  then? [$DEFAULT_GITHUBUSER] " githubuser
  if [[ ! $githubuser ]];then
    githubuser=$DEFAULT_GITHUBUSER
  fi
fi
running "Github username set to '$COL_YELLOW$githubuser$COL_RESET'";ok

botdone

################################################
bot "Checking sudo"
################################################
if sudo -n true 2>/dev/null; then
  msg "Already has sudo";filler
else
  # Ask for the administrator password upfront
  msg "Sudo is needed:"
  sudo -p "" -v
fi
# Keep-alive: update existing sudo time stamp until the script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# ################################################
# # check if user wants sudo passwordless
# ################################################
# if sudo grep -q "# %wheel\tALL=(ALL) NOPASSWD: ALL" "/etc/sudoers"; then
#   question "Do you want me to setup this machine to allow you to run sudo without a password?\n
#       More infomation here: http://wiki.summercode.com/sudo_without_a_password_in_mac_os_x \n
#       [y|N]" response

#   if [[ $response =~ (yes|y|Y) ]];then
#       sed --version
#       if [[ $? == 0 ]];then
#           sudo sed -i 's/^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers
#       else
#           sudo sed -i '' 's/^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers
#       fi
#       sudo dscl . append /Groups/wheel GroupMembership $(whoami)
#       running "You can now run sudo commands without password!"
#   fi
# fi
# ok

# botdone

################################################
# /etc/hosts
################################################

read -r -p "Overwrite /etc/hosts with the ad-blocking hosts file from someonewhocares.org? (from ./configs/hosts file) [y|N] " response
if [[ $response =~ (yes|y|Y) ]];then
    action "cp /etc/hosts /etc/hosts.backup"
    sudo cp /etc/hosts /etc/hosts.backup
    ok
    action "cp ./configs/hosts /etc/hosts"
    sudo cp ./configs/hosts /etc/hosts
    ok
    bot "Your /etc/hosts file has been updated. Last version is saved in /etc/hosts.backup"
fi

################################################
bot "Changing Wallpaper"
################################################
MD5_NEWWP=$(md5 img/wallpaper.jpg | awk '{print $4}')
MD5_OLDWP=$(md5 /System/Library/CoreServices/DefaultDesktop.jpg | awk '{print $4}')
if [[ "$MD5_NEWWP" != "$MD5_OLDWP" ]]; then
  read -r -p "Do you want to use the project's custom desktop wallpaper? [Y|n] " response
  if [[ $response =~ ^(no|n|N) ]];then
    echo "skipping...";
    ok
  else
    running "Set a custom wallpaper image"
    # `DefaultDesktop.jpg` is already a symlink, and
    # all wallpapers are in `/Library/Desktop Pictures/`. The default is `Wave.jpg`.
    rm -rf ~/Library/Application Support/Dock/desktoppicture.db
    sudo rm -f /System/Library/CoreServices/DefaultDesktop.jpg > /dev/null 2>&1
    sudo rm -f /Library/Desktop\ Pictures/El\ Capitan.jpg > /dev/null 2>&1
    sudo rm -f /Library/Desktop\ Pictures/Sierra.jpg > /dev/null 2>&1
    sudo rm -f /Library/Desktop\ Pictures/Sierra\ 2.jpg > /dev/null 2>&1
    sudo cp ./img/wallpaper.jpg /System/Library/CoreServices/DefaultDesktop.jpg;
    sudo cp ./img/wallpaper.jpg /Library/Desktop\ Pictures/Sierra.jpg;
    sudo cp ./img/wallpaper.jpg /Library/Desktop\ Pictures/Sierra\ 2.jpg;
    sudo cp ./img/wallpaper.jpg /Library/Desktop\ Pictures/El\ Capitan.jpg;ok
  fi
fi

# ################################################
# bot "Setting up >crontab nightly jobs<"
# ################################################
# # adds nightly cron software updates.
# # Note that this may wake you in the morning to compatibility issues
# # so use only if you like being on the edge
# running "symlinking shell files"; filler
# pushd ~ > /dev/null 2>&1
# symlinkifne .crontab
# popd > /dev/null 2>&1

# running "starting cron"
# sudo cron ~/.crontab > /dev/null 2>&1 ;ok

# botdone

################################################
bot "creating symlinks for project dotfiles..."
################################################
pushd homedir > /dev/null 2>&1
now=$(date +"%Y.%m.%d.%H.%M.%S")

for file in .*; do
  if [[ $file == "." || $file == ".." ]]; then
    continue
  fi
  running "~/$file"
  # if the file exists:
  if [[ -e ~/$file ]]; then
      mkdir -p ~/.dotfiles_backup/$now
      mv ~/$file ~/.dotfiles_backup/$now/$file
      echo "backup saved as ~/.dotfiles_backup/$now/$file"
  fi
  # symlink might still exist
  unlink ~/$file > /dev/null 2>&1
  # create the link
  ln -s ~/.dotfiles/homedir/$file ~/$file
  echo -en '\tlinked';ok
done

popd > /dev/null 2>&1

################################################
# homebrew
################################################
source ./brew.sh

################################################
# brew cask
################################################
source ./casks.sh

################################################
# osx
################################################
source ./osx.sh

################################################
# "extra" software
################################################
source ./extras.sh

################################################
bot "Cleaning up the mess"
################################################
# Remove outdated versions from the cellar
running "Cleaning up homebrew cache"
brew cleanup > /dev/null 2>&1
brew cask cleanup > /dev/null 2>&1
ok

msg "Note that some of these changes require a logout/restart to take effect."; filler
msg "You should also NOT open System Preferences. It might overwrite some of the settings."; filler
running "Killing affected applications (so they can reboot)...."
for app in "Activity Monitor" "Address Book" "Calendar" "Contacts" "cfprefsd" \
  "Dock" "Finder" "Google Chrome" "Mail" "Messages" "Photos" "Safari" "Spectacle" "SystemUIServer" "iCal" "Visual Studio Code" \
  "The Unarchiver"; do
  killall "${app}" > /dev/null 2>&1
done
ok

botdone

{
  ###############################################################################
  bot "Unfortunately I can't setup everything :( Heres a list of things you need to manually do"
  ###############################################################################
  item 1 "Set Finder settings"
  item 2 "Remove 'All My Files', 'Movies', 'Music' and 'Pictures' from sidebar"
  item 2 "Add folders to sidebar: 'PhD', 'Code'"
  filler
  item 1 "Set User & Groups settings:"
  item 2 "Enable auto login"
  item 2 "Disable Guest account"
  filler
  item 1 "Set iCloud settings:"
  item 2 "Disable Safari and Mail sync"
  item 2 "Sign in for Facebook, Twitter, Linkedin, Google (Only select contacts)"
  filler
  item 1 "Set Dropbox configuration:"
  item 2 "Show desktop notifications"
  item 2 "Start dropbox on system startup"
  item 2 "Selective Sync folders"
  item 2 "Do not enable camera uploads"
  item 2 "Share screenshots using Dropbox"
  item 2 "Enable LAN sync"
  filler
}

botdone

# kills caffeinate
# TODO Outputing the terminated message
kill $caff_pid
wait $caff_pid &>/dev/null

################################################
bot "Woot! All done."
################################################
