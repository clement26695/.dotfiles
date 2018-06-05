#!/usr/bin/env bash

ln -s ~/.dotfiles/config/VSCode/settings.json ~/Library/Application\ Support/Code/User/
ln -s "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" /usr/local/bin/code

for line in $(cat ${HOME}/.dotfiles/config/VSCode/extensions)
do
	code --install-extension "$line"
done