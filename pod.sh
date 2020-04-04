#!/bin/bash

set -e
set -o pipefail

pod lib lint --verbose
