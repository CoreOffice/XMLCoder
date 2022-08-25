#!/bin/bash

set -e 
set -o pipefail

sudo xcode-select --switch /Applications/$1.app/Contents/Developer

xcodebuild -version
xcodebuild test -scheme XMLCoder \
  -sdk iphonesimulator -destination "$IOS_DEVICE" | xcpretty

if $(xcodebuild -showdestinations -scheme XMLCoder | grep 'platform:tvOS.* OS:'); then
  xcodebuild test -scheme XMLCoder \
    -sdk appletvsimulator -destination "$TVOS_DEVICE" | xcpretty
fi

if [ "$CODECOV_JOB" = "true" ] ; then
  xcodebuild test -enableCodeCoverage YES -scheme XMLCoder \
    -sdk macosx | xcpretty
  bash <(curl -s https://codecov.io/bash)
else 
  xcodebuild test -scheme XMLCoder \
    -sdk macosx | xcpretty
fi
