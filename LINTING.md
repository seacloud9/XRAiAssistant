# 🧹 XRAiAssistant Linting Setup

## 📋 Overview

This project uses **SwiftLint** to maintain consistent Swift code quality and catch common issues early in development.

## 🚀 Quick Start

### 1. Install SwiftLint
```bash
brew install swiftlint
```

### 2. Run Linting
```bash
# Basic lint check
swiftlint lint

# Auto-fix some issues
swiftlint --fix

# Lint specific files
swiftlint lint XRAiAssistant/XRAiAssistant/ContentView.swift
```

## ⚙️ Configuration

The project includes a comprehensive `.swiftlint.yml` configuration with:

### 📏 **Code Metrics**
- **Line length**: Warning at 120, error at 150 characters
- **Function length**: Warning at 80, error at 120 lines
- **File length**: Warning at 400, error at 500 lines
- **Type length**: Warning at 300, error at 400 lines

### ✅ **Enabled Rules**
- `empty_count` - Prefer `isEmpty` over `count == 0`
- `empty_string` - Prefer `isEmpty` over `== ""`
- `trailing_closure` - Use trailing closure syntax when appropriate

### 🚫 **Disabled Rules**
- `todo` - Allow TODO comments during development
- `trailing_whitespace` - Auto-fixable, non-critical

### 🎯 **Custom Rules for XRAiAssistant**
- **No print statements**: Warns about `print()` usage, suggests proper logging
- **3D/AI naming**: Ensures consistent naming for Three.js, React Three Fiber, etc.

## 🔧 Xcode Integration

### Method 1: Run Script Build Phase

1. Open your Xcode project
2. Select your target → Build Phases
3. Add "New Run Script Phase"
4. Add this script:

```bash
if which swiftlint >/dev/null; then
    swiftlint lint --config "${SRCROOT}/.swiftlint.yml"
else
    echo "SwiftLint not installed. Install with: brew install swiftlint"
fi
```

### Method 2: External Build Tool

1. In Xcode, go to **Product → Scheme → Edit Scheme**
2. Select **Build → Pre-actions**
3. Add "New Run Script Action"
4. Use the same script as above

## 📊 Code Quality Metrics

### Current Status
- **Swift files**: ~15-20 files
- **Average file length**: ~200-300 lines
- **Main areas**: ContentView, ChatViewModel, CodeSandbox services

### Common Issues to Fix
1. **Long functions**: Break down functions over 80 lines
2. **Print statements**: Replace with proper logging
3. **Force unwrapping**: Use safe unwrapping patterns
4. **Line length**: Keep lines under 120 characters

## 🛠️ Auto-fixing

Many issues can be auto-fixed:

```bash
# Fix formatting issues
swiftlint --fix

# Fix and format in one go
swiftlint --fix --format
```

### Auto-fixable Issues
- Trailing whitespace
- Missing final newlines
- Spacing around operators
- Comma spacing
- Colon spacing

## 📈 Best Practices

### 1. **Before Committing**
```bash
# Quick lint check
swiftlint lint --quiet

# Fix auto-fixable issues
swiftlint --fix
```

### 2. **Function Length**
Break down functions over 80 lines:
```swift
// ❌ Too long
func handleUserInteraction() {
    // 100+ lines of code
}

// ✅ Better
func handleUserInteraction() {
    validateInput()
    processRequest()
    updateUI()
}

private func validateInput() { /* ... */ }
private func processRequest() { /* ... */ }
private func updateUI() { /* ... */ }
```

### 3. **Logging Instead of Print**
```swift
// ❌ Avoid
print("Debug info: \(value)")

// ✅ Better
import os.log
private let logger = Logger(subsystem: "XRAiAssistant", category: "ContentView")
logger.debug("Debug info: \(value)")
```

### 4. **Safe Unwrapping**
```swift
// ❌ Force unwrapping
let result = someOptional!

// ✅ Safe unwrapping
guard let result = someOptional else { return }
// or
if let result = someOptional {
    // use result
}
```

## 🎯 XRAiAssistant-Specific Guidelines

### 1. **3D Framework Naming**
- Use "Three.js" (not "threejs" or "threeJS")
- Use "React Three Fiber" consistently
- Use "Babylon.js" (not "babylonjs")

### 2. **AI Integration Code**
- Keep AI provider methods under 60 lines
- Use clear variable names for model parameters
- Document complex AI workflows

### 3. **WebView Integration**
- Separate JavaScript injection logic
- Use meaningful function names for bridge methods
- Keep WebView coordinators focused

## 🚨 CI/CD Integration

For automated checking in CI:

```yaml
# GitHub Actions example
- name: SwiftLint
  run: |
    brew install swiftlint
    swiftlint lint --reporter github-actions-logging
```

## 📞 Support

- **SwiftLint Docs**: https://github.com/realm/SwiftLint
- **Configuration**: See `.swiftlint.yml` in project root
- **Issues**: Check GitHub Issues for SwiftLint-related problems

---

**Maintaining clean, consistent code helps the entire XRAiAssistant development team! 🚀**