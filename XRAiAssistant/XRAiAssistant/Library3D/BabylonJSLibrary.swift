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
                difficulty: .beginner,
                keywords: ["glow", "pbr", "metallic", "animation", "floating", "polyhedron", "crystal"],
                aiPromptHints: "Use PBRMaterial for realistic metallic surfaces with emissive glow. Add GlowLayer for neon effects. Animate with registerBeforeRender and Math.sin for smooth floating motion."
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
            ),

            CodeExample(
                title: "Particle Fountain",
                description: "Colorful particle system creating a fountain effect",
                code: """
                const createScene = () => {
                    const scene = new BABYLON.Scene(engine);
                    scene.clearColor = new BABYLON.Color3(0.05, 0.05, 0.15);

                    const camera = new BABYLON.ArcRotateCamera("camera1", -Math.PI / 2, Math.PI / 3, 15, new BABYLON.Vector3(0, 0, 0), scene);
                    if (camera.attachControls) {
                        camera.attachControls(canvas, true);
                    }

                    const light = new BABYLON.HemisphericLight("light1", new BABYLON.Vector3(0, 1, 0), scene);
                    light.intensity = 0.6;

                    // Create particle system
                    const particleSystem = new BABYLON.ParticleSystem("particles", 2000, scene);
                    particleSystem.particleTexture = new BABYLON.Texture("https://assets.babylonjs.com/textures/flare.png", scene);

                    // Fountain emitter
                    particleSystem.emitter = new BABYLON.Vector3(0, 0, 0);
                    particleSystem.minEmitBox = new BABYLON.Vector3(-0.5, 0, -0.5);
                    particleSystem.maxEmitBox = new BABYLON.Vector3(0.5, 0, 0.5);

                    // Colors
                    particleSystem.color1 = new BABYLON.Color4(1, 0.2, 0.6, 1.0);
                    particleSystem.color2 = new BABYLON.Color4(0.2, 0.6, 1, 1.0);
                    particleSystem.colorDead = new BABYLON.Color4(0, 0, 0, 0.0);

                    // Size
                    particleSystem.minSize = 0.1;
                    particleSystem.maxSize = 0.3;

                    // Life time
                    particleSystem.minLifeTime = 1.0;
                    particleSystem.maxLifeTime = 2.0;

                    // Emission rate
                    particleSystem.emitRate = 300;

                    // Blend mode
                    particleSystem.blendMode = BABYLON.ParticleSystem.BLENDMODE_ONEONE;

                    // Gravity
                    particleSystem.gravity = new BABYLON.Vector3(0, -9.81, 0);

                    // Direction
                    particleSystem.direction1 = new BABYLON.Vector3(-1, 8, -1);
                    particleSystem.direction2 = new BABYLON.Vector3(1, 10, 1);

                    // Speed
                    particleSystem.minEmitPower = 1;
                    particleSystem.maxEmitPower = 3;
                    particleSystem.updateSpeed = 0.01;

                    particleSystem.start();

                    // Base platform
                    const base = BABYLON.MeshBuilder.CreateCylinder("base", {diameter: 3, height: 0.5}, scene);
                    base.position.y = -0.25;
                    const baseMat = new BABYLON.StandardMaterial("baseMat", scene);
                    baseMat.diffuseColor = new BABYLON.Color3(0.2, 0.2, 0.3);
                    base.material = baseMat;

                    return scene;
                };
                const scene = createScene();
                """,
                category: .effects,
                difficulty: .intermediate
            ),

            CodeExample(
                title: "Fractal Sphere Grid",
                description: "Grid of spheres with fractal-like scaling and rotation patterns",
                code: """
                const createScene = () => {
                    const scene = new BABYLON.Scene(engine);
                    scene.clearColor = new BABYLON.Color3(0.02, 0.02, 0.05);

                    const camera = new BABYLON.ArcRotateCamera("camera1", 0, Math.PI / 4, 25, new BABYLON.Vector3(0, 0, 0), scene);
                    if (camera.attachControls) {
                        camera.attachControls(canvas, true);
                    }

                    const light = new BABYLON.HemisphericLight("light1", new BABYLON.Vector3(0, 1, 0), scene);
                    light.intensity = 0.7;

                    const gl = new BABYLON.GlowLayer("glow", scene);
                    gl.intensity = 0.8;

                    // Create grid of spheres
                    const spheres = [];
                    const gridSize = 5;

                    for (let x = 0; x < gridSize; x++) {
                        for (let z = 0; z < gridSize; z++) {
                            const sphere = BABYLON.MeshBuilder.CreateSphere("sphere" + x + "_" + z, {diameter: 1}, scene);
                            sphere.position.x = (x - gridSize / 2) * 2.5;
                            sphere.position.z = (z - gridSize / 2) * 2.5;

                            // Distance from center for fractal pattern
                            const distFromCenter = Math.sqrt(Math.pow(x - gridSize / 2, 2) + Math.pow(z - gridSize / 2, 2));
                            const normalizedDist = distFromCenter / (gridSize / 2);

                            const material = new BABYLON.PBRMaterial("mat" + x + "_" + z, scene);
                            const hue = (x + z) / (gridSize * 2);
                            material.albedoColor = new BABYLON.Color3(
                                Math.abs(Math.sin(hue * Math.PI * 2)),
                                Math.abs(Math.sin((hue + 0.33) * Math.PI * 2)),
                                Math.abs(Math.sin((hue + 0.66) * Math.PI * 2))
                            );
                            material.metallic = 0.9;
                            material.roughness = 0.1;
                            material.emissiveColor = material.albedoColor;
                            material.emissiveIntensity = 0.4;
                            sphere.material = material;

                            spheres.push({mesh: sphere, dist: normalizedDist, x: x, z: z});
                        }
                    }

                    // Animation
                    scene.registerBeforeRender(() => {
                        const time = Date.now() * 0.001;

                        spheres.forEach(data => {
                            const wave = Math.sin(time + data.dist * 3);
                            data.mesh.position.y = wave * 1.5;
                            data.mesh.rotation.y = time + data.dist;
                            const scale = 0.5 + wave * 0.3;
                            data.mesh.scaling = new BABYLON.Vector3(scale, scale, scale);
                        });
                    });

                    return scene;
                };
                const scene = createScene();
                """,
                category: .advanced,
                difficulty: .advanced
            ),

            CodeExample(
                title: "Skybox with Fog",
                description: "Atmospheric scene with skybox and volumetric fog effects",
                code: """
                const createScene = () => {
                    const scene = new BABYLON.Scene(engine);

                    const camera = new BABYLON.ArcRotateCamera("camera1", -Math.PI / 2, Math.PI / 3, 20, new BABYLON.Vector3(0, 0, 0), scene);
                    if (camera.attachControls) {
                        camera.attachControls(canvas, true);
                    }

                    // Skybox
                    const skybox = BABYLON.MeshBuilder.CreateBox("skyBox", {size: 1000}, scene);
                    const skyboxMaterial = new BABYLON.StandardMaterial("skyBoxMat", scene);
                    skyboxMaterial.backFaceCulling = false;
                    skyboxMaterial.diffuseColor = new BABYLON.Color3(0, 0, 0);
                    skyboxMaterial.specularColor = new BABYLON.Color3(0, 0, 0);
                    skyboxMaterial.emissiveColor = new BABYLON.Color3(0.05, 0.05, 0.15);
                    skybox.material = skyboxMaterial;

                    // Fog
                    scene.fogMode = BABYLON.Scene.FOGMODE_EXP;
                    scene.fogDensity = 0.02;
                    scene.fogColor = new BABYLON.Color3(0.1, 0.05, 0.15);

                    const light = new BABYLON.HemisphericLight("light1", new BABYLON.Vector3(0, 1, 0), scene);
                    light.intensity = 0.5;

                    // Create floating monoliths
                    for (let i = 0; i < 8; i++) {
                        const angle = (i / 8) * Math.PI * 2;
                        const radius = 10;

                        const monolith = BABYLON.MeshBuilder.CreateBox("monolith" + i, {
                            width: 1.5,
                            height: 5,
                            depth: 1.5
                        }, scene);

                        monolith.position.x = Math.cos(angle) * radius;
                        monolith.position.z = Math.sin(angle) * radius;
                        monolith.position.y = 2.5;
                        monolith.rotation.y = -angle;

                        const material = new BABYLON.PBRMaterial("monolithMat" + i, scene);
                        material.albedoColor = new BABYLON.Color3(0.3, 0.2, 0.5);
                        material.metallic = 0.8;
                        material.roughness = 0.2;
                        material.emissiveColor = new BABYLON.Color3(0.5, 0.2, 0.8);
                        material.emissiveIntensity = 0.3;
                        monolith.material = material;
                    }

                    // Ground
                    const ground = BABYLON.MeshBuilder.CreateGround("ground", {width: 50, height: 50}, scene);
                    const groundMat = new BABYLON.StandardMaterial("groundMat", scene);
                    groundMat.diffuseColor = new BABYLON.Color3(0.1, 0.05, 0.15);
                    groundMat.specularColor = new BABYLON.Color3(0.1, 0.1, 0.1);
                    ground.material = groundMat;

                    return scene;
                };
                const scene = createScene();
                """,
                category: .effects,
                difficulty: .intermediate
            ),

            CodeExample(
                title: "Plasma Orb",
                description: "Pulsating orb with dynamic material and electric effects",
                code: """
                const createScene = () => {
                    const scene = new BABYLON.Scene(engine);
                    scene.clearColor = new BABYLON.Color3(0, 0, 0);

                    const camera = new BABYLON.ArcRotateCamera("camera1", -Math.PI / 2, Math.PI / 2.5, 8, new BABYLON.Vector3(0, 0, 0), scene);
                    if (camera.attachControls) {
                        camera.attachControls(canvas, true);
                    }

                    const light = new BABYLON.HemisphericLight("light1", new BABYLON.Vector3(0, 1, 0), scene);
                    light.intensity = 0.3;

                    const gl = new BABYLON.GlowLayer("glow", scene);
                    gl.intensity = 1.8;

                    // Main orb
                    const orb = BABYLON.MeshBuilder.CreateSphere("orb", {diameter: 3, segments: 64}, scene);
                    const orbMat = new BABYLON.PBRMaterial("orbMat", scene);
                    orbMat.albedoColor = new BABYLON.Color3(0.5, 0.1, 1);
                    orbMat.metallic = 0.95;
                    orbMat.roughness = 0.05;
                    orbMat.emissiveColor = new BABYLON.Color3(0.8, 0.2, 1);
                    orbMat.emissiveIntensity = 1.5;
                    orb.material = orbMat;

                    // Electric rings
                    const rings = [];
                    for (let i = 0; i < 3; i++) {
                        const ring = BABYLON.MeshBuilder.CreateTorus("ring" + i, {
                            diameter: 4 + i * 0.5,
                            thickness: 0.05,
                            tessellation: 64
                        }, scene);

                        const ringMat = new BABYLON.StandardMaterial("ringMat" + i, scene);
                        ringMat.emissiveColor = new BABYLON.Color3(0, 1, 1);
                        ring.material = ringMat;

                        rings.push(ring);
                    }

                    // Point lights
                    const light1 = new BABYLON.PointLight("light1", new BABYLON.Vector3(0, 0, 0), scene);
                    light1.diffuse = new BABYLON.Color3(0.8, 0.2, 1);
                    light1.intensity = 2;

                    // Animation
                    scene.registerBeforeRender(() => {
                        const time = Date.now() * 0.001;

                        // Pulsating orb
                        const scale = 1 + Math.sin(time * 2) * 0.1;
                        orb.scaling = new BABYLON.Vector3(scale, scale, scale);

                        // Rotating rings at different speeds
                        rings.forEach((ring, i) => {
                            ring.rotation.x = time * (0.5 + i * 0.2);
                            ring.rotation.y = time * (0.3 + i * 0.15);
                        });

                        // Pulsating glow
                        gl.intensity = 1.5 + Math.sin(time * 3) * 0.5;

                        // Color shift
                        const hue = (time * 0.1) % 1;
                        orbMat.emissiveColor = new BABYLON.Color3(
                            0.5 + Math.sin(hue * Math.PI * 2) * 0.5,
                            0.2,
                            0.8 + Math.cos(hue * Math.PI * 2) * 0.2
                        );
                    });

                    return scene;
                };
                const scene = createScene();
                """,
                category: .advanced,
                difficulty: .advanced
            ),

            CodeExample(
                title: "Spotlight Showcase",
                description: "Multiple spotlights illuminating objects with shadows",
                code: """
                const createScene = () => {
                    const scene = new BABYLON.Scene(engine);
                    scene.clearColor = new BABYLON.Color3(0.05, 0.05, 0.1);

                    const camera = new BABYLON.ArcRotateCamera("camera1", -Math.PI / 2, Math.PI / 2.5, 15, new BABYLON.Vector3(0, 0, 0), scene);
                    if (camera.attachControls) {
                        camera.attachControls(canvas, true);
                    }

                    const light = new BABYLON.HemisphericLight("ambient", new BABYLON.Vector3(0, 1, 0), scene);
                    light.intensity = 0.2;

                    // Create three spotlights
                    const colors = [
                        new BABYLON.Color3(1, 0.2, 0.2),
                        new BABYLON.Color3(0.2, 1, 0.2),
                        new BABYLON.Color3(0.2, 0.2, 1)
                    ];

                    const spotlights = [];
                    for (let i = 0; i < 3; i++) {
                        const spotlight = new BABYLON.SpotLight(
                            "spot" + i,
                            new BABYLON.Vector3((i - 1) * 4, 8, 0),
                            new BABYLON.Vector3(0, -1, 0),
                            Math.PI / 3,
                            2,
                            scene
                        );
                        spotlight.diffuse = colors[i];
                        spotlight.intensity = 3;

                        // Shadow generator
                        const shadowGenerator = new BABYLON.ShadowGenerator(1024, spotlight);
                        shadowGenerator.useBlurExponentialShadowMap = true;

                        spotlights.push({light: spotlight, shadow: shadowGenerator});

                        // Create object under each spotlight
                        const box = BABYLON.MeshBuilder.CreateBox("box" + i, {size: 2}, scene);
                        box.position.x = (i - 1) * 4;
                        box.position.y = 1;

                        const material = new BABYLON.StandardMaterial("mat" + i, scene);
                        material.diffuseColor = new BABYLON.Color3(0.8, 0.8, 0.8);
                        material.specularColor = colors[i];
                        box.material = material;

                        shadowGenerator.addShadowCaster(box);
                    }

                    // Ground with shadow receiving
                    const ground = BABYLON.MeshBuilder.CreateGround("ground", {width: 20, height: 10}, scene);
                    const groundMat = new BABYLON.StandardMaterial("groundMat", scene);
                    groundMat.diffuseColor = new BABYLON.Color3(0.2, 0.2, 0.25);
                    ground.material = groundMat;
                    ground.receiveShadows = true;

                    return scene;
                };
                const scene = createScene();
                """,
                category: .lighting,
                difficulty: .intermediate
            ),

            // ADVANCED PROCEDURAL EXAMPLE WITH METADATA
            CodeExample(
                id: "voxel-wormhole",
                title: "🌀 Infinite Voxel Wormhole with Mario Star",
                description: "Procedurally generated infinite tunnel using simplex noise, featuring dynamic color customization, bloom post-processing, and retro-gaming aesthetics. Performance-optimized with voxel culling to maintain 60fps.",
                code: """
                const createScene = () => {
                    const scene = new BABYLON.Scene(engine);
                    scene.clearColor = new BABYLON.Color3(0, 0, 0);

                    const camera = new BABYLON.ArcRotateCamera("camera1", 0, 0, 30, new BABYLON.Vector3(0, 0, 0), scene);
                    if (camera.attachControls) {
                        camera.attachControls(canvas, true);
                    }

                    const light = new BABYLON.HemisphericLight("light1", new BABYLON.Vector3(0, 1, 0), scene);
                    light.intensity = 0.7;

                    // Add glow layer for neon effect
                    const gl = new BABYLON.GlowLayer("glow", scene);
                    gl.intensity = 1.5;

                    // SimplexNoise implementation for procedural generation
                    class SimplexNoise {
                        constructor() {
                            this.grad3 = [[1,1,0],[-1,1,0],[1,-1,0],[-1,-1,0],[1,0,1],[-1,0,1],[1,0,-1],[-1,0,-1],[0,1,1],[0,-1,1],[0,1,-1],[0,-1,-1]];
                            this.p = [];
                            for(let i=0; i<256; i++) { this.p[i] = Math.floor(Math.random()*256); }
                            this.perm = [];
                            for(let i=0; i<512; i++) { this.perm[i]=this.p[i & 255]; }
                            this.F3 = 1.0/3.0;
                            this.G3 = 1.0/6.0;
                        }

                        dot(g, x, y, z) {
                            return g[0]*x + g[1]*y + g[2]*z;
                        }

                        noise(xin, yin, zin) {
                            let n0, n1, n2, n3;
                            let s = (xin+yin+zin)*this.F3;
                            let i = Math.floor(xin+s);
                            let j = Math.floor(yin+s);
                            let k = Math.floor(zin+s);
                            let t = (i+j+k)*this.G3;
                            let X0 = i-t;
                            let Y0 = j-t;
                            let Z0 = k-t;
                            let x0 = xin-X0;
                            let y0 = yin-Y0;
                            let z0 = zin-Z0;
                            let i1, j1, k1;
                            let i2, j2, k2;
                            if(x0>=y0) {
                                if(y0>=z0) { i1=1; j1=0; k1=0; i2=1; j2=1; k2=0; }
                                else if(x0>=z0) { i1=1; j1=0; k1=0; i2=1; j2=0; k2=1; }
                                else { i1=0; j1=0; k1=1; i2=1; j2=0; k2=1; }
                            } else {
                                if(y0<z0) { i1=0; j1=0; k1=1; i2=0; j2=1; k2=1; }
                                else if(x0<z0) { i1=0; j1=1; k1=0; i2=0; j2=1; k2=1; }
                                else { i1=0; j1=1; k1=0; i2=1; j2=1; k2=0; }
                            }
                            let x1 = x0 - i1 + this.G3;
                            let y1 = y0 - j1 + this.G3;
                            let z1 = z0 - k1 + this.G3;
                            let x2 = x0 - i2 + 2.0*this.G3;
                            let y2 = y0 - j2 + 2.0*this.G3;
                            let z2 = z0 - k2 + 2.0*this.G3;
                            let x3 = x0 - 1.0 + 3.0*this.G3;
                            let y3 = y0 - 1.0 + 3.0*this.G3;
                            let z3 = z0 - 1.0 + 3.0*this.G3;
                            let ii = i & 255;
                            let jj = j & 255;
                            let kk = k & 255;
                            let gi0 = this.perm[ii+this.perm[jj+this.perm[kk]]] % 12;
                            let gi1 = this.perm[ii+i1+this.perm[jj+j1+this.perm[kk+k1]]] % 12;
                            let gi2 = this.perm[ii+i2+this.perm[jj+j2+this.perm[kk+k2]]] % 12;
                            let gi3 = this.perm[ii+1+this.perm[jj+1+this.perm[kk+1]]] % 12;
                            let t0 = 0.6 - x0*x0 - y0*y0 - z0*z0;
                            if(t0<0) n0 = 0.0;
                            else { t0 *= t0; n0 = t0 * t0 * this.dot(this.grad3[gi0], x0, y0, z0); }
                            let t1 = 0.6 - x1*x1 - y1*y1 - z1*z1;
                            if(t1<0) n1 = 0.0;
                            else { t1 *= t1; n1 = t1 * t1 * this.dot(this.grad3[gi1], x1, y1, z1); }
                            let t2 = 0.6 - x2*x2 - y2*y2 - z2*z2;
                            if(t2<0) n2 = 0.0;
                            else { t2 *= t2; n2 = t2 * t2 * this.dot(this.grad3[gi2], x2, y2, z2); }
                            let t3 = 0.6 - x3*x3 - y3*y3 - z3*z3;
                            if(t3<0) n3 = 0.0;
                            else { t3 *= t3; n3 = t3 * t3 * this.dot(this.grad3[gi3], x3, y3, z3); }
                            return 32.0*(n0 + n1 + n2 + n3);
                        }
                    }

                    const noise = new SimplexNoise();
                    const voxels = [];
                    const maxVoxels = 2000; // Performance limit
                    let cameraZ = 0;

                    // Voxel generation with culling
                    function generateVoxels(zStart, zEnd) {
                        for(let z = zStart; z < zEnd; z += 2) {
                            const radius = 10;
                            for(let angle = 0; angle < Math.PI * 2; angle += Math.PI / 8) {
                                const x = Math.cos(angle) * radius;
                                const y = Math.sin(angle) * radius;
                                const noiseVal = noise.noise(x * 0.1, y * 0.1, z * 0.05);

                                if(noiseVal > 0.2 && voxels.length < maxVoxels) {
                                    const voxel = BABYLON.MeshBuilder.CreateBox("voxel", {size: 1}, scene);
                                    voxel.position = new BABYLON.Vector3(x, y, z);

                                    const mat = new BABYLON.StandardMaterial("mat", scene);
                                    const colorPhase = z * 0.1;
                                    mat.emissiveColor = new BABYLON.Color3(
                                        Math.sin(colorPhase) * 0.5 + 0.5,
                                        Math.sin(colorPhase + 2) * 0.5 + 0.5,
                                        Math.sin(colorPhase + 4) * 0.5 + 0.5
                                    );
                                    voxel.material = mat;
                                    voxels.push(voxel);
                                }
                            }
                        }
                    }

                    // Mario star in the center
                    const star = BABYLON.MeshBuilder.CreatePolyhedron("star", {type: 1, size: 2}, scene);
                    const starMat = new BABYLON.PBRMaterial("starMat", scene);
                    starMat.albedoColor = new BABYLON.Color3(1, 0.9, 0.2);
                    starMat.metallic = 1;
                    starMat.roughness = 0.1;
                    starMat.emissiveColor = new BABYLON.Color3(1, 0.9, 0);
                    starMat.emissiveIntensity = 2;
                    star.material = starMat;

                    // Initial voxel generation
                    generateVoxels(-20, 40);

                    // Animation loop
                    scene.registerBeforeRender(() => {
                        cameraZ += 0.5;
                        camera.target.z = cameraZ;

                        star.rotation.y += 0.05;
                        star.rotation.x += 0.03;

                        // Regenerate voxels for infinite tunnel
                        if(cameraZ % 20 === 0) {
                            const voxelsToRemove = voxels.filter(v => v.position.z < cameraZ - 30);
                            voxelsToRemove.forEach(v => {
                                v.dispose();
                                voxels.splice(voxels.indexOf(v), 1);
                            });
                            generateVoxels(cameraZ + 20, cameraZ + 40);
                        }
                    });

                    console.log("Voxel wormhole scene created successfully");
                    return scene;
                };
                const scene = createScene();
                """,
                category: .effects,
                difficulty: .advanced,
                keywords: [
                    "voxel", "procedural", "infinite", "wormhole", "tunnel",
                    "simplex-noise", "algorithm", "post-processing", "bloom",
                    "retro-gaming", "mario", "neon", "glow", "optimization"
                ],
                aiPromptHints: """
                When users request voxel, infinite tunnel, or procedural generation scenes:

                1. PROCEDURAL GENERATION: Use SimplexNoise class for organic, natural-looking patterns
                   - Initialize with random permutation table
                   - Call noise(x, y, z) with scaled coordinates for variation
                   - Threshold noise values to create sparse distributions

                2. PERFORMANCE OPTIMIZATION: Implement voxel culling to maintain 60fps
                   - Set maxVoxels limit (typically 1500-2000 for smooth performance)
                   - Remove voxels behind camera: if(voxel.position.z < camera.z - 30) dispose()
                   - Check voxels.length before creating new instances

                3. INFINITE TUNNEL: Create continuous movement by regenerating at boundaries
                   - Advance camera position in registerBeforeRender: camera.target.z += speed
                   - Detect when camera crosses threshold: if(cameraZ % segmentLength === 0)
                   - Generate new segment ahead, dispose old segment behind

                4. VISUAL EFFECTS: Add bloom/glow for neon aesthetics
                   - Use GlowLayer with intensity 1.0-2.0
                   - Set emissiveColor on materials for self-illumination
                   - Vary colors using Math.sin with phase offsets for rainbow effects

                5. HTML UI: Include controls for real-time customization (advanced)
                   - Add sliders for speed, color, density parameters
                   - Update values in registerBeforeRender loop
                   - Display FPS counter for performance monitoring

                PERFORMANCE TIPS:
                - Limit active objects to ~2000 max for 60fps on mobile
                - Use dispose() to free memory for removed meshes
                - Batch similar operations to reduce draw calls
                - Consider InstancedMesh for repeated geometry (10x+ performance boost)
                """
            ),

            // RETRO SYNTHWAVE TRONSCAPE
            CodeExample(
                id: "tronscape-demo",
                title: "🌆 Retrowave Tronscape",
                description: "Epic synthwave landscape with fractal terrain, warp star background, pink sun, and chromatic aberration. Features procedural grid material, infinite scrolling terrain, and retro 80s aesthetics.",
                code: """
                // Minimal Perlin-like noise for fractal terrain
                function fade(t) {
                    return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
                }
                function lerp(a, b, t) {
                    return a + (b - a) * t;
                }
                function random2D(i, j) {
                    let seed = (i * 49632) ^ (j * 325176);
                    let s = Math.sin(seed) * 43758.5453;
                    return s - Math.floor(s);
                }
                function noise2D(x, z) {
                    let xi = Math.floor(x);
                    let zi = Math.floor(z);
                    let xf = x - xi;
                    let zf = z - zi;

                    let tl = random2D(xi,   zi);
                    let tr = random2D(xi+1, zi);
                    let bl = random2D(xi,   zi+1);
                    let br = random2D(xi+1, zi+1);

                    let u = fade(xf);
                    let v = fade(zf);

                    let top    = lerp(tl, tr, u);
                    let bottom = lerp(bl, br, u);
                    return lerp(top, bottom, v);
                }
                function fractalNoise2D(x, z, octaves, lacunarity, gain) {
                    let sum = 0.0;
                    let amp = 1.0;
                    let freq = 1.0;
                    let norm = 0.0;

                    for (let i = 0; i < octaves; i++) {
                        sum += amp * noise2D(x * freq, z * freq);
                        norm += amp;
                        freq *= lacunarity;
                        amp *= gain;
                    }
                    return sum / norm;
                }

                var url = "https://cdn.rawgit.com/BabylonJS/Extensions/master/DynamicTerrain/dist/babylon.dynamicTerrain.min.js";
                var s = document.createElement("script");
                s.src = url;
                document.head.appendChild(s);

                const createScene = () => {
                    const scene = new BABYLON.Scene(engine);

                    // Set background to BLACK
                    scene.clearColor = new BABYLON.Color4(0, 0, 0, 1);

                    // Camera
                    const camera = new BABYLON.ArcRotateCamera("camera", 0, 1.2, 180, BABYLON.Vector3.Zero(), scene);
                    if (camera.attachControl) {
                        camera.attachControl(canvas, true);
                    }
                    camera.fov = 1.2;
                    camera.maxZ = 5000;

                    // Lock zoom
                    camera.lowerRadiusLimit = camera.radius;
                    camera.upperRadiusLimit = camera.radius;

                    // Light
                    new BABYLON.HemisphericLight("light", new BABYLON.Vector3(0, 1, 0), scene);

                    // Load DynamicTerrain
                    s.onload = function() {
                        let mapSize = 200;
                        let mapData = [];
                        for (let z = 0; z <= mapSize; z++) {
                            for (let x = 0; x <= mapSize; x++) {
                                let worldX = x - mapSize / 2;
                                let worldZ = z - mapSize / 2;
                                let n = fractalNoise2D(worldX * 0.04, worldZ * 0.04, 4, 2.0, 0.5);
                                let y = n * 10.0;
                                mapData.push(worldX, y, worldZ);
                            }
                        }

                        let terrainOpts = {
                            mapData: mapData,
                            mapSubX: mapSize,
                            mapSubZ: mapSize,
                            terrainSub: 60
                        };
                        let terrain = new BABYLON.DynamicTerrain("terrain", terrainOpts, scene);
                        terrain.createUVMap();
                        terrain.update(true);

                        let gridMat = new BABYLON.GridMaterial("gridMaterial", scene);
                        gridMat.majorUnitFrequency = 1;
                        gridMat.minorUnitVisibility = 0;
                        gridMat.gridRatio = 1;
                        gridMat.backFaceCulling = false;
                        gridMat.mainColor = new BABYLON.Color3(0, 0, 0);
                        gridMat.lineColor = new BABYLON.Color3(0, 1, 1);
                        terrain.mesh.material = gridMat;
                        terrain.mesh.position.y = -2;

                        scene.onBeforeRenderObservable.add(() => {
                            terrain.mesh.position.z -= 0.2;
                        });
                    };

                    // Bigger pink sun
                    let sun = BABYLON.MeshBuilder.CreateDisc("sun", { radius: 15, tessellation: 64 }, scene);
                    let sunMat = new BABYLON.StandardMaterial("sunMat", scene);
                    sunMat.emissiveColor = new BABYLON.Color3(1, 0.2, 0.6);
                    sun.material = sunMat;
                    sun.position.set(0, 10, -30);

                    camera.position.set(-6.1, 5.69, -213.73);
                    camera.setTarget(sun.position);

                    // Skybox
                    let skybox = BABYLON.MeshBuilder.CreateBox("skyBox", { size: 10000 }, scene);
                    skybox.infiniteDistance = true;
                    skybox.applyFog = false;

                    // Warp star shader
                    BABYLON.Effect.ShadersStore["warpStarVertexShader"] = `
                        precision highp float;
                        attribute vec3 position;
                        attribute vec2 uv;
                        uniform mat4 worldViewProjection;
                        varying vec2 vUV;
                        void main() {
                            vUV = uv;
                            gl_Position = worldViewProjection * vec4(position, 1.0);
                        }
                    `;
                    BABYLON.Effect.ShadersStore["warpStarFragmentShader"] = `
                        precision highp float;
                        varying vec2 vUV;
                        uniform float iTime;
                        uniform vec3  starColor;
                        float hash12(vec2 p) {
                            float h = dot(p, vec2(127.1, 311.7));
                            return fract(sin(h)*43758.5453);
                        }
                        void main() {
                            vec2 uv = vUV * 2.0 - 1.0;
                            float r = length(uv);
                            float angle = atan(uv.y, uv.x);
                            float warpSpeed = 1.2;
                            float radial = r - iTime * warpSpeed;
                            float slices = 40.0;
                            float rings  = 25.0;
                            float sliceIndex = floor(angle * slices);
                            float ringIndex  = floor(radial * rings);
                            float starChance = hash12(vec2(sliceIndex, ringIndex));
                            float ringPos = fract(radial * rings);
                            float starIntensity = 0.0;
                            if (starChance < 0.25) {
                                float bandWidth = 0.15;
                                if (ringPos < bandWidth) {
                                    float fade = 1.0 - (ringPos / bandWidth);
                                    starIntensity = fade;
                                }
                            }
                            float centerGlow = max(0.0, 0.15 - r) * 4.0;
                            starIntensity = max(starIntensity, centerGlow);
                            vec3 col = mix(vec3(0.0), starColor, starIntensity);
                            gl_FragColor = vec4(col, 1.0);
                        }
                    `;
                    let warpStarMat = new BABYLON.ShaderMaterial(
                        "warpStarMat",
                        scene,
                        { vertex: "warpStar", fragment: "warpStar" },
                        {
                            attributes: ["position", "uv"],
                            uniforms: ["worldViewProjection", "iTime", "starColor"]
                        }
                    );
                    warpStarMat.setColor3("starColor", new BABYLON.Color3(0.9, 0.9, 1.0));
                    let startTime = Date.now();
                    scene.onBeforeRenderObservable.add(() => {
                        let t = (Date.now() - startTime) * 0.001;
                        warpStarMat.setFloat("iTime", t);
                    });
                    skybox.material = warpStarMat;

                    // Fog
                    scene.fogMode = BABYLON.Scene.FOGMODE_LINEAR;
                    scene.fogStart = 300;
                    scene.fogEnd = 900;
                    scene.fogColor = new BABYLON.Color3(0,0,0);

                    // Postprocess pipeline
                    let pipeline = new BABYLON.DefaultRenderingPipeline("DefaultPipeline", true, scene, [camera]);
                    pipeline.bloomEnabled = true;
                    pipeline.bloomThreshold = 0.2;
                    pipeline.bloomWeight = 1.0;
                    pipeline.bloomKernel = 64;
                    pipeline.bloomScale = 0.5;
                    pipeline.chromaticAberrationEnabled = true;
                    pipeline.chromaticAberration.aberrationAmount = 4.0;
                    pipeline.chromaticAberration.radialIntensity = 1.0;

                    console.log("Tronscape scene created successfully");
                    return scene;
                };
                const scene = createScene();
                """,
                category: .effects,
                difficulty: .advanced,
                keywords: [
                    "synthwave", "retrowave", "tron", "80s", "neon",
                    "procedural", "terrain", "fractal", "noise", "perlin",
                    "shader", "glsl", "custom-material", "warp-stars",
                    "bloom", "chromatic-aberration", "post-processing",
                    "grid", "infinite-scroll", "dynamic-terrain"
                ],
                aiPromptHints: """
                When users request synthwave, retrowave, Tron, or 80s aesthetic scenes:

                1. FRACTAL TERRAIN: Use Perlin/simplex noise for procedural landscapes
                   - Implement fade, lerp, and noise functions for smooth terrain
                   - Use fractalNoise2D with multiple octaves (4+) for detail
                   - Parameters: octaves, lacunarity (2.0), gain (0.5)
                   - Generate heightmap data: noise * amplitude for Y values

                2. DYNAMIC TERRAIN: Load external DynamicTerrain library
                   - Include script: cdn.rawgit.com/BabylonJS/Extensions/master/DynamicTerrain
                   - Create mapData array with [x, y, z] positions
                   - Configure terrainSub for level of detail
                   - Use GridMaterial for classic Tron wireframe look

                3. CUSTOM SHADERS: Create warp star/tunnel effects
                   - Define vertex/fragment shaders in BABYLON.Effect.ShadersStore
                   - Use ShaderMaterial with custom uniforms (iTime, colors)
                   - Implement radial patterns with atan() for angle
                   - Animate with time-based uniforms in beforeRender

                4. RETRO AESTHETICS: Pink sun + cyan grid + black background
                   - Pink/magenta sun: Color3(1, 0.2, 0.6) with emissive material
                   - Cyan grid lines: Color3(0, 1, 1) on GridMaterial
                   - Black clearColor: Color4(0, 0, 0, 1)
                   - Large sun disc (radius: 15) for dramatic effect

                5. POST-PROCESSING: Bloom + chromatic aberration
                   - DefaultRenderingPipeline for easy effects
                   - Bloom: threshold 0.2, weight 1.0, kernel 64
                   - Chromatic aberration: amount 4.0, radial intensity 1.0
                   - Add fog (linear mode) for depth

                6. INFINITE SCROLLING: Move terrain continuously
                   - In beforeRender: terrain.mesh.position.z -= speed
                   - Lock camera zoom (lowerRadiusLimit = upperRadiusLimit)
                   - Position camera for dramatic angle

                TECHNICAL TIPS:
                - Load external libraries with script injection (check s.onload)
                - Use GridMaterial for instant Tron aesthetic
                - Combine multiple noise octaves for realistic terrain
                - Custom shaders need vertex + fragment in ShadersStore
                - Lock camera radius for cinematic fixed view
                """
            ),

            // FRACTAL INVADER
            CodeExample(
                id: "fractal-invader",
                title: "👾 Fractal Invader",
                description: "Procedurally generated voxel space invaders with glowing effects, reflective water plane, animated geometric shapes, and dynamic skybox. Features mesh merging optimization, emissive materials, and glow layer effects.",
                code: """
                const createScene = function () {
                    const scene = new BABYLON.Scene(engine);

                    // Camera setup
                    const camera = new BABYLON.FreeCamera("camera", new BABYLON.Vector3(0, 3.6, -21), scene);
                    camera.setTarget(new BABYLON.Vector3(0, 3.6, 0));

                    // Light setup
                    const light = new BABYLON.HemisphericLight("light", new BABYLON.Vector3(0, 1, 0), scene);

                    // VoxelVader function - generates procedural space invader
                    function VoxelVader({
                        colorPool = [0xff004b, 0x0000ff, 0x00ff3c, 0x6900ff, 0xff0000, 0x00b3ff, 0x1e00ff],
                        color = [
                            BABYLON.Color3.FromHexString("#" + colorPool[Math.floor(Math.random() * colorPool.length)].toString(16).padStart(6, '0')),
                            BABYLON.Color3.FromHexString("#" + colorPool[Math.floor(Math.random() * colorPool.length)].toString(16).padStart(6, '0'))
                        ],
                        size = 5,
                        steps = size / 5,
                        padding = parseInt(size / 2),
                        position = [0, 0, 0]
                    }) {
                        let groups = [];

                        // Create materials with emissive glow
                        let materials = [
                            new BABYLON.StandardMaterial("material1", scene),
                            new BABYLON.StandardMaterial("material2", scene)
                        ];

                        materials[0].diffuseColor = color[0];
                        materials[0].specularColor = new BABYLON.Color3(1, 1, 0);
                        materials[0].emissiveColor = color[0].scale(0.5);
                        materials[0].emissiveIntensity = 0.7;

                        materials[1].diffuseColor = color[1];
                        materials[1].emissiveColor = color[1].scale(0.5);
                        materials[1].emissiveIntensity = 0.7;

                        const voxelMesh = generateVoxel({ colorPool, color, size, steps, padding, materials, camera, scene, groups });

                        // Animate glow intensity
                        let time = 0;
                        scene.registerBeforeRender(() => {
                            time += 0.05;
                            gl.intensity = 0.5 + Math.sin(time) * 0.25;

                            if (groups.length) {
                                for (let i = 0; i < groups.length; i++) {
                                    if (groups[i].isGlowing) {
                                        groups[i].material.emissiveIntensity = 0.7 + Math.sin(time) * 0.3;
                                    }
                                }
                            }
                        });

                        return voxelMesh;
                    }

                    // Generate voxel mesh with symmetric pattern
                    const generateVoxel = ({ colorPool, color, size, steps, padding, materials, camera, scene, groups }) => {
                        const createVaderMesh = (material) => {
                            let mesh = BABYLON.MeshBuilder.CreateBox("box", {}, scene);
                            mesh.material = material.clone("clonedMaterial");
                            return mesh;
                        }

                        const VaderMesh = (obj = {}) => {
                            obj.vaderObj = new BABYLON.Mesh("VaderObj", scene);
                            obj.bg = new BABYLON.Mesh("VaderObj2BG", scene);
                            let col = [];

                            // Generate symmetric pattern
                            for (let j = 0; j < size; j += steps) {
                                let m = 1;
                                col[j] = [];
                                for (let i = 0; i < size / 2; i += steps) {
                                    let c = Math.random() > 0.5;
                                    col[j][i] = c;
                                    col[j][i + (size - steps) / m] = c;
                                    m++;
                                }
                            }

                            // Create voxel grid
                            for (let j = 0; j < size; j += steps) {
                                for (let i = 0; i < size; i += steps) {
                                    let vaders = createVaderMesh(materials[0]);
                                    let vader2 = createVaderMesh(materials[0]);
                                    let vadersBG = createVaderMesh(materials[1]);
                                    vadersBG.position = new BABYLON.Vector3(i, j, 4);
                                    vadersBG.isVisible = col[j][i];
                                    vadersBG.vaderT = 'bg';
                                    vaders.position = new BABYLON.Vector3(i, j, 5);
                                    vaders.isVisible = col[j][i];
                                    vaders.vaderT = 'front';
                                    vader2.vaderT = 'front';
                                    vader2.position = new BABYLON.Vector3(i, j, 6);
                                    vader2.isVisible = col[j][i];
                                    obj.bg.addChild(vadersBG);
                                    obj.vaderObj.addChild(vadersBG);
                                    obj.vaderObj.addChild(vaders);
                                    obj.vaderObj.addChild(vader2);
                                }
                            }
                            return obj.vaderObj;
                        }

                        let voxelInvader = VaderMesh();

                        // Merge geometry for performance
                        let visibileArrBG = [];
                        let visibileArr = [];
                        let meshInvaderVisibile = (obj) => {
                            for (let i = 0; i < obj.getChildren().length; i++) {
                                let child = obj.getChildren()[i];
                                if (child.getChildren().length === 0 && child.isVisible && child.vaderT === 'bg') {
                                    visibileArrBG.push(child);
                                } else if (child.isVisible && child.vaderT === 'front') {
                                    visibileArr.push(child);
                                } else {
                                    meshInvaderVisibile(child);
                                }
                            }
                        }
                        meshInvaderVisibile(voxelInvader);

                        var mergedGeo = BABYLON.Mesh.MergeMeshes(visibileArr, true, true, undefined, false, true);
                        var mergedGeoBG = BABYLON.Mesh.MergeMeshes(visibileArrBG, true, true, undefined, false, true);

                        if (mergedGeo) {
                            mergedGeo.material = materials[0].clone("mergedMaterial1");
                            groups.push(mergedGeo);
                            groups[groups.length - 1].isGlowing = false;

                            let glowingMeshFront = mergedGeo.clone("glowingMeshFront");
                            glowingMeshFront.scaling.multiplyInPlace(new BABYLON.Vector3(1.1, 1.1, 1.1));
                            glowingMeshFront.material = materials[0].clone("glowingMaterial1");
                            glowingMeshFront.material.emissiveColor = color[0];
                            glowingMeshFront.material.emissiveIntensity = 1;
                            glowingMeshFront.isGlowing = true;
                            groups.push(glowingMeshFront);
                        }

                        if (mergedGeoBG) {
                            mergedGeoBG.material = materials[1].clone("mergedMaterial2");
                            groups.push(mergedGeoBG);
                            groups[groups.length - 1].isGlowing = false;

                            let glowingMesh = mergedGeoBG.clone("glowingMesh");
                            glowingMesh.scaling.multiplyInPlace(new BABYLON.Vector3(1.1, 1.1, 1.1));
                            glowingMesh.material = materials[1].clone("glowingMaterial2");
                            glowingMesh.material.emissiveColor = color[1];
                            glowingMesh.material.emissiveIntensity = 1;
                            glowingMesh.isGlowing = true;
                            groups.push(glowingMesh);
                        }

                        for (let i = 0; i < groups.length; i++) {
                            voxelInvader.addChild(groups[i]);
                        }

                        return voxelInvader;
                    }

                    function randomSize(minSize, maxSize) {
                        return Math.floor(Math.random() * (maxSize - minSize + 1)) + minSize;
                    }

                    function spawnVoxelVader(scene, camera) {
                        const vxSize = randomSize(2, 6);
                        const voxelVader = VoxelVader({
                            size: vxSize,
                            steps: vxSize / 5,
                            padding: 1,
                            position: [0, 0, 0]
                        });

                        // Spawn in front of camera
                        const spawnDistance = 50;
                        const direction = camera.getForwardRay().direction;
                        const spawnPosition = camera.position.add(direction.scale(spawnDistance));
                        voxelVader.position = spawnPosition;
                        voxelVader.position.y = 3;

                        const scale = 0.5;
                        voxelVader.scaling = new BABYLON.Vector3(scale, scale, scale);
                        voxelVader.rotation.y = Math.PI / 4;
                        voxelVader.lookAt(camera.position);

                        // Random transparency
                        const transparency = Math.random() * 0.5 + 0.5;
                        voxelVader.getChildMeshes().forEach(mesh => {
                            if (mesh.material) {
                                mesh.material.alpha = transparency;
                            }
                        });

                        return voxelVader;
                    }

                    const voxelVaders = [];
                    const maxVoxelVaders = 1;

                    function moveVoxelVaders(camera) {
                        const speed = 0.3;
                        voxelVaders.forEach((vader, index) => {
                            const direction = camera.position.subtract(vader.position).normalize();
                            vader.position.addInPlace(direction.scale(speed));
                            vader.lookAt(camera.position);

                            // Remove if too close
                            if (BABYLON.Vector3.Distance(vader.position, camera.position) < 2) {
                                vader.dispose();
                                voxelVaders.splice(index, 1);
                            }
                        });
                    }

                    for (let i = 0; i < maxVoxelVaders; i++) {
                        voxelVaders.push(spawnVoxelVader(scene, camera));
                    }

                    const skyBoxImgs = [
                        "https://raw.githubusercontent.com/seacloud9/seacloud9.github.io/master/assets/sky/sky",
                        "https://raw.githubusercontent.com/seacloud9/seacloud9.github.io/master/assets/aquatic/sky"
                    ];

                    function getRandomSkyBoxImg() {
                        const randomIndex = Math.floor(Math.random() * skyBoxImgs.length);
                        return skyBoxImgs[randomIndex];
                    }

                    // Skybox
                    const skybox = BABYLON.MeshBuilder.CreateBox("skyBox", {size: 10000.0}, scene);
                    const skyboxMaterial = new BABYLON.StandardMaterial("skyBox", scene);
                    skyboxMaterial.backFaceCulling = false;
                    skyboxMaterial.reflectionTexture = new BABYLON.CubeTexture(getRandomSkyBoxImg(), scene);
                    skyboxMaterial.reflectionTexture.coordinatesMode = BABYLON.Texture.SKYBOX_MODE;
                    skyboxMaterial.diffuseColor = new BABYLON.Color3(0, 0, 0);
                    skyboxMaterial.specularColor = new BABYLON.Color3(0, 0, 0);
                    skybox.material = skyboxMaterial;

                    // Water plane with reflections
                    const waterMesh = BABYLON.MeshBuilder.CreateGround("waterMesh", {width: 200, height: 200}, scene);
                    const waterMaterial = new BABYLON.WaterMaterial("water", scene);
                    waterMaterial.bumpTexture = new BABYLON.Texture("https://assets.babylonjs.com/textures/waterbump.png", scene);
                    waterMaterial.windForce = 45;
                    waterMaterial.waveHeight = 0.4;
                    waterMaterial.bumpHeight = 2.3;
                    waterMaterial.windDirection = new BABYLON.Vector2(-1, 0);
                    waterMaterial.waterColor = new BABYLON.Color3(0.1, 0.1, 0.6);
                    waterMaterial.colorBlendFactor = 0.0;
                    waterMaterial.waveLength = 0.05;
                    waterMaterial.addToRenderList(skybox);
                    waterMesh.material = waterMaterial;

                    // Glowing materials
                    const glowMaterial = new BABYLON.StandardMaterial("glowMaterial", scene);
                    glowMaterial.emissiveColor = new BABYLON.Color3(0, 1, 1);
                    glowMaterial.disableLighting = true;

                    const redGlowMaterial = new BABYLON.StandardMaterial("redGlowMaterial", scene);
                    redGlowMaterial.emissiveColor = new BABYLON.Color3(1, 0, 0);
                    redGlowMaterial.disableLighting = true;

                    // Create hollow triangle mesh
                    const createHollowTriangle = (size) => {
                        const trianglePoints = [
                            new BABYLON.Vector3(-size, -size * Math.sqrt(3) / 2, 0),
                            new BABYLON.Vector3(size, -size * Math.sqrt(3) / 2, 0),
                            new BABYLON.Vector3(0, size * Math.sqrt(3) / 2, 0)
                        ];
                        const lines = BABYLON.MeshBuilder.CreateLines("hollowTriangle", {points: [...trianglePoints, trianglePoints[0]]}, scene);
                        return lines;
                    };

                    // Create hollow square mesh
                    const createHollowSquare = (size) => {
                        const squarePoints = [
                            new BABYLON.Vector3(-size, -size, 0),
                            new BABYLON.Vector3(size, -size, 0),
                            new BABYLON.Vector3(size, size, 0),
                            new BABYLON.Vector3(-size, size, 0)
                        ];
                        const lines = BABYLON.MeshBuilder.CreateLines("hollowSquare", {points: [...squarePoints, squarePoints[0]]}, scene);
                        return lines;
                    };

                    // Create animated geometric shapes
                    const triangles = [];
                    const squares = [];
                    const shapeCount = 30;
                    const spacing = 10;
                    const startZ = -5;
                    const squareOffset = 0;

                    for (let i = 0; i < shapeCount; i++) {
                        const triangle = createHollowTriangle(0.5);
                        triangle.material = glowMaterial;
                        triangle.position = new BABYLON.Vector3(0, 4, startZ + i * spacing);
                        triangles.push(triangle);
                        waterMaterial.addToRenderList(triangle);

                        const square = createHollowSquare(0.5);
                        square.material = redGlowMaterial;
                        square.position = new BABYLON.Vector3(squareOffset, 4, startZ + i * spacing);
                        square.rotation.z = Math.PI / 4;
                        squares.push(square);
                        waterMaterial.addToRenderList(square);
                    }

                    // Glow layer
                    const gl = new BABYLON.GlowLayer("glow", scene);
                    gl.intensity = 1.25;

                    // Animation
                    const speed = 0.1;
                    scene.registerBeforeRender(() => {
                        moveVoxelVaders(camera);

                        while (voxelVaders.length < maxVoxelVaders) {
                            voxelVaders.push(spawnVoxelVader(scene, camera));
                        }

                        triangles.forEach((triangle, index) => {
                            triangle.position.z -= speed;
                            if (triangle.position.z < -15) {
                                triangle.position.z = startZ;
                            }
                            triangle.lookAt(camera.position);

                            const square = squares[index];
                            square.position.z = triangle.position.z;
                            if (square.position.z < -15) {
                                square.position.z = startZ;
                            }
                            square.rotation.y = Math.atan2(camera.position.x - square.position.x, camera.position.z - square.position.z);
                        });
                    });

                    return scene;
                };

                export default createScene;
                """,
                category: .effects,
                difficulty: .advanced,
                keywords: [
                    "voxel", "procedural", "space-invader", "retro", "arcade",
                    "glow-layer", "emissive", "water-material", "reflections",
                    "mesh-merging", "optimization", "geometric-shapes", "animation",
                    "skybox", "cube-texture", "random-generation", "symmetric-pattern",
                    "hollow-shapes", "billboard", "spawning"
                ],
                aiPromptHints: """
                When users request retro arcade, space invader, or voxel character scenes:

                1. PROCEDURAL VOXEL GENERATION: Create symmetric patterns
                   - Use random grid generation with symmetry (mirror left/right)
                   - Build voxel grid with nested loops (size, steps parameters)
                   - Create depth layers (front, middle, back voxels at z: 4, 5, 6)
                   - Random color selection from predefined palette

                2. MESH OPTIMIZATION: Merge geometry for performance
                   - Collect visible meshes into arrays (separate by material type)
                   - Use BABYLON.Mesh.MergeMeshes() to combine similar meshes
                   - Clone merged mesh at 1.1x scale for glow halo effect
                   - Reduces draw calls from 100+ individual boxes to 2-4 merged meshes

                3. EMISSIVE GLOW EFFECTS: Layer multiple glowing elements
                   - Set material.emissiveColor and emissiveIntensity
                   - Create GlowLayer with intensity 1.0-1.5
                   - Animate emissiveIntensity with Math.sin() for pulsing
                   - Use disableLighting: true for pure emissive materials

                4. WATER MATERIAL: Reflective animated surface
                   - Load WaterMaterial extension library
                   - Configure bump texture, wind force, wave height
                   - addToRenderList() for each object to reflect (skybox, shapes, invaders)
                   - Position below camera (y: 0) for floor reflection

                5. DYNAMIC SPAWNING: Continuous object generation
                   - Spawn objects in front of camera using getForwardRay()
                   - Move towards camera each frame (subtract distance)
                   - Remove when too close (dispose + splice from array)
                   - Respawn to maintain constant count (while loop in beforeRender)

                6. GEOMETRIC SHAPES: Animated hollow wireframes
                   - Use MeshBuilder.CreateLines() with point arrays
                   - Make shapes billboard/lookAt camera for facing effect
                   - Loop position.z with modulo for infinite scrolling
                   - Combine multiple shape types (triangles, squares, circles)

                7. RANDOM SKYBOX: Dynamic environment selection
                   - Array of CubeTexture URLs
                   - Random selection on scene creation
                   - Use coordinatesMode: SKYBOX_MODE
                   - Large box size (10000) with backFaceCulling: false

                TECHNICAL TIPS:
                - Mesh merging is CRITICAL for voxel performance (100+ boxes → 1 mesh)
                - Clone materials when sharing between meshes (avoid global state)
                - Use getChildMeshes() to apply properties to entire hierarchy
                - Store custom properties (vaderT, isGlowing) on mesh objects
                - Recursive tree traversal for finding visible children
                - Water reflections require explicit addToRenderList() calls

                PERFORMANCE OPTIMIZATIONS:
                - Merge all voxels into 2-4 meshes max (not 100+ individual boxes)
                - Limit total voxel invaders to 1-3 on screen simultaneously
                - Dispose removed objects properly (vader.dispose())
                - Use array.splice() to remove from tracking arrays
                - Set upperLimit for spawning (while voxelVaders.length < maxVoxelVaders)

                VISUAL STYLE:
                - Neon/vibrant color palette (pink, cyan, red, blue, purple)
                - Heavy use of emissive materials and glow layers
                - Reflective water surface for retro futuristic aesthetic
                - Geometric hollow shapes (triangles, squares) as environment
                - Symmetric voxel patterns reminiscent of classic arcade sprites
                """
            ),

            // SPACE HARRIER GAME
            CodeExample(
                id: "space-harrier",
                title: "🎮 Space Harrier Game",
                description: "Complete retro arcade shooter game with WASD/Arrow controls, SPACE to fire, and dynamic enemy spawning. Simplified version - see full implementation at playground link in console.",
                code: """
                // Simplified Space Harrier - Full version: https://playground.babylonjs.com/#WJ20GP#16
                const createScene = function() {
                    const scene = new BABYLON.Scene(engine);
                    scene.clearColor = new BABYLON.Color3(0, 0, 0);

                    let score = 0;
                    let gameOver = false;
                    const enemies = [];
                    const projectiles = [];

                    const light = new BABYLON.HemisphericLight("light", new BABYLON.Vector3(0, 1, 0), scene);

                    const player = BABYLON.MeshBuilder.CreateSphere("player", {diameter: 2}, scene);
                    player.position = new BABYLON.Vector3(0, 5, 0);
                    const playerMat = new BABYLON.StandardMaterial("playerMat", scene);
                    playerMat.emissiveColor = new BABYLON.Color3(0, 0.7, 1);
                    player.material = playerMat;

                    const camera = new BABYLON.FollowCamera("camera", new BABYLON.Vector3(0, 10, -15), scene);
                    camera.lockedTarget = player;
                    camera.radius = 15;
                    camera.heightOffset = 5;
                    scene.activeCamera = camera;

                    const ground = BABYLON.MeshBuilder.CreateGround("ground", {width: 1000, height: 1000}, scene);
                    const groundMat = new BABYLON.StandardMaterial("groundMat", scene);
                    groundMat.diffuseColor = new BABYLON.Color3(0.1, 0.2, 0.4);
                    ground.material = groundMat;

                    const skybox = BABYLON.MeshBuilder.CreateBox("skyBox", {size: 1000}, scene);
                    const skyboxMat = new BABYLON.StandardMaterial("skyBox", scene);
                    skyboxMat.backFaceCulling = false;
                    skyboxMat.reflectionTexture = new BABYLON.CubeTexture("https://assets.babylonjs.com/textures/skybox", scene);
                    skyboxMat.reflectionTexture.coordinatesMode = BABYLON.Texture.SKYBOX_MODE;
                    skyboxMat.diffuseColor = new BABYLON.Color3(0, 0, 0);
                    skyboxMat.specularColor = new BABYLON.Color3(0, 0, 0);
                    skybox.material = skyboxMat;

                    const keys = {w: false, a: false, s: false, d: false, space: false,
                                  arrowUp: false, arrowDown: false, arrowLeft: false, arrowRight: false};

                    scene.onKeyboardObservable.add((kbInfo) => {
                        const key = kbInfo.event.key.toLowerCase();
                        const isDown = kbInfo.type === BABYLON.KeyboardEventTypes.KEYDOWN;

                        if (key === "arrowup") keys.arrowUp = isDown;
                        else if (key === "arrowdown") keys.arrowDown = isDown;
                        else if (key === "arrowleft") keys.arrowLeft = isDown;
                        else if (key === "arrowright") keys.arrowRight = isDown;
                        else if (key === " ") keys.space = isDown;
                        else if (key in keys) keys[key] = isDown;
                    });

                    const createEnemy = () => {
                        const enemy = BABYLON.MeshBuilder.CreateBox("enemy", {size: 2}, scene);
                        const enemyMat = new BABYLON.StandardMaterial("enemyMat", scene);
                        const colors = ["#ff004b", "#0000ff", "#00ff3c", "#ff0000", "#00b3ff"];
                        enemyMat.emissiveColor = BABYLON.Color3.FromHexString(colors[Math.floor(Math.random() * colors.length)]);
                        enemy.material = enemyMat;
                        enemy.position = new BABYLON.Vector3(
                            Math.random() * 60 - 30,
                            Math.random() * 10 + 2,
                            player.position.z + 200
                        );
                        enemy.health = 100;
                        enemies.push(enemy);
                        return enemy;
                    };

                    let lastFireTime = 0;
                    const fireProjectile = () => {
                        if (gameOver) return;
                        const now = performance.now() / 1000;
                        if (now - lastFireTime < 0.2) return;
                        lastFireTime = now;

                        const projectile = BABYLON.MeshBuilder.CreateSphere("projectile", {diameter: 0.5}, scene);
                        const projMat = new BABYLON.StandardMaterial("projMat", scene);
                        projMat.emissiveColor = new BABYLON.Color3(0, 1, 0.5);
                        projectile.material = projMat;
                        projectile.position = player.position.clone();
                        projectile.position.z += 2;
                        projectile.speed = 3;
                        projectile.damage = 50;
                        projectiles.push(projectile);
                    };

                    scene.registerBeforeRender(() => {
                        if (gameOver) return;

                        const speed = 0.3;
                        if (keys.w || keys.arrowUp) player.position.y += speed;
                        if (keys.s || keys.arrowDown) player.position.y -= speed;
                        if (keys.a || keys.arrowLeft) player.position.x -= speed;
                        if (keys.d || keys.arrowRight) player.position.x += speed;

                        player.position.y = Math.max(2, Math.min(20, player.position.y));
                        player.position.x = Math.max(-40, Math.min(40, player.position.x));

                        if (keys.space) fireProjectile();

                        projectiles.forEach((proj, i) => {
                            proj.position.z += proj.speed;
                            if (proj.position.z > player.position.z + 300) {
                                proj.dispose();
                                projectiles.splice(i, 1);
                            }
                        });

                        enemies.forEach((enemy, i) => {
                            enemy.position.z -= 0.5;
                            enemy.rotation.y += 0.02;
                            if (enemy.position.z < player.position.z - 50) {
                                enemy.dispose();
                                enemies.splice(i, 1);
                            }
                        });

                        if (enemies.length < 10 && Math.random() < 0.02) createEnemy();

                        for (let i = projectiles.length - 1; i >= 0; i--) {
                            const proj = projectiles[i];
                            for (let j = enemies.length - 1; j >= 0; j--) {
                                const enemy = enemies[j];
                                if (BABYLON.Vector3.Distance(proj.position, enemy.position) < 2) {
                                    enemy.health -= proj.damage;
                                    proj.dispose();
                                    projectiles.splice(i, 1);
                                    if (enemy.health <= 0) {
                                        enemy.dispose();
                                        enemies.splice(j, 1);
                                        score += 100;
                                    }
                                    break;
                                }
                            }
                        }

                        for (let i = 0; i < enemies.length; i++) {
                            if (BABYLON.Vector3.Distance(player.position, enemies[i].position) < 3) {
                                gameOver = true;
                                player.isVisible = false;
                                console.log("GAME OVER! Final Score: " + score);
                                break;
                            }
                        }
                    });

                    const ui = BABYLON.GUI.AdvancedDynamicTexture.CreateFullscreenUI("UI");
                    const scoreText = new BABYLON.GUI.TextBlock();
                    scoreText.text = "Score: 0";
                    scoreText.color = "white";
                    scoreText.fontSize = 24;
                    scoreText.textHorizontalAlignment = BABYLON.GUI.Control.HORIZONTAL_ALIGNMENT_LEFT;
                    scoreText.textVerticalAlignment = BABYLON.GUI.Control.VERTICAL_ALIGNMENT_TOP;
                    scoreText.left = "10px";
                    scoreText.top = "10px";
                    ui.addControl(scoreText);

                    const controlsText = new BABYLON.GUI.TextBlock();
                    controlsText.text = "WASD/Arrows: Move | SPACE: Fire";
                    controlsText.color = "cyan";
                    controlsText.fontSize = 18;
                    controlsText.textHorizontalAlignment = BABYLON.GUI.Control.HORIZONTAL_ALIGNMENT_CENTER;
                    controlsText.textVerticalAlignment = BABYLON.GUI.Control.VERTICAL_ALIGNMENT_BOTTOM;
                    controlsText.top = "-10px";
                    ui.addControl(controlsText);

                    scene.registerBeforeRender(() => {
                        scoreText.text = "Score: " + score + (gameOver ? " - GAME OVER" : "");
                    });

                    console.log("🎮 Space Harrier Game Started!");
                    console.log("Full version: https://playground.babylonjs.com/#WJ20GP#16");
                    return scene;
                };

                export default createScene;
                """,
                category: .interaction,
                difficulty: .advanced,
                keywords: [
                    "game", "arcade", "space-harrier", "shooter", "retro",
                    "keyboard-controls", "projectiles", "collision-detection",
                    "score-system", "enemy-spawning", "camera-follow", "gameplay"
                ],
                aiPromptHints: """
                When users request arcade shooter, Space Harrier, or game development:

                1. GAME LOOP: Use scene.registerBeforeRender() for updates
                   - Player movement based on keyboard input
                   - Projectile and enemy position updates
                   - Collision detection between all entities
                   - Score tracking and game over conditions

                2. INPUT HANDLING: Multi-key support with state tracking
                   - Keyboard: WASD + Arrow keys (both work simultaneously)
                   - Space bar for firing with rate limiting
                   - Track key states in object: {w: false, a: false, ...}
                   - Handle both KEYDOWN and KEYUP events

                3. ENTITY MANAGEMENT: Arrays for dynamic objects
                   - enemies[] array for tracking all enemies
                   - projectiles[] array for all bullets
                   - Use reverse iteration when removing (for loop from end)
                   - Dispose meshes when removing to prevent memory leaks

                4. COLLISION DETECTION: Distance-based hit testing
                   - BABYLON.Vector3.Distance() for proximity checks
                   - Projectile vs Enemy: award points, remove both
                   - Player vs Enemy: trigger game over
                   - Use threshold distances (< 2 for projectile, < 3 for player)

                5. CAMERA SYSTEM: FollowCamera for smooth tracking
                   - camera.lockedTarget = player
                   - Set radius and heightOffset for good view angle
                   - Camera automatically follows player movement

                6. UI OVERLAY: BABYLON.GUI for HUD elements
                   - Score display in corner (updated every frame)
                   - Controls instructions at bottom
                   - Position with textHorizontalAlignment/textVerticalAlignment
                   - Use AdvancedDynamicTexture.CreateFullscreenUI()

                TECHNICAL IMPLEMENTATION:
                - Clamp player position to boundaries (min/max x and y)
                - Fire rate limiting with lastFireTime timestamp
                - Projectile lifespan check (dispose if too far)
                - Enemy spawn probability check each frame
                - Max enemy count to prevent performance issues

                SIMPLIFIED VS FULL:
                This is a simplified version for demonstration.
                Full version at https://playground.babylonjs.com/#WJ20GP#16 includes:
                - Multi-scene system (start, game, game over screens)
                - VoxelVader procedural enemies
                - Touch controls and virtual joystick
                - Particle effects for explosions
                - Sound effects and advanced camera modes
                """
            )
        ]
    }
}
