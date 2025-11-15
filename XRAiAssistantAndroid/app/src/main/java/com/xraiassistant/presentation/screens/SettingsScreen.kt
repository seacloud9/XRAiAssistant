package com.xraiassistant.presentation.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalSoftwareKeyboardController
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.xraiassistant.R
import com.xraiassistant.data.models.AIModel
import com.xraiassistant.domain.models.Library3D
import com.xraiassistant.ui.viewmodels.ChatViewModel
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

/**
 * Settings Screen - Exact recreation of iOS ContentView settings implementation
 * 
 * Features identical to iOS:
 * - API Configuration Section (Together.ai, OpenAI, Anthropic, CodeSandbox)
 * - Model & Library Settings Section with provider grouping
 * - Temperature and Top-P sliders with intelligent descriptions
 * - Parameter summary view with current mode display
 * - Sandbox & Deployment settings
 * - System Prompt customization
 * - Save/Cancel with visual feedback
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen(
    onNavigateBack: () -> Unit,
    viewModel: ChatViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    var settingsSaved by remember { mutableStateOf(false) }
    
    // Local state for editing before save
    var togetherApiKey by remember { mutableStateOf("") }
    var openaiApiKey by remember { mutableStateOf("") }
    var anthropicApiKey by remember { mutableStateOf("") }
    var codesandboxApiKey by remember { mutableStateOf("") }
    var selectedModel by remember { mutableStateOf("") }
    var selectedLibrary by remember { mutableStateOf("") }
    var temperature by remember { mutableFloatStateOf(0.7f) }
    var topP by remember { mutableFloatStateOf(0.9f) }
    var systemPrompt by remember { mutableStateOf("") }
    var useSandpackForR3F by remember { mutableStateOf(true) }
    var showClearAllDialog by remember { mutableStateOf(false) }
    var historyCleared by remember { mutableStateOf(false) }
    val coroutineScope = rememberCoroutineScope()
    
    // Initialize local state with current values
    LaunchedEffect(Unit) {
        println("🔧 SettingsScreen: Loading current settings from ViewModel...")

        // Load current settings into local state
        // CRITICAL FIX: Use getRawAPIKey() for editing, not getAPIKey() which returns masked version
        togetherApiKey = viewModel.getRawAPIKey("Together.ai")
        openaiApiKey = viewModel.getRawAPIKey("OpenAI")
        anthropicApiKey = viewModel.getRawAPIKey("Anthropic")
        codesandboxApiKey = viewModel.getRawAPIKey("CodeSandbox")
        selectedModel = viewModel.selectedModel
        selectedLibrary = viewModel.currentLibraryId
        temperature = viewModel.temperature
        topP = viewModel.topP
        systemPrompt = viewModel.systemPrompt
        useSandpackForR3F = true // Default value

        println("✅ SettingsScreen: Settings loaded")
        println("   Selected Model: $selectedModel")
        println("   Selected Library: $selectedLibrary")
        println("   Temperature: $temperature")
        println("   Top-P: $topP")
        println("   System Prompt Length: ${systemPrompt.length} characters")
        if (systemPrompt.isNotEmpty()) {
            println("   System Prompt Preview: ${systemPrompt.take(100)}...")
        } else {
            println("   ⚠️ System Prompt is EMPTY!")
        }
    }
    
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Settings") },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Icon(Icons.Default.Close, contentDescription = "Cancel")
                    }
                },
                actions = {
                    TextButton(
                        onClick = {
                            // Save all settings in a coroutine to ensure proper sequencing
                            coroutineScope.launch {
                                // Save API keys first (await completion)
                                viewModel.setAPIKey("Together.ai", togetherApiKey)
                                viewModel.setAPIKey("OpenAI", openaiApiKey)
                                viewModel.setAPIKey("Anthropic", anthropicApiKey)
                                viewModel.setAPIKey("CodeSandbox", codesandboxApiKey)

                                // Update model settings
                                viewModel.selectedModel = selectedModel
                                viewModel.selectLibrary(selectedLibrary)
                                viewModel.temperature = temperature
                                viewModel.topP = topP
                                viewModel.systemPrompt = systemPrompt

                                // Save remaining settings
                                viewModel.saveSettings()

                                // Show success message
                                settingsSaved = true

                                // Auto-dismiss after showing confirmation
                                delay(1500L)
                                onNavigateBack()
                            }
                        }
                    ) {
                        Text(
                            "Save",
                            fontSize = 16.sp,
                            fontWeight = FontWeight.SemiBold,
                            color = MaterialTheme.colorScheme.primary
                        )
                    }
                }
            )
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(24.dp)
        ) {
            // API Configuration Section
            ApiConfigurationSection(
                togetherApiKey = togetherApiKey,
                onTogetherApiKeyChange = { togetherApiKey = it },
                openaiApiKey = openaiApiKey,
                onOpenaiApiKeyChange = { openaiApiKey = it },
                anthropicApiKey = anthropicApiKey,
                onAnthropicApiKeyChange = { anthropicApiKey = it },
                codesandboxApiKey = codesandboxApiKey,
                onCodesandboxApiKeyChange = { codesandboxApiKey = it },
                viewModel = viewModel
            )
            
            // Model & Library Settings Section
            ModelSettingsSection(
                selectedModel = selectedModel,
                onModelChange = { selectedModel = it },
                selectedLibrary = selectedLibrary,
                onLibraryChange = { selectedLibrary = it },
                temperature = temperature,
                onTemperatureChange = { temperature = it },
                topP = topP,
                onTopPChange = { topP = it },
                viewModel = viewModel
            )
            
            // Sandbox & Deployment Section
            SandboxSettingsSection(
                useSandpackForR3F = useSandpackForR3F,
                onUseSandpackChange = { useSandpackForR3F = it }
            )
            
            // System Prompt Section
            SystemPromptSection(
                systemPrompt = systemPrompt,
                onSystemPromptChange = { systemPrompt = it }
            )

            // Data & Privacy Section
            DataPrivacySection(
                onClearHistoryClick = { showClearAllDialog = true },
                historyCleared = historyCleared
            )

            // Save Settings Section
            SaveSettingsSection(
                settingsSaved = settingsSaved
            )
        }
    }

    // Clear all history confirmation dialog
    if (showClearAllDialog) {
        ClearAllHistoryDialog(
            onConfirm = {
                coroutineScope.launch {
                    viewModel.clearAllConversations()
                    historyCleared = true
                    showClearAllDialog = false

                    // Reset the success message after 3 seconds
                    delay(3000L)
                    historyCleared = false
                }
            },
            onDismiss = { showClearAllDialog = false }
        )
    }
}

@Composable
private fun ApiConfigurationSection(
    togetherApiKey: String,
    onTogetherApiKeyChange: (String) -> Unit,
    openaiApiKey: String,
    onOpenaiApiKeyChange: (String) -> Unit,
    anthropicApiKey: String,
    onAnthropicApiKeyChange: (String) -> Unit,
    codesandboxApiKey: String,
    onCodesandboxApiKeyChange: (String) -> Unit,
    viewModel: ChatViewModel
) {
    SettingsSection(
        title = "AI Provider API Keys",
        icon = Icons.Default.Key
    ) {
        Column(verticalArrangement = Arrangement.spacedBy(16.dp)) {
            // Together.ai API Key
            ProviderAPIKeyView(
                provider = "Together.ai",
                description = "Get your API key from together.ai",
                color = Color(0xFF2196F3), // Blue
                apiKey = togetherApiKey,
                onApiKeyChange = onTogetherApiKeyChange,
                isConfigured = viewModel.isProviderConfigured("Together.ai")
            )
            
            // OpenAI API Key
            ProviderAPIKeyView(
                provider = "OpenAI",
                description = "Get your API key from platform.openai.com",
                color = Color(0xFF4CAF50), // Green
                apiKey = openaiApiKey,
                onApiKeyChange = onOpenaiApiKeyChange,
                isConfigured = viewModel.isProviderConfigured("OpenAI")
            )
            
            // Anthropic API Key
            ProviderAPIKeyView(
                provider = "Anthropic",
                description = "Get your API key from console.anthropic.com",
                color = Color(0xFF9C27B0), // Purple
                apiKey = anthropicApiKey,
                onApiKeyChange = onAnthropicApiKeyChange,
                isConfigured = viewModel.isProviderConfigured("Anthropic")
            )
            
            // CodeSandbox API Key (Optional)
            CodeSandboxAPIKeyView(
                apiKey = codesandboxApiKey,
                onApiKeyChange = onCodesandboxApiKeyChange
            )
        }
    }
}

@Composable
private fun ProviderAPIKeyView(
    provider: String,
    description: String,
    color: Color,
    apiKey: String,
    onApiKeyChange: (String) -> Unit,
    isConfigured: Boolean
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = color.copy(alpha = 0.05f)
        ),
        shape = RoundedCornerShape(8.dp)
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Text(
                text = "$provider API Key",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold
            )
            
            val keyboardController = LocalSoftwareKeyboardController.current

            OutlinedTextField(
                value = apiKey,
                onValueChange = onApiKeyChange,
                placeholder = { Text("Enter your $provider API key") },
                modifier = Modifier.fillMaxWidth(),
                visualTransformation = PasswordVisualTransformation(),
                keyboardOptions = KeyboardOptions(
                    keyboardType = KeyboardType.Password,
                    imeAction = ImeAction.Done
                ),
                keyboardActions = KeyboardActions(
                    onDone = { keyboardController?.hide() }
                ),
                singleLine = true
            )
            
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = description,
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    if (isConfigured) {
                        Icon(
                            Icons.Default.CheckCircle,
                            contentDescription = "Configured",
                            tint = color,
                            modifier = Modifier.size(16.dp)
                        )
                        Text(
                            "Configured",
                            style = MaterialTheme.typography.bodySmall,
                            color = color
                        )
                    } else {
                        Icon(
                            Icons.Default.Warning,
                            contentDescription = "API key required",
                            tint = Color(0xFFFF9800), // Orange
                            modifier = Modifier.size(16.dp)
                        )
                        Text(
                            "API key required",
                            style = MaterialTheme.typography.bodySmall,
                            color = Color(0xFFFF9800)
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun CodeSandboxAPIKeyView(
    apiKey: String,
    onApiKeyChange: (String) -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(
            containerColor = Color(0xFFFF9800).copy(alpha = 0.05f) // Orange
        ),
        shape = RoundedCornerShape(8.dp)
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            Text(
                text = "CodeSandbox API Key (Optional)",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold
            )

            val keyboardController = LocalSoftwareKeyboardController.current

            OutlinedTextField(
                value = apiKey,
                onValueChange = onApiKeyChange,
                placeholder = { Text("Enter your CodeSandbox API key") },
                modifier = Modifier.fillMaxWidth(),
                visualTransformation = PasswordVisualTransformation(),
                keyboardOptions = KeyboardOptions(
                    keyboardType = KeyboardType.Password,
                    imeAction = ImeAction.Done
                ),
                keyboardActions = KeyboardActions(
                    onDone = { keyboardController?.hide() }
                ),
                singleLine = true
            )
            
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "Enables advanced CodeSandbox features and deployment",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    if (apiKey.isNotEmpty()) {
                        Icon(
                            Icons.Default.CheckCircle,
                            contentDescription = "Configured",
                            tint = Color(0xFFFF9800),
                            modifier = Modifier.size(16.dp)
                        )
                        Text(
                            "Configured",
                            style = MaterialTheme.typography.bodySmall,
                            color = Color(0xFFFF9800)
                        )
                    } else {
                        Icon(
                            Icons.Default.Info,
                            contentDescription = "Optional",
                            tint = Color(0xFF2196F3),
                            modifier = Modifier.size(16.dp)
                        )
                        Text(
                            "Optional - basic features work without API key",
                            style = MaterialTheme.typography.bodySmall,
                            color = Color(0xFF2196F3)
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun ModelSettingsSection(
    selectedModel: String,
    onModelChange: (String) -> Unit,
    selectedLibrary: String,
    onLibraryChange: (String) -> Unit,
    temperature: Float,
    onTemperatureChange: (Float) -> Unit,
    topP: Float,
    onTopPChange: (Float) -> Unit,
    viewModel: ChatViewModel
) {
    SettingsSection(
        title = "Model & Library Settings",
        icon = Icons.Default.Tune
    ) {
        Column(verticalArrangement = Arrangement.spacedBy(16.dp)) {
            // Model Selection
            ModelSelectionView(
                selectedModel = selectedModel,
                onModelChange = onModelChange,
                viewModel = viewModel
            )
            
            // Library Selection
            LibrarySelectionView(
                selectedLibrary = selectedLibrary,
                onLibraryChange = onLibraryChange,
                viewModel = viewModel
            )
            
            // Temperature Slider
            TemperatureSliderView(
                temperature = temperature,
                onTemperatureChange = onTemperatureChange
            )
            
            // Top-P Slider
            TopPSliderView(
                topP = topP,
                onTopPChange = onTopPChange
            )
            
            // Parameter Summary
            ParameterSummaryView(
                temperature = temperature,
                topP = topP
            )
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun ModelSelectionView(
    selectedModel: String,
    onModelChange: (String) -> Unit,
    viewModel: ChatViewModel
) {
    var expanded by remember { mutableStateOf(false) }
    
    Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
        Text(
            text = "AI Model",
            style = MaterialTheme.typography.titleMedium,
            fontWeight = FontWeight.Bold
        )
        
        ExposedDropdownMenuBox(
            expanded = expanded,
            onExpandedChange = { expanded = !expanded },
            modifier = Modifier.fillMaxWidth()
        ) {
            OutlinedTextField(
                value = viewModel.getModelDisplayName(selectedModel),
                onValueChange = { },
                readOnly = true,
                trailingIcon = {
                    ExposedDropdownMenuDefaults.TrailingIcon(expanded = expanded)
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .menuAnchor()
            )
            
            ExposedDropdownMenu(
                expanded = expanded,
                onDismissRequest = { expanded = false }
            ) {
                // Group models by provider
                viewModel.modelsByProvider.forEach { (provider, models) ->
                    Text(
                        text = provider,
                        style = MaterialTheme.typography.labelMedium,
                        color = MaterialTheme.colorScheme.primary,
                        modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)
                    )
                    
                    models.forEach { model ->
                        DropdownMenuItem(
                            text = {
                                Column {
                                    Row(
                                        modifier = Modifier.fillMaxWidth(),
                                        horizontalArrangement = Arrangement.SpaceBetween
                                    ) {
                                        Text(
                                            text = model.displayName,
                                            style = MaterialTheme.typography.bodyMedium,
                                            fontWeight = FontWeight.Medium
                                        )
                                        if (model.pricing.isNotEmpty()) {
                                            Card(
                                                colors = CardDefaults.cardColors(
                                                    containerColor = MaterialTheme.colorScheme.surfaceVariant
                                                )
                                            ) {
                                                Text(
                                                    text = model.pricing,
                                                    style = MaterialTheme.typography.labelSmall,
                                                    modifier = Modifier.padding(horizontal = 4.dp, vertical = 1.dp)
                                                )
                                            }
                                        }
                                    }
                                    Text(
                                        text = model.description,
                                        style = MaterialTheme.typography.bodySmall,
                                        color = MaterialTheme.colorScheme.onSurfaceVariant
                                    )
                                }
                            },
                            onClick = {
                                onModelChange(model.id)
                                expanded = false
                            }
                        )
                    }
                }
            }
        }
        
        // Show current provider info
        val currentModel = viewModel.allAvailableModels.find { it.id == selectedModel }
        currentModel?.let { model ->
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    Icon(
                        Icons.Default.Business,
                        contentDescription = "Provider",
                        tint = Color(0xFF2196F3),
                        modifier = Modifier.size(16.dp)
                    )
                    Text(
                        "Provider: ${model.provider}",
                        style = MaterialTheme.typography.bodySmall,
                        color = Color(0xFF2196F3)
                    )
                }
                
                if (viewModel.isProviderConfigured(model.provider)) {
                    Icon(
                        Icons.Default.CheckCircle,
                        contentDescription = "Configured",
                        tint = Color(0xFF4CAF50),
                        modifier = Modifier.size(16.dp)
                    )
                } else {
                    Icon(
                        Icons.Default.Warning,
                        contentDescription = "Not configured",
                        tint = Color(0xFFFF9800),
                        modifier = Modifier.size(16.dp)
                    )
                }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun LibrarySelectionView(
    selectedLibrary: String,
    onLibraryChange: (String) -> Unit,
    viewModel: ChatViewModel
) {
    var expanded by remember { mutableStateOf(false) }
    val availableLibraries = viewModel.getAvailableLibraries()
    val currentLibrary = viewModel.getCurrentLibrary()
    
    Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
        Text(
            text = "3D Library",
            style = MaterialTheme.typography.titleMedium,
            fontWeight = FontWeight.Bold
        )
        
        ExposedDropdownMenuBox(
            expanded = expanded,
            onExpandedChange = { expanded = !expanded },
            modifier = Modifier.fillMaxWidth()
        ) {
            OutlinedTextField(
                value = currentLibrary.displayName,
                onValueChange = { },
                readOnly = true,
                trailingIcon = {
                    ExposedDropdownMenuDefaults.TrailingIcon(expanded = expanded)
                },
                modifier = Modifier
                    .fillMaxWidth()
                    .menuAnchor()
            )
            
            ExposedDropdownMenu(
                expanded = expanded,
                onDismissRequest = { expanded = false }
            ) {
                availableLibraries.forEach { library ->
                    DropdownMenuItem(
                        text = {
                            Column {
                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.SpaceBetween
                                ) {
                                    Text(
                                        text = library.displayName,
                                        style = MaterialTheme.typography.bodyMedium,
                                        fontWeight = FontWeight.Medium
                                    )
                                    Card(
                                        colors = CardDefaults.cardColors(
                                            containerColor = MaterialTheme.colorScheme.surfaceVariant
                                        )
                                    ) {
                                        Text(
                                            text = library.version,
                                            style = MaterialTheme.typography.labelSmall,
                                            modifier = Modifier.padding(horizontal = 4.dp, vertical = 1.dp)
                                        )
                                    }
                                }
                                Text(
                                    text = library.description,
                                    style = MaterialTheme.typography.bodySmall,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant
                                )
                            }
                        },
                        onClick = {
                            onLibraryChange(library.id)
                            expanded = false
                        }
                    )
                }
            }
        }
        
        // Show current library info
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                Icon(
                    Icons.Default.ViewInAr,
                    contentDescription = "Library",
                    tint = Color(0xFF4CAF50),
                    modifier = Modifier.size(16.dp)
                )
                Text(
                    "Library: ${currentLibrary.displayName}",
                    style = MaterialTheme.typography.bodySmall,
                    color = Color(0xFF4CAF50)
                )
            }
            
            Card(
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.surfaceVariant
                )
            ) {
                Text(
                    text = "Playground: ${currentLibrary.codeLanguage}",
                    style = MaterialTheme.typography.labelSmall,
                    modifier = Modifier.padding(horizontal = 4.dp, vertical = 1.dp)
                )
            }
        }
    }
}

@Composable
private fun TemperatureSliderView(
    temperature: Float,
    onTemperatureChange: (Float) -> Unit
) {
    Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "Temperature",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold
            )
            Card(
                colors = CardDefaults.cardColors(
                    containerColor = Color(0xFF2196F3).copy(alpha = 0.1f)
                )
            ) {
                Text(
                    text = String.format("%.1f", temperature),
                    style = MaterialTheme.typography.bodyMedium,
                    color = Color(0xFF2196F3),
                    modifier = Modifier.padding(horizontal = 8.dp, vertical = 2.dp)
                )
            }
        }
        
        Slider(
            value = temperature,
            onValueChange = onTemperatureChange,
            valueRange = 0.0f..2.0f,
            steps = 19, // 20 steps total (0.1 increments)
            colors = SliderDefaults.colors(
                thumbColor = Color(0xFF2196F3),
                activeTrackColor = Color(0xFF2196F3)
            )
        )
        
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text(
                "0.0 - Focused",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Text(
                "2.0 - Creative",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

@Composable
private fun TopPSliderView(
    topP: Float,
    onTopPChange: (Float) -> Unit
) {
    Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = "Top-p (Nucleus Sampling)",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold
            )
            Card(
                colors = CardDefaults.cardColors(
                    containerColor = Color(0xFF4CAF50).copy(alpha = 0.1f)
                )
            ) {
                Text(
                    text = String.format("%.1f", topP),
                    style = MaterialTheme.typography.bodyMedium,
                    color = Color(0xFF4CAF50),
                    modifier = Modifier.padding(horizontal = 8.dp, vertical = 2.dp)
                )
            }
        }
        
        Slider(
            value = topP,
            onValueChange = onTopPChange,
            valueRange = 0.1f..1.0f,
            steps = 8, // 9 steps total (0.1 increments)
            colors = SliderDefaults.colors(
                thumbColor = Color(0xFF4CAF50),
                activeTrackColor = Color(0xFF4CAF50)
            )
        )
        
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text(
                "0.1 - Precise",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Text(
                "1.0 - Diverse",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
        
        Text(
            "Controls vocabulary diversity. Lower values focus on most likely words.",
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

@Composable
private fun ParameterSummaryView(
    temperature: Float,
    topP: Float
) {
    val parameterDescription = getParameterDescription(temperature, topP)
    
    Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
        Row(
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            Icon(
                Icons.Default.Speed,
                contentDescription = "Current Mode",
                tint = Color(0xFF9C27B0),
                modifier = Modifier.size(16.dp)
            )
            Text(
                text = "Current Mode",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold
            )
        }
        
        Card(
            colors = CardDefaults.cardColors(
                containerColor = Color(0xFF9C27B0).copy(alpha = 0.1f)
            ),
            shape = RoundedCornerShape(8.dp)
        ) {
            Text(
                text = parameterDescription,
                style = MaterialTheme.typography.bodyMedium,
                color = Color(0xFF9C27B0),
                modifier = Modifier.padding(12.dp)
            )
        }
    }
}

@Composable
private fun SandboxSettingsSection(
    useSandpackForR3F: Boolean,
    onUseSandpackChange: (Boolean) -> Unit
) {
    SettingsSection(
        title = "Sandbox & Deployment",
        icon = Icons.Default.Cloud
    ) {
        Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Icon(
                    Icons.Default.Language,
                    contentDescription = "React Three Fiber Rendering",
                    tint = Color(0xFFFF9800),
                    modifier = Modifier.size(16.dp)
                )
                Text(
                    text = "React Three Fiber Rendering",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold
                )
            }
            
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        "Use CodeSandbox Live",
                        style = MaterialTheme.typography.bodyMedium
                    )
                    Text(
                        if (useSandpackForR3F) {
                            "Real CodeSandbox projects with sharing & npm packages"
                        } else {
                            "Local playground with offline support"
                        },
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
                Switch(
                    checked = useSandpackForR3F,
                    onCheckedChange = onUseSandpackChange,
                    colors = SwitchDefaults.colors(
                        checkedThumbColor = Color(0xFFFF9800),
                        checkedTrackColor = Color(0xFFFF9800).copy(alpha = 0.5f)
                    )
                )
            }
            
            // Description based on current setting
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                Icon(
                    if (useSandpackForR3F) Icons.Default.CloudCircle else Icons.Default.Computer,
                    contentDescription = if (useSandpackForR3F) "Online" else "Offline",
                    tint = if (useSandpackForR3F) Color(0xFF2196F3) else Color(0xFF4CAF50),
                    modifier = Modifier.size(16.dp)
                )
                Text(
                    if (useSandpackForR3F) {
                        "Online: Real CodeSandbox environment with full npm ecosystem"
                    } else {
                        "Offline: Fast local rendering, no network required"
                    },
                    style = MaterialTheme.typography.bodySmall,
                    color = if (useSandpackForR3F) Color(0xFF2196F3) else Color(0xFF4CAF50)
                )
            }
            
            // Benefits info
            Card(
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f)
                ),
                shape = RoundedCornerShape(6.dp)
            ) {
                Column(
                    modifier = Modifier.padding(8.dp),
                    verticalArrangement = Arrangement.spacedBy(4.dp)
                ) {
                    Text(
                        "Benefits:",
                        style = MaterialTheme.typography.bodySmall,
                        fontWeight = FontWeight.SemiBold,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    
                    if (useSandpackForR3F) {
                        Text("• Instant deployment to CodeSandbox", style = MaterialTheme.typography.bodySmall)
                        Text("• Social sharing with direct links", style = MaterialTheme.typography.bodySmall)
                        Text("• Live collaboration and embedding", style = MaterialTheme.typography.bodySmall)
                    } else {
                        Text("• Works completely offline", style = MaterialTheme.typography.bodySmall)
                        Text("• Faster local rendering", style = MaterialTheme.typography.bodySmall)
                        Text("• No external dependencies", style = MaterialTheme.typography.bodySmall)
                    }
                }
            }
        }
    }
}

@Composable
private fun SystemPromptSection(
    systemPrompt: String,
    onSystemPromptChange: (String) -> Unit
) {
    SettingsSection(
        title = "System Prompt",
        icon = Icons.Default.Code
    ) {
        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
            Text(
                text = "Custom Instructions",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold
            )
            
            OutlinedTextField(
                value = systemPrompt,
                onValueChange = onSystemPromptChange,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(200.dp),
                placeholder = { Text("Enter custom instructions for the AI assistant...") },
                textStyle = MaterialTheme.typography.bodySmall.copy(
                    fontFamily = androidx.compose.ui.text.font.FontFamily.Monospace
                )
            )
            
            Text(
                "Customize how the AI assistant behaves and responds to your requests",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

@Composable
private fun SaveSettingsSection(
    settingsSaved: Boolean
) {
    SettingsSection(
        title = "",
        icon = null
    ) {
        if (settingsSaved) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Icon(
                    Icons.Default.CheckCircle,
                    contentDescription = "Settings saved",
                    tint = Color(0xFF4CAF50)
                )
                Text(
                    "Settings saved successfully!",
                    style = MaterialTheme.typography.bodyMedium,
                    color = Color(0xFF4CAF50)
                )
            }
        } else {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Icon(
                        Icons.Default.Info,
                        contentDescription = "Save Your Settings",
                        tint = Color(0xFF2196F3)
                    )
                    Text(
                        text = "Save Your Settings",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Bold
                    )
                }
                
                Text(
                    "Tap 'Save' to persist your API key, system prompt, model selection, and AI parameters. Your settings will be remembered when you return to the app.",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}

@Composable
private fun DataPrivacySection(
    onClearHistoryClick: () -> Unit,
    historyCleared: Boolean
) {
    SettingsSection(
        title = "Data & Privacy",
        icon = Icons.Default.Security
    ) {
        Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
            // Clear Chat History Card
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(
                    containerColor = Color(0xFFF44336).copy(alpha = 0.05f) // Red
                ),
                shape = RoundedCornerShape(8.dp)
            ) {
                Column(
                    modifier = Modifier.padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Icon(
                            Icons.Default.History,
                            contentDescription = "Chat History",
                            tint = Color(0xFFF44336),
                            modifier = Modifier.size(20.dp)
                        )
                        Text(
                            text = "Chat History",
                            style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.Bold
                        )
                    }

                    Text(
                        "Clear all saved conversations and messages. This action cannot be undone.",
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )

                    Button(
                        onClick = onClearHistoryClick,
                        modifier = Modifier.fillMaxWidth(),
                        colors = ButtonDefaults.buttonColors(
                            containerColor = Color(0xFFF44336)
                        )
                    ) {
                        Icon(
                            Icons.Default.DeleteForever,
                            contentDescription = "Clear All",
                            modifier = Modifier.size(20.dp)
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text("Clear All Chat History")
                    }

                    // Success message
                    if (historyCleared) {
                        Row(
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(8.dp),
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Icon(
                                Icons.Default.CheckCircle,
                                contentDescription = "Cleared",
                                tint = Color(0xFF4CAF50),
                                modifier = Modifier.size(16.dp)
                            )
                            Text(
                                "All chat history cleared successfully",
                                style = MaterialTheme.typography.bodySmall,
                                color = Color(0xFF4CAF50)
                            )
                        }
                    }
                }
            }
        }
    }
}

/**
 * Clear All History Confirmation Dialog
 */
