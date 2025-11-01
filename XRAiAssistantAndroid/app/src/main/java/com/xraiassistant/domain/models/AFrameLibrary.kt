package com.xraiassistant.domain.models

/**
 * A-Frame Library Implementation
 */
class AFrameLibrary : Library3D {
    override val id = "aframe"
    override val displayName = "A-Frame"
    override val description = "Web framework for building VR/AR experiences"
    override val version = "v1.7.0"
    override val playgroundTemplate = "playground-aframe.html"
    override val codeLanguage = CodeLanguage.HTML
    override val iconName = "view_3d"
    override val documentationURL = "https://aframe.io/docs/"
    override val requiresBuild = false
    
    override val supportedFeatures = setOf(
        Library3DFeature.WEBGL, Library3DFeature.WEBXR, Library3DFeature.VR,
        Library3DFeature.AR, Library3DFeature.ANIMATION, Library3DFeature.LIGHTING,
        Library3DFeature.MATERIALS, Library3DFeature.DECLARATIVE
    )
    
    override val systemPrompt = """
        You are an expert A-Frame assistant helping users create VR/AR scenes and learn A-Frame.
        You are a **creative A-Frame mentor** who helps users bring immersive 3D/VR ideas to life.
        Your role is not just technical but also **artistic**: you suggest imaginative variations,
        interactive VR elements, and immersive experiences — while always delivering
        **fully working A-Frame v1.7+ HTML code**

        When users ask you ANYTHING about creating 3D/VR scenes, objects, animations, or A-Frame, ALWAYS respond with:
        1. A brief explanation of what you're creating
        2. The complete working HTML code wrapped in [INSERT_CODE]```html
code here
```[/INSERT_CODE]
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

        IMPORTANT A-FRAME PATTERNS:
        - Use position="x y z" for 3D positioning
        - Use rotation="x y z" for rotations in degrees
        - Use color="#hex" or color="colorname" for colors
        - Use animation="property: rotation; to: 0 360 0; loop: true; dur: 4000" for animations
        - Use sound="src: #soundfile; autoplay: true" for audio
        - Use material="color: red; metalness: 0.2" for advanced materials
        - Use geometry="primitive: box; width: 2; height: 1; depth: 1" for custom geometries

        VR/AR SPECIFIC FEATURES:
        - Add hand-tracking with hand-controls component
        - Use teleport-controls for VR movement
        - Add haptic feedback with haptics component
        - Use raycaster for object selection
        - Add spatial audio with positional-audio
        - Consider room-scale VR with tracked-controls

        CREATIVE VR GUIDELINES:
        - Always think in 3D space - objects should surround the user
        - Add interactive elements users can click/gaze at
        - Use animations to bring the scene to life
        - Consider spatial audio for immersion
        - Add text elements for information or UI
        - Create environments that encourage exploration
        - Use lighting to set mood and atmosphere

        Special commands you MUST use:
        - To insert code, wrap it in: [INSERT_CODE]```html
code here
```[/INSERT_CODE]
        - To run the scene, use: [RUN_SCENE]

        Mindset: Think like a VR experience designer. Create immersive worlds that users want to explore and interact with. Make VR development accessible while showcasing the unique possibilities of immersive 3D.
        ALWAYS generate VR-ready code for ANY 3D-related request. Make every scene an invitation to step into virtual reality!
    """.trimIndent()
    
    override val defaultSceneCode = """
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
    """.trimIndent()

