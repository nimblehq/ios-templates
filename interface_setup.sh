#!/bin/sh
if [[ -z "${CI}" ]]; then
    read -p "Which Interface do you want to use [(S)wiftUI/(U)IKit]: " interface

    if [ "$interface" = "s" -o "$interface" = "SwiftUI" -o "$interface" = "S" ]; then
        echo "Setting up SwiftUI" 
        cp -r tuist/Interfaces/SwiftUI/Pod/. .
        cp -r tuist/Interfaces/SwiftUI/Sources/. {PROJECT_NAME}/Sources
    else
        echo "Setting up UIKit"
        cp -r tuist/Interfaces/UIKit/Pod/. .
        cp -r tuist/Interfaces/UIKit/Sources/. {PROJECT_NAME}/Sources
    fi
else
    cp -r tuist/Interfaces/UIKit/Pod/. .
    cp -r tuist/Interfaces/UIKit/Sources/. {PROJECT_NAME}/Sources
fi
rm -rf tuist/Interfaces
