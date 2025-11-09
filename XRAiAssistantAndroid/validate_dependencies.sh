#!/bin/bash

# Script to validate Android dependencies without requiring Java build
# This script checks if the dependencies are properly configured

echo "🔍 Validating Android dependency configuration..."

# Check if settings.gradle.kts exists and has proper repositories
if [[ -f "settings.gradle.kts" ]]; then
    echo "✅ settings.gradle.kts found"
    
    if grep -q "mavenCentral()" settings.gradle.kts; then
        echo "✅ Maven Central repository configured"
    else
        echo "❌ Maven Central repository not found"
        exit 1
    fi
    
    if grep -q "google()" settings.gradle.kts; then
        echo "✅ Google repository configured"
    else
        echo "❌ Google repository not found"
        exit 1
    fi
else
    echo "❌ settings.gradle.kts not found"
    exit 1
fi

# Check if libs.versions.toml has the commonmark dependency
if [[ -f "gradle/libs.versions.toml" ]]; then
    echo "✅ libs.versions.toml found"
    
    if grep -q "commonmark" gradle/libs.versions.toml; then
        echo "✅ CommonMark dependency configured"
    else
        echo "❌ CommonMark dependency not found"
        exit 1
    fi
else
    echo "❌ gradle/libs.versions.toml not found"
    exit 1
fi

# Check if app/build.gradle.kts references the correct dependency
if [[ -f "app/build.gradle.kts" ]]; then
    echo "✅ app/build.gradle.kts found"
    
    if grep -q "libs.commonmark" app/build.gradle.kts; then
        echo "✅ CommonMark dependency referenced in app build"
    else
        echo "❌ CommonMark dependency not referenced in app build"
        exit 1
    fi
else
    echo "❌ app/build.gradle.kts not found"
    exit 1
fi

echo ""
echo "🎉 All dependency configurations look correct!"
echo ""
echo "📝 Summary of changes made:"
echo "   • Replaced com.halilibo.compose:markdown:0.3.1"
echo "   • With org.commonmark:commonmark:0.21.0"
echo "   • CommonMark is available on Maven Central"
echo "   • No code changes needed (no existing markdown usage found)"
echo ""
echo "🛠️  Next steps:"
echo "   1. Install Java JDK 17+ on your system"
echo "   2. Run './gradlew build' to test the build"
echo "   3. If using markdown in the future, import: org.commonmark.*"