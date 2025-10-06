# Building XRAiAssistant, Part 3: Local Development Meets Universal Platform Vision

*Published: September 29, 2025 | By: Brendon Smith*

---

## Expanding Beyond iOS: The Web Platform Arrives

If you missed the previous posts, catch up here:
- [Part 1: The Future of AI-Powered 3D Development on iOS](blog-part-1)
- [Part 2: Multi-Provider AI meets Multi-Framework XR on iOS](blog-part-2)

What started as an iOS-first vision has evolved into something bigger. XRAiAssistant Station - our NextJS web implementation - brings complete iOS feature parity to local development environments with ambitious plans for universal platform deployment.

## What's inside this release

XRAiAssistant Station delivers a sophisticated local development environment that matches the iOS app feature-for-feature while introducing new capabilities for collaboration and deployment.

**🔒 Local Development Focus**: Built for `localhost:3000` with security-first architecture
**🌐 Universal Platform Foundation**: Alpha support for Android and web deployment
**📦 CodeSandbox Integration**: One-click deployment for React Three Fiber and React scenes
**⚛️ React Three Fiber Ready**: Full support with hot reload and component composition

## Quick links to the tech we use

- **Source**: [XRAiAssistant on GitHub](https://github.com/seacloud9/XRAiAssistant)
- **NextJS Station**: `XrAiAssistantStation/` directory
- **CodeSandbox**: [Define API](https://codesandbox.io/docs/learn/sandboxes/cli-api) • [Sandpack](https://sandpack.codesandbox.io/)
- **React Three Fiber**: [Docs](https://docs.pmnd.rs/react-three-fiber) • [Drei](https://github.com/pmndrs/drei)

## Recap from Part 2

We built multi-provider AI integration (Together.ai, OpenAI, Anthropic) with multi-framework XR support (Babylon.js, Three.js, A-Frame) all powered by SwiftUI and WKWebView on iOS. Professional parameter control, settings persistence, and streaming responses created a mobile-first XR development experience.

## What's new in Part 3

### XRAiAssistant Station: NextJS Feature Parity

The web implementation delivers complete iOS functionality with web-native advantages:

```typescript
// Complete feature parity with localStorage persistence
export const useAppStore = create<AppState>()(
  persist(
    (set, get) => ({
      // All iOS features implemented
      settings: AppSettings,      // API keys, models, parameters
      messages: ChatMessage[],    // Complete chat history
      currentCode: string,        // Active playground code
      libraries: Library3D[],     // Babylon.js, Three.js, R3F
      providers: AIProvider[],    // Together.ai, OpenAI, Anthropic
    }),
    { name: 'xrai-assistant-storage' }
  )
)
```

**Local Development Architecture**:
- **Security-first**: API keys in localStorage (safe for localhost only)
- **Privacy-focused**: Complete offline operation after initial setup
- **Development-optimized**: Hot reload, TypeScript, and professional debugging

### CodeSandbox Integration: From Local to Live

React Three Fiber scenes can now deploy directly to CodeSandbox with zero configuration:

```typescript
// One-click deployment to CodeSandbox
const deployToSandbox = async (code: string, library: Library3D) => {
  if (library.id === 'react-three-fiber') {
    const sandbox = await createSandbox({
      files: {
        'App.js': { code },
        'package.json': {
          code: JSON.stringify({
            dependencies: {
              '@react-three/fiber': '^8.17.10',
              '@react-three/drei': '^9.109.0',
              'react': '^18.2.0',
              'three': '^0.171.0'
            }
          })
        }
      },
      template: 'create-react-app'
    })
    
    // Return live URL for sharing
    return `https://codesandbox.io/s/${sandbox.id}`
  }
}
```

**CodeSandbox Benefits**:
- **Instant sharing**: Generated scenes become live, shareable URLs
- **Collaborative editing**: Team members can fork and improve
- **Portfolio integration**: Embed live demos in Medium, docs, or portfolios
- **Version control**: Automatic GitHub integration for larger projects

### Alpha Platform Support: Android and Web

While XRAiAssistant Station is designed for local development, we're exploring broader platform deployment:

**🤖 Android Alpha**:
- React Native wrapper around web components
- Native WebView integration for Babylon.js scenes
- SharedPreferences for settings persistence
- **Limitation**: Still requires localhost development server

**🌐 Web Alpha**:
- Static site generation for portfolio deployment
- **Critical limitation**: API keys exposed in client-side code
- **Security warning**: Not suitable for production without proxy architecture
- **Use case**: Demo sites and educational content only

## Local Development: Strengths and Honest Limitations

### Why localhost-only makes sense

**🔒 Security Reality**:
```typescript
// This is why we can't deploy publicly yet
const apiKey = localStorage.getItem('together-api-key') // ❌ Exposed to all users
const validation = validateApiKey(apiKey, 'together')   // ❌ Client-side validation only

// For production, we'd need:
const response = await fetch('/api/ai-proxy', {         // ✅ Server-side proxy
  headers: { 'Authorization': `Bearer ${serverApiKey}` } // ✅ Hidden from client
})
```

**Current architecture strengths**:
- **Rapid prototyping**: Zero deployment friction for development
- **Privacy-first**: All processing happens locally
- **Cost-effective**: No server infrastructure required
- **Educational**: Perfect for learning XR development patterns

**Honest limitations**:
- **Localhost dependency**: Requires local development server
- **API key exposure**: Client-side storage unsuitable for production
- **Collaboration barriers**: No built-in real-time collaborative editing
- **Deployment complexity**: Additional steps needed for public sharing

### The opportunity and contribution pitch

This architecture creates unique opportunities for the community:

**🚀 Immediate opportunities**:
- **Educational platforms**: Perfect for XR development courses
- **Rapid prototyping**: Fastest XR iteration cycle available
- **Framework learning**: Safe environment to experiment with Babylon.js, Three.js, R3F
- **AI exploration**: Test different models and parameters without cost pressure

**🤝 Community contribution areas**:

```typescript
// Help us build the production architecture
interface ProductionContributions {
  serverProxy: {
    description: "API key proxy with rate limiting"
    technologies: ["Node.js", "Vercel", "Railway"]
    impact: "Enable public deployment"
  }
  
  authentication: {
    description: "OAuth flows for secure API key management"  
    technologies: ["Auth0", "Clerk", "Supabase"]
    impact: "User account system with secure storage"
  }
  
  collaboration: {
    description: "Real-time collaborative editing"
    technologies: ["Socket.io", "Yjs", "Liveblocks"]
    impact: "Multi-user XR scene development"
  }
  
  deployment: {
    description: "One-click hosting with security"
    technologies: ["Vercel", "Netlify", "Docker"]
    impact: "Safe public scene sharing"
  }
}
```

## Technical deep dive: Architecture decisions

### Multi-framework template system

Each framework gets specialized AI prompting and execution environment:

```typescript
// Framework-specific AI enhancement
const enhancePromptForFramework = (userRequest: string, library: Library3D) => {
  let prompt = `${library.systemPrompt}\n\nUser request: ${userRequest}`
  
  // Add framework-specific context
  switch (library.id) {
    case 'react-three-fiber':
      prompt += `\n\nGenerate JSX components with hooks and proper React patterns.`
      prompt += `\nUse @react-three/drei helpers when appropriate.`
      prompt += `\nInclude useState and useFrame for animations.`
      break
      
    case 'babylonjs':
      prompt += `\n\nUse BABYLON namespace and modern v8+ APIs.`
      prompt += `\nInclude proper scene, camera, and lighting setup.`
      prompt += `\nOptimize for WebXR compatibility.`
      break
  }
  
  return prompt
}
```

### Streaming AI with localStorage persistence

Real-time responses save automatically as they stream:

```typescript
// Streaming with automatic persistence
await aiService.generateStreamingResponse(prompt, options, (chunk) => {
  if (!chunk.done) {
    streamedContent += chunk.content
    
    // Update UI and localStorage in real-time
    const updatedMessages = [...useAppStore.getState().messages]
    const lastMessage = updatedMessages[updatedMessages.length - 1]
    lastMessage.content = streamedContent
    lastMessage.hasCode = extractCodeFromMessage(streamedContent) !== null
    
    useAppStore.setState({ messages: updatedMessages }) // Auto-persists
  }
})
```

## CodeSandbox integration: Technical implementation

### React Three Fiber deployment pipeline

```typescript
// Automated CodeSandbox deployment for R3F scenes
class CodeSandboxDeployer {
  async deployR3FScene(code: string): Promise<string> {
    const files = {
      'src/App.js': {
        code: this.wrapR3FComponent(code)
      },
      'src/index.js': {
        code: `
import React from 'react'
import ReactDOM from 'react-dom'
import App from './App'

ReactDOM.render(<App />, document.getElementById('root'))
        `
      },
      'package.json': {
        code: JSON.stringify({
          name: 'xraiassistant-scene',
          dependencies: {
            '@react-three/fiber': '^8.17.10',
            '@react-three/drei': '^9.109.0',
            'react': '^18.2.0',
            'react-dom': '^18.2.0',
            'three': '^0.171.0'
          }
        })
      }
    }
    
    const sandbox = await this.createSandbox(files)
    return `https://codesandbox.io/s/${sandbox.id}`
  }
  
  private wrapR3FComponent(userCode: string): string {
    return `
import React from 'react'
import { Canvas } from '@react-three/fiber'
import { OrbitControls } from '@react-three/drei'

${userCode}

export default function App() {
  return (
    <Canvas camera={{ position: [0, 0, 5] }}>
      <ambientLight intensity={0.5} />
      <pointLight position={[10, 10, 10]} />
      <Scene />
      <OrbitControls />
    </Canvas>
  )
}
    `
  }
}
```

### Embedding and sharing workflow

Generated CodeSandbox URLs can be embedded anywhere:

```html
<!-- Embed in Medium, docs, or portfolio -->
<iframe src="https://codesandbox.io/embed/xraiassistant-scene-abc123" 
        width="100%" height="500px"></iframe>

<!-- Or use Sandpack for live editing -->
<SandpackProvider>
  <SandpackCodeEditor />
  <SandpackPreview />
</SandpackProvider>
```

## Platform expansion: Android and web alpha

### Android native wrapper

```kotlin
// Android WebView integration (alpha)
class XRAiAssistantActivity : AppCompatActivity() {
    private lateinit var webView: WebView
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        webView = WebView(this).apply {
            settings.javaScriptEnabled = true
            settings.domStorageEnabled = true
            
            // Load localhost development server
            loadUrl("http://localhost:3000")
        }
    }
}
```

**Android limitations**:
- Requires local development server running
- No native settings integration yet
- WebView-dependent for all 3D rendering

### Web static deployment considerations

```typescript
// Static generation with API key warnings
export async function getStaticProps() {
  return {
    props: {
      warning: "This demo uses placeholder API keys. For full functionality, run locally."
    }
  }
}

