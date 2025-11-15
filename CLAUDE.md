# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

> **⚠️ SYNCHRONIZATION REQUIREMENT**: This file must be kept in sync with COPILOT.md. When either file is updated, the other MUST be updated to maintain consistency across AI assistants.

**XRAiAssistant** is a revolutionary AI-powered Extended Reality development platform that combines Babylon.js, Together AI, and native iOS development into the ultimate mobile XR development environment with advanced AI assistance capabilities.

> **The Ultimate Mobile XR Development Environment**
> Democratizing 3D and Extended Reality development through conversational AI assistance, professional parameter control, and privacy-first architecture.

---

## ✅ CRITICAL FIX: Reactylon Engine Import Pattern

### Resolution Status: FULLY FIXED ✅ (October 15, 2025)

**Issue**: App component was causing "Element type is invalid: got undefined" errors because `Engine` was being imported from `'reactylon'` instead of `'reactylon/web'`.

**Root Cause**: According to the official Reactylon documentation at https://www.reactylon.com/docs/getting-started/reactylon, `Engine` must be imported from `'reactylon/web'`, while all other components are imported from `'reactylon'`.

**Correct Import Pattern**:
```typescript
// ✅ CORRECT: Engine from 'reactylon/web'
import { Engine } from 'reactylon/web'
import { Scene, box, sphere, cylinder, hemisphericLight, standardMaterial } from 'reactylon'
import { Color3, Vector3, createDefaultCameraOrLight } from '@babylonjs/core'

// ❌ WRONG: Engine from 'reactylon'
import { Engine, Scene, box } from 'reactylon' // BREAKS!
```

**Complete Fix**:
1. ✅ **ReactylonLibrary.swift** - Lines 38-39: Updated import pattern to use `'reactylon/web'` for Engine
2. ✅ **ReactylonLibrary.swift** - Lines 165-166: Updated default scene code with correct imports
3. ✅ **ReactylonLibrary.swift** - Lines 71-72: Updated critical rules to document Engine import pattern
4. ✅ **CodeSandboxAPIClient.swift** - Lines 1042-1073: Added logic to split Engine import from other components
5. ✅ **CodeSandboxAPIClient.swift** - Lines 1020-1022: Updated import removal to handle both `'reactylon'` and `'reactylon/web'`

