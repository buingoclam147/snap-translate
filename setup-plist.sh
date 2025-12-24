#!/bin/bash
# This script copies Info.plist to the right location for SPM executable builds

SOURCE_PLIST="Sources/SnapTranslate/Info.plist"
BUILD_DIR=".build/debug"

if [ ! -d "$BUILD_DIR" ]; then
    mkdir -p "$BUILD_DIR"
fi

if [ -f "$SOURCE_PLIST" ]; then
    cp "$SOURCE_PLIST" "$BUILD_DIR/SnapTranslate.app/Contents/Info.plist" 2>/dev/null || true
    echo "Info.plist copied to bundle"
else
    echo "ERROR: Source Info.plist not found at $SOURCE_PLIST"
fi