// Client-side API key replacement for demos
const DemoMode = () => (
  <div className="bg-yellow-50 p-4 rounded-lg">
    <h3>⚠️ Demo Mode</h3>
    <p>This is a static demo. For full AI functionality:</p>
    <ol>
      <li>Clone the repository</li>
      <li>Run <code>pnpm install && pnpm dev</code></li>
      <li>Configure your API keys at localhost:3000</li>
    </ol>
  </div>
)
```

## Development commands and setup

### Getting started with XRAiAssistant Station

```bash
# Clone and setup (requires Node.js 20+, pnpm 8+)
git clone https://github.com/seacloud9/XRAiAssistant.git
cd XRAiAssistant/XrAiAssistantStation

# Install dependencies
pnpm install

# Start local development (localhost:3000 only)
pnpm dev

# Build for local testing
pnpm build && pnpm start
```

### API key configuration

1. **Together.ai** (free models): Get key at [together.ai](https://together.ai)
2. **OpenAI**: Get key at [platform.openai.com](https://platform.openai.com)
3. **Anthropic**: Get key at [console.anthropic.com](https://console.anthropic.com)

Replace "changeMe" defaults in Settings → API Keys

### CodeSandbox deployment

```bash
# Deploy current R3F scene to CodeSandbox
# (Available in UI for react-three-fiber library only)
1. Generate R3F scene with AI
2. Click "Deploy to CodeSandbox" button
3. Share the returned live URL
```

## Why this architecture matters for XR development

### Educational and prototyping advantages

**🎓 Perfect for learning**:
- Zero deployment complexity - just code and see results
- Safe environment to experiment with expensive AI models
- Framework comparison side-by-side
- Real-time feedback without cost pressure

**🚀 Rapid prototyping workflow**:
```
Idea → AI prompt → Generated code → Live preview → CodeSandbox share
    ↑                                                              ↓
    └────────────── Iterate with team feedback ←──────────────────┘
