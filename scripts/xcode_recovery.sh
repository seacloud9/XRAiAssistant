#!/bin/bash

# Xcode Project Recovery Script
# Fixes "duplicate GUID" and other Xcode corruption issues

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔧 XRAiAssistant - Xcode Project Recovery"
echo "========================================"
echo ""

echo "📍 Project root: $PROJECT_ROOT"
echo ""

# Step 1: Close Xcode
echo "⚠️  Step 1: Closing Xcode..."
osascript -e 'tell application "Xcode" to quit' 2>/dev/null || echo "  Xcode not running"
sleep 2
echo "✅ Xcode closed"
echo ""

# Step 2: Clean DerivedData
echo "🧹 Step 2: Cleaning DerivedData..."
DERIVED_DATA_PATH="$HOME/Library/Developer/Xcode/DerivedData"
if [ -d "$DERIVED_DATA_PATH" ]; then
    # Find and remove only XRAiAssistant derived data
    find "$DERIVED_DATA_PATH" -name "XRAiAssistant-*" -maxdepth 1 -type d -exec rm -rf {} + 2>/dev/null || true
    echo "✅ Removed XRAiAssistant DerivedData"
else
    echo "  No DerivedData found"
fi
echo ""

# Step 3: Clean Swift Package Manager caches
echo "🧹 Step 3: Cleaning Swift Package Manager caches..."
SPM_CACHE="$HOME/Library/Caches/org.swift.swiftpm"
if [ -d "$SPM_CACHE" ]; then
    rm -rf "$SPM_CACHE" 2>/dev/null || true
    echo "✅ Cleared SPM cache"
else
    echo "  No SPM cache found"
fi
echo ""

# Step 4: Clean Xcode caches
echo "🧹 Step 4: Cleaning Xcode caches..."
XCODE_CACHE="$HOME/Library/Developer/Xcode/DerivedData/ModuleCache.noindex"
if [ -d "$XCODE_CACHE" ]; then
    rm -rf "$XCODE_CACHE" 2>/dev/null || true
    echo "✅ Cleared module cache"
else
    echo "  No module cache found"
fi
echo ""

# Step 5: Remove project workspace data
echo "🧹 Step 5: Cleaning workspace data..."
WORKSPACE_DATA="XRAiAssistant/XRAiAssistant.xcodeproj/project.xcworkspace/xcuserdata"
if [ -d "$WORKSPACE_DATA" ]; then
    rm -rf "$WORKSPACE_DATA" 2>/dev/null || true
    echo "✅ Removed workspace user data"
else
    echo "  No workspace user data found"
fi
echo ""

# Step 6: Remove xcuserdata
echo "🧹 Step 6: Cleaning xcuserdata..."
XCUSER_DATA="XRAiAssistant/XRAiAssistant.xcodeproj/xcuserdata"
if [ -d "$XCUSER_DATA" ]; then
    rm -rf "$XCUSER_DATA" 2>/dev/null || true
    echo "✅ Removed xcuserdata"
else
    echo "  No xcuserdata found"
fi
echo ""

# Step 7: Verify project file integrity
echo "🔍 Step 7: Verifying project.pbxproj integrity..."
PBXPROJ="XRAiAssistant/XRAiAssistant.xcodeproj/project.pbxproj"
if [ -f "$PBXPROJ" ]; then
    # Check for duplicate GUIDs
    DUPLICATE_GUIDS=$(grep -oE '[A-F0-9]{24}' "$PBXPROJ" | sort | uniq -d | wc -l | tr -d ' ')
    if [ "$DUPLICATE_GUIDS" -eq 0 ]; then
        echo "✅ No duplicate GUIDs found in project file"
    else
        echo "⚠️  Found $DUPLICATE_GUIDS duplicate GUIDs"
        echo "  This should be fixed by Xcode when it reopens"
    fi
    
    # Check if file is valid
    if plutil -lint "$PBXPROJ" >/dev/null 2>&1; then
        echo "✅ Project file syntax is valid"
    else
        echo "❌ Project file has syntax errors"
        echo "  You may need to restore from git"
    fi
else
    echo "❌ Project file not found"
    exit 1
fi
echo ""

# Step 8: Clean Package.resolved
echo "🧹 Step 8: Cleaning Package.resolved..."
PACKAGE_RESOLVED="XRAiAssistant/XRAiAssistant.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"
if [ -f "$PACKAGE_RESOLVED" ]; then
    rm -f "$PACKAGE_RESOLVED" 2>/dev/null || true
    echo "✅ Removed Package.resolved (will be regenerated)"
else
    echo "  No Package.resolved found"
fi
echo ""

echo "========================================"
echo "✅ Xcode Project Recovery Complete!"
echo "========================================"
echo ""
echo "📝 Next Steps:"
echo "1. Open Xcode: open XRAiAssistant/XRAiAssistant.xcodeproj"
echo "2. Wait for packages to resolve (may take 1-2 minutes)"
echo "3. Clean build folder: Product → Clean Build Folder (Shift+Cmd+K)"
echo "4. Build: Product → Build (Cmd+B)"
echo ""
echo "💡 If issues persist:"
echo "   - Restart your Mac"
echo "   - Check for Xcode updates"
echo "   - Verify git status: git status"
echo ""
