# XRAiAssistant Android

> **The Ultimate Mobile XR Development Environment** - Now on Android!

XRAiAssistant Android is a revolutionary AI-powered Extended Reality development platform that combines Babylon.js, Together AI, and native Android development into the ultimate mobile XR development environment with advanced AI assistance capabilities.

**Complete feature parity with iOS version** using Kotlin, Jetpack Compose, and modern Android architecture.

---

## ✨ Features

### 🤖 Professional AI Integration
- **Multi-Provider Support**: Together.ai, OpenAI, Anthropic
- **Streaming Responses**: Real-time AI generation with progress indicators
- **Advanced Parameter Control**: Temperature & Top-p with intelligent descriptions
- **6+ AI Models**: DeepSeek R1, Llama 3.3, GPT-4o, Claude 3.5 Sonnet, and more

### 🎨 5 Supported 3D Libraries
- **Babylon.js** - Full-featured WebGL engine
- **Three.js** - Popular 3D library
- **A-Frame** - WebVR framework
- **React Three Fiber** - React + Three.js declarative
- **Reactylon** - React + Babylon.js declarative

### 📦 CodeSandbox Integration
- Automatic sandbox creation for R3F and Reactylon
- Live preview and hot reload
- One-tap deployment
- Share sandboxes instantly

### 💾 Data Persistence
- Conversation history with Room database
- Settings stored in DataStore
- Offline-ready architecture
- Auto-save functionality

### 🎯 Code Intelligence
- Automatic code extraction from AI responses
- Babylon.js API error correction
- TypeScript to JavaScript conversion
- React component validation

---

## 🏗️ Architecture

### **MVVM + Clean Architecture**

```
┌─────────────────────────────────────┐
│      Presentation Layer              │
│  Compose UI → ViewModels → State    │
└──────────────┬──────────────────────┘
               │
┌──────────────┴──────────────────────┐
│         Domain Layer                 │
│  Use Cases → Repositories (I)       │
└──────────────┬──────────────────────┘
               │
┌──────────────┴──────────────────────┐
│          Data Layer                  │
│  Repositories (Impl) → Data Sources │
└─────────────────────────────────────┘
```

### **Tech Stack**
- **Language**: Kotlin 1.9.20
- **UI**: Jetpack Compose 1.5.4 + Material 3
- **DI**: Hilt 2.48
- **Networking**: Retrofit 2.9 + OkHttp 4.11
- **Database**: Room 2.6.0
- **Settings**: DataStore 1.0.0
- **Testing**: JUnit 5, Mockk, Turbine

---

## 🚀 Getting Started

### Prerequisites
- **Android Studio**: Hedgehog (2023.1.1) or later
- **JDK**: 17 or later
- **Minimum Android**: API 26 (Android 8.0)
- **Target Android**: API 34 (Android 14)

### Setup Instructions

1. **Clone the repository**
   ```bash
   cd XRAiAssistant/XRAiAssistantAndroid
   ```

2. **Open in Android Studio**
   - File → Open → Select `XRAiAssistantAndroid` folder
   - Wait for Gradle sync to complete

3. **Build the project**
   ```bash
   ./gradlew build
   ```

4. **Run on device/emulator**
   - Click "Run" or use `./gradlew installDebug`

5. **Configure API Keys**
   - Launch app on device/emulator
   - Tap Settings (⚙️) in bottom navigation
   - Enter your Together.ai API key (required)
   - Optional: Add OpenAI or Anthropic keys
   - Tap "Save"

---

## 📱 App Structure

### Package Organization

```
com.xrai.assistant/
├── di/                         # Dependency Injection
│   ├── AppModule.kt
│   ├── NetworkModule.kt
│   └── DatabaseModule.kt
│
├── data/                       # Data Layer
│   ├── remote/                # API clients
│   │   ├── TogetherAiService.kt
│   │   ├── OpenAiService.kt
│   │   ├── AnthropicService.kt
│   │   └── CodeSandboxService.kt
│   ├── local/                 # Local storage
│   │   ├── dao/
│   │   ├── database/
│   │   └── datastore/
│   └── repository/            # Repository implementations
│       ├── ChatRepositoryImpl.kt
│       └── SettingsRepositoryImpl.kt
│
├── domain/                     # Domain Layer
│   ├── model/                 # Domain models
│   │   ├── ChatMessage.kt
│   │   ├── AIProvider.kt
│   │   ├── AIModel.kt
│   │   └── Library3D.kt
│   ├── repository/            # Repository interfaces
│   │   ├── ChatRepository.kt
│   │   └── SettingsRepository.kt
│   └── usecase/               # Use cases
│       ├── SendMessageUseCase.kt
│       └── CreateSandboxUseCase.kt
│
├── presentation/               # Presentation Layer
│   ├── screens/
│   │   ├── chat/
│   │   │   ├── ChatScreen.kt
│   │   │   └── ChatViewModel.kt
│   │   ├── scene/
│   │   │   ├── SceneScreen.kt
│   │   │   └── SceneViewModel.kt
│   │   └── settings/
│   │       ├── SettingsScreen.kt
│   │       └── SettingsViewModel.kt
│   ├── navigation/
│   │   ├── NavGraph.kt
│   │   └── NavigationDestinations.kt
│   └── theme/
│       ├── Color.kt
│       ├── Theme.kt
│       └── Type.kt
│
└── util/                       # Utilities
    ├── CodeExtractor.kt
    ├── TypeScriptCleaner.kt
    └── BabylonJSFixer.kt
```

