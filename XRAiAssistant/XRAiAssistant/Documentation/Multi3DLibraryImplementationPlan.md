# XRAiAssistant Multi-3D Library Implementation Plan

## 🎯 Overview

This plan details the implementation of multi-3D library support, expanding XRAiAssistant beyond Babylon.js to include Three.js and A-Frame support. Users will be able to select their preferred 3D library through a dropdown, with automatic switching of system prompts, playground environments, and default scene code.

## 🏗️ Architecture Design

### Core Components

```
XRAiAssistant Multi-3D Library System
├── 3DLibraryManager (New)
│   ├── Library definitions and metadata
│   ├── System prompt management per library
│   └── Default scene code templates
├── Dynamic Playground System (Enhanced)
│   ├── playground-babylonjs.html (existing → renamed)
│   ├── playground-threejs.html (new)
│   └── playground-aframe.html (new)
├── UI Library Selection (New)
│   ├── Library dropdown in chat interface
│   └── Library selection in settings panel
└── Enhanced ChatViewModel (Enhanced)
    ├── Library-specific system prompts
    └── Dynamic playground loading
```

### 3D Library Abstraction

```swift
// Core 3D Library Protocol
protocol Library3D {
    var id: String { get }
    var displayName: String { get }
    var description: String { get }
    var version: String { get }
    var playgroundTemplate: String { get }
    var systemPrompt: String { get }
    var defaultSceneCode: String { get }
    var codeLanguage: String { get } // "javascript", "html"
    var iconName: String { get }
}

// Library Manager
class Library3DManager: ObservableObject {
    @Published var availableLibraries: [Library3D] = []
    @Published var selectedLibrary: Library3D
    
    func getSystemPrompt(for library: Library3D) -> String
    func getDefaultCode(for library: Library3D) -> String
    func getPlaygroundHTML(for library: Library3D) -> String
}
```

## 📚 3D Library Implementations

### 1. Babylon.js (Existing → Enhanced)
```swift
struct BabylonJSLibrary: Library3D {
    let id = "babylonjs"
    let displayName = "Babylon.js"
    let description = "Professional WebGL 3D engine with advanced features"
    let version = "v6+"
    let playgroundTemplate = "playground-babylonjs.html"
    let codeLanguage = "javascript"
    let iconName = "cube.fill"
    
    var systemPrompt: String {
        // Current detailed Babylon.js prompt (enhanced)
    }
    
    var defaultSceneCode: String {
        // Current default scene code
    }
}
```

