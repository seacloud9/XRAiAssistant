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
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

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
    val selectedModel: StateFlow<String> = _selectedModel.asStateFlow()

    private val _temperature = MutableStateFlow(0.7)
    val temperature: StateFlow<Double> = _temperature.asStateFlow()

    private val _topP = MutableStateFlow(0.9)
    val topP: StateFlow<Double> = _topP.asStateFlow()

    private val _systemPrompt = MutableStateFlow("")
    val systemPrompt: StateFlow<String> = _systemPrompt.asStateFlow()

    // MARK: - 3D Library
    private val _currentLibrary = MutableStateFlow<Library3D?>(null)
    val currentLibrary: StateFlow<Library3D?> = _currentLibrary.asStateFlow()

    // MARK: - Generated Code
    private val _lastGeneratedCode = MutableStateFlow("")
    val lastGeneratedCode: StateFlow<String> = _lastGeneratedCode.asStateFlow()

    // MARK: - Callbacks (equivalent to iOS closures)
    var onInsertCode: ((String) -> Unit)? = null
    var onRunScene: (() -> Unit)? = null
    var onDescribeScene: ((String) -> Unit)? = null
    var onInsertCodeWithBuild: ((String, Library3D) -> Unit)? = null

    init {
        loadSettings()
        loadDefaultLibrary()
    }

    // MARK: - Core Chat Functions

    /**
     * Send message to AI and handle response
     * Equivalent to sendMessage in iOS
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

                // Call AI service
                val response = aiProviderRepository.generateResponse(
                    prompt = enhancedPrompt,
                    model = _selectedModel.value,
                    temperature = _temperature.value,
                    topP = _topP.value,
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
                _errorMessage.value = e.message ?: "Unknown error occurred"
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
        // Look for code blocks in response
        val codePattern = "\\[INSERT_CODE\\]```(?:javascript|typescript|html)?\\n([\\s\\S]*?)\\n```\\[/INSERT_CODE\\]".toRegex()
        val codeMatch = codePattern.find(response)

        if (codeMatch != null) {
            val extractedCode = codeMatch.groupValues[1].trim()
            _lastGeneratedCode.value = extractedCode

            // Trigger code insertion callback
            if (library?.requiresBuild == true) {
                onInsertCodeWithBuild?.invoke(extractedCode, library)
            } else {
                onInsertCode?.invoke(extractedCode)
            }
        }

        // Check for run scene command
        if (response.contains("[RUN_SCENE]")) {
            onRunScene?.invoke()
        }

        // Check for scene description
        if (response.contains("[DESCRIBE_SCENE]")) {
            onDescribeScene?.invoke(response)
        }
    }

    // MARK: - AI Parameter Management

    /**
     * Get parameter description based on current settings
     * Equivalent to iOS getParameterDescription()
     */
    fun getParameterDescription(): String {
        val temp = _temperature.value
        val topP = _topP.value

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
        _temperature.value = value.coerceIn(0.0, 2.0)
    }

    fun updateTopP(value: Double) {
        _topP.value = value.coerceIn(0.1, 1.0)
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
     */
    fun selectLibrary(libraryId: String) {
        viewModelScope.launch {
            val library = library3DRepository.getLibraryById(libraryId)
            _currentLibrary.value = library
            library?.let {
                _systemPrompt.value = it.systemPrompt
            }
        }
    }

    fun getCurrentLibrary(): Library3D? = _currentLibrary.value

    fun getAvailableLibraries(): List<Library3D> = library3DRepository.getAllLibraries()

    // MARK: - Settings Management

    /**
     * Save all settings to persistent storage
     * Equivalent to iOS saveSettings()
     */
    fun saveSettings() {
        viewModelScope.launch {
            settingsRepository.saveSettings(
                selectedModel = _selectedModel.value,
                temperature = _temperature.value,
                topP = _topP.value,
                systemPrompt = _systemPrompt.value,
                selectedLibraryId = _currentLibrary.value?.id
            )
        }
    }

    /**
     * Load settings from persistent storage
     */
    private fun loadSettings() {
        viewModelScope.launch {
            val settings = settingsRepository.getSettings()
            _selectedModel.value = settings.selectedModel
            _temperature.value = settings.temperature
            _topP.value = settings.topP
            _systemPrompt.value = settings.systemPrompt
            
            settings.selectedLibraryId?.let { libraryId ->
                selectLibrary(libraryId)
            }
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
    fun getModelsByProvider(): Map<String, List<AIModel>> {
        return AIModels.MODELS_BY_PROVIDER
    }

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

/**
 * UI State data class
 */
data class ChatUiState(
    val showSettings: Boolean = false,
    val settingsSaved: Boolean = false,
    val currentView: AppView = AppView.CHAT,
    val isInjectingCode: Boolean = false,
    val webViewReady: Boolean = false
)

enum class AppView {
    CHAT,
    SCENE
}