# XRAiAssistant Android

**AI-powered Extended Reality development platform for Android**

Kotlin/Compose port of the iOS XRAiAssistant application, bringing the same powerful AI-assisted 3D development capabilities to Android devices.

## Features

### 🤖 **Multi-Provider AI Integration**
- **Together.ai** (Primary) - DeepSeek R1 70B, Llama 3.3 70B, Qwen models
- **OpenAI** - GPT-4o and other models  
- **Anthropic** - Claude 3.5 Sonnet
- Dual-parameter control (Temperature + Top-p)
- Streaming AI responses with real-time generation

### 🎯 **3D Library Support**
- **Babylon.js v8.22.3** - Professional WebGL engine
- **Three.js r171** - Popular lightweight 3D library
- **React Three Fiber 8.17.10** - Declarative React renderer
- **A-Frame v1.7.0** - WebXR VR/AR framework
- Automatic framework switching with specialized AI prompts

### 🔧 **Professional Development Environment**
- Monaco code editor integration (via WebView)
- Real-time 3D scene rendering
- Code injection and execution
- Build system for React frameworks
- Hot reload capabilities

### 🔐 **Security & Privacy**
- Encrypted API key storage
- Local settings persistence
- No data collection
- User-controlled AI provider selection

## Architecture

### **Core Components**
- **`ChatViewModel`** - Main AI integration hub with Compose StateFlow
- **`Library3DRepository`** - 3D framework management system
- **`AIProviderRepository`** - Multi-provider API client with retry logic
- **`SettingsDataStore`** - Encrypted preferences with DataStore

### **UI Structure**
- **Jetpack Compose** - Modern declarative UI
- **Material Design 3** - Consistent Android design language
- **Bottom Navigation** - Code → Run Scene → Settings workflow
- **Modal Bottom Sheets** - Progressive disclosure settings panel

### **AI Integration**
```kotlin
// Multi-provider AI architecture
class ChatViewModel @Inject constructor(
    private val aiProviderRepository: AIProviderRepository,
    private val library3DRepository: Library3DRepository,
    private val settingsRepository: SettingsRepository
) {
    // Intelligent AI routing based on model selection
    suspend fun sendMessage(content: String, currentCode: String = "") {
        val library = currentLibrary.value
        val enhancedPrompt = buildPrompt(content, currentCode, library)
        
        val response = aiProviderRepository.generateResponse(
            prompt = enhancedPrompt,
            model = selectedModel.value,
            temperature = temperature.value,
            topP = topP.value,
            systemPrompt = systemPrompt.value
        )
        
        processAIResponse(response, library)
    }
}
```

## Technology Stack

### **Android/Kotlin**
- **Kotlin 1.9.20** - Modern Android development
- **Jetpack Compose** - Declarative UI framework
- **Material Design 3** - Google's latest design system
- **Android Gradle Plugin 8.2.0** - Latest build tools

### **Architecture & DI**
- **Hilt** - Dependency injection
- **ViewModel + StateFlow** - Reactive state management
- **DataStore Preferences** - Type-safe preferences
- **Encrypted SharedPreferences** - Secure API key storage

### **Networking & Async**
- **Retrofit + OkHttp** - HTTP client for AI APIs
- **Kotlin Coroutines** - Async programming
- **Kotlinx Serialization** - JSON processing

### **WebView Integration**
- **AndroidX WebKit** - Modern WebView APIs
- **JavaScript Bridge** - Bidirectional communication
- **Custom URL Schemes** - Asset serving

## Project Structure

