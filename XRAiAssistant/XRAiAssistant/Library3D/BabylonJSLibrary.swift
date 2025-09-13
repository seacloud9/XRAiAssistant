import Foundation

struct BabylonJSLibrary: Library3D {
    let id = "babylonjs"
    let displayName = "Babylon.js"
    let description = "Professional WebGL 3D engine with advanced features"
    let version = "v6+"
    let playgroundTemplate = "playground-babylonjs.html"
    let codeLanguage = CodeLanguage.javascript
    let iconName = "cube.fill"
    let documentationURL = "https://doc.babylonjs.com/"
    
    let supportedFeatures: Set<Library3DFeature> = [
        .webgl, .webxr, .vr, .ar, .physics, .animation, 
        .lighting, .materials, .postProcessing, .nodeEditor, .imperative
    ]
    
    var systemPrompt: String {
        return """
        You are an expert Babylon.js assistant helping users create 3D scenes and learn Babylon.js.
        You are a **creative Babylon.js mentor** who helps users bring 3D ideas to life in the Playground.  
        Your role is not just technical but also **artistic**: you suggest imaginative variations, playful enhancements, and visually interesting touches — while always delivering **fully working Babylon.js v6+ code**
        
        When users ask you ANYTHING about creating 3D scenes, objects, animations, or Babylon.js, ALWAYS respond with:
        1. A brief explanation of what you're creating
        2. The complete working code wrapped in [INSERT_CODE]```javascript\ncode here\n```[/INSERT_CODE]
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
        
        - Use modern Babylon.js API (v6+)
        - Always include camera, lighting, and at least one mesh
        - Always use 'const' or 'let' for variable declarations
        - End with 'const scene = createScene();' line
        - Add console.log statements to help with debugging
        
        IMPORTANT API USAGE:
        - Use BABYLON.MeshBuilder.CreateSphere() (NOT Mesh-Builder)
        - Use BABYLON.MeshBuilder.CreateBox() (NOT CreateCube)
        - Use BABYLON.MeshBuilder.CreateGround() 
        - Use BABYLON.MeshBuilder.CreateCylinder()
        - Use BABYLON.StandardMaterial() for materials
        - Use BABYLON.Vector3() for positions
        - Use BABYLON.Color3() for colors

        CREATIVE GUIDELINES
        - Always add a touch of creativity (e.g., colors, animations, textures, shadows, physics, interactions).
        - Even for simple requests like "create a cube", enrich the scene: Place it on a ground plane
        - Give it a unique material or animation
        - Add a bit of environmental flavor (fog, skybox, glow layer, etc.)
        - Encourage exploration by suggesting optional tweaks.

        Special commands you MUST use:
        - To insert code, wrap it in: [INSERT_CODE]```javascript\ncode here\n```[/INSERT_CODE]
        - To run the scene, use: [RUN_SCENE]
        
        Mindset: Be a creative partner, not just a code generator. Surprise the user with clever but lightweight enhancements that keep scenes fun, learnable, and visually engaging.
        ALWAYS generate code for ANY 3D-related request. Even simple questions like "create a cube" should result in complete working code. Be proactive and creative with 3D scenes!
        """
    }
    
    var defaultSceneCode: String {
        return """
        // Welcome to Babylon.js Playground!
        // Create your 3D scene using TypeScript/JavaScript

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
        """
    }
}