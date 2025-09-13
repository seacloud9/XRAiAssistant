# XRAiAssistant Multi-Provider AI Integration

## Overview

XRAiAssistant now supports multiple AI providers, giving users the flexibility to choose from different AI models and providers based on their needs, preferences, and budget. The system supports:

- **Together.ai** - Cost-effective models with free options
- **OpenAI** - Industry-leading GPT models
- **Anthropic** - Advanced Claude models

## Architecture

### Provider System Components

1. **AIProvider Protocol** - Defines the interface for all AI providers
2. **Concrete Provider Classes** - Implementation for each provider (TogetherAI, OpenAI, Anthropic)
3. **AIProviderManager** - Centralized management of all providers and their configurations
4. **Smart Model Selection** - Organized dropdowns showing models by provider with pricing information

### Key Features

- **Multi-API Key Management** - Separate API key storage for each provider
- **Automatic Provider Detection** - Smart routing to the appropriate provider based on selected model
- **Fallback System** - Legacy support for existing Together.ai integration
- **Real-time Configuration** - Visual indicators showing which providers are configured
- **Settings Persistence** - All API keys automatically saved and restored

## Getting Started

### 1. Configure API Keys

To use XRAiAssistant with multiple providers, you'll need to configure API keys for the providers you want to use:

#### Together.ai (Cost-effective, has free models)
1. Visit [together.ai](https://together.ai)
2. Sign up for an account
3. Navigate to your dashboard and generate an API key
4. In XRAiAssistant settings, enter the key in the "Together.ai API Key" field

#### OpenAI (Industry-leading models)
1. Visit [platform.openai.com](https://platform.openai.com)
2. Sign up and verify your account
3. Go to the API Keys section
4. Generate a new API key (starts with `sk-`)
5. In XRAiAssistant settings, enter the key in the "OpenAI API Key" field

#### Anthropic (Advanced Claude models)
1. Visit [console.anthropic.com](https://console.anthropic.com)
2. Create an account and complete verification
3. Navigate to API Keys
4. Generate a new API key
5. In XRAiAssistant settings, enter the key in the "Anthropic API Key" field

### 2. Select Models

Once you've configured API keys, you can choose from organized model categories:

#### Together.ai Models
- **DeepSeek R1 70B** (FREE) - Advanced reasoning & coding
- **Llama 3.3 70B** (FREE) - Latest large model
- **Llama 3 8B Lite** ($0.10/1M tokens) - Cost-effective
- **Qwen 2.5 7B Turbo** ($0.30/1M tokens) - Fast coding specialist
- **Qwen 2.5 Coder 32B** ($0.80/1M tokens) - Advanced XR coding

#### OpenAI Models
- **GPT-4o** - Most advanced multimodal model
- **GPT-4o Mini** - Fast and affordable
- **GPT-4 Turbo** - Previous flagship model
- **GPT-3.5 Turbo** - Cost-effective option

#### Anthropic Models
- **Claude 3.5 Sonnet** - Most intelligent for complex tasks
- **Claude 3.5 Haiku** - Fast and affordable
- **Claude 3 Opus** - Most powerful model
- **Claude 3 Sonnet** - Balance of intelligence and speed

### 3. Smart Provider Indicators

The interface provides visual feedback about provider configuration:

- **Green checkmark** ✅ - Provider is configured and ready to use
- **Orange warning** ⚠️ - API key required for this provider
- **Blue provider tag** - Shows which provider owns the selected model

## Technical Implementation

### Provider Interface

All providers implement the `AIProvider` protocol:

```swift
protocol AIProvider {
    var name: String { get }
    var models: [AIModel] { get }
    var requiresAPIKey: Bool { get }
    
    func configure(apiKey: String)
    func generateResponse(
        messages: [AIMessage],
        model: String,
        temperature: Double,
        topP: Double
    ) async throws -> AsyncThrowingStream<String, Error>
}
```

### Model Structure

Each model includes comprehensive metadata:

```swift
struct AIModel {
    let id: String          // API model identifier
    let displayName: String // Human-readable name
    let description: String // Model capabilities
    let pricing: String     // Cost information
    let provider: String    // Provider name
    let isDefault: Bool     // Default model for provider
}
```

### Smart Routing

The system automatically routes requests to the appropriate provider:

1. **New Provider System** - Uses configured providers for supported models
2. **Legacy Fallback** - Falls back to original Together.ai integration
3. **Error Handling** - Graceful degradation when providers are unavailable

## Usage Examples

### Basic Usage

1. Open XRAiAssistant
2. Tap Settings (gear icon)
3. Configure API keys for desired providers
4. Tap Save
5. Select a model from the organized dropdown
6. Start creating 3D scenes with AI assistance

### Cost Optimization

To minimize costs:

1. **Start with free models** - Use Together.ai's free DeepSeek R1 70B or Llama 3.3 70B
2. **Use appropriate model sizes** - Choose smaller models for simple tasks
3. **Monitor usage** - Each provider has usage dashboards
4. **Compare pricing** - Check pricing information in model descriptions

### Advanced Configuration

For power users:

1. **Multiple providers** - Configure all three providers for maximum flexibility
2. **Model comparison** - Try the same prompt with different models to compare results
3. **Parameter tuning** - Adjust temperature and top-p settings per provider
4. **Custom system prompts** - Fine-tune AI behavior for specific use cases

## Best Practices

### Security
- **Never share API keys** - Keep your API keys private and secure
- **Use separate keys** - Different keys for development and production
- **Monitor usage** - Regularly check your provider dashboards for unusual activity

### Performance
- **Choose appropriate models** - Larger models aren't always better
- **Batch requests** - Group related operations when possible
- **Cache responses** - The app automatically caches recent responses

### Troubleshooting

#### Model Selection Issues
- **Provider not configured** - Ensure API key is entered and saved
- **Invalid API key** - Check that the key is correct and has permissions
- **Rate limiting** - Some providers have usage limits

#### Generation Issues
- **Empty responses** - Check API key validity and account status
- **Error messages** - Review provider documentation for specific error codes
- **Slow responses** - Some models take longer than others

## Provider Comparison

| Feature | Together.ai | OpenAI | Anthropic |
|---------|-------------|---------|-----------|
| **Free Models** | ✅ Yes (DeepSeek R1, Llama 3.3) | ❌ No | ❌ No |
| **Coding Capability** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **3D/XR Knowledge** | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |
| **Cost per Token** | Low-High | Medium-High | Medium-High |
| **Response Speed** | Fast | Medium | Medium |
| **Model Variety** | High | Medium | Medium |

## Migration from Legacy System

If you're upgrading from the previous version:

1. **Existing Together.ai keys** - Will continue to work automatically
2. **Model selection** - Legacy models appear in "Legacy" section
3. **Gradual transition** - You can use both old and new systems simultaneously
4. **Settings migration** - Old settings are automatically preserved

## API Reference

### ChatViewModel Methods

```swift
// Multi-provider API key management
func setAPIKey(for provider: String, key: String)
func getAPIKey(for provider: String) -> String
func isProviderConfigured(_ provider: String) -> Bool

// Provider and model information
func getConfiguredProviders() -> [AIProvider]
var modelsByProvider: [String: [AIModel]]
var allAvailableModels: [AIModel]

// Model display helpers
func getModelDisplayName(_ modelId: String) -> String
func getModelDescription(_ modelId: String) -> String
```

### AIProviderManager Methods

```swift
func setCurrentProvider(_ provider: AIProvider)
func getProvider(for modelId: String) -> AIProvider?
func generateResponse(messages:model:temperature:topP:) -> AsyncThrowingStream
```

## Future Enhancements

Planned improvements include:

- **Additional Providers** - Support for more AI providers
- **Cost Tracking** - Built-in usage monitoring
- **Model Performance Analytics** - Compare model performance
- **Custom Provider Integration** - Support for self-hosted models
- **Multi-modal Support** - Image and video model integration

---

## Support

For issues or questions:

1. **Check provider status** - Ensure your chosen provider is operational
2. **Verify API keys** - Confirm keys are valid and have sufficient credits
3. **Review documentation** - Check provider-specific documentation
4. **Test with free models** - Use Together.ai free models for troubleshooting

This multi-provider system brings professional-grade AI capability to XRAiAssistant while maintaining the simplicity and creativity that makes 3D development accessible to everyone.