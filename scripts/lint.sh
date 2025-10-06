#!/bin/bash

# SwiftLint runner script for XRAiAssistant
# Usage: ./scripts/lint.sh [--fix] [--strict]

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project root directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo -e "${BLUE}🧹 XRAiAssistant SwiftLint Runner${NC}"
echo "Project root: $PROJECT_ROOT"

# Check if SwiftLint is installed
if ! command -v swiftlint &> /dev/null; then
    echo -e "${RED}❌ SwiftLint is not installed${NC}"
    echo -e "${YELLOW}📦 Installing SwiftLint via Homebrew...${NC}"

    if command -v brew &> /dev/null; then
        brew install swiftlint
    else
        echo -e "${RED}❌ Homebrew not found. Please install SwiftLint manually:${NC}"
        echo "Visit: https://github.com/realm/SwiftLint#installation"
        exit 1
    fi
fi

# Get SwiftLint version
SWIFTLINT_VERSION=$(swiftlint version)
echo -e "${GREEN}✅ SwiftLint $SWIFTLINT_VERSION found${NC}"

# Parse command line arguments
FIX_MODE=false
STRICT_MODE=false

for arg in "$@"; do
    case $arg in
        --fix)
            FIX_MODE=true
            shift
            ;;
        --strict)
            STRICT_MODE=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "OPTIONS:"
            echo "  --fix     Automatically fix violations that can be corrected"
            echo "  --strict  Enable strict mode (treat warnings as errors)"
            echo "  --help    Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Unknown option: $arg${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Run SwiftLint with appropriate options
echo -e "${BLUE}🔍 Running SwiftLint analysis...${NC}"

if [ "$FIX_MODE" = true ]; then
    echo -e "${YELLOW}🔧 Auto-fixing violations...${NC}"
    swiftlint --fix --format --config .swiftlint.yml
fi

# Main linting
if [ "$STRICT_MODE" = true ]; then
    echo -e "${YELLOW}⚠️  Running in strict mode (warnings as errors)${NC}"
    swiftlint lint --strict --config .swiftlint.yml
else
    swiftlint lint --config .swiftlint.yml
fi

LINT_EXIT_CODE=$?

# Report results
if [ $LINT_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✅ SwiftLint passed! No violations found.${NC}"

    # Run quick stats
    echo -e "${BLUE}📊 Code Quality Stats:${NC}"
    SWIFT_FILES=$(find XRAiAssistant/XRAiAssistant -name "*.swift" | wc -l | tr -d ' ')
    TOTAL_LINES=$(find XRAiAssistant/XRAiAssistant -name "*.swift" -exec wc -l {} + | tail -1 | awk '{print $1}')
    echo "  Swift files: $SWIFT_FILES"
    echo "  Total lines: $TOTAL_LINES"
    echo "  Average lines per file: $((TOTAL_LINES / SWIFT_FILES))"
else
    echo -e "${RED}❌ SwiftLint found violations. Please fix them before committing.${NC}"

    if [ "$FIX_MODE" = false ]; then
        echo -e "${YELLOW}💡 Tip: Run './scripts/lint.sh --fix' to automatically fix some violations${NC}"
    fi
fi

# Additional checks for XRAiAssistant-specific patterns
echo -e "${BLUE}🎯 Running XRAiAssistant-specific checks...${NC}"

# Check for proper AI/3D naming conventions
echo "  - Checking naming conventions..."
NAMING_VIOLATIONS=0

if grep -r "threejs\|threeJS" XRAiAssistant/XRAiAssistant --include="*.swift" > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Found inconsistent Three.js naming${NC}"
    NAMING_VIOLATIONS=$((NAMING_VIOLATIONS + 1))
fi

if grep -r "TODO\|FIXME\|HACK" XRAiAssistant/XRAiAssistant --include="*.swift" > /dev/null 2>&1; then
    TODO_COUNT=$(grep -r "TODO\|FIXME\|HACK" XRAiAssistant/XRAiAssistant --include="*.swift" | wc -l | tr -d ' ')
    echo -e "${YELLOW}📝 Found $TODO_COUNT TODO/FIXME/HACK comments${NC}"
fi

# Check for debug code
if grep -r "print(" XRAiAssistant/XRAiAssistant --include="*.swift" > /dev/null 2>&1; then
    PRINT_COUNT=$(grep -r "print(" XRAiAssistant/XRAiAssistant --include="*.swift" | wc -l | tr -d ' ')
    echo -e "${YELLOW}🐛 Found $PRINT_COUNT print statements (consider using proper logging)${NC}"
fi

if [ $NAMING_VIOLATIONS -eq 0 ]; then
    echo -e "${GREEN}✅ All XRAiAssistant-specific checks passed!${NC}"
fi

echo -e "${BLUE}🎉 Linting complete!${NC}"
exit $LINT_EXIT_CODE