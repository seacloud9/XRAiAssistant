#!/bin/bash

# XRAiAssistant Pre-Build Script
# Runs automatically before Xcode builds
# Add this to Xcode: Project Settings → Build Phases → New Run Script Phase
# Script: ${PROJECT_DIR}/scripts/pre_build.sh

set -e

echo "🔍 Running pre-build checks..."

PROJECT_ROOT="${PROJECT_DIR:-.}"
cd "$PROJECT_ROOT"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ERRORS=0

# 1. Quick syntax check on modified files
echo "Checking Swift syntax..."
SWIFT_FILES=$(find XRAiAssistant/XRAiAssistant -name "*.swift" -not -path "*/Preview Content/*" 2>/dev/null || true)

if [ -n "$SWIFT_FILES" ]; then
    for file in $SWIFT_FILES; do
        # Quick brace balance check
        open_braces=$(grep -o '{' "$file" | wc -l | tr -d ' ')
        close_braces=$(grep -o '}' "$file" | wc -l | tr -d ' ')
        
        if [ "$open_braces" -ne "$close_braces" ]; then
            echo -e "${RED}❌ Unmatched braces in $(basename "$file"): open=$open_braces close=$close_braces${NC}"
            ERRORS=$((ERRORS + 1))
        fi
    done
fi

# 2. Run SwiftLint if available (quick mode)
if command -v swiftlint &> /dev/null; then
    echo "Running SwiftLint..."
    if ! swiftlint lint --quiet --strict XRAiAssistant/XRAiAssistant 2>&1 | head -20; then
        echo -e "${YELLOW}⚠️  SwiftLint warnings found${NC}"
    fi
fi

# Exit status
if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}❌ Pre-build checks failed with $ERRORS error(s)${NC}"
    exit 1
else
    echo -e "${GREEN}✅ Pre-build checks passed${NC}"
    exit 0
fi
