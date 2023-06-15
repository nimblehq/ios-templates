#!/bin/sh
if [[ -z "${CI}" ]]; then
    read -p "Which Interface do you want to use [(S)wiftUI/(U)IKit]: " interface

    if [ "$interface" = "s" -o "$ciService" = "SwiftUI" -o "$ciService" = "S" ]; then
        echo "Setting up SwiftUI" 
        cp -r tuist/Projects/SwiftUI/. . 
    else
        echo "Setting up UIKit"
        cp -r tuist/Projects/UIKit/. . 
    fi
    rm -rf tuist/Projects
    echo "✅  Completed"
else
    cp -r tuist/Projects/UIKit/. . 
fi
