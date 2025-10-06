# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**XRAiAssistant** is a revolutionary AI-powered Extended Reality development platform that combines Babylon.js, Together AI, and native iOS development into the ultimate mobile XR development environment with advanced AI assistance capabilities.

> **The Ultimate Mobile XR Development Environment**  
> Democratizing 3D and Extended Reality development through conversational AI assistance, professional parameter control, and privacy-first architecture.

## Project Structure

### Main iOS Application (`XRAiAssistant/XRAiAssistant/`)
**XRAiAssistant** - The core iOS application with advanced AI integration:
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