```

### Professional development pipeline

**Local development** (XRAiAssistant Station) → **Collaboration** (CodeSandbox) → **Production** (Custom deployment)

This three-stage pipeline separates concerns:
1. **Private ideation**: API keys and experimentation stay local
2. **Team collaboration**: Share working demos without infrastructure
3. **Production deployment**: Custom architecture with proper security

## Contributing to the future

### High-impact contribution opportunities

**🔧 Infrastructure contributions**:
```typescript
// Help build production-ready architecture
const contributionAreas = [
  {
    name: "API Proxy Server",
    impact: "Enable public deployment",
    skills: ["Node.js", "Edge Functions", "Rate Limiting"],
    difficulty: "Medium",
    timeframe: "2-4 weeks"
  },
  {
    name: "Real-time Collaboration", 
    impact: "Multi-user scene editing",
    skills: ["WebRTC", "Yjs", "Socket.io"],
    difficulty: "High",
    timeframe: "6-8 weeks"
  },
  {
    name: "Mobile App Packaging",
    impact: "True native apps",
    skills: ["React Native", "Expo", "Native Modules"],
    difficulty: "Medium",
    timeframe: "4-6 weeks"
  }
]
```

**🎨 Feature contributions**:
- Additional 3D frameworks (PlayCanvas, A-Frame extensions)
- AI provider integrations (Google Gemini, Cohere)
- Deployment targets (Vercel, Netlify, custom hosting)
- UI/UX improvements (accessibility, mobile optimization)

### Community building

**📚 Documentation needs**:
- Tutorial series for each framework
- AI prompting best practices for 3D
- Performance optimization guides
- Deployment architecture patterns

**🎯 Example projects**:
- Educational XR experiences
- AR business card generators
- VR gallery templates
- WebXR game prototypes

## What's next: The production vision

### Secure deployment architecture

```typescript
// Future production-ready architecture
interface ProductionDeployment {
  proxy: {
    description: "Server-side API key management"
    implementation: "Vercel Edge Functions + KV storage"
    security: "Rate limiting, usage tracking, key rotation"
  }
  
