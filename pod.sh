#!/bin/bash

set -e 
set -o pipefail

sudo gem uninstall cocoapods
sudo gem install cocoapods -v 1.7.5
pod setup
pod lib lint --verbose
