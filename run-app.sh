#!/bin/bash

# SnapTranslate App Runner
# This script packages and runs the SPM executable as a proper macOS app

set -e

PROJECT_DIR="/Users/lamngoc/snap-translate"
BUILD_DIR="$PROJECT_DIR/.build/debug"
EXECUTABLE="$BUILD_DIR/SnapTranslate"
APP_BUNDLE="$BUILD_DIR/SnapTranslate.app"

echo "=================================="
echo "🚀 SnapTranslate App Launcher"
echo "=================================="
echo ""

# Always build to get latest changes
echo "📦 Building SnapTranslate..."
cd "$PROJECT_DIR"
swift build
echo ""

# Clean old app bundle to force rebuild
echo "🧹 Cleaning old app bundle..."
rm -rf "$APP_BUNDLE"

# Create app bundle structure
echo "📁 Creating macOS app bundle..."
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Copy executable
cp "$EXECUTABLE" "$APP_BUNDLE/Contents/MacOS/SnapTranslate"
chmod +x "$APP_BUNDLE/Contents/MacOS/SnapTranslate"

# Copy Info.plist
cp "$PROJECT_DIR/Sources/SnapTranslate/Info.plist" "$APP_BUNDLE/Contents/Info.plist"

# Copy entitlements
cp "$PROJECT_DIR/Sources/SnapTranslate/SnapTranslate.entitlements" "$APP_BUNDLE/Contents/SnapTranslate.entitlements"

echo "✅ App bundle ready at:"
echo "   $APP_BUNDLE"
echo ""

# Run
echo "▶️  Launching app..."
echo ""

# Remove from Accessibility cache to force re-prompt
echo "🔐 Clearing accessibility cache..."
defaults delete /Users/lamngoc/.com.apple.dt.Xcode.plist 2>/dev/null || true

# Launch app
open "$APP_BUNDLE"

echo ""
echo "✅ App launched!"
echo ""
echo "If you see an accessibility permission prompt:"
echo "  1. Click 'Open System Preferences'"
echo "  2. Grant permission"
echo "  3. Run this script again"
echo ""
echo "Then test: Press Cmd+Ctrl+C to trigger capture"
