#!/bin/sh

interface=""

while [ $# -gt 0 ] ; do
    case "$1" in
    -i|--interface)
        interface="$2"
        shift
        ;;
    esac
    shift
done

if [ "$interface" = "s" -o "$interface" = "SwiftUI" -o "$interface" = "S" ]; then
    echo "Setting up SwiftUI" 
    cp -r tuist/Interfaces/SwiftUI/Pod/. .
    cp -r tuist/Interfaces/SwiftUI/Sources/. {PROJECT_NAME}/Sources
else
    echo "Setting up UIKit"
    cp -r tuist/Interfaces/UIKit/Pod/. .
    cp -r tuist/Interfaces/UIKit/Sources/. {PROJECT_NAME}/Sources
fi
rm -rf tuist/Interfaces
