import SwiftUI

// MARK: - Enhanced Chat View with Adaptive Layout
struct EnhancedChatView: View {
    @ObservedObject var viewModel: ChatViewModel
    @ObservedObject var storageManager: ConversationStorageManager
    var onRunCode: ((_ code: String, _ libraryId: String?) -> Void)?

    @State private var currentConversation: Conversation?
    @State private var expandedThreads: Set<UUID> = []
    @State private var replyingToMessageID: UUID?
    @State private var inputText = ""
    @State private var showHistory = false
    @State private var selectedHistoryConversation: Conversation?
    @State private var isCompactView = false

    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass

    // Adaptive layout properties
    private var isWideLayout: Bool {
        horizontalSizeClass == .regular && verticalSizeClass == .regular
    }

    private var maxMessageWidth: CGFloat {
        if isCompactView {
            return 600
        } else if isWideLayout {
            return 900 // Wider for iPad
        } else {
            return 600
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Model and Library selectors header (always visible)
                modelAndLibraryHeader

                // Conversation header (if loaded from history)
                if let conversation = currentConversation {
                    conversationHeaderView(conversation)
                }

                // Messages list
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            if let conversation = currentConversation {
                                // Threaded conversation view
                                ForEach(conversation.getTopLevelMessages()) { message in
                                    ThreadedMessageView(
                                        message: message,
                                        conversation: conversation,
                                        isExpanded: expandedThreads.contains(message.id),
                                        onReply: { messageID in
                                            replyingToMessageID = messageID
                                        },
                                        onToggleThread: { messageID in
                                            withAnimation {
                                                if expandedThreads.contains(messageID) {
                                                    expandedThreads.remove(messageID)
                                                } else {
                                                    expandedThreads.insert(messageID)
                                                }
                                            }
                                        },
                                        onRun: { code, libraryId in
                                            onRunCode?(code, libraryId)
                                        }
                                    )
                                    .id(message.id)
                                }
                            } else {
                                // Legacy message view for current session
                                ForEach(viewModel.messages) { message in
                                    legacyMessageView(message)
                                        .id(message.id)
                                }
                            }

                            if viewModel.isLoading {
                                loadingIndicator
                            }
                        }
                        .padding()
                        .frame(maxWidth: maxMessageWidth)
                        .frame(maxWidth: .infinity) // Center the content
                    }
                    .onChange(of: viewModel.messages.count) { _ in
                        if let lastMessage = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }

