#!/bin/bash

echo "🔧 Testing Android theme configuration..."
echo ""

# Check if AppCompat themes are being used
echo "📋 Theme Configuration:"
if grep -q "Theme.AppCompat.DayNight.NoActionBar" app/src/main/res/values/themes.xml; then
    echo "✅ Light theme uses AppCompat (compatible)"
else
    echo "❌ Light theme not using AppCompat"
fi

if grep -q "Theme.AppCompat.DayNight.NoActionBar" app/src/main/res/values-night/themes.xml; then
    echo "✅ Dark theme uses AppCompat (compatible)"
else
    echo "❌ Dark theme not using AppCompat"
fi

# Check dependencies
echo ""
echo "📦 Dependencies:"
if grep -q "appcompat" gradle/libs.versions.toml; then
    echo "✅ AppCompat library configured"
else
    echo "❌ AppCompat library missing"
fi

if grep -q "material.*1.11.0" gradle/libs.versions.toml; then
    echo "✅ Material Design Components configured"
else
    echo "❌ Material Design Components missing"
fi

if grep -q "libs.appcompat" app/build.gradle.kts; then
    echo "✅ AppCompat dependency included in app"
else
    echo "❌ AppCompat dependency not included in app"
fi

echo ""
echo "🎯 Changes Made:"
echo "   • Switched from Material3 themes to AppCompat themes"
echo "   • Added AppCompat 1.6.1 dependency"
echo "   • Added Material Design Components 1.11.0"
echo "   • Used compatible theme attributes"
echo "   • Cleaned all build caches"
echo ""
echo "✅ The build should now succeed with AppCompat themes!"