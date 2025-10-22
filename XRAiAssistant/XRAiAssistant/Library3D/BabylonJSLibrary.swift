import Foundation

struct BabylonJSLibrary: Library3D {
    let id = "babylonjs"
    let displayName = "Babylon.js"
    let description = "Professional WebGL 3D engine with advanced features"
    let version = "v8.22.3"
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
        
        - Use modern Babylon.js API (v8+)
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

        🚨 CRITICAL COLOR3 RULES:
        - ALWAYS use constructor syntax: new BABYLON.Color3(r, g, b)
        - NEVER use static properties: Color3.Red(), Color3.Orange(), Color3.Green(), etc.
        - NEVER use static properties without parentheses: Color3.Red, Color3.Orange, etc.
        - RGB values are in range 0.0 to 1.0 (NOT 0-255)

        Common Color3 RGB Values (USE THESE):
        - Red: new BABYLON.Color3(1, 0, 0)
        - Orange: new BABYLON.Color3(1, 0.5, 0)
        - Yellow: new BABYLON.Color3(1, 1, 0)
        - Green: new BABYLON.Color3(0, 1, 0)
        - Blue: new BABYLON.Color3(0, 0, 1)
        - Purple: new BABYLON.Color3(0.5, 0, 1)
        - White: new BABYLON.Color3(1, 1, 1)
        - Black: new BABYLON.Color3(0, 0, 0)
        - Gray: new BABYLON.Color3(0.5, 0.5, 0.5)

        Examples:
        ✅ material.diffuseColor = new BABYLON.Color3(1, 0.5, 0); // Orange
        ✅ light.diffuse = new BABYLON.Color3(1, 1, 1); // White
        ❌ material.diffuseColor = BABYLON.Color3.Orange(); // WRONG
        ❌ material.diffuseColor = Color3.Orange; // WRONG

        POSTPROCESSING EFFECTS:
        Babylon.js supports powerful postprocessing effects that are applied to the camera. Available effects:

        1. GlowLayer (Bloom Effect):
        const gl = new BABYLON.GlowLayer("glow", scene);
        gl.intensity = 1.0; // Adjust glow intensity
        // Use with emissive materials for best results:
        material.emissiveColor = new BABYLON.Color3(1, 0.2, 0.2);

        2. BlurPostProcess (Depth of Field):
        const horizontalBlur = new BABYLON.BlurPostProcess(
            "HorizontalBlur",
            new BABYLON.Vector3(1.0, 0),  // Direction (horizontal)
            10,                            // Kernel size (blur intensity)
            1.0,                           // Sampling ratio
            camera                         // Attach to camera
        );

        3. BlackAndWhitePostProcess:
        const bwPostProcess = new BABYLON.BlackAndWhitePostProcess("bandw", 1.0, camera);

        4. Other Available PostProcesses:
        - BABYLON.FxaaPostProcess (anti-aliasing)
        - BABYLON.VolumetricLightScatteringPostProcess
        - BABYLON.HighlightsPostProcess
        - BABYLON.ImageProcessingPostProcess (tone mapping, vignette, color grading)

        CREATIVE GUIDELINES
        - Always add a touch of creativity (e.g., colors, animations, textures, shadows, physics, interactions).
        - Even for simple requests like "create a cube", enrich the scene: Place it on a ground plane
        - Give it a unique material or animation
        - Add a bit of environmental flavor (fog, skybox, glow layer, postprocessing effects, etc.)
        - Encourage exploration by suggesting optional tweaks.
        - When users ask for "effects" or "glowing objects", use GlowLayer or emissive materials
        - When users ask for "blur" or "depth of field", use BlurPostProcess
        - When users ask for "black and white" or "grayscale", use BlackAndWhitePostProcess

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

