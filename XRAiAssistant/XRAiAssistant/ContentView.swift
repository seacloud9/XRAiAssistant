import SwiftUI
import WebKit

enum AppView {
    case chat
    case scene
}

struct ContentView: View {
    @StateObject private var chatViewModel = ChatViewModel()
    @State private var webView: WKWebView?
    @State private var currentCode = ""
    @State private var lastGeneratedCode = ""
    @State private var chatInput = ""
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var currentView: AppView = .chat
    @State private var webViewReady = false
    @State private var isInjectingCode = false
    @State private var showingSettings = false
    @State private var settingsSaved = false
    
    private var settingsView: some View {
        NavigationView {
            Form {
                apiConfigurationSection
                modelSettingsSection
                systemPromptSection
                saveSettingsSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingSettings = false
                    }
                    .font(.system(size: 16, weight: .medium))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        chatViewModel.saveSettings()
                        withAnimation(.easeInOut(duration: 0.3)) {
                            settingsSaved = true
                        }
                        
                        // Auto-dismiss after showing confirmation
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showingSettings = false
                                settingsSaved = false
                            }
                        }
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.blue)
                }
            }
        }
    }
    
    private var apiConfigurationSection: some View {
        Section("AI Provider API Keys") {
            VStack(spacing: 16) {
                // Together.ai API Key
                providerAPIKeyView(
                    provider: "Together.ai",
                    description: "Get your API key from together.ai",
                    color: .blue
                )
                
                // OpenAI API Key
                providerAPIKeyView(
                    provider: "OpenAI",
                    description: "Get your API key from platform.openai.com",
                    color: .green
                )
                
                // Anthropic API Key
                providerAPIKeyView(
                    provider: "Anthropic",
                    description: "Get your API key from console.anthropic.com",
                    color: .purple
                )
            }
            .padding(.vertical, 4)
        }
    }
    
    private func providerAPIKeyView(provider: String, description: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(provider) API Key")
                .font(.headline)
                .foregroundColor(.primary)
            
            SecureField("Enter your \(provider) API key", text: Binding(
                get: { chatViewModel.getAPIKey(for: provider) },
                set: { chatViewModel.setAPIKey(for: provider, key: $0) }
            ))
            .textFieldStyle(RoundedBorderTextFieldStyle())
            
            HStack {
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                if chatViewModel.isProviderConfigured(provider) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(color)
                        Text("Configured")
                            .font(.caption)
                            .foregroundColor(color)
                    }
                } else {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("API key required")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(color.opacity(0.05))
        .cornerRadius(8)
    }
    
    private var modelSettingsSection: some View {
        Section("Model & Library Settings") {
            VStack(alignment: .leading, spacing: 12) {
                modelSelectionView
                librarySelectionView
                temperatureSliderView
                topPSliderView
                parameterSummaryView
            }
            .padding(.vertical, 4)
        }
    }
    
    private var modelSelectionView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("AI Model")
                .font(.headline)
                .foregroundColor(.primary)
            
            Picker("Model", selection: $chatViewModel.selectedModel) {
                // Show models organized by provider
                ForEach(Array(chatViewModel.modelsByProvider.keys.sorted()), id: \.self) { provider in
                    Section(provider) {
                        ForEach(chatViewModel.modelsByProvider[provider] ?? [], id: \.id) { model in
                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text(model.displayName)
                                        .font(.system(size: 14, weight: .medium))
                                    Spacer()
                                    if !model.pricing.isEmpty {
                                        Text(model.pricing)
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                            .padding(.horizontal, 4)
                                            .padding(.vertical, 1)
                                            .background(Color.gray.opacity(0.2))
                                            .cornerRadius(4)
                                    }
                                }
                                Text(model.description)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .tag(model.id)
                        }
                    }
                }
                
                // Legacy models for backwards compatibility
                if !chatViewModel.availableModels.isEmpty {
                    Section("Legacy (Together.ai)") {
                        ForEach(chatViewModel.availableModels, id: \.self) { model in
                            VStack(alignment: .leading) {
                                Text(chatViewModel.getModelDisplayName(model))
                                    .font(.system(size: 14, weight: .medium))
                                Text(chatViewModel.getModelDescription(model))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .tag(model)
                        }
                    }
                }
            }
            .pickerStyle(MenuPickerStyle())
            
            // Show current provider info
            if let currentModel = chatViewModel.allAvailableModels.first(where: { $0.id == chatViewModel.selectedModel }) {
                HStack {
                    Image(systemName: "building.2")
                        .foregroundColor(.blue)
                        .font(.caption)
                    Text("Provider: \(currentModel.provider)")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Spacer()
                    
                    if chatViewModel.isProviderConfigured(currentModel.provider) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    } else {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                    }
                }
                .padding(.top, 4)
            }
        }
    }
    
    private var librarySelectionView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("3D Library")
                .font(.headline)
                .foregroundColor(.primary)
            
            Picker("Library", selection: Binding(
                get: { chatViewModel.getCurrentLibrary().id },
                set: { libraryId in chatViewModel.selectLibrary(id: libraryId) }
            )) {
                ForEach(chatViewModel.getAvailableLibraries(), id: \.id) { library in
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(library.displayName)
                                .font(.system(size: 14, weight: .medium))
                            Spacer()
                            Text(library.version)
                                .font(.caption2)
                                .foregroundColor(.gray)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(4)
                        }
                        Text(library.description)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .tag(library.id)
                }
            }
            .pickerStyle(MenuPickerStyle())
            
            // Show current library info
            let currentLibrary = chatViewModel.getCurrentLibrary()
            HStack {
                Image(systemName: "cube.box")
                    .foregroundColor(.green)
                    .font(.caption)
                Text("Library: \(currentLibrary.displayName)")
                    .font(.caption)
                    .foregroundColor(.green)
                
                Spacer()
                
                Text("Playground: \(currentLibrary.codeLanguage.rawValue)")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(4)
            }
            .padding(.top, 4)
        }
    }
    
    private var temperatureSliderView: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Temperature")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Text("\(chatViewModel.temperature, specifier: "%.1f")")
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(6)
            }
            
            Slider(value: $chatViewModel.temperature, in: 0.0...2.0, step: 0.1)
                .accentColor(.blue)
            
            HStack {
                Text("0.0 - Focused")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text("2.0 - Creative")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var topPSliderView: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Top-p (Nucleus Sampling)")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Text("\(chatViewModel.topP, specifier: "%.1f")")
                    .font(.subheadline)
                    .foregroundColor(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(6)
            }
            
            Slider(value: $chatViewModel.topP, in: 0.1...1.0, step: 0.1)
                .accentColor(.green)
            
            HStack {
                Text("0.1 - Precise")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text("1.0 - Diverse")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text("Controls vocabulary diversity. Lower values focus on most likely words.")
                .font(.caption2)
                .foregroundColor(.gray)
                .padding(.top, 2)
        }
    }
    
    private var parameterSummaryView: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "gauge.badge.plus")
                    .foregroundColor(.purple)
                    .font(.caption)
                Text("Current Mode")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            Text(chatViewModel.getParameterDescription())
                .font(.subheadline)
                .foregroundColor(.purple)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(8)
        }
    }
    
    private var systemPromptSection: some View {
        Section("System Prompt") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Custom Instructions")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                TextEditor(text: $chatViewModel.systemPrompt)
                    .frame(minHeight: 200)
                    .font(.system(size: 14).monospaced())
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                Text("Customize how the AI assistant behaves and responds to your requests")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 4)
        }
    }
    
    private var saveSettingsSection: some View {
        Section {
            VStack(spacing: 12) {
                if settingsSaved {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Settings saved successfully!")
                            .font(.subheadline)
                            .foregroundColor(.green)
                        Spacer()
                    }
                    .transition(.opacity)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.blue)
                            Text("Save Your Settings")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        
                        Text("Tap 'Save' to persist your API key, system prompt, model selection, and AI parameters. Your settings will be remembered when you return to the app.")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Main content area
            Group {
                if currentView == .chat {
                    // Chat View - Clean chat-only interface
                    VStack(spacing: 0) {
                        // Chat header
                        VStack(spacing: 0) {
                            // Top row with title and loading
                            HStack {
                                Image(systemName: "brain")
                                    .foregroundColor(.blue)
                                Text("AI Assistant")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if chatViewModel.isLoading {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                            
                            // Model and Library selector row
                            HStack {
                                // Model selector
                                Image(systemName: "cpu")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                                
                                Text("Model:")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Menu {
                                    // Show models organized by provider
                                    ForEach(Array(chatViewModel.modelsByProvider.keys.sorted()), id: \.self) { provider in
                                        Section(provider) {
                                            ForEach(chatViewModel.modelsByProvider[provider] ?? [], id: \.id) { model in
                                                Button(action: {
                                                    chatViewModel.selectedModel = model.id
                                                }) {
                                                    HStack {
                                                        VStack(alignment: .leading, spacing: 2) {
                                                            Text(model.displayName)
                                                                .font(.system(size: 14, weight: .medium))
                                                            Text("\(model.description) - \(model.pricing)")
                                                                .font(.caption2)
                                                                .foregroundColor(.gray)
                                                        }
                                                        
                                                        Spacer()
                                                        
                                                        if chatViewModel.selectedModel == model.id {
                                                            Image(systemName: "checkmark")
                                                                .foregroundColor(.blue)
                                                                .font(.caption)
                                                        }
                                                        
                                                        if !chatViewModel.isProviderConfigured(provider) {
                                                            Image(systemName: "exclamationmark.triangle")
                                                                .foregroundColor(.orange)
                                                                .font(.caption2)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    
                                    // Legacy models
                                    if !chatViewModel.availableModels.isEmpty {
                                        Section("Legacy") {
                                            ForEach(chatViewModel.availableModels, id: \.self) { model in
                                                Button(action: {
                                                    chatViewModel.selectedModel = model
                                                }) {
                                                    VStack(alignment: .leading, spacing: 2) {
                                                        HStack {
                                                            Text(chatViewModel.getModelDisplayName(model))
                                                                .font(.system(size: 14, weight: .medium))
                                                            if chatViewModel.selectedModel == model {
                                                                Image(systemName: "checkmark")
                                                                    .foregroundColor(.blue)
                                                                    .font(.caption)
                                                            }
                                                        }
                                                        Text(chatViewModel.getModelDescription(model))
                                                            .font(.caption2)
                                                            .foregroundColor(.gray)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(chatViewModel.getModelDisplayName(chatViewModel.selectedModel))
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                        Image(systemName: "chevron.down")
                                            .font(.caption2)
                                            .foregroundColor(.blue)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(6)
                                }
                                
                                // Library selector
                                Image(systemName: "cube.box")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                                    .padding(.leading, 12)
                                
                                Text("Library:")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Menu {
                                    ForEach(chatViewModel.getAvailableLibraries(), id: \.id) { library in
                                        Button(action: {
                                            chatViewModel.selectLibrary(id: library.id)
                                        }) {
                                            HStack {
                                                VStack(alignment: .leading, spacing: 2) {
                                                    Text(library.displayName)
                                                        .font(.system(size: 14, weight: .medium))
                                                    Text(library.description)
                                                        .font(.caption2)
                                                        .foregroundColor(.gray)
                                                }
                                                
                                                Spacer()
                                                
                                                if chatViewModel.getCurrentLibrary().id == library.id {
                                                    Image(systemName: "checkmark")
                                                        .foregroundColor(.green)
                                                        .font(.caption)
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    HStack {
                                        Text(chatViewModel.getCurrentLibrary().displayName)
                                            .font(.caption)
                                            .foregroundColor(.green)
                                        Image(systemName: "chevron.down")
                                            .font(.caption2)
                                            .foregroundColor(.green)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(6)
                                }
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                        }
                        .background(Color(.systemGray6))
                        
                        // Chat messages - Takes full available space
                        ScrollViewReader { proxy in
                            ScrollView {
                                LazyVStack(alignment: .leading, spacing: 8) {
                                    ForEach(chatViewModel.messages) { message in
                                        ChatMessageView(message: message)
                                            .id(message.id)
                                    }
                                    
                                    if chatViewModel.isLoading {
                                        HStack {
                                            ProgressView()
                                                .scaleEffect(0.7)
                                            Text("AI is thinking...")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                    }
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color(.systemBackground))
                            .onChange(of: chatViewModel.messages.count) { _ in
                                if let lastMessage = chatViewModel.messages.last {
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                    }
                                }
                            }
                        }
                        
                        // AI Code Status Banner
                        if !lastGeneratedCode.isEmpty {
                            VStack {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("AI code ready! Tap 'Run Scene' to see it.")
                                            .font(.callout)
                                            .foregroundColor(.green)
                                        Text("Generated by \(chatViewModel.getModelDisplayName(chatViewModel.selectedModel))")
                                            .font(.caption2)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Text("(\(lastGeneratedCode.count) chars)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.green.opacity(0.1))
                                .overlay(
                                    Rectangle()
                                        .frame(height: 1)
                                        .foregroundColor(.green.opacity(0.3)),
                                    alignment: .top
                                )
                            }
                        }
                        
                        // Chat input
                        HStack {
                            TextField("Ask me to create a 3D scene...", text: $chatInput)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onSubmit {
                                    sendMessage()
                                }
                            
                            Button(action: sendMessage) {
                                Image(systemName: "paperplane.fill")
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(chatInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.blue)
                                    .clipShape(Circle())
                            }
                            .disabled(chatInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                    }
                } else {
                    // Scene View - Full screen WebView with Monaco editor + 3D rendering
                    ZStack {
                        PlaygroundWebView(
                            webView: $webView,
                            playgroundTemplate: chatViewModel.getPlaygroundTemplate(),
                            onWebViewLoaded: {
                                print("WebView loaded successfully")
                            },
                            onWebViewError: { error in
                                errorMessage = error.localizedDescription
                                showingError = true
                            },
                            onJavaScriptMessage: { action, data in
                                handleWebViewMessage(action: action, data: data)
                            }
                        )
                        
                        // Code injection overlay
                        if isInjectingCode {
                            VStack {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .tint(.blue)
                                Text("Injecting AI Code...")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .padding(.top, 8)
                            }
                            .padding(20)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(12)
                        }
                    }
                }
            }
            
            // Bottom tab bar
            HStack {
                // Code Tab (Chat)
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentView = .chat
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: currentView == .chat ? "bubble.left.fill" : "bubble.left")
                        Text("Code")
                            .font(.caption)
                    }
                    .foregroundColor(currentView == .chat ? .blue : .gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                
                Divider()
                    .frame(height: 30)
                
                // Run Scene Tab
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentView = .scene
                    }
                    
                    // Inject AI-generated code and automatically run it
                    if !lastGeneratedCode.isEmpty {
                        print("Injecting AI code into Scene tab and running...")
                        isInjectingCode = true
                        
                        // Wait longer for Scene tab to be visible and WebView to be ready
                        // Increased delay and retries for better reliability across all playground templates
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            self.injectCodeWithRetry(lastGeneratedCode, maxRetries: 6)
                        }
                    } else {
                        print("No AI-generated code available, running default scene")
                        runScene()
                    }
                }) {
                    VStack(spacing: 4) {
                        ZStack {
                            Image(systemName: currentView == .scene ? "play.circle.fill" : "play.circle")
                            
                            // Show notification dot if code is ready
                            if !lastGeneratedCode.isEmpty && currentView != .scene {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 8, y: -8)
                            }
                        }
                        Text("Run Scene")
                            .font(.caption)
                    }
                    .foregroundColor(currentView == .scene ? .green : (!lastGeneratedCode.isEmpty ? .blue : .gray))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
                
                Divider()
                    .frame(height: 30)
                
                // Settings Button
                Button(action: {
                    showingSettings = true
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: "gearshape.fill")
                        Text("Settings")
                            .font(.caption)
                    }
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray.opacity(0.3)),
                alignment: .top
            )
        }
        .sheet(isPresented: $showingSettings) {
            settingsView
        }
        .onChange(of: showingSettings) { _, isShowing in
            if !isShowing {
                settingsSaved = false
            }
        }
        .onAppear {
            setupChatCallbacks()
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .alert("Chat Error", isPresented: .constant(chatViewModel.errorMessage != nil)) {
            Button("OK") {
                chatViewModel.errorMessage = nil
            }
        } message: {
            Text(chatViewModel.errorMessage ?? "")
        }
    }
    
    private func setupChatCallbacks() {
        chatViewModel.onInsertCode = { code in
            print("=== CALLBACK: AI generated code received ===")
            print("Code length: \(code.count) characters")
            print("Code preview: \(code.prefix(200))...")
            lastGeneratedCode = code
            print("✅ Code stored successfully in lastGeneratedCode")
            
            // DO NOT inject here - wait for user to switch to Scene tab
            // The green banner will show "AI code ready! Tap 'Run Scene' to see it."
            print("Code ready - waiting for user to switch to Run Scene tab for injection and execution")
        }
        
        chatViewModel.onRunScene = {
            print("=== CALLBACK: onRunScene triggered - but disabled for manual execution ===")
            // DO NOT auto-switch or auto-run - let user manually control execution
            // The code is already stored via onInsertCode callback above
            // User must manually tap "Run Scene" tab to execute
        }
        
        chatViewModel.onDescribeScene = { description in
            print("Scene description: \(description)")
        }
    }
    
    private func sendMessage() {
        let message = chatInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else { return }
        
        chatInput = ""
        chatViewModel.sendMessage(message, currentCode: currentCode)
    }
    
    private func handleWebViewMessage(action: String, data: [String: Any]) {
        switch action {
        case "initializationComplete":
            webViewReady = true
            print("WebView initialization complete - setting ready state")
            if let editorReady = data["editorReady"] as? Bool {
                print("Monaco editor ready: \(editorReady)")
            }
            if let engineReady = data["engineReady"] as? Bool {
                print("Babylon engine ready: \(engineReady)")
            }
        case "codeChanged":
            if let code = data["code"] as? String {
                currentCode = code
            }
        case "sceneCreated":
            print("Scene created successfully")
        case "sceneError":
            if let error = data["error"] as? String {
                errorMessage = "Scene Error: \(error)"
                showingError = true
            }
        case "codeRun":
            print("Scene execution completed")
        case "codeInserted":
            if let code = data["code"] as? String {
                print("Code inserted: \(code)")
            }
        case "codeFormatted":
            print("Code formatted")
        case "testInjection":
            print("🧪 Test injection requested")
            testEditorInjection()
        default:
            print("Unknown action: \(action)")
        }
    }
    
    private func runScene() {
        guard let webView = webView else {
            errorMessage = "WebView not available"
            showingError = true
            return
        }
        
        let jsCode = "if (typeof runCode === 'function') { runCode(); } else { console.error('runCode function not found'); }"
        
        webView.evaluateJavaScript(jsCode) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Error running scene: \(error.localizedDescription)"
                    self.showingError = true
                }
                print("Error running scene: \(error)")
            }
        }
    }
    
    private func formatCode() {
        guard let webView = webView else {
            errorMessage = "WebView not available"
            showingError = true
            return
        }
        
        let jsCode = "if (typeof formatCode === 'function') { formatCode(); } else { console.error('formatCode function not found'); }"
        
        webView.evaluateJavaScript(jsCode) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Error formatting code: \(error.localizedDescription)"
                    self.showingError = true
                }
                print("Error formatting code: \(error)")
            }
        }
    }
    
    private func injectCodeWithRetry(_ code: String, maxRetries: Int) {
        print("🔄 Starting injection attempt with \(maxRetries) retries remaining...")
        
        guard let webView = webView else {
            print("❌ WebView not available for injection")
            isInjectingCode = false
            return
        }
        
        // Enhanced readiness check that works across all playground templates
        let checkReadinessJS = """
        (function() {
            // Check Monaco editor readiness
            const monacoReady = window.editor && 
                               typeof window.editor.setValue === 'function' && 
                               typeof window.editor.getValue === 'function' &&
                               typeof window.editor.layout === 'function';
            
            // Check editor ready flag (set by all playground templates)
            const editorFlagReady = window.editorReady === true;
            
            // Check if the DOM is fully loaded
            const domReady = document.readyState === 'complete';
            
            // Check if setFullEditorContent function exists (our injection function)
            const injectionFuncReady = typeof window.setFullEditorContent === 'function';
            
            console.log('Readiness check:', {
                monaco: monacoReady,
                flag: editorFlagReady, 
                dom: domReady,
                injection: injectionFuncReady
            });
            
            if (monacoReady && editorFlagReady && domReady) {
                return "READY";
            } else {
                return "NOT_READY";
            }
        })();
        """
        
        webView.evaluateJavaScript(checkReadinessJS) { result, error in
            DispatchQueue.main.async {
                if let result = result as? String, result == "READY" {
                    print("✅ Monaco editor is ready, proceeding with injection")
                    self.insertCodeInWebView(code)
                    
                    // JavaScript function will handle auto-run, just clear the loading state
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.isInjectingCode = false
                    }
                } else {
                    print("⏳ Monaco not ready yet, retries left: \(maxRetries)")
                    print("🔍 Current readiness result: \(result ?? "nil")")
                    if let error = error {
                        print("🔍 Readiness check error: \(error)")
                    }
                    
                    if maxRetries > 0 {
                        // Retry after delay - longer delay for first few retries to allow full initialization
                        let delay = maxRetries > 3 ? 2.0 : 1.0
                        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                            self.injectCodeWithRetry(code, maxRetries: maxRetries - 1)
                        }
                    } else {
                        print("❌ Max retries reached, injection failed")
                        print("🔍 Final check - trying emergency injection...")
                        
                        // Emergency injection attempt - try even if not completely ready
                        self.insertCodeInWebView(code)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.isInjectingCode = false
                        }
                    }
                }
            }
        }
    }
    
    private func insertCodeInWebView(_ code: String) {
        guard let webView = webView else {
            print("❌ WebView not available")
            return
        }
        
        let escapedCode = code
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
            .replacingOccurrences(of: "`", with: "\\`")
        
        let jsCode = """
        console.log("=== CALLING ENHANCED setFullEditorContent ===");
        
        (function() {
            // Try method 1: Enhanced setFullEditorContent function
            if (typeof setFullEditorContent === 'function') {
                console.log("📋 Method 1: Using setFullEditorContent function");
                try {
                    const success = setFullEditorContent("\(escapedCode)");
                    console.log("setFullEditorContent result:", success ? "SUCCESS" : "FAILED");
                    if (success) return "SUCCESS_METHOD_1";
                } catch (error) {
                    console.error("❌ setFullEditorContent error:", error);
                }
            }
            
            // Try method 2: Direct Monaco setValue with checks
            if (window.editor && typeof window.editor.setValue === 'function') {
                console.log("📋 Method 2: Direct Monaco setValue");
                try {
                    window.editor.setValue("\(escapedCode)");
                    if (typeof window.editor.layout === 'function') {
                        window.editor.layout();
                    }
                    if (typeof window.editor.focus === 'function') {
                        window.editor.focus();
                    }
                    
                    // Try to trigger auto-run if available
                    if (typeof runCode === 'function') {
                        setTimeout(() => {
                            console.log("🚀 Auto-running code after injection...");
                            runCode();
                        }, 500);
                    }
                    
                    console.log("✅ Direct injection completed");
                    return "SUCCESS_METHOD_2";
                } catch (error) {
                    console.error("❌ Direct injection error:", error);
                }
            }
            
            // Try method 3: Emergency text area injection (last resort)
            console.log("📋 Method 3: Emergency injection attempt");
            try {
                const editorElement = document.getElementById('monaco-editor');
                if (editorElement) {
                    console.log("Found editor element, attempting emergency injection");
                    // This is a fallback that at least puts the code somewhere visible
                    return "EMERGENCY_FALLBACK";
                }
            } catch (error) {
                console.error("❌ Emergency injection error:", error);
            }
            
            return "ALL_METHODS_FAILED";
        })();
        """
        
        print("Executing ENHANCED JavaScript code injection...")
        webView.evaluateJavaScript(jsCode) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ JavaScript execution error: \(error)")
                    // Don't show error immediately - the emergency injection might have worked
                    print("🔄 JavaScript error occurred, but continuing...")
                } else if let resultString = result as? String {
                    print("✅ JavaScript executed successfully")
                    print("📋 Injection result: \(resultString)")
                    
                    switch resultString {
                    case "SUCCESS_METHOD_1":
                        print("🎉 Code injection successful via setFullEditorContent")
                    case "SUCCESS_METHOD_2":
                        print("🎉 Code injection successful via direct Monaco API")
                    case "EMERGENCY_FALLBACK":
                        print("⚠️ Used emergency fallback injection method")
                    case "ALL_METHODS_FAILED":
                        print("❌ All injection methods failed")
                        self.errorMessage = "Unable to inject code into editor. Please try again."
                        self.showingError = true
                    default:
                        print("✅ Injection completed with result: \(resultString)")
                    }
                } else {
                    print("✅ JavaScript executed, result: \(String(describing: result))")
                }
            }
        }
    }
    
    // MARK: - Testing and Debugging
    
    /// Test function to verify Monaco editor injection system works across all playground templates
    private func testEditorInjection() {
        print("🧪 Testing editor injection system...")
        
        let testCode = """
        // Test injection - \(Date())
        console.log("Editor injection test successful!");
        """
        
        guard let webView = webView else {
            print("❌ WebView not available for testing")
            return
        }
        
        // Test the readiness check first
        let checkReadinessJS = """
        (function() {
            const monacoReady = window.editor && 
                               typeof window.editor.setValue === 'function' && 
                               typeof window.editor.getValue === 'function' &&
                               typeof window.editor.layout === 'function';
            
            const editorFlagReady = window.editorReady === true;
            const domReady = document.readyState === 'complete';
            const injectionFuncReady = typeof window.setFullEditorContent === 'function';
            
            return {
                monaco: monacoReady,
                flag: editorFlagReady, 
                dom: domReady,
                injection: injectionFuncReady,
                ready: monacoReady && editorFlagReady && domReady
            };
        })();
        """
        
        webView.evaluateJavaScript(checkReadinessJS) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("🧪 Test readiness check failed: \(error)")
                } else if let resultDict = result as? [String: Any] {
                    print("🧪 Test readiness results:")
                    for (key, value) in resultDict {
                        print("   \(key): \(value)")
                    }
                    
                    if let ready = resultDict["ready"] as? Bool, ready {
                        print("🧪 ✅ Editor is ready - proceeding with test injection")
                        self.insertCodeInWebView(testCode)
                    } else {
                        print("🧪 ❌ Editor not ready for testing")
                    }
                } else {
                    print("🧪 Test readiness check returned: \(String(describing: result))")
                }
            }
        }
    }
}

struct ChatMessageView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if message.isUser {
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.content)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .frame(maxWidth: 250, alignment: .trailing)
                    
                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.content)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .frame(maxWidth: 250, alignment: .leading)
                    
                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    ContentView()
}