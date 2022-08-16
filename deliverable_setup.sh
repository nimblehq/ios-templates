#!/bin/sh
read -p "Which CICD service do you use (Can be edited later) [(g)ithub/(b)itrise]: " ciService

if [ "$ciService" = "g" -o "$ciService" = "github" ]; then
    echo "Setting template for Github Actions"
    rm bitrise.yml
elif [ "$ciService" = "b" -o "$ciService" = "bitrise" ]; then
    echo "Setting template for Bitrise"
    rm -rf .github/workflows
else
    echo "You can manually setup the template later."
fi
echo "✅  Completed"

read -n1 -p "Do you want to set up Deliverable Constants values? (Can be edited later) [Y/n]:" confirm
if ! echo $confirm | grep '^[Yy]\?$'; then
  exit 1
fi

open -a Xcode fastlane/Constants/DeliverableConstants.rb