    var examples: [CodeExample] {
        return [
            // BASIC EXAMPLES
            CodeExample(
                title: "Floating Crystal Gems",
                description: "Beautiful rotating gems with metallic materials and soft glow",
                code: """
                const createScene = () => {
                    const scene = new BABYLON.Scene(engine);
                    scene.clearColor = new BABYLON.Color3(0.02, 0.02, 0.05);

                    const camera = new BABYLON.ArcRotateCamera("camera1", -Math.PI / 2, Math.PI / 3, 12, new BABYLON.Vector3(0, 0, 0), scene);
                    if (camera.attachControls) {
                        camera.attachControls(canvas, true);
                    }

                    const light = new BABYLON.HemisphericLight("light1", new BABYLON.Vector3(0, 1, 0), scene);
                    light.intensity = 0.8;

                    // Add glow layer
                    const gl = new BABYLON.GlowLayer("glow", scene);
                    gl.intensity = 0.5;

                    // Create three floating crystals
                    const colors = [
                        new BABYLON.Color3(1, 0.2, 0.6),  // Pink
                        new BABYLON.Color3(0.2, 0.6, 1),  // Blue
                        new BABYLON.Color3(1, 0.8, 0.2)   // Gold
                    ];

                    for (let i = 0; i < 3; i++) {
                        const crystal = BABYLON.MeshBuilder.CreatePolyhedron("crystal" + i, {type: 1, size: 1.2}, scene);
                        crystal.position.x = (i - 1) * 3;
                        crystal.position.y = 1;

                        const material = new BABYLON.PBRMaterial("mat" + i, scene);
                        material.albedoColor = colors[i];
                        material.metallic = 0.9;
                        material.roughness = 0.1;
                        material.emissiveColor = colors[i];
                        material.emissiveIntensity = 0.3;
                        crystal.material = material;

                        // Floating animation
                        const startY = crystal.position.y;
                        scene.registerBeforeRender(() => {
                            crystal.rotation.y += 0.005 + i * 0.003;
                            crystal.position.y = startY + Math.sin(Date.now() * 0.001 + i) * 0.3;
                        });
                    }

                    const ground = BABYLON.MeshBuilder.CreateGround("ground", {width: 15, height: 15}, scene);
                    const groundMat = new BABYLON.StandardMaterial("groundMat", scene);
                    groundMat.diffuseColor = new BABYLON.Color3(0.1, 0.1, 0.15);
                    groundMat.specularColor = new BABYLON.Color3(0.3, 0.3, 0.3);
                    ground.material = groundMat;

                    return scene;
                };
                const scene = createScene();
                """,
                category: .basic,
                difficulty: .beginner
            ),

            CodeExample(
                title: "Sphere with Physics",
                description: "Bouncing sphere with gravity using Babylon.js physics engine",
                code: """
                const createScene = () => {
                    const scene = new BABYLON.Scene(engine);
                    const camera = new BABYLON.FreeCamera("camera1", new BABYLON.Vector3(0, 5, -10), scene);
                    camera.setTarget(BABYLON.Vector3.Zero());
                    if (camera.attachControls) {
                        camera.attachControls(canvas, true);
                    }

                    const light = new BABYLON.HemisphericLight("light1", new BABYLON.Vector3(0, 1, 0), scene);
                    light.intensity = 0.7;

                    // Enable physics
                    const gravityVector = new BABYLON.Vector3(0, -9.81, 0);
                    scene.enablePhysics(gravityVector, new BABYLON.CannonJSPlugin());

                    // Create sphere with physics
                    const sphere = BABYLON.MeshBuilder.CreateSphere("sphere", {diameter: 2}, scene);
                    sphere.position.y = 5;
                    sphere.physicsImpostor = new BABYLON.PhysicsImpostor(sphere, BABYLON.PhysicsImpostor.SphereImpostor, {mass: 1, restitution: 0.9}, scene);

                    const material = new BABYLON.StandardMaterial("sphereMat", scene);
                    material.diffuseColor = new BABYLON.Color3(0, 0.5, 1);
                    sphere.material = material;

                    // Ground with physics
                    const ground = BABYLON.MeshBuilder.CreateGround("ground", {width: 10, height: 10}, scene);
                    ground.physicsImpostor = new BABYLON.PhysicsImpostor(ground, BABYLON.PhysicsImpostor.BoxImpostor, {mass: 0, restitution: 0.9}, scene);

                    return scene;
                };
                const scene = createScene();
                """,
                category: .physics,
                difficulty: .intermediate
            ),

            // ANIMATION EXAMPLES
            CodeExample(
                title: "Animated Path Following",
                description: "Object following a curved path with smooth animation",
                code: """
                const createScene = () => {
                    const scene = new BABYLON.Scene(engine);
                    const camera = new BABYLON.ArcRotateCamera("camera1", -Math.PI / 2, Math.PI / 2.5, 15, new BABYLON.Vector3(0, 0, 0), scene);
                    if (camera.attachControls) {
                        camera.attachControls(canvas, true);
                    }

                    const light = new BABYLON.HemisphericLight("light1", new BABYLON.Vector3(0, 1, 0), scene);

                    // Create a path
                    const path = [];
                    for (let i = 0; i < 60; i++) {
                        path.push(new BABYLON.Vector3(5 * Math.cos(i * 0.1), 0, 5 * Math.sin(i * 0.1)));
                    }

                    // Create tube along path
                    const tube = BABYLON.MeshBuilder.CreateTube("tube", {path: path, radius: 0.1}, scene);

                    // Create moving sphere
                    const sphere = BABYLON.MeshBuilder.CreateSphere("sphere", {diameter: 1}, scene);
                    const material = new BABYLON.StandardMaterial("mat", scene);
                    material.diffuseColor = new BABYLON.Color3(1, 0, 0);
                    sphere.material = material;

                    // Animation
                    let alpha = 0;
                    scene.registerBeforeRender(() => {
                        alpha += 0.02;
                        const index = Math.floor(alpha) % path.length;
                        sphere.position = path[index];
                    });

                    return scene;
                };
                const scene = createScene();
                """,
                category: .animation,
                difficulty: .intermediate
            ),

            // LIGHTING EXAMPLES
            CodeExample(
                title: "Dynamic Lighting Scene",
                description: "Multiple colored lights creating dramatic atmosphere",
                code: """
                const createScene = () => {
                    const scene = new BABYLON.Scene(engine);
                    scene.clearColor = new BABYLON.Color3(0.1, 0.1, 0.2);

                    const camera = new BABYLON.ArcRotateCamera("camera1", -Math.PI / 2, Math.PI / 2.5, 10, new BABYLON.Vector3(0, 0, 0), scene);
                    if (camera.attachControls) {
                        camera.attachControls(canvas, true);
                    }

                    // Create multiple point lights
                    const light1 = new BABYLON.PointLight("light1", new BABYLON.Vector3(3, 3, 0), scene);
                    light1.diffuse = new BABYLON.Color3(1, 0, 0);
                    light1.intensity = 0.5;

                    const light2 = new BABYLON.PointLight("light2", new BABYLON.Vector3(-3, 3, 0), scene);
                    light2.diffuse = new BABYLON.Color3(0, 1, 0);
                    light2.intensity = 0.5;

                    const light3 = new BABYLON.PointLight("light3", new BABYLON.Vector3(0, 3, 3), scene);
                    light3.diffuse = new BABYLON.Color3(0, 0, 1);
                    light3.intensity = 0.5;

                    // Center object
                    const box = BABYLON.MeshBuilder.CreateBox("box", {size: 2}, scene);
                    const material = new BABYLON.StandardMaterial("mat", scene);
                    material.specularColor = new BABYLON.Color3(1, 1, 1);
                    box.material = material;

                    // Animate lights
                    let time = 0;
                    scene.registerBeforeRender(() => {
                        time += 0.01;
                        light1.position.x = 3 * Math.cos(time);
                        light1.position.z = 3 * Math.sin(time);
                        light2.position.x = 3 * Math.cos(time + 2.09);
                        light2.position.z = 3 * Math.sin(time + 2.09);
                        light3.position.x = 3 * Math.cos(time + 4.18);
                        light3.position.z = 3 * Math.sin(time + 4.18);
                    });

                    return scene;
                };
                const scene = createScene();
                """,
                category: .lighting,
                difficulty: .intermediate
            ),

            // MATERIALS EXAMPLES
            CodeExample(
                title: "PBR Materials Showcase",
                description: "Physically based rendering with metallic and roughness properties",
                code: """
                const createScene = () => {
                    const scene = new BABYLON.Scene(engine);
                    const camera = new BABYLON.ArcRotateCamera("camera1", -Math.PI / 2, Math.PI / 2.5, 15, new BABYLON.Vector3(0, 0, 0), scene);
                    if (camera.attachControls) {
                        camera.attachControls(canvas, true);
                    }

                    const light = new BABYLON.HemisphericLight("light1", new BABYLON.Vector3(0, 1, 0), scene);
                    light.intensity = 1.0;

                    // Create spheres with different materials
                    for (let i = 0; i < 5; i++) {
                        const sphere = BABYLON.MeshBuilder.CreateSphere("sphere" + i, {diameter: 2}, scene);
                        sphere.position.x = (i - 2) * 3;

                        const material = new BABYLON.PBRMaterial("pbr" + i, scene);
                        material.albedoColor = new BABYLON.Color3(1, 0.5, 0);
                        material.metallic = i / 4; // Varying metallic
                        material.roughness = 0.3;
                        sphere.material = material;
                    }

                    const ground = BABYLON.MeshBuilder.CreateGround("ground", {width: 20, height: 10}, scene);
                    const groundMat = new BABYLON.StandardMaterial("groundMat", scene);
                    groundMat.diffuseColor = new BABYLON.Color3(0.3, 0.3, 0.3);
                    ground.material = groundMat;

                    return scene;
                };
                const scene = createScene();
                """,
                category: .materials,
                difficulty: .intermediate
            ),

            // EFFECTS EXAMPLES
            CodeExample(
                title: "Glow Effect (Bloom)",
                description: "Glowing objects with bloom post-processing effect",
                code: """
                const createScene = () => {
                    const scene = new BABYLON.Scene(engine);
                    scene.clearColor = new BABYLON.Color3(0, 0, 0);

                    const camera = new BABYLON.FreeCamera("camera1", new BABYLON.Vector3(0, 5, -10), scene);
                    camera.setTarget(BABYLON.Vector3.Zero());
                    if (camera.attachControls) {
                        camera.attachControls(canvas, true);
                    }

                    const light = new BABYLON.HemisphericLight("light1", new BABYLON.Vector3(0, 1, 0), scene);
                    light.intensity = 0.3;

                    // Create glow layer
                    const gl = new BABYLON.GlowLayer("glow", scene);
                    gl.intensity = 1.0;

                    // Create glowing sphere
                    const sphere = BABYLON.MeshBuilder.CreateSphere("sphere", {diameter: 2}, scene);
                    sphere.position.y = 1;

                    const material = new BABYLON.StandardMaterial("mat", scene);
                    material.emissiveColor = new BABYLON.Color3(0, 1, 1);
                    material.diffuseColor = new BABYLON.Color3(0, 0.3, 0.3);
                    sphere.material = material;

                    // Animated rotation
                    scene.registerBeforeRender(() => {
                        sphere.rotation.y += 0.01;
                    });

                    const ground = BABYLON.MeshBuilder.CreateGround("ground", {width: 6, height: 6}, scene);

                    return scene;
                };
                const scene = createScene();
                """,
                category: .effects,
                difficulty: .intermediate
            ),

            // INTERACTION EXAMPLE
            CodeExample(
                title: "Click Interaction",
                description: "Interactive objects that respond to mouse clicks",
                code: """
                const createScene = () => {
                    const scene = new BABYLON.Scene(engine);
                    const camera = new BABYLON.FreeCamera("camera1", new BABYLON.Vector3(0, 5, -10), scene);
                    camera.setTarget(BABYLON.Vector3.Zero());
                    if (camera.attachControls) {
                        camera.attachControls(canvas, true);
                    }

                    const light = new BABYLON.HemisphericLight("light1", new BABYLON.Vector3(0, 1, 0), scene);

                    // Create boxes
                    const colors = [
                        new BABYLON.Color3(1, 0, 0),
                        new BABYLON.Color3(0, 1, 0),
                        new BABYLON.Color3(0, 0, 1)
                    ];

                    for (let i = 0; i < 3; i++) {
                        const box = BABYLON.MeshBuilder.CreateBox("box" + i, {size: 1.5}, scene);
                        box.position.x = (i - 1) * 3;
                        box.position.y = 1;

                        const material = new BABYLON.StandardMaterial("mat" + i, scene);
                        material.diffuseColor = colors[i];
                        box.material = material;

                        // Add click interaction
                        box.actionManager = new BABYLON.ActionManager(scene);
                        box.actionManager.registerAction(
                            new BABYLON.ExecuteCodeAction(
                                BABYLON.ActionManager.OnPickTrigger,
                                function() {
                                    box.scaling = box.scaling.x === 1 ? new BABYLON.Vector3(1.5, 1.5, 1.5) : new BABYLON.Vector3(1, 1, 1);
                                }
                            )
                        );
                    }

                    const ground = BABYLON.MeshBuilder.CreateGround("ground", {width: 10, height: 10}, scene);

                    return scene;
                };
                const scene = createScene();
                """,
                category: .interaction,
                difficulty: .intermediate
            ),

            // ADVANCED EXAMPLE
            CodeExample(
                title: "Holographic Torus Array",
                description: "Mesmerizing array of torus meshes with holographic glow and wave animation",
                code: """
                const createScene = () => {
                    const scene = new BABYLON.Scene(engine);
                    scene.clearColor = new BABYLON.Color3(0, 0.02, 0.08);

                    const camera = new BABYLON.ArcRotateCamera("camera1", 0, Math.PI / 3, 20, new BABYLON.Vector3(0, 0, 0), scene);
                    camera.lowerRadiusLimit = 10;
                    camera.upperRadiusLimit = 40;
                    if (camera.attachControls) {
                        camera.attachControls(canvas, true);
                    }

                    const light = new BABYLON.HemisphericLight("light1", new BABYLON.Vector3(0, 1, 0), scene);
                    light.intensity = 0.4;

                    // Create intense glow layer
                    const gl = new BABYLON.GlowLayer("glow", scene);
                    gl.intensity = 1.5;

                    // Create array of torus meshes
                    const count = 8;
                    const toruses = [];

                    for (let i = 0; i < count; i++) {
                        const torus = BABYLON.MeshBuilder.CreateTorus("torus" + i, {
                            diameter: 3,
                            thickness: 0.5,
                            tessellation: 64
                        }, scene);

                        torus.position.z = (i - count / 2) * 2;

                        // Create rainbow gradient material
                        const hue = (i / count) * 360;
                        const r = Math.abs(Math.sin((hue) * Math.PI / 180));
                        const g = Math.abs(Math.sin((hue + 120) * Math.PI / 180));
                        const b = Math.abs(Math.sin((hue + 240) * Math.PI / 180));

                        const material = new BABYLON.PBRMaterial("mat" + i, scene);
                        material.albedoColor = new BABYLON.Color3(r, g, b);
                        material.metallic = 0.95;
                        material.roughness = 0.05;
                        material.emissiveColor = new BABYLON.Color3(r * 0.8, g * 0.8, b * 0.8);
                        material.emissiveIntensity = 0.8;
                        torus.material = material;

                        toruses.push(torus);
                    }

                    // Wave animation
                    let time = 0;
                    scene.registerBeforeRender(() => {
                        time += 0.016;

                        // Auto-rotate camera
                        camera.alpha += 0.002;

                        toruses.forEach((torus, i) => {
                            const offset = (i / count) * Math.PI * 2;

                            // Wave motion
                            torus.position.y = Math.sin(time + offset) * 2.5;

                            // Rotation
                            torus.rotation.x = time * 0.3;
                            torus.rotation.z = time * 0.2;

                            // Pulsing scale
                            const scale = 1 + Math.sin(time + offset) * 0.15;
                            torus.scaling = new BABYLON.Vector3(scale, scale, scale);
                        });
                    });

                    return scene;
                };
                const scene = createScene();
                """,
                category: .advanced,
                difficulty: .advanced
            )
        ]
    }
}