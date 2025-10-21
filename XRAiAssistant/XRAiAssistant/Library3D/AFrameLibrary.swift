import Foundation

struct AFrameLibrary: Library3D {
    let id = "aframe"
    let displayName = "A-Frame"
    let description = "Web framework for building VR/AR experiences"
    let version = "v1.7.0"
    let playgroundTemplate = "playground-aframe.html"
    let codeLanguage = CodeLanguage.html
    let iconName = "view.3d"
    let documentationURL = "https://aframe.io/docs/"
    
    let supportedFeatures: Set<Library3DFeature> = [
        .webgl, .webxr, .vr, .ar, .animation, 
        .lighting, .materials, .declarative
    ]
    
    var systemPrompt: String {
        return """
        You are an expert A-Frame assistant helping users create VR/AR scenes and learn A-Frame.
        You are a **creative A-Frame mentor** who helps users bring immersive 3D/VR ideas to life.
        Your role is not just technical but also **artistic**: you suggest imaginative variations,
        interactive VR elements, and immersive experiences — while always delivering 
        **fully working A-Frame v1.7+ HTML code**
        
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
        - To insert code, wrap it in: [INSERT_CODE]```html\ncode here\n```[/INSERT_CODE]
        - To run the scene, use: [RUN_SCENE]
        
        Mindset: Think like a VR experience designer. Create immersive worlds that users want to explore and interact with. Make VR development accessible while showcasing the unique possibilities of immersive 3D.
        ALWAYS generate VR-ready code for ANY 3D-related request. Make every scene an invitation to step into virtual reality!
        """
    }
    
