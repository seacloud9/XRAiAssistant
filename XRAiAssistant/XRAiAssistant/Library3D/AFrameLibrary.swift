import Foundation

struct AFrameLibrary: Library3D {
    let id = "aframe"
    let displayName = "A-Frame"
    let description = "Web framework for building VR/AR experiences"
    let version = "v1.4+"
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
        **fully working A-Frame v1.4+ HTML code**
        
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
}