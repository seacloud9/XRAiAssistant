package com.xrai.assistant.domain.model

/**
 * 3D Library interface defining the contract for 3D rendering frameworks
 *
 * iOS equivalent: Library3D protocol in Library3D.swift (line 5)
 *
 * Implementations: Babylon.js, Three.js, A-Frame, React Three Fiber, Reactylon
 */
interface Library3D {
    val id: String
    val displayName: String
    val description: String
    val version: String
    val playgroundTemplate: String
    val systemPrompt: String
    val defaultSceneCode: String
    val codeLanguage: CodeLanguage
    val iconName: String
    val supportedFeatures: Set<Library3DFeature>
    val documentationURL: String
    val examples: List<CodeExample>
}

/**
 * Code example with metadata for AI-assisted learning
 *
 * iOS equivalent: CodeExample struct in Library3D.swift (line 21)
 */
data class CodeExample(
    val id: String = java.util.UUID.randomUUID().toString(),
    val title: String,
    val description: String,
    val code: String,
    val category: ExampleCategory,
    val difficulty: ExampleDifficulty = ExampleDifficulty.BEGINNER,
    val keywords: List<String> = emptyList(),
    val aiPromptHints: String? = null
)

/**
 * Example categories
 *
 * iOS equivalent: ExampleCategory enum in Library3D.swift (line 54)
 */
enum class ExampleCategory(
    val displayName: String,
    val icon: String
) {
    BASIC("Basic Shapes", "cube"),
    ANIMATION("Animation", "rotate_3d"),
    LIGHTING("Lighting", "lightbulb"),
    MATERIALS("Materials", "palette"),
    INTERACTION("Interaction", "touch_app"),
    PHYSICS("Physics", "sports_handball"),
    EFFECTS("Effects", "auto_awesome"),
    VR("VR/XR", "view_in_ar"),
    ADVANCED("Advanced", "settings")
}

/**
 * Example difficulty levels
 *
 * iOS equivalent: ExampleDifficulty enum in Library3D.swift (line 80)
 */
enum class ExampleDifficulty(val displayName: String) {
    BEGINNER("Beginner"),
    INTERMEDIATE("Intermediate"),
    ADVANCED("Advanced")
}

/**
 * Code language types
 *
 * iOS equivalent: CodeLanguage enum in Library3D.swift (line 88)
 */
enum class CodeLanguage(
    val rawValue: String,
    val displayName: String,
    val monacoLanguage: String
) {
    JAVASCRIPT("javascript", "JavaScript", "javascript"),
    HTML("html", "HTML", "html"),
    TYPESCRIPT("typescript", "TypeScript", "typescript")
}

/**
 * Library features
 *
 * iOS equivalent: Library3DFeature enum in Library3D.swift (line 110)
 */
enum class Library3DFeature(val displayName: String) {
    WEBGL("WebGL"),
    WEBXR("WebXR"),
    VR("VR Support"),
    AR("AR Support"),
    PHYSICS("Physics Engine"),
    ANIMATION("Animation System"),
    LIGHTING("Advanced Lighting"),
    MATERIALS("Material System"),
    POST_PROCESSING("Post-Processing"),
    NODE_EDITOR("Node Editor"),
    DECLARATIVE("Declarative Syntax"),
    IMPERATIVE("Imperative Syntax")
}

/**
 * Factory for creating library instances
 *
 * iOS equivalent: Library3DFactory enum in Library3D.swift (line 158)
 */
object Library3DFactory {
    /**
     * Create all available libraries
     */
    fun createAllLibraries(): List<Library3D> {
        return listOf(
            BabylonJSLibrary(),
            ThreeJSLibrary(),
            AFrameLibrary(),
            ReactThreeFiberLibrary(),
            ReactylonLibrary()
        )
    }

    /**
     * Create library by ID
     */
    fun createLibrary(id: String): Library3D? {
        return createAllLibraries().find { it.id == id }
    }

    /**
     * Get default library (Babylon.js)
     */
    fun getDefaultLibrary(): Library3D {
        return BabylonJSLibrary()
    }
}

/**
 * Placeholder implementations (will be implemented in separate files)
 */
