import Foundation

struct ThreeJSLibrary: Library3D {
    let id = "threejs"
    let displayName = "Three.js"
    let description = "Popular, lightweight 3D library with large community"
    let version = "r160"
    let playgroundTemplate = "playground-threejs.html"
    let codeLanguage = CodeLanguage.javascript
    let iconName = "scribble.variable"
    let documentationURL = "https://threejs.org/docs/"
    
    let supportedFeatures: Set<Library3DFeature> = [
        .webgl, .webxr, .vr, .ar, .animation, 
        .lighting, .materials, .postProcessing, .imperative
    ]
    
    var systemPrompt: String {
        return """
        You are an expert Three.js assistant helping users create 3D scenes and learn Three.js.
        You are a **creative Three.js mentor** who helps users bring 3D ideas to life in the Playground.
        Your role is not just technical but also **artistic**: you suggest imaginative variations,
        playful enhancements, and visually interesting touches — while always delivering
        **fully working Three.js r160 code**
        
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
        
        IMPORTANT API USAGE:
        - Use THREE.BoxGeometry(), THREE.SphereGeometry(), THREE.PlaneGeometry()
        - Use THREE.MeshPhongMaterial(), THREE.MeshBasicMaterial(), THREE.MeshStandardMaterial()
        - Use THREE.Mesh(geometry, material) to create objects
        - Use scene.add(object) to add objects to the scene
        - Use THREE.Vector3(x, y, z) for positions
        - Use THREE.Color(hex) for colors
        - Use object.position.set(x, y, z) for positioning
        - Use object.rotation.set(x, y, z) for rotation

        POSTPROCESSING EFFECTS (AVAILABLE):
        Three.js r160 includes powerful postprocessing capabilities loaded from local files.
        Available globally: EffectComposer, RenderPass, UnrealBloomPass, ShaderPass, OutputPass

        Example: Adding bloom effect to your scene
        const composer = new EffectComposer(renderer);
        const renderPass = new RenderPass(scene, camera);
        composer.addPass(renderPass);

        const bloomPass = new UnrealBloomPass(
            new THREE.Vector2(window.innerWidth, window.innerHeight),
            1.5,  // strength
            0.4,  // radius
            0.85  // threshold
        );
        composer.addPass(bloomPass);

        const outputPass = new OutputPass();
        composer.addPass(outputPass);

        // IMPORTANT: Replace the default render loop with composer
        function animate() {
            requestAnimationFrame(animate);
            composer.render(); // Use composer instead of renderer.render()
        }
        animate();

        VISUAL EFFECTS (Without Post-Processing):
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
        - Use postprocessing for bloom, depth of field, and other effects
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
        - To insert code, wrap it in: [INSERT_CODE]```javascript\ncode here\n```[/INSERT_CODE]
        - To run the scene, use: [RUN_SCENE]
        
        Mindset: Be a creative partner who understands Three.js patterns. Create scenes that showcase the power and flexibility of Three.js while being educational and inspiring.
        ALWAYS generate code for ANY 3D-related request. Make Three.js accessible and fun!
        """
    }
    
    var defaultSceneCode: String {
        return """
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
        """
    }

    var examples: [CodeExample] {
        return [
            CodeExample(
                title: "Neon Cubes",
                description: "Rotating cubes with neon materials and emissive glow",
                code: """
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
                """,
                category: .basic,
                difficulty: .beginner
            ),

            CodeExample(
                title: "Particle Spiral Galaxy",
                description: "Thousands of particles forming a rotating spiral galaxy",
                code: """
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
                """,
                category: .effects,
                difficulty: .intermediate
            ),

            CodeExample(
                title: "Morphing Geometry",
                description: "Smooth morphing animation between different 3D shapes",
                code: """
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
                """,
                category: .animation,
                difficulty: .advanced
            ),

            CodeExample(
                title: "Interactive Color Spheres",
                description: "Click spheres to change colors with smooth hover effects",
                code: """
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
                """,
                category: .interaction,
                difficulty: .intermediate
            ),

            CodeExample(
                title: "Glowing Torus Knots",
                description: "Beautiful animated torus knots with bloom post-processing",
                code: """
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
                """,
                category: .advanced,
                difficulty: .advanced
            )
        ]
    }
}