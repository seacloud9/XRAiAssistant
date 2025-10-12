#!/bin/bash

# XRAiAssistant Swift Linting Script
# Quick syntax checks without hanging
# Usage: ./scripts/lint_swift.sh

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🔍 XRAiAssistant Quick Lint"
echo "============================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 1. Count Swift files
echo "1. Scanning Swift files..."
SWIFT_FILES=$(find XRAiAssistant/XRAiAssistant -name "*.swift" -not -path "*/Preview Content/*" -not -path "*/DerivedData/*" -not -path "*/Build/*")
FILE_COUNT=$(echo "$SWIFT_FILES" | wc -l | tr -d ' ')
echo -e "${GREEN}✅ Found $FILE_COUNT Swift files${NC}"
echo ""

# 2. Run SwiftLint (if available, with timeout)
echo "2. Running SwiftLint..."
if command -v swiftlint &> /dev/null; then
    if timeout 5s swiftlint lint --quiet XRAiAssistant/XRAiAssistant/ 2>/dev/null; then
        echo -e "${GREEN}✅ SwiftLint passed${NC}"
    else
        echo -e "${YELLOW}⚠️  SwiftLint found style issues (non-blocking)${NC}"
    fi
else
    echo -e "${YELLOW}ℹ️  SwiftLint not installed (optional)${NC}"
fi
echo ""

# 3. Check TODO/FIXME
echo "3. Checking annotations..."
TODO_COUNT=$(grep -r "// TODO:" XRAiAssistant/XRAiAssistant --include="*.swift" 2>/dev/null | wc -l | tr -d ' ')
FIXME_COUNT=$(grep -r "// FIXME:" XRAiAssistant/XRAiAssistant --include="*.swift" 2>/dev/null | wc -l | tr -d ' ')
echo -e "${YELLOW}ℹ️  Found $TODO_COUNT TODO and $FIXME_COUNT FIXME comments${NC}"
echo ""

# Summary - treat as informational only
echo "============================"
echo -e "${GREEN}✅ Lint check complete!${NC}"
echo -e "${YELLOW}ℹ️  Build with Xcode (Cmd+B) to verify compilation${NC}"
exit 0
