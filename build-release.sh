#!/bin/bash

# ESnap Release Builder
# Tạo release app bundle sẵn để phân phối theo chuẩn macOS

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$PROJECT_DIR/.build/release"
EXECUTABLE="$BUILD_DIR/ESnap"
APP_BUNDLE="$BUILD_DIR/ESnap.app"
OUTPUT_DIR="$PROJECT_DIR/releases"
DMG_TEMP_DIR="/tmp/esnap-dmg-$$"

echo "=================================="
echo "🚀 ESnap Release Builder"
echo "=================================="
echo ""

# Clean old builds COMPLETELY
echo "🧹 Cleaning old builds..."
rm -rf "$BUILD_DIR"
rm -rf "$DMG_TEMP_DIR"

# Backup old releases (optional)
if [ -d "$OUTPUT_DIR" ]; then
    echo "📦 Old releases found, creating backup..."
    BACKUP_DIR="$OUTPUT_DIR/.backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    find "$OUTPUT_DIR" -maxdepth 1 -type f \( -name "*.dmg" -o -name "*.zip" \) -exec mv {} "$BACKUP_DIR" \;
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Build in release mode
echo "📦 Building ESnap (release mode)..."
cd "$PROJECT_DIR"
swift build -c release 2>&1
echo ""

# Create app bundle structure
echo "📁 Creating app bundle..."
mkdir -p "$APP_BUNDLE/Contents/MacOS"
mkdir -p "$APP_BUNDLE/Contents/Resources"

# Copy executable
cp "$EXECUTABLE" "$APP_BUNDLE/Contents/MacOS/ESnap"
chmod +x "$APP_BUNDLE/Contents/MacOS/ESnap"

# Copy Info.plist
if [ -f "$PROJECT_DIR/Sources/SnapTranslate/Info.plist" ]; then
    cp "$PROJECT_DIR/Sources/SnapTranslate/Info.plist" "$APP_BUNDLE/Contents/Info.plist"
    echo "✅ Info.plist copied"
fi

# Copy resources
if [ -f "$PROJECT_DIR/Sources/SnapTranslate/Assets.xcassets/ESnap.imageset/ESnap.png" ]; then
    cp "$PROJECT_DIR/Sources/SnapTranslate/Assets.xcassets/ESnap.imageset/ESnap.png" "$APP_BUNDLE/Contents/Resources/"
    echo "✅ App icon (PNG) copied"
fi

if [ -f "$PROJECT_DIR/Sources/SnapTranslate/AppIcon.icns" ]; then
    cp "$PROJECT_DIR/Sources/SnapTranslate/AppIcon.icns" "$APP_BUNDLE/Contents/Resources/"
    echo "✅ Bundle icon (ICNS) copied"
fi

echo ""
echo "✅ App bundle ready:"
echo "   $APP_BUNDLE"
echo ""

# Create DMG (với Applications shortcut)
echo "📦 Creating DMG (macOS standard format)..."

# Create temporary DMG staging area
mkdir -p "$DMG_TEMP_DIR"
cp -r "$APP_BUNDLE" "$DMG_TEMP_DIR/"

# Create symbolic link to /Applications
ln -s /Applications "$DMG_TEMP_DIR/Applications"

echo "   - Added Applications folder shortcut"

# Create DMG
DMG_FILE="$OUTPUT_DIR/ESnap.dmg"
rm -f "$DMG_FILE"

# Create with proper format
hdiutil create \
    -volname "ESnap" \
    -srcfolder "$DMG_TEMP_DIR" \
    -ov \
    -format UDZO \
    -imagekey zlib-level=9 \
    "$DMG_FILE" 2>&1

echo "✅ DMG created: $DMG_FILE"
echo ""

# Cleanup temp directory
rm -rf "$DMG_TEMP_DIR"

# Create ZIP as alternative
echo "📦 Creating ZIP (alternative format)..."
cd "$BUILD_DIR"
ZIP_FILE="$OUTPUT_DIR/ESnap.zip"
rm -f "$ZIP_FILE"
zip -r -q "$ZIP_FILE" ESnap.app
cd "$PROJECT_DIR"

echo "✅ ZIP created: $ZIP_FILE"
echo ""

# Summary
echo "=================================="
echo "✨ Release Build Complete!"
echo "=================================="
echo ""
echo "📦 Output files in: $OUTPUT_DIR"
ls -lh "$OUTPUT_DIR" | grep -E "\.dmg|\.zip|^total"
echo ""
echo "📤 To distribute:"
echo "   ✓ $DMG_FILE (recommended - standard macOS installer)"
echo "     → User mở DMG, kéo app vào Applications folder"
echo ""
echo "   ✓ $ZIP_FILE (alternative - simpler)"
echo "     → User giải nén, chạy app"
echo ""
echo "🧪 To test locally:"
echo "   open '$DMG_FILE'"
echo ""
