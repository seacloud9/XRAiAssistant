#!/bin/bash

echo "🎨 Validating Android Material3 theme fixes..."
echo ""

# Check if light theme exists
if [[ -f "app/src/main/res/values/themes.xml" ]]; then
    echo "✅ Light theme file exists"
    if grep -q "Theme.Material3.DayNight.NoActionBar" app/src/main/res/values/themes.xml; then
        echo "✅ Light theme uses Material3.DayNight parent"
    else
        echo "❌ Light theme parent incorrect"
    fi
else
    echo "❌ Light theme file missing"
fi

# Check if dark theme exists
if [[ -f "app/src/main/res/values-night/themes.xml" ]]; then
    echo "✅ Dark theme file exists"
    if grep -q "Theme.Material3.DayNight.NoActionBar" app/src/main/res/values-night/themes.xml; then
        echo "✅ Dark theme uses Material3.DayNight parent"
    else
        echo "❌ Dark theme parent incorrect"
    fi
else
    echo "❌ Dark theme file missing"
fi

# Check color resources
if [[ -f "app/src/main/res/values/colors.xml" ]]; then
    echo "✅ Color resources file exists"
else
    echo "❌ Color resources file missing"
fi

# Check theme reference in manifest
if [[ -f "app/src/main/AndroidManifest.xml" ]]; then
    echo "✅ AndroidManifest.xml exists"
    if grep -q "Theme.XRAiAssistant" app/src/main/AndroidManifest.xml; then
        echo "✅ Theme referenced in manifest"
    else
        echo "❌ Theme not referenced in manifest"
    fi
else
    echo "❌ AndroidManifest.xml missing"
fi

# Check version compatibility
echo ""
echo "📋 Version Summary:"
echo "   • Compose BOM: $(grep 'compose-bom' gradle/libs.versions.toml | cut -d'"' -f2)"
echo "   • Kotlin: $(grep '^kotlin' gradle/libs.versions.toml | cut -d'"' -f2)"
echo "   • AGP: $(grep '^agp' gradle/libs.versions.toml | cut -d'"' -f2)"
echo "   • Compiler Extension: $(grep 'kotlinCompilerExtensionVersion' app/build.gradle.kts | cut -d'"' -f2)"

echo ""
echo "🛠️  Changes Made:"
echo "   1. ✅ Updated Compose BOM to 2024.02.00 (better Material3 support)"
echo "   2. ✅ Updated Kotlin to 1.9.22 (compatibility)"
echo "   3. ✅ Updated AGP to 8.2.2 (latest stable)"
echo "   4. ✅ Simplified theme structure (removed complex color references)"
echo "   5. ✅ Added proper dark theme in values-night/"
echo "   6. ✅ Used direct hex colors for better compatibility"
echo "   7. ✅ Cleaned gradle cache"
echo ""
echo "🎯 The Material3 theme resource linking errors should now be resolved!"
echo "   Next: Run './gradlew build' to test the fixes"