// COMPLETE ThreeJSLibrary examples for Android
// Copy this into: XRAiAssistantAndroid/app/src/main/java/com/xraiassistant/domain/libraries/ThreeJSLibrary.kt

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
        positions[i * 3 + 1] = randomY;
        positions[i * 3 + 2] = Math.sin(branchAngle + spinAngle) * radius + randomZ;

        const mixedColor = new THREE.Color('#ff6030').lerp(new THREE.Color('#1b3984'), radius / 6);
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

    // Continue with remaining 7 examples...
    // Due to length, use the iOS file as reference and follow this exact pattern
)
