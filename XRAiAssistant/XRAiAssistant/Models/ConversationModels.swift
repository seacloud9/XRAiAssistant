import Foundation

// MARK: - Enhanced Chat Message with Threading Support
struct EnhancedChatMessage: Identifiable, Codable, Equatable {
    let id: UUID
    var content: String
    let isUser: Bool
    let timestamp: Date
    var threadParentID: UUID? // Reference to parent message for threading
    var replies: [UUID] // Child message IDs
    var libraryId: String? // Track which 3D library was active when this message was created

    init(id: UUID = UUID(), content: String, isUser: Bool, timestamp: Date = Date(), threadParentID: UUID? = nil, replies: [UUID] = [], libraryId: String? = nil) {
        self.id = id
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
        self.threadParentID = threadParentID
        self.replies = replies
        self.libraryId = libraryId
    }

    // Convert from legacy ChatMessage
    init(from legacyMessage: ChatMessage) {
        self.id = UUID()
        self.content = legacyMessage.content
        self.isUser = legacyMessage.isUser
        self.timestamp = legacyMessage.timestamp
        self.threadParentID = nil
        self.replies = []
        self.libraryId = legacyMessage.libraryId
    }
}

// MARK: - Conversation Thread
struct Conversation: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var messages: [EnhancedChatMessage]
    let createdAt: Date
    var updatedAt: Date
    var library3DID: String? // Associated 3D library for context
    var modelUsed: String? // AI model used in this conversation

    init(id: UUID = UUID(), title: String, messages: [EnhancedChatMessage] = [], createdAt: Date = Date(), updatedAt: Date = Date(), library3DID: String? = nil, modelUsed: String? = nil) {
        self.id = id
        self.title = title
        self.messages = messages
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.library3DID = library3DID
        self.modelUsed = modelUsed
    }

    // Auto-generate title from first user message
    mutating func generateTitleIfNeeded() {
        if title.isEmpty || title == "New Conversation" {
            if let firstUserMessage = messages.first(where: { $0.isUser }) {
                let content = firstUserMessage.content
                let maxLength = 50
                if content.count > maxLength {
                    title = String(content.prefix(maxLength)) + "..."
                } else {
                    title = content
                }
            }
        }
    }

    // Get top-level messages (not replies)
    func getTopLevelMessages() -> [EnhancedChatMessage] {
        return messages.filter { $0.threadParentID == nil }
    }

    // Get replies for a specific message
    func getReplies(for messageID: UUID) -> [EnhancedChatMessage] {
        return messages.filter { $0.threadParentID == messageID }
            .sorted { $0.timestamp < $1.timestamp }
    }

    // Check if a message has replies
    func hasReplies(_ messageID: UUID) -> Bool {
        return messages.contains { $0.threadParentID == messageID }
    }
}

// MARK: - Conversation Storage Manager
@MainActor
class ConversationStorageManager: ObservableObject {
    @Published var conversations: [Conversation] = []

    private let storageKey = "XRAiAssistant_Conversations"
    private let maxStoredConversations = 100

    init() {
        loadConversations()
    }

    // MARK: - Persistence

    func saveConversations() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(conversations)
            UserDefaults.standard.set(data, forKey: storageKey)
            print("💾 Saved \(conversations.count) conversations")
        } catch {
            print("❌ Failed to save conversations: \(error.localizedDescription)")
        }
    }

    func loadConversations() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            print("📂 No saved conversations found")
            return
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            conversations = try decoder.decode([Conversation].self, from: data)
            print("📂 Loaded \(conversations.count) conversations")
        } catch {
            print("❌ Failed to load conversations: \(error.localizedDescription)")
            conversations = []
        }
    }

    // MARK: - Conversation Management

    func addConversation(_ conversation: Conversation) {
        var newConversation = conversation
        newConversation.generateTitleIfNeeded()
        conversations.insert(newConversation, at: 0) // Most recent first

        // Limit stored conversations
        if conversations.count > maxStoredConversations {
            conversations = Array(conversations.prefix(maxStoredConversations))
        }

        saveConversations()
    }

    func updateConversation(_ conversation: Conversation) {
        if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
            var updated = conversation
            updated.updatedAt = Date()
            updated.generateTitleIfNeeded()
            conversations[index] = updated

            // Move to top (most recent)
            let removed = conversations.remove(at: index)
            conversations.insert(removed, at: 0)

            saveConversations()
        }
    }

    func deleteConversation(_ id: UUID) {
        conversations.removeAll { $0.id == id }
        saveConversations()
    }

    func clearAllConversations() {
        conversations.removeAll()
        saveConversations()
    }

    func getConversation(id: UUID) -> Conversation? {
        return conversations.first { $0.id == id }
    }

    // MARK: - Search & Filter

    func searchConversations(query: String) -> [Conversation] {
        guard !query.isEmpty else { return conversations }

        return conversations.filter { conversation in
            conversation.title.localizedCaseInsensitiveContains(query) ||
            conversation.messages.contains { message in
                message.content.localizedCaseInsensitiveContains(query)
            }
        }
    }

    func getConversationsByLibrary(_ libraryID: String) -> [Conversation] {
        return conversations.filter { $0.library3DID == libraryID }
    }

    func getConversationsByModel(_ modelName: String) -> [Conversation] {
        return conversations.filter { $0.modelUsed == modelName }
    }
}
