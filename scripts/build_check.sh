#!/bin/bash

# Safe iOS build check script for XRAiAssistant
# This script performs a quick syntax/compile check without hanging

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔨 XRAiAssistant Build Check"
echo "Project root: $PROJECT_ROOT"
echo ""

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ xcodebuild not found"
    echo "💡 Make sure Xcode is installed"
    exit 1
fi

# Check if project file exists
if [ ! -f "XRAiAssistant/XRAiAssistant.xcodeproj/project.pbxproj" ]; then
    echo "❌ Xcode project not found"
    exit 1
fi

echo "🚀 Starting build check..."
echo "⚠️  This may take 1-2 minutes on first run (resolving packages)"
echo ""

# Build with timeout to prevent hanging
# Using 'timeout' command if available (macOS doesn't have it by default)
if command -v timeout &> /dev/null; then
    BUILD_CMD="timeout 300"
else
    BUILD_CMD=""
fi

# Run build and capture output
$BUILD_CMD xcodebuild \
  -project XRAiAssistant/XRAiAssistant.xcodeproj \
  -scheme XRAiAssistant \
  -configuration Debug \
  -sdk iphonesimulator \
  -quiet \
  build \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  2>&1 | tee /tmp/xrabuild.log

BUILD_EXIT_CODE=${PIPESTATUS[0]}

echo ""
echo "📊 Build Summary"
echo "════════════════════════════════════════════════"

# Check for errors
ERROR_COUNT=$(grep -c "error:" /tmp/xrabuild.log || echo "0")
WARNING_COUNT=$(grep -c "warning:" /tmp/xrabuild.log || echo "0")

if [ $BUILD_EXIT_CODE -eq 0 ]; then
    echo "✅ BUILD SUCCEEDED"
    if [ "$WARNING_COUNT" -gt 0 ]; then
        echo "⚠️  $WARNING_COUNT warning(s) found"
        echo ""
        echo "Warnings:"
        grep "warning:" /tmp/xrabuild.log | head -10
    fi
else
    echo "❌ BUILD FAILED"
    echo "❌ $ERROR_COUNT error(s) found"
    if [ "$WARNING_COUNT" -gt 0 ]; then
        echo "⚠️  $WARNING_COUNT warning(s) found"
    fi
    echo ""
    echo "Errors:"
    grep "error:" /tmp/xrabuild.log | head -20
    echo ""
    echo "💡 Full build log saved to: /tmp/xrabuild.log"
    exit 1
fi

echo "════════════════════════════════════════════════"
echo ""
echo "✅ Build check complete!"
echo ""

# Clean up
rm -f /tmp/xrabuild.log

exit 0
