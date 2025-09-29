package com.xraiassistant.domain.models

/**
 * Library3D - 3D Framework abstraction interface
 * 
 * Kotlin port of iOS Library3D protocol
 * Defines common interface for all 3D libraries (Babylon.js, Three.js, A-Frame, etc.)
 */
interface Library3D {
    val id: String
    val displayName: String
    val description: String
    val version: String
    val playgroundTemplate: String
    val codeLanguage: CodeLanguage
    val iconName: String
    val documentationURL: String
    val supportedFeatures: Set<Library3DFeature>
    val systemPrompt: String
    val defaultSceneCode: String
    val requiresBuild: Boolean
}

/**
 * Code language enum
 */
enum class CodeLanguage(val extension: String, val displayName: String) {
    JAVASCRIPT("js", "JavaScript"),
    TYPESCRIPT("tsx", "TypeScript"),
    HTML("html", "HTML")
}

/**
 * 3D Library features
 */
enum class Library3DFeature {
    WEBGL,
    WEBXR,
    VR,
    AR,
    PHYSICS,
    ANIMATION,
    LIGHTING,
    MATERIALS,
    POST_PROCESSING,
    NODE_EDITOR,
    IMPERATIVE,
    DECLARATIVE
}

/**
 * BabylonJS Library Implementation
 */
class BabylonJSLibrary : Library3D {
    override val id = "babylonjs"
    override val displayName = "Babylon.js"
    override val description = "Professional WebGL 3D engine with advanced features"
    override val version = "v8.22.3"
    override val playgroundTemplate = "playground-babylonjs.html"
    override val codeLanguage = CodeLanguage.JAVASCRIPT
    override val iconName = "cube_fill"
    override val documentationURL = "https://doc.babylonjs.com/"
    override val requiresBuild = false
    
    override val supportedFeatures = setOf(
        Library3DFeature.WEBGL, Library3DFeature.WEBXR, Library3DFeature.VR, 
        Library3DFeature.AR, Library3DFeature.PHYSICS, Library3DFeature.ANIMATION,
        Library3DFeature.LIGHTING, Library3DFeature.MATERIALS, Library3DFeature.POST_PROCESSING,
        Library3DFeature.NODE_EDITOR, Library3DFeature.IMPERATIVE
    )
    
    override val systemPrompt = """
        You are an expert Babylon.js assistant helping users create 3D scenes and learn Babylon.js.
        You are a **creative Babylon.js mentor** who helps users bring 3D ideas to life in the Playground.  
        Your role is not just technical but also **artistic**: you suggest imaginative variations, playful enhancements, and visually interesting touches — while always delivering **fully working Babylon.js v8+ code**
        
        When users ask you ANYTHING about creating 3D scenes, objects, animations, or Babylon.js, ALWAYS respond with:
        1. A brief explanation of what you're creating
        2. The complete working code wrapped in [INSERT_CODE]```javascript
code here
```[/INSERT_CODE]
        3. A brief explanation of key features
        4. Automatically add [RUN_SCENE] at the end to run the code
        
        IMPORTANT Code Guidelines:
        - Always provide COMPLETE working code that creates a scene
        - Your code must follow this exact structure:
        
        const createScene = () => {
            const scene = new BABYLON.Scene(engine);
            
            // Camera
            const camera = new BABYLON.FreeCamera("camera1", new BABYLON.Vector3(0, 5, -10), scene);
            camera.setTarget(BABYLON.Vector3.Zero());
            
            // Attach camera controls safely
            if (camera.attachControls) {
                camera.attachControls(canvas, true);
            }
            
            // Light
            const light = new BABYLON.HemisphericLight("light1", new BABYLON.Vector3(0, 1, 0), scene);
            light.intensity = 0.7;
            
            // Your 3D objects here
            
            console.log("Scene created successfully");
            
            return scene;
        };

        const scene = createScene();
        
        CRITICAL RULES:
        - DO NOT create new canvas or engine objects
        - DO NOT use document.createElement("canvas")  
        - DO NOT use new BABYLON.Engine() 
        - DO NOT use engine.runRenderLoop() 
        - DO NOT create incomplete code
        - The canvas and engine variables are already available globally
        - Just use the existing 'canvas' and 'engine' variables
        
        - Use modern Babylon.js API (v8+)
        - Always include camera, lighting, and at least one mesh
        - Always use 'const' or 'let' for variable declarations
        - End with 'const scene = createScene();' line
        - Add console.log statements to help with debugging
        
        Special commands you MUST use:
        - To insert code, wrap it in: [INSERT_CODE]```javascript
code here
```[/INSERT_CODE]
        - To run the scene, use: [RUN_SCENE]
        
        ALWAYS generate code for ANY 3D-related request. Be proactive and creative with 3D scenes!
    """.trimIndent()
    
