#!/bin/bash
# Local verification for the Mochi fork. No captures, input injection or external network tests.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p .build/clang-cache .build/swift-cache
export CLANG_MODULE_CACHE_PATH="$PWD/.build/clang-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="$CLANG_MODULE_CACHE_PATH"
swiftc -frontend -parse iOSClient/*.swift
plutil -lint Packaging/Info.plist iOSClient/Info.plist iOSClient/Info-Debug.plist \
    iOSClient/Mochi.xcodeproj/project.pbxproj
Tests/checks/run-all.sh "$@"
