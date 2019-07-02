#!/bin/bash

set -e 
set -o pipefail

sudo xcode-select --switch /Applications/$1.app/Contents/Developer

xcodebuild -version
carthage bootstrap
xcodebuild build -scheme XMLCoder \
  -sdk iphonesimulator -destination "$IOS_DEVICE" | xcpretty
xcodebuild build -scheme XMLCoder \
  -sdk appletvsimulator -destination "$TVOS_DEVICE" | xcpretty

if [ -n "$CODECOV_JOB" ]; then
  xcodebuild test -enableCodeCoverage YES -scheme XMLCoder \
    -sdk macosx | xcpretty
  bash <(curl -s https://codecov.io/bash)
else 
  xcodebuild test -scheme XMLCoder \
    -sdk macosx | xcpretty
fi
