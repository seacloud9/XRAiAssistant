# Enhanced Chat System Integration Guide

## Overview

This guide explains how to integrate the new threaded conversation system, persistent chat history, and improved code formatting into the XRAiAssistant iOS app.

## New Files Created

### 1. Data Models
**File**: `XRAiAssistant/XRAiAssistant/Models/ConversationModels.swift`

**Contains**:
- `EnhancedChatMessage` - Enhanced message model with threading support
- `Conversation` - Full conversation with metadata and history
- `ConversationStorageManager` - Persistent storage using UserDefaults/JSON

**Key Features**:
- Thread parent/child relationships via `threadParentID`
- Auto-generated conversation titles
- Search and filter capabilities
- Maximum 100 stored conversations
- ISO8601 date encoding for cross-platform compatibility

### 2. Markdown Renderer
**File**: `XRAiAssistant/XRAiAssistant/Views/MarkdownMessageView.swift`

**Features**:
- ✅ Code block detection with syntax highlighting labels
- ✅ Copy button for each code block with "Copied!" feedback
- ✅ Horizontal scrolling for long code lines
- ✅ Inline code with backticks (`)
- ✅ Bold (**text**) and italic (*text*)
- ✅ Headings (# ## ###)
- ✅ Proper text wrapping for paragraphs

**Usage**:
```swift
MarkdownMessageView(content: messageText, isUser: false)
```

### 3. Threaded Message View
**File**: `XRAiAssistant/XRAiAssistant/Views/ThreadedMessageView.swift`

**Features**:
- Collapsible thread display with chevron indicators
- Reply button on AI messages
- Thread depth visualization with indentation
- Reply count badges
- Smooth animations for expand/collapse
- Timestamp display

**Usage**:
```swift
ThreadedMessageView(
    message: message,
    conversation: conversation,
    isExpanded: expandedThreads.contains(message.id),
    onReply: { messageID in /* Handle reply */ },
    onToggleThread: { messageID in /* Toggle expand */ }
)
```

### 4. Conversation History View
**File**: `XRAiAssistant/XRAiAssistant/Views/ConversationHistoryView.swift`

**Features**:
- ✅ Searchable conversation list
- ✅ Swipe-to-delete conversations
- ✅ Relative date formatting ("2 hours ago")
- ✅ Message count badges
- ✅ Library/model tags
- ✅ "Clear All History" with confirmation alert
- ✅ Empty state when no conversations exist

**Usage**:
```swift
ConversationHistoryView(
    storageManager: storageManager,
    isPresented: $showHistory,
    selectedConversation: $selectedConversation
)
```

### 5. Enhanced Chat View
**File**: `XRAiAssistant/XRAiAssistant/Views/EnhancedChatView.swift`

**Features**:
- 📱 Adaptive layout (600px compact, 900px iPad)
- 🔄 Threaded conversation support
- 💾 Auto-save conversations
- 📜 History button in toolbar
- 🎨 Compact/Wide view toggle
- ⚡ Smooth scrolling to latest message
- 🧵 Reply indicator when threading
- 🎯 Load conversations from history

**Usage**:
```swift
EnhancedChatView(
    viewModel: chatViewModel,
    storageManager: storageManager
)
```

## Integration Steps

### Step 1: Add Files to Xcode Project

1. Create `Models` folder in Xcode:
   - Right-click `XRAiAssistant` group
   - New Group → "Models"
   - Add `ConversationModels.swift`

2. Create `Views` folder in Xcode:
   - Right-click `XRAiAssistant` group
   - New Group → "Views"
   - Add all view files:
     - `MarkdownMessageView.swift`
     - `ThreadedMessageView.swift`
     - `ConversationHistoryView.swift`
     - `EnhancedChatView.swift`

### Step 2: Update ChatViewModel (Optional Gradual Migration)

**Option A: Full Migration** (Recommended)
Replace the chat section in `ContentView.swift` with:

```swift
import SwiftUI

struct ContentView: View {
    @StateObject private var chatViewModel = ChatViewModel()
    @StateObject private var storageManager = ConversationStorageManager()
    // ... other state variables

    var body: some View {
        TabView(selection: $selectedTab) {
            // ... existing tabs

            // REPLACE existing chat tab with:
            EnhancedChatView(
                viewModel: chatViewModel,
                storageManager: storageManager
            )
            .tabItem {
                Label("Chat", systemImage: "message")
            }
            .tag(0)
        }
    }
}
```

**Option B: Gradual Migration** (Side-by-side comparison)
Add as a separate tab for testing:

```swift
EnhancedChatView(
    viewModel: chatViewModel,
    storageManager: storageManager
)
.tabItem {
    Label("Enhanced Chat", systemImage: "sparkles.rectangle.stack")
}
.tag(5)
```

### Step 3: Initialize Storage Manager

In `ContentView.swift` or `XRAiAssistant.swift`:

```swift
@StateObject private var conversationStorage = ConversationStorageManager()
```

Pass it to the enhanced chat view:

```swift
.environmentObject(conversationStorage)
```

### Step 4: Update ChatViewModel for Conversation Saving

Add this method to `ChatViewModel.swift`:

```swift
func getCurrentConversation(storageManager: ConversationStorageManager) -> Conversation {
    let enhancedMessages = messages.map { EnhancedChatMessage(from: $0) }
    var conversation = Conversation(
        title: "Auto-saved conversation",
        messages: enhancedMessages,
        library3DID: libraryManager.selectedLibrary?.id,
        modelUsed: selectedModel
    )
    conversation.generateTitleIfNeeded()
    return conversation
}

func autoSaveConversation(storageManager: ConversationStorageManager) {
    guard !messages.isEmpty else { return }
    let conversation = getCurrentConversation(storageManager: storageManager)
    storageManager.addConversation(conversation)
}
```

### Step 5: Test Features

1. **Send a message** - Should appear with markdown formatting
2. **Send code** - Wrap in triple backticks:
   ```swift
   ```javascript
   function hello() {
       console.log("Hello!");
   }
   ```
   ```
3. **Click copy button** - Should show "Copied!" feedback
4. **Click history icon** - Should show saved conversations
5. **Select a conversation** - Should load with all messages
6. **Test iPad/landscape** - Chat should expand to 900px width
7. **Toggle compact/wide view** - Toolbar menu option

## Features Comparison

| Feature | Old Chat | Enhanced Chat |
|---------|----------|---------------|
| Message display | Plain text | Markdown with code blocks |
| Code formatting | None | Syntax-highlighted with copy |
| Threading | None | Full thread support with replies |
| History | None | Persistent with search |
| Layout | Fixed 250px | Adaptive 600-900px |
| Save conversations | None | Auto-save with manual save |
| Search | None | Full-text search |
| Code width | Clipped | Horizontal scroll |

## Advanced Features

### Custom Thread Handling

```swift
// Reply to a specific message
func replyToMessage(_ messageID: UUID, content: String) {
    var newMessage = EnhancedChatMessage(
        content: content,
        isUser: true,
        threadParentID: messageID
    )

    // Add to conversation
    currentConversation?.messages.append(newMessage)

    // Update parent's replies array
    if let parentIndex = currentConversation?.messages.firstIndex(where: { $0.id == messageID }) {
        currentConversation?.messages[parentIndex].replies.append(newMessage.id)
    }
}
```

### Search Conversations

```swift
// Search by keyword
let results = storageManager.searchConversations(query: "Three.js")

// Filter by library
let threejsConvos = storageManager.getConversationsByLibrary("threejs")

// Filter by model
let llamaConvos = storageManager.getConversationsByModel("Llama-3.3-70B")
```

### Export Conversations

```swift
extension Conversation {
    func exportToJSON() -> String? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted

        guard let data = try? encoder.encode(self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
```

## Migration Notes

### Backward Compatibility

The `EnhancedChatMessage` has an initializer that converts legacy `ChatMessage`:

```swift
init(from legacyMessage: ChatMessage) {
    self.id = UUID()
    self.content = legacyMessage.content
    self.isUser = legacyMessage.isUser
    self.timestamp = legacyMessage.timestamp
    self.threadParentID = nil
    self.replies = []
}
```

### Data Persistence

Conversations are stored in UserDefaults under the key `XRAiAssistant_Conversations`. To migrate to a different storage backend (CoreData, SQLite), modify the `ConversationStorageManager` methods:

```swift
// Example CoreData migration
func saveConversations() {
    // Replace UserDefaults with CoreData save
    let context = PersistenceController.shared.container.viewContext
    // ... CoreData save logic
}
```

## Troubleshooting

### Code blocks not rendering
- Ensure triple backticks (```) are on separate lines
- Check that language identifier has no spaces: ```javascript not ``` javascript

### History not appearing
- Verify `ConversationStorageManager` is initialized as `@StateObject`
- Check UserDefaults key: `XRAiAssistant_Conversations`
- Try clearing and re-saving: Settings → Clear All History

### Layout issues on iPad
- Check `horizontalSizeClass` is `.regular`
- Verify `maxMessageWidth` calculation
- Test in both portrait and landscape

### Threads not expanding
- Ensure `expandedThreads` state is managed correctly
- Check `conversation.getReplies(for:)` returns messages
- Verify `threadParentID` is set correctly

## Performance Considerations

- **Maximum stored conversations**: 100 (configurable in `ConversationStorageManager`)
- **Message rendering**: Uses `LazyVStack` for efficient scrolling
- **Search**: Filters in-memory, O(n) complexity
- **Auto-save**: Only on explicit user action (not every message)

## Future Enhancements

- [ ] CoreData migration for better performance
- [ ] Export conversations as markdown files
- [ ] Share conversations via URL
- [ ] Conversation tagging and folders
- [ ] Full-text search with highlighting
- [ ] Message editing
- [ ] Voice input for messages
- [ ] Image attachments in messages

## Support

For issues or questions about the enhanced chat system:
1. Check this documentation first
2. Review the code comments in each file
3. Test with the provided previews
4. Check the XCode build output for errors

---

**Last Updated**: January 2025
**Version**: 1.0.0
**Compatibility**: iOS 16.0+, iPadOS 16.0+
