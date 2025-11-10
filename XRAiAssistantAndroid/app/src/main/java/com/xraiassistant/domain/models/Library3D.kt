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
    val examples: List<CodeExample>  // Code examples for this library

    /**
     * Generate welcome message with random example
     * Matches iOS getWelcomeMessage() implementation
     */
    fun getWelcomeMessage(): String {
        if (examples.isEmpty()) {
            return """
                Welcome to $displayName!

                Start creating amazing 3D scenes with AI assistance.
                Just describe what you want to create and I'll generate the code for you!
            """.trimIndent()
        }

        val randomExample = examples.random()
        return """
            Welcome to $displayName!

            Try this example: ${randomExample.title}
            ${randomExample.description}
        """.trimIndent()
    }
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
    DECLARATIVE,
    BASIC_PRIMITIVES,
    VR_AR,
    DECLARATIVE_SYNTAX
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
        Your role is not just technical but also **artistic**: you suggest imaginative variations, playful enhancements, and visually interesting touches — while always delivering **fully working Babylon.js v6+ code**

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
        - To insert code, wrap it in: [INSERT_CODE]```javascript
code here
```[/INSERT_CODE]
        - To run the scene, use: [RUN_SCENE]

        Mindset: Be a creative partner, not just a code generator. Surprise the user with clever but lightweight enhancements that keep scenes fun, learnable, and visually engaging.
        ALWAYS generate code for ANY 3D-related request. Even simple questions like "create a cube" should result in complete working code. Be proactive and creative with 3D scenes!
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

    override val examples = listOf(
        CodeExample(
            title = "Floating Crystals",
            description = "Three floating metallic crystals with glow effects and smooth animation",
            code = """
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
            """.trimIndent(),
            category = ExampleCategory.BASIC,
            difficulty = ExampleDifficulty.BEGINNER
        ),

        CodeExample(
            title = "Sphere with Physics",
            description = "Bouncing sphere with gravity using Babylon.js physics engine",
            code = """
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
            """.trimIndent(),
            category = ExampleCategory.PHYSICS,
            difficulty = ExampleDifficulty.INTERMEDIATE
        ),

        CodeExample(
            title = "Animated Path Following",
            description = "Object following a curved path with smooth animation",
            code = """
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
            """.trimIndent(),
            category = ExampleCategory.ANIMATION,
            difficulty = ExampleDifficulty.INTERMEDIATE
        ),

        CodeExample(
            title = "Dynamic Lighting Scene",
            description = "Multiple colored lights creating dramatic atmosphere",
            code = """
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
            """.trimIndent(),
            category = ExampleCategory.LIGHTING,
            difficulty = ExampleDifficulty.INTERMEDIATE
        ),

        CodeExample(
            title = "PBR Materials Showcase",
            description = "Physically based rendering with metallic and roughness properties",
            code = """
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
            """.trimIndent(),
            category = ExampleCategory.MATERIALS,
            difficulty = ExampleDifficulty.INTERMEDIATE
        ),

        CodeExample(
            title = "Glow Effect (Bloom)",
            description = "Glowing objects with bloom post-processing effect",
            code = """
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
            """.trimIndent(),
            category = ExampleCategory.EFFECTS,
            difficulty = ExampleDifficulty.INTERMEDIATE
        ),

        CodeExample(
            title = "Click Interaction",
            description = "Interactive objects that respond to mouse clicks",
            code = """
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
            """.trimIndent(),
            category = ExampleCategory.INTERACTION,
            difficulty = ExampleDifficulty.INTERMEDIATE
        ),

        CodeExample(
            title = "Holographic Torus Array",
            description = "Mesmerizing array of torus meshes with holographic glow and wave animation",
            code = """
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
            """.trimIndent(),
            category = ExampleCategory.ADVANCED,
            difficulty = ExampleDifficulty.ADVANCED
        ),

        CodeExample(
            title = "Particle Fountain",
            description = "Colorful particle system creating a fountain effect",
            code = """
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
            """.trimIndent(),
            category = ExampleCategory.EFFECTS,
            difficulty = ExampleDifficulty.INTERMEDIATE
        ),

        CodeExample(
            title = "Fractal Sphere Grid",
            description = "Grid of spheres with fractal-like scaling and rotation patterns",
            code = """
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
            """.trimIndent(),
            category = ExampleCategory.ADVANCED,
            difficulty = ExampleDifficulty.ADVANCED
        ),

        CodeExample(
            title = "Skybox with Fog",
            description = "Atmospheric scene with skybox and volumetric fog effects",
            code = """
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
            """.trimIndent(),
            category = ExampleCategory.EFFECTS,
            difficulty = ExampleDifficulty.INTERMEDIATE
        ),

        CodeExample(
            title = "Plasma Orb",
            description = "Pulsating orb with dynamic material and electric effects",
            code = """
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
            """.trimIndent(),
            category = ExampleCategory.ADVANCED,
            difficulty = ExampleDifficulty.ADVANCED
        ),

        CodeExample(
            title = "Spotlight Showcase",
            description = "Multiple spotlights illuminating objects with shadows",
            code = """
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
            """.trimIndent(),
            category = ExampleCategory.LIGHTING,
            difficulty = ExampleDifficulty.INTERMEDIATE
        ),

        CodeExample(
            id = "voxel-wormhole",
            title = "Infinite Voxel Wormhole",
            description = "Procedurally generated infinite tunnel using simplex noise with dynamic colors and bloom effects",
            code = """
                const createScene = () => {
                    const scene = new BABYLON.Scene(engine);
                    scene.clearColor = new BABYLON.Color3(0, 0, 0);

                    const camera = new BABYLON.ArcRotateCamera("camera1", 0, 0, 30, new BABYLON.Vector3(0, 0, 0), scene);
                    if (camera.attachControls) {
                        camera.attachControls(canvas, true);
                    }

                    const light = new BABYLON.HemisphericLight("light1", new BABYLON.Vector3(0, 1, 0), scene);
                    light.intensity = 0.7;

                    const gl = new BABYLON.GlowLayer("glow", scene);
                    gl.intensity = 1.5;

                    // Simplified noise implementation
                    function noise(x, y, z) {
                        const X = Math.floor(x) & 255;
                        const Y = Math.floor(y) & 255;
                        const Z = Math.floor(z) & 255;
                        x -= Math.floor(x);
                        y -= Math.floor(y);
                        z -= Math.floor(z);
                        const u = x * x * x * (x * (x * 6 - 15) + 10);
                        const v = y * y * y * (y * (y * 6 - 15) + 10);
                        const w = z * z * z * (z * (z * 6 - 15) + 10);
                        return Math.sin(X * 12.9898 + Y * 78.233 + Z * 37.719) * 43758.5453 % 1;
                    }

                    const voxels = [];
                    const maxVoxels = 2000;
                    let cameraZ = 0;

                    function generateVoxels(zStart, zEnd) {
                        for(let z = zStart; z < zEnd; z += 2) {
                            const radius = 10;
                            for(let angle = 0; angle < Math.PI * 2; angle += Math.PI / 8) {
                                const x = Math.cos(angle) * radius;
                                const y = Math.sin(angle) * radius;
                                const noiseVal = noise(x * 0.1, y * 0.1, z * 0.05);

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

                    const star = BABYLON.MeshBuilder.CreatePolyhedron("star", {type: 1, size: 2}, scene);
                    const starMat = new BABYLON.PBRMaterial("starMat", scene);
                    starMat.albedoColor = new BABYLON.Color3(1, 0.9, 0.2);
                    starMat.metallic = 1;
                    starMat.roughness = 0.1;
                    starMat.emissiveColor = new BABYLON.Color3(1, 0.9, 0);
                    starMat.emissiveIntensity = 2;
                    star.material = starMat;

                    generateVoxels(-20, 40);

                    scene.registerBeforeRender(() => {
                        cameraZ += 0.5;
                        camera.target.z = cameraZ;

                        star.rotation.y += 0.05;
                        star.rotation.x += 0.03;

                        if(cameraZ % 20 === 0) {
                            const voxelsToRemove = voxels.filter(v => v.position.z < cameraZ - 30);
                            voxelsToRemove.forEach(v => {
                                v.dispose();
                                voxels.splice(voxels.indexOf(v), 1);
                            });
                            generateVoxels(cameraZ + 20, cameraZ + 40);
                        }
                    });

                    return scene;
                };
                const scene = createScene();
            """.trimIndent(),
            category = ExampleCategory.EFFECTS,
            difficulty = ExampleDifficulty.ADVANCED
        ),

        CodeExample(
            id = "tronscape-demo",
            title = "Retrowave Tronscape",
            description = "Epic synthwave landscape with procedural terrain, pink sun, and retro 80s aesthetics",
            code = """
                // Note: Simplified version - full implementation requires external DynamicTerrain library
                const createScene = () => {
                    const scene = new BABYLON.Scene(engine);
                    scene.clearColor = new BABYLON.Color4(0, 0, 0, 1);

                    const camera = new BABYLON.ArcRotateCamera("camera", 0, 1.2, 180, BABYLON.Vector3.Zero(), scene);
                    if (camera.attachControl) {
                        camera.attachControl(canvas, true);
                    }
                    camera.fov = 1.2;
                    camera.maxZ = 5000;

                    new BABYLON.HemisphericLight("light", new BABYLON.Vector3(0, 1, 0), scene);

                    // Pink sun
                    let sun = BABYLON.MeshBuilder.CreateDisc("sun", { radius: 15, tessellation: 64 }, scene);
                    let sunMat = new BABYLON.StandardMaterial("sunMat", scene);
                    sunMat.emissiveColor = new BABYLON.Color3(1, 0.2, 0.6);
                    sun.material = sunMat;
                    sun.position.set(0, 10, -30);

                    camera.position.set(-6.1, 5.69, -213.73);
                    camera.setTarget(sun.position);

                    // Create grid ground
                    const ground = BABYLON.MeshBuilder.CreateGround("ground", {width: 200, height: 200, subdivisions: 32}, scene);
                    const groundMat = new BABYLON.StandardMaterial("groundMat", scene);
                    groundMat.diffuseColor = new BABYLON.Color3(0, 0, 0);
                    groundMat.emissiveColor = new BABYLON.Color3(0, 1, 1);
                    groundMat.wireframe = true;
                    ground.material = groundMat;
                    ground.position.y = -2;

                    // Animate scrolling effect
                    scene.onBeforeRenderObservable.add(() => {
                        ground.position.z -= 0.2;
                        if (ground.position.z < -100) {
                            ground.position.z = 0;
                        }
                    });

                    // Fog
                    scene.fogMode = BABYLON.Scene.FOGMODE_LINEAR;
                    scene.fogStart = 300;
                    scene.fogEnd = 900;
                    scene.fogColor = new BABYLON.Color3(0,0,0);

                    return scene;
                };
                const scene = createScene();
            """.trimIndent(),
            category = ExampleCategory.EFFECTS,
            difficulty = ExampleDifficulty.ADVANCED
        )
    )
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
        **fully working Three.js r160 code**

        When users ask you ANYTHING about creating 3D scenes, objects, animations, or Three.js, ALWAYS respond with:
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

        IMPORTANT API USAGE:
        - Use THREE.BoxGeometry(), THREE.SphereGeometry(), THREE.PlaneGeometry()
        - Use THREE.MeshPhongMaterial(), THREE.MeshBasicMaterial(), THREE.MeshStandardMaterial()
        - Use THREE.Mesh(geometry, material) to create objects
        - Use scene.add(object) to add objects to the scene
        - Use THREE.Vector3(x, y, z) for positions
        - Use THREE.Color(hex) for colors
        - Use object.position.set(x, y, z) for positioning
        - Use object.rotation.set(x, y, z) for rotation

        VISUAL EFFECTS:
        Create stunning visual effects using emissive materials and creative lighting:

        // Glowing effect with emissive materials
        const glowMaterial = new THREE.MeshStandardMaterial({
            color: 0xff0000,        // Base color
            emissive: 0xff0000,     // Glow color (same as base for pure glow)
            emissiveIntensity: 0.8, // Glow strength (0-1, higher = brighter)
            metalness: 0.3,         // Metallic appearance (0-1)
            roughness: 0.4          // Surface roughness (0-1, lower = shinier)
        });

        Tips for Beautiful Scenes:
        - Use emissive + emissiveIntensity for self-illuminated objects
        - Combine ambient + directional lights for depth
        - Dark backgrounds (0x000011) make emissive materials pop
        - Use multiple colored lights for dramatic effects
        - Try transparent materials with opacity for layered effects

        CREATIVE GUIDELINES:
        - Always add interesting lighting (ambient + directional/point lights)
        - Use materials with realistic properties (metalness, roughness for StandardMaterial)
        - Add subtle animations with requestAnimationFrame patterns
        - Create interesting geometries and compositions
        - Consider adding fog, shadows, or post-processing effects
        - Use the camera controls for interactive viewing

        Special commands you MUST use:
        - To insert code, wrap it in: [INSERT_CODE]```javascript
code here
```[/INSERT_CODE]
        - To run the scene, use: [RUN_SCENE]

        Mindset: Be a creative partner who understands Three.js patterns. Create scenes that showcase the power and flexibility of Three.js while being educational and inspiring.
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

    override val examples = listOf(
        CodeExample(
            title = "Neon Cubes",
            description = "Rotating cubes with neon materials and emissive glow",
            code = """
                const createScene = () => {
                    const scene = new THREE.Scene();
                    scene.background = new THREE.Color(0x050510);
                    scene.fog = new THREE.Fog(0x050510, 10, 50);

                    const camera = new THREE.PerspectiveCamera(60, window.innerWidth / window.innerHeight, 0.1, 1000);
                    camera.position.set(0, 3, 10);

                    const ambientLight = new THREE.AmbientLight(0x404040, 0.3);
                    scene.add(ambientLight);

                    const pointLight = new THREE.PointLight(0xff00ff, 2, 50);
                    pointLight.position.set(5, 5, 5);
                    scene.add(pointLight);

                    // Create neon cubes
                    const colors = [0xff0080, 0x00ff80, 0x0080ff, 0xffff00];
                    const cubes = [];

                    for (let i = 0; i < 4; i++) {
                        const geometry = new THREE.BoxGeometry(1.5, 1.5, 1.5);
                        const material = new THREE.MeshStandardMaterial({
                            color: colors[i],
                            emissive: colors[i],
                            emissiveIntensity: 0.5,
                            metalness: 0.8,
                            roughness: 0.2
                        });

                        const cube = new THREE.Mesh(geometry, material);
                        cube.position.set(
                            (i - 1.5) * 2.5,
                            1,
                            0
                        );
                        scene.add(cube);
                        cubes.push(cube);
                    }

                    // Ground
                    const groundGeometry = new THREE.PlaneGeometry(20, 20);
                    const groundMaterial = new THREE.MeshStandardMaterial({
                        color: 0x0f0f20,
                        roughness: 0.8,
                        metalness: 0.2
                    });
                    const ground = new THREE.Mesh(groundGeometry, groundMaterial);
                    ground.rotation.x = -Math.PI / 2;
                    scene.add(ground);

                    // Animation
                    function animate() {
                        requestAnimationFrame(animate);

                        cubes.forEach((cube, i) => {
                            cube.rotation.x += 0.01;
                            cube.rotation.y += 0.01;
                            cube.position.y = 1 + Math.sin(Date.now() * 0.001 + i) * 0.3;
                        });

                        controls.update();
                        renderer.render(scene, camera);
                    }
                    animate();

                    return { scene, camera };
                };

                const { scene, camera } = createScene();
            """.trimIndent(),
            category = ExampleCategory.BASIC,
            difficulty = ExampleDifficulty.BEGINNER
        ),

        CodeExample(
            title = "Particle Spiral Galaxy",
            description = "Thousands of particles forming a rotating spiral galaxy",
            code = """
                const createScene = () => {
                    const scene = new THREE.Scene();
                    scene.background = new THREE.Color(0x000000);

                    const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
                    camera.position.set(0, 5, 15);

                    // Create particle system
                    const particleCount = 10000;
                    const positions = new Float32Array(particleCount * 3);
                    const colors = new Float32Array(particleCount * 3);

                    for (let i = 0; i < particleCount; i++) {
                        // Spiral galaxy formation
                        const radius = Math.random() * 10;
                        const spinAngle = radius * 2;
                        const branchAngle = (i % 3) * ((2 * Math.PI) / 3);

                        const randomX = Math.pow(Math.random(), 3) * (Math.random() < 0.5 ? 1 : -1);
                        const randomY = Math.pow(Math.random(), 3) * (Math.random() < 0.5 ? 1 : -1);
                        const randomZ = Math.pow(Math.random(), 3) * (Math.random() < 0.5 ? 1 : -1);

                        positions[i * 3] = Math.cos(branchAngle + spinAngle) * radius + randomX;
                        positions[i * 3 + 1] = randomY * 0.5;
                        positions[i * 3 + 2] = Math.sin(branchAngle + spinAngle) * radius + randomZ;

                        // Color gradient from center to edge
                        const colorInner = new THREE.Color(0xff6030);
                        const colorOuter = new THREE.Color(0x1b3984);
                        const mixedColor = colorInner.clone().lerp(colorOuter, radius / 10);

                        colors[i * 3] = mixedColor.r;
                        colors[i * 3 + 1] = mixedColor.g;
                        colors[i * 3 + 2] = mixedColor.b;
                    }

                    const geometry = new THREE.BufferGeometry();
                    geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
                    geometry.setAttribute('color', new THREE.BufferAttribute(colors, 3));

                    const material = new THREE.PointsMaterial({
                        size: 0.1,
                        vertexColors: true,
                        blending: THREE.AdditiveBlending,
                        transparent: true,
                        depthWrite: false
                    });

                    const particles = new THREE.Points(geometry, material);
                    scene.add(particles);

                    // Animation
                    function animate() {
                        requestAnimationFrame(animate);

                        particles.rotation.y += 0.001;

                        controls.update();
                        renderer.render(scene, camera);
                    }
                    animate();

                    return { scene, camera };
                };

                const { scene, camera } = createScene();
            """.trimIndent(),
            category = ExampleCategory.EFFECTS,
            difficulty = ExampleDifficulty.INTERMEDIATE
        ),

        CodeExample(
            title = "Morphing Geometry",
            description = "Smooth morphing animation between different 3D shapes",
            code = """
                const createScene = () => {
                    const scene = new THREE.Scene();
                    scene.background = new THREE.Color(0x1a1a2e);

                    const camera = new THREE.PerspectiveCamera(60, window.innerWidth / window.innerHeight, 0.1, 1000);
                    camera.position.set(0, 2, 8);

                    const ambientLight = new THREE.AmbientLight(0xffffff, 0.4);
                    scene.add(ambientLight);

                    const pointLight = new THREE.PointLight(0xffffff, 1);
                    pointLight.position.set(5, 5, 5);
                    scene.add(pointLight);

                    // Create geometries for morphing
                    const geometry1 = new THREE.BoxGeometry(2, 2, 2, 32, 32, 32);
                    const geometry2 = new THREE.SphereGeometry(1.5, 32, 32);
                    const geometry3 = new THREE.TorusGeometry(1, 0.4, 32, 100);

                    // Ensure all geometries have the same number of vertices
                    const maxVertices = Math.max(
                        geometry1.attributes.position.count,
                        geometry2.attributes.position.count,
                        geometry3.attributes.position.count
                    );

                    // Create morph targets
                    const geometry = geometry1.clone();
                    geometry.morphAttributes.position = [
                        geometry2.attributes.position,
                        geometry3.attributes.position
                    ];

                    const material = new THREE.MeshStandardMaterial({
                        color: 0x4ecdc4,
                        emissive: 0x4ecdc4,
                        emissiveIntensity: 0.2,
                        metalness: 0.7,
                        roughness: 0.3,
                        morphTargets: true
                    });

                    const mesh = new THREE.Mesh(geometry, material);
                    scene.add(mesh);

                    // Animation
                    function animate() {
                        requestAnimationFrame(animate);

                        const time = Date.now() * 0.001;

                        // Morph between shapes
                        mesh.morphTargetInfluences[0] = Math.sin(time * 0.5) * 0.5 + 0.5;
                        mesh.morphTargetInfluences[1] = Math.cos(time * 0.3) * 0.5 + 0.5;

                        mesh.rotation.x = time * 0.2;
                        mesh.rotation.y = time * 0.3;

                        controls.update();
                        renderer.render(scene, camera);
                    }
                    animate();

                    return { scene, camera };
                };

                const { scene, camera } = createScene();
            """.trimIndent(),
            category = ExampleCategory.ANIMATION,
            difficulty = ExampleDifficulty.ADVANCED
        ),

        CodeExample(
            title = "Interactive Color Spheres",
            description = "Click spheres to change colors with smooth hover effects",
            code = """
                const createScene = () => {
                    const scene = new THREE.Scene();
                    scene.background = new THREE.Color(0x0a0a1a);

                    const camera = new THREE.PerspectiveCamera(60, window.innerWidth / window.innerHeight, 0.1, 1000);
                    camera.position.set(0, 0, 10);

                    const ambientLight = new THREE.AmbientLight(0xffffff, 0.5);
                    scene.add(ambientLight);

                    const pointLight = new THREE.PointLight(0xffffff, 1);
                    pointLight.position.set(10, 10, 10);
                    scene.add(pointLight);

                    // Create interactive spheres
                    const spheres = [];
                    const colors = [0xff6b9d, 0x4080ff, 0x4ecdc4, 0xffe66d, 0xa26cf7];

                    for (let i = 0; i < 5; i++) {
                        const geometry = new THREE.SphereGeometry(0.8, 32, 32);
                        const material = new THREE.MeshStandardMaterial({
                            color: colors[i],
                            emissive: colors[i],
                            emissiveIntensity: 0.1,
                            metalness: 0.5,
                            roughness: 0.2
                        });

                        const sphere = new THREE.Mesh(geometry, material);
                        sphere.position.set((i - 2) * 2.5, 0, 0);
                        sphere.userData = {
                            baseScale: 1,
                            targetScale: 1,
                            colorIndex: i,
                            hovered: false
                        };
                        scene.add(sphere);
                        spheres.push(sphere);
                    }

                    // Raycaster for interaction
                    const raycaster = new THREE.Raycaster();
                    const mouse = new THREE.Vector2();

                    function onMouseMove(event) {
                        mouse.x = (event.clientX / window.innerWidth) * 2 - 1;
                        mouse.y = -(event.clientY / window.innerHeight) * 2 + 1;

                        raycaster.setFromCamera(mouse, camera);
                        const intersects = raycaster.intersectObjects(spheres);

                        spheres.forEach(sphere => {
                            sphere.userData.hovered = false;
                            sphere.userData.targetScale = 1;
                        });

                        if (intersects.length > 0) {
                            intersects[0].object.userData.hovered = true;
                            intersects[0].object.userData.targetScale = 1.3;
                        }
                    }

                    function onClick(event) {
                        mouse.x = (event.clientX / window.innerWidth) * 2 - 1;
                        mouse.y = -(event.clientY / window.innerHeight) * 2 + 1;

                        raycaster.setFromCamera(mouse, camera);
                        const intersects = raycaster.intersectObjects(spheres);

                        if (intersects.length > 0) {
                            const sphere = intersects[0].object;
                            sphere.userData.colorIndex = (sphere.userData.colorIndex + 1) % colors.length;
                            sphere.material.color.setHex(colors[sphere.userData.colorIndex]);
                            sphere.material.emissive.setHex(colors[sphere.userData.colorIndex]);
                        }
                    }

                    window.addEventListener('mousemove', onMouseMove);
                    window.addEventListener('click', onClick);

                    // Animation
                    function animate() {
                        requestAnimationFrame(animate);

                        spheres.forEach(sphere => {
                            // Smooth scale transition
                            sphere.scale.lerp(
                                new THREE.Vector3(
                                    sphere.userData.targetScale,
                                    sphere.userData.targetScale,
                                    sphere.userData.targetScale
                                ),
                                0.1
                            );

                            sphere.rotation.y += 0.01;
                        });

                        controls.update();
                        renderer.render(scene, camera);
                    }
                    animate();

                    return { scene, camera };
                };

                const { scene, camera } = createScene();
            """.trimIndent(),
            category = ExampleCategory.INTERACTION,
            difficulty = ExampleDifficulty.INTERMEDIATE
        ),

        CodeExample(
            title = "Glowing Torus Knots",
            description = "Beautiful animated torus knots with bloom post-processing",
            code = """
                const createScene = () => {
                    const scene = new THREE.Scene();
                    scene.background = new THREE.Color(0x000000);

                    const camera = new THREE.PerspectiveCamera(60, window.innerWidth / window.innerHeight, 0.1, 1000);
                    camera.position.set(0, 0, 15);

                    const ambientLight = new THREE.AmbientLight(0xffffff, 0.2);
                    scene.add(ambientLight);

                    // Create three torus knots
                    const knots = [];
                    const colors = [0xff006e, 0x00f5ff, 0xffbe0b];

                    for (let i = 0; i < 3; i++) {
                        const geometry = new THREE.TorusKnotGeometry(1.5, 0.5, 100, 16, 2 + i, 3);
                        const material = new THREE.MeshStandardMaterial({
                            color: colors[i],
                            emissive: colors[i],
                            emissiveIntensity: 0.8,
                            metalness: 0.9,
                            roughness: 0.1
                        });

                        const knot = new THREE.Mesh(geometry, material);
                        knot.position.set((i - 1) * 5, 0, 0);
                        scene.add(knot);
                        knots.push(knot);
                    }

                    // Animation
                    function animate() {
                        requestAnimationFrame(animate);

                        const time = Date.now() * 0.001;

                        knots.forEach((knot, i) => {
                            knot.rotation.x = time * (0.3 + i * 0.1);
                            knot.rotation.y = time * (0.2 + i * 0.1);
                            knot.position.y = Math.sin(time + i * 2) * 1.5;
                        });

                        controls.update();
                        renderer.render(scene, camera);
                    }
                    animate();

                    return { scene, camera };
                };

                const { scene, camera } = createScene();
            """.trimIndent(),
            category = ExampleCategory.ADVANCED,
            difficulty = ExampleDifficulty.ADVANCED
        ),

        CodeExample(
            title = "Wireframe Geometry Dance",
            description = "Animated wireframe geometries with pulsing effects",
            code = """
                const createScene = () => {
                    const scene = new THREE.Scene();
                    scene.background = new THREE.Color(0x0a0a0a);

                    const camera = new THREE.PerspectiveCamera(60, window.innerWidth / window.innerHeight, 0.1, 1000);
                    camera.position.set(0, 5, 12);

                    const ambientLight = new THREE.AmbientLight(0x404040, 0.5);
                    scene.add(ambientLight);

                    // Create wireframe objects
                    const objects = [];
                    const geometries = [
                        new THREE.IcosahedronGeometry(1.5, 0),
                        new THREE.OctahedronGeometry(1.5),
                        new THREE.TetrahedronGeometry(1.5)
                    ];

                    const colors = [0xff00ff, 0x00ffff, 0xffff00];

                    for (let i = 0; i < 3; i++) {
                        const material = new THREE.MeshBasicMaterial({
                            color: colors[i],
                            wireframe: true,
                            wireframeLinewidth: 2
                        });

                        const mesh = new THREE.Mesh(geometries[i], material);
                        mesh.position.set((i - 1) * 4, 0, 0);
                        scene.add(mesh);
                        objects.push(mesh);

                        // Add inner solid mesh
                        const innerMaterial = new THREE.MeshStandardMaterial({
                            color: colors[i],
                            emissive: colors[i],
                            emissiveIntensity: 0.3,
                            metalness: 0.8,
                            roughness: 0.2,
                            transparent: true,
                            opacity: 0.3
                        });
                        const innerMesh = new THREE.Mesh(geometries[i].clone(), innerMaterial);
                        innerMesh.scale.set(0.8, 0.8, 0.8);
                        mesh.add(innerMesh);
                    }

                    // Ground grid
                    const gridHelper = new THREE.GridHelper(20, 20, 0x444444, 0x222222);
                    scene.add(gridHelper);

                    // Animation
                    function animate() {
                        requestAnimationFrame(animate);

                        const time = Date.now() * 0.001;

                        objects.forEach((obj, i) => {
                            obj.rotation.x = time * (0.5 + i * 0.2);
                            obj.rotation.y = time * (0.3 + i * 0.15);

                            const pulse = Math.sin(time * 2 + i) * 0.3 + 1;
                            obj.scale.set(pulse, pulse, pulse);

                            obj.position.y = Math.sin(time + i * 1.5) * 1.5;
                        });

                        controls.update();
                        renderer.render(scene, camera);
                    }
                    animate();

                    return { scene, camera };
                };

                const { scene, camera } = createScene();
            """.trimIndent(),
            category = ExampleCategory.EFFECTS,
            difficulty = ExampleDifficulty.INTERMEDIATE
        ),

        CodeExample(
            title = "Gradient Plane Wave",
            description = "Undulating plane with vertex displacement and gradient colors",
            code = """
                const createScene = () => {
                    const scene = new THREE.Scene();
                    scene.background = new THREE.Color(0x000033);

                    const camera = new THREE.PerspectiveCamera(60, window.innerWidth / window.innerHeight, 0.1, 1000);
                    camera.position.set(0, 8, 15);
                    camera.lookAt(0, 0, 0);

                    const ambientLight = new THREE.AmbientLight(0x404040, 0.6);
                    scene.add(ambientLight);

                    const pointLight = new THREE.PointLight(0xff00ff, 2, 50);
                    pointLight.position.set(0, 5, 0);
                    scene.add(pointLight);

                    // Create undulating plane
                    const geometry = new THREE.PlaneGeometry(20, 20, 50, 50);
                    const material = new THREE.MeshStandardMaterial({
                        color: 0x4080ff,
                        emissive: 0x2040ff,
                        emissiveIntensity: 0.5,
                        metalness: 0.7,
                        roughness: 0.3,
                        wireframe: false,
                        side: THREE.DoubleSide
                    });

                    const plane = new THREE.Mesh(geometry, material);
                    plane.rotation.x = -Math.PI / 2;
                    scene.add(plane);

                    const positionAttribute = geometry.getAttribute('position');
                    const originalPositions = positionAttribute.array.slice();

                    // Animation
                    function animate() {
                        requestAnimationFrame(animate);

                        const time = Date.now() * 0.001;

                        for (let i = 0; i < positionAttribute.count; i++) {
                            const x = originalPositions[i * 3];
                            const y = originalPositions[i * 3 + 1];

                            const distance = Math.sqrt(x * x + y * y);
                            const wave = Math.sin(distance * 0.5 - time * 2) * Math.cos(x * 0.3 + time) * 1.5;

                            positionAttribute.setZ(i, wave);
                        }

                        positionAttribute.needsUpdate = true;
                        geometry.computeVertexNormals();

                        pointLight.position.x = Math.sin(time) * 5;
                        pointLight.position.z = Math.cos(time) * 5;

                        controls.update();
                        renderer.render(scene, camera);
                    }
                    animate();

                    return { scene, camera };
                };

                const { scene, camera } = createScene();
            """.trimIndent(),
            category = ExampleCategory.ANIMATION,
            difficulty = ExampleDifficulty.ADVANCED
        ),

        CodeExample(
            title = "Ring Portal",
            description = "Concentric rings creating a portal effect with light trails",
            code = """
                const createScene = () => {
                    const scene = new THREE.Scene();
                    scene.background = new THREE.Color(0x000000);
                    scene.fog = new THREE.Fog(0x000000, 10, 40);

                    const camera = new THREE.PerspectiveCamera(60, window.innerWidth / window.innerHeight, 0.1, 1000);
                    camera.position.set(0, 0, 20);

                    const ambientLight = new THREE.AmbientLight(0x202020, 0.3);
                    scene.add(ambientLight);

                    // Create concentric rings
                    const rings = [];
                    const ringCount = 15;

                    for (let i = 0; i < ringCount; i++) {
                        const radius = 0.5 + i * 0.5;
                        const geometry = new THREE.TorusGeometry(radius, 0.05, 16, 100);

                        const hue = i / ringCount;
                        const color = new THREE.Color().setHSL(hue, 1.0, 0.5);

                        const material = new THREE.MeshStandardMaterial({
                            color: color,
                            emissive: color,
                            emissiveIntensity: 0.8,
                            metalness: 0.9,
                            roughness: 0.1
                        });

                        const ring = new THREE.Mesh(geometry, material);
                        ring.position.z = -i * 1.5;
                        scene.add(ring);
                        rings.push(ring);
                    }

                    // Central point light
                    const centerLight = new THREE.PointLight(0x00ffff, 3, 30);
                    centerLight.position.set(0, 0, -20);
                    scene.add(centerLight);

                    // Animation
                    function animate() {
                        requestAnimationFrame(animate);

                        const time = Date.now() * 0.001;

                        rings.forEach((ring, i) => {
                            ring.rotation.z = time * (0.2 + i * 0.05);

                            const pulse = Math.sin(time * 2 - i * 0.3) * 0.1 + 1;
                            ring.scale.set(pulse, pulse, 1);

                            const zOffset = ((time * 5 + i) % ringCount) * 1.5 - ringCount * 1.5;
                            ring.position.z = zOffset;
                        });

                        centerLight.intensity = 2 + Math.sin(time * 4) * 1;

                        controls.update();
                        renderer.render(scene, camera);
                    }
                    animate();

                    return { scene, camera };
                };

                const { scene, camera } = createScene();
            """.trimIndent(),
            category = ExampleCategory.ADVANCED,
            difficulty = ExampleDifficulty.ADVANCED
        ),

        CodeExample(
            title = "Bouncing Spheres Physics",
            description = "Multiple spheres with simulated physics and collision effects",
            code = """
                const createScene = () => {
                    const scene = new THREE.Scene();
                    scene.background = new THREE.Color(0x1a1a2e);

                    const camera = new THREE.PerspectiveCamera(60, window.innerWidth / window.innerHeight, 0.1, 1000);
                    camera.position.set(0, 8, 15);

                    const ambientLight = new THREE.AmbientLight(0x404040, 0.5);
                    scene.add(ambientLight);

                    const directionalLight = new THREE.DirectionalLight(0xffffff, 0.8);
                    directionalLight.position.set(5, 10, 5);
                    scene.add(directionalLight);

                    // Create spheres with physics properties
                    const spheres = [];
                    const colors = [0xff6b9d, 0x4080ff, 0x4ecdc4, 0xffe66d, 0xa26cf7];

                    for (let i = 0; i < 5; i++) {
                        const geometry = new THREE.SphereGeometry(0.7, 32, 32);
                        const material = new THREE.MeshStandardMaterial({
                            color: colors[i],
                            emissive: colors[i],
                            emissiveIntensity: 0.2,
                            metalness: 0.5,
                            roughness: 0.3
                        });

                        const sphere = new THREE.Mesh(geometry, material);
                        sphere.position.set(
                            (Math.random() - 0.5) * 8,
                            5 + Math.random() * 5,
                            (Math.random() - 0.5) * 8
                        );

                        sphere.userData.velocity = new THREE.Vector3(
                            (Math.random() - 0.5) * 0.2,
                            0,
                            (Math.random() - 0.5) * 0.2
                        );

                        scene.add(sphere);
                        spheres.push(sphere);
                    }

                    // Ground
                    const groundGeometry = new THREE.PlaneGeometry(20, 20);
                    const groundMaterial = new THREE.MeshStandardMaterial({
                        color: 0x16213e,
                        roughness: 0.8,
                        metalness: 0.2
                    });
                    const ground = new THREE.Mesh(groundGeometry, groundMaterial);
                    ground.rotation.x = -Math.PI / 2;
                    scene.add(ground);

                    // Walls
                    const wallMaterial = new THREE.MeshStandardMaterial({
                        color: 0x0f3460,
                        transparent: true,
                        opacity: 0.3
                    });

                    // Physics simulation
                    const gravity = -0.015;
                    const damping = 0.98;
                    const bounds = 9;

                    function animate() {
                        requestAnimationFrame(animate);

                        spheres.forEach(sphere => {
                            // Apply gravity
                            sphere.userData.velocity.y += gravity;

                            // Update position
                            sphere.position.add(sphere.userData.velocity);

                            // Ground collision
                            if (sphere.position.y - 0.7 <= 0) {
                                sphere.position.y = 0.7;
                                sphere.userData.velocity.y *= -0.8;
                            }

                            // Wall collisions
                            if (Math.abs(sphere.position.x) > bounds) {
                                sphere.position.x = Math.sign(sphere.position.x) * bounds;
                                sphere.userData.velocity.x *= -1;
                            }

                            if (Math.abs(sphere.position.z) > bounds) {
                                sphere.position.z = Math.sign(sphere.position.z) * bounds;
                                sphere.userData.velocity.z *= -1;
                            }

                            // Apply damping
                            sphere.userData.velocity.multiplyScalar(damping);

                            // Rotation
                            sphere.rotation.x += sphere.userData.velocity.length();
                            sphere.rotation.y += sphere.userData.velocity.length();
                        });

                        controls.update();
                        renderer.render(scene, camera);
                    }
                    animate();

                    return { scene, camera };
                };

                const { scene, camera } = createScene();
            """.trimIndent(),
            category = ExampleCategory.ANIMATION,
            difficulty = ExampleDifficulty.INTERMEDIATE
        )
    )
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

        When users ask you ANYTHING about creating 3D scenes, objects, animations, or React Three Fiber, ALWAYS respond with:
        1. A brief explanation of what you're creating
        2. The complete working TSX code wrapped in [INSERT_CODE]```typescript
code here
```[/INSERT_CODE]
        3. A brief explanation of key React Three Fiber concepts used
        4. Automatically add [RUN_SCENE] at the end to trigger code execution

        IMPORTANT Code Guidelines:
        - Always provide COMPLETE working code for a React Three Fiber app
        - Your code must follow this exact structure:

        import React, { useRef } from 'react'
        import { Canvas, useFrame } from '@react-three/fiber'
        import { OrbitControls } from '@react-three/drei'

        function RotatingBox() {
          const meshRef = useRef(null)

          useFrame((state, delta) => {
            if (meshRef.current) {
              meshRef.current.rotation.x += delta
            }
          })

          return (
            <mesh ref={meshRef}>
              <boxGeometry args={[1, 1, 1]} />
              <meshStandardMaterial color="orange" />
            </mesh>
          )
        }

        function App() {
          return (
            <Canvas
              style={{ width: '100%', height: '100%' }}
              camera={{ position: [0, 0, 5], fov: 75 }}
              gl={{ antialias: true }}
            >
              <ambientLight intensity={0.5} />
              <directionalLight position={[2, 2, 2]} intensity={1} />
              <RotatingBox />
              <OrbitControls />
            </Canvas>
          )
        }

        export default App

        CRITICAL RULES:
        - DO NOT include createRoot or root.render - the build system handles mounting
        - DO NOT import from 'react-dom/client' - not needed in App.js
        - ALWAYS export default App at the end
        - Import React and hooks from 'react'
        - Import Canvas and hooks from '@react-three/fiber'
        - Import helper components from '@react-three/drei'
        - Use functional components with hooks (useRef, useFrame, useThree, etc.)
        - Canvas should have style={{ width: '100%', height: '100%' }}
        - Use null checks when accessing refs: if (meshRef.current) { ... }

        IMPORTANT R3F PATTERNS:
        - Use <mesh>, <boxGeometry>, <meshStandardMaterial> for objects
        - Use useRef<THREE.Mesh>() for refs with proper typing
        - Use useFrame((state, delta) => {}) for animations
        - Use declarative positioning: <mesh position={[x, y, z]} />
        - Use color props as strings: color="hotpink" or color="#ff6b6b"
        - Group related objects with <group>
        - Use drei helpers: <OrbitControls />, <Text />, <Environment />

        CREATIVE GUIDELINES:
        - Always add interesting lighting (ambient + directional/point lights)
        - Use materials with realistic properties
        - Add smooth animations with useFrame
        - Create interesting component compositions
        - Consider using drei helpers for enhanced UX
        - Use proper TypeScript types for better development experience

        REACT PATTERNS:
        - Extract reusable components for complex objects
        - Use props to make components configurable
        - Use React state for interactive elements
        - Leverage useFrame for performance-optimized animations
        - Use useThree hook for accessing canvas state

        Special commands you MUST use:
        - To insert code, wrap it in: [INSERT_CODE]```typescript
code here
```[/INSERT_CODE]
        - To trigger code execution, use: [RUN_SCENE]

        Mindset: Be a creative partner who understands React patterns and Three.js. Create scenes that showcase the power of declarative 3D programming while being educational and inspiring.
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

    override val examples = listOf(
        CodeExample(
            title = "Floating Crystals",
            description = "Beautiful rotating crystals with gradient materials and glow effects",
            code = """
                import React, { useRef } from 'react'
                import { Canvas, useFrame } from '@react-three/fiber'
                import { OrbitControls, MeshTransmissionMaterial } from '@react-three/drei'

                function Crystal({ position, color, scale = 1 }) {
                  const meshRef = useRef(null)

                  useFrame((state) => {
                    if (meshRef.current) {
                      meshRef.current.rotation.y = state.clock.elapsedTime * 0.5
                      meshRef.current.position.y = position[1] + Math.sin(state.clock.elapsedTime + position[0]) * 0.2
                    }
                  })

                  return (
                    <mesh ref={meshRef} position={position} scale={scale}>
                      <octahedronGeometry args={[1, 0]} />
                      <meshStandardMaterial
                        color={color}
                        metalness={0.9}
                        roughness={0.1}
                        emissive={color}
                        emissiveIntensity={0.3}
                      />
                    </mesh>
                  )
                }

                function App() {
                  return (
                    <Canvas camera={{ position: [0, 0, 8], fov: 50 }}>
                      <color attach="background" args={['#050510']} />
                      <ambientLight intensity={0.3} />
                      <pointLight position={[10, 10, 10]} intensity={1} />
                      <pointLight position={[-10, -10, -10]} color="#4080ff" intensity={0.5} />

                      <Crystal position={[-2, 0, 0]} color="#ff6b9d" scale={0.8} />
                      <Crystal position={[0, 0, 0]} color="#4080ff" scale={1.2} />
                      <Crystal position={[2, 0, 0]} color="#ffd93d" scale={0.9} />

                      <OrbitControls enableDamping dampingFactor={0.05} />
                    </Canvas>
                  )
                }

                export default App
            """.trimIndent(),
            category = ExampleCategory.BASIC,
            difficulty = ExampleDifficulty.BEGINNER
        ),

        CodeExample(
            title = "Animated Galaxy",
            description = "Stunning galaxy with thousands of particles in spiral formation",
            code = """
                import React, { useRef, useMemo } from 'react'
                import { Canvas, useFrame } from '@react-three/fiber'
                import { OrbitControls } from '@react-three/drei'
                import * as THREE from 'three'

                function Galaxy() {
                  const points = useRef(null)

                  const particlesPosition = useMemo(() => {
                    const positions = new Float32Array(5000 * 3)
                    const colors = new Float32Array(5000 * 3)

                    for (let i = 0; i < 5000; i++) {
                      const radius = Math.random() * 6
                      const spinAngle = radius * 2
                      const branchAngle = (i % 3) * ((2 * Math.PI) / 3)

                      const randomX = Math.pow(Math.random(), 3) * (Math.random() < 0.5 ? 1 : -1)
                      const randomY = Math.pow(Math.random(), 3) * (Math.random() < 0.5 ? 1 : -1)
                      const randomZ = Math.pow(Math.random(), 3) * (Math.random() < 0.5 ? 1 : -1)

                      positions[i * 3] = Math.cos(branchAngle + spinAngle) * radius + randomX
                      positions[i * 3 + 1] = randomY
                      positions[i * 3 + 2] = Math.sin(branchAngle + spinAngle) * radius + randomZ

                      const mixedColor = new THREE.Color('#ff6030').lerp(new THREE.Color('#1b3984'), radius / 6)
                      colors[i * 3] = mixedColor.r
                      colors[i * 3 + 1] = mixedColor.g
                      colors[i * 3 + 2] = mixedColor.b
                    }

                    return { positions, colors }
                  }, [])

                  useFrame((state) => {
                    if (points.current) {
                      points.current.rotation.y = state.clock.elapsedTime * 0.05
                    }
                  })

                  return (
                    <points ref={points}>
                      <bufferGeometry>
                        <bufferAttribute
                          attach="attributes-position"
                          count={particlesPosition.positions.length / 3}
                          array={particlesPosition.positions}
                          itemSize={3}
                        />
                        <bufferAttribute
                          attach="attributes-color"
                          count={particlesPosition.colors.length / 3}
                          array={particlesPosition.colors}
                          itemSize={3}
                        />
                      </bufferGeometry>
                      <pointsMaterial
                        size={0.1}
                        sizeAttenuation={true}
                        depthWrite={false}
                        vertexColors={true}
                        blending={THREE.AdditiveBlending}
                      />
                    </points>
                  )
                }

                function App() {
                  return (
                    <Canvas camera={{ position: [0, 3, 8] }}>
                      <color attach="background" args={['#000000']} />
                      <Galaxy />
                      <OrbitControls enableDamping autoRotate autoRotateSpeed={0.5} />
                    </Canvas>
                  )
                }

                export default App
            """.trimIndent(),
            category = ExampleCategory.EFFECTS,
            difficulty = ExampleDifficulty.INTERMEDIATE
        ),

        CodeExample(
            title = "Bouncing Balls Physics",
            description = "Colorful balls with realistic bouncing physics and trails",
            code = """
                import React, { useRef } from 'react'
                import { Canvas, useFrame } from '@react-three/fiber'
                import { OrbitControls, Trail } from '@react-three/drei'

                function BouncingBall({ position, color, speed = 1 }) {
                  const meshRef = useRef(null)
                  const velocity = useRef(0)
                  const posY = useRef(position[1])

                  useFrame((state, delta) => {
                    if (meshRef.current) {
                      velocity.current -= 9.8 * delta * speed
                      posY.current += velocity.current * delta

                      if (posY.current < 0.5) {
                        posY.current = 0.5
                        velocity.current = Math.abs(velocity.current) * 0.8
                      }

                      meshRef.current.position.y = posY.current
                      meshRef.current.rotation.x += delta * 2
                      meshRef.current.rotation.z += delta * 3
                    }
                  })

                  return (
                    <Trail width={2} length={8} color={color} attenuation={(t) => t * t}>
                      <mesh ref={meshRef} position={position} castShadow>
                        <sphereGeometry args={[0.5, 32, 32]} />
                        <meshStandardMaterial
                          color={color}
                          metalness={0.3}
                          roughness={0.4}
                          emissive={color}
                          emissiveIntensity={0.2}
                        />
                      </mesh>
                    </Trail>
                  )
                }

                function App() {
                  return (
                    <Canvas shadows camera={{ position: [0, 3, 10], fov: 50 }}>
                      <color attach="background" args={['#1a1a2e']} />
                      <ambientLight intensity={0.4} />
                      <directionalLight position={[5, 10, 5]} intensity={1} castShadow />
                      <pointLight position={[-5, 5, -5]} color="#ff6b9d" intensity={0.5} />

                      <BouncingBall position={[-2, 5, 0]} color="#ff6b9d" speed={1} />
                      <BouncingBall position={[0, 8, 0]} color="#4ecdc4" speed={0.8} />
                      <BouncingBall position={[2, 6, 0]} color="#ffe66d" speed={1.2} />

                      <mesh rotation={[-Math.PI / 2, 0, 0]} position={[0, 0, 0]} receiveShadow>
                        <planeGeometry args={[20, 20]} />
                        <meshStandardMaterial color="#0f3460" roughness={0.8} />
                      </mesh>

                      <OrbitControls />
                    </Canvas>
                  )
                }

                export default App
            """.trimIndent(),
            category = ExampleCategory.ANIMATION,
            difficulty = ExampleDifficulty.INTERMEDIATE
        ),

        CodeExample(
            title = "Interactive Color Spheres",
            description = "Click spheres to change colors with smooth transitions",
            code = """
                import React, { useRef, useState } from 'react'
                import { Canvas, useFrame } from '@react-three/fiber'
                import { OrbitControls, Text } from '@react-three/drei'
                import * as THREE from 'three'

                function InteractiveSphere({ position }) {
                  const meshRef = useRef(null)
                  const [hovered, setHovered] = useState(false)
                  const [active, setActive] = useState(false)
                  const [color, setColor] = useState('#4080ff')

                  const colors = ['#ff6b9d', '#4080ff', '#4ecdc4', '#ffe66d', '#a26cf7']

                  useFrame((state) => {
                    if (meshRef.current) {
                      meshRef.current.scale.x = THREE.MathUtils.lerp(
                        meshRef.current.scale.x,
                        hovered ? 1.3 : active ? 1.15 : 1,
                        0.1
                      )
                      meshRef.current.scale.y = meshRef.current.scale.x
                      meshRef.current.scale.z = meshRef.current.scale.x

                      meshRef.current.rotation.y += 0.01
                    }
                  })

                  const handleClick = () => {
                    setActive(!active)
                    setColor(colors[Math.floor(Math.random() * colors.length)])
                  }

                  return (
                    <mesh
                      ref={meshRef}
                      position={position}
                      onClick={handleClick}
                      onPointerOver={() => setHovered(true)}
                      onPointerOut={() => setHovered(false)}
                    >
                      <sphereGeometry args={[0.8, 32, 32]} />
                      <meshStandardMaterial
                        color={color}
                        metalness={0.5}
                        roughness={0.2}
                        emissive={color}
                        emissiveIntensity={active ? 0.5 : 0.1}
                      />
                    </mesh>
                  )
                }

                function App() {
                  return (
                    <Canvas camera={{ position: [0, 0, 8] }}>
                      <color attach="background" args={['#0a0a1a']} />
                      <ambientLight intensity={0.5} />
                      <pointLight position={[10, 10, 10]} intensity={1} />

                      <Text position={[0, 3, 0]} fontSize={0.5} color="#ffffff">
                        Click the spheres!
                      </Text>

                      <InteractiveSphere position={[-2.5, 0, 0]} />
                      <InteractiveSphere position={[0, 0, 0]} />
                      <InteractiveSphere position={[2.5, 0, 0]} />

                      <OrbitControls />
                    </Canvas>
                  )
                }

                export default App
            """.trimIndent(),
            category = ExampleCategory.INTERACTION,
            difficulty = ExampleDifficulty.INTERMEDIATE
        ),

        CodeExample(
            title = "Holographic Torus Wave",
            description = "Mesmerizing wave of torus rings with holographic shader effect",
            code = """
                import React, { useRef } from 'react'
                import { Canvas, useFrame } from '@react-three/fiber'
                import { OrbitControls, MeshDistortMaterial } from '@react-three/drei'

                function TorusWave({ index, total }) {
                  const meshRef = useRef(null)
                  const offset = (index / total) * Math.PI * 2

                  useFrame((state) => {
                    if (meshRef.current) {
                      const time = state.clock.elapsedTime
                      meshRef.current.position.y = Math.sin(time + offset) * 2
                      meshRef.current.rotation.x = time * 0.3
                      meshRef.current.rotation.z = time * 0.2

                      const scale = 1 + Math.sin(time + offset) * 0.2
                      meshRef.current.scale.setScalar(scale)
                    }
                  })

                  const hue = (index / total) * 360
                  const color = `hsl(${'$'}{hue}, 80%, 60%)`

                  return (
                    <mesh ref={meshRef} position={[0, 0, index * 1.5 - (total * 1.5) / 2]}>
                      <torusGeometry args={[1, 0.3, 16, 100]} />
                      <MeshDistortMaterial
                        color={color}
                        metalness={0.8}
                        roughness={0.2}
                        distort={0.4}
                        speed={2}
                        emissive={color}
                        emissiveIntensity={0.3}
                      />
                    </mesh>
                  )
                }

                function App() {
                  const count = 8

                  return (
                    <Canvas camera={{ position: [0, 0, 15], fov: 60 }}>
                      <color attach="background" args={['#000511']} />
                      <ambientLight intensity={0.3} />
                      <pointLight position={[10, 10, 10]} intensity={1} color="#ffffff" />
                      <pointLight position={[-10, -10, -10]} intensity={0.5} color="#ff00ff" />

                      {Array.from({ length: count }).map((_, i) => (
                        <TorusWave key={i} index={i} total={count} />
                      ))}

                      <OrbitControls
                        enableDamping
                        dampingFactor={0.05}
                        autoRotate
                        autoRotateSpeed={0.5}
                      />
                    </Canvas>
                  )
                }

                export default App
            """.trimIndent(),
            category = ExampleCategory.ADVANCED,
            difficulty = ExampleDifficulty.ADVANCED
        )
    )
}