### 2. Three.js (New)
```swift
struct ThreeJSLibrary: Library3D {
    let id = "threejs"
    let displayName = "Three.js"
    let description = "Popular, lightweight 3D library with large community"
    let version = "r160+"
    let playgroundTemplate = "playground-threejs.html"
    let codeLanguage = "javascript"
    let iconName = "scribble.variable"
    
    var systemPrompt: String {
        """
        You are an expert Three.js assistant helping users create 3D scenes and learn Three.js.
        You are a **creative Three.js mentor** who helps users bring 3D ideas to life in the Playground.
        Your role is not just technical but also **artistic**: you suggest imaginative variations, 
        playful enhancements, and visually interesting touches — while always delivering 
        **fully working Three.js r160+ code**
        
        When users ask you ANYTHING about creating 3D scenes, objects, animations, or Three.js, ALWAYS respond with:
        1. A brief explanation of what you're creating
        2. The complete working code wrapped in [INSERT_CODE]```javascript\ncode here\n```[/INSERT_CODE]
        3. A brief explanation of key features  
        4. Automatically add [RUN_SCENE] at the end to run the code
        
        IMPORTANT Code Guidelines:
        - Always provide COMPLETE working code that creates a scene
        - Your code must follow this exact structure:
        
        const createScene = () => {
            // Scene
            const scene = new THREE.Scene();
            
            // Camera
            const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
            camera.position.set(0, 5, 10);
            
            // Renderer (already available as global 'renderer')
            renderer.setSize(window.innerWidth, window.innerHeight);
            
            // Lighting
            const ambientLight = new THREE.AmbientLight(0x404040, 0.6);
            scene.add(ambientLight);
            
            const directionalLight = new THREE.DirectionalLight(0xffffff, 0.8);
            directionalLight.position.set(10, 10, 5);
            scene.add(directionalLight);
            
            // Your 3D objects here
            
            // Controls (already available as global 'controls')
            controls.target.set(0, 0, 0);
            controls.update();
            
            console.log("Three.js scene created successfully");
            
            return { scene, camera };
        };

        const { scene, camera } = createScene();
        
        CRITICAL RULES:
        - DO NOT create new renderer or canvas objects
        - DO NOT use document.getElementById or create canvas elements
        - DO NOT initialize OrbitControls manually
        - The renderer, canvas, and controls are already available globally
        - Just use the existing 'renderer', 'canvas', and 'controls' variables
        - Always return { scene, camera } from createScene function
        """
    }
    
    var defaultSceneCode: String {
        """
        // Welcome to Three.js Playground!
        // Create your 3D scene using Three.js r160+

        const createScene = () => {
            // Create scene
            const scene = new THREE.Scene();
            scene.background = new THREE.Color(0x333333);
            
            // Create camera
            const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
            camera.position.set(0, 5, 10);
            
            // Lighting
            const ambientLight = new THREE.AmbientLight(0x404040, 0.6);
            scene.add(ambientLight);
            
            const directionalLight = new THREE.DirectionalLight(0xffffff, 0.8);
            directionalLight.position.set(10, 10, 5);
            scene.add(directionalLight);
            
            // Create geometry and material
            const geometry = new THREE.SphereGeometry(1, 32, 32);
            const material = new THREE.MeshPhongMaterial({ color: 0x00ff00 });
            const sphere = new THREE.Mesh(geometry, material);
            sphere.position.y = 1;
            scene.add(sphere);
            
            // Create ground
            const groundGeometry = new THREE.PlaneGeometry(10, 10);
            const groundMaterial = new THREE.MeshPhongMaterial({ color: 0x888888 });
            const ground = new THREE.Mesh(groundGeometry, groundMaterial);
            ground.rotation.x = -Math.PI / 2;
            scene.add(ground);
            
            console.log("Scene created with camera:", !!camera, "lights:", scene.children.length);
            
            return { scene, camera };
        };

        // Execute the scene creation
        const { scene, camera } = createScene();
        """
    }
}
```

