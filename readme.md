# 🚀 XRAiAssistant - AI-Powered Extended Reality Development for iOS

> **The Ultimate Mobile XR Development Environment**  
> Revolutionizing 3D and Extended Reality development by combining Babylon.js, Together AI, and native iOS into an AI-assisted creative platform.

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-15.0+-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-Open%20Source-green.svg)](LICENSE)
[![Together AI](https://img.shields.io/badge/Together%20AI-Integrated-purple.svg)](https://together.ai)
[![XR Ready](https://img.shields.io/badge/XR-Ready-brightgreen.svg)](https://www.babylonjs.com/community/)

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

### 1. **Clone & Open**
```bash
git clone https://github.com/your-repo/XRAiAssistant.git
cd XRAiAssistant
open XRAiAssistant.xcodeproj
```

### 2. **Get Your Together AI API Key** ⚠️ **REQUIRED**
1. Visit [together.ai](https://together.ai) and create a free account
2. Navigate to API Keys section in your dashboard
3. Generate a new API key
4. Copy the key (starts with `tgp_v1_...`)

### 3. **Configure XRAiAssistant**
1. Build and run the app in Xcode (iOS Simulator or device)
2. Tap the **Settings** icon (gear) in the bottom tab bar
3. In "API Configuration" section, replace "changeMe" with your actual API key
4. Select your preferred AI model (free options available)
5. Adjust Temperature/Top-p parameters for your workflow
6. **Tap "Save"** to persist all settings - they'll be automatically restored when you restart the app

### 4. **Start Creating XR Experiences**
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

We welcome contributions across multiple areas:

### **Technical Contributions**
- **AI Providers**: OpenAI, Anthropic, local model integrations
- **XR Frameworks**: Three.js, A-Frame, WebXR enhancements
- **Performance**: Mobile XR optimizations, battery usage improvements
- **RAG Enhancement**: SQLite vector search, embedding model integration

### **Creative Contributions**  
- **XR Scene Templates**: Pre-built VR/AR experiences and demos
- **AI Prompt Engineering**: Specialized prompts for XR development domains
- **Documentation**: XR development guides, WebXR tutorials

### **Platform Extensions**
- **Android**: Cross-platform XR development
- **Web**: Browser-based XR playground deployment
- **Desktop**: macOS/Windows XR development environments

---

## 📊 **Project Status**

### ✅ **Stable & Ready to Use**
- Dual-parameter AI control (Temperature + Top-p) with smart descriptions
- Professional settings management with secure API key handling  
- Settings persistence with UserDefaults and visual feedback system
- 6+ AI model selection with cost optimization
- Babylon.js XR playground with Monaco editor
- Swift-JavaScript bridge architecture
- Intelligent error handling and streaming responses
- Real-time validation indicators and save confirmation animations

### 🚧 **In Active Development**
- Local SQLite RAG implementation with privacy-first vector search
- Universal framework toggle system (Three.js, A-Frame, etc.)
- Multi-modal AI with image input for XR scene analysis
- Enhanced embedding models (CoreML, Ollama integration)

### 🔮 **Future Roadmap**
- Cross-platform deployment (Android, Web)
- Collaborative multiplayer XR editing
- XR asset marketplace integration
- Advanced physics and spatial audio tools

---

## 🎯 **Why XRAiAssistant Matters**

This project represents a **fundamental shift** in how developers approach XR and 3D development:

- **Democratizes XR Development**: Complex 3D/XR programming becomes conversational
- **Privacy-Respecting AI**: Local RAG keeps your creative work completely private
- **Professional-Grade Tools**: Enterprise-level AI parameter control
- **Educational Platform**: Learn XR development through AI mentorship
- **Open Source Innovation**: Community-driven development of next-generation XR tools

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
- **GitHub**: [github.com/your-repo/XRAiAssistant](https://github.com/your-repo/XRAiAssistant)
- **Issues**: [Report bugs and request features](https://github.com/your-repo/XRAiAssistant/issues)
- **Discussions**: [Join technical discussions](https://github.com/your-repo/XRAiAssistant/discussions)

---

## 🏆 **Join the XR Revolution**

Ready to transform Extended Reality development with AI?

**Start building today** → Clone the repo, get your Together AI API key, and create your first AI-generated XR scene in minutes.

**Contribute tomorrow** → Help us build the future of AI-assisted XR development.

**Shape the community** → Join discussions, share your XR creations, and guide the project's evolution.

*The future of XR development is conversational, collaborative, and creative. Welcome to the revolution.* 🚀

---

## 📄 **License**

This project is open source and available under the [MIT License](LICENSE).

## 🙏 **Acknowledgments**

- **[Together.ai](https://together.ai)** for providing accessible AI model APIs
- **[Babylon.js Team](https://www.babylonjs.com/)** for the incredible XR-ready 3D engine
- **[Meta](https://llama.meta.com/)** for LlamaStack client libraries  
- **[SQLite](https://www.sqlite.org/)** community for vector extension innovations
- **[WebXR Community](https://www.w3.org/community/webxr/)** for pushing XR standards forward
- **Open Source Community** for inspiration and contributions

---

**Ready to build the future of XR development?** [Get started now!](https://github.com/your-repo/XRAiAssistant) 🚀

**Don't forget**: Replace `"changeMe"` with your Together AI API key! Get yours at [together.ai](https://together.ai) 🔑