    override val defaultSceneCode = """
        // Welcome to Babylon.js Playground!
        // Create your 3D scene using JavaScript

        const createScene = () => {
            // Create scene
            const scene = new BABYLON.Scene(engine);
            
            // Create camera
            const camera = new BABYLON.FreeCamera("camera1", new BABYLON.Vector3(0, 5, -10), scene);
            camera.setTarget(BABYLON.Vector3.Zero());
            
            // Attach camera controls - modern API
            if (camera.attachControls) {
                camera.attachControls(canvas, true);
            } else if (scene.actionManager) {
                scene.actionManager = new BABYLON.ActionManager(scene);
            }
            
            // Create light
            const light = new BABYLON.HemisphericLight("light1", new BABYLON.Vector3(0, 1, 0), scene);
            light.intensity = 0.7;
            
            // Create sphere
            const sphere = BABYLON.MeshBuilder.CreateSphere("sphere", {diameter: 2}, scene);
            sphere.position.y = 1;
            
            // Create ground
            const ground = BABYLON.MeshBuilder.CreateGround("ground", {width: 6, height: 6}, scene);
            
            console.log("Scene created with camera:", !!camera, "light:", !!light);
            
            return scene;
        };

        // Execute the scene creation
        const scene = createScene();
    """.trimIndent()
}

/**
 * ThreeJS Library Implementation
 */
class ThreeJSLibrary : Library3D {
    override val id = "threejs"
    override val displayName = "Three.js"
    override val description = "Popular, lightweight 3D library with large community"
    override val version = "r171"
    override val playgroundTemplate = "playground-threejs.html"
    override val codeLanguage = CodeLanguage.JAVASCRIPT
    override val iconName = "scribble_variable"
    override val documentationURL = "https://threejs.org/docs/"
    override val requiresBuild = false
    
    override val supportedFeatures = setOf(
        Library3DFeature.WEBGL, Library3DFeature.WEBXR, Library3DFeature.VR,
        Library3DFeature.AR, Library3DFeature.ANIMATION, Library3DFeature.LIGHTING,
        Library3DFeature.MATERIALS, Library3DFeature.POST_PROCESSING, Library3DFeature.IMPERATIVE
    )
    
    override val systemPrompt = """
        You are an expert Three.js assistant helping users create 3D scenes and learn Three.js.
        You are a **creative Three.js mentor** who helps users bring 3D ideas to life in the Playground.
        Your role is not just technical but also **artistic**: you suggest imaginative variations, 
        playful enhancements, and visually interesting touches — while always delivering 
        **fully working Three.js r171+ code**
        
        When users ask you ANYTHING about creating 3D scenes, objects, animations, or Three.js, ALWAYS respond with:
        1. A brief explanation of what you're creating
        2. The complete working code wrapped in [INSERT_CODE]```javascript
code here
```[/INSERT_CODE]
        3. A brief explanation of key features  
        4. Automatically add [RUN_SCENE] at the end to run the code
        
        Special commands you MUST use:
        - To insert code, wrap it in: [INSERT_CODE]```javascript
code here
```[/INSERT_CODE]
        - To run the scene, use: [RUN_SCENE]
        
        ALWAYS generate code for ANY 3D-related request. Make Three.js accessible and fun!
    """.trimIndent()
    
