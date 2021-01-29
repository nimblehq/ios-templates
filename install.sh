#!/bin/bash
# set -e

source scripts/helpers.sh

# ----------------------------------
# Templates
# ----------------------------------
section "Templates"
confirm "Do you want to copy templates?"
response=$?
if [[ $response = 1 ]]; then

  # Backup old templates in case you have your custom templates
  confirm "Do you want to backup your old templates?"
  response=$?

  if [[ ! $response == 0 ]]; then
    currentDate=`date +%s`
    dest="~/Library/Developer/Xcode/Templates-Backup-${currentDate}"
    mkdir -p $dest
    
    if cp -R ~/Library/Developer/Xcode/Templates $dest; then
      success "Successfully backup your old templates at '$dest'"
    else
      exit
    fi
  fi

  rm -rf ~/Library/Developer/Xcode/Templates/File\ Templates
  rm -rf ~/Library/Developer/Xcode/Templates/Project\ Templates

  # Create Folders
  mkdir -p ~/Library/Developer/Xcode/Templates/File\ Templates
  mkdir -p ~/Library/Developer/Xcode/Templates/Project\ Templates
  mkdir -p ~/Library/Developer/Xcode/Templates/Project\ Templates/Nimble\ Templates
  cp -R Nimble\ Templates/* ~/Library/Developer/Xcode/Templates/Project\ Templates/Nimble\ Templates
fi

# ----------------------------------
# Code Snippets
# ----------------------------------
section "Code Snippets"
confirm "Do you want to copy code snippets?"
response=$?

if [[ $response = 1 ]];then

  # Checking `CodeSnippets` directory exists
  if [ ! -d "~/Library/Developer/Xcode/UserData/CodeSnippets" ]; then
    mkdir -p ~/Library/Developer/Xcode/UserData/CodeSnippets
  fi

  # Copy code snippets for Unit Test
  dest=~/Library/Developer/Xcode/UserData/CodeSnippets
  if cp -R Nimble\ Code\ Snippets/Unit\ Test/* $dest; then
    success "Successfully copied code snippets to '$dest'"
  else
    exit
  fi
fi