@Composable
private fun ClearAllHistoryDialog(
    onConfirm: () -> Unit,
    onDismiss: () -> Unit
) {
    AlertDialog(
        onDismissRequest = onDismiss,
        icon = {
            Icon(
                Icons.Default.Warning,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.error,
                modifier = Modifier.size(48.dp)
            )
        },
        title = {
            Text(
                "Clear All Chat History?",
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.Bold
            )
        },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text(
                    "This will permanently delete all saved conversations and messages.",
                    style = MaterialTheme.typography.bodyMedium
                )
                Text(
                    "This action cannot be undone.",
                    style = MaterialTheme.typography.bodyMedium,
                    fontWeight = FontWeight.SemiBold,
                    color = MaterialTheme.colorScheme.error
                )
            }
        },
        confirmButton = {
            Button(
                onClick = onConfirm,
                colors = ButtonDefaults.buttonColors(
                    containerColor = MaterialTheme.colorScheme.error
                )
            ) {
                Text("Clear All")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancel")
            }
        }
    )
}

@Composable
private fun SettingsSection(
    title: String,
    icon: ImageVector?,
    content: @Composable () -> Unit
) {
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        if (title.isNotEmpty()) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                icon?.let {
                    Icon(
                        it,
                        contentDescription = title,
                        tint = MaterialTheme.colorScheme.primary,
                        modifier = Modifier.size(20.dp)
                    )
                }
                Text(
                    text = title,
                    style = MaterialTheme.typography.titleLarge,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.primary
                )
            }
        }
        content()
    }
}

private fun getParameterDescription(temperature: Float, topP: Float): String {
    return when {
        temperature in 0.0f..0.3f && topP in 0.1f..0.5f -> "Precise & Focused - Perfect for debugging"
        temperature in 0.4f..0.8f && topP in 0.6f..0.9f -> "Balanced Creativity - Ideal for most scenes"
        temperature in 0.9f..2.0f && topP in 0.9f..1.0f -> "Experimental Mode - Maximum innovation"
        else -> "Custom Configuration"
    }
}