  collaboration: {
    description: "Real-time multi-user editing"
    implementation: "Yjs + WebRTC data channels"
    features: "Cursor tracking, voice chat, version history"
  }
  
  deployment: {
    description: "One-click secure hosting"
    implementation: "GitHub integration + automated SSL"
    targets: "Custom domains, CDN optimization, analytics"
  }
}
```

### Universal platform support

**Mobile apps**: React Native wrappers with native performance
**Desktop**: Electron packaging with offline capabilities  
**Web**: Progressive Web App with service worker caching
**XR devices**: Direct WebXR deployment for Quest, HoloLens, Apple Vision Pro

## Try it today

### For rapid prototyping
```bash
cd XRAiAssistant/XrAiAssistantStation
pnpm install && pnpm dev
# Open localhost:3000, configure API keys, start creating
```

### For collaboration
1. Generate scenes locally
2. Deploy R3F scenes to CodeSandbox
3. Share live URLs with team
4. Iterate and fork as needed

### For contribution
1. Fork the repository
2. Pick a contribution area
3. Join our Discord for coordination
4. Build the future of XR development

## Conclusion: Local development as a launchpad

XRAiAssistant Station proves that localhost development can be the foundation for universal platform ambitions. By starting with security, privacy, and developer experience, we're building toward a future where XR development is:

- **Accessible**: Free to start, scalable to enterprise
- **Collaborative**: Real-time editing without infrastructure complexity
- **Secure**: Production-ready deployment with proper API key management
- **Universal**: Same codebase, multiple deployment targets

The limitations are honest - API key exposure, localhost dependency, collaboration barriers. But they're also opportunities for the community to build solutions that benefit everyone.

**This is just the beginning.** The future of AI-powered XR development is collaborative, secure, and universally accessible. Help us build it.

---

### Links and resources

- **XRAiAssistant**: [GitHub Repository](https://github.com/seacloud9/XRAiAssistant)
- **Documentation**: [Setup guides and API reference](docs/)
- **CodeSandbox**: [Define API](https://codesandbox.io/docs/learn/sandboxes/cli-api) • [Sandpack](https://sandpack.codesandbox.io/)
- **React Three Fiber**: [Docs](https://docs.pmnd.rs/react-three-fiber) • [Drei](https://github.com/pmndrs/drei)
- **Community**: [Discord](discord-link) • [Discussions](github-discussions)

### Tags

**Core platform**: #XRAiAssistant, #NextJS, #LocalDevelopment, #WebXR, #MobileFirst, #UniversalPlatform

**Frameworks**: #BabylonJS, #ThreeJS, #ReactThreeFiber, #R3F, #AFrame

**AI and deployment**: #TogetherAI, #OpenAI, #Anthropic, #CodeSandbox, #Sandpack, #LiveDemo

**Architecture**: #TypeScript, #Zustand, #LocalStorage, #SecurityFirst, #PrivacyFirst

**Platforms**: #iOS, #Android, #Web, #PWA, #ReactNative, #CrossPlatform

---

*Ready to build the future of XR development? Start locally, deploy globally, contribute universally. 🚀*