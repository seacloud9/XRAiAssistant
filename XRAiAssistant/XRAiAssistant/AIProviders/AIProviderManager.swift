import Foundation
import SwiftUI

class AIProviderManager: ObservableObject {
    @Published var providers: [AIProvider] = []
    @Published var currentProvider: AIProvider?
    @Published var apiKeys: [String: String] = [:]
    
    private let togetherProvider = TogetherAIProvider()
    private let openaiProvider = OpenAIProvider()
    private let anthropicProvider = AnthropicProvider()
    
    init() {
        setupProviders()
        loadAPIKeys()
    }
    
    private func setupProviders() {
        providers = [togetherProvider, openaiProvider, anthropicProvider]
        currentProvider = togetherProvider // Default to Together.ai
        
        // Initialize CodeSandbox API key (not a chat provider, but deployment service)
        if apiKeys["CodeSandbox"] == nil {
            apiKeys["CodeSandbox"] = "" // Empty by default for optional service
        }
    }
    
    func setAPIKey(for provider: String, key: String) {
        apiKeys[provider] = key
        saveAPIKeys()
        
        // Configure the provider with the new key
        if let providerInstance = providers.first(where: { $0.name == provider }) {
            providerInstance.configure(apiKey: key)
            
            // If this is the current provider, update it
            if currentProvider?.name == provider {
                currentProvider = providerInstance
            }
        }
    }
    
    func getAPIKey(for provider: String) -> String {
        return apiKeys[provider] ?? "changeMe"
    }
    
    func setCurrentProvider(_ provider: AIProvider) {
        currentProvider = provider
        
        // Configure with existing API key if available
        let apiKey = getAPIKey(for: provider.name)
        if apiKey != "changeMe" {
            provider.configure(apiKey: apiKey)
        }
    }
    
    func getAllModels() -> [AIModel] {
        return providers.flatMap { $0.models }
    }
    
    func getModelsByProvider() -> [String: [AIModel]] {
        var modelsByProvider: [String: [AIModel]] = [:]
        for provider in providers {
            modelsByProvider[provider.name] = provider.models
        }
        return modelsByProvider
    }
    
    func getProvider(for modelId: String) -> AIProvider? {
        return providers.first { provider in
            provider.models.contains { $0.id == modelId }
        }
    }
    
    func getModel(id: String) -> AIModel? {
        return getAllModels().first { $0.id == id }
    }
    
    func getDefaultModel(for provider: String) -> AIModel? {
        return providers.first(where: { $0.name == provider })?
            .models.first(where: { $0.isDefault }) ??
            providers.first(where: { $0.name == provider })?.models.first
    }
    
    func generateResponse(
        messages: [AIMessage],
        modelId: String,
        temperature: Double,
        topP: Double
    ) async throws -> AsyncThrowingStream<String, Error> {
        
        guard let provider = getProvider(for: modelId) else {
            throw AIProviderError.modelNotSupported
        }
        
        // Ensure provider is configured with API key
        let apiKey = getAPIKey(for: provider.name)
        if apiKey == "changeMe" {
            throw AIProviderError.configurationError("API key not configured for \(provider.name)")
        }
        
        provider.configure(apiKey: apiKey)
        
        return try await provider.generateResponse(
            messages: messages,
            model: modelId,
            temperature: temperature,
            topP: topP
        )
    }
    
    // MARK: - Persistence
    
    private func saveAPIKeys() {
        for (provider, key) in apiKeys {
            UserDefaults.standard.set(key, forKey: "XRAiAssistant_APIKey_\(provider)")
        }
        print("💾 Saved API keys for \(apiKeys.count) providers")
    }
    
    private func loadAPIKeys() {
        for provider in providers {
            let key = UserDefaults.standard.string(forKey: "XRAiAssistant_APIKey_\(provider.name)") ?? "changeMe"
            apiKeys[provider.name] = key
            
            if key != "changeMe" {
                provider.configure(apiKey: key)
                print("🔑 Loaded API key for \(provider.name): \(String(key.prefix(10)))...")
            }
        }
        print("📂 Loaded API keys for \(providers.count) providers")
    }
    
    func isProviderConfigured(_ provider: String) -> Bool {
        let apiKey = getAPIKey(for: provider)
        
        // CodeSandbox is optional, so empty key is acceptable
        if provider == "CodeSandbox" {
            return true // Always considered "configured" since it's optional
        }
        
        return apiKey != "changeMe" && !apiKey.isEmpty
    }
    
    func getConfiguredProviders() -> [AIProvider] {
        return providers.filter { isProviderConfigured($0.name) }
    }
}