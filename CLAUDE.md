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