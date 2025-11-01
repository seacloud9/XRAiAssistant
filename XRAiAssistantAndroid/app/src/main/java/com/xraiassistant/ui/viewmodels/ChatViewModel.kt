package com.xraiassistant.ui.viewmodels

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.xraiassistant.data.models.AIModel
import com.xraiassistant.data.models.AIModels
import com.xraiassistant.data.models.ChatMessage
import com.xraiassistant.data.repositories.AIProviderRepository
import com.xraiassistant.data.repositories.Library3DRepository
import com.xraiassistant.data.repositories.SettingsRepository
import com.xraiassistant.domain.models.Library3D
import com.xraiassistant.ui.screens.AppView
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

/**
 * UI State for Chat screen
 */
data class ChatUiState(
    val showSettings: Boolean = false,
    val settingsSaved: Boolean = false,
    val currentView: AppView = AppView.CHAT,
    val isInjectingCode: Boolean = false,
    val webViewReady: Boolean = false
)

/**
 * ChatViewModel - Core AI integration hub for XRAiAssistant
 * 
 * Kotlin/Android port of iOS ChatViewModel.swift
 * Manages AI conversations, 3D library selection, and code generation
 */
@HiltViewModel
class ChatViewModel @Inject constructor(
    private val aiProviderRepository: AIProviderRepository,
    private val library3DRepository: Library3DRepository,
    private val settingsRepository: SettingsRepository
) : ViewModel() {

    // MARK: - UI State
    private val _uiState = MutableStateFlow(ChatUiState())
    val uiState: StateFlow<ChatUiState> = _uiState.asStateFlow()

    // MARK: - Messages
    private val _messages = MutableStateFlow<List<ChatMessage>>(emptyList())
    val messages: StateFlow<List<ChatMessage>> = _messages.asStateFlow()

    // MARK: - Loading State
    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    // MARK: - Error State
    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    // MARK: - AI Configuration
    private val _selectedModel = MutableStateFlow(AIModels.DEEPSEEK_R1_70B.id)
    var selectedModel: String
        get() = _selectedModel.value
        set(value) { _selectedModel.value = value }

    private val _temperature = MutableStateFlow(0.7f)
    var temperature: Float
        get() = _temperature.value
        set(value) { _temperature.value = value.coerceIn(0.0f, 2.0f) }

    private val _topP = MutableStateFlow(0.9f)
    var topP: Float
        get() = _topP.value
        set(value) { _topP.value = value.coerceIn(0.1f, 1.0f) }

    private val _systemPrompt = MutableStateFlow("")
    var systemPrompt: String
        get() = _systemPrompt.value
        set(value) { _systemPrompt.value = value }

    // MARK: - 3D Library
    private val _currentLibrary = MutableStateFlow<Library3D?>(null)
    val currentLibrary: StateFlow<Library3D?> = _currentLibrary.asStateFlow()
    
    val currentLibraryId: String
        get() = _currentLibrary.value?.id ?: "babylonjs"

    // MARK: - Generated Code
    private val _lastGeneratedCode = MutableStateFlow("")
    val lastGeneratedCode: StateFlow<String> = _lastGeneratedCode.asStateFlow()

    // MARK: - Callbacks (equivalent to iOS closures)
    var onInsertCode: ((String) -> Unit)? = null
    var onRunScene: (() -> Unit)? = null
    var onDescribeScene: ((String) -> Unit)? = null
    var onInsertCodeWithBuild: ((String, Library3D) -> Unit)? = null

    init {
        println("🚀 ChatViewModel initialization starting...")

        // Initialize UI state
        _uiState.value = ChatUiState()

        // Setup in correct order (matching iOS):
        // 1. Setup initial welcome message
        // 2. Setup default system prompt from library
        // 3. Load saved settings (which may override system prompt)
        setupInitialMessage()
        setupDefaultSystemPrompt()
        loadSettings()

        println("✅ ChatViewModel initialization complete")
    }

    /**
     * Setup initial welcome message
     * Equivalent to iOS setupInitialMessage()
     */
    private fun setupInitialMessage() {
        val defaultLibrary = library3DRepository.getDefaultLibrary()
        _currentLibrary.value = defaultLibrary

        var welcomeContent = defaultLibrary.getWelcomeMessage()

        // Check if API key is configured
        val currentAPIKey = aiProviderRepository.getAPIKey("Together.ai")
        if (currentAPIKey == "changeMe" || currentAPIKey.length < 10) {
            welcomeContent += "\n\n⚠️ **Setup Required**: Please configure your Together.ai API key in Settings (gear icon) to start chatting. Get your free API key at https://api.together.ai/settings/api-keys"
        }

        val welcomeMessage = ChatMessage(
            id = java.util.UUID.randomUUID().toString(),
            content = welcomeContent,
            isUser = false,
            timestamp = java.util.Date()
        )
        _messages.value = listOf(welcomeMessage)
    }

    /**
     * Setup default system prompt from current library
     * Equivalent to iOS setupDefaultSystemPrompt()
     */
    private fun setupDefaultSystemPrompt() {
        val defaultLibrary = library3DRepository.getDefaultLibrary()
        _systemPrompt.value = defaultLibrary.systemPrompt
        println("📝 Default system prompt set from ${defaultLibrary.displayName} (${_systemPrompt.value.length} characters)")
    }

    // MARK: - Core Chat Functions

    /**
     * Send message to AI and handle response
     * Equivalent to sendMessage in iOS
     */
    /**
     * Send message with streaming response (NEW - iOS parity)
     *
     * Provides real-time feedback as AI generates response, matching iOS behavior.
     */
    fun sendMessage(content: String, currentCode: String = "") {
        if (content.isBlank()) return

        viewModelScope.launch {
            try {
                _isLoading.value = true
                _errorMessage.value = null

                // Add user message
                val userMessage = ChatMessage.userMessage(content)
                _messages.value = _messages.value + userMessage

                // Get current library for context
                val library = _currentLibrary.value
                val enhancedPrompt = buildPrompt(content, currentCode, library)

                // Create placeholder AI message that will be updated with streaming chunks
                val placeholderMessage = ChatMessage.aiMessage(
                    content = "",
                    model = getModelDisplayName(_selectedModel.value)
                )
                _messages.value = _messages.value + placeholderMessage
                val messageIndex = _messages.value.lastIndex

                // Collect streaming response
                val fullResponse = StringBuilder()

                aiProviderRepository.generateResponseStream(
                    prompt = enhancedPrompt,
                    model = _selectedModel.value,
                    temperature = _temperature.value.toDouble(),
                    topP = _topP.value.toDouble(),
                    systemPrompt = _systemPrompt.value
                ).collect { chunk ->
                    // Append chunk to full response
                    fullResponse.append(chunk)

                    // Update the message in real-time
                    val updatedMessages = _messages.value.toMutableList()
                    updatedMessages[messageIndex] = ChatMessage.aiMessage(
                        content = fullResponse.toString(),
                        model = getModelDisplayName(_selectedModel.value)
                    )
                    _messages.value = updatedMessages
                }

                // Process complete response for code extraction
                processAIResponse(fullResponse.toString(), library)

            } catch (e: Exception) {
                // User-friendly error messages matching iOS
                val errorMsg = when {
                    e.message?.contains("401") == true ->
                        "⚠️ Invalid API Key: Please verify your API key in Settings"
                    e.message?.contains("API key not configured") == true ->
                        "⚠️ API Key Required: Please configure your API key in Settings"
                    else ->
                        "Failed to get response: ${e.message ?: "Unknown error"}"
                }
                _errorMessage.value = errorMsg
            } finally {
                _isLoading.value = false
            }
        }
    }

    /**
     * Send message without streaming (fallback for compatibility)
     */
    fun sendMessageNonStreaming(content: String, currentCode: String = "") {
        if (content.isBlank()) return

        viewModelScope.launch {
            try {
                _isLoading.value = true
                _errorMessage.value = null

                // Add user message
                val userMessage = ChatMessage.userMessage(content)
                _messages.value = _messages.value + userMessage

                // Get current library for context
                val library = _currentLibrary.value
                val enhancedPrompt = buildPrompt(content, currentCode, library)

                // Call AI service (non-streaming)
                val response = aiProviderRepository.generateResponse(
                    prompt = enhancedPrompt,
                    model = _selectedModel.value,
                    temperature = _temperature.value.toDouble(),
                    topP = _topP.value.toDouble(),
                    systemPrompt = _systemPrompt.value
                )

                // Add AI response
                val aiMessage = ChatMessage.aiMessage(
                    content = response,
                    model = getModelDisplayName(_selectedModel.value)
                )
                _messages.value = _messages.value + aiMessage

                // Process response for code extraction
                processAIResponse(response, library)

            } catch (e: Exception) {
                val errorMsg = when {
                    e.message?.contains("401") == true ->
                        "⚠️ Invalid API Key: Please verify your API key in Settings"
                    e.message?.contains("API key not configured") == true ->
                        "⚠️ API Key Required: Please configure your API key in Settings"
                    else ->
                        "Failed to get response: ${e.message ?: "Unknown error"}"
                }
                _errorMessage.value = errorMsg
            } finally {
                _isLoading.value = false
            }
        }
    }

    // MARK: - AI Response Processing

    /**
     * Process AI response and extract code if present
     * Equivalent to iOS code extraction logic
     */
    private fun processAIResponse(response: String, library: Library3D?) {
        println("🔍 Processing AI response for code extraction...")

        // Look for code blocks in response (matching iOS patterns)
        // Pattern 1: [INSERT_CODE]```...```[/INSERT_CODE]
        val primaryPattern = "\\[INSERT_CODE\\]```(?:javascript|typescript|html)?\\n([\\s\\S]*?)\\n```\\[/INSERT_CODE\\]".toRegex()
        var codeMatch = primaryPattern.find(response)

        if (codeMatch != null) {
            val extractedCode = codeMatch.groupValues[1].trim()
            println("✅ Code extracted via PRIMARY pattern (${extractedCode.length} chars)")
            _lastGeneratedCode.value = extractedCode

            // Trigger code insertion callback
            if (library?.requiresBuild == true) {
                println("🏗️ Library requires build, calling onInsertCodeWithBuild")
                onInsertCodeWithBuild?.invoke(extractedCode, library)
            } else {
                println("📝 Direct injection, calling onInsertCode")
                onInsertCode?.invoke(extractedCode)
            }
        } else {
            // Pattern 2: Any code block with ```javascript or ```typescript
            val fallbackPattern = "```(?:javascript|typescript|html)\\n([\\s\\S]*?)```".toRegex()
            codeMatch = fallbackPattern.find(response)

            if (codeMatch != null) {
                val extractedCode = codeMatch.groupValues[1].trim()
                println("✅ Code extracted via FALLBACK pattern (${extractedCode.length} chars)")

                // Only inject if code is substantial (matching iOS logic)
                if (extractedCode.length > 50) {
                    _lastGeneratedCode.value = extractedCode

                    if (library?.requiresBuild == true) {
                        onInsertCodeWithBuild?.invoke(extractedCode, library)
                    } else {
                        onInsertCode?.invoke(extractedCode)
                    }
                } else {
                    println("⚠️ Code too short (${extractedCode.length} chars), skipping injection")
                }
            } else {
                println("⚠️ No code blocks found in AI response")
            }
        }

        // Check for run scene command
        if (response.contains("[RUN_SCENE]")) {
            println("✅ Found [RUN_SCENE] command")
            onRunScene?.invoke()
        }

        // Check for scene description
        if (response.contains("[DESCRIBE_SCENE]")) {
            println("✅ Found [DESCRIBE_SCENE] command")
            onDescribeScene?.invoke(response)
        }
    }

    // MARK: - AI Parameter Management

    /**
     * Get parameter description based on current settings
     * Equivalent to iOS getParameterDescription()
     */
    fun getParameterDescription(): String {
        val temp = _temperature.value.toDouble()
        val topP = _topP.value.toDouble()

        return when {
            temp in 0.0..0.3 && topP in 0.1..0.5 -> "Precise & Focused - Perfect for debugging"
            temp in 0.4..0.8 && topP in 0.6..0.9 -> "Balanced Creativity - Ideal for most scenes"
            temp in 0.9..2.0 && topP in 0.9..1.0 -> "Experimental Mode - Maximum innovation"
            else -> "Custom Configuration"
        }
    }

    /**
     * Update AI parameters
     */
    fun updateTemperature(value: Double) {
        _temperature.value = value.toFloat().coerceIn(0.0f, 2.0f)
    }

    fun updateTopP(value: Double) {
        _topP.value = value.toFloat().coerceIn(0.1f, 1.0f)
    }

    fun updateSystemPrompt(prompt: String) {
        _systemPrompt.value = prompt
    }

    fun updateSelectedModel(modelId: String) {
        _selectedModel.value = modelId
    }

    // MARK: - 3D Library Management

    /**
     * Select 3D library and update system prompt
     * Matches iOS selectLibrary() behavior
     */
    fun selectLibrary(libraryId: String) {
        viewModelScope.launch {
            val library = library3DRepository.getLibraryById(libraryId)
            _currentLibrary.value = library

            library?.let {
                // Update system prompt with library's default
                _systemPrompt.value = it.systemPrompt

                // Update welcome message if it exists
                if (_messages.value.isNotEmpty()) {
                    val updatedMessages = _messages.value.toMutableList()
                    updatedMessages[0] = ChatMessage(
                        id = updatedMessages[0].id,
                        content = it.getWelcomeMessage(),
                        isUser = false,
                        timestamp = updatedMessages[0].timestamp
                    )
                    _messages.value = updatedMessages
                }

                println("🎯 Switched to ${it.displayName}")
                println("📊 System prompt updated (${_systemPrompt.value.length} characters)")
            }
        }
    }

    fun getCurrentLibrary(): Library3D {
        return _currentLibrary.value ?: library3DRepository.getDefaultLibrary()
    }

    fun getAvailableLibraries(): List<Library3D> = library3DRepository.getAllLibraries()
    
    /**
     * Get model description for legacy compatibility
     */
    fun getModelDescription(modelId: String): String {
        return AIModels.ALL_MODELS.find { it.id == modelId }?.description ?: "AI Model"
    }

    // MARK: - Settings Management

    /**
     * Save all settings to persistent storage
     * Equivalent to iOS saveSettings()
     */
    fun saveSettings() {
        viewModelScope.launch {
            settingsRepository.saveSettings(
                selectedModel = _selectedModel.value,
                temperature = _temperature.value.toDouble(),
                topP = _topP.value.toDouble(),
                systemPrompt = _systemPrompt.value,
                selectedLibraryId = _currentLibrary.value?.id
            )
        }
    }

    /**
     * Load settings from persistent storage
     * Matches iOS loadSettings() behavior
     */
    private fun loadSettings() {
        viewModelScope.launch {
            val settings = settingsRepository.getSettings()
            _selectedModel.value = settings.selectedModel
            _temperature.value = settings.temperature.toFloat()
            _topP.value = settings.topP.toFloat()

            // Only override system prompt if a custom one was saved (matching iOS)
            if (settings.systemPrompt.isNotEmpty()) {
                _systemPrompt.value = settings.systemPrompt
                println("📝 Loaded custom system prompt (${settings.systemPrompt.length} characters)")
            } else {
                println("📝 No custom system prompt saved, using library default (${_systemPrompt.value.length} characters)")
            }

            settings.selectedLibraryId?.let { libraryId ->
                selectLibrary(libraryId)
            }

            println("✅ Settings loaded successfully")
        }
    }

    private fun loadDefaultLibrary() {
        viewModelScope.launch {
            val defaultLibrary = library3DRepository.getDefaultLibrary()
            _currentLibrary.value = defaultLibrary
            _systemPrompt.value = defaultLibrary.systemPrompt
        }
    }

    // MARK: - Provider Management

    /**
     * Check if a provider is configured with API key
     */
    fun isProviderConfigured(provider: String): Boolean {
        return aiProviderRepository.isProviderConfigured(provider)
    }

    /**
     * Set API key for provider
     */
    fun setAPIKey(provider: String, key: String) {
        viewModelScope.launch {
            aiProviderRepository.setAPIKey(provider, key)
        }
    }

    /**
     * Get API key for provider (masked for display)
     */
    fun getAPIKey(provider: String): String {
        return aiProviderRepository.getAPIKey(provider)
    }

    // MARK: - Helper Functions

    /**
     * Get display name for model ID
     */
    fun getModelDisplayName(modelId: String): String {
        return AIModels.ALL_MODELS.find { it.id == modelId }?.displayName ?: modelId
    }

    /**
     * Get all available models grouped by provider
     */
    val modelsByProvider: Map<String, List<AIModel>>
        get() = AIModels.MODELS_BY_PROVIDER
    
    /**
     * Get all available models (flat list)
     */
    val allAvailableModels: List<AIModel>
        get() = AIModels.ALL_MODELS
    
    /**
     * Get available models (legacy compatibility)
     */
    val availableModels: List<String>
        get() = AIModels.ALL_MODELS.map { it.id }

    /**
     * Build enhanced prompt with library context
     */
    private fun buildPrompt(userMessage: String, currentCode: String, library: Library3D?): String {
        val libraryContext = library?.let { 
            "Current 3D Library: ${it.displayName} (${it.version})\n" +
            "Language: ${it.codeLanguage}\n"
        } ?: ""

        val codeContext = if (currentCode.isNotBlank()) {
            "Current code in editor:\n```\n$currentCode\n```\n\n"
        } else ""

        return "$libraryContext$codeContext$userMessage"
    }

    /**
     * Clear error message
     */
    fun clearError() {
        _errorMessage.value = null
    }
    
    // MARK: - UI State Management
    
    /**
     * Update current view
     */
    fun updateCurrentView(view: AppView) {
        _uiState.value = _uiState.value.copy(currentView = view)
    }
    
    /**
     * Show settings modal
     */
    fun showSettings() {
        _uiState.value = _uiState.value.copy(showSettings = true)
    }
    
    /**
     * Hide settings modal
     */
    fun hideSettings() {
        _uiState.value = _uiState.value.copy(showSettings = false, settingsSaved = false)
    }
    
    /**
     * Set code injection loading state
     */
    fun setCodeInjecting(isInjecting: Boolean) {
        _uiState.value = _uiState.value.copy(isInjectingCode = isInjecting)
    }
    
    /**
     * Set WebView ready state
     */
    fun setWebViewReady(ready: Boolean) {
        _uiState.value = _uiState.value.copy(webViewReady = ready)
    }
    
    /**
     * Show settings saved confirmation
     */
    fun showSettingsSaved() {
        _uiState.value = _uiState.value.copy(settingsSaved = true)
    }
}