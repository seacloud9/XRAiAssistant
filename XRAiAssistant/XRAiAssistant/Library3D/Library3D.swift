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