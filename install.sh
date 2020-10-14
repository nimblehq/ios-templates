#!/bin/bash

# Backup old templates in case you have your custom templates

read -r -p "Do you want to backup your old templates? [Y|n] " response

if [[ ! $response =~ (n|no|N) ]];then
  currentDate=`date +%s`
  cp -R ~/Library/Developer/Xcode/Templates ~/Library/Developer/Xcode/Templates-Backup-${currentDate}
fi

rm -rf ~/Library/Developer/Xcode/Templates/File\ Templates
rm -rf ~/Library/Developer/Xcode/Templates/Project\ Templates

# Create Folders
mkdir -p ~/Library/Developer/Xcode/Templates/File\ Templates
mkdir -p ~/Library/Developer/Xcode/Templates/Project\ Templates
mkdir -p ~/Library/Developer/Xcode/Templates/Project\ Templates/Nimble\ Templates
cp -R Nimble\ Templates/* ~/Library/Developer/Xcode/Templates/Project\ Templates/Nimble\ Templates