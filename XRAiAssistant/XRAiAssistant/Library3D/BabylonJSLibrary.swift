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
            )
        ]
    }
}