### 3. A-Frame (New)
```swift
struct AFrameLibrary: Library3D {
    let id = "aframe"
    let displayName = "A-Frame"
    let description = "Web framework for building VR/AR experiences"
    let version = "v1.4+"
    let playgroundTemplate = "playground-aframe.html"
    let codeLanguage = "html"
    let iconName = "view.3d"
    
    var systemPrompt: String {
        """
        You are an expert A-Frame assistant helping users create VR/AR scenes and learn A-Frame.
        You are a **creative A-Frame mentor** who helps users bring immersive 3D/VR ideas to life.
        Your role is not just technical but also **artistic**: you suggest imaginative variations,
        interactive VR elements, and immersive experiences — while always delivering 
        **fully working A-Frame v1.4+ HTML code**
        
        When users ask you ANYTHING about creating 3D/VR scenes, objects, animations, or A-Frame, ALWAYS respond with:
        1. A brief explanation of what you're creating
        2. The complete working HTML code wrapped in [INSERT_CODE]```html\ncode here\n```[/INSERT_CODE]
        3. A brief explanation of key VR/AR features
        4. Automatically add [RUN_SCENE] at the end to run the code
        
        IMPORTANT Code Guidelines:
        - Always provide COMPLETE working HTML that creates a VR scene
        - Your code must follow this exact structure:
        
        <a-scene embedded vr-mode-ui="enabled: true" background="color: #212">
            <!-- Assets (textures, models, etc.) -->
            <a-assets>
                <!-- Define reusable assets here if needed -->
            </a-assets>
            
            <!-- Lighting -->
            <a-light type="ambient" color="#404040" intensity="0.6"></a-light>
            <a-light type="directional" position="10 10 5" color="#ffffff" intensity="0.8"></a-light>
            
            <!-- 3D Objects -->
            <a-sphere position="0 1.25 -5" radius="1.25" color="#EF2D5E"></a-sphere>
            <a-box position="-1 0.5 -3" rotation="0 45 0" color="#4CC3D9"></a-box>
            <a-cylinder position="1 0.75 -3" radius="0.5" height="1.5" color="#FFC65D"></a-cylinder>
            <a-plane position="0 0 -4" rotation="-90 0 0" width="10" height="10" color="#7BC8A4"></a-plane>
            
            <!-- Camera with controls -->
            <a-camera look-controls wasd-controls position="0 1.6 0">
                <a-cursor color="#fff"></a-cursor>
            </a-camera>
        </a-scene>
        
        CRITICAL RULES:
        - Always use <a-scene> as the root element with embedded and vr-mode-ui attributes
        - DO NOT include DOCTYPE, html, head, or body tags - just the A-Frame scene
        - Always include basic lighting (ambient + directional)
        - Always include a camera with look-controls and wasd-controls
        - Use proper A-Frame entity-component architecture
        - Include a cursor for VR interaction
        - Use semantic A-Frame primitives (a-box, a-sphere, etc.) when possible
        """
    }
    
    var defaultSceneCode: String {
        """
        <!-- Welcome to A-Frame VR Playground! -->
        <!-- Create immersive VR/AR scenes using A-Frame -->

        <a-scene embedded vr-mode-ui="enabled: true" background="color: #212">
            <!-- Assets -->
            <a-assets>
                <!-- Add textures, models, sounds here -->
            </a-assets>
            
            <!-- Lighting -->
            <a-light type="ambient" color="#404040" intensity="0.6"></a-light>
            <a-light type="directional" position="10 10 5" color="#ffffff" intensity="0.8"></a-light>
            
            <!-- 3D Objects -->
            <a-sphere 
                position="0 2 -5" 
                radius="1" 
                color="#ff6b6b"
                animation="property: rotation; to: 0 360 0; loop: true; dur: 4000">
            </a-sphere>
            
            <a-box 
                position="-2 1 -3" 
                rotation="0 45 0" 
                color="#4ecdc4"
                animation="property: position; to: -2 2 -3; direction: alternate; loop: true; dur: 2000">
            </a-box>
            
            <a-cylinder 
                position="2 1 -3" 
                radius="0.5" 
                height="2" 
                color="#ffe66d">
            </a-cylinder>
            
            <!-- Ground -->
            <a-plane 
                position="0 0 -4" 
                rotation="-90 0 0" 
                width="20" 
                height="20" 
                color="#95e1d3"
                shadow="receive: true">
            </a-plane>
            
            <!-- Interactive text -->
            <a-text 
                value="Welcome to A-Frame!" 
                position="0 3 -2" 
                align="center" 
                color="#fff"
                animation="property: rotation; to: 0 360 0; loop: true; dur: 8000">
            </a-text>
            
            <!-- VR Camera with controls -->
            <a-camera 
                look-controls 
                wasd-controls 
                position="0 1.6 3"
                animation="property: position; to: 0 1.6 8; startEvents: click; dur: 3000">
                <a-cursor 
                    color="#fff" 
                    raycaster="objects: [clickable]">
                </a-cursor>
            </a-camera>
        </a-scene>
        """
    }
}
```

## 🎨 Playground Templates

### Three.js Playground Template (`playground-threejs.html`)
Key differences from Babylon.js template:
- Three.js r160+ CDN imports
- WebGL renderer initialization
- OrbitControls setup
- Different default scene structure
- Scene/camera return pattern