    override val examples = listOf(
        CodeExample(
            title = "Floating Neon Spheres",
            description = "Beautiful floating spheres with emissive materials and animation",
            code = """
                <a-scene embedded vr-mode-ui="enabled: true">
                <a-light type="ambient" color="#404040" intensity="0.5"></a-light>
                <a-light type="point" position="0 3 0" color="#ff6b9d" intensity="1.5"></a-light>
                <a-light type="point" position="3 2 -5" color="#4080ff" intensity="1.5"></a-light>

                <a-sphere
                position="-2 2 -5"
                radius="0.8"
                color="#ff6b9d"
                material="emissive: #ff6b9d; emissiveIntensity: 0.5; metalness: 0.8; roughness: 0.2"
                animation="property: position; to: -2 2.5 -5; direction: alternate; loop: true; dur: 2000; easing: easeInOutSine">
                </a-sphere>

                <a-sphere
                position="0 2.3 -5"
                radius="1"
                color="#4080ff"
                material="emissive: #4080ff; emissiveIntensity: 0.5; metalness: 0.8; roughness: 0.2"
                animation="property: position; to: 0 1.8 -5; direction: alternate; loop: true; dur: 2500; easing: easeInOutSine">
                </a-sphere>

                <a-sphere
                position="2 2 -5"
                radius="0.8"
                color="#ffd93d"
                material="emissive: #ffd93d; emissiveIntensity: 0.5; metalness: 0.8; roughness: 0.2"
                animation="property: position; to: 2 2.5 -5; direction: alternate; loop: true; dur: 1800; easing: easeInOutSine">
                </a-sphere>

                <a-plane
                position="0 0 -5"
                rotation="-90 0 0"
                width="15"
                height="15"
                color="#1a1a2e"
                material="metalness: 0.3; roughness: 0.7">
                </a-plane>

                <a-camera look-controls wasd-controls position="0 1.6 2">
                <a-cursor color="#ffffff"></a-cursor>
                </a-camera>
                </a-scene>
            """.trimIndent(),
            category = ExampleCategory.BASIC,
            difficulty = ExampleDifficulty.BEGINNER
        ),

        CodeExample(
            title = "Rotating Crystal Array",
            description = "Array of rotating crystals with metallic materials",
            code = """
                <a-scene embedded vr-mode-ui="enabled: true" background="color: #000511">
                <a-light type="ambient" color="#404040" intensity="0.4"></a-light>
                <a-light type="point" position="5 5 5" color="#ffffff" intensity="1.5"></a-light>
                <a-light type="point" position="-5 5 5" color="#ff00ff" intensity="1.0"></a-light>

                <a-box
                position="-2 2 -5"
                rotation="0 45 0"
                scale="1 1 1"
                color="#ff006e"
                material="metalness: 0.9; roughness: 0.1; emissive: #ff006e; emissiveIntensity: 0.3"
                animation="property: rotation; to: 360 360 360; loop: true; dur: 8000; easing: linear">
                </a-box>

                <a-octahedron
                position="0 2 -5"
                radius="1"
                color="#00f5ff"
                material="metalness: 0.9; roughness: 0.1; emissive: #00f5ff; emissiveIntensity: 0.3"
                animation="property: rotation; to: 0 360 0; loop: true; dur: 6000; easing: linear">
                </a-octahedron>

                <a-box
                position="2 2 -5"
                rotation="0 45 0"
                scale="1 1 1"
                color="#ffbe0b"
                material="metalness: 0.9; roughness: 0.1; emissive: #ffbe0b; emissiveIntensity: 0.3"
                animation="property: rotation; to: 360 360 360; loop: true; dur: 7000; easing: linear">
                </a-box>

                <a-plane
                position="0 0 -5"
                rotation="-90 0 0"
                width="20"
                height="20"
                color="#0a0a1a"
                material="metalness: 0.2; roughness: 0.8">
                </a-plane>

                <a-camera look-controls wasd-controls position="0 1.6 3">
                <a-cursor color="#ffffff"></a-cursor>
                </a-camera>
                </a-scene>
            """.trimIndent(),
            category = ExampleCategory.ANIMATION,
            difficulty = ExampleDifficulty.BEGINNER
        ),

        CodeExample(
            title = "Color Wave Animation",
            description = "Spheres with pulsing colors in a wave pattern",
            code = """
                <a-scene embedded vr-mode-ui="enabled: true" background="color: #1a1a2e">
                <a-light type="ambient" color="#404040" intensity="0.6"></a-light>
                <a-light type="directional" position="5 5 5" intensity="0.8"></a-light>

                <a-sphere
                position="-3 1.5 -5"
                radius="0.6"
                color="#ff6b9d"
                material="metalness: 0.5; roughness: 0.3"
                animation="property: scale; to: 1.3 1.3 1.3; direction: alternate; loop: true; dur: 1000; easing: easeInOutSine"
                animation__color="property: components.material.material.color; type: color; from: #ff6b9d; to: #ff0080; direction: alternate; loop: true; dur: 2000">
                </a-sphere>

                <a-sphere
                position="-1.5 1.5 -5"
                radius="0.6"
                color="#4ecdc4"
                material="metalness: 0.5; roughness: 0.3"
                animation="property: scale; to: 1.3 1.3 1.3; direction: alternate; loop: true; dur: 1200; easing: easeInOutSine; delay: 200"
                animation__color="property: components.material.material.color; type: color; from: #4ecdc4; to: #00a896; direction: alternate; loop: true; dur: 2000; delay: 200">
                </a-sphere>

                <a-sphere
                position="0 1.5 -5"
                radius="0.6"
                color="#ffe66d"
                material="metalness: 0.5; roughness: 0.3"
                animation="property: scale; to: 1.3 1.3 1.3; direction: alternate; loop: true; dur: 1000; easing: easeInOutSine; delay: 400"
                animation__color="property: components.material.material.color; type: color; from: #ffe66d; to: #ffb700; direction: alternate; loop: true; dur: 2000; delay: 400">
                </a-sphere>

                <a-sphere
                position="1.5 1.5 -5"
                radius="0.6"
                color="#a26cf7"
                material="metalness: 0.5; roughness: 0.3"
                animation="property: scale; to: 1.3 1.3 1.3; direction: alternate; loop: true; dur: 1200; easing: easeInOutSine; delay: 600"
                animation__color="property: components.material.material.color; type: color; from: #a26cf7; to: #7209b7; direction: alternate; loop: true; dur: 2000; delay: 600">
                </a-sphere>

                <a-sphere
                position="3 1.5 -5"
                radius="0.6"
                color="#4080ff"
                material="metalness: 0.5; roughness: 0.3"
                animation="property: scale; to: 1.3 1.3 1.3; direction: alternate; loop: true; dur: 1000; easing: easeInOutSine; delay: 800"
                animation__color="property: components.material.material.color; type: color; from: #4080ff; to: #0047ab; direction: alternate; loop: true; dur: 2000; delay: 800">
                </a-sphere>

                <a-plane
                position="0 0 -5"
                rotation="-90 0 0"
                width="15"
                height="15"
                color="#0f3460"
                material="metalness: 0.2; roughness: 0.8">
                </a-plane>

                <a-camera look-controls wasd-controls position="0 1.6 2">
                <a-cursor color="#ffffff"></a-cursor>
                </a-camera>
                </a-scene>
            """.trimIndent(),
            category = ExampleCategory.ANIMATION,
            difficulty = ExampleDifficulty.INTERMEDIATE
        ),

        CodeExample(
            title = "Interactive Hover Effects",
            description = "Hover over objects to see them grow and glow",
            code = """
                <a-scene embedded vr-mode-ui="enabled: true" background="color: #0a0a1a">
                <a-assets>
                <script>
                AFRAME.registerComponent('hover-grow', {
                init: function () {
                const el = this.el;
                el.addEventListener('mouseenter', function () {
                el.setAttribute('scale', '1.4 1.4 1.4');
                el.setAttribute('material', 'emissiveIntensity', 0.8);
                });
                el.addEventListener('mouseleave', function () {
                el.setAttribute('scale', '1 1 1');
                el.setAttribute('material', 'emissiveIntensity', 0.2);
                });
                }
                });
                </script>
                </a-assets>

                <a-light type="ambient" color="#505050" intensity="0.6"></a-light>
                <a-light type="point" position="0 3 0" color="#ffffff" intensity="1.5"></a-light>

                <a-sphere
                position="-2.5 1.5 -5"
                radius="0.7"
                color="#ff6b9d"
                material="emissive: #ff6b9d; emissiveIntensity: 0.2; metalness: 0.7; roughness: 0.3"
                hover-grow>
                </a-sphere>

                <a-box
                position="0 1.5 -5"
                scale="1 1 1"
                color="#4080ff"
                material="emissive: #4080ff; emissiveIntensity: 0.2; metalness: 0.7; roughness: 0.3"
                hover-grow>
                </a-box>

                <a-cylinder
                position="2.5 1.5 -5"
                radius="0.5"
                height="1.4"
                color="#4ecdc4"
                material="emissive: #4ecdc4; emissiveIntensity: 0.2; metalness: 0.7; roughness: 0.3"
                hover-grow>
                </a-cylinder>

                <a-text
                value="Hover over the shapes!"
                position="0 3 -4"
                align="center"
                color="#ffffff"
                width="6">
                </a-text>

                <a-plane
                position="0 0 -5"
                rotation="-90 0 0"
                width="15"
                height="15"
                color="#1a1a2e"
                material="metalness: 0.1; roughness: 0.9">
                </a-plane>

                <a-camera look-controls wasd-controls position="0 1.6 2">
                <a-cursor
                color="#ffffff"
                raycaster="objects: [hover-grow]">
                </a-cursor>
                </a-camera>
                </a-scene>
            """.trimIndent(),
            category = ExampleCategory.INTERACTION,
            difficulty = ExampleDifficulty.INTERMEDIATE
        ),

        CodeExample(
            title = "Neon City Lights",
            description = "Multiple colored lights creating a neon atmosphere",
            code = """
                <a-scene embedded vr-mode-ui="enabled: true" background="color: #0a0a0a">
                <a-light type="ambient" color="#202020" intensity="0.3"></a-light>

                <a-light
                type="point"
                position="3 3 -5"
                color="#ff0055"
                intensity="1.5"
                animation="property: position; to: -3 3 -5; direction: alternate; loop: true; dur: 3000; easing: easeInOutSine">
                </a-light>

                <a-light
                type="point"
                position="-3 3 -5"
                color="#00ff88"
                intensity="1.5"
                animation="property: position; to: 3 3 -5; direction: alternate; loop: true; dur: 3000; easing: easeInOutSine">
                </a-light>

                <a-light
                type="point"
                position="0 3 -2"
                color="#0088ff"
                intensity="1.5"
                animation="property: position; to: 0 3 -8; direction: alternate; loop: true; dur: 4000; easing: easeInOutSine">
                </a-light>

                <a-sphere
                position="0 1.5 -5"
                radius="1"
                color="#ffffff"
                material="metalness: 0.95; roughness: 0.05">
                </a-sphere>

                <a-text
                value="Neon City"
                position="0 3.5 -4"
                align="center"
                color="#ffffff"
                width="6">
                </a-text>

                <a-plane
                position="0 0 -5"
                rotation="-90 0 0"
                width="20"
                height="20"
                color="#1a1a1a"
                material="metalness: 0.3; roughness: 0.7">
                </a-plane>

                <a-camera look-controls wasd-controls position="0 1.6 3">
                <a-cursor color="#ffffff"></a-cursor>
                </a-camera>
                </a-scene>
            """.trimIndent(),
            category = ExampleCategory.LIGHTING,
            difficulty = ExampleDifficulty.INTERMEDIATE
        ),

        CodeExample(
            title = "VR Hand Controllers",
            description = "Enter VR mode to see hand controllers in action",
            code = """
                <a-scene embedded vr-mode-ui="enabled: true" background="color: #1a1a2e">
                <a-light type="ambient" color="#606060" intensity="0.6"></a-light>
                <a-light type="directional" position="5 5 5" intensity="0.8"></a-light>

                <a-sphere
                position="0 1.5 -5"
                radius="0.6"
                color="#ff6b9d"
                material="metalness: 0.7; roughness: 0.3">
                </a-sphere>

                <a-box
                position="-2 1 -4"
                rotation="0 45 0"
                color="#4080ff"
                material="metalness: 0.6; roughness: 0.4">
                </a-box>

                <a-cylinder
                position="2 1 -4"
                radius="0.4"
                height="1.2"
                color="#4ecdc4"
                material="metalness: 0.6; roughness: 0.4">
                </a-cylinder>

                <a-text
                value="Enter VR to use hand controllers"
                position="0 3 -4"
                align="center"
                color="#ffffff"
                width="8">
                </a-text>

                <a-plane
                position="0 0 -5"
                rotation="-90 0 0"
                width="20"
                height="20"
                color="#0f3460"
                material="metalness: 0.2; roughness: 0.8">
                </a-plane>

                <a-entity id="leftHand" hand-controls="hand: left"></a-entity>
                <a-entity id="rightHand" hand-controls="hand: right"></a-entity>

                <a-camera look-controls wasd-controls position="0 1.6 2">
                <a-cursor color="#ffffff"></a-cursor>
                </a-camera>
                </a-scene>
            """.trimIndent(),
            category = ExampleCategory.VR,
            difficulty = ExampleDifficulty.INTERMEDIATE
        ),

        CodeExample(
            title = "Metallic Material Showcase",
            description = "Different metallic and roughness values for realistic materials",
            code = """
                <a-scene embedded vr-mode-ui="enabled: true" background="color: #2c3e50">
                <a-light type="ambient" color="#505050" intensity="0.6"></a-light>
                <a-light type="directional" position="5 5 5" intensity="1.0"></a-light>
                <a-light type="point" position="-5 3 -5" color="#ff6b9d" intensity="0.8"></a-light>

                <a-sphere
                position="-3 1.5 -5"
                radius="0.75"
                color="#c0c0c0"
                material="metalness: 1.0; roughness: 0.1">
                </a-sphere>

                <a-box
                position="-1 1 -5"
                scale="1 1 1"
                color="#cd7f32"
                material="metalness: 0.8; roughness: 0.6">
                </a-box>

                <a-cylinder
                position="1 1 -5"
                radius="0.5"
                height="1.5"
                color="#3498db"
                material="metalness: 0.2; roughness: 0.3">
                </a-cylinder>

                <a-sphere
                position="3 1.5 -5"
                radius="0.75"
                color="#ff6b9d"
                material="metalness: 0.4; roughness: 0.05">
                </a-sphere>

                <a-text
                value="PBR Materials"
                position="0 3 -4"
                align="center"
                color="#ffffff"
                width="6">
                </a-text>

                <a-plane
                position="0 0 -5"
                rotation="-90 0 0"
                width="20"
                height="20"
                color="#34495e"
                material="metalness: 0.1; roughness: 0.9">
                </a-plane>

                <a-camera look-controls wasd-controls position="0 1.6 3">
                <a-cursor color="#ffffff"></a-cursor>
                </a-camera>
                </a-scene>
            """.trimIndent(),
            category = ExampleCategory.MATERIALS,
            difficulty = ExampleDifficulty.INTERMEDIATE
        ),

        CodeExample(
            title = "VR Art Gallery",
            description = "Immersive gallery with interactive hover effects",
            code = """
                <a-scene embedded vr-mode-ui="enabled: true" background="color: #ecf0f1">
                <a-assets>
                <script>
                AFRAME.registerComponent('hover-grow', {
                init: function () {
                const el = this.el;
                el.addEventListener('mouseenter', function () {
                el.setAttribute('scale', '1.3 1.3 1.3');
                });
                el.addEventListener('mouseleave', function () {
                el.setAttribute('scale', '1 1 1');
                });
                }
                });
                </script>
                </a-assets>

                <a-light type="ambient" color="#888888" intensity="0.7"></a-light>
                <a-light type="point" position="0 4 -5" color="#ffffff" intensity="1.5"></a-light>

                <a-plane
                position="0 0 0"
                rotation="-90 0 0"
                width="20"
                height="20"
                color="#34495e"
                material="metalness: 0.1; roughness: 0.9">
                </a-plane>

                <a-box
                position="0 2 -10"
                width="20"
                height="4"
                depth="0.1"
                color="#ffffff">
                </a-box>

                <a-sphere
                position="-5 2 -9"
                radius="0.8"
                color="#e74c3c"
                material="metalness: 0.7; roughness: 0.2"
                hover-grow>
                </a-sphere>

                <a-box
                position="0 2 -9"
                scale="1 1 1"
                color="#3498db"
                material="metalness: 0.6; roughness: 0.3"
                hover-grow>
                </a-box>

                <a-cylinder
                position="5 2 -9"
                radius="0.6"
                height="1.5"
                color="#2ecc71"
                material="metalness: 0.8; roughness: 0.2"
                hover-grow>
                </a-cylinder>

                <a-text
                value="VR Art Gallery"
                position="0 3.5 -9.5"
                align="center"
                color="#2c3e50"
                width="10">
                </a-text>

                <a-text
                value="Hover over artworks"
                position="0 0.5 -9.5"
                align="center"
                color="#7f8c8d"
                width="8">
                </a-text>

                <a-entity id="leftHand" hand-controls="hand: left"></a-entity>
                <a-entity id="rightHand" hand-controls="hand: right"></a-entity>

                <a-camera look-controls wasd-controls position="0 1.6 5">
                <a-cursor
                color="#ffffff"
                raycaster="objects: [hover-grow]">
                </a-cursor>
                </a-camera>
                </a-scene>
            """.trimIndent(),
            category = ExampleCategory.ADVANCED,
            difficulty = ExampleDifficulty.ADVANCED
        ),

        CodeExample(
            title = "Orbiting Planets",
            description = "Solar system with orbiting planets and moons",
            code = """
                <a-scene embedded vr-mode-ui="enabled: true" background="color: #000000">
                <a-light type="ambient" color="#333333" intensity="0.4"></a-light>
                <a-light type="point" position="0 0 0" color="#fff5e6" intensity="2.5"></a-light>

                <a-sphere
                position="0 0 0"
                radius="1"
                color="#fff5e6"
                material="emissive: #fff5e6; emissiveIntensity: 0.8">
                </a-sphere>

                <a-entity
                animation="property: rotation; to: 0 360 0; loop: true; dur: 10000; easing: linear">
                <a-sphere
                position="3 0 0"
                radius="0.3"
                color="#4080ff"
                material="metalness: 0.5; roughness: 0.3">
                </a-sphere>
                </a-entity>

                <a-entity
                animation="property: rotation; to: 0 360 0; loop: true; dur: 20000; easing: linear">
                <a-sphere
                position="5 0 0"
                radius="0.5"
                color="#ff6b9d"
                material="metalness: 0.6; roughness: 0.4">
                </a-sphere>
                </a-entity>

                <a-entity
                animation="property: rotation; to: 0 360 0; loop: true; dur: 30000; easing: linear">
                <a-sphere
                position="7 0 0"
                radius="0.4"
                color="#4ecdc4"
                material="metalness: 0.7; roughness: 0.2">
                </a-sphere>
                </a-entity>

                <a-torus
                position="0 0 0"
                radius="3"
                radius-tubular="0.01"
                color="#ffffff"
                material="opacity: 0.3"
                rotation="90 0 0">
                </a-torus>

                <a-torus
                position="0 0 0"
                radius="5"
                radius-tubular="0.01"
                color="#ffffff"
                material="opacity: 0.3"
                rotation="90 0 0">
                </a-torus>

                <a-torus
                position="0 0 0"
                radius="7"
                radius-tubular="0.01"
                color="#ffffff"
                material="opacity: 0.3"
                rotation="90 0 0">
                </a-torus>

                <a-camera look-controls wasd-controls position="0 5 12">
                <a-cursor color="#ffffff"></a-cursor>
                </a-camera>
                </a-scene>
            """.trimIndent(),
            category = ExampleCategory.ANIMATION,
            difficulty = ExampleDifficulty.INTERMEDIATE
        ),

        CodeExample(
            title = "Particle Ring",
            description = "Ring of small spheres with wave animation",
            code = """
                <a-scene embedded vr-mode-ui="enabled: true" background="color: #0a0a1a">
                <a-assets>
                <script>
                AFRAME.registerComponent('orbit-ring', {
                init: function () {
                const el = this.el;
                const count = 20;
                const radius = 4;

                for (let i = 0; i < count; i++) {
                const angle = (i / count) * Math.PI * 2;
                const x = Math.cos(angle) * radius;
                const z = Math.sin(angle) * radius;

                const sphere = document.createElement('a-sphere');
                sphere.setAttribute('position', x + ' 0 ' + z);
                sphere.setAttribute('radius', '0.15');
                sphere.setAttribute('color', '#ff00ff');
                sphere.setAttribute('material', 'emissive: #ff00ff; emissiveIntensity: 0.5; metalness: 0.8; roughness: 0.2');

                const delay = i * 100;
                sphere.setAttribute('animation', 'property: position; to: ' + x + ' ' + (Math.sin(i) * 2) + ' ' + z + '; direction: alternate; loop: true; dur: 2000; delay: ' + delay + '; easing: easeInOutSine');

                el.appendChild(sphere);
                }
                }
                });
                </script>
                </a-assets>

                <a-light type="ambient" color="#404040" intensity="0.5"></a-light>
                <a-light type="point" position="0 3 0" color="#ff00ff" intensity="1.5"></a-light>

                <a-entity
                orbit-ring
                animation="property: rotation; to: 0 360 0; loop: true; dur: 15000; easing: linear">
                </a-entity>

                <a-plane
                position="0 0 0"
                rotation="-90 0 0"
                width="20"
                height="20"
                color="#1a1a2e"
                material="metalness: 0.2; roughness: 0.8">
                </a-plane>

                <a-camera look-controls wasd-controls position="0 3 8">
                <a-cursor color="#ffffff"></a-cursor>
                </a-camera>
                </a-scene>
            """.trimIndent(),
            category = ExampleCategory.EFFECTS,
            difficulty = ExampleDifficulty.ADVANCED
        ),

        CodeExample(
            title = "Glowing Tunnel",
            description = "Infinite tunnel effect with glowing rings",
            code = """
                <a-scene embedded vr-mode-ui="enabled: true" background="color: #000000">
                <a-light type="ambient" color="#202020" intensity="0.3"></a-light>

                <a-torus
                position="0 1.6 -5"
                radius="2"
                radius-tubular="0.1"
                color="#ff006e"
                material="emissive: #ff006e; emissiveIntensity: 0.8"
                animation="property: rotation; to: 0 0 360; loop: true; dur: 3000; easing: linear">
                </a-torus>

                <a-torus
                position="0 1.6 -8"
                radius="2"
                radius-tubular="0.1"
                color="#00f5ff"
                material="emissive: #00f5ff; emissiveIntensity: 0.8"
                animation="property: rotation; to: 0 0 -360; loop: true; dur: 4000; easing: linear">
                </a-torus>

                <a-torus
                position="0 1.6 -11"
                radius="2"
                radius-tubular="0.1"
                color="#ffbe0b"
                material="emissive: #ffbe0b; emissiveIntensity: 0.8"
                animation="property: rotation; to: 0 0 360; loop: true; dur: 5000; easing: linear">
                </a-torus>

                <a-torus
                position="0 1.6 -14"
                radius="2"
                radius-tubular="0.1"
                color="#4ecdc4"
                material="emissive: #4ecdc4; emissiveIntensity: 0.8"
                animation="property: rotation; to: 0 0 -360; loop: true; dur: 6000; easing: linear">
                </a-torus>

                <a-torus
                position="0 1.6 -17"
                radius="2"
                radius-tubular="0.1"
                color="#a26cf7"
                material="emissive: #a26cf7; emissiveIntensity: 0.8"
                animation="property: rotation; to: 0 0 360; loop: true; dur: 7000; easing: linear">
                </a-torus>

                <a-light type="point" position="0 1.6 -5" color="#ff006e" intensity="1.5"></a-light>
                <a-light type="point" position="0 1.6 -11" color="#ffbe0b" intensity="1.5"></a-light>
                <a-light type="point" position="0 1.6 -17" color="#a26cf7" intensity="1.5"></a-light>

                <a-camera look-controls wasd-controls position="0 1.6 2">
                <a-cursor color="#ffffff"></a-cursor>
                </a-camera>
                </a-scene>
            """.trimIndent(),
            category = ExampleCategory.EFFECTS,
            difficulty = ExampleDifficulty.INTERMEDIATE
        ),

        CodeExample(
            title = "Stacked Cubes Tower",
            description = "Tower of rotating cubes with different speeds",
            code = """
                <a-scene embedded vr-mode-ui="enabled: true" background="color: #1a1a2e">
                <a-light type="ambient" color="#505050" intensity="0.6"></a-light>
                <a-light type="directional" position="5 5 5" intensity="0.8"></a-light>
                <a-light type="point" position="0 8 0" color="#ff6b9d" intensity="1.5"></a-light>

                <a-box
                position="0 0.5 -5"
                scale="2 0.5 2"
                color="#ff6b9d"
                material="metalness: 0.7; roughness: 0.3"
                animation="property: rotation; to: 0 360 0; loop: true; dur: 8000; easing: linear">
                </a-box>

                <a-box
                position="0 1.5 -5"
                scale="1.8 0.5 1.8"
                color="#4080ff"
                material="metalness: 0.7; roughness: 0.3"
                animation="property: rotation; to: 0 -360 0; loop: true; dur: 7000; easing: linear">
                </a-box>

                <a-box
                position="0 2.5 -5"
                scale="1.6 0.5 1.6"
                color="#4ecdc4"
                material="metalness: 0.7; roughness: 0.3"
                animation="property: rotation; to: 0 360 0; loop: true; dur: 6000; easing: linear">
                </a-box>

                <a-box
                position="0 3.5 -5"
                scale="1.4 0.5 1.4"
                color="#ffe66d"
                material="metalness: 0.7; roughness: 0.3"
                animation="property: rotation; to: 0 -360 0; loop: true; dur: 5000; easing: linear">
                </a-box>

                <a-box
                position="0 4.5 -5"
                scale="1.2 0.5 1.2"
                color="#a26cf7"
                material="metalness: 0.7; roughness: 0.3"
                animation="property: rotation; to: 0 360 0; loop: true; dur: 4000; easing: linear">
                </a-box>

                <a-box
                position="0 5.5 -5"
                scale="1 0.5 1"
                color="#ff9f9f"
                material="metalness: 0.7; roughness: 0.3"
                animation="property: rotation; to: 0 -360 0; loop: true; dur: 3000; easing: linear">
                </a-box>

                <a-plane
                position="0 0 -5"
                rotation="-90 0 0"
                width="15"
                height="15"
                color="#0f3460"
                material="metalness: 0.2; roughness: 0.8">
                </a-plane>

                <a-camera look-controls wasd-controls position="0 3 3">
                <a-cursor color="#ffffff"></a-cursor>
                </a-camera>
                </a-scene>
            """.trimIndent(),
            category = ExampleCategory.ANIMATION,
            difficulty = ExampleDifficulty.BEGINNER
        ),

        CodeExample(
            title = "Color Changing Environment",
            description = "Scene with smoothly transitioning ambient colors",
            code = """
                <a-scene embedded vr-mode-ui="enabled: true">
                <a-assets>
                <script>
                AFRAME.registerComponent('color-cycle', {
                init: function () {
                const el = this.el;
                const colors = ['#ff6b9d', '#4080ff', '#4ecdc4', '#ffe66d', '#a26cf7'];
                let index = 0;

                setInterval(() => {
                index = (index + 1) % colors.length;
                el.setAttribute('animation', 'property: components.material.material.color; type: color; to: ' + colors[index] + '; dur: 2000; easing: easeInOutSine');
                }, 3000);
                }
                });

                AFRAME.registerComponent('background-cycle', {
                init: function () {
                const scene = this.el.sceneEl;
                const colors = ['#1a1a2e', '#16213e', '#0f3460', '#533483', '#c71585'];
                let index = 0;

                setInterval(() => {
                index = (index + 1) % colors.length;
                scene.setAttribute('animation', 'property: background; to: ' + colors[index] + '; dur: 2000; easing: easeInOutSine');
                }, 3000);
                }
                });
                </script>
                </a-assets>

                <a-light type="ambient" color="#606060" intensity="0.6"></a-light>
                <a-light type="directional" position="5 5 5" intensity="0.8"></a-light>

                <a-entity background-cycle></a-entity>

                <a-sphere
                position="-2 1.5 -5"
                radius="0.8"
                color="#ff6b9d"
                material="metalness: 0.6; roughness: 0.4"
                color-cycle>
                </a-sphere>

                <a-box
                position="0 1.5 -5"
                scale="1 1 1"
                color="#4080ff"
                material="metalness: 0.6; roughness: 0.4"
                color-cycle>
                </a-box>

                <a-cylinder
                position="2 1.5 -5"
                radius="0.5"
                height="1.5"
                color="#4ecdc4"
                material="metalness: 0.6; roughness: 0.4"
                color-cycle>
                </a-cylinder>

                <a-text
                value="Color Changing World"
                position="0 3.5 -4"
                align="center"
                color="#ffffff"
                width="6">
                </a-text>

                <a-plane
                position="0 0 -5"
                rotation="-90 0 0"
                width="15"
                height="15"
                color="#2c3e50"
                material="metalness: 0.1; roughness: 0.9">
                </a-plane>

                <a-camera look-controls wasd-controls position="0 1.6 2">
                <a-cursor color="#ffffff"></a-cursor>
                </a-camera>
                </a-scene>
            """.trimIndent(),
            category = ExampleCategory.ADVANCED,
            difficulty = ExampleDifficulty.ADVANCED
        )
    )
}