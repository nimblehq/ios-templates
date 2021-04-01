#!/bin/bash
# set -e

source scripts/helpers.sh

cmd=$1
if [[ $cmd ==  "githooks" ]]; then
  projectPath=$2
  if [[ ! -d $projectPath ]]; then
    info "Directory doesn't exist or missing"
    exit
  fi

  gitHooksPath="${projectPath}/.githooks"
  if [[ ! -d $gitHooksPath ]]; then
    mkdir -p $gitHooksPath
  fi

  if cp -R resources/git-hooks/* $gitHooksPath; then
    success "Copied git hooks successfully"
  fi
  exit
fi
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
    dest="${HOME}/Library/Developer/Xcode/Templates-Backup-${currentDate}"
    mkdir -p $dest

    if cp -R ~/Library/Developer/Xcode/Templates $dest; then
      success "Backup your old templates at '$dest' successfully"
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
  cp -R resources/xcode-templates/* ~/Library/Developer/Xcode/Templates/Project\ Templates/Nimble\ Templates
  success "Copied Nimble Templates successfully"
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
  if cp -R resources/xcode-code-snippets/unit-test/* $dest; then
    success "Copied code snippets successfully"
  else
    exit
  fi
fi
