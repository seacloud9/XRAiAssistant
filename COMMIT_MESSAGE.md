# Disable Reactylon, improve React Three Fiber UX, and add Babylon.js Color3 cleaning

## Summary

This commit disables Reactylon framework support due to unfixable CodeSandbox compatibility issues, improves the React Three Fiber user experience by preventing automatic scene switching after AI responses, and adds automatic Color3 constructor conversion for Babylon.js to ensure code compatibility.

## Changes

### Reactylon Removal

**Removed:**
- ❌ Reactylon from framework dropdown (Library3D.swift)
- ❌ ReactylonLibrary.swift implementation file
- ❌ Reactylon code generation functions in CodeSandboxAPIClient.swift
- ❌ Reactylon-specific playground HTML and vendor files
- ❌ All Reactylon references from ContentView.swift

**Updated:**
- ✅ CLAUDE.md - Added prominent warning about Reactylon removal
- ✅ COPILOT.md - Synchronized with CLAUDE.md warning
- ✅ Documentation now clearly states only 4 supported frameworks

### React Three Fiber UX Improvements

**Enhanced User Control:**
- ✅ Disabled automatic tab switch to Scene after AI response (ContentView.swift line 1632)
- ✅ Users now stay on Chat tab to read AI explanation and code
- ✅ Users manually click "Run Scene" button when ready to view CodeSandbox
- ✅ Improved Run Scene button logic to handle R3F CodeSandbox creation (lines 1054-1068)

**User Workflow:**
1. User sends AI prompt → AI generates R3F code
2. AI finishes streaming → User stays on Chat tab to read response ✅
3. User reviews code and explanation
4. User clicks "Run Scene" → Tab switches and CodeSandbox creates
5. Scene renders in WKWebView

### Babylon.js Color3 Constructor Preference

**Problem:**
AI-generated Babylon.js code sometimes used static Color3 properties like `Color3.Orange()` or `Color3.Red` which may not exist or behave inconsistently across Babylon.js versions.

**Solution:**
- ✅ Updated BabylonJSLibrary.swift system prompt with critical Color3 rules
- ✅ Added comprehensive Color3 RGB value examples for common colors
- ✅ Implemented `cleanBabylonJSCode()` function in playground-babylonjs.html
- ✅ Automatic runtime conversion of all Color3 static properties to constructors

**How It Works:**
```javascript
// Before (may fail):
material.diffuseColor = BABYLON.Color3.Orange();
light.diffuse = Color3.Red;

// After (guaranteed to work):
material.diffuseColor = new BABYLON.Color3(1, 0.5, 0);
light.diffuse = new Color3(1, 0, 0);
```

**Implementation Details:**
- System prompt now instructs AI to always use `new BABYLON.Color3(r, g, b)` syntax
- Runtime cleaning function handles both `Color3.Red()` and `Color3.Red` formats
- Supports both `BABYLON.Color3` and bare `Color3` references
- Converts 12 common colors: Red, Green, Blue, Yellow, Orange, Purple, Magenta, Cyan, White, Black, Gray, Teal
- Two-pass replacement: function calls first, then property access (avoids double-replacement)

## Supported Frameworks

**Active and Working:**
1. React Three Fiber (R3F) - Primary CodeSandbox framework ✅
2. Babylon.js - Native WebGL
3. Three.js - Native WebGL
4. A-Frame - VR-focused

**Disabled (Not Ready):**
- ❌ Reactylon - Blocked by react-reconciler compatibility with CodeSandbox

## Technical Details

### Issue
The error `(0, B.default) is not a function` where `B.default` is undefined indicates that Reactylon's compiled code expects a default export from react-reconciler that doesn't exist in CodeSandbox's bundling environment.

### Root Cause
- Reactylon requires local build tools (Vite/Webpack with Babel plugin)
- CodeSandbox's browser-based bundler cannot properly resolve react-reconciler for Reactylon's internal dependencies
- No official Reactylon examples exist for CodeSandbox (red flag)
- WKWebView environment adds additional compatibility constraints

### Why Not Fixable
Package.json changes (dependencies, resolutions, overrides) cannot fix this because:
1. Reactylon 2.0.0 was pre-compiled with assumptions about react-reconciler exports
2. CodeSandbox's bundler has different module resolution than local npm
3. The bundler creates a mismatch between what Reactylon expects and what it receives

## Future Work

Reactylon support can be re-enabled when:
- [ ] Reactylon releases a CodeSandbox-compatible version
- [ ] Alternative local rendering approach is implemented
- [ ] WKWebView compatibility issues are resolved

## Migration Path

Users should use **React Three Fiber** for React-based 3D scenes in CodeSandbox. R3F provides similar declarative API and works perfectly in the browser-based environment.

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