    override val defaultSceneCode = """
        // Welcome to Three.js Playground!
        // Create your 3D scene using Three.js r171+

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
            
            // Set up controls
            controls.target.set(0, 0, 0);
            controls.update();
            
            console.log("Scene created with camera:", !!camera, "objects:", scene.children.length);
            
            return { scene, camera };
        };

        // Execute the scene creation
        const { scene, camera } = createScene();
    """.trimIndent()
}

/**
 * React Three Fiber Library Implementation
 */
class ReactThreeFiberLibrary : Library3D {
    override val id = "reactThreeFiber"
    override val displayName = "React Three Fiber"
    override val description = "React renderer for Three.js with declarative components"
    override val version = "8.17.10"
    override val playgroundTemplate = "playground-react-three-fiber.html"
    override val codeLanguage = CodeLanguage.TYPESCRIPT
    override val iconName = "cube_transparent"
    override val documentationURL = "https://docs.pmnd.rs/react-three-fiber"
    override val requiresBuild = true
    
    override val supportedFeatures = setOf(
        Library3DFeature.WEBGL, Library3DFeature.WEBXR, Library3DFeature.VR,
        Library3DFeature.AR, Library3DFeature.ANIMATION, Library3DFeature.LIGHTING,
        Library3DFeature.MATERIALS, Library3DFeature.POST_PROCESSING, Library3DFeature.DECLARATIVE
    )
    
    override val systemPrompt = """
        You are an expert React Three Fiber assistant helping users create 3D scenes with React components.
        You are a **creative React Three Fiber mentor** who helps users bring 3D ideas to life using declarative React patterns.
        Your role is not just technical but also **artistic**: you suggest imaginative variations, 
        playful enhancements, and visually interesting touches — while always delivering 
        **fully working React Three Fiber code with TypeScript**
        
        Special commands you MUST use:
        - To insert code, wrap it in: [INSERT_CODE]```typescript
code here
```[/INSERT_CODE]
        - To build and run, use: [BUILD_AND_RUN]
        
        ALWAYS generate TSX code for ANY 3D-related request. Make React Three Fiber accessible and fun!
    """.trimIndent()
    
    override val defaultSceneCode = """
        // Welcome to React Three Fiber!
        // Create declarative 3D scenes with React components

        import React, { useRef } from 'react'
        import { createRoot } from 'react-dom/client'
        import { Canvas, useFrame } from '@react-three/fiber'
        import { OrbitControls } from '@react-three/drei'
        import * as THREE from 'three'

        function RotatingCube() {
          const meshRef = useRef<THREE.Mesh>(null!)
          
          useFrame((state, delta) => {
            meshRef.current.rotation.x += delta * 0.5
            meshRef.current.rotation.y += delta * 0.2
          })
          
          return (
            <mesh ref={meshRef} position={[0, 1, 0]}>
              <boxGeometry args={[1, 1, 1]} />
              <meshStandardMaterial color="hotpink" />
            </mesh>
          )
        }

        function Scene() {
          return (
            <>
              <ambientLight intensity={0.6} />
              <directionalLight position={[2, 2, 2]} intensity={1} />
              
              <RotatingCube />
              
              {/* Ground plane */}
              <mesh rotation={[-Math.PI / 2, 0, 0]} position={[0, -0.5, 0]}>
                <planeGeometry args={[10, 10]} />
                <meshStandardMaterial color="#888888" />
              </mesh>
              
              <OrbitControls />
            </>
          )
        }

        function App() {
          return (
            <Canvas 
              style={{ width: '100%', height: '100%' }}
              camera={{ position: [3, 3, 3], fov: 75 }}
              gl={{ antialias: true }}
            >
              <Scene />
            </Canvas>
          )
        }

        const root = createRoot(document.getElementById('root')!)
        root.render(<App />)
    """.trimIndent()
}