### A-Frame Playground Template (`playground-aframe.html`)
Key differences:
- A-Frame v1.4+ CDN import
- HTML-based scene editor instead of JavaScript
- VR-enabled interface
- Built-in VR controls and cursor
- Real-time HTML preview

## 🖥️ UI Implementation

### Library Selection Dropdown
```swift
// In ContentView.swift - Chat Interface
Menu {
    ForEach(library3DManager.availableLibraries, id: \.id) { library in
        Button(action: {
            chatViewModel.selectedLibrary = library
        }) {
            HStack {
                Image(systemName: library.iconName)
                    .foregroundColor(.blue)
                VStack(alignment: .leading, spacing: 2) {
                    Text(library.displayName)
                        .font(.system(size: 14, weight: .medium))
                    Text(library.description)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if chatViewModel.selectedLibrary.id == library.id {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
            }
        }
    }
} label: {
    HStack {
        Image(systemName: chatViewModel.selectedLibrary.iconName)
            .foregroundColor(.blue)
        Text(chatViewModel.selectedLibrary.displayName)
            .font(.caption)
            .foregroundColor(.blue)
        Image(systemName: "chevron.down")
            .font(.caption2)
            .foregroundColor(.blue)
    }
    .padding(.horizontal, 8)
    .padding(.vertical, 4)
    .background(Color.blue.opacity(0.1))
    .cornerRadius(6)
}
```

### Settings Panel Integration
```swift
// Library selection section in settings
Section("3D Library") {
    VStack(alignment: .leading, spacing: 8) {
        Text("Choose your 3D development library")
            .font(.headline)
            .foregroundColor(.primary)
        
        Picker("3D Library", selection: $chatViewModel.selectedLibrary) {
            ForEach(library3DManager.availableLibraries, id: \.id) { library in
                HStack {
                    Image(systemName: library.iconName)
                    VStack(alignment: .leading) {
                        Text(library.displayName)
                            .font(.headline)
                        Text(library.description)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .tag(library)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}
```

## 🔄 Dynamic System Integration

### ChatViewModel Enhancements
```swift
extension ChatViewModel {
    @Published var selectedLibrary: Library3D = BabylonJSLibrary()
    @Published var library3DManager = Library3DManager()
    
    func updateSelectedLibrary(_ library: Library3D) {
        selectedLibrary = library
        
        // Update system prompt for current library
        systemPrompt = library.systemPrompt
        
        // Update welcome message
        updateWelcomeMessage(for: library)
        
        // Notify WebView to switch playground
        switchPlaygroundEnvironment(to: library)
        
        // Save preference
        UserDefaults.standard.set(library.id, forKey: "XRAiAssistant_Selected3DLibrary")
    }
    
    private func switchPlaygroundEnvironment(to library: Library3D) {
        // Signal WebView to reload with new library template
        onSwitchLibrary?(library)
    }
    
    private func updateWelcomeMessage(for library: Library3D) {
        if let welcomeIndex = messages.firstIndex(where: { !$0.isUser }) {
            let newWelcome = ChatMessage(
                id: messages[welcomeIndex].id,
                content: "Hello! I'm your \(library.displayName) assistant. I can help you create 3D scenes, explain concepts, and write code. Try asking me to create a scene or help with specific \(library.displayName) features!",
                isUser: false,
                timestamp: messages[welcomeIndex].timestamp
            )
            messages[welcomeIndex] = newWelcome
        }
    }
}
```

### WebView Coordinator Enhancements
```swift
extension WebViewCoordinator {
    func switchLibraryEnvironment(to library: Library3D) {
        // Load appropriate playground HTML based on library
        let playgroundHTML = loadPlaygroundHTML(for: library.playgroundTemplate)
        webView?.loadHTMLString(playgroundHTML, baseURL: Bundle.main.bundleURL)
        
        // Update default code in editor after playground loads
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.setDefaultCode(library.defaultSceneCode)
        }
    }
    
    private func loadPlaygroundHTML(for template: String) -> String {
        guard let path = Bundle.main.path(forResource: template.replacingOccurrences(of: ".html", with: ""), 
                                         ofType: "html"),
              let html = try? String(contentsOfFile: path) else {
            return fallbackHTML
        }
        return html
    }
}
```

