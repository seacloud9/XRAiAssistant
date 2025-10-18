import SwiftUI

// MARK: - Threaded Message View
struct ThreadedMessageView: View {
    let message: EnhancedChatMessage
    let conversation: Conversation
    let isExpanded: Bool
    let onReply: (UUID) -> Void
    let onToggleThread: (UUID) -> Void

    @State private var showReplyField = false

    private var replies: [EnhancedChatMessage] {
        conversation.getReplies(for: message.id)
    }

    private var hasReplies: Bool {
        !replies.isEmpty
    }

    var body: some View {
        VStack(alignment: message.isUser ? .trailing : .leading, spacing: 8) {
            // Main message
            HStack(alignment: .top, spacing: 8) {
                if message.isUser {
                    Spacer()
                }

                VStack(alignment: message.isUser ? .trailing : .leading, spacing: 6) {
                    // Message bubble
                    MarkdownMessageView(content: message.content, isUser: message.isUser)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(message.isUser ? Color.blue : Color(.systemGray5))
                        .foregroundColor(message.isUser ? .white : .primary)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .frame(maxWidth: 600, alignment: message.isUser ? .trailing : .leading)

                    // Timestamp and actions
                    HStack(spacing: 12) {
                        Text(formatTime(message.timestamp))
                            .font(.caption2)
                            .foregroundColor(.gray)

                        if !message.isUser {
                            Button(action: { onReply(message.id) }) {
                                Label("Reply", systemImage: "arrowshape.turn.up.left")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }

                        if hasReplies {
                            Button(action: { onToggleThread(message.id) }) {
                                Label("\(replies.count) \(replies.count == 1 ? "reply" : "replies")",
                                      systemImage: isExpanded ? "chevron.up" : "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .frame(maxWidth: 600, alignment: message.isUser ? .trailing : .leading)
                }

                if !message.isUser {
                    Spacer()
                }
            }

            // Thread replies
            if hasReplies && isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(replies) { reply in
                        ThreadReplyView(
                            message: reply,
                            onReply: onReply
                        )
                    }
                }
                .padding(.leading, message.isUser ? 0 : 40) // Indent replies
                .padding(.trailing, message.isUser ? 40 : 0)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isExpanded)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Thread Reply View
struct ThreadReplyView: View {
    let message: EnhancedChatMessage
    let onReply: (UUID) -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // Thread indicator line
            Rectangle()
                .fill(Color.blue.opacity(0.3))
                .frame(width: 2)

            VStack(alignment: .leading, spacing: 4) {
                // Reply bubble (smaller than main messages)
                MarkdownMessageView(content: message.content, isUser: message.isUser)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(message.isUser ? Color.blue.opacity(0.8) : Color(.systemGray6))
                    .foregroundColor(message.isUser ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .frame(maxWidth: 500, alignment: .leading)

                // Timestamp
                HStack(spacing: 8) {
                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.gray)

                    if !message.isUser {
                        Button(action: { onReply(message.id) }) {
                            Text("Reply")
                                .font(.caption2)
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Preview
#Preview {
    struct PreviewWrapper: View {
        @State private var expandedThreads: Set<UUID> = []
        @State private var conversation: Conversation

        init() {
            let mainMessage = EnhancedChatMessage(
                content: "Can you explain how **React Three Fiber** works?\n\n```jsx\nimport { Canvas } from '@react-three/fiber'\n```",
                isUser: true
            )

            let aiResponse = EnhancedChatMessage(
                content: "React Three Fiber is a React renderer for Three.js. Here's a basic example:\n\n```jsx\nfunction Box() {\n  return (\n    <mesh>\n      <boxGeometry />\n      <meshStandardMaterial color=\"orange\" />\n    </mesh>\n  )\n}\n```",
                isUser: false
            )

            let reply1 = EnhancedChatMessage(
                content: "How do I add animations?",
                isUser: true,
                threadParentID: aiResponse.id
            )

            let reply2 = EnhancedChatMessage(
                content: "Use the `useFrame` hook:\n\n```jsx\nuseFrame((state, delta) => {\n  meshRef.current.rotation.x += delta\n})\n```",
                isUser: false,
                threadParentID: aiResponse.id
            )

            _conversation = State(initialValue: Conversation(
                title: "React Three Fiber Tutorial",
                messages: [mainMessage, aiResponse, reply1, reply2]
            ))
        }

        var body: some View {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(conversation.getTopLevelMessages()) { message in
                        ThreadedMessageView(
                            message: message,
                            conversation: conversation,
                            isExpanded: expandedThreads.contains(message.id),
                            onReply: { messageID in
                                print("Reply to: \(messageID)")
                            },
                            onToggleThread: { messageID in
                                if expandedThreads.contains(messageID) {
                                    expandedThreads.remove(messageID)
                                } else {
                                    expandedThreads.insert(messageID)
                                }
                            }
                        )
                    }
                }
                .padding()
            }
        }
    }

    return PreviewWrapper()
}
