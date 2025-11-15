# Android Examples Generation Guide

I've analyzed all 5 iOS library files and here's the summary for generating complete Kotlin code:

## Libraries Overview

### 1. **ThreeJSLibrary** - 9 Examples
- Neon Cubes (BASIC, BEGINNER)
- Particle Spiral Galaxy (EFFECTS, INTERMEDIATE)
- Morphing Geometry (ANIMATION, ADVANCED)
- Interactive Color Spheres (INTERACTION, INTERMEDIATE)
- Glowing Torus Knots (ADVANCED, ADVANCED)
- Wireframe Geometry Dance (EFFECTS, INTERMEDIATE)
- Gradient Plane Wave (ANIMATION, ADVANCED)
- Ring Portal (ADVANCED, ADVANCED)
- Bouncing Spheres Physics (ANIMATION, INTERMEDIATE)

### 2. **ReactThreeFiberLibrary** - 5 Examples
- Floating Crystals (BASIC, BEGINNER)
- Animated Galaxy (EFFECTS, INTERMEDIATE)
- Bouncing Balls Physics (ANIMATION, INTERMEDIATE)
- Interactive Color Spheres (INTERACTION, INTERMEDIATE)
- Holographic Torus Wave (ADVANCED, ADVANCED)

### 3. **ReactylonLibrary** - 4 Examples
- Floating Gems (BASIC, BEGINNER)
- Interactive Color Boxes (INTERACTION, INTERMEDIATE)
- Animated Rainbow Spheres (ANIMATION, INTERMEDIATE)
- Dynamic Material Playground (ADVANCED, ADVANCED)

### 4. **AFrameLibrary** - 14 Examples
- Floating Neon Spheres (BASIC, BEGINNER)
- Rotating Crystal Array (ANIMATION, BEGINNER)
- Color Wave Animation (ANIMATION, INTERMEDIATE)
- Interactive Hover Effects (INTERACTION, INTERMEDIATE)
- Neon City Lights (LIGHTING, INTERMEDIATE)
- VR Hand Controllers (VR, INTERMEDIATE)
- Metallic Material Showcase (MATERIALS, INTERMEDIATE)
- VR Art Gallery (ADVANCED, ADVANCED)
- Orbiting Planets (ANIMATION, INTERMEDIATE)
- Particle Ring (EFFECTS, ADVANCED)
- Glowing Tunnel (EFFECTS, INTERMEDIATE)
- Stacked Cubes Tower (ANIMATION, BEGINNER)
- Color Changing Environment (ADVANCED, ADVANCED)

### 5. **BabylonJSLibrary** - 15+ Examples (Complex)
Key examples with metadata:
- Floating Crystal Gems (BASIC, BEGINNER) - with keywords and aiPromptHints
- Sphere with Physics (PHYSICS, INTERMEDIATE)
- Animated Path Following (ANIMATION, INTERMEDIATE)
- Dynamic Lighting Scene (LIGHTING, INTERMEDIATE)
- PBR Materials Showcase (MATERIALS, INTERMEDIATE)
- Glow Effect Bloom (EFFECTS, INTERMEDIATE)
- Click Interaction (INTERACTION, INTERMEDIATE)
- Holographic Torus Array (ADVANCED, ADVANCED)
- **Infinite Voxel Wormhole** (EFFECTS, ADVANCED) - with extensive metadata
- **Retrowave Tronscape** (EFFECTS, ADVANCED) - with extensive metadata
- **Fractal Invader** (EFFECTS, ADVANCED) - procedural voxel generation
- Plus more...

## Critical Android/Kotlin Requirements

### String Handling
```kotlin
code = """
    // Multi-line JavaScript/HTML code here
    // Preserve ALL content exactly as in iOS
""".trimIndent()
```

### Optional Fields
Only include if present in iOS:
```kotlin
id = "voxel-wormhole"  // Only if iOS has id
keywords = listOf("voxel", "procedural", ...)  // Only if iOS has keywords
aiPromptHints = "..."  // Only if iOS has aiPromptHints
```

### Enum Mapping
```kotlin
category = ExampleCategory.BASIC  // .basic → .BASIC
difficulty = ExampleDifficulty.BEGINNER  // .beginner → .BEGINNER
```

## Next Steps

Due to file size (28,000+ tokens for BabylonJS alone), I recommend:

1. **Generate files one at a time** - I can create each complete file
2. **Use existing iOS files** as the source of truth
3. **Preserve ALL code exactly** - don't modify JavaScript/HTML/TSX
4. **Include metadata** where present (keywords, aiPromptHints)

Would you like me to:
- A) Generate complete code for ONE library at a time (recommended)
- B) Create a script to automate the conversion
- C) Provide template code with placeholders for you to fill

Let me know which approach you prefer!