## 📊 Implementation Phases

### Phase 1: Core Architecture (Week 1)
1. ✅ Create Library3D protocol and base implementations
2. ✅ Implement Library3DManager with Babylon.js integration
3. ✅ Add library selection to ChatViewModel
4. ✅ Create basic UI dropdown in chat interface

### Phase 2: Three.js Integration (Week 2) 
1. ✅ Design and implement ThreeJSLibrary
2. ✅ Create playground-threejs.html template
3. ✅ Implement Three.js system prompt with proper code patterns
4. ✅ Test Three.js scene generation and code execution

### Phase 3: A-Frame Integration (Week 3)
1. ✅ Design and implement AFrameLibrary  
2. ✅ Create playground-aframe.html template with VR support
3. ✅ Implement A-Frame system prompt with HTML patterns
4. ✅ Test A-Frame VR scene generation

### Phase 4: Dynamic Environment Switching (Week 4)
1. ✅ Implement playground template switching in WebView
2. ✅ Add smooth transitions between libraries
3. ✅ Implement default code switching
4. ✅ Test library switching workflows

### Phase 5: Polish & Testing (Week 5)
1. ✅ Add comprehensive test coverage
2. ✅ Implement settings persistence
3. ✅ Create documentation and examples
4. ✅ Performance optimization and bug fixes

## 🧪 Testing Strategy

### Unit Tests
- Library3D protocol implementations
- System prompt generation for each library  
- Default code generation and validation
- Library switching logic

### Integration Tests
- ChatViewModel library management
- WebView playground switching
- Code generation with different libraries
- Settings persistence across libraries

### UI Tests
- Library dropdown functionality
- Settings panel library selection
- Chat interface updates with library changes
- WebView playground transitions

## 📚 Documentation Requirements

### User Documentation
- **Multi-Library Setup Guide**: How to switch between libraries
- **Library Comparison**: Feature comparison and use cases
- **Migration Guide**: Moving projects between libraries
- **VR/AR Guide**: Specific A-Frame VR development guide

### Developer Documentation
- **Library3D Protocol**: How to add new 3D libraries
- **System Prompt Guidelines**: Creating effective AI prompts per library
- **Playground Template Guide**: Creating new playground environments
- **Testing Guidelines**: Testing multi-library functionality

## 🎯 Success Criteria

### Functional Requirements ✅
- Users can select between Babylon.js, Three.js, and A-Frame
- System prompts automatically adapt to selected library
- Playground environment switches seamlessly
- Default scene code updates per library
- Settings persist across app restarts

### Performance Requirements ✅  
- Library switching completes within 2 seconds
- No memory leaks during environment transitions
- Responsive UI during library changes
- Efficient HTML template loading

### User Experience Requirements ✅
- Intuitive library selection interface
- Clear visual indicators of current library
- Smooth transitions without jarring changes
- Helpful error messages for library-specific issues
- Consistent chat experience across libraries

## 🚀 Future Enhancements

### Additional Libraries
- **React Three Fiber** - React-based Three.js framework
- **PlayCanvas** - Web-first 3D engine  
- **X3DOM** - Declarative 3D in HTML
- **Godot Web** - Godot engine for web

### Advanced Features
- **Library-specific Templates** - Starter projects per library
- **Cross-Library Migration** - Convert scenes between libraries
- **Performance Benchmarking** - Compare library performance  
- **Custom Library Support** - Allow users to add their own libraries

This comprehensive plan provides a roadmap for implementing robust multi-3D library support while maintaining the intuitive user experience that makes XRAiAssistant special.