    var defaultSceneCode: String {
        return """
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

    var examples: [CodeExample] {
        return [
            // BASIC EXAMPLES
            CodeExample(
                title: "Animated VR Room",
                description: "Simple VR room with animated objects",
                code: """
                <a-scene embedded vr-mode-ui="enabled: true">
                    <a-light type="ambient" color="#999"></a-light>
                    <a-light type="directional" position="5 5 5" intensity="0.7"></a-light>

                    <a-sphere position="0 2 -5" radius="1.25" color="#EF2D5E"
                              animation="property: rotation; to: 0 360 0; loop: true; dur: 3000"></a-sphere>

                    <a-box position="-1.5 1 -3" rotation="0 45 0" color="#4CC3D9"
                           animation="property: position; to: -1.5 2 -3; direction: alternate; loop: true; dur: 2000"></a-box>

                    <a-cylinder position="1.5 1 -3" radius="0.5" height="1.5" color="#FFC65D"></a-cylinder>

                    <a-plane position="0 0 -4" rotation="-90 0 0" width="10" height="10" color="#7BC8A4"></a-plane>

                    <a-camera look-controls wasd-controls position="0 1.6 0">
                        <a-cursor color="#fff"></a-cursor>
                    </a-camera>
                </a-scene>
                """,
                category: .basic,
                difficulty: .beginner
            ),

            // POST-PROCESSING EXAMPLE (v1.7.0 FEATURE)
            CodeExample(
                title: "Enhanced Rendering (v1.7.0)",
                description: "A-Frame 1.7.0 renderer with tone mapping and enhanced visuals",
                code: """
                <a-scene embedded vr-mode-ui="enabled: true"
                         renderer="antialias: true; colorManagement: true; toneMapping: ACESFilmic; exposure: 1.2">
                    <a-light type="ambient" color="#888" intensity="0.5"></a-light>
                    <a-light type="directional" position="5 5 5" intensity="1.0"></a-light>

                    <a-sphere position="0 1.5 -5" radius="1" color="#ff6b6b"
                              material="metalness: 0.8; roughness: 0.2"></a-sphere>

                    <a-box position="-2 1 -3" rotation="0 45 0" color="#4ecdc4"
                           material="metalness: 0.6; roughness: 0.3"></a-box>

                    <a-cylinder position="2 1 -3" radius="0.5" height="2" color="#ffe66d"
                                material="metalness: 0.5; roughness: 0.4"></a-cylinder>

                    <a-plane position="0 0 -4" rotation="-90 0 0" width="20" height="20" color="#2c3e50"
                             material="metalness: 0.3; roughness: 0.7"></a-plane>

                    <a-text value="A-Frame 1.7.0 - Enhanced Rendering" position="0 3 -3" align="center" color="#fff"></a-text>

                    <a-camera look-controls wasd-controls position="0 1.6 3">
                        <a-cursor color="#fff"></a-cursor>
                    </a-camera>
                </a-scene>
                """,
                category: .effects,
                difficulty: .intermediate
            ),

            // ANIMATION EXAMPLE
            CodeExample(
                title: "Interactive Solar System",
                description: "Planets orbiting the sun with realistic animation",
                code: """
                <a-scene embedded vr-mode-ui="enabled: true" background="color: #000">
                    <a-light type="ambient" color="#222"></a-light>

                    <!-- Sun -->
                    <a-sphere position="0 2 -5" radius="0.5" color="#ffcc00"
                              material="emissive: #ffcc00; emissiveIntensity: 0.5"></a-sphere>

                    <!-- Mercury -->
                    <a-sphere position="1 2 -5" radius="0.1" color="#8c7853"
                              animation="property: object3D.position.x; to: -1; from: 1; loop: true; dur: 3000; easing: linear"
                              animation__y="property: object3D.position.z; to: -6; from: -4; loop: true; dur: 3000; easing: linear; dir: alternate"></a-sphere>

                    <!-- Venus -->
                    <a-sphere position="1.5 2 -5" radius="0.15" color="#ffc649"
                              animation="property: object3D.position.x; to: -1.5; from: 1.5; loop: true; dur: 5000; easing: linear"
                              animation__y="property: object3D.position.z; to: -6.5; from: -3.5; loop: true; dur: 5000; easing: linear; dir: alternate"></a-sphere>

                    <!-- Earth -->
                    <a-sphere position="2 2 -5" radius="0.15" color="#4a90e2"
                              animation="property: object3D.position.x; to: -2; from: 2; loop: true; dur: 7000; easing: linear"
                              animation__y="property: object3D.position.z; to: -7; from: -3; loop: true; dur: 7000; easing: linear; dir: alternate"></a-sphere>

                    <a-text value="Solar System VR" position="0 4 -5" align="center" color="#fff"></a-text>

                    <a-camera look-controls wasd-controls position="0 2 0">
                        <a-cursor color="#fff"></a-cursor>
                    </a-camera>
                </a-scene>
                """,
                category: .animation,
                difficulty: .intermediate
            ),

            // INTERACTION EXAMPLE
            CodeExample(
                title: "Interactive Color Changer",
                description: "Click on objects to change their colors",
                code: """
                <a-scene embedded vr-mode-ui="enabled: true">
                    <a-assets>
                        <script>
                            AFRAME.registerComponent('click-color', {
                                init: function () {
                                    this.colors = ['#ff6b6b', '#4ecdc4', '#ffe66d', '#a8e6cf', '#ff8b94'];
                                    this.colorIndex = 0;
                                    this.el.addEventListener('click', () => {
                                        this.colorIndex = (this.colorIndex + 1) % this.colors.length;
                                        this.el.setAttribute('color', this.colors[this.colorIndex]);
                                    });
                                }
                            });
                        </script>
                    </a-assets>

                    <a-light type="ambient" color="#888"></a-light>
                    <a-light type="directional" position="5 5 5"></a-light>

                    <a-sphere position="-2 1.5 -5" radius="0.75" color="#ff6b6b" click-color></a-sphere>
                    <a-box position="0 1 -5" color="#4ecdc4" click-color></a-box>
                    <a-cylinder position="2 1 -5" radius="0.5" height="1.5" color="#ffe66d" click-color></a-cylinder>

                    <a-text value="Click objects to change colors!" position="0 3 -4" align="center" color="#fff"></a-text>

                    <a-plane position="0 0 -4" rotation="-90 0 0" width="10" height="10" color="#2c3e50"></a-plane>

                    <a-camera look-controls wasd-controls position="0 1.6 0">
                        <a-cursor color="#fff" raycaster="objects: [click-color]"></a-cursor>
                    </a-camera>
                </a-scene>
                """,
                category: .interaction,
                difficulty: .intermediate
            ),

            // LIGHTING EXAMPLE
            CodeExample(
                title: "Dynamic Lighting Scene",
                description: "Animated lights creating dramatic atmosphere",
                code: """
                <a-scene embedded vr-mode-ui="enabled: true" background="color: #111">
                    <a-light type="ambient" color="#222" intensity="0.3"></a-light>

                    <a-light type="point" position="3 3 0" color="#ff0000" intensity="0.8"
                             animation="property: object3D.position.x; to: -3; from: 3; loop: true; dur: 3000; easing: easeInOutSine"></a-light>

                    <a-light type="point" position="-3 3 0" color="#00ff00" intensity="0.8"
                             animation="property: object3D.position.x; to: 3; from: -3; loop: true; dur: 3000; easing: easeInOutSine"></a-light>

                    <a-light type="point" position="0 3 3" color="#0000ff" intensity="0.8"
                             animation="property: object3D.position.z; to: -3; from: 3; loop: true; dur: 4000; easing: easeInOutSine"></a-light>

                    <a-sphere position="0 1.5 -5" radius="1" color="#ffffff"
                              material="metalness: 0.9; roughness: 0.1"></a-sphere>

                    <a-plane position="0 0 -4" rotation="-90 0 0" width="20" height="20" color="#333"></a-plane>

                    <a-text value="Dynamic RGB Lighting" position="0 3.5 -3" align="center" color="#fff"></a-text>

                    <a-camera look-controls wasd-controls position="0 1.6 3">
                        <a-cursor color="#fff"></a-cursor>
                    </a-camera>
                </a-scene>
                """,
                category: .lighting,
                difficulty: .intermediate
            ),

            // VR EXAMPLE
            CodeExample(
                title: "VR Hand Tracking",
                description: "VR scene with hand controllers for immersive interaction",
                code: """
                <a-scene embedded vr-mode-ui="enabled: true">
                    <a-light type="ambient" color="#888"></a-light>
                    <a-light type="directional" position="5 5 5"></a-light>

                    <a-sphere position="0 1.5 -5" radius="0.5" color="#ff6b6b"></a-sphere>
                    <a-box position="-1.5 1 -3" color="#4ecdc4"></a-box>
                    <a-cylinder position="1.5 1 -3" radius="0.3" height="1" color="#ffe66d"></a-cylinder>

                    <a-text value="VR Hand Tracking Demo" position="0 3 -3" align="center" color="#fff"></a-text>

                    <a-plane position="0 0 -4" rotation="-90 0 0" width="20" height="20" color="#2c3e50"></a-plane>

                    <!-- VR Hand Controllers -->
                    <a-entity id="leftHand" hand-controls="hand: left"></a-entity>
                    <a-entity id="rightHand" hand-controls="hand: right"></a-entity>

                    <a-camera look-controls wasd-controls position="0 1.6 0"></a-camera>
                </a-scene>
                """,
                category: .vr,
                difficulty: .intermediate
            ),

            // MATERIALS EXAMPLE
            CodeExample(
                title: "Advanced Materials",
                description: "Showcasing different material properties for realistic rendering",
                code: """
                <a-scene embedded vr-mode-ui="enabled: true"
                         renderer="antialias: true; colorManagement: true; toneMapping: neutral">
                    <a-light type="ambient" color="#666"></a-light>
                    <a-light type="directional" position="5 5 5" intensity="0.8"></a-light>

                    <!-- Metallic sphere -->
                    <a-sphere position="-3 1.5 -5" radius="0.75" color="#c0c0c0"
                              material="metalness: 1.0; roughness: 0.1"></a-sphere>

                    <!-- Rough metallic box -->
                    <a-box position="-1 1 -5" color="#8b7355"
                           material="metalness: 0.8; roughness: 0.6"></a-box>

                    <!-- Dielectric cylinder -->
                    <a-cylinder position="1 1 -5" radius="0.5" height="1.5" color="#3498db"
                                material="metalness: 0.0; roughness: 0.3"></a-cylinder>

                    <!-- Glossy sphere -->
                    <a-sphere position="3 1.5 -5" radius="0.75" color="#e74c3c"
                              material="metalness: 0.2; roughness: 0.05"></a-sphere>

                    <a-text value="PBR Materials" position="0 3 -3" align="center" color="#fff"></a-text>

                    <a-plane position="0 0 -4" rotation="-90 0 0" width="20" height="20" color="#34495e"
                             material="metalness: 0.1; roughness: 0.8"></a-plane>

                    <a-camera look-controls wasd-controls position="0 1.6 3">
                        <a-cursor color="#fff"></a-cursor>
                    </a-camera>
                </a-scene>
                """,
                category: .materials,
                difficulty: .intermediate
            ),

            // ADVANCED EXAMPLE
            CodeExample(
                title: "Immersive VR Gallery",
                description: "Complete VR art gallery with interactive elements",
                code: """
                <a-scene embedded vr-mode-ui="enabled: true"
                         renderer="antialias: true; colorManagement: true; toneMapping: ACESFilmic; exposure: 1.0">
                    <a-assets>
                        <script>
                            AFRAME.registerComponent('hover-scale', {
                                init: function () {
                                    this.el.addEventListener('mouseenter', () => {
                                        this.el.setAttribute('scale', '1.2 1.2 1.2');
                                    });
                                    this.el.addEventListener('mouseleave', () => {
                                        this.el.setAttribute('scale', '1 1 1');
                                    });
                                }
                            });
                        </script>
                    </a-assets>

                    <a-light type="ambient" color="#999" intensity="0.5"></a-light>
                    <a-light type="point" position="0 4 0" color="#fff" intensity="1.0"></a-light>

                    <!-- Floor -->
                    <a-plane position="0 0 0" rotation="-90 0 0" width="20" height="20" color="#34495e"
                             material="metalness: 0.1; roughness: 0.8"></a-plane>

                    <!-- Walls -->
                    <a-box position="0 2 -10" width="20" height="4" depth="0.1" color="#ecf0f1"></a-box>
                    <a-box position="-10 2 0" rotation="0 90 0" width="20" height="4" depth="0.1" color="#ecf0f1"></a-box>
                    <a-box position="10 2 0" rotation="0 -90 0" width="20" height="4" depth="0.1" color="#ecf0f1"></a-box>

                    <!-- Art pieces (interactive) -->
                    <a-sphere position="-5 2 -9" radius="0.8" color="#e74c3c" hover-scale
                              material="metalness: 0.6; roughness: 0.2"></a-sphere>

                    <a-box position="0 2 -9" color="#3498db" hover-scale
                           material="metalness: 0.5; roughness: 0.3"></a-box>

                    <a-cylinder position="5 2 -9" radius="0.6" height="1.5" color="#2ecc71" hover-scale
                                material="metalness: 0.7; roughness: 0.2"></a-cylinder>

                    <!-- Gallery info -->
                    <a-text value="VR Art Gallery" position="0 3.5 -9.5" align="center" color="#2c3e50" width="10"></a-text>
                    <a-text value="Hover over artworks to interact" position="0 0.5 -9.5" align="center" color="#7f8c8d" width="8"></a-text>

                    <!-- VR Controls -->
                    <a-entity id="leftHand" hand-controls="hand: left"></a-entity>
                    <a-entity id="rightHand" hand-controls="hand: right"></a-entity>

                    <a-camera look-controls wasd-controls position="0 1.6 5">
                        <a-cursor color="#fff" raycaster="objects: [hover-scale]"></a-cursor>
                    </a-camera>
                </a-scene>
                """,
                category: .advanced,
                difficulty: .advanced
            )
        ]
    }
}