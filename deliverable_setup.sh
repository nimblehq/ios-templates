#!/bin/sh
read -p "Which CI/CD service do you use (Can be edited later) [(g)ithub/(b)itrise/(l)ater]: " ciService

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
    echo "✅  Completed"
else
    open -a Xcode fastlane/Constants/DeliverableConstants.rb
fi
