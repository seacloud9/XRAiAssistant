# 📚 Keyword System Guide for XRAiAssistant Examples

## What Are Keywords?

Keywords are **searchable tags** that help both users and AI discover examples and learn patterns. When you add rich keywords to examples, the AI can:

1. **Find similar examples** when users ask for specific effects
2. **Learn best practices** from your implementations
3. **Suggest better code** by referencing proven patterns

## Keyword Taxonomy (Categories)

### 🎨 Visual Style Keywords
Use these to describe the **look and feel** of your scene:

- `voxel` - Blocky, Minecraft-style cubes
- `wireframe` - Outline-only rendering
- `particle` - Particle effects and systems
- `holographic` - Sci-fi hologram aesthetics
- `retro` - Old-school graphics style
- `neon` - Bright, glowing colors
- `glitch` - Digital corruption effects
- `glow` - Soft luminescence
- `metallic` - Shiny metal surfaces
- `crystal` - Gem-like transparent materials

### 🔧 Technical Keywords
Use these to describe **how it's built**:

- `procedural` - Generated algorithmically
- `noise` - Random variation patterns
- `simplex` - Simplex noise algorithm
- `perlin` - Perlin noise algorithm
- `algorithm` - Custom algorithmic approach
- `optimization` - Performance-focused code
- `instancing` - Using mesh instances
- `pbr` - Physically-based rendering
- `physics` - Physics simulation

### 🌍 Scene Type Keywords
Use these to describe **what the scene represents**:

- `infinite` - Endless/looping environment
- `tunnel` - Corridor or tube scene
- `wormhole` - Space-time tunnel effect
- `portal` - Doorway or gateway
- `environment` - Complete world/skybox
- `skybox` - Background environment
- `landscape` - Terrain or outdoor scene
- `interior` - Indoor/room scene

### ✨ Effect Keywords
Use these to describe **special effects**:

- `bloom` - Bright light bleeding effect
- `post-processing` - Screen-space effects
- `color-cycling` - Animated color changes
- `animation-loop` - Repeating animation
- `shadows` - Shadow rendering
- `reflection` - Mirror/water reflections
- `fog` - Atmospheric fog effect

### 🎮 Interaction Keywords
Use these to describe **user interaction**:

- `interactive` - User can click/touch
- `customizable` - User can modify parameters
- `html-ui` - HTML controls overlay
- `controls` - Camera or object controls
- `parameters` - Adjustable settings
- `click` - Mouse click interaction
- `drag` - Drag and drop
- `vr` - Virtual reality support
- `ar` - Augmented reality support

## How to Choose Keywords

### Step 1: Describe Visual Appearance (3-5 keywords)
Look at your scene and pick words that describe what you SEE:

**Example**: Voxel wormhole scene
- ✅ `voxel` (blocky cubes)
- ✅ `neon` (bright glowing colors)
- ✅ `tunnel` (cylindrical passage)
- ✅ `glow` (emissive lighting)

### Step 2: Describe Technical Approach (2-3 keywords)
How did you BUILD it?

**Example**: Voxel wormhole scene
- ✅ `procedural` (generated with code)
- ✅ `simplex-noise` (noise algorithm used)
- ✅ `optimization` (voxel culling for performance)

### Step 3: Describe Special Features (1-3 keywords)
What makes it SPECIAL?

**Example**: Voxel wormhole scene
- ✅ `infinite` (continuous regeneration)
- ✅ `post-processing` (bloom effect)
- ✅ `retro-gaming` (Mario star reference)

### Total: 5-10 keywords per example

## Real-World Examples

### Example 1: Floating Crystal Gems
```swift
keywords: [
    "glow",          // Visual: glowing effect
    "pbr",           // Technical: PBR materials
    "metallic",      // Visual: shiny metal
    "animation",     // Effect: animated motion
    "floating",      // Effect: levitation
    "polyhedron",    // Scene type: geometric shape
    "crystal"        // Visual: gem-like
]
```

### Example 2: Voxel Wormhole
```swift
keywords: [
    "voxel",         // Visual: blocky cubes
    "procedural",    // Technical: algorithmic generation
    "infinite",      // Scene type: endless tunnel
    "wormhole",      // Scene type: space tunnel
    "tunnel",        // Scene type: corridor
    "simplex-noise", // Technical: noise algorithm
    "algorithm",     // Technical: custom code
    "post-processing", // Effect: bloom
    "bloom",         // Effect: glow
    "retro-gaming",  // Visual: nostalgic style
    "mario",         // Scene type: game reference
    "neon",          // Visual: bright colors
    "glow",          // Visual: luminescence
    "optimization"   // Technical: performance tuning
]
```

