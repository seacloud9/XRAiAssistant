# XRAiAssistant Station

**🔒 LOCAL DEVELOPMENT ONLY - DO NOT DEPLOY TO PRODUCTION**

**AI-powered Extended Reality development platform for local web development**

A NextJS web application that brings the power of XRAiAssistant to your local browser for development and prototyping. Features AI-assisted 3D development, multi-library support, and localStorage persistence.

## ⚠️ SECURITY WARNING - LOCALHOST ONLY

**🚫 THIS APPLICATION IS NOT DESIGNED FOR PRODUCTION DEPLOYMENT**

- **API Key Storage**: Uses localStorage which exposes keys in production
- **Local Development Only**: Designed exclusively for `http://localhost:3000`
- **Security Risk**: Public deployment would expose all users' API keys
- **Use Case**: Local XR prototyping and development environment only

## 🚀 Features

### 🤖 **Multi-Provider AI Integration**
- **Together.ai** (Primary) - DeepSeek R1 70B, Llama 3.3 70B, Qwen models  
- **OpenAI** - GPT-4o and other models
- **Anthropic** - Claude 3.5 Sonnet
- Dual-parameter control (Temperature + Top-p) with intelligent descriptions
- Real-time streaming responses

### 🎯 **3D Library Support**
- **Babylon.js v8.22.3** - Professional WebGL engine
- **Three.js r171** - Popular lightweight 3D library  
- **React Three Fiber 8.17.10** - Declarative React renderer
- Automatic framework switching with specialized AI prompts
- Live code execution in sandboxed iframe

### 🛠️ **Professional Development Environment**
- **Monaco Editor** - Full IntelliSense and syntax highlighting
- **Split-view interface** - Code editor + 3D scene preview
- **Real-time execution** - See your changes instantly
- **Code management** - Upload, download, and template system
- **Error handling** - Comprehensive error display and debugging

### 📱 **Progressive Web App**
- **Offline capable** - Works without internet connection
- **Installable** - Add to home screen on mobile/desktop
- **localStorage persistence** - All settings and code saved locally
- **Responsive design** - Optimized for all screen sizes
- **Service worker caching** - Fast loading and offline support

### 🔐 **Privacy & Security**
- **Local storage only** - No data sent to external servers (except AI APIs)
- **Encrypted API keys** - Secure storage of credentials
- **Sandboxed execution** - Safe code execution environment
- **No telemetry** - Complete privacy protection

## 🏗️ Architecture

### **Tech Stack**
- **Next.js 14** - React framework with App Router
- **TypeScript** - Type-safe development
- **Tailwind CSS** - Utility-first styling
- **Zustand** - Lightweight state management
- **Monaco Editor** - Professional code editing
- **React Hot Toast** - Beautiful notifications

### **AI Integration**
```typescript
// Multi-provider AI service with streaming support
class AIService {
  async generateResponse(prompt: string, options: {
    provider: string    // 'together' | 'openai' | 'anthropic'
    model: string      // Model-specific ID
    apiKey: string     // User-provided API key
    temperature: number // 0.0-2.0 creativity control
    topP: number       // 0.1-1.0 vocabulary diversity
  }): Promise<AIResponse>
  
  async generateStreamingResponse(
    prompt: string,
    options: AIOptions,
    onChunk: (chunk: StreamingResponse) => void
  ): Promise<void>
}
```

### **Library3D System**
```typescript
interface Library3D {
  id: string           // 'babylonjs' | 'threejs' | 'react-three-fiber'
  name: string         // Human-readable name
  version: string      // Library version
  description: string  // Feature description
  cdnUrls: string[]   // CDN resources to load
  systemPrompt: string // AI instructions for this library
  codeTemplate: string // Starting template code
}
```

