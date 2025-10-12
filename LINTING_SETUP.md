# Linting Setup for XRAiAssistant

## Overview
Automated linting prevents syntax errors and maintains code quality. This setup includes:
- SwiftLint for style checking
- Syntax validation before builds
- Brace matching
- Automated pre-build checks

---

## Quick Start

### 1. Install SwiftLint
```bash
brew install swiftlint
```

### 2. Run Manual Lint
```bash
./scripts/lint_swift.sh
```

### 3. Add to Xcode (Automated)

**Option A: Pre-Build Script (Recommended)**
1. Open `XRAiAssistant.xcodeproj` in Xcode
2. Select the project in navigator
3. Select "XRAiAssistant" target
4. Go to "Build Phases" tab
5. Click "+" → "New Run Script Phase"
6. Name it "Pre-Build Lint"
7. Move it to the top (before "Compile Sources")
8. Add this script:
```bash
${PROJECT_DIR}/scripts/pre_build.sh
```
9. Check "Based on dependency analysis"

**Option B: Post-Build Analysis**
Add another Run Script Phase after compilation:
```bash
${PROJECT_DIR}/scripts/lint_swift.sh
```

---

## Scripts

### `scripts/lint_swift.sh` - Comprehensive Linting
Full linting suite that checks:
- SwiftLint style violations
- Swift syntax errors
- Brace matching
- TODO/FIXME counts

**Usage:**
```bash
./scripts/lint_swift.sh
```

**When to use:** Before commits, end of sessions

### `scripts/pre_build.sh` - Quick Pre-Build Check
Fast checks before Xcode builds:
- Brace matching only
- Quick SwiftLint pass
- Fails build on errors

**Usage:** Automatic (via Xcode Build Phase)

---

## SwiftLint Configuration

Located in `.swiftlint.yml`:

**Enabled checks:**
- Code style and formatting
- Unused imports and declarations
- Redundant code
- Naming conventions

**Disabled:**
- `line_length` (SwiftUI views can be long)
- `force_cast` (sometimes necessary)
- `todo` (allowed during development)

**Custom rules:**
- Warning on `print()` statements (prefer logging)
- Warning on empty catch blocks

---

## Common Errors Prevented

### 1. Extraneous Braces
```swift
// ❌ Error - Extra closing brace
func myFunc() {
    // code
}
}  // <-- Extraneous

// ✅ Correct
func myFunc() {
    // code
}
```

**Detection:** Brace counting in `lint_swift.sh`

### 2. Optional String Interpolation
```swift
// ❌ Warning
print("Error: \(error)")  // error is Optional

// ✅ Correct
print("Error: \(error?.localizedDescription ?? "unknown")")
```

**Detection:** SwiftLint + Xcode warnings

### 3. Type-Checking Timeout
```swift
// ❌ Complex nested views
var body: some View {
    VStack {
        HStack {
            Menu {
                ForEach(...) {
                    // 100+ lines...
                }
            }
        }
    }
}

// ✅ Extracted views
var body: some View {
    VStack {
        headerView
        contentView
    }
}

private var headerView: some View { ... }
```

**Detection:** Manual code review (SwiftLint warns on long functions)

---

## Integration with Git

### Pre-Commit Hook
Add to `.git/hooks/pre-commit`:
```bash
#!/bin/bash
./scripts/lint_swift.sh
if [ $? -ne 0 ]; then
    echo "Linting failed. Commit aborted."
    exit 1
fi
```

Make executable:
```bash
chmod +x .git/hooks/pre-commit
```

---

## CI/CD Integration

### GitHub Actions
```yaml
name: Lint
on: [push, pull_request]
jobs:
  lint:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install SwiftLint
        run: brew install swiftlint
      - name: Run Linting
        run: ./scripts/lint_swift.sh
```

---

## Troubleshooting

### SwiftLint Not Found
```bash
# Install via Homebrew
brew install swiftlint

# OR download binary
https://github.com/realm/SwiftLint/releases
```

### Pre-Build Script Not Running
1. Check script is executable: `ls -l scripts/pre_build.sh`
2. Verify path in Xcode Build Phase
3. Check "Show environment variables in build log"

### False Positives
Edit `.swiftlint.yml` to disable specific rules:
```yaml
disabled_rules:
  - rule_name_here
```

---

## Best Practices

### During Development
- Run `lint_swift.sh` before committing
- Fix errors immediately (don't accumulate)
- Review warnings periodically

### Before Releases
- Clean build: Cmd+Shift+K
- Run full lint: `./scripts/lint_swift.sh`
- Check TODO/FIXME count
- Verify no syntax errors

### Code Review
- Lint should pass before PR
- Address all errors
- Discuss warnings as needed

---

## Example Output

### Successful Lint
```
🔍 XRAiAssistant Swift Linting
==============================

1. Checking for SwiftLint...
✅ SwiftLint installed: 0.50.3

2. Running SwiftLint...
✅ SwiftLint passed with no violations

3. Checking Swift syntax...
✅ No syntax errors found in 45 Swift files

4. Checking for common issues...
   ✅ All braces matched
   ℹ️  Found 3 TODO and 1 FIXME comments

==============================
✅ All checks passed! Code is ready to build.
```

### With Errors
```
3. Checking Swift syntax...
❌ Syntax errors in: ContentView.swift
error: extraneous '}' at top level

4. Checking for common issues...
   ❌ Unmatched braces in ContentView.swift: { count=42, } count=43

==============================
❌ Linting found errors. Please fix before building.
```

---

## Summary

**Manual:** `./scripts/lint_swift.sh` before commits  
**Automatic:** Add `pre_build.sh` to Xcode Build Phases  
**Configuration:** Edit `.swiftlint.yml` as needed

This prevents syntax errors like the extraneous braces we encountered and maintains code quality automatically! 🎉
