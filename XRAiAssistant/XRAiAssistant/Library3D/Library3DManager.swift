import Foundation
import SwiftUI

class Library3DManager: ObservableObject {
    @Published var availableLibraries: [AnyLibrary3D] = []
    @Published var selectedLibrary: AnyLibrary3D = AnyLibrary3D(BabylonJSLibrary()) {
        didSet {
            saveSelectedLibrary()
        }
    }
    
    // Type-erased wrapper for library storage
    struct AnyLibrary3D: Library3D {
        private let _library: any Library3D
        
        init(_ library: any Library3D) {
            self._library = library
        }
        
        var id: String { _library.id }
        var displayName: String { _library.displayName }
        var description: String { _library.description }
        var version: String { _library.version }
        var playgroundTemplate: String { _library.playgroundTemplate }
        var systemPrompt: String { _library.systemPrompt }
        var defaultSceneCode: String { _library.defaultSceneCode }
        var codeLanguage: CodeLanguage { _library.codeLanguage }
        var iconName: String { _library.iconName }
        var supportedFeatures: Set<Library3DFeature> { _library.supportedFeatures }
        var documentationURL: String { _library.documentationURL }
        var examples: [CodeExample] { _library.examples }
        
        // Manual Hashable implementation
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        // Manual Equatable implementation
        static func == (lhs: AnyLibrary3D, rhs: AnyLibrary3D) -> Bool {
            return lhs.id == rhs.id
        }
    }
    
    init() {
        setupAvailableLibraries()
        loadSelectedLibrary()
    }
    
    private func setupAvailableLibraries() {
        let rawLibraries = Library3DFactory.createAllLibraries()
        availableLibraries = rawLibraries.map { AnyLibrary3D($0) }
        print("📚 Initialized \(availableLibraries.count) 3D libraries")
        
        // Log available libraries
        for library in availableLibraries {
            print("  - \(library.displayName) (\(library.id)): \(library.description)")
        }
    }
    
    func selectLibrary(id: String) {
        guard let library = availableLibraries.first(where: { $0.id == id }) else {
            print("❌ Library not found: \(id)")
            return
        }
        
        print("🎯 Switching to library: \(library.displayName)")
        selectedLibrary = library
    }
    
    func selectLibrary(_ library: any Library3D) {
        print("🎯 Switching to library: \(library.displayName)")
        selectedLibrary = AnyLibrary3D(library)
    }
    
    func getLibrary(id: String) -> AnyLibrary3D? {
        return availableLibraries.first { $0.id == id }
    }
    
    func getSystemPrompt() -> String {
        return selectedLibrary.systemPrompt
    }
    
    func getDefaultSceneCode() -> String {
        return selectedLibrary.defaultSceneCode
    }
    
    func getPlaygroundTemplate() -> String {
        return selectedLibrary.playgroundTemplate
    }
    
    func getCodeLanguage() -> CodeLanguage {
        return selectedLibrary.codeLanguage
    }
    
    // MARK: - Persistence
    
    private func saveSelectedLibrary() {
        UserDefaults.standard.set(selectedLibrary.id, forKey: "XRAiAssistant_Selected3DLibrary")
        print("💾 Saved selected 3D library: \(selectedLibrary.displayName)")
    }
    
    private func loadSelectedLibrary() {
        let savedLibraryId = UserDefaults.standard.string(forKey: "XRAiAssistant_Selected3DLibrary") ?? "babylonjs"
        
        if let library = availableLibraries.first(where: { $0.id == savedLibraryId }) {
            selectedLibrary = library
            print("📂 Loaded saved 3D library: \(library.displayName)")
        } else {
            selectedLibrary = AnyLibrary3D(Library3DFactory.getDefaultLibrary())
            print("📂 Using default 3D library: \(selectedLibrary.displayName)")
        }
    }
    
    // MARK: - Library Information
    
    func getLibraryFeatures(_ library: AnyLibrary3D) -> [Library3DFeature] {
        return Array(library.supportedFeatures).sorted { $0.displayName < $1.displayName }
    }
    
    func isFeatureSupported(_ feature: Library3DFeature, in library: AnyLibrary3D) -> Bool {
        return library.supportedFeatures.contains(feature)
    }
    
    func getLibraryComparison() -> [String: [Library3DFeature]] {
        var comparison: [String: [Library3DFeature]] = [:]
        
        for library in availableLibraries {
            comparison[library.displayName] = getLibraryFeatures(library)
        }
        
        return comparison
    }
    
    // MARK: - Helper Methods
    
    func getWelcomeMessage() -> String {
        return "Hello! I'm your \(selectedLibrary.displayName) assistant. I can help you create 3D scenes, explain concepts, and write code. Try asking me to create a scene or help with specific \(selectedLibrary.displayName) features!"
    }
    
    func getLibrarySpecificPrompt(for userMessage: String, currentCode: String? = nil) -> String {
        var prompt = selectedLibrary.systemPrompt
        
        if let code = currentCode, !code.isEmpty {
            prompt += "\n\nCurrent scene code:\n```\(selectedLibrary.codeLanguage.rawValue)\n\(code)\n```"
        }
        
        return prompt
    }
}