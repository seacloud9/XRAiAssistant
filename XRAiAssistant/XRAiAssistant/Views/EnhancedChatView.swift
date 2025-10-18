import SwiftUI

// MARK: - Enhanced Chat View with Adaptive Layout
struct EnhancedChatView: View {
    @ObservedObject var viewModel: ChatViewModel
    @ObservedObject var storageManager: ConversationStorageManager

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
                VStack(alignment: .leading, spacing: 4) {
                    MarkdownMessageView(content: message.content, isUser: false)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .frame(maxWidth: 600, alignment: .leading)

                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                Spacer()
            }
        }
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
            if #available(iOS 16.0, *) {
                TextField("Type a message...", text: $inputText, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(1...5)
            } else {
                TextField("Type a message...", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
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
        .padding()
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

            // TODO: Send to AI and get response
        } else {
            // Legacy path - send through existing ViewModel
            viewModel.sendMessage(messageContent)
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
