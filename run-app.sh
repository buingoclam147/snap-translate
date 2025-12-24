#!/bin/bash

# SnapTranslate App Runner
# This script packages and runs the SPM executable as a proper macOS app

set -e

PROJECT_DIR="/Users/lamngoc/snap-translate"
BUILD_DIR="$PROJECT_DIR/.build/debug"
EXECUTABLE="$BUILD_DIR/ESnap"
APP_BUNDLE="$BUILD_DIR/ESnap.app"

echo "=================================="
echo "🚀 ESnap App Launcher"
echo "=================================="
echo ""

# Clean build directory first
echo "🧹 Cleaning old build..."
rm -rf "$BUILD_DIR"

# Always build to get latest changes
echo "📦 Building ESnap..."
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
cp "$EXECUTABLE" "$APP_BUNDLE/Contents/MacOS/ESnap"
chmod +x "$APP_BUNDLE/Contents/MacOS/ESnap"

# Copy Info.plist
cp "$PROJECT_DIR/Sources/SnapTranslate/Info.plist" "$APP_BUNDLE/Contents/Info.plist"

# Copy image resources and app icon
cp "$PROJECT_DIR/Sources/SnapTranslate/Assets.xcassets/ESnap.imageset/ESnap.png" "$APP_BUNDLE/Contents/Resources/"
cp "$PROJECT_DIR/Sources/SnapTranslate/AppIcon.icns" "$APP_BUNDLE/Contents/Resources/"

# Copy entitlements
cp "$PROJECT_DIR/Sources/SnapTranslate/SnapTranslate.entitlements" "$APP_BUNDLE/Contents/ESnap.entitlements"

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