```
app/src/main/java/com/xraiassistant/
├── MainActivity.kt                    # App entry point
├── XRAiAssistantApplication.kt       # Hilt application
├── data/
│   ├── local/
│   │   └── SettingsDataStore.kt      # Encrypted settings storage
│   ├── models/
│   │   ├── ChatMessage.kt            # Chat data models
│   │   └── AIModel.kt                # AI model definitions
│   ├── remote/
│   │   └── AIProviderService.kt      # HTTP AI provider client
│   └── repositories/
│       ├── AIProviderRepository.kt   # AI provider management
│       ├── Library3DRepository.kt    # 3D library management
│       └── SettingsRepository.kt     # Settings persistence
├── domain/
│   └── models/
│       ├── Library3D.kt              # 3D library interface
│       └── AFrameLibrary.kt          # A-Frame implementation
├── ui/
│   ├── components/
│   │   ├── ChatScreen.kt             # AI conversation UI
│   │   ├── SceneScreen.kt            # 3D playground WebView
│   │   ├── SettingsScreen.kt         # Configuration panel
│   │   └── ChatMessageCard.kt        # Message display
│   ├── screens/
│   │   └── MainScreen.kt             # Primary navigation
│   ├── theme/
│   │   ├── Color.kt                  # Material Design colors
│   │   ├── Theme.kt                  # Compose theme
│   │   └── Type.kt                   # Typography
│   └── viewmodels/
│       └── ChatViewModel.kt          # Core business logic
└── di/
    └── AppModule.kt                  # Hilt dependency injection
```

## Getting Started

### **Prerequisites**
- **Android Studio Flamingo** or later
- **Android SDK 26+** (Android 8.0+)
- **JDK 8** or later

### **Setup**
1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd XRAiAssistantAndroid
   ```

2. **Open in Android Studio**:
   - File → Open → Select `XRAiAssistantAndroid` folder
   - Wait for Gradle sync to complete

3. **Build and run**:
   - Connect Android device or start emulator
   - Click Run (▶) or press `Ctrl+R`

4. **Configure API keys**:
   - Launch app on device/emulator
   - Tap Settings (⚙️) in bottom navigation
   - Enter API keys for your preferred AI providers:
     - **Together.ai**: Get free key at [together.ai](https://together.ai)
     - **OpenAI**: Get key at [platform.openai.com](https://platform.openai.com)
     - **Anthropic**: Get key at [console.anthropic.com](https://console.anthropic.com)

### **First 3D Scene**
1. **Select your 3D library** in Settings (Babylon.js recommended for beginners)
2. **Choose an AI model** (DeepSeek R1 70B is free and powerful)
3. **Return to Code tab** and ask: *"Create a spinning cube with rainbow colors"*
4. **Tap Run Scene** when code is generated
5. **Enjoy your AI-created 3D scene!**

## Development Status

### **✅ Completed (Phase 1)**
- [x] Complete project structure and Gradle configuration
- [x] Core AI integration with multi-provider support
- [x] Library3D framework system (5 libraries)
- [x] Jetpack Compose UI with Material Design 3
- [x] Settings persistence with encrypted API keys
- [x] Chat interface with streaming responses
- [x] Professional parameter control (Temperature + Top-p)

### **🚧 In Progress (Phase 2)**
- [ ] WebView integration with Monaco editor
- [ ] JavaScript bridge for code injection
- [ ] 3D scene rendering and execution
- [ ] Build system for React frameworks
- [ ] Vendor asset management
- [ ] Hot reload capabilities

### **📋 Planned (Phase 3)**
- [ ] Advanced WebXR features
- [ ] Local RAG system with SQLite
- [ ] Multi-framework build pipeline
- [ ] Performance analytics
- [ ] Offline mode capabilities

## Contributing

We welcome contributions! This project aims to democratize 3D/XR development through AI assistance.

### **Areas for Contribution**
- **WebView Integration** - Monaco editor and 3D rendering
- **Build System** - React Three Fiber compilation
- **UI/UX** - Material Design improvements
- **Testing** - Unit and integration tests
- **Documentation** - Code examples and tutorials

## License

See LICENSE file for details.

---

## **XRAiAssistant: The Future of AI-Powered XR Development**

This Android implementation brings the groundbreaking XRAiAssistant experience to the world's most popular mobile platform. Whether you're learning 3D programming, prototyping XR experiences, or building professional applications, XRAiAssistant makes 3D development as simple as having a conversation.

**From idea to immersive experience in seconds. That's the power of AI-assisted XR development.** 🚀