### Example 3: Physics Bouncing Sphere
```swift
keywords: [
    "physics",       // Technical: physics engine
    "gravity",       // Technical: physics simulation
    "bounce",        // Effect: bouncing motion
    "collision",     // Technical: collision detection
    "sphere"         // Scene type: ball object
]
```

## Writing AI Prompt Hints

The `aiPromptHints` field teaches the AI **HOW** to use techniques from your example.

### Template Structure:
```
When users request [KEYWORDS]:

1. [TECHNIQUE 1]: [HOW TO IMPLEMENT]
   - Detail A
   - Detail B

2. [TECHNIQUE 2]: [HOW TO IMPLEMENT]
   - Detail A
   - Detail B

PERFORMANCE TIPS:
- Tip 1
- Tip 2
```

### Example: Voxel Wormhole Hints
```swift
aiPromptHints: """
When users request voxel, infinite tunnel, or procedural generation scenes:

1. PROCEDURAL GENERATION: Use SimplexNoise class for organic patterns
   - Initialize with random permutation table
   - Call noise(x, y, z) with scaled coordinates
   - Threshold noise values to create sparse distributions

2. PERFORMANCE OPTIMIZATION: Implement voxel culling to maintain 60fps
   - Set maxVoxels limit (typically 1500-2000)
   - Remove voxels behind camera
   - Check voxels.length before creating new instances

3. INFINITE TUNNEL: Create continuous movement
   - Advance camera position in registerBeforeRender
   - Detect when camera crosses threshold
   - Generate new segment ahead, dispose old segment behind

PERFORMANCE TIPS:
- Limit active objects to ~2000 max for 60fps
- Use dispose() to free memory
- Consider InstancedMesh for 10x+ performance boost
"""
```

## Quick Reference: Adding Keywords to Your Example

```swift
CodeExample(
    id: "my-awesome-scene",  // Optional: unique identifier
    title: "🌟 My Awesome Scene",
    description: "Brief description of what it does",
    code: """
    // Your complete working code here
    """,
    category: .effects,  // Choose: .basic, .animation, .lighting, .materials, .interaction, .physics, .effects, .vr, .advanced
    difficulty: .intermediate,  // Choose: .beginner, .intermediate, .advanced

    // NEW METADATA FIELDS:
    keywords: [
        // Visual (3-5): What do you SEE?
        "neon", "glow", "particle",

        // Technical (2-3): How is it BUILT?
        "procedural", "optimization",

        // Special (1-3): What makes it SPECIAL?
        "interactive", "infinite"
    ],

    aiPromptHints: """
    When users request [your keywords]:

    1. KEY TECHNIQUE: How to implement
       - Important detail
       - Another detail

    2. ANOTHER TECHNIQUE: How to implement
       - Detail

    TIPS:
    - Performance tip
    - Best practice
    """
)
```

## Benefits of Good Keywords

### For Users:
- ✅ Find examples faster by searching for concepts
- ✅ Discover related examples with similar keywords
- ✅ Learn new techniques from AI suggestions

### For AI:
- ✅ Reference proven patterns when generating code
- ✅ Suggest better implementations based on examples
- ✅ Provide educational explanations of techniques

### For You:
- ✅ Build a searchable knowledge base
- ✅ Document best practices
- ✅ Share techniques with community

## Common Mistakes to Avoid

❌ **Too generic**: `["scene", "3d", "babylonjs"]`
✅ **Specific**: `["voxel", "procedural", "infinite-tunnel"]`

❌ **Too many**: 20+ keywords (overwhelming)
✅ **Just right**: 5-10 focused keywords

❌ **No technical details**: `["cool", "awesome", "fun"]`
✅ **Technical**: `["simplex-noise", "optimization", "instancing"]`

❌ **Empty hints**: `aiPromptHints: "This is a cool example"`
✅ **Helpful hints**: Step-by-step implementation guide

## Next Steps

1. **Review the voxel wormhole example** in `BabylonJSLibrary.swift` lines 987-1191
2. **Add keywords to your existing examples** using this guide
3. **Write helpful AI hints** that explain your techniques
4. **Test it**: Ask the AI "create a voxel scene" and see if it references your example!

---

**Questions?** Check `CLAUDE.md` and `COPILOT.md` for the full Example Contribution Strategy documentation.
