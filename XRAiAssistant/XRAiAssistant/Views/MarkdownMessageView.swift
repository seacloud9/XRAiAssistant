import SwiftUI

// MARK: - Markdown Message View with Code Block Support
struct MarkdownMessageView: View {
    let content: String
    let isUser: Bool
    @State private var copiedCodeBlocks: Set<Int> = []

    var body: some View {
        VStack(alignment: isUser ? .trailing : .leading, spacing: 8) {
            ForEach(Array(parseContent().enumerated()), id: \.offset) { index, block in
                renderBlock(block, index: index)
            }
        }
    }

    @ViewBuilder
    private func renderBlock(_ block: ContentBlock, index: Int) -> some View {
        switch block {
        case .text(let text):
            Text(text)
                .font(.body)
                .foregroundColor(isUser ? .white : .primary)
                .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)

        case .codeBlock(let code, let language):
            codeBlockView(code: code, language: language, index: index)

        case .inlineCode(let code):
            Text(code)
                .font(.system(.body, design: .monospaced))
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(Color(.systemGray6))
                .cornerRadius(4)
                .foregroundColor(.primary)

        case .heading(let text, let level):
            Text(text)
                .font(headingFont(for: level))
                .fontWeight(.bold)
                .foregroundColor(isUser ? .white : .primary)
                .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)

        case .bold(let text):
            Text(text)
                .fontWeight(.bold)
                .foregroundColor(isUser ? .white : .primary)

        case .italic(let text):
            Text(text)
                .italic()
                .foregroundColor(isUser ? .white : .primary)
        }
    }

    private func codeBlockView(code: String, language: String?, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with language and copy button
            HStack {
                if let lang = language, !lang.isEmpty {
                    Text(lang)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                Button(action: {
                    copyToClipboard(code, index: index)
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: copiedCodeBlocks.contains(index) ? "checkmark" : "doc.on.doc")
                            .font(.caption)
                        Text(copiedCodeBlocks.contains(index) ? "Copied!" : "Copy")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(6)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray))

            // Code content
            ScrollView(.horizontal, showsIndicators: true) {
                Text(code)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(12)
            }
            .background(Color(.systemGray2))
        }
        .cornerRadius(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
    }

    private func copyToClipboard(_ text: String, index: Int) {
        #if os(iOS)
        UIPasteboard.general.string = text
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #endif

        // Show copied feedback
        copiedCodeBlocks.insert(index)

        // Reset after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            copiedCodeBlocks.remove(index)
        }
    }

    private func headingFont(for level: Int) -> Font {
        switch level {
        case 1: return .title
        case 2: return .title2
        case 3: return .title3
        default: return .headline
        }
    }

    // MARK: - Content Parsing

    private func parseContent() -> [ContentBlock] {
        var blocks: [ContentBlock] = []
        let lines = content.components(separatedBy: .newlines)
        var i = 0

        while i < lines.count {
            let line = lines[i]

            // Code block detection (```)
            if line.trimmingCharacters(in: .whitespaces).hasPrefix("```") {
                let language = line.trimmingCharacters(in: .whitespaces)
                    .replacingOccurrences(of: "```", with: "")
                    .trimmingCharacters(in: .whitespaces)

                var codeLines: [String] = []
                i += 1

                while i < lines.count {
                    let codeLine = lines[i]
                    if codeLine.trimmingCharacters(in: .whitespaces).hasPrefix("```") {
                        break
                    }
                    codeLines.append(codeLine)
                    i += 1
                }

                let code = codeLines.joined(separator: "\n")
                blocks.append(.codeBlock(code: code, language: language.isEmpty ? nil : language))
                i += 1
                continue
            }

            // Heading detection
            if line.hasPrefix("#") {
                let level = line.prefix(while: { $0 == "#" }).count
                let text = line.dropFirst(level).trimmingCharacters(in: .whitespaces)
                blocks.append(.heading(text: text, level: level))
                i += 1
                continue
            }

            // Inline code detection (`)
            if line.contains("`") {
                blocks.append(contentsOf: parseInlineFormatting(line))
                i += 1
                continue
            }

            // Regular text
            if !line.trimmingCharacters(in: .whitespaces).isEmpty {
                blocks.append(.text(line))
            }

            i += 1
        }

        return blocks
    }

    private func parseInlineFormatting(_ text: String) -> [ContentBlock] {
        var blocks: [ContentBlock] = []
        var currentText = ""
        var i = text.startIndex

        while i < text.endIndex {
            let char = text[i]

            // Inline code (`code`)
            if char == "`" {
                if !currentText.isEmpty {
                    blocks.append(.text(currentText))
                    currentText = ""
                }

                i = text.index(after: i)
                var code = ""
                while i < text.endIndex && text[i] != "`" {
                    code.append(text[i])
                    i = text.index(after: i)
                }
                blocks.append(.inlineCode(code))

                if i < text.endIndex {
                    i = text.index(after: i)
                }
                continue
            }

            // Bold (**text**)
            if char == "*" && i < text.index(before: text.endIndex) && text[text.index(after: i)] == "*" {
                if !currentText.isEmpty {
                    blocks.append(.text(currentText))
                    currentText = ""
                }

                i = text.index(i, offsetBy: 2)
                var bold = ""
                while i < text.index(before: text.endIndex) {
                    if text[i] == "*" && text[text.index(after: i)] == "*" {
                        break
                    }
                    bold.append(text[i])
                    i = text.index(after: i)
                }
                blocks.append(.bold(bold))

                if i < text.endIndex {
                    i = text.index(i, offsetBy: 2)
                }
                continue
            }

            // Italic (*text*)
            if char == "*" {
                if !currentText.isEmpty {
                    blocks.append(.text(currentText))
                    currentText = ""
                }

                i = text.index(after: i)
                var italic = ""
                while i < text.endIndex && text[i] != "*" {
                    italic.append(text[i])
                    i = text.index(after: i)
                }
                blocks.append(.italic(italic))

                if i < text.endIndex {
                    i = text.index(after: i)
                }
                continue
            }

            currentText.append(char)
            i = text.index(after: i)
        }

        if !currentText.isEmpty {
            blocks.append(.text(currentText))
        }

        return blocks.isEmpty ? [.text(text)] : blocks
    }
}

// MARK: - Content Block Types
enum ContentBlock {
    case text(String)
    case codeBlock(code: String, language: String?)
    case inlineCode(String)
    case heading(text: String, level: Int)
    case bold(String)
    case italic(String)
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        MarkdownMessageView(
            content: """
            Here's a **bold** example with *italic* text.

            # Heading 1
            ## Heading 2

            Inline code: `const x = 42;`

            ```javascript
            function hello() {
                console.log("Hello, World!");
                return true;
            }
            ```

            ```python
            def fibonacci(n):
                if n <= 1:
                    return n
                return fibonacci(n-1) + fibonacci(n-2)
            ```
            """,
            isUser: false
        )
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(16)
        .padding()
    }
}
