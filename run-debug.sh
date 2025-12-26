#!/bin/bash

# TSnap Debug Runner
# Build & run app in debug mode - fresh build, no cache

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$PROJECT_DIR/.build/debug"
EXECUTABLE="$BUILD_DIR/TSnap"

echo "=================================="
echo "🚀 TSnap Debug Runner"
echo "=================================="
echo ""

# Clean build cache (fresh build, no cache issues)
echo "🧹 Cleaning build cache..."
rm -rf "$BUILD_DIR"
echo "✅ Cache cleared"
echo ""

# Build in debug mode
echo "📦 Building TSnap (debug mode)..."
cd "$PROJECT_DIR"
swift build -c debug 2>&1
echo ""
echo "✅ Build complete"
echo ""

# Run the app
if [ -f "$EXECUTABLE" ]; then
    echo "▶️  Running TSnap..."
    echo "════════════════════════════════════════"
    "$EXECUTABLE"
else
    echo "❌ Executable not found: $EXECUTABLE"
    exit 1
fi