---

## 🔧 Development

### Building

```bash
# Debug build
./gradlew assembleDebug

# Release build
./gradlew assembleRelease

# Run tests
./gradlew test

# Run UI tests
./gradlew connectedAndroidTest
```

### Code Quality

```bash
# Run linter
./gradlew lint

# Check code style
./gradlew ktlintCheck

# Format code
./gradlew ktlintFormat
```

---

## 🧪 Testing

### Test Coverage Goals
- **Unit Tests**: 80%+ coverage
- **UI Tests**: All critical user flows
- **Integration Tests**: All API clients

### Running Tests

```bash
# All unit tests
./gradlew test

# Specific test class
./gradlew test --tests ChatViewModelTest

# All instrumentation tests
./gradlew connectedAndroidTest

# Generate coverage report
./gradlew jacocoTestReport
```

### Test Structure

```
app/src/test/                   # Unit tests
├── viewmodel/
│   └── ChatViewModelTest.kt
├── usecase/
│   └── SendMessageUseCaseTest.kt
└── repository/
    └── ChatRepositoryTest.kt

app/src/androidTest/            # Instrumentation tests
├── ui/
│   ├── ChatScreenTest.kt
│   └── SettingsScreenTest.kt
└── database/
    └── MessageDaoTest.kt
```

---

## 📚 Documentation

### iOS to Android Translation Guide

| iOS (Swift/SwiftUI) | Android (Kotlin/Compose) |
|---------------------|--------------------------|
| `@ObservableObject` | `@HiltViewModel` |
| `@Published var` | `StateFlow<T>` |
| `struct ContentView: View` | `@Composable fun ContentView()` |
| `@State private var text = ""` | `var text by remember { mutableStateOf("") }` |
| `TextField("Prompt", text: $text)` | `TextField(value = text, onValueChange = { text = it })` |
| `List { ForEach(items) { } }` | `LazyColumn { items(items) { } }` |
| `UserDefaults` | `DataStore` |
| `URLSession` | `Retrofit + OkHttp` |
| `async/await` | `suspend fun` with Coroutines |
| `WKWebView` | `WebView` |

### Key Differences

1. **State Management**: `@Published` → `StateFlow`
2. **UI**: SwiftUI → Jetpack Compose
3. **DI**: Property wrappers → Hilt annotations
4. **Networking**: URLSession → Retrofit
5. **Storage**: UserDefaults → DataStore, CoreData → Room

---

## 🎯 Implementation Status

### ✅ Phase 1: Foundation (COMPLETE)
- [x] Project structure
- [x] Gradle configuration
- [x] Version catalog with all dependencies
- [x] Navigation setup
- [x] Material 3 theming
- [x] Domain models (ChatMessage, AIProvider, AIModel, Library3D)
- [x] Application class with Hilt
- [x] MainActivity with Compose
- [x] Bottom navigation
- [x] Theme (Color, Type, Theme)

### 🚧 Phase 2: AI Integration (IN PROGRESS)
- [ ] TogetherAiService implementation
- [ ] OpenAiService implementation
- [ ] AnthropicService implementation
- [ ] ChatRepository
- [ ] ChatViewModel
- [ ] Streaming responses with Flow
- [ ] Message persistence with Room
- [ ] Chat UI (message list, input field)
- [ ] Markdown rendering

### 📋 Phase 3-10 (PLANNED)
See [ANDROID_IMPLEMENTATION_PLAN.md](../ANDROID_IMPLEMENTATION_PLAN.md) for complete roadmap.

---

## 🤝 Contributing

### Code Style
- Follow [Kotlin coding conventions](https://kotlinlang.org/docs/coding-conventions.html)
- Use ktlint for formatting
- Write KDoc comments for public APIs
- Include unit tests for new features

### Git Workflow
1. Create feature branch from `main`
2. Implement changes with tests
3. Run `./gradlew ktlintFormat test`
4. Submit PR with description

---

## 📄 License

Copyright © 2024 XRAiAssistant

See LICENSE file for details.

---

## 🔗 Links

- **iOS Version**: [../XRAiAssistant/](../XRAiAssistant/)
- **Implementation Plan**: [../ANDROID_IMPLEMENTATION_PLAN.md](../ANDROID_IMPLEMENTATION_PLAN.md)
- **Together.ai API**: https://together.ai
- **OpenAI API**: https://platform.openai.com
- **Anthropic API**: https://console.anthropic.com

---

## 📞 Support

For issues, questions, or feature requests:
- Open an issue on GitHub
- Check the [Implementation Plan](../ANDROID_IMPLEMENTATION_PLAN.md)
- Review iOS implementation for reference

---

**Built with ❤️ using Kotlin, Jetpack Compose, and AI**