### **State Management**
```typescript
// Zustand store with localStorage persistence
const useAppStore = create<AppState>()(
  persist(
    (set, get) => ({
      // Chat state
      messages: ChatMessage[]
      addMessage: (message) => void
      
      // Code state  
      currentCode: string
      setCurrentCode: (code) => void
      
      // Settings state
      settings: AppSettings
      updateSettings: (settings) => void
      
      // Library state
      libraries: Library3D[]
      getCurrentLibrary: () => Library3D
      
      // AI provider state
      providers: AIProvider[]
      getCurrentProvider: () => AIProvider
    }),
    { name: 'xrai-assistant-storage' }
  )
)
```

## 🛠️ Getting Started

### **Prerequisites**
- **Node.js 20+** - JavaScript runtime (minimum version 20.0.0)
- **pnpm 8+** - Package manager (preferred over npm)
- **Modern browser** - Chrome, Firefox, Safari, Edge

### **Installation**
```bash
# Clone repository
git clone <repository-url>
cd XrAiAssistantStation

# Install dependencies with pnpm
pnpm install

# Start LOCAL development server
pnpm run dev
```

### **First Setup (LOCAL DEVELOPMENT)**
1. **Open browser** to `http://localhost:3000` (LOCALHOST ONLY)
2. **Configure API keys** in Settings (replace "changeMe"):
   - **Together.ai**: Get free key at [together.ai](https://together.ai)
   - **OpenAI**: Get key at [platform.openai.com](https://platform.openai.com) 
   - **Anthropic**: Get key at [console.anthropic.com](https://console.anthropic.com)
3. **Select 3D library** (Babylon.js recommended for beginners)
4. **Choose AI model** (DeepSeek R1 70B is free and powerful)

**🔒 LOCAL STORAGE SECURITY**: API keys stored in browser localStorage - secure for local development only!

### **First 3D Scene**
1. **Go to Chat tab** and ask: *"Create a spinning cube with rainbow colors"*
2. **AI generates code** automatically using your selected library
3. **Click "Send to Playground"** to open the code editor
4. **Click "Run"** to see your AI-created 3D scene!

## 📁 Project Structure

```
XrAiAssistantStation/
├── src/
│   ├── app/                    # Next.js App Router
│   │   ├── layout.tsx         # Root layout with PWA config
│   │   ├── page.tsx           # Main application page
│   │   └── globals.css        # Global styles
│   ├── components/
│   │   ├── chat/              # AI conversation interface
│   │   │   ├── chat-interface.tsx    # Main chat UI
│   │   │   └── chat-message.tsx      # Message display
│   │   ├── playground/        # 3D development environment
│   │   │   ├── playground-view.tsx   # Split-view layout
│   │   │   ├── code-editor.tsx       # Monaco editor wrapper
│   │   │   └── scene-renderer.tsx    # 3D scene iframe
│   │   ├── settings/          # Configuration panel
│   │   │   └── settings-panel.tsx    # Settings modal
│   │   ├── layout/            # Navigation components
│   │   │   ├── header.tsx            # Top header
│   │   │   └── bottom-navigation.tsx # Tab navigation
│   │   └── theme-provider.tsx # Dark/light mode
│   ├── lib/
│   │   ├── ai-service.ts      # Multi-provider AI client
│   │   └── utils.ts           # Helper functions
│   └── store/
│       └── app-store.ts       # Zustand state management
├── public/
│   ├── manifest.json          # PWA manifest
│   ├── sw.js                  # Service worker
│   └── icons/                 # App icons
├── package.json               # Dependencies and scripts
├── tailwind.config.js         # Tailwind CSS configuration
├── next.config.js             # Next.js + PWA configuration
└── tsconfig.json              # TypeScript configuration
```

## 🎯 Usage Examples

### **Creating 3D Scenes**
```typescript
// Ask AI natural language questions:
"Create a spinning cube with rainbow colors"
"Make a solar system with orbiting planets" 
"Build a particle system with floating spheres"
"Generate a procedural landscape with trees"

// AI automatically:
// 1. Understands your request
// 2. Generates appropriate code for your selected library
// 3. Includes proper lighting, cameras, and materials
// 4. Provides working, executable code
```

### **Debugging & Learning**
```typescript
// Ask for help with existing code:
"Why isn't my mesh rotating?"
"How do I add physics to this scene?"
"Explain what this lighting setup does"
"Optimize this code for better performance"

// AI provides:
// 1. Detailed explanations
// 2. Code corrections
// 3. Best practices
// 4. Performance tips
```

### **Framework Switching**
```typescript
// Switch between libraries seamlessly:
// 1. Change library in Settings
// 2. Ask AI to "convert this to Three.js"
// 3. AI adapts code to new framework
// 4. Maintains same functionality

// Supported conversions:
// Babylon.js ↔ Three.js ↔ React Three Fiber
```

## ⚙️ Configuration

### **AI Parameters**
- **Temperature (0.0-2.0)**: Controls creativity vs precision
  - `0.0-0.3`: Focused, deterministic (debugging)
  - `0.4-0.8`: Balanced creativity (general use)
  - `0.9-2.0`: Experimental, creative (exploration)

- **Top-p (0.1-1.0)**: Controls vocabulary diversity
  - `0.1-0.5`: Precise vocabulary (technical code)
  - `0.6-0.9`: Balanced vocabulary (most use cases)
  - `0.9-1.0`: Full vocabulary (creative scenarios)

### **3D Libraries**
- **Babylon.js**: Best for complex 3D applications, WebXR, physics
- **Three.js**: Lightweight, popular, extensive community
- **React Three Fiber**: Declarative React patterns, component-based

### **Storage**
All data persists in browser localStorage:
- API keys (encrypted)
- Chat history
- Code snippets
- User preferences
- Library settings

## 🚀 Local Development Only

### **Build for Local Testing**
```bash
# Create optimized build for LOCAL testing only
pnpm run build

# Start production server LOCALLY
pnpm run start

# ⚠️ DO NOT DEPLOY - FOR LOCAL TESTING ONLY
```

### **🚫 NO PRODUCTION DEPLOYMENT**
**This application is NOT suitable for public deployment:**
- **Security Risk**: API keys exposed in client-side code
- **localStorage Vulnerability**: Keys accessible to all site visitors
- **Local Development Only**: Designed exclusively for localhost usage

### **Local PWA Installation**
1. **Desktop**: Chrome → Install app icon in address bar
2. **Mobile**: Add to Home Screen from browser menu  
3. **Local Offline**: Works offline once installed (localhost only)

### **🔒 For Production Deployment Consider:**
- **Server-side API key management**
- **OAuth authentication flows**
- **Environment variable configuration**
- **Secure API proxy implementation**

## 🤝 Contributing

We welcome contributions to make XRAiAssistant Station even better!

### **Areas for Contribution**
- **Additional 3D libraries** (A-Frame, Playcanvas, etc.)
- **AI provider integrations** (Google Gemini, Cohere, etc.)
- **UI/UX improvements** (animations, accessibility)
- **Performance optimizations** (caching, lazy loading)
- **Documentation** (tutorials, examples)

### **Development Setup**
```bash
# Fork repository
# Clone your fork
git clone https://github.com/yourusername/XRAiAssistant.git
cd XrAiAssistantStation

# Install dependencies
npm install

# Start development
npm run dev

# Run type checking
npm run type-check

# Run linting
npm run lint
```

## 📄 License

See LICENSE file for details.

---

## **XRAiAssistant Station: The Future of Web-Based XR Development**

**From idea to immersive experience in your browser.**

XRAiAssistant Station democratizes 3D development by making it as simple as having a conversation. Whether you're learning WebGL, prototyping XR experiences, or building professional applications, our AI-powered platform provides the tools and guidance you need.

**Start creating amazing 3D experiences today - no installation required, just open your browser and begin!** 🚀