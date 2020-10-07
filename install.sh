#!/bin/bash

mkdir -p ~/Library/Developer/Xcode/Templates/File\ Templates
mkdir -p ~/Library/Developer/Xcode/Templates/Project\ Templates
mkdir -p ~/Library/Developer/Xcode/Templates/Project\ Templates/Nimble\ Templates
cp -R Nimble\ Templates/* ~/Library/Developer/Xcode/Templates/Project\ Templates/Nimble\ Templates
find ~/Library/Developer/Xcode/Templates/Project\ Templates/Nimble\ Templates/temp -name ".gitignore" -delete