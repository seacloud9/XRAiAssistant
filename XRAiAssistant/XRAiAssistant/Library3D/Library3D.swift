import Foundation

// MARK: - 3D Library Protocol

protocol Library3D: Identifiable, Hashable {
    var id: String { get }
    var displayName: String { get }
    var description: String { get }
    var version: String { get }
    var playgroundTemplate: String { get }
    var systemPrompt: String { get }
    var defaultSceneCode: String { get }
    var codeLanguage: CodeLanguage { get }
    var iconName: String { get }
    var supportedFeatures: Set<Library3DFeature> { get }
    var documentationURL: String { get }
    var examples: [CodeExample] { get }
}

// MARK: - Code Example Model
struct CodeExample: Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
    let code: String
    let category: ExampleCategory
    let difficulty: ExampleDifficulty

    // MARK: - Enhanced Metadata (for AI-assisted scene generation)
    let keywords: [String]           // Searchable keywords for finding similar examples
    let aiPromptHints: String?       // Hints for AI when generating similar scenes

    init(
        id: String? = nil,
        title: String,
        description: String,
        code: String,
        category: ExampleCategory,
        difficulty: ExampleDifficulty = .beginner,
        keywords: [String] = [],
        aiPromptHints: String? = nil
    ) {
        self.id = id ?? UUID().uuidString
        self.title = title
        self.description = description
        self.code = code
        self.category = category
        self.difficulty = difficulty
        self.keywords = keywords
        self.aiPromptHints = aiPromptHints
    }
}

enum ExampleCategory: String, CaseIterable {
    case basic = "Basic Shapes"
    case animation = "Animation"
    case lighting = "Lighting"
    case materials = "Materials"
    case interaction = "Interaction"
    case physics = "Physics"
    case effects = "Effects"
    case vr = "VR/XR"
    case advanced = "Advanced"

    var icon: String {
        switch self {
        case .basic: return "cube"
        case .animation: return "rotate.3d"
        case .lighting: return "lightbulb"
        case .materials: return "paintbrush"
        case .interaction: return "hand.tap"
        case .physics: return "figure.fall"
        case .effects: return "sparkles"
        case .vr: return "visionpro"
        case .advanced: return "gearshape.2"
        }
    }
}

enum ExampleDifficulty: String {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
}

// MARK: - Supporting Types

enum CodeLanguage: String, CaseIterable {
    case javascript = "javascript"
    case html = "html"
    case typescript = "typescript"
    
    var displayName: String {
        switch self {
        case .javascript: return "JavaScript"
        case .html: return "HTML"
        case .typescript: return "TypeScript"
        }
    }
    
    var monacoLanguage: String {
        switch self {
        case .javascript: return "javascript"
        case .html: return "html"
        case .typescript: return "typescript"
        }
    }
}

enum Library3DFeature: String, CaseIterable {
    case webgl = "webgl"
    case webxr = "webxr"
    case vr = "vr"
    case ar = "ar"
    case physics = "physics"
    case animation = "animation"
    case lighting = "lighting"
    case materials = "materials"
    case postProcessing = "postProcessing"
    case nodeEditor = "nodeEditor"
    case declarative = "declarative"
    case imperative = "imperative"
    
    var displayName: String {
        switch self {
        case .webgl: return "WebGL"
        case .webxr: return "WebXR"
        case .vr: return "VR Support"
        case .ar: return "AR Support"
        case .physics: return "Physics Engine"
        case .animation: return "Animation System"
        case .lighting: return "Advanced Lighting"
        case .materials: return "Material System"
        case .postProcessing: return "Post-Processing"
        case .nodeEditor: return "Node Editor"
        case .declarative: return "Declarative Syntax"
        case .imperative: return "Imperative Syntax"
        }
    }
}

// MARK: - Default Implementation

extension Library3D {
    // Default Hashable implementation
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Default Equatable implementation
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Library3D Factory

enum Library3DFactory {
    static func createAllLibraries() -> [any Library3D] {
        return [
            BabylonJSLibrary(),
            ThreeJSLibrary(),
            AFrameLibrary(),
            ReactThreeFiberLibrary(),
            ReactylonLibrary()
        ]
    }
    
    static func createLibrary(id: String) -> (any Library3D)? {
        return createAllLibraries().first { $0.id == id }
    }
    
    static func getDefaultLibrary() -> any Library3D {
        return BabylonJSLibrary()
    }
}