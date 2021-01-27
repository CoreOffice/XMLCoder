#!/bin/bash

set -e
set -o pipefail

swift test --parallel --enable-test-discovery