                            // Auto-save conversation only after AI responses (not user messages)
                            if currentConversation == nil && !lastMessage.isUser && !viewModel.messages.isEmpty {
                                autoSaveConversation()
                            }
                        }
                    }
                }

                // Reply indicator
                if let replyID = replyingToMessageID {
                    replyIndicatorView(for: replyID)
                }

                // Input area
                inputAreaView
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showHistory = true }) {
                        Image(systemName: "clock.arrow.circlepath")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            isCompactView.toggle()
                        } label: {
                            Label(isCompactView ? "Wide View" : "Compact View",
                                  systemImage: isCompactView ? "arrow.up.left.and.arrow.down.right" : "arrow.down.right.and.arrow.up.left")
                        }

                        Button {
                            saveCurrentConversation()
                        } label: {
                            Label("Save Conversation", systemImage: "square.and.arrow.down")
                        }
                        .disabled(viewModel.messages.isEmpty)

                        Button(role: .destructive) {
                            clearCurrentConversation()
                        } label: {
                            Label("New Conversation", systemImage: "plus.bubble")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showHistory) {
                ConversationHistoryView(
                    storageManager: storageManager,
                    isPresented: $showHistory,
                    selectedConversation: $selectedHistoryConversation
                )
            }
            .onChange(of: selectedHistoryConversation) { newConversation in
                if let conversation = newConversation {
                    loadConversation(conversation)
                    selectedHistoryConversation = nil
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // MARK: - Subviews

    // MARK: - Model and Library Header (broken into sub-views for compiler)

    private var modelAndLibraryHeader: some View {
        HStack(spacing: 12) {
            modelSelectorView
            librarySelectorView
            Spacer()

            // Documentation button
            Button(action: {
                let currentLibrary = viewModel.libraryManager.selectedLibrary
                if let url = URL(string: currentLibrary.documentationURL) {
                    UIApplication.shared.open(url)
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "book.circle")
                        .foregroundColor(.purple)
                        .font(.caption)
                    Text("Docs")
                        .font(.caption)
                        .foregroundColor(.purple)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(6)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.separator)),
            alignment: .bottom
        )
    }

    private var modelSelectorView: some View {
        HStack(spacing: 8) {
            Image(systemName: "cpu")
                .foregroundColor(.gray)
                .font(.caption)

            Text("Model:")
                .font(.caption)
                .foregroundColor(.gray)

            modelMenuView
        }
    }

    private var modelMenuView: some View {
        Menu {
            modelMenuContent
        } label: {
            modelMenuLabel
        }
    }

    private var modelMenuContent: some View {
        Group {
            ForEach(Array(viewModel.modelsByProvider.keys.sorted()), id: \.self) { provider in
                Section(provider) {
                    ForEach(viewModel.modelsByProvider[provider] ?? [], id: \.id) { model in
                        Button(action: {
                            viewModel.selectedModel = model.id
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
                                if viewModel.selectedModel == model.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                }
            }

            if !viewModel.availableModels.isEmpty {
                Section("Legacy") {
                    ForEach(viewModel.availableModels, id: \.self) { model in
                        Button(action: {
                            viewModel.selectedModel = model
                        }) {
                            HStack {
                                Text(viewModel.getModelDisplayName(model))
                                    .font(.system(size: 14, weight: .medium))
                                if viewModel.selectedModel == model {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var modelMenuLabel: some View {
        HStack {
            Text(viewModel.getModelDisplayName(viewModel.selectedModel))
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

    private var librarySelectorView: some View {
        HStack(spacing: 8) {
            Image(systemName: "cube.box")
                .foregroundColor(.gray)
                .font(.caption)

            Text("Library:")
                .font(.caption)
                .foregroundColor(.gray)

            libraryMenuView
        }
    }

    private var libraryMenuView: some View {
        Menu {
            ForEach(viewModel.libraryManager.availableLibraries, id: \.id) { library in
                Button(action: {
                    viewModel.libraryManager.selectLibrary(library)
                }) {
                    HStack {
                        Text(library.displayName)
                            .font(.system(size: 14, weight: .medium))
                        if viewModel.libraryManager.selectedLibrary.id == library.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                                .font(.caption)
                        }
                    }
                }
            }
        } label: {
            libraryMenuLabel
        }
    }

    private var libraryMenuLabel: some View {
        HStack {
            Text(viewModel.libraryManager.selectedLibrary.displayName)
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

    private func conversationHeaderView(_ conversation: Conversation) -> some View {
        VStack(spacing: 4) {
            Text(conversation.title)
                .font(.headline)
                .lineLimit(1)

            HStack(spacing: 8) {
                if let library = conversation.library3DID {
                    Text(library)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(4)
                }

                if let model = conversation.modelUsed {
                    Text(model)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Text(relativeDateString(from: conversation.updatedAt))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(Color(.systemGray6))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.separator)),
            alignment: .bottom
        )
    }

    private func legacyMessageView(_ message: ChatMessage) -> some View {
        HStack(alignment: .top, spacing: 8) {
            if message.isUser {
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    MarkdownMessageView(content: message.content, isUser: true)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .frame(maxWidth: 600, alignment: .trailing)

                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    MarkdownMessageView(content: message.content, isUser: false)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .frame(maxWidth: 600, alignment: .leading)

                    // Timestamp and action buttons
                    HStack(spacing: 12) {
                        Text(formatTime(message.timestamp))
                            .font(.caption2)
                            .foregroundColor(.gray)

                        // ALWAYS show "Run the Scene" button for AI messages, but extract code smartly
                        Button(action: {
                            // Try to extract code first, fallback to full content if no code blocks found
                            if let code = extractCode(from: message.content) {
                                print("🎯 Running extracted code (\(code.count) chars) with library: \(message.libraryId ?? "current")")
                                onRunCode?(code, message.libraryId)
                            } else {
                                print("⚠️ No code blocks found, running full message content with library: \(message.libraryId ?? "current")")
                                onRunCode?(message.content, message.libraryId)
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "play.fill")
                                    .font(.caption)
                                Text("Run the Scene")
                                    .font(.caption)
                                    .underline() // Make it look like a hyperlink
                            }
                            .foregroundColor(extractCode(from: message.content) != nil ? .green : .orange)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .frame(maxWidth: 600, alignment: .leading)
                }
                Spacer()
            }
        }
    }

    private func extractCode(from content: String) -> String? {
        // DEBUG: Print full content to understand the format
        print("🔍 [Legacy] Attempting code extraction:")
        print("📏 Length: \(content.count)")
        print("📝 First 300 chars: \(content.prefix(300))")
        print("📝 Last 100 chars: \(content.suffix(100))")

        // STRICT: Only extract code from TRIPLE backtick blocks (``` not `)
        // Find the start of the code block
        let possibleStarts = ["```javascript", "```typescript", "```js", "```ts", "```jsx", "```html", "```"]
        var codeStart: String.Index? = nil
        var foundMarker = ""

        for marker in possibleStarts {
            if let range = content.range(of: marker) {
                // Verify it's actually triple backticks, not more
                let beforeMarker = content[..<range.lowerBound]
                let afterMarkerStart = content.index(range.upperBound, offsetBy: 0, limitedBy: content.endIndex) ?? content.endIndex
                
                // Make sure we're not matching part of a longer backtick sequence
                if !beforeMarker.hasSuffix("`") && 
                   (afterMarkerStart == content.endIndex || !content[afterMarkerStart...].hasPrefix("`")) {
                    codeStart = range.upperBound
                    foundMarker = marker
                    print("✅ Found code block start: '\(marker)'")
                    break
                }
            }
        }

        guard let start = codeStart else {
            print("❌ No code block start marker found")
            return nil
        }

        // Find the end of the code block (closing triple backticks)
        let afterStart = content[start...]
        
        // Look for newline followed by ``` (the proper closing)
        guard let endRange = afterStart.range(of: "\n```") ?? afterStart.range(of: "```") else {
            print("❌ No closing ``` found")
            return nil
        }

        // Extract the code between start and end
        let codeRange = start..<endRange.lowerBound
        var code = String(content[codeRange]).trimmingCharacters(in: .whitespacesAndNewlines)

        print("✅ Raw extracted code length: \(code.count)")
        print("📝 First 100 chars of code: \(code.prefix(100))")

        // Remove any artifacts that might be at the end
        let artifactsToRemove = ["[/INSERT_CODE]", "[RUN_SCENE]", "```"]
        for artifact in artifactsToRemove {
            if code.hasSuffix(artifact) {
                code = String(code.dropLast(artifact.count)).trimmingCharacters(in: .whitespacesAndNewlines)
                print("🧹 Removed trailing artifact: \(artifact)")
            }
        }

        print("✅ Final extracted code length: \(code.count)")
        
        // Sanity check: ignore if it's too short (probably not real code)
        if code.count < 10 {
            print("⚠️ Extracted code too short, ignoring")
            return nil
        }
        
        return code.isEmpty ? nil : code
    }

    private var loadingIndicator: some View {
        HStack {
            ProgressView()
            Text("Thinking...")
                .font(.callout)
                .foregroundColor(.secondary)
        }
        .padding()
    }

    private func replyIndicatorView(for messageID: UUID) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Replying to:")
                    .font(.caption)
                    .foregroundColor(.secondary)

                if let message = currentConversation?.messages.first(where: { $0.id == messageID }) {
                    Text(String(message.content.prefix(50)) + (message.content.count > 50 ? "..." : ""))
                        .font(.caption)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                }
            }

            Spacer()

            Button(action: { replyingToMessageID = nil }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.separator)),
            alignment: .top
        )
    }

    private var inputAreaView: some View {
        HStack(spacing: 12) {
            // Use single-line TextField so Enter/Return submits instead of creating new line
            TextField("Type a message...", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .submitLabel(.send) // Shows "Send" button on keyboard
                .onSubmit {
                    sendMessage()
                }

            Button(action: sendMessage) {
                Image(systemName: "paperplane.fill")
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(inputText.isEmpty ? Color.gray : Color.blue)
                    .clipShape(Circle())
            }
            .disabled(inputText.isEmpty || viewModel.isLoading)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .padding(.bottom, 0) // Remove extra bottom padding - let safe area handle it
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.separator)),
            alignment: .top
        )
    }

    private var navigationTitle: String {
        if let conversation = currentConversation {
            return conversation.title
        } else {
            return "Chat"
        }
    }

    // MARK: - Helper Functions

    private func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let messageContent = inputText
        inputText = ""

        // Dismiss keyboard immediately after sending
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

        if let conversation = currentConversation {
            // Add message as threaded reply
            var updatedConversation = conversation
            let newMessage = EnhancedChatMessage(
                content: messageContent,
                isUser: true,
                threadParentID: replyingToMessageID
            )
            updatedConversation.messages.append(newMessage)

            // Update parent's replies array
            if let parentID = replyingToMessageID,
               let parentIndex = updatedConversation.messages.firstIndex(where: { $0.id == parentID }) {
                updatedConversation.messages[parentIndex].replies.append(newMessage.id)
            }

            currentConversation = updatedConversation
            storageManager.updateConversation(updatedConversation)
            replyingToMessageID = nil

            // Send to AI and get response
            Task {
                await sendToAIAndUpdateConversation(messageContent, in: updatedConversation)
            }
        } else {
            // Legacy path - send through existing ViewModel
            viewModel.sendMessage(messageContent)
        }
    }

    private func sendToAIAndUpdateConversation(_ userMessage: String, in conversation: Conversation) async {
        // Temporarily sync conversation to viewModel to get AI response
        await MainActor.run {
            // Clear viewModel messages and add conversation history
            viewModel.messages = conversation.messages.map { enhanced in
                ChatMessage(
                    id: enhanced.id.uuidString,
                    content: enhanced.content,
                    isUser: enhanced.isUser,
                    timestamp: enhanced.timestamp,
                    libraryId: enhanced.libraryId
                )
            }

            // Add the new user message
            let userChatMessage = ChatMessage(
                id: UUID().uuidString,
                content: userMessage,
                isUser: true,
                timestamp: Date(),
                libraryId: viewModel.currentLibraryId
            )
            viewModel.messages.append(userChatMessage)
        }

        // Use viewModel's sendMessage which handles AI response
        await MainActor.run {
            viewModel.sendMessage(userMessage)
        }

        // Wait for the response and sync back to conversation
        Task { @MainActor in
            // Wait for loading to finish
            while viewModel.isLoading {
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            }

            // Sync viewModel messages back to conversation
            guard var updatedConversation = currentConversation else { return }

            // Update conversation with all messages from viewModel
            updatedConversation.messages = viewModel.messages.map { EnhancedChatMessage(from: $0) }
            updatedConversation.updatedAt = Date()

            currentConversation = updatedConversation
            storageManager.updateConversation(updatedConversation)

            // Clear viewModel messages to avoid confusion
            viewModel.messages.removeAll()
        }
    }

    private func saveCurrentConversation() {
        guard !viewModel.messages.isEmpty else { return }

        let enhancedMessages = viewModel.messages.map { EnhancedChatMessage(from: $0) }
        var newConversation = Conversation(
            title: "New Conversation",
            messages: enhancedMessages,
            library3DID: viewModel.libraryManager.selectedLibrary.id,
            modelUsed: viewModel.selectedModel
        )
        newConversation.generateTitleIfNeeded()

        storageManager.addConversation(newConversation)
        currentConversation = newConversation
    }

    private func autoSaveConversation() {
        // Automatically save conversation after AI responses
        guard !viewModel.messages.isEmpty else { return }

        if let conversation = currentConversation {
            // Update existing conversation with new messages
            var updatedConversation = conversation
            let enhancedMessages = viewModel.messages.map { EnhancedChatMessage(from: $0) }
            updatedConversation.messages = enhancedMessages
            updatedConversation.updatedAt = Date()

            storageManager.updateConversation(updatedConversation)
            currentConversation = updatedConversation
        } else {
            // Create new conversation with title from first user message
            let enhancedMessages = viewModel.messages.map { EnhancedChatMessage(from: $0) }

            // Find the first user message to use as the title
            let firstUserMessage = viewModel.messages.first(where: { $0.isUser })
            let title = generateConversationTitle(from: firstUserMessage?.content ?? "New Conversation")

            let newConversation = Conversation(
                title: title,
                messages: enhancedMessages,
                library3DID: viewModel.libraryManager.selectedLibrary.id,
                modelUsed: viewModel.selectedModel
            )

            storageManager.addConversation(newConversation)
            currentConversation = newConversation
        }
    }

    private func generateConversationTitle(from message: String) -> String {
        // Clean and truncate the message to create a good title
        let cleaned = message.trimmingCharacters(in: .whitespacesAndNewlines)

        // Take first line or first 50 characters
        let firstLine = cleaned.components(separatedBy: .newlines).first ?? cleaned
        if firstLine.count <= 50 {
            return firstLine
        } else {
            return String(firstLine.prefix(47)) + "..."
        }
    }

    private func loadConversation(_ conversation: Conversation) {
        currentConversation = conversation
        expandedThreads.removeAll()
        replyingToMessageID = nil

        // Clear current session
        viewModel.messages.removeAll()
    }

    private func clearCurrentConversation() {
        if currentConversation != nil {
            saveCurrentConversation()
        }

        currentConversation = nil
        expandedThreads.removeAll()
        replyingToMessageID = nil
        viewModel.messages.removeAll()
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func relativeDateString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Preview
#Preview {
    struct PreviewWrapper: View {
        @StateObject var viewModel = ChatViewModel()
        @StateObject var storageManager = ConversationStorageManager()

        var body: some View {
            EnhancedChatView(
                viewModel: viewModel,
                storageManager: storageManager
            )
        }
    }

    return PreviewWrapper()
}
