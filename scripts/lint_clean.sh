#!/bin/bash

# SwiftLint runner script for XRAiAssistant
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "🧹 XRAiAssistant SwiftLint Runner"
echo "Project root: $PROJECT_ROOT"

# Check if SwiftLint is installed
if ! command -v swiftlint &> /dev/null; then
    echo "❌ SwiftLint is not installed"
    echo "📦 Install with: brew install swiftlint"
    exit 1
fi

# Get SwiftLint version
SWIFTLINT_VERSION=$(swiftlint version)
echo "✅ SwiftLint $SWIFTLINT_VERSION found"

# Parse arguments
FIX_MODE=false
for arg in "$@"; do
    case $arg in
        --fix)
            FIX_MODE=true
            ;;
        --help|-h)
            echo "Usage: $0 [--fix] [--help]"
            echo "  --fix   Auto-fix violations"
            echo "  --help  Show help"
            exit 0
            ;;
    esac
done

# Run SwiftLint
echo "🔍 Running SwiftLint analysis..."

if [ "$FIX_MODE" = true ]; then
    echo "🔧 Auto-fixing violations..."
    swiftlint --fix --format --config .swiftlint.yml
fi

swiftlint lint --config .swiftlint.yml

LINT_EXIT_CODE=$?

if [ $LINT_EXIT_CODE -eq 0 ]; then
    echo "✅ SwiftLint passed!"
else
    echo "❌ SwiftLint found violations"
fi

exit $LINT_EXIT_CODE