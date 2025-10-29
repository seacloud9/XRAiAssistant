# 🚀 XRAiAssistant Android - Quick Start Guide

> **Get the Android app running in 5 minutes!**

This guide gets you from zero to a running Android app as fast as possible.

---

## ⚡ 5-Minute Setup

### Step 1: Open in Android Studio (1 min)

```bash
cd /Users/brendonsmith/exp/XRAiAssistant/XRAiAssistantAndroid
open -a "Android Studio" .
```

**Wait for**:
- ✅ Gradle sync to complete
- ✅ Dependencies to download (~200MB)
- ✅ Indexing to finish

### Step 2: Build the Project (2 min)

In Android Studio:
1. Click **Build → Make Project** (or `⌘ + F9`)
2. Wait for build to succeed
3. Check no errors in **Build** panel

### Step 3: Run on Device (2 min)

1. **Connect Android device** OR **launch emulator**
   - Physical device: Enable USB debugging
   - Emulator: Use AVD Manager (Pixel 6 with API 34 recommended)

2. Click **Run → Run 'app'** (or `^ + R`)

3. **App launches** → You should see:
   - Bottom navigation with 5 tabs
   - "Code" screen as default (placeholder)
   - Material 3 themed UI (purple gradient)

---

## 🎯 What You'll See

### Home Screen (Chat/Code)
```
┌─────────────────────────────────┐
│       🤖 XRAiAssistant          │  ← Top bar
├─────────────────────────────────┤
│                                 │
│    Chat Screen - Coming Soon    │  ← Placeholder
│                                 │
│                                 │
├─────────────────────────────────┤
│ 💬 Code │ ▶️ Scene │ ⚙️ | 📚 | ⏱ │  ← Bottom nav
└─────────────────────────────────┘
```

### Features Working Now
- ✅ **Navigation** - Tap tabs to switch screens
- ✅ **Settings Modal** - Tap ⚙️ to open (placeholder)
- ✅ **Examples Modal** - Tap 📚 to open (placeholder)
- ✅ **Theme** - Material 3 with light/dark mode support
- ✅ **Smooth Animations** - Screen transitions

### Features Coming in Phase 2
- 🚧 AI chat integration
- 🚧 Message history
- 🚧 Code generation
- 🚧 3D scene rendering
- 🚧 CodeSandbox deployment

---

## 🐛 Quick Troubleshooting

### "Gradle sync failed"
```bash
# Clean and retry
./gradlew clean
# In Android Studio: File → Invalidate Caches / Restart
```

### "Java version incompatible"
- Ensure **JDK 17+** is installed
- Android Studio → Preferences → Build Tools → Gradle
- Set "Gradle JDK" to 17 or higher

### "SDK not found"
- Android Studio → Preferences → Appearance & Behavior → System Settings → Android SDK
- Install **Android 14.0 (API 34)** and **Build Tools 34.0.0**

### "App crashes on launch"
- Check **Logcat** panel in Android Studio
- Look for `FATAL EXCEPTION` or `AndroidRuntime`
- Verify `AndroidManifest.xml` has correct activity declaration

---

## 📁 Project Structure at a Glance

```
XRAiAssistantAndroid/
├── app/
│   ├── src/main/java/com/xrai/assistant/
│   │   ├── XRAiApplication.kt           ← App entry point
│   │   ├── di/AppModule.kt              ← Dependency injection
│   │   ├── domain/model/                ← Core data models
│   │   │   ├── ChatMessage.kt
│   │   │   ├── AIProvider.kt
│   │   │   ├── AIModel.kt
│   │   │   └── Library3D.kt
│   │   └── presentation/
│   │       ├── MainActivity.kt          ← Main activity
│   │       ├── navigation/NavGraph.kt   ← Navigation setup
│   │       └── theme/                   ← Material 3 theme
│   ├── build.gradle.kts                 ← App dependencies
│   └── src/main/AndroidManifest.xml     ← App configuration
├── gradle/libs.versions.toml            ← Version catalog
├── build.gradle.kts                     ← Root build config
└── settings.gradle.kts                  ← Project settings
```

---

## 📚 Next Steps

### Phase 2: AI Integration (Start Here!)

1. **Read the plan**: [ANDROID_IMPLEMENTATION_PLAN.md](ANDROID_IMPLEMENTATION_PLAN.md#phase-2-ai-integration-week-3-4)

2. **Create data layer**:
   ```
   app/src/main/java/com/xrai/assistant/data/
   ├── remote/
   │   ├── TogetherAiService.kt       ← Retrofit service
   │   ├── OpenAiService.kt
   │   └── dto/                       ← API request/response models
   └── repository/
       └── ChatRepositoryImpl.kt      ← Repository implementation
   ```

3. **Implement ChatViewModel**:
   ```kotlin
   @HiltViewModel
   class ChatViewModel @Inject constructor(
       private val chatRepository: ChatRepository
   ) : ViewModel() {
       val messages = chatRepository.getMessages()
           .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

       fun sendMessage(text: String) {
           viewModelScope.launch {
               chatRepository.sendMessage(text).collect { response ->
                   // Handle streaming AI response
               }
           }
       }
   }
   ```

4. **Build Chat UI**:
   ```kotlin
   @Composable
   fun ChatScreen(viewModel: ChatViewModel = hiltViewModel()) {
       val messages by viewModel.messages.collectAsState()

       LazyColumn {
           items(messages) { message ->
               MessageItem(message)
           }
       }

       ChatInput(onSend = { viewModel.sendMessage(it) })
   }
   ```

---

## 🔗 Useful Links

- **Full Implementation Plan**: [ANDROID_IMPLEMENTATION_PLAN.md](ANDROID_IMPLEMENTATION_PLAN.md)
- **Android README**: [XRAiAssistantAndroid/ANDROID_README.md](XRAiAssistantAndroid/ANDROID_README.md)
- **Setup Complete Summary**: [XRAiAssistantAndroid/ANDROID_SETUP_COMPLETE.md](XRAiAssistantAndroid/ANDROID_SETUP_COMPLETE.md)
- **iOS Reference**: [XRAiAssistant/](XRAiAssistant/)

---

## ✅ Checklist: Did It Work?

- [ ] Android Studio opened project without errors
- [ ] Gradle sync completed successfully
- [ ] Project builds (no compilation errors)
- [ ] App runs on device/emulator
- [ ] Bottom navigation shows 5 tabs
- [ ] Can navigate between tabs
- [ ] Settings modal opens when tapping ⚙️
- [ ] Examples modal opens when tapping 📚

**All checked?** → **Phase 1 Complete! 🎉**

**Not working?** → Check [Troubleshooting](#-quick-troubleshooting) or open an issue.

---

**Next**: [Start Phase 2 - AI Integration](ANDROID_IMPLEMENTATION_PLAN.md#phase-2-ai-integration-week-3-4) 🚀
