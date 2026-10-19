#!/bin/bash
# Mochi's local development build. No upload, update service, or upstream signing identity.
set -euo pipefail
cd "$(dirname "$0")/.."
configuration=release
open_app=0
staged=0
for arg in "$@"; do
    case "$arg" in
        --debug) configuration=debug ;;
        --open) open_app=1 ;;
        --staged) staged=1 ;;
        -h|--help) echo "usage: Scripts/make-mochi.sh [--debug] [--open] [--staged]"; exit 0 ;;
        *) echo "Unsupported option: $arg. This script builds locally; it never installs or publishes." >&2; exit 2 ;;
    esac
done
mkdir -p .build/clang-cache .build/swift-cache
export CLANG_MODULE_CACHE_PATH="$PWD/.build/clang-cache"
export SWIFTPM_MODULECACHE_OVERRIDE="$CLANG_MODULE_CACHE_PATH"
swift build -c "$configuration" --product MochiMenuBar --jobs 4 \
    --cache-path "$PWD/.build/swift-cache" --disable-sandbox
bin="$(swift build -c "$configuration" --show-bin-path --cache-path "$PWD/.build/swift-cache" --disable-sandbox)"
icons="$PWD/.build/mochi-icons"
mkdir -p "$icons"
if [ ! -f "$icons/AppIcon.icns" ] || [ Scripts/render-mochi-icon.swift -nt "$icons/AppIcon.icns" ] || [ design/MochiCharacter.png -nt "$icons/AppIcon.icns" ]; then
    swift Scripts/render-mochi-icon.swift "$icons"
    iconutil -c icns "$icons/Mochi.iconset" -o "$icons/AppIcon.icns"
fi
app="$PWD/.build/Mochi.app"
if [ "$staged" = 1 ]; then app="$PWD/.build/Mochi-next.app"; fi
stage="${app}.partial"
rm -rf "$stage"
mkdir -p "$stage/Contents/MacOS" "$stage/Contents/Resources"
cp "$bin/MochiMenuBar" "$stage/Contents/MacOS/Mochi"
cp Packaging/Info.plist "$stage/Contents/Info.plist"
cp "$icons/AppIcon.icns" "$stage/Contents/Resources/AppIcon.icns"
cp design/MochiCharacter.png "$stage/Contents/Resources/MochiCharacter.png"
cp LICENSE "$stage/Contents/Resources/LICENSE.txt"
cp NOTICE "$stage/Contents/Resources/NOTICE.txt"
# A stable Apple Development identity keeps privacy grants valid across local rebuilds.
# MOCHI_SIGN_IDENTITY may explicitly override this (including "-" for ad-hoc builds).
signing_identity="${MOCHI_SIGN_IDENTITY:-}"
if [ -z "$signing_identity" ]; then
    identities=()
    while IFS= read -r identity; do
        [ -n "$identity" ] && identities+=("$identity")
    done < <(security find-identity -v -p codesigning | awk '/"Apple Development:/ { print $2 }')
    if [ "${#identities[@]}" -eq 1 ]; then
        signing_identity="${identities[0]}"
    elif [ "${#identities[@]}" -gt 1 ]; then
        echo "Multiple Apple Development identities found. Set MOCHI_SIGN_IDENTITY to the intended identity." >&2
        exit 2
    else
        signing_identity="-"
        echo "No Apple Development identity found; using ad-hoc signing. Rebuilds may need fresh privacy grants." >&2
    fi
fi
codesign --force --sign "$signing_identity" --timestamp=none "$stage"
codesign --verify --strict "$stage"
rm -rf "$app"
mv "$stage" "$app"
printf '\nBuilt %s\n' "$app"
if [ "$open_app" = 1 ]; then open "$app"; fi