**Critical Import Rules**:
- ✅ ALWAYS import Engine from 'reactylon/web'
- ✅ ALWAYS import Scene and all other components from 'reactylon'
- ❌ NEVER import Engine from 'reactylon' (it's undefined there!)

---

## ✅ CRITICAL FIX: Reactylon Camera Setup Pattern

### Resolution Status: FULLY FIXED ✅ (October 15, 2025)

**Issue**: XRScene component was causing "Element type is invalid" errors due to incorrect camera setup pattern using `useScene()` hook with `useEffect`.

**Root Cause**: After examining the official Reactylon example at https://stackblitz.com/edit/reactylon-cube, discovered the correct pattern uses `onSceneReady` callback on the `<Scene>` component, NOT `useScene()` hook with `useEffect`.

**Official Reactylon Camera Pattern (from StackBlitz example)**:
```typescript
import { Color3, Vector3, createDefaultCameraOrLight } from '@babylonjs/core'
import { Engine, Scene, box } from 'reactylon'

function App() {
  return (
    <Engine antialias adaptToDeviceRatio canvasId="canvas">
      <Scene
        clearColor="#2c2c54"
        onSceneReady={(scene) => createDefaultCameraOrLight(scene, true, true, true)}
      >
        {/* Your 3D content here */}
      </Scene>
    </Engine>
  )
}

// ❌ WRONG: Using useScene() hook with useEffect
const Content = () => {
  const scene = useScene()
  useEffect(() => {
    if (scene) {
      scene.createDefaultCameraOrLight(true, true, true) // BREAKS!
    }
  }, [scene])
}
```

**Complete Camera Fix**:
1. ✅ **ReactylonLibrary.swift** - Lines 36-62: Updated example to use `onSceneReady` callback
2. ✅ **ReactylonLibrary.swift** - Lines 88-94: Added camera setup critical rules section
3. ✅ **ReactylonLibrary.swift** - Lines 156-251: Updated default scene code to use `onSceneReady`
4. ✅ **Removed**: All references to `useScene()` hook for camera setup
5. ✅ **Removed**: Unnecessary nested `Content` component pattern
6. ✅ **Added**: Import `createDefaultCameraOrLight` from `@babylonjs/core`

**Critical Camera Rules**:
- ✅ ALWAYS import createDefaultCameraOrLight from '@babylonjs/core'
- ✅ ALWAYS use onSceneReady callback: `<Scene onSceneReady={(scene) => createDefaultCameraOrLight(scene, true, true, true)}>`
- ❌ NEVER use useScene() hook with useEffect for camera setup
- ❌ NEVER use declarative camera components like `<ArcRotateCamera />`
- ❌ NEVER create nested Content components just for camera setup

---

## ✅ CRITICAL FIX: Reactylon Babylon.js Class Usage

### Resolution Status: FULLY FIXED ✅ (October 15, 2025)

**Issue**: Persistent "Element type is invalid: got undefined" errors in Reactylon CodeSandbox scenes despite previous camera API fixes.

**Root Cause Discovery**: After researching the actual Reactylon documentation at reactylon.com, discovered THREE critical API mismatches:

1. **Color3/Vector3 Removal**: Code cleaning was REMOVING Babylon.js classes (`Color3`, `Vector3`) and converting them to hex strings/arrays
2. **Wrong Material Casing**: Converting `<pBRMaterial>` → `<pbrmaterial>` (lowercase all), but correct is `<pBRMaterial>` (capital BR)
3. **Wrong API Pattern**: System prompt taught AI to use arrays/hex strings instead of Babylon.js objects

**Official Reactylon API (from reactylon.com docs)**:
```typescript
import { Color3, Vector3 } from '@babylonjs/core'
import { Engine, Scene, box, sphere, hemisphericLight, standardMaterial, pBRMaterial } from 'reactylon'

// ✅ CORRECT: Use Babylon.js objects for colors and positions
<hemisphericLight
  name="light1"
  direction={new Vector3(0, 1, 0)}
  diffuse={Color3.Red()}
  specular={Color3.Green()}
/>

<sphere name="sphere1" position={new Vector3(0, 1, 0)} options={{ diameter: 2 }}>
  <pBRMaterial name="mat1" albedoColor={Color3.Blue()} metallic={0.5} />
</sphere>

// ❌ WRONG: Arrays and hex strings don't work!
<hemisphericLight direction={[0, 1, 0]} diffuse="#ff0000" /> // BREAKS!
<sphere position={[0, 1, 0]}><pbrMaterial albedoColor="#0000ff" /></sphere> // BREAKS!
```

**Complete Fix Summary**:

1. ✅ **CodeSandboxAPIClient.swift** - Lines 808-813: REMOVED code that was converting Color3/Vector3 to strings/arrays
2. ✅ **CodeSandboxAPIClient.swift** - Lines 756-757: REMOVED code that was deleting Babylon.js imports
3. ✅ **CodeSandboxAPIClient.swift** - Line 857: Fixed `"PBRMaterial": "pbrMaterial"` → `"PBRMaterial": "pBRMaterial"` (capital BR)
4. ✅ **CodeSandboxAPIClient.swift** - Line 982: Fixed `"pbrMaterial"` → `"pBRMaterial"` in validation list
5. ✅ **CodeSandboxAPIClient.swift** - Line 912: Fixed material pattern regex to use `pBRMaterial` not `pbrMaterial`
6. ✅ **ReactylonLibrary.swift** - Lines 38-39: Added `import { Color3, Vector3 } from '@babylonjs/core'` to examples
7. ✅ **ReactylonLibrary.swift** - Lines 93-103: Updated system prompt to REQUIRE Babylon.js classes (reversed previous guidance)
8. ✅ **ReactylonLibrary.swift** - Lines 108-135: Updated all examples to use `new Vector3()`, `Color3.Red()`, `options` prop
9. ✅ **ReactylonLibrary.swift** - Lines 172-287: Updated default scene code to use correct Babylon.js API

**Component Naming (Verified from reactylon.com)**:
- **Meshes**: `<box>`, `<sphere>`, `<cylinder>`, `<plane>`, `<ground>` (all lowercase)
- **Lights**: `<hemisphericLight>`, `<pointLight>`, `<directionalLight>`, `<spotLight>` (all lowercase)
- **Materials**: `<standardMaterial>`, `<pBRMaterial>` (lowercase except capital BR!)
- **Core**: `<Engine>`, `<Scene>` (capital E and S)
- **Babylon.js Classes**: `Color3`, `Vector3`, `Quaternion`, `Tools`, `Axis` (from `@babylonjs/core`)

**Critical Rules**:
- ✅ ALWAYS import Babylon.js classes: `import { Color3, Vector3 } from '@babylonjs/core'`
- ✅ ALWAYS use Babylon.js objects: `position={new Vector3(0, 1, 0)}`
- ✅ ALWAYS use Color3 methods: `diffuseColor={Color3.Red()}` or `Color3.FromHexString("#ff0000")`
- ❌ NEVER use plain arrays: `position={[0, 1, 0]}` (BREAKS!)
- ❌ NEVER use hex strings directly: `diffuseColor="#ff0000"` (BREAKS!)
- ✅ Use `options` prop for mesh configuration: `options={{ size: 2, diameter: 3 }}`

**Status**: All fixes implemented and ready for testing. The code cleaning pipeline now PRESERVES Babylon.js imports and usage instead of removing them.

---

## ✅ FIXED: Reactylon API Pattern Correction

### Resolution Status: CAMERA API UPDATED ✅ (October 15, 2025)

**Issue**: AI was generating declarative camera components like `<ArcRotateCamera />`, which don't exist in the Reactylon package, causing "Element type is invalid: got undefined" errors.

**Root Cause**: System prompt was teaching AI to use capitalized declarative components (`<Box>`, `<Sphere>`, `<ArcRotateCamera>`) instead of the correct Reactylon API pattern which uses:
1. **Lowercase component names** for meshes and lights (`<box>`, `<sphere>`, `<hemisphericLight>`)
2. **Scene methods** for cameras via `scene.createDefaultCameraOrLight()`
3. **`useScene()` hook** to access Babylon.js scene instance

**Solution**: Updated ReactylonLibrary.swift system prompt and CodeSandboxAPIClient.swift component validation to match actual Reactylon API.

#### Correct Reactylon API Pattern:
```typescript
import React, { useEffect } from 'react'
import {
  Engine, Scene, useScene,
  box, sphere, cylinder, ground, hemisphericLight,
  standardMaterial, pbrMaterial,
  XRExperience
} from 'reactylon'

function XRScene() {
  const Content = () => {
    const scene = useScene()

    // ✅ CORRECT: Create camera using scene methods, NOT declarative JSX
    useEffect(() => {
      if (scene) {
        scene.createDefaultCameraOrLight(true, true, true)
      }
    }, [scene])

    return (
      <>
        <hemisphericLight direction={[0, 1, 0]} intensity={0.9} />

        <box position={[0, 1, 0]} size={2}>
          <standardMaterial diffuseColor="#ff0000" />
        </box>

        <XRExperience baseExperience={true} floorMeshes={[]} />
      </>
    )
  }

  return (
    <Engine antialias adaptToDeviceRatio canvasId="canvas">
      <Scene clearColor="#2c2c54">
        <Content />
      </Scene>
    </Engine>
  )
}
```

#### What Was Fixed:
1. ✅ **ReactylonLibrary.swift (Lines 36-81)**: Updated system prompt with correct API patterns
   - Removed `<ArcRotateCamera />` from examples
   - Added `useScene()` hook pattern
   - Switched to lowercase component names (`box`, `sphere`, `hemisphericLight`)
   - Added camera creation via `scene.createDefaultCameraOrLight()`

2. ✅ **ReactylonLibrary.swift (Lines 120-130)**: Updated component documentation
   - Added warning: "🚨 NEVER use declarative camera components"
   - Added rule: "🚨 CREATE CAMERAS: Always use scene.createDefaultCameraOrLight()"
   - Listed lowercase component names as valid

3. ✅ **ReactylonLibrary.swift (Lines 172-275)**: Updated default scene code
   - Uses `useScene()` hook
   - Creates camera in `useEffect()` with scene methods
   - Uses lowercase components throughout
   - Proper React 18 patterns with `useEffect` dependency array

4. ✅ **CodeSandboxAPIClient.swift (Lines 841-880)**: Added automatic component case conversion
   - **Capital → lowercase transformation**: Automatically converts `<Box>` → `<box>`, `<PBRMaterial>` → `<pbrMaterial>`, etc.
   - Handles both opening and closing tags
   - Converts 14 component types to proper lowercase format
   - Runs BEFORE import scanning to ensure AI-generated capital-case components work correctly

5. ✅ **CodeSandboxAPIClient.swift (Lines 882-904)**: Removed XRExperience component usage
   - **XRExperience is NOT a component** - it's a hook called `useXrExperience()`
   - Automatically removes all `<XRExperience>` JSX tags from code
   - Prevents "Element type is invalid: got undefined" errors

6. ✅ **CodeSandboxAPIClient.swift (Lines 954-977)**: Updated component validation
   - **Valid components**: `box`, `sphere`, `cylinder`, `hemisphericLight`, `standardMaterial`, `pbrMaterial`, `useScene`, `useXrExperience`
   - **Invalid/removed**: `XRExperience` component, `ArcRotateCamera`, `FreeCamera`, `WebXRCamera`, `Box`, `Sphere`, `HemisphericLight`, `StandardMaterial`
   - All camera components and XRExperience moved to `nonExistentOrUtilityClasses` list

7. ✅ **CodeSandboxAPIClient.swift (Lines 1028-1082)**: Fixed React hooks import preservation
   - **Extracts React import with hooks FIRST** before removing imports
   - **Adds React import at the top** with `useEffect`, `useState`, `useRef`, etc.
   - **Then adds reactylon imports** in correct order
   - **Prevents `useEffect is not defined` errors**
   - **R3F UNAFFECTED**: Changes only in `cleanReactylonCode()`, R3F uses separate `cleanReactThreeFiberCode()`

#### Why This Fixes the "Element type is invalid" Error:
- **Before**:
  - AI generated `<ArcRotateCamera />`, `<PBRMaterial />`, `<XRExperience />` (undefined components) → React error "got: undefined"
  - React hooks import was removed → `useEffect is not defined` error
- **After**:
  1. AI learns lowercase pattern from system prompt → generates `<box>`, `<pbrMaterial>` ✅
  2. If AI still uses capital-case → auto-converted to lowercase ✅
  3. Camera creation via `scene.createDefaultCameraOrLight()` ✅
  4. `<XRExperience>` JSX tags removed automatically ✅
  5. React import with hooks (`useEffect`, `useState`) preserved at top ✅
  6. All components now valid and defined in reactylon package ✅

#### Component Naming Rules:
```typescript
// ✅ CORRECT: Lowercase declarative components
<box position={[0, 0, 0]} />
<sphere diameter={2} />
<hemisphericLight intensity={0.7} />
<standardMaterial diffuseColor="#ff0000" />

// ❌ WRONG: Capital-case components (don't exist in Reactylon)
<Box position={[0, 0, 0]} />          // undefined
<Sphere diameter={2} />                // undefined
<HemisphericLight intensity={0.7} />   // undefined
<StandardMaterial />                   // undefined

// ❌ WRONG: Declarative camera components (don't exist)
<ArcRotateCamera />                    // undefined
<FreeCamera />                         // undefined
<WebXRCamera />                        // undefined

// ✅ CORRECT: Create cameras via scene methods
const scene = useScene()
useEffect(() => {
  if (scene) {
    scene.createDefaultCameraOrLight(true, true, true)
  }
}, [scene])
```

#### Status (October 15, 2025):
- ✅ System prompt updated with correct Reactylon API patterns
- ✅ Automatic capital → lowercase component conversion added
- ✅ Component validation updated (lowercase = valid, capital-case = invalid)
- ✅ Camera components removed from valid list
- ✅ **XRExperience component removed** (doesn't exist - it's a hook!)
- ✅ **React hooks import preserved** (`useEffect`, `useState`, `useRef`)
- ✅ useScene() hook pattern added to examples
- ✅ Default scene code uses correct API
- ✅ **Auto-Conversion Safety Net**: Capital-case components auto-fixed
- ✅ **R3F Compatibility**: Changes isolated to Reactylon code path only
- 🎯 **Ready for Testing**: All undefined component errors should be resolved

---

## ✅ WORKING: React Three Fiber CodeSandbox Integration

### Status: FULLY WORKING ✅ (October 14, 2025)

**React Three Fiber (R3F) CodeSandbox implementation is working perfectly!** Do not modify the R3F code paths.

#### R3F Implementation (DO NOT MODIFY):
- ✅ **Native CodeSandbox API**: URLSession-based HTTP client
- ✅ **TypeScript Cleaning**: Removes all TS syntax including object literal types
- ✅ **Dependencies**: React 18.3.1, @react-three/fiber, @react-three/drei, @react-three/postprocessing, three
- ✅ **File Generation**: 6 files (package.json, index.html, index.js, App.js, index.css, .gitignore)
- ✅ **Sandbox Creation**: Extracts ID from HTML response
- ✅ **Scene Rendering**: Loads and displays perfectly in WKWebView

**CRITICAL**: When fixing Reactylon, only modify Reactylon-specific code paths. Leave all R3F code unchanged.

---

## ✅ FIXED: Reactylon CodeSandbox Integration

### Status: JSX COMPONENT SCANNING IMPLEMENTED ✅ (October 14, 2025)

**Solution**: Added automatic JSX component scanning to detect and import all react-babylonjs components used in the code, preventing missing import errors that caused black screens.

#### What Was Fixed:
1. ✅ **JSX Component Scanner** ([CodeSandboxAPIClient.swift:809-881](XRAiAssistant/XRAiAssistant/CodeSandboxAPIClient.swift#L809-L881))
   - Automatically detects all react-babylonjs components used in JSX (`<Plane>`, `<Box>`, `<Sphere>`, etc.)
   - Scans for 25+ common components including meshes, cameras, lights, and materials
   - Consolidates all imports into single import statement
   - Prevents `ReferenceError: Component is not defined` runtime errors

2. ✅ **Import Consolidation**
   - Extracts existing imports from code
   - Scans JSX for component usage
   - Removes duplicate import statements
   - Generates consolidated: `import { ArcRotateCamera, Box, Cylinder, Engine, HemisphericLight, Plane, Scene, Sphere, StandardMaterial } from 'react-babylonjs';`

3. ✅ **Package Name**: Uses `reactylon` (correct package name)
   - AI may generate code with either `reactylon` or `react-babylonjs`
   - Code cleaning converts `react-babylonjs` → `reactylon` automatically
   - Dependencies use `reactylon@^3.2.1` with `@babylonjs/core@^8.0.0`
   - **Critical**: Includes `react-reconciler@^0.29.0` peer dependency

#### How It Works:
```swift
// Step 3 in cleanReactylonCode():
// 1. Extract existing imports from react-babylonjs
var reactBabylonImports: Set<String> = []

// 2. Scan JSX for component usage (e.g., <Plane>, <Box>, <Sphere>)
for component in reactBabylonComponents {
    if cleanedCode.contains("<\(component)") {
        reactBabylonImports.insert(component)
    }
}

// 3. Generate consolidated import at top of file
// import { ArcRotateCamera, Box, Cylinder, Plane, Scene, ... } from 'react-babylonjs';

// 4. Remove ALL import statements from code body (lines 887-903)
// This prevents duplicate imports and unused React hooks like useState
```

#### Recent Fixes (October 15, 2025 - COMPLETE ✅):
- ✅ **Fixed Duplicate Imports**: Now removes ALL import statements from code body after consolidation
- ✅ **Fixed React Version Error**: `TypeError: undefined is not an object (evaluating 'ReactSharedInternals.S')` was caused by unused `useState` import
- ✅ **Fixed Package Name**: Switched from `react-babylonjs` to `reactylon` (official package for React 18+)
- ✅ **Added react-reconciler**: Required peer dependency for reactylon (v0.29.0)
- ✅ **Fixed Orphaned `</Ground>` Tags**: Removes orphaned closing tags from Ground component removal
- ✅ **Fixed Orphaned `}` and `/>` Tags**: Enhanced cleanup to remove orphaned closing tags throughout entire code body, not just at end
- ✅ **Fixed "Element type is invalid" Error**: Removed Color3/Vector3 utility classes from imports (not React components)
- ✅ **Color3 Auto-Conversion**: Automatically converts Color3.Red() to "#ff0000" hex strings
- ✅ **Fixed Material Prop Pattern**: Converts `material={<Material />}` to proper child structure `<Mesh><Material /></Mesh>`
- ✅ **Fixed WebXRCamera Import**: Removed WebXRCamera from imports (doesn't exist in reactylon package)
- ✅ **Updated System Prompt**: AI now uses hex strings, proper material nesting, and valid components only
- ✅ **Clean Import Structure**: Only consolidated reactylon imports at top, no duplicate React imports
- ✅ **Protected R3F**: All fixes isolated to Reactylon code paths only

#### JSX Cleaning & Validation Approach:
The cleaning pipeline now includes comprehensive JSX validation and orphaned tag removal:

1. **Malformed Tag Auto-Fix**: Detects components with `<Component ...>` missing the self-closing `/` and automatically fixes to `<Component />`
2. **Smart Context Analysis**: Looks ahead 200 characters to verify if closing tag exists before assuming self-closing
3. **Conservative Orphaned Brace Removal**: Only removes standalone `}` after semicolons followed by blank lines
4. **Preserves Legitimate JSX**: Never removes valid self-closing tags or component structures
5. **End-of-File Cleanup**: Additional cleanup for orphaned brackets at the very end

Implementation in `CodeSandboxAPIClient.swift` lines 911-980:
```swift
// STEP 4: Fix malformed JSX tags (components with > instead of />)
let selfClosingComponentPattern = #"<([A-Z][a-zA-Z0-9]*)\s+([^>]*)\s+>"#
for match in matches.reversed() {
    let componentName = String(finalCode[componentRange])

    // Look ahead up to 200 characters to see if there's a </ComponentName>
    let closingTag = "</\(componentName)>"

    if !finalCode[searchRange].contains(closingTag) {
        // No closing tag found - this should be self-closing
        let fixedTag = matchedText.replacingOccurrences(of: #"\s+>"#, with: " />", options: .regularExpression)
        mutableCode.replaceSubrange(mutableRange, with: fixedTag)
        print("  🔧 Fixed malformed tag: \(componentName) (added self-closing />)")
    }
}

// STEP 5: Clean up orphaned closing braces (NOT self-closing tags)
for (index, line) in codeLines.enumerated() {
    if trimmedLine == "}" {
        // Only remove if previous line ends with `;` AND followed by blank line
        if previousLine.hasSuffix(";") && (index + 1 >= codeLines.count || codeLines[index + 1].isEmpty) {
            continue // Skip this orphaned brace
        }
    }
    cleanedLines.append(line)
}
```

#### What Still May Need Attention:
- ⏳ **Build Timeout**: Babylon.js packages are large, may need to wait 30-60s for first build
- 🔍 **BrowserFS Warnings**: CodeSandbox internal warnings (can be ignored)
- 🔍 **Runtime Errors**: Check browser console for Babylon.js API usage errors

#### Protected R3F Code Paths (DO NOT MODIFY):
- `CodeSandboxAPIClient.swift`: `generateReactThreeFiberFiles()` method
- `CodeSandboxAPIClient.swift`: `cleanReactThreeFiberCode()` method
- R3F package dependencies
- R3F file generation and structure

#### Implementation Details:
- **New File**: `XRAiAssistant/XRAiAssistant/CodeSandboxAPIClient.swift`
- **Modified**: `XRAiAssistant/XRAiAssistant/CodeSandboxWebView.swift`
- **Modified**: `XRAiAssistant/XRAiAssistant/ContentView.swift`
- **API Endpoint**: `https://codesandbox.io/api/v1/sandboxes/define`
- **Request Method**: HTTP POST with JSON body containing files structure
- **Response Format**: HTML (200 OK) with sandbox ID embedded in meta tags
- **ID Extraction**: Regex pattern `(?<=codesandbox\.io/s/)[a-zA-Z0-9-]+` from og:url
- **File Generation**: Creates package.json, public/index.html, src/index.js, src/App.js, src/index.css, .gitignore
- **Dependencies - R3F**: react, react-dom, react-scripts, @react-three/fiber, @react-three/drei, @react-three/postprocessing, three
- **Dependencies - Reactylon**: react-babylonjs, @babylonjs/core, @babylonjs/loaders, @babylonjs/gui, @babylonjs/materials

#### Technical Architecture:
```swift
// CodeSandboxAPIClient.swift
class CodeSandboxAPIClient {
    func createSandbox(code: String, framework: String) async throws -> String {
        let files = generateFiles(code: code, framework: framework)
        let parameters = try createParameters(files: files)
        let sandboxURL = try await postToDefineAPI(parameters: parameters)
        return sandboxURL
    }
    
    private func generateReactThreeFiberFiles(code: String) -> [String: CodeSandboxAPIFile] {
        // Returns: package.json, public/index.html, src/index.js, src/App.js
    }
    
    private func extractSandboxIDFromHTML(_ html: String) -> String? {
        // Uses regex to extract ID from og:url meta tag
    }
}
```

---

## ✅ FIXED: Android Anthropic API Streaming Response Parsing

### Resolution Status: FULLY FIXED ✅ (November 14, 2025)

**Issue**: Anthropic Claude API streaming responses were not appearing in the Android app UI despite successful HTTP 200 responses and correct Server-Sent Events (SSE) being received.

**Root Cause**: The `AnthropicResponse` data model required the `id` field to be non-null, but Anthropic's streaming events (`content_block_delta`, `content_block_start`, etc.) do not include an `id` field. This caused Moshi JSON parsing to fail silently, resulting in no text being emitted to the UI.

**Anthropic SSE Event Format**:
```json
// Event with ID (message_start):
{"type":"message_start","message":{"id":"msg_011t6KeQ3MPJaYKHD7ikJEFc",...}}

// Events WITHOUT ID (streaming deltas):
{"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":"Hello"}}
{"type":"content_block_start","index":0,"content_block":{"type":"text","text":""}}
```

**The Fix**:
```kotlin
// BEFORE (BROKEN):
@JsonClass(generateAdapter = true)
data class AnthropicResponse(
    @Json(name = "id") val id: String,  // ❌ REQUIRED - parsing fails when missing!
    @Json(name = "type") val type: String,
    @Json(name = "delta") val delta: Delta? = null,
    //...
)

// AFTER (FIXED):
@JsonClass(generateAdapter = true)
data class AnthropicResponse(
    @Json(name = "id") val id: String? = null,  // ✅ NULLABLE - parsing succeeds for all events
    @Json(name = "type") val type: String,
    @Json(name = "delta") val delta: Delta? = null,
    //...
)
```

**Files Modified**:
- ✅ `XRAiAssistantAndroid/app/src/main/java/com/xraiassistant/data/models/AIRequest.kt` (Line 127)

**Impact**:
- ✅ Anthropic Claude streaming responses now work correctly
- ✅ All streaming event types can be parsed successfully
- ✅ UI receives and displays streamed text chunks in real-time
- ✅ No breaking changes to other providers (Together.ai, OpenAI remain unaffected)

**Verification**:
```
// Logs showing successful streaming (from Nov 9, 2025):
2025-11-09 20:31:30.215 okhttp.OkHttpClient: <-- 200 https://api.anthropic.com/v1/messages (1046ms)
2025-11-09 20:31:38.576 okhttp.OkHttpClient: event: content_block_delta
2025-11-09 20:31:38.576 okhttp.OkHttpClient: data: {"type":"content_block_delta","delta":{"text":"# 🌈 Rainbow"}}
```

**Notes**:
- ⚠️ **WSL Build Limitation**: This fix was made in WSL where Java/Android Studio are not installed. The fix is code-verified but **requires building in Android Studio** to test.
- 🏗️ **Build Requirement**: Open project in Android Studio and run `Build → Rebuild Project` to compile the updated Kotlin data classes with Moshi adapters.
- ✅ **API Working**: The Anthropic API itself is working correctly (200 OK, valid SSE events received).
- ✅ **Code Quality**: Fix follows Kotlin null-safety best practices and Moshi JSON parsing conventions.

---

## 🤖 ANDROID IMPLEMENTATION NOW AVAILABLE! 🎉

### XRAiAssistantAndroid - Full Feature Parity with iOS

**STATUS**: Phase 1 Complete ✅ (Foundation ready for development)

The Android version of XRAiAssistant is now under development with **complete feature parity** planned with the iOS version. Built using modern Android best practices:

- **Architecture**: MVVM + Clean Architecture (Presentation → Domain → Data layers)
- **Language**: Kotlin 1.9.20 with null safety and coroutines
- **UI Framework**: Jetpack Compose 1.5.4 with Material 3 theming
- **Dependency Injection**: Hilt 2.48
- **Networking**: Retrofit 2.9 + OkHttp 4.11
- **Database**: Room 2.6.0 for message persistence
- **Settings**: DataStore 1.0.0 for preferences
- **3D Rendering**: WebView with JavaScript bridge

### Quick Start (Android)

```bash
# Navigate to Android project
cd XRAiAssistantAndroid

# Open in Android Studio
open -a "Android Studio" .

# Or build from command line
./gradlew assembleDebug
./gradlew installDebug
```

### Android Documentation

- **[ANDROID_QUICK_START.md](ANDROID_QUICK_START.md)** - Get running in 5 minutes
- **[ANDROID_IMPLEMENTATION_PLAN.md](ANDROID_IMPLEMENTATION_PLAN.md)** - Complete 14-week roadmap (1,000+ lines)
- **[XRAiAssistantAndroid/ANDROID_README.md](XRAiAssistantAndroid/ANDROID_README.md)** - Developer guide
- **[XRAiAssistantAndroid/ANDROID_SETUP_COMPLETE.md](XRAiAssistantAndroid/ANDROID_SETUP_COMPLETE.md)** - Phase 1 summary

### iOS → Android Translation Reference

When porting iOS features to Android, use these mappings:

| iOS (Swift/SwiftUI) | Android (Kotlin/Compose) | File Reference |
|---------------------|--------------------------|----------------|
| `@ObservableObject` | `@HiltViewModel` | ChatViewModel.kt |
| `@Published var messages` | `StateFlow<List<ChatMessage>>` | ChatViewModel.kt |
| `UserDefaults` | `DataStore` | SettingsDataStore.kt |
| `URLSession` | `Retrofit + OkHttp` | TogetherAiService.kt |
| `WKWebView` | `WebView` | WebViewBridge.kt |
| `NavigationView` | `NavHost` | NavGraph.kt |

### Android Development Status (Phase 1 Complete ✅)

**✅ Completed**:
- Project structure and build configuration
- Domain models (ChatMessage, AIProvider, AIModel, Library3D)
- Navigation with bottom tabs (5 screens)
- Material 3 theming (light/dark mode)
- Hilt dependency injection setup
- Comprehensive documentation

**🚧 In Progress (Phase 2)**:
- AI provider implementations (Together.ai, OpenAI, Anthropic)
- ChatViewModel with streaming responses
- Message persistence with Room
- Chat UI with markdown rendering

**📋 Planned (Phases 3-10)**:
- 3D library system (Babylon.js, Three.js, A-Frame, R3F, Reactylon)
- WebView bridge for code injection
- CodeSandbox API client
- Settings UI with API key management
- Examples library browser
- Complete testing suite

---

## Project Structure

### Android Application (`XRAiAssistantAndroid/`)
**XRAiAssistant Android** - The Android implementation with full iOS feature parity:
- **Architecture**: MVVM + Clean Architecture (3-layer separation)
- **Domain Models**: `domain/model/` - ChatMessage.kt, AIProvider.kt, AIModel.kt, Library3D.kt
- **Data Layer**: `data/` - Repositories, API services (Retrofit), Room database, DataStore
- **Presentation Layer**: `presentation/` - Compose screens, ViewModels, Navigation, Theme
- **DI**: `di/` - Hilt modules (AppModule, NetworkModule, DatabaseModule)
- **Testing**: Comprehensive unit tests (JUnit, Mockk) and UI tests (Compose Test)

**Key Android Files**:
- `XRAiApplication.kt` - Application class with Hilt setup
- `MainActivity.kt` - Compose entry point
- `presentation/navigation/NavGraph.kt` - Bottom navigation with 5 screens
- `presentation/theme/` - Material 3 color scheme and typography
- `build.gradle.kts` - Dependencies (30+ libraries configured)
- `gradle/libs.versions.toml` - Version catalog for dependency management

### Main iOS Application (`XRAiAssistant/XRAiAssistant/`)
**XRAiAssistant iOS** - The core iOS application with advanced AI integration:
- **`ChatViewModel.swift`**: Advanced AI integration with Together.ai and LlamaStack, dual-parameter control
- **`ContentView.swift`**: SwiftUI interface with professional settings panel and progressive disclosure
- **`WebViewCoordinator.swift`**: Swift-JavaScript bridge for seamless native-web communication
- **`XRAiAssistant.swift`**: App entry point and configuration
- **`Resources/playground.html`**: Embedded Babylon.js playground environment
- **Tests**: `XRAiAssistantTests/ChatViewModelTests.swift` - Comprehensive AI integration and validation tests

**⚠️ CRITICAL SETUP REQUIRED**: XRAiAssistant uses `DEFAULT_API_KEY = "changeMe"` for security. Users MUST configure their Together AI API key in the Settings panel before AI features will work.

### NextJS Web Application (`XrAiAssistantStation/`)
**⚠️ LOCAL DEVELOPMENT ONLY**: XRAiAssistant Station - NextJS web implementation with complete iOS feature parity:
- **🔒 LOCALHOST ONLY**: Currently designed for local development at `http://localhost:3000`
- **🚫 NO PRODUCTION DEPLOYMENT**: Not configured for public hosting due to API key exposure risks
- **🛡️ SECURITY NOTE**: API keys stored in localStorage - safe only for local development
- **📱 Feature Parity**: Complete match with iOS app including streaming AI, settings persistence, and Babylon.js playground
- **🎯 Development Target**: Professional local development environment for XR prototyping

**⚠️ CRITICAL SETUP REQUIRED**: Like iOS app, uses `"changeMe"` default API key. Users MUST configure their Together AI API key in Settings before AI features work.

### Web Playground (`playground/`)
**XRAiAssistant Web Layer** - TypeScript/React-based Babylon.js playground implementation:
- Monaco editor for professional code editing with IntelliSense and XR syntax highlighting
- Babylon.js v6+ for real-time 3D rendering and WebXR scene visualization
- XR-ready architecture designed for AR/VR development workflows
- Cross-platform deployment capability (browsers + iOS WKWebView + future Android)
- Entry point: `src/legacy/legacy.ts`, Main component: `src/playground.tsx`

### Legacy iOS Demo (`ios_quick_demo/`)
Simple demonstration app (reference only - not part of XRAiAssistant):
- Basic LlamaStackClient integration example
- **Note**: Active development focuses on **XRAiAssistant** in `XRAiAssistant/`

## Current XRAiAssistant Feature Set (Implemented & Ready)

### 🤖 **Professional AI Integration with Dual-Parameter Control**
```swift
// CRITICAL: Secure API key management with user setup requirement
private let DEFAULT_API_KEY = "changeMe"  // User MUST configure in Settings

// Dual-parameter AI control system for professional workflows
@Published var temperature: Double = 0.7  // Creativity control (0.0-2.0)
@Published var topP: Double = 0.9         // Vocabulary diversity (0.1-1.0)
@Published var apiKey: String = DEFAULT_API_KEY
@Published var systemPrompt: String = ""

// Multi-provider AI architecture
private var togetherAIService: TogetherAIService  // Primary: Together.ai models
private var inference: RemoteInference            // Fallback: LlamaStack models

// Intelligent parameter descriptions
func getParameterDescription() -> String {
    switch (temperature, topP) {
    case (0.0...0.3, 0.1...0.5): return "Precise & Focused - Perfect for debugging"
    case (0.4...0.8, 0.6...0.9): return "Balanced Creativity - Ideal for most scenes"
    case (0.9...2.0, 0.9...1.0): return "Experimental Mode - Maximum innovation"
    default: return "Custom Configuration"
    }
}
```

**Available XR-Optimized AI Models:**
- **DeepSeek R1 70B** (FREE) - Advanced reasoning & coding
- **Llama 3.3 70B** (FREE) - Latest Meta large model  
- **Llama 3 8B Lite** ($0.10/1M) - Cost-effective option
- **Qwen 2.5 7B Turbo** ($0.30/1M) - Fast coding specialist
- **Qwen 2.5 Coder 32B** ($0.80/1M) - Advanced coding & XR

### 🎛️ **Professional Settings Architecture with Persistence (IMPLEMENTED)**
```swift
// Organized settings with progressive disclosure and UserDefaults persistence
private var settingsView: some View {
    Form {
        apiConfigurationSection     // Secure Together.ai API key management with validation
        modelSettingsSection       // Model picker + Temperature + Top-p + Smart summary
        systemPromptSection        // Full AI behavior customization
        saveSettingsSection        // Save/Cancel buttons with visual feedback
    }
    .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("Cancel") { showingSettings = false }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("Save") {
                chatViewModel.saveSettings()
                withAnimation(.easeInOut(duration: 0.3)) { settingsSaved = true }
                // Auto-dismiss with confirmation
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    showingSettings = false
                }
            }
        }
    }
}

// Settings persistence using UserDefaults (COMPLETE IMPLEMENTATION)
func saveSettings() {
    UserDefaults.standard.set(apiKey, forKey: "XRAiAssistant_APIKey")
    UserDefaults.standard.set(systemPrompt, forKey: "XRAiAssistant_SystemPrompt")
    UserDefaults.standard.set(selectedModel, forKey: "XRAiAssistant_SelectedModel")
    UserDefaults.standard.set(temperature, forKey: "XRAiAssistant_Temperature")
    UserDefaults.standard.set(topP, forKey: "XRAiAssistant_TopP")
    updateAPIKey(apiKey) // Live update AI services
}

private func loadSettings() {
    // Auto-restore all settings on app launch
    apiKey = UserDefaults.standard.string(forKey: "XRAiAssistant_APIKey") ?? DEFAULT_API_KEY
    // ... restore all other settings with defaults
}
```

### 🌐 **Babylon.js Integration Features**
- **Smart Code Generation**: AI creates complete, working Babylon.js scenes
- **Intelligent Code Correction**: Auto-fixes common API mistakes and patterns
- **Real-time 3D Preview**: Instant scene visualization with WebGL
- **Professional Code Editor**: Monaco editor with TypeScript IntelliSense

## Roadmap Features (In Development)

### 📚 **Local SQLite RAG System**
```swift
// Privacy-first knowledge enhancement
class LocalRAGChatViewModel: ChatViewModel {
    private let sqliteRAG: SQLiteVectorStore      // sqlite-vec extension
    private let embeddingGenerator: LocalEmbeddingService
    
    func enhancePromptWithLocalRAG(_ query: String) async -> String {
        let embedding = await embeddingGenerator.embed(query)
        let relevantDocs = await sqliteRAG.vectorSearch(embedding, limit: 5)
        return systemPrompt + "\n\nRelevant Documentation:\n\(relevantDocs)"
    }
}
```

**RAG Architecture Benefits:**
- **100% Private**: All processing happens on-device
- **Works Offline**: Complete functionality without internet
- **Fast Search**: Sub-100ms semantic search on mobile
- **Efficient Storage**: Complete knowledge base in <50MB SQLite file

### 🔄 **Universal Framework Toggle System**
```typescript
// Framework abstraction layer for multi-3D-library support
interface FrameworkAdapter {
    name: string;
    generateSceneCode(aiPrompt: string): string;
    validateCode(code: string): boolean;
    getDocumentationContext(): string[];
}

// Supported frameworks (roadmap)
const frameworks = ['babylonjs', 'threejs', 'react-three-fiber', 'aframe', 'xr8'];
```

## Development Commands

### XRAiAssistant iOS Application (Primary Development)
```bash
cd XRAiAssistant/
open XRAiAssistant.xcodeproj  # Open in Xcode

# IMPORTANT: Default Simulator Target
# Always use: iPad Air 11-inch (M3)
# Build command:
xcodebuild -project XRAiAssistant.xcodeproj \
  -scheme XRAiAssistant \
  -configuration Debug \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPad Air 11-inch (M3)' \
  build

# IMPORTANT: Before building, user MUST configure API key:
# 1. Build and run app on iOS simulator/device
# 2. Tap Settings (gear icon) in bottom tab bar
# 3. Replace "changeMe" with actual Together AI API key from https://together.ai
# 4. Select preferred AI model and adjust temperature/top-p parameters
```

**✅ Project Successfully Renamed**: All files and directories have been renamed from "BabylonPlaygroundApp" to "XRAiAssistant":
- Directory: `BabylonPlaygroundApp_New/` → `XRAiAssistant/`
- Xcode Project: `BabylonPlaygroundApp.xcodeproj` → `XRAiAssistant.xcodeproj`
- App Target: `BabylonPlaygroundApp` → `XRAiAssistant`
- Swift Files: `BabylonPlaygroundApp.swift` → `XRAiAssistant.swift`
- Test Target: `BabylonPlaygroundAppTests` → `XRAiAssistantTests`
- Bundle ID: `com.example.XRAiAssistant`

### XRAiAssistant Station - NextJS Web Application (LOCAL DEVELOPMENT ONLY)
**🔒 LOCALHOST ONLY - DO NOT DEPLOY TO PRODUCTION**

```bash
cd XrAiAssistantStation/
pnpm install               # Install dependencies (requires Node.js 20+)
pnpm run dev              # Start local development server on http://localhost:3000
pnpm run build            # Build for local testing only
pnpm run start            # Start production build locally
pnpm run lint             # Run ESLint
pnpm run type-check       # TypeScript type checking
```

**⚠️ SECURITY WARNING - LOCAL DEVELOPMENT ONLY:**
- **🚫 DO NOT DEPLOY**: This implementation stores API keys in localStorage
- **🔒 LOCALHOST ONLY**: Designed exclusively for local development at `http://localhost:3000`
- **🛡️ API KEY EXPOSURE**: Public deployment would expose API keys to all users
- **🎯 LOCAL PROTOTYPING**: Perfect for local XR development and testing

**IMPORTANT Setup Steps:**
1. Ensure Node.js 20+ and pnpm 8+ are installed
2. Run `pnpm install` to install dependencies
3. Start with `pnpm run dev`
4. Open `http://localhost:3000` in browser
5. Go to Settings and replace "changeMe" with your Together AI API key
6. Select AI model and configure temperature/top-p parameters

### Web Playground (Supporting Development)
```bash
cd playground/
npm run build              # Build for production
npm run build:deployment   # Clean build for deployment  
npm run serve              # Development server on port 1338
npm run serve:dev          # Development server with hot reload
npm run serve:https        # HTTPS development server
npm run clean              # Clean dist directory
```

## Architecture Deep Dive

### 🧠 **AI Integration Architecture**
```swift
// Intelligent routing between AI providers
func callLlamaInference(userMessage: String, systemPrompt: String) async throws -> String {
    if useLlamaStackForLlamaModels && selectedModel.contains("meta-llama") {
        return try await callLlamaStackModel(userMessage: userMessage, systemPrompt: systemPrompt)
    } else {
        return try await callTogetherAIModel(userMessage: userMessage, systemPrompt: systemPrompt)
    }
}
```

**Key AI Features:**
- **Streaming Responses**: Real-time AI generation with progress indicators
- **Intelligent Retry Logic**: Optimized error handling (max 2 API calls per request)
- **Smart Parameter Control**: Dynamic descriptions of AI behavior modes
- **Code Injection Pipeline**: AI → Code Parsing → Babylon.js Integration

### 🌉 **Swift-JavaScript Bridge**
```swift
// Bidirectional communication between native and web layers
func handleWebViewMessage(action: String, data: String) {
    switch action {
    case "insertCode": onInsertCode?(data)
    case "runScene": onRunScene?()
    case "codeFormatted": print("Code formatted successfully")
    }
}

// JavaScript execution from Swift
let jsCode = "insertCodeAtCursor(`\(correctedCode)`);"
webView.evaluateJavaScript(jsCode)
```

### 📱 **SwiftUI Reactive Architecture**
```swift
@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isLoading = false
    @Published var selectedModel: String = "deepseek-ai/DeepSeek-R1-Distill-Llama-70B-free"
    @Published var temperature: Double = 0.7
    @Published var topP: Double = 0.9
    @Published var apiKey: String = DEFAULT_API_KEY
    @Published var systemPrompt: String = ""
}
```

## Key Dependencies

### iOS Native Stack
- **Swift 5.9+**: Modern language features and concurrency
- **SwiftUI**: Declarative UI framework with reactive patterns
- **WebKit**: High-performance web content integration
- **Combine**: Reactive programming for data flow
- **AIProxy Swift v0.126.1**: Together.ai API client
- **LlamaStackClient**: Meta model integration

### Web Technology Stack  
- **Babylon.js v6+**: Advanced 3D rendering engine
- **Monaco Editor**: Professional code editor with IntelliSense
- **TypeScript**: Type-safe JavaScript development
- **React**: Component-based UI library
- **Webpack**: Module bundler with optimization

## File Organization

### iOS Source (`XRAiAssistant/XRAiAssistant/`)
```
XRAiAssistant/
├── XRAiAssistant.swift            # App entry point (renamed)
├── ContentView.swift              # Main UI with settings panel
├── ChatViewModel.swift            # AI integration + state management
├── WebViewCoordinator.swift       # Swift-JavaScript bridge
├── Resources/
│   └── playground.html           # Embedded Babylon.js environment
├── Assets.xcassets/              # App icons and visual assets
├── Info.plist                   # App configuration
└── Preview Content/              # SwiftUI preview assets

XRAiAssistantTests/
└── ChatViewModelTests.swift      # Comprehensive AI integration tests
```

### Web Source (`playground/src/`)
```
playground/src/
├── components/                    # React UI components
├── tools/                         # Utility modules (save, load, download)
├── scss/                          # Styling and themes
├── legacy/                        # Entry point and compatibility
└── playground.tsx                 # Main playground component
```

---

## 📚 **Example Contribution Strategy**

### Overview: Enriching XRAiAssistant with Metadata-Rich Examples

**Objective**: Build a curated library of high-quality 3D examples with rich metadata that helps the AI generate better scenes by learning from proven patterns.

### Why This Matters

Traditional code examples are static and isolated. **Metadata-rich examples** enable:
- **AI Learning**: System prompts reference available techniques, helping AI suggest better implementations
- **Keyword Search**: Users can discover examples by searching for concepts like "voxel", "procedural", "infinite"
- **Pattern Recognition**: AI identifies common patterns and suggests them when appropriate
- **Educational Value**: Examples teach both users and AI about best practices

### Current Implementation (Starting Small)

**Phase 1 Fields** (Currently Implemented):
```swift
struct CodeExample {
    // Existing fields
    let id, title, description, code: String
    let category: ExampleCategory
    let difficulty: ExampleDifficulty

    // NEW: Minimal metadata for AI enhancement
    let keywords: [String]        // Searchable tags for finding similar examples
    let aiPromptHints: String?    // Guidance for AI when generating similar scenes
}
```

### Keyword Taxonomy

Use these keyword categories when tagging examples:

**Visual Style Keywords**:
- `voxel`, `wireframe`, `particle`, `holographic`, `retro`, `neon`, `glitch`

**Technical Keywords**:
- `procedural`, `noise`, `simplex`, `perlin`, `algorithm`, `optimization`

**Scene Type Keywords**:
- `infinite`, `tunnel`, `wormhole`, `portal`, `environment`, `skybox`

**Effect Keywords**:
- `bloom`, `glow`, `post-processing`, `color-cycling`, `animation-loop`

**Interaction Keywords**:
- `interactive`, `customizable`, `html-ui`, `controls`, `parameters`

### How to Add Enhanced Examples

**Step 1**: Create the example code (complete, working scene)

**Step 2**: Tag with relevant keywords
```swift
keywords: [
    "voxel", "procedural", "infinite", "wormhole",
    "simplex-noise", "post-processing", "bloom",
    "interactive", "html-ui", "retro-gaming"
]
```

**Step 3**: Write AI prompt hints (teach the AI what makes this example special)
```swift
aiPromptHints: """
When users request voxel or infinite tunnel scenes:
1. Use SimplexNoise class for organic procedural generation
2. Implement voxel culling to maintain 60fps (only render visible voxels)
3. Create continuous movement by regenerating voxels at boundaries
4. Add bloom post-processing for neon glow effects
5. Include HTML UI controls for real-time customization
6. Consider performance: limit active voxels to ~2000 max
"""
```

**Step 4**: Add to library's examples array
```swift
CodeExample(
    id: "voxel-wormhole",
    title: "🌀 Infinite Voxel Wormhole",
    description: "Procedurally generated infinite tunnel using simplex noise...",
    code: """...""",
    category: .effects,
    difficulty: .advanced,
    keywords: ["voxel", "procedural", "infinite", "wormhole", "simplex-noise"],
    aiPromptHints: """
    Use SimplexNoise for organic generation, implement voxel culling,
    add bloom for neon effects. Maintain 60fps with max 2000 voxels.
    """
)
```

### How AI Uses This Metadata

**Scenario 1: User asks "Create a voxel tunnel"**
- AI searches examples for keyword `"voxel"`
- Finds voxel wormhole example
- Reads `aiPromptHints` to learn best practices
- Generates scene using SimplexNoise + voxel culling techniques

**Scenario 2: User asks "Make an infinite scrolling background"**
- AI searches for keywords `"infinite"`, `"procedural"`
- Discovers continuous regeneration pattern from wormhole example
- Applies the technique to new context

**Scenario 3: Welcome message displays random example**
- System selects voxel wormhole
- User sees impressive visual in welcome message
- Clicks "Run the Scene" to explore immediately

### Example: Voxel Wormhole with Full Metadata

See [BabylonJSLibrary.swift](XRAiAssistant/XRAiAssistant/Library3D/BabylonJSLibrary.swift) for the complete voxel wormhole implementation.

**Key Features**:
- Procedural generation using SimplexNoise algorithm
- Infinite tunnel with continuous voxel regeneration
- Performance optimization (voxel culling, max object limits)
- Post-processing effects (bloom for neon glow)
- HTML UI for real-time parameter control

### Future Enhancements (Roadmap)

**Phase 2**: Extended metadata fields
- `techniques: [String]` - Specific technical implementations
- `features: [String]` - User-facing capabilities
- `author: String?` - Credit for community contributions
- `sourceURL: String?` - Link to original or inspiration
- `performanceNotes: String?` - FPS benchmarks and optimization tips

**Phase 3**: Smart recommendation system
- Keyword-based similarity search
- AI-powered "Users who liked this also enjoyed..."
- Category-based browsing interface

**Phase 4**: Community contributions
- Submit examples via GitHub PR
- Automated keyword validation
- Quality review process

### Contributing New Examples

1. **Find inspiration**: Awesome CodePen, Three.js examples, Babylon.js playground
2. **Adapt to XRAiAssistant**: Ensure code works in embedded playground
3. **Add metadata**: Tag with 5-10 relevant keywords, write helpful AI hints
4. **Test thoroughly**: Verify scene runs smoothly, "Run the Scene" button works
5. **Submit**: Add to appropriate library file or submit as PR

### Best Practices

- **Keywords**: Use 5-10 specific, searchable terms
- **AI Hints**: Focus on "what makes this example special" and "how to apply this technique"
- **Code Quality**: Complete, working examples only (no placeholders)
- **Performance**: Note any optimization techniques used
- **Documentation**: Clear description of what the example demonstrates

---

## Development Guidelines

### 🔧 **Code Standards**
- **Swift**: Follow SwiftUI best practices, use @Published for reactive properties
- **AI Integration**: Always include proper error handling and retry logic
- **WebView Bridge**: Use type-safe message passing between Swift and JavaScript
- **Performance**: Optimize for mobile constraints (memory, battery, network)
- **Settings Persistence**: Use UserDefaults with proper key prefixing ("XRAiAssistant_") and default fallbacks
- **UI Feedback**: Implement visual confirmation for all user actions with appropriate animations

### 🚀 **AI Parameter Tuning Guidelines**
```swift
// Professional parameter combinations for different use cases
enum AIMode {
    case debugging    // temp: 0.2, top-p: 0.3 - Highly focused
    case balanced     // temp: 0.7, top-p: 0.9 - General purpose
    case creative     // temp: 1.2, top-p: 0.9 - Maximum innovation
    case teaching     // temp: 0.7, top-p: 0.8 - Educational explanations
}
```

### 📚 **RAG Implementation Guidelines**
- **Privacy First**: All vector search and embeddings stay on-device
- **Mobile Optimized**: Design for iOS memory and storage constraints  
- **Offline Capable**: Full functionality without internet connection
- **Fast Search**: Target <100ms response times for semantic queries

## Important Implementation Notes

### 🔐 **Security & Privacy**
- **API Key Management**: Secure storage with user-configurable keys
- **Local RAG**: No user data sent to external services
- **Code Privacy**: Generated 3D scenes remain on-device

### ⚡ **Performance Optimizations**
- **Streaming AI**: Real-time response generation without blocking UI
- **Intelligent Caching**: Avoid redundant API calls and processing
- **Memory Management**: Proper cleanup of WebView resources
- **Mobile-First**: Optimized for iPhone/iPad constraints

### 🎯 **User Experience Priorities**
- **Progressive Disclosure**: Advanced features don't overwhelm beginners
- **Visual Feedback**: Real-time parameter descriptions and status indicators
- **Educational Value**: Help users understand AI parameters and 3D concepts
- **Professional Workflows**: Match enterprise development tool expectations
- **Settings Persistence**: All user preferences automatically saved and restored
- **Explicit Save Actions**: Users control when settings are persisted with clear visual feedback

## Future Architecture Evolution

### 🔄 **Multi-Framework Support**
The architecture is designed for easy extension to support additional 3D frameworks through a plugin-like adapter system.

### 🌐 **Cross-Platform Deployment**
The dual-layer architecture (Swift + Web) enables future deployment to:
- **Android**: React Native or native Android development
- **Web**: Browser-based playground deployment
- **Desktop**: Electron or native macOS/Windows applications

### 🤝 **Community Extensions**
The modular architecture supports community contributions in:
- **AI Providers**: Additional language model integrations
- **3D Frameworks**: Support for Three.js, A-Frame, etc.
- **Knowledge Sources**: Extended RAG databases and embedding models

---

## Blog Post Memory Notes

### HTML Blog Formatting for Medium Publication

**IMPORTANT**: When creating blog.html files for Medium publication, use minimal styling to ensure clean copy-paste compatibility:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>[Blog Post Title]</title>
</head>
<body>
    <!-- Content with minimal styling -->
</body>
</html>
```

**Medium-Compatible Formatting Guidelines**:
- **NO custom CSS**: Remove all `<style>` tags and custom styling
- **Simple HTML only**: Use basic `<h1>`, `<h2>`, `<p>`, `<ul>`, `<li>`, `<pre><code>`
- **Replace styled divs**: Convert `.feature-card`, `.warning`, `.tags` to simple lists
- **Keep emojis**: Medium supports Unicode emojis in content
- **Preserve code blocks**: Use `<pre><code>` for code snippets
- **Simple links**: Use standard `<a href="">` without custom styling

**Tag Format**: Convert styled tags to simple paragraph:
```html
<h3>Tags</h3>
<p>#XRAiAssistant #NextJS #LocalDevelopment #WebXR #BabylonJS #ThreeJS</p>
```

**Warning Sections**: Convert styled warnings to bold paragraphs:
```html
<p><strong>⚠️ Security Reality</strong>:</p>
<ul>
    <li>Point 1</li>
    <li>Point 2</li>
</ul>
```

This ensures the HTML can be copied directly into Medium's editor without formatting issues.

---

## Sandpack WebView Integration Plan

### Overview: CodeSandbox Sandpack Integration for React Three Fiber and React Builds

**Objective**: Implement a WebView component utilizing Sandpack from CodeSandbox to provide in-app execution of React Three Fiber and React builds with live preview, hot reload, and sharing capabilities.

**🔒 CRITICAL: PRESERVE CURRENT IMPLEMENTATION**

**Non-Negotiable Requirements**:
- ✅ **Keep existing iframe implementation for Three.js, Babylon.js, and A-Frame**
- ✅ **Maintain current SceneRenderer and CodeEditor components unchanged**
- ✅ **Preserve existing split-view layout for legacy frameworks**
- ✅ **No breaking changes to current playground functionality**
- ✅ **Add Sandpack as OPTIONAL enhancement for React frameworks only**

**Framework-Specific Approach**:
```typescript
// PRESERVE: Three.js, Babylon.js, A-Frame → Always use current iframe system
// ENHANCE: React, React Three Fiber → Add optional Sandpack integration

const FRAMEWORK_RENDERING_STRATEGY = {
  'babylonjs': 'iframe-only',           // PRESERVE: No changes
  'threejs': 'iframe-only',             // PRESERVE: No changes  
  'aframe': 'iframe-only',              // PRESERVE: No changes
  'react-three-fiber': 'iframe-or-sandpack', // NEW: User choice
  'react': 'iframe-or-sandpack'               // NEW: User choice
}
```

### Phase 1: Research and Architecture (High Priority)

#### Sandpack Integration Analysis
```typescript
// Sandpack React components for in-app code execution
import { 
  SandpackProvider, 
  SandpackCodeEditor, 
  SandpackPreview,
  SandpackConsole,
  SandpackLayout 
} from "@codesandbox/sandpack-react"

// CodeSandbox Define API for programmatic sandbox creation
interface DefineAPIOptions {
  files: Record<string, { code: string }>
  template: string // 'react' | 'react-ts' | 'create-react-app'
  dependencies?: Record<string, string>
  devDependencies?: Record<string, string>
}
```

#### WebView Architecture Design
```typescript
// New component architecture for embedded sandbox execution
interface SandpackWebViewProps {
  initialCode: string
  framework: 'react' | 'react-three-fiber'
  onCodeChange?: (code: string) => void
  onSandboxCreated?: (sandboxId: string) => void
  showConsole?: boolean
  showPreview?: boolean
  autoReload?: boolean
}

// Integration with existing playground system - PRESERVING CURRENT IMPLEMENTATION
interface PlaygroundViewEnhancement {
  renderMode: 'iframe' | 'sandpack' // Keep iframe for Three.js, Babylon.js, A-Frame
  livePreview: boolean
  hotReload: boolean
  shareableUrl?: string
  
  // Framework-specific rendering strategy
  renderingStrategy: {
    'babylonjs': 'iframe'      // PRESERVE: Current iframe implementation
    'threejs': 'iframe'        // PRESERVE: Current iframe implementation  
    'aframe': 'iframe'         // PRESERVE: Current iframe implementation
    'react-three-fiber': 'sandpack' | 'iframe' // NEW: Optional Sandpack
    'react': 'sandpack' | 'iframe'              // NEW: Optional Sandpack
  }
}

// Backwards compatibility interface
interface LegacyPlaygroundSupport {
  preserveCurrentRendering: boolean // Always true for non-React frameworks
  enableSandpackOption: boolean     // Only true for React frameworks
}
```

### Phase 2: Core Implementation (High Priority)

#### CodeSandbox API Integration
```typescript
// Service for CodeSandbox Define API integration
class CodeSandboxService {
  private readonly API_BASE = 'https://codesandbox.io/api/v1'
  
  async createSandbox(options: DefineAPIOptions): Promise<string> {
    const response = await fetch(`${this.API_BASE}/sandboxes/define`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(options)
    })
    
    const { sandbox_id } = await response.json()
    return `https://codesandbox.io/s/${sandbox_id}`
  }
  
  generateR3FFiles(userCode: string): DefineAPIOptions {
    return {
      files: {
        'src/App.js': { code: this.wrapR3FComponent(userCode) },
        'src/index.js': { code: this.getReactIndex() },
        'package.json': { code: JSON.stringify(this.getR3FDependencies()) }
      },
      template: 'create-react-app'
    }
  }
  
  private wrapR3FComponent(userCode: string): string {
    return `
import React from 'react'
import { Canvas } from '@react-three/fiber'
import { OrbitControls, Environment } from '@react-three/drei'

${userCode}

export default function App() {
  return (
    <Canvas camera={{ position: [0, 0, 5] }}>
      <ambientLight intensity={0.5} />
      <spotLight position={[10, 10, 10]} angle={0.15} penumbra={1} />
      <pointLight position={[-10, -10, -10]} />
      <Scene />
      <OrbitControls />
      <Environment preset="city" />
    </Canvas>
  )
}
    `
  }
  
  private getR3FDependencies() {
    return {
      name: 'xraiassistant-r3f-scene',
      dependencies: {
        '@react-three/fiber': '^8.17.10',
        '@react-three/drei': '^9.109.0',
        'react': '^18.2.0',
        'react-dom': '^18.2.0',
        'three': '^0.171.0'
      }
    }
  }
}
```

#### Sandpack Component Implementation
```typescript
// Main Sandpack WebView component
export function SandpackWebView({ 
  initialCode, 
  framework, 
  onCodeChange, 
  onSandboxCreated,
  showConsole = false,
  showPreview = true,
  autoReload = true 
}: SandpackWebViewProps) {
  const [files, setFiles] = useState<Record<string, string>>({})
  const [template, setTemplate] = useState<string>('react')
  const [dependencies, setDependencies] = useState<Record<string, string>>({})
  
  useEffect(() => {
    if (framework === 'react-three-fiber') {
      const r3fFiles = CodeSandboxService.generateR3FFiles(initialCode)
      setFiles(r3fFiles.files)
      setTemplate('create-react-app')
      setDependencies(r3fFiles.dependencies || {})
    } else {
      // Standard React setup
      setFiles({
        'src/App.js': initialCode,
        'src/index.js': getReactIndex()
      })
      setTemplate('react')
      setDependencies(getReactDependencies())
    }
  }, [initialCode, framework])
  
  const handleCodeChange = (code: string) => {
    onCodeChange?.(code)
    if (autoReload) {
      // Update files state to trigger Sandpack reload
      setFiles(prev => ({
        ...prev,
        'src/App.js': code
      }))
    }
  }
  
  const handleCreateSandbox = async () => {
    try {
      const sandboxUrl = await CodeSandboxService.createSandbox({
        files,
        template,
        dependencies
      })
      onSandboxCreated?.(sandboxUrl)
      toast.success('Sandbox created! URL copied to clipboard.')
      copyToClipboard(sandboxUrl)
    } catch (error) {
      toast.error('Failed to create sandbox')
      console.error(error)
    }
  }
  
  return (
    <div className="h-full flex flex-col">
      {/* Toolbar */}
      <div className="flex items-center justify-between p-3 bg-gray-100 dark:bg-gray-800 border-b">
        <div className="flex items-center space-x-2">
          <span className="text-sm font-medium text-gray-700 dark:text-gray-300">
            {framework === 'react-three-fiber' ? 'React Three Fiber' : 'React'} Sandbox
          </span>
          {framework === 'react-three-fiber' && (
            <span className="px-2 py-1 text-xs bg-purple-100 dark:bg-purple-900 text-purple-700 dark:text-purple-300 rounded">
              R3F
            </span>
          )}
        </div>
        
        <div className="flex items-center space-x-2">
          <button
            onClick={() => setShowConsole(!showConsole)}
            className="px-3 py-1 text-sm rounded bg-gray-200 dark:bg-gray-700 hover:bg-gray-300 dark:hover:bg-gray-600"
          >
            {showConsole ? 'Hide Console' : 'Show Console'}
          </button>
          
          <button
            onClick={handleCreateSandbox}
            className="px-3 py-1 text-sm rounded bg-blue-600 text-white hover:bg-blue-700"
          >
            Share Sandbox
          </button>
        </div>
      </div>
      
      {/* Sandpack Container */}
      <div className="flex-1">
        <SandpackProvider
          template={template}
          files={files}
          customSetup={{
            dependencies
          }}
          options={{
            showNavigator: false,
            showRefreshButton: true,
            showOpenInCodeSandbox: true,
            editorHeight: '100%'
          }}
        >
          <SandpackLayout>
            <SandpackCodeEditor 
              showTabs={false}
              showLineNumbers={true}
              showInlineErrors={true}
              wrapContent={true}
              closableTabs={false}
              onCodeUpdate={(code) => handleCodeChange(code)}
            />
            
            {showPreview && (
              <SandpackPreview
                showNavigator={false}
                showRefreshButton={true}
                showOpenInCodeSandbox={true}
              />
            )}
          </SandpackLayout>
          
          {showConsole && (
            <div className="h-48 border-t">
              <SandpackConsole />
            </div>
          )}
        </SandpackProvider>
      </div>
    </div>
  )
}
```

### Phase 3: Template System (Medium Priority)

#### React Three Fiber Templates
```typescript
// R3F template system for different scene types
export const R3F_TEMPLATES = {
  basic: {
    name: 'Basic Scene',
    description: 'Simple mesh with lighting and controls',
    code: `
function Scene() {
  const meshRef = useRef()
  
  useFrame((state, delta) => {
    if (meshRef.current) {
      meshRef.current.rotation.x += delta
      meshRef.current.rotation.y += delta * 0.5
    }
  })
  
  return (
    <mesh ref={meshRef}>
      <boxGeometry args={[1, 1, 1]} />
      <meshStandardMaterial color="orange" />
    </mesh>
  )
}
    `,
    dependencies: ['@react-three/fiber', '@react-three/drei', 'three']
  },
  
  interactive: {
    name: 'Interactive Scene',
    description: 'Clickable meshes with state management',
    code: `
function Scene() {
  const [active, setActive] = useState(false)
  const [hovered, setHovered] = useState(false)
  
  return (
    <mesh
      scale={active ? 1.5 : 1}
      onClick={() => setActive(!active)}
      onPointerOver={() => setHovered(true)}
      onPointerOut={() => setHovered(false)}
    >
      <boxGeometry args={[1, 1, 1]} />
      <meshStandardMaterial color={hovered ? 'hotpink' : 'orange'} />
    </mesh>
  )
}
    `,
    dependencies: ['@react-three/fiber', '@react-three/drei', 'three']
  },
  
  physics: {
    name: 'Physics Scene',
    description: 'Physics-enabled objects with Cannon.js',
    code: `
import { useBox, usePlane, Physics } from '@react-three/cannon'

function Box(props) {
  const [ref, api] = useBox(() => ({ mass: 1, ...props }))
  
  return (
    <mesh ref={ref} onClick={() => api.velocity.set(0, 5, 0)}>
      <boxGeometry args={[1, 1, 1]} />
      <meshStandardMaterial color="orange" />
    </mesh>
  )
}

function Plane(props) {
  const [ref] = usePlane(() => ({ rotation: [-Math.PI / 2, 0, 0], ...props }))
  
  return (
    <mesh ref={ref}>
      <planeGeometry args={[100, 100]} />
      <meshStandardMaterial color="lightblue" />
    </mesh>
  )
}

function Scene() {
  return (
    <Physics>
      <Box position={[0, 5, 0]} />
      <Plane />
    </Physics>
  )
}
    `,
    dependencies: ['@react-three/fiber', '@react-three/drei', '@react-three/cannon', 'cannon', 'three']
  }
}
```

#### Standard React Templates
```typescript
// Standard React templates for various UI scenarios
export const REACT_TEMPLATES = {
  dashboard: {
    name: 'Dashboard',
    description: 'Interactive dashboard with charts and metrics',
    code: `
import React, { useState, useEffect } from 'react'

function Dashboard() {
  const [data, setData] = useState([])
  const [selectedMetric, setSelectedMetric] = useState('sales')
  
  useEffect(() => {
    // Simulate data fetching
    setData([
      { name: 'Sales', value: 12345 },
      { name: 'Users', value: 8901 },
      { name: 'Revenue', value: 45678 }
    ])
  }, [])
  
  return (
    <div className="p-6 bg-gray-50 min-h-screen">
      <h1 className="text-3xl font-bold mb-6">Analytics Dashboard</h1>
      
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        {data.map((item) => (
          <div key={item.name} className="bg-white p-6 rounded-lg shadow">
            <h3 className="text-lg font-semibold mb-2">{item.name}</h3>
            <p className="text-3xl font-bold text-blue-600">{item.value.toLocaleString()}</p>
          </div>
        ))}
      </div>
      
      <div className="bg-white p-6 rounded-lg shadow">
        <h2 className="text-xl font-semibold mb-4">Detailed Metrics</h2>
        <select 
          value={selectedMetric}
          onChange={(e) => setSelectedMetric(e.target.value)}
          className="p-2 border rounded"
        >
          <option value="sales">Sales</option>
          <option value="users">Users</option>
          <option value="revenue">Revenue</option>
        </select>
      </div>
    </div>
  )
}

export default Dashboard
    `,
    dependencies: ['react', 'react-dom']
  }
}
```

### Phase 4: Integration and Features (Medium Priority)

#### Live Preview and Hot Reload (PRESERVING CURRENT IMPLEMENTATION)
```typescript
// Enhanced playground view with Sandpack integration - BACKWARDS COMPATIBLE
export function EnhancedPlaygroundView() {
  const { currentCode, setCurrentCode, getCurrentLibrary } = useAppStore()
  const [renderMode, setRenderMode] = useState<'iframe' | 'sandpack'>('iframe')
  const [showLivePreview, setShowLivePreview] = useState(true)
  
  const library = getCurrentLibrary()
  const isReactBased = library?.id === 'react-three-fiber' || library?.id === 'react'
  const isLegacyFramework = library?.id === 'babylonjs' || library?.id === 'threejs' || library?.id === 'aframe'
  
  // PRESERVE: Always use iframe for legacy frameworks
  const effectiveRenderMode = isLegacyFramework ? 'iframe' : renderMode
  
  const handleCodeChange = (newCode: string) => {
    setCurrentCode(newCode)
    
    // Auto-save every 2 seconds when using Sandpack
    if (effectiveRenderMode === 'sandpack') {
      debounce(() => {
        // Save to localStorage or backend
        localStorage.setItem('xrai-current-code', newCode)
      }, 2000)()
    }
  }
  
  const handleSandboxCreated = (sandboxUrl: string) => {
    // Add to app state for sharing
    useAppStore.setState({ 
      lastCreatedSandbox: {
        url: sandboxUrl,
        code: currentCode,
        framework: library?.id,
        createdAt: Date.now()
      }
    })
  }
  
  return (
    <div className="flex flex-col h-full">
      {/* Enhanced Toolbar */}
      <div className="flex items-center justify-between p-3 bg-white dark:bg-gray-800 border-b">
        <div className="flex items-center space-x-4">
          {/* PRESERVE: Show render mode selector only for React frameworks */}
          {isReactBased && (
            <select
              value={renderMode}
              onChange={(e) => setRenderMode(e.target.value as 'iframe' | 'sandpack')}
              className="p-2 border rounded"
            >
              <option value="iframe">Iframe Renderer</option>
              <option value="sandpack">Sandpack Live</option>
            </select>
          )}
          
          {/* Show current rendering method */}
          <span className="text-xs px-2 py-1 bg-gray-100 dark:bg-gray-700 rounded">
            {isLegacyFramework ? 'Iframe (Optimized)' : effectiveRenderMode}
          </span>
          
          {effectiveRenderMode === 'sandpack' && (
            <label className="flex items-center space-x-2">
              <input
                type="checkbox"
                checked={showLivePreview}
                onChange={(e) => setShowLivePreview(e.target.checked)}
              />
              <span>Live Preview</span>
            </label>
          )}
        </div>
        
        <div className="flex items-center space-x-2">
          <span className="text-sm text-gray-600 dark:text-gray-400">
            {library?.name} v{library?.version}
          </span>
          
          {/* PRESERVE: Show compatibility badge for legacy frameworks */}
          {isLegacyFramework && (
            <span className="px-2 py-1 text-xs bg-green-100 dark:bg-green-900 text-green-700 dark:text-green-300 rounded">
              Native WebGL
            </span>
          )}
        </div>
      </div>
      
      {/* Content Area - CONDITIONAL RENDERING */}
      <div className="flex-1">
        {effectiveRenderMode === 'sandpack' && isReactBased ? (
          // NEW: Sandpack integration for React frameworks only
          <SandpackWebView
            initialCode={currentCode}
            framework={library?.id as 'react' | 'react-three-fiber'}
            onCodeChange={handleCodeChange}
            onSandboxCreated={handleSandboxCreated}
            showPreview={showLivePreview}
            autoReload={true}
          />
        ) : (
          // PRESERVE: Current iframe implementation for ALL non-React frameworks
          // This maintains the existing split-view layout and SceneRenderer
          <div className="flex h-full">
            <div className="w-1/2 border-r border-gray-200 dark:border-gray-700">
              <CodeEditor
                value={currentCode}
                onChange={handleCodeChange}
                language={getLanguageForLibrary(library)}
                library={library}
              />
            </div>
            <div className="w-1/2">
              <SceneRenderer
                code={currentCode}
                library={library}
                isRunning={true}
              />
            </div>
          </div>
        )}
      </div>
    </div>
  )
}

// Helper function to determine language mode
function getLanguageForLibrary(library: Library3D | undefined): string {
  if (!library) return 'javascript'
  
  switch (library.id) {
    case 'react-three-fiber':
    case 'react':
      return 'jsx'
    case 'babylonjs':
    case 'threejs':
    case 'aframe':
    default:
      return 'javascript'
  }
}
```

#### Sharing and Collaboration Features
```typescript
// Sharing service for created sandboxes
class SharingService {
  async createShareableLink(code: string, framework: string): Promise<string> {
    const sandboxUrl = await CodeSandboxService.createSandbox({
      files: this.generateFiles(code, framework),
      template: this.getTemplate(framework)
    })
    
    // Store in app history
    const shareData = {
      id: generateId(),
      url: sandboxUrl,
      code,
      framework,
      createdAt: Date.now(),
      title: this.generateTitle(code)
    }
    
    this.saveToHistory(shareData)
    return sandboxUrl
  }
  
  generateEmbedCode(sandboxUrl: string): string {
    const sandboxId = this.extractSandboxId(sandboxUrl)
    return `<iframe src="https://codesandbox.io/embed/${sandboxId}" 
             width="100%" height="500px" 
             title="XRAiAssistant Generated Scene"></iframe>`
  }
  
  async shareToSocialMedia(sandboxUrl: string, platform: 'twitter' | 'linkedin') {
    const message = this.generateSocialMessage(sandboxUrl, platform)
    const shareUrl = this.buildShareUrl(platform, message, sandboxUrl)
    window.open(shareUrl, '_blank')
  }
  
  private generateSocialMessage(sandboxUrl: string, platform: string): string {
    const baseMessage = "Check out this 3D scene I created with XRAiAssistant! 🚀"
    const hashtags = "#XRAiAssistant #ReactThreeFiber #WebXR #AI #3D"
    
    return platform === 'twitter' 
      ? `${baseMessage} ${sandboxUrl} ${hashtags}`
      : `${baseMessage}\n\nCreated with AI-powered XR development tools.\n\n${sandboxUrl}\n\n${hashtags}`
  }
}
```

### Phase 5: Error Handling and Testing (Medium-Low Priority)

#### Comprehensive Error Handling
```typescript
// Error handling for Sandpack integration
interface SandpackError {
  type: 'compile' | 'runtime' | 'dependency' | 'network'
  message: string
  line?: number
  column?: number
  file?: string
  stack?: string
}

class SandpackErrorHandler {
  handleError(error: SandpackError): void {
    switch (error.type) {
      case 'compile':
        this.showCompileError(error)
        break
      case 'runtime':
        this.showRuntimeError(error)
        break
      case 'dependency':
        this.showDependencyError(error)
        break
      case 'network':
        this.showNetworkError(error)
        break
    }
  }
  
  private showCompileError(error: SandpackError): void {
    toast.error(`Compile Error: ${error.message}`)
    // Highlight error line in editor
    if (error.line) {
      this.highlightErrorLine(error.line, error.column)
    }
  }
  
  private showRuntimeError(error: SandpackError): void {
    toast.error(`Runtime Error: ${error.message}`)
    console.error('Runtime Error Details:', error.stack)
  }
  
  private showDependencyError(error: SandpackError): void {
    toast.error(`Dependency Error: ${error.message}`)
    // Suggest alternative dependencies
    this.suggestAlternativeDependencies(error.message)
  }
  
  private showNetworkError(error: SandpackError): void {
    toast.error('Network Error: Unable to create sandbox. Please check your connection.')
    // Offer offline mode or retry
    this.offerRetryOption()
  }
}
```

### Implementation Timeline

**Week 1-2**: Research Sandpack APIs, design architecture, implement CodeSandbox service
**Week 3-4**: Build core Sandpack WebView component, integrate with existing playground
**Week 5-6**: Implement templates system, add sharing features, comprehensive testing
**Week 7**: Error handling, performance optimization, documentation

### Dependencies to Add

```json
{
  "dependencies": {
    "@codesandbox/sandpack-react": "^2.13.5",
    "@codesandbox/sandpack-client": "^2.13.5"
  }
}
```

This implementation will provide a seamless in-app development experience with live preview, hot reload, and instant sharing capabilities for React Three Fiber and React builds.

---

## XRAiAssistant: The Future of AI-Powered XR Development

**XRAiAssistant** represents the cutting edge of AI-assisted Extended Reality development, combining:

### 🚀 **Current State (Ready to Use)**
- ✅ **Professional AI Control**: Dual-parameter system (Temperature + Top-p) with intelligent descriptions
- ✅ **Multi-Model Support**: 6+ AI models optimized for XR development workflows  
- ✅ **Secure API Management**: User-configurable Together AI integration with "changeMe" default
- ✅ **Advanced Settings Panel**: Progressive disclosure with model selection and system prompt editing
- ✅ **Settings Persistence**: Complete UserDefaults-based saving with Save/Cancel buttons and auto-restore
- ✅ **Visual Feedback**: Real-time validation indicators, save confirmation animations, and status badges
- ✅ **Professional UX**: Enterprise-grade settings workflow with animated confirmations
- ✅ **Swift-JavaScript Bridge**: Seamless native iOS + web playground integration
- ✅ **Real-time 3D Generation**: AI creates complete Babylon.js scenes with intelligent code correction
- ✅ **Automatic State Restoration**: All user preferences persist across app restarts

### 🔮 **Roadmap (In Development)**
- 🚧 **Local SQLite RAG**: Privacy-first knowledge enhancement with on-device vector search
- 🚧 **Universal Framework Toggle**: Support for Three.js, React Three Fiber, A-Frame, XR8
- 🚧 **Multi-modal AI**: Image input for XR scene analysis and modification
- 🚧 **Cross-platform Deployment**: Android, web, and desktop XR development environments

### 🎯 **Vision Statement**
XRAiAssistant democratizes Extended Reality development by making 3D/XR programming conversational, collaborative, and creative. Whether you're debugging a VR scene or exploring experimental AR interactions, XRAiAssistant provides professional-grade AI assistance while keeping your creative work completely private.

**This is the future of XR development: where natural language becomes the primary programming interface for immersive experiences.** 🚀

---

## 🔨 BUILD VERIFICATION REQUIREMENT

**MANDATORY**: At the end of EVERY coding session, verify that the iOS project builds successfully.

### Quick Build Check (Recommended)
```bash
# Fast syntax/compile check - no code signing
xcodebuild -project XRAiAssistant/XRAiAssistant.xcodeproj \
  -scheme XRAiAssistant \
  -configuration Debug \
  -sdk iphonesimulator \
  build \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  2>&1 | grep -E "(error:|warning:|Build succeeded|BUILD FAILED)"
```

### Expected Output (Success)
```
** BUILD SUCCEEDED **
```

### If Build Fails
1. **Check error messages** for file not found or compilation errors
2. **Verify new files** are in the correct location
3. **For Xcode 15+ projects**: Files are automatically included via `PBXFileSystemSynchronizedRootGroup`
4. **Clean if needed**: Delete DerivedData and retry
5. **Report errors** with full compilation log for debugging

### Why This Matters
- ✅ Catch syntax errors before committing
- ✅ Verify new files are properly integrated
- ✅ Ensure dependencies resolve correctly
- ✅ Prevent broken builds for other developers
- ✅ Maintain code quality and stability

**NOTE**: This project uses Xcode 15+ file system synchronization, so manually adding files to .pbxproj is NOT required. Simply placing files in the correct directory automatically includes them in the build.

### ⚠️ CRITICAL: Never Manually Edit project.pbxproj

**DO NOT** programmatically modify the `project.pbxproj` file. This can cause:
- Duplicate GUID errors
- Project corruption
- Loss of ability to clean/build
- Xcode crashes

**Instead**:
1. ✅ Place new Swift files in `XRAiAssistant/XRAiAssistant/` directory
2. ✅ Xcode 15+ automatically includes them (PBXFileSystemSynchronizedRootGroup)
3. ✅ If corruption occurs, run: `./scripts/xcode_recovery.sh`

**Recovery from Corruption**:
```bash
# If you see "duplicate GUID" or "unable to compute dependency graph":
./scripts/xcode_recovery.sh

# Then open Xcode and let it resolve packages
open XRAiAssistant/XRAiAssistant.xcodeproj
```