private class BabylonJSLibrary : Library3D {
    override val id = "babylonjs"
    override val displayName = "Babylon.js"
    override val description = "Powerful WebGL engine for 3D rendering"
    override val version = "6.0+"
    override val playgroundTemplate = ""
    override val systemPrompt = ""
    override val defaultSceneCode = ""
    override val codeLanguage = CodeLanguage.JAVASCRIPT
    override val iconName = "view_in_ar"
    override val supportedFeatures = setOf(
        Library3DFeature.WEBGL,
        Library3DFeature.WEBXR,
        Library3DFeature.VR,
        Library3DFeature.AR,
        Library3DFeature.PHYSICS,
        Library3DFeature.ANIMATION,
        Library3DFeature.LIGHTING,
        Library3DFeature.MATERIALS,
        Library3DFeature.POST_PROCESSING,
        Library3DFeature.NODE_EDITOR,
        Library3DFeature.IMPERATIVE
    )
    override val documentationURL = "https://doc.babylonjs.com/"
    override val examples = emptyList<CodeExample>()
}

private class ThreeJSLibrary : Library3D {
    override val id = "threejs"
    override val displayName = "Three.js"
    override val description = "Popular JavaScript 3D library"
    override val version = "0.171.0"
    override val playgroundTemplate = ""
    override val systemPrompt = ""
    override val defaultSceneCode = ""
    override val codeLanguage = CodeLanguage.JAVASCRIPT
    override val iconName = "category"
    override val supportedFeatures = setOf(
        Library3DFeature.WEBGL,
        Library3DFeature.WEBXR,
        Library3DFeature.VR,
        Library3DFeature.AR,
        Library3DFeature.ANIMATION,
        Library3DFeature.LIGHTING,
        Library3DFeature.MATERIALS,
        Library3DFeature.POST_PROCESSING,
        Library3DFeature.IMPERATIVE
    )
    override val documentationURL = "https://threejs.org/docs/"
    override val examples = emptyList<CodeExample>()
}

private class AFrameLibrary : Library3D {
    override val id = "aframe"
    override val displayName = "A-Frame"
    override val description = "Web framework for building VR experiences"
    override val version = "1.4.0"
    override val playgroundTemplate = ""
    override val systemPrompt = ""
    override val defaultSceneCode = ""
    override val codeLanguage = CodeLanguage.HTML
    override val iconName = "view_in_ar"
    override val supportedFeatures = setOf(
        Library3DFeature.WEBGL,
        Library3DFeature.WEBXR,
        Library3DFeature.VR,
        Library3DFeature.AR,
        Library3DFeature.DECLARATIVE
    )
    override val documentationURL = "https://aframe.io/docs/"
    override val examples = emptyList<CodeExample>()
}

private class ReactThreeFiberLibrary : Library3D {
    override val id = "reactThreeFiber"
    override val displayName = "React Three Fiber"
    override val description = "React renderer for Three.js"
    override val version = "8.17.10"
    override val playgroundTemplate = ""
    override val systemPrompt = ""
    override val defaultSceneCode = ""
    override val codeLanguage = CodeLanguage.TYPESCRIPT
    override val iconName = "code"
    override val supportedFeatures = setOf(
        Library3DFeature.WEBGL,
        Library3DFeature.WEBXR,
        Library3DFeature.VR,
        Library3DFeature.AR,
        Library3DFeature.DECLARATIVE
    )
    override val documentationURL = "https://docs.pmnd.rs/react-three-fiber/"
    override val examples = emptyList<CodeExample>()
}

private class ReactylonLibrary : Library3D {
    override val id = "reactylon"
    override val displayName = "Reactylon"
    override val description = "React renderer for Babylon.js"
    override val version = "3.2.1"
    override val playgroundTemplate = ""
    override val systemPrompt = ""
    override val defaultSceneCode = ""
    override val codeLanguage = CodeLanguage.TYPESCRIPT
    override val iconName = "code"
    override val supportedFeatures = setOf(
        Library3DFeature.WEBGL,
        Library3DFeature.WEBXR,
        Library3DFeature.VR,
        Library3DFeature.AR,
        Library3DFeature.DECLARATIVE
    )
    override val documentationURL = "https://www.reactylon.com/"
    override val examples = emptyList<CodeExample>()
}
