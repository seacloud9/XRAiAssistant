# 🚀 XRAiAssistant - AI-Powered Extended Reality Development

> **The Ultimate Cross-Platform Mobile XR Development Environment**
> Democratizing 3D and Extended Reality development through conversational AI, professional tools, and privacy-first architecture.

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Kotlin](https://img.shields.io/badge/Kotlin-1.9.20+-7F52FF.svg)](https://kotlinlang.org)
[![iOS](https://img.shields.io/badge/iOS-15.0+-blue.svg)](https://developer.apple.com/ios/)
[![Android](https://img.shields.io/badge/Android-85%25%20Feature%20Parity-green.svg)](https://developer.android.com)
[![License](https://img.shields.io/badge/License-Open%20Source-green.svg)](LICENSE)
[![Together AI](https://img.shields.io/badge/Together%20AI-Integrated-purple.svg)](https://together.ai)
[![XR Ready](https://img.shields.io/badge/XR-Ready-brightgreen.svg)](https://www.babylonjs.com/community/)

📺 [Watch Demo](https://youtube.com/shorts/CJPmFxm9HE0?feature=share) | 📖 [Latest Blog: Part 4 - From Dreams to Production Reality](https://medium.com/@seacloud9/building-xraiassistant-part-4-from-multi-platform-dreams-to-production-reality-8268cbab5566)

---

## 📍 **Project Status**
- [Part 1: The Future of AI-Powered 3D Development on iOS](https://medium.com/@seacloud9/building-xraiassistant-the-future-of-ai-powered-3d-development-on-ios-part-1-ab3291b494d3)
- [Part 2: Multi-Provider AI meets Multi-Framework XR on iOS](https://medium.com/@seacloud9/building-xraiassistant-part-2-multi-provider-ai-meets-multi-framework-xr-on-ios-8f0784070e9d)
- [Part 3: Local Development Meets Universal Platform Vision](https://medium.com/@seacloud9/building-xraiassistant-part-3-local-development-meets-universal-platform-vision-15e2e5b9801b)
- [Building XRAiAssistant, Part 4: From Multi-Platform Dreams to Production Reality](https://medium.com/@seacloud9/building-xraiassistant-part-4-from-multi-platform-dreams-to-production-reality-8268cbab5566?postPublishedType=repub)

### 🎉 **What We've Achieved**

**Cross-Platform Reality** - XRAiAssistant is now live on both iOS and Android with **85% feature parity**!

- ✅ **iOS (Production Ready)**: Full AI integration, BuildKit JSX compilation, CodeSandbox deployment, enhanced chat UI
- ✅ **Android (85% Complete)**: Clean Architecture + Hilt, streaming AI responses, 3D framework support
- ✅ **3 AI Providers**: Together.ai, OpenAI, Anthropic - all with streaming responses
- ✅ **4 3D Frameworks**: Babylon.js, Three.js, React Three Fiber, A-Frame
- ✅ **BuildKit**: Local JSX/TSX compilation using esbuild-wasm (iOS only, 2-3s builds)
- ✅ **CodeSandbox Integration**: One-click R3F scene deployment to live URLs (iOS only)

### 📊 **By the Numbers**

```
880 lines    → Android AI integration code
85%          → iOS-Android feature parity
2-3 seconds  → BuildKit JSX compilation time
100%         → Offline capability (after setup)
3 providers  → Together.ai, OpenAI, Anthropic
7+ models    → Free and paid options available
4 frameworks → Babylon.js, Three.js, R3F, A-Frame
50-150KB     → Typical R3F bundle size
0 deps       → External dependencies for R3F builds
```

### 🚀 **Next Priority Improvements**

Want to contribute? Here's our roadmap prioritized by impact:

#### **🟢 High-Priority (Next 4-6 Weeks)**

**Android Feature Parity** - Bring Android to 100%:
1. **Examples Browser** - Port iOS examples library with search and filtering
2. **Persistent Chat History** - Room database integration for conversation storage
3. **Enhanced Chat UI** - Markdown rendering with code syntax highlighting
4. **CodeSandbox Integration** - Deploy R3F scenes from Android devices

**iOS Enhancements**:
1. **BuildKit Phase 2** - Explore Node.js Mobile for sub-1.5s build times
2. **Reactylon Support** - Add React + Babylon.js framework compilation
3. **Hot Reload** - Live editing without full rebuilds
4. **Bundle Caching** - Smart build system with incremental compilation

#### **🟡 Medium-Priority (Next 2-3 Months)**

**Cross-Platform Core**:
1. **Conversation Export** - Save chat history as Markdown/JSON
2. **Error Handling** - Better error messages and recovery flows
3. **Build Optimization** - Improve BuildKit performance and memory usage
4. **UI Polish** - Dark mode improvements, animations, accessibility

**Community & Documentation**:
1. **Video Tutorials** - Step-by-step guides for new users
2. **API Documentation** - Complete reference for AI providers and frameworks
3. **Example Gallery** - Curated collection of impressive 3D scenes
4. **Contribution Guide** - Clear pathways for community contributions

#### **🔴 Advanced Projects (Next 6+ Months)**

**Game-Changing Features**:
1. **Real-Time Collaboration** - Multi-user scene editing with Yjs + WebRTC
2. **Cloud Sync** - Cross-device conversation and settings sync
3. **XR Device Support** - Direct deployment to Vision Pro, Meta Quest
4. **Web Platform** - Browser-based XRAiAssistant with secure API key handling
5. **Node.js Mobile** - Native build support for Android (matching iOS BuildKit)

---

## 🌟 **What Makes XRAiAssistant Special**

This isn't just another 3D playground—it's a **paradigm shift** toward AI-assisted Extended Reality development:

- 🧠 **Professional AI Control**: Dual-parameter system (Temperature + Top-p) for precise creativity tuning
- 🔒 **Privacy-First RAG**: Local SQLite vector search for on-device knowledge enhancement  
- 📱 **Native iOS Performance**: SwiftUI + WebKit bridge for seamless XR development
- 🎨 **Universal Framework Support**: Babylon.js today, Three.js/R3F/A-Frame/XR8 coming soon
- ⚡ **Real-time Code Generation**: AI writes, corrects, and explains 3D/XR scenes instantly

---

## 🚨 **Important Setup Required**

**⚠️ API Key Setup**: XRAiAssistant comes with `apiKey = "changeMe"` by default for security. You MUST configure your API key:

1. **Get your free Together AI API key**: Visit [together.ai](https://together.ai) and sign up
2. **Open XRAiAssistant**: Launch the app on iOS Simulator or device
3. **Open Settings**: Tap the gear icon in the bottom tab bar
4. **Enter API Key**: Replace "changeMe" with your actual Together AI API key
5. **Select Model**: Choose from 6+ available AI models (free options available)

**Without a valid API key, the AI features will not work.**

---

## 🎯 **Current Features (Ready to Use)**

### 🤖 **Advanced AI Integration**
```swift
// Dual-parameter AI control for professional workflows
@Published var temperature: Double = 0.7  // Creativity control (0.0-2.0)
@Published var topP: Double = 0.9         // Vocabulary diversity (0.1-1.0)
@Published var apiKey: String = "changeMe" // REQUIRES USER SETUP
```

**Available AI Models:**
- **DeepSeek R1 70B** (FREE) - Advanced reasoning & coding
- **Llama 3.3 70B** (FREE) - Latest Meta large model
- **Llama 3 8B Lite** ($0.10/1M) - Cost-effective option
- **Qwen 2.5 7B Turbo** ($0.30/1M) - Fast coding specialist  
- **Qwen 2.5 Coder 32B** ($0.80/1M) - Advanced coding & XR

### 🎛️ **Professional Settings Panel**
- **Secure API Key Management**: Together.ai integration with real-time validation and status indicators
- **AI Model Selection**: Visual picker with pricing and capability information
- **Dual Parameter Control**: Temperature + Top-p sliders with smart descriptions
- **System Prompt Editor**: Full customization of AI behavior for XR development
- **Parameter Intelligence**: Dynamic explanations of combined parameter effects
- **Settings Persistence**: UserDefaults-based saving with Save/Cancel buttons and visual feedback
- **Auto-restore Settings**: All configurations automatically restored on app launch

### 🌐 **Babylon.js XR Integration**
- **Monaco Editor**: Professional code editing with IntelliSense
- **Real-time 3D Rendering**: WebGL scenes with instant XR preview
- **Smart Code Injection**: AI-generated code integrates seamlessly
- **XR-Ready**: Built for WebXR, AR, and VR development workflows
- **Swift-JavaScript Bridge**: Bidirectional communication for native performance

---

## 🔮 **Roadmap: What's Coming Next**

### 📚 **Local SQLite RAG (In Development)**
```swift
// Privacy-first knowledge enhancement - NO DATA LEAVES YOUR DEVICE
class LocalRAGChatViewModel: ChatViewModel {
    private let sqliteRAG: SQLiteVectorStore
    private let embeddingGenerator: LocalEmbeddingService
    
    func enhancePromptWithLocalRAG(_ query: String) async -> String {
        let embedding = await embeddingGenerator.embed(query)
        let relevantDocs = await sqliteRAG.vectorSearch(embedding)
        return systemPrompt + "\n\nRelevant Context:\n\(relevantDocs)"
    }
}
```

**Revolutionary Benefits:**
- 🔒 **100% Private**: All AI processing happens on your device
- ⚡ **Instant Search**: Sub-100ms semantic search on mobile
- 📦 **Efficient Storage**: Complete XR knowledge base in <50MB
- 🌍 **Works Offline**: Full functionality without internet

### 🔄 **Universal Framework Toggle**
- **React Three Fiber**: JSX-based 3D components for React developers
- **A-Frame**: WebXR and VR-focused declarative framework
- **Three.js**: Direct WebGL programming with full control
- **XR8 (8th Wall)**: Professional augmented reality experiences

---

## 🚀 **Quick Start**

Choose your platform and get started in minutes:

### **iOS Setup**

#### 1. **Clone & Open**
```bash
git clone https://github.com/seacloud9/XRAiAssistant.git
cd XRAiAssistant/XRAiAssistant
open XRAiAssistant.xcodeproj

# Build target: iPad Air 11-inch (M3) recommended
# Press Cmd+R to build and run
```

#### 2. **Get Your API Key** ⚠️ **REQUIRED**
1. Visit [together.ai](https://together.ai) and create a free account
2. Navigate to API Keys section in your dashboard
3. Generate a new API key (starts with `tgp_v1_...`)

#### 3. **Configure & Run**
1. Build and run in Xcode (iOS Simulator or device)
2. Tap **Settings** (gear icon) in bottom tab bar
3. Replace "changeMe" with your Together AI API key
4. Select your preferred AI model (DeepSeek R1 70B is FREE!)
5. Adjust Temperature/Top-p parameters
6. Tap **"Save"** - settings persist across app restarts

### **Android Setup**

#### 1. **Clone & Build**
```bash
git clone https://github.com/seacloud9/XRAiAssistant.git
cd XRAiAssistant/XRAiAssistantAndroid

# Build and install via Gradle
./gradlew assembleDebug
./gradlew installDebug

# Or open in Android Studio
```

#### 2. **Configure API Key**
1. Launch the app on Android device or emulator
2. Tap **Settings** (gear icon) in bottom navigation
3. Enter your Together AI API key (or OpenAI/Anthropic)
4. Select AI model and framework preferences
5. Settings are saved securely with EncryptedSharedPreferences

📖 **Full Android Guide**: See [ANDROID_QUICK_START.md](ANDROID_QUICK_START.md) for detailed setup instructions

### **Your First XR Scene**
```javascript
// Ask the AI: "Create a VR-ready scene with interactive objects"
// XRAiAssistant generates professional code like this:

const createScene = () => {
    const scene = new BABYLON.Scene(engine);
    
    // XR-optimized camera
    const camera = new BABYLON.UniversalCamera("camera", new BABYLON.Vector3(0, 1.6, -5), scene);
    camera.setTarget(BABYLON.Vector3.Zero());
    camera.attachControls(canvas, true);
    
    // VR-friendly lighting
    const light = new BABYLON.HemisphericLight("hemiLight", new BABYLON.Vector3(0, 1, 0), scene);
    light.intensity = 0.8;
    
    // Interactive XR elements with physics
    const sphere = BABYLON.MeshBuilder.CreateSphere("sphere", {diameter: 2}, scene);
    sphere.position.y = 1;
    
    // AI adds sophisticated XR interactions, optimizations, and creative elements
    
    return scene;
};
```

---

## 🏗️ **Architecture Overview**

### 📱 **iOS Native Layer (Swift/SwiftUI)**
```swift
@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var temperature: Double = 0.7
    @Published var topP: Double = 0.9
    @Published var apiKey: String = "changeMe"  // User must configure
    
    private var togetherAIService: TogetherAIService
    private var inference: RemoteInference
}
```

### 🌐 **Web XR Layer (Babylon.js/WebXR)**
```typescript
// Monaco Editor + Babylon.js + WebXR integration
interface XRPlaygroundBridge {
    insertCode(code: string): void;
    runScene(): void;
    enableVR(): void;
    enableAR(): void;
}
```

### 🤖 **AI Integration Layer**
- **Together.ai**: Primary provider with 6+ XR-optimized models
- **LlamaStack**: Fallback for Meta models
- **Streaming**: Real-time response generation
- **Error Handling**: Intelligent retry logic with cost optimization

---

## 🛠️ **Development Stack**

### **iOS Technologies**
- **Swift 5.9+**: Modern async/await and concurrency
- **SwiftUI**: Reactive UI framework with real-time parameter updates
- **WebKit**: High-performance WebXR integration
- **Combine**: Reactive programming for AI parameter binding

### **AI Integration**
- **AIProxy Swift v0.126.1**: Together.ai client library
- **LlamaStackClient**: Meta model support with streaming
- **Custom Parameter System**: Professional creativity control

### **Web XR Technologies**  
- **Babylon.js v6+**: Advanced XR rendering engine with WebXR support
- **Monaco Editor**: Professional code editing with XR snippets
- **TypeScript**: Type-safe XR development
- **WebXR APIs**: Native AR/VR support

---

## 🎨 **Real-World Usage Examples**

### **VR Scene Generation**
```
Developer: "Create an immersive space station interior for VR"
AI: *Generates complete VR-optimized scene with proper scale, interactive panels, 
    floating objects, ambient lighting, and performance optimizations for mobile VR*
```

### **AR Experience Development**  
```
Developer: "Build an AR furniture placement demo"
AI: *Creates AR-ready scene with plane detection, realistic furniture models,
    proper lighting estimation, and touch interactions for object placement*
```

### **WebXR Learning Mode**
```
Developer: "Explain how WebXR controllers work"
AI: *Provides comprehensive explanation with working demo code showing controller 
    tracking, haptic feedback, and interaction patterns for both VR and AR*
```

---

## ✅ **Project Successfully Renamed to XRAiAssistant**

**Complete Renaming Completed**: All project files and directories have been successfully renamed from "BabylonPlaygroundApp" to "XRAiAssistant":

### **What Was Renamed:**
- ✅ Directory: `BabylonPlaygroundApp_New/` → `XRAiAssistant/`
- ✅ Xcode Project: `BabylonPlaygroundApp.xcodeproj` → `XRAiAssistant.xcodeproj`
- ✅ App Target: `BabylonPlaygroundApp` → `XRAiAssistant`
- ✅ Swift App File: `BabylonPlaygroundApp.swift` → `XRAiAssistant.swift`
- ✅ Test Target: `BabylonPlaygroundAppTests` → `XRAiAssistantTests`
- ✅ Bundle ID: `com.example.XRAiAssistant`
- ✅ All project references and imports updated

**Ready to Build**: Simply open `XRAiAssistant.xcodeproj` in Xcode and build!

---

## 🤝 **Contributing**

We'd love your help building the future of XR development! Here are contribution opportunities organized by skill level:

### **🟢 Good First Issues**

Perfect for newcomers to the project:

- **Examples Library**: Add more Babylon.js, Three.js, or R3F scene examples
- **Documentation**: Improve setup guides, add troubleshooting sections
- **Testing**: Write unit tests for AI providers or 3D framework integrations
- **UI Polish**: Dark mode improvements, animations, accessibility enhancements
- **Translations**: Help internationalize the app (i18n support coming soon)

### **🟡 Intermediate Challenges**

Great for developers familiar with the codebase:

- **Android Examples Screen**: Port iOS examples browser to Android with search/filtering
- **Conversation Export**: Add ability to save chat history as Markdown or JSON
- **Build Optimization**: Improve BuildKit performance and reduce memory usage
- **Error Handling**: Better error messages and graceful recovery flows
- **Monaco Editor**: Enhanced IntelliSense for XR-specific APIs

### **🔴 Advanced Projects**

For experienced developers ready to tackle complex features:

- **Node.js Mobile**: Native JSX compilation for Android (matching iOS BuildKit)
- **Real-Time Collaboration**: WebRTC + Yjs integration for multi-user scene editing
- **Cloud Backend**: User authentication, scene sharing, cross-device sync
- **XR Device Support**: Direct deployment to Vision Pro, Meta Quest devices
- **Advanced RAG**: Local SQLite vector search with privacy-first architecture

### **Contributing Guidelines**

1. **Fork the repository** and create a feature branch
2. **Check existing issues** or create a new one describing your contribution
3. **Follow platform conventions**: SwiftUI for iOS, Jetpack Compose for Android
4. **Write tests** for new features when applicable
5. **Update documentation** to reflect your changes
6. **Submit a Pull Request** with a clear description of the changes

📖 **Full Guidelines**: See [CONTRIBUTING.md](CONTRIBUTING.md) (coming soon)

---

## 📊 **Detailed Platform Status**

### **iOS - Production Ready** ✅

**Core Features (100% Complete)**:
- ✅ Dual-parameter AI control (Temperature + Top-p) with intelligent descriptions
- ✅ 3 AI providers: Together.ai, OpenAI, Anthropic with streaming responses
- ✅ 7+ AI models with free and paid options
- ✅ Professional settings panel with secure API key management
- ✅ Settings persistence via UserDefaults with visual feedback
- ✅ Swift-JavaScript bridge for native-web communication

**Advanced Features (iOS Only)**:
- ✅ **BuildKit**: Local JSX/TSX compilation using esbuild-wasm (2-3s builds)
- ✅ **CodeSandbox Integration**: One-click R3F scene deployment to live URLs
- ✅ **Enhanced Chat UI**: Markdown rendering, syntax highlighting, threaded conversations
- ✅ **Persistent History**: Conversations survive app restarts with full-text search
- ✅ **Examples Browser**: Curated library with metadata-rich 3D scenes
- ✅ **4 3D Frameworks**: Babylon.js, Three.js, React Three Fiber, A-Frame

### **Android - 85% Feature Parity** 🚧

**What Works Now (85% Complete)**:
- ✅ Clean Architecture (MVVM + 3-layer separation)
- ✅ Jetpack Compose UI matching iOS elegance
- ✅ Hilt dependency injection
- ✅ All 3 AI providers with streaming SSE parsing
- ✅ 7+ AI models supported
- ✅ Babylon.js, Three.js, React Three Fiber support
- ✅ WebView playground with Monaco editor
- ✅ Secure settings with EncryptedSharedPreferences

**Coming to Android (Next 4-6 Weeks)**:
- ⏳ **Examples Browser** - Port iOS examples library
- ⏳ **Persistent Chat History** - Room database integration
- ⏳ **Enhanced Chat UI** - Markdown rendering + code highlighting
- ⏳ **CodeSandbox Integration** - Deploy R3F scenes from Android

**Future Android Enhancements**:
- 🔮 **BuildKit Android** - Node.js Mobile for native JSX compilation
- 🔮 **Hot Reload** - Live editing without full rebuilds
- 🔮 **A-Frame Full Support** - Currently partial implementation

### **Cross-Platform Vision** 🔮

**Long-Term Roadmap** (6+ months):
- 🔮 **Real-Time Collaboration**: Multi-user scene editing (Yjs + WebRTC)
- 🔮 **Cloud Sync**: Cross-device conversations and settings
- 🔮 **XR Device Support**: Vision Pro, Meta Quest direct deployment
- 🔮 **Web Platform**: Browser-based XRAiAssistant with secure architecture
- 🔮 **Local RAG**: Privacy-first SQLite vector search with on-device embeddings
- 🔮 **Multi-modal AI**: Image input for XR scene analysis and modifications

---

## 🎯 **Why XRAiAssistant Matters**

This project represents a **fundamental shift** in how developers approach XR and 3D development:

- 🎨 **Natural Language First**: Complex 3D/XR programming becomes conversational
- 📱 **Mobile-Native Development**: First-class XR development on phones and tablets
- 🔒 **Privacy-Respecting AI**: Local build systems and optional on-device processing
- ⚡ **Professional-Grade Tools**: Enterprise-level AI parameter control
- 🌍 **Cross-Platform by Design**: iOS and Android with shared architecture vision
- 📚 **Educational Platform**: Learn XR development through AI-powered mentorship
- 🚀 **Open Source Innovation**: Community-driven development of next-generation XR tools

---

## 📰 **Recent Updates (January 2025)**

### 🎉 **Major Milestones**

**Android Launch** - 85% iOS feature parity achieved in 4 months:
- ✅ Clean Architecture implementation (MVVM + Hilt)
- ✅ All 3 AI providers with streaming responses
- ✅ Full 3D framework support (Babylon.js, Three.js, R3F)
- ✅ Secure settings with EncryptedSharedPreferences

**iOS Advanced Features** - Production-ready enhancements:
- ✅ **BuildKit**: Local JSX compilation (2-3s builds, 100% offline)
- ✅ **CodeSandbox Integration**: One-click R3F scene deployment
- ✅ **Enhanced Chat**: Markdown, syntax highlighting, threaded conversations
- ✅ **Persistent History**: Full-text search across conversations

**Technical Achievements**:
- 880 lines of Android AI integration code
- 50-150KB bundle sizes for React Three Fiber
- Zero external dependencies for local builds
- Complete offline capability after initial setup

📖 **Read the Full Story**: [Building XRAiAssistant Part 4: From Multi-Platform Dreams to Production Reality](https://medium.com/@seacloud9/building-xraiassistant-part-4-from-multi-platform-dreams-to-production-reality-8268cbab5566)

---

## 🚨 **Critical Setup Reminder**

**Before building**: You MUST replace the default API key!

1. **In Code**: `DEFAULT_API_KEY = "changeMe"` requires your Together AI key
2. **In App**: Use Settings panel to configure your API key securely
3. **Get Key**: Free signup at [together.ai](https://together.ai)

**Without proper API key setup, AI features will not function.**

---

## 📚 **Learning Resources**

### **Getting Started**
- [Together AI API Documentation](https://docs.together.ai/)
- [Babylon.js WebXR Guide](https://doc.babylonjs.com/divingDeeper/webXR)
- [SwiftUI Documentation](https://developer.apple.com/xcode/swiftui/)

### **Advanced Topics**
- [WebXR Device API](https://www.w3.org/TR/webxr/)
- [AI Parameter Tuning Best Practices](https://platform.openai.com/docs/guides/parameter-tuning)
- [Mobile XR Performance Optimization](https://developer.oculus.com/documentation/web/webxr-performance/)

### **Community**
- **GitHub**: [github.com/seacloud9/XRAiAssistant](https://github.com/seacloud9/XRAiAssistant)
- **Issues**: [Report bugs and request features](https://github.com/seacloud9/XRAiAssistant/issues)
- **Discussions**: [Join technical discussions](https://github.com/seacloud9/XRAiAssistant/discussions)
- **Blog Series**: [Read the journey on Medium](https://medium.com/@seacloud9)

---

## 🏆 **Join the XR Revolution**

Ready to transform Extended Reality development with AI?

**🚀 Start Building Today**
- Clone the repo and choose your platform (iOS or Android)
- Get your free Together AI API key
- Create your first AI-generated XR scene in minutes
- Deploy to CodeSandbox and share with the world (iOS)

**🤝 Contribute Tomorrow**
- Pick a task from our prioritized roadmap above
- Help bring Android to 100% feature parity
- Add new examples to the library
- Improve documentation and tutorials

**💬 Shape the Community**
- Join GitHub Discussions and share your creations
- Report bugs and request features you'd love to see
- Provide feedback on the AI-assisted workflow
- Guide the project's evolution with your expertise

*The future of XR development is conversational, collaborative, and creative. We went from localhost-only dreams to cross-platform reality in 4 months. What will the next 4 months bring? Join us and find out!* 🚀✨

---

## 📄 **License**

This project is open source and available under the [MIT License](LICENSE).

## 🙏 **Acknowledgments**

### **Technology Partners**
- **[Together.ai](https://together.ai)** - Accessible AI model APIs with generous free tier
- **[OpenAI](https://openai.com)** - GPT-4 and GPT-4o model support
- **[Anthropic](https://anthropic.com)** - Claude 3.5 Sonnet integration
- **[Babylon.js Team](https://www.babylonjs.com/)** - Incredible XR-ready 3D engine
- **[Three.js Contributors](https://threejs.org/)** - Industry-standard WebGL library
- **[React Three Fiber](https://docs.pmnd.rs/react-three-fiber)** - React renderer for Three.js
- **[Meta](https://llama.meta.com/)** - LlamaStack client libraries and open models

### **Build Tools & Infrastructure**
- **[esbuild](https://esbuild.github.io/)** - Lightning-fast JavaScript bundler (WASM build system)
- **[CodeSandbox](https://codesandbox.io)** - Instant deployment and sharing infrastructure
- **[Monaco Editor](https://microsoft.github.io/monaco-editor/)** - Professional code editing experience
- **[WebXR Community](https://www.w3.org/community/webxr/)** - Pushing XR standards forward

### **Community Wins** 🎉

Special thanks to early testers and contributors:
- **CodeSandbox R3F Testing**: "This is excellent work! R3F is working exceptionally well!"
- **Android Alpha Testers**: Identified streaming response issues early
- **iOS Build Verification**: Caught Xcode 15 file synchronization problems
- **Documentation Contributors**: Improved setup guides for new users

### **Open Source Community**
This project stands on the shoulders of giants. Thank you to all open-source maintainers, contributors, and enthusiasts who make projects like this possible. ❤️

---

**Ready to build the future of XR development?**

⭐ [Star the project on GitHub](https://github.com/seacloud9/XRAiAssistant) | 📖 [Read the blog series](https://medium.com/@seacloud9) | 🚀 [Get started now!](https://github.com/seacloud9/XRAiAssistant#-quick-start)

**Don't forget**: Replace `"changeMe"` with your Together AI API key! Get yours at [together.ai](https://together.ai) 🔑

---

*Built with ❤️ by the XRAiAssistant community. From localhost dreams to cross-platform reality. Join the revolution!* 🚀
