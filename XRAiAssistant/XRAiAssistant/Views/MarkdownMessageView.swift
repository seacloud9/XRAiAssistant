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

        case .inlineFormattedLine(let blocks):
            // Render a line with mixed inline formatting (text + inline code + bold + italic)
            // NO background container - only inline code gets gray background
            buildAttributedText(from: blocks)
                .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)

        case .heading(let text, let level):
            Text(text)
                .font(headingFont(for: level))
                .fontWeight(.bold)
                .foregroundColor(isUser ? .white : .primary)
                .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)

        // Legacy cases - kept for backward compatibility but shouldn't be used directly anymore
        case .inlineCode(let code):
            Text(code)
                .font(.system(.body, design: .monospaced))
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(Color(.systemGray6))
                .cornerRadius(4)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)

        case .bold(let text):
            Text(text)
                .fontWeight(.bold)
                .foregroundColor(isUser ? .white : .primary)
                .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)

        case .italic(let text):
            Text(text)
                .italic()
                .foregroundColor(isUser ? .white : .primary)
                .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)
        }
    }
    
    // Build an inline formatted view using HStack for better control
    // This ensures inline code gets gray background while text remains normal
    private func buildAttributedText(from blocks: [InlineBlock]) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            ForEach(Array(blocks.enumerated()), id: \.offset) { index, block in
                switch block {
                case .plainText(let text):
                    Text(text)
                        .font(.body)
                        .foregroundColor(isUser ? .white : .primary)
                    
                case .code(let code):
                    Text(code)
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray6))
                        )
                    
                case .boldText(let text):
                    Text(text)
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(isUser ? .white : .primary)
                    
                case .italicText(let text):
                    Text(text)
                        .font(.body)
                        .italic()
                        .foregroundColor(isUser ? .white : .primary)
                }
            }
        }
    }

    private func codeBlockView(code: String, language: String?, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with language and copy button
            HStack {
                if let lang = language, !lang.isEmpty {
                    Text(lang.uppercased())
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 0.4, green: 0.8, blue: 1.0)) // Bright blue
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
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(copiedCodeBlocks.contains(index) ? 
                               Color.green.opacity(0.8) : 
                               Color(red: 0.3, green: 0.6, blue: 0.9))
                    .cornerRadius(6)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(red: 0.12, green: 0.14, blue: 0.18)) // Dark blue-gray header

            // Code content with enhanced syntax highlighting
            ScrollView(.horizontal, showsIndicators: true) {
                syntaxHighlightedCode(code, language: language)
                    .padding(12)
            }
            .background(Color(red: 0.08, green: 0.10, blue: 0.13)) // Darker code background
        }
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(red: 0.2, green: 0.3, blue: 0.4).opacity(0.3), lineWidth: 1)
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
    }

    private func syntaxHighlightedCode(_ code: String, language: String?) -> Text {
        // Enhanced syntax highlighting with better contrast colors
        let keywords = [
            // JavaScript/TypeScript
            "const", "let", "var", "function", "return", "if", "else", "for", "while", "class",
            "import", "export", "from", "new", "this", "true", "false", "null", "undefined",
            // Swift
            "func", "struct", "enum", "protocol", "extension", "private", "public", "static",
            "override", "init", "deinit", "guard", "defer", "await", "async",
            // Python
            "def", "class", "import", "from", "return", "if", "elif", "else", "for", "while",
            "try", "except", "finally", "with", "as", "lambda", "yield",
            // Common
            "async", "await", "break", "case", "catch", "continue", "default", "do",
            "switch", "throw", "throws", "try", "typeof", "void"
        ]

        var result = Text("")
        let lines = code.components(separatedBy: .newlines)

        for (lineIndex, line) in lines.enumerated() {
            var currentText = ""
            let words = line.components(separatedBy: .whitespaces)

            for (wordIndex, word) in words.enumerated() {
                // Check if word contains a keyword
                let trimmedWord = word.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)

                if keywords.contains(trimmedWord) {
                    // Add accumulated text first
                    if !currentText.isEmpty {
                        result = result + Text(currentText)
                            .foregroundColor(Color(red: 0.85, green: 0.90, blue: 0.95)) // Light gray-blue for text
                            .font(.system(.body, design: .monospaced))
                        currentText = ""
                    }

                    // Add keyword with highlighting
                    let prefix = word.prefix(while: { !$0.isLetter && !$0.isNumber })
                    let suffix = word.suffix(from: word.index(word.startIndex, offsetBy: prefix.count + trimmedWord.count))

                    result = result +
                        Text(String(prefix))
                            .foregroundColor(Color(red: 0.85, green: 0.90, blue: 0.95))
                            .font(.system(.body, design: .monospaced)) +
                        Text(trimmedWord)
                            .foregroundColor(Color(red: 0.4, green: 0.85, blue: 1.0)) // Bright cyan for keywords
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.semibold) +
                        Text(String(suffix))
                            .foregroundColor(Color(red: 0.85, green: 0.90, blue: 0.95))
                            .font(.system(.body, design: .monospaced))

                    if wordIndex < words.count - 1 {
                        result = result + Text(" ")
                            .foregroundColor(Color(red: 0.85, green: 0.90, blue: 0.95))
                            .font(.system(.body, design: .monospaced))
                    }
                } else {
                    currentText += word
                    if wordIndex < words.count - 1 {
                        currentText += " "
                    }
                }
            }

            // Add any remaining text
            if !currentText.isEmpty {
                result = result + Text(currentText)
                    .foregroundColor(Color(red: 0.85, green: 0.90, blue: 0.95)) // Light gray-blue for text
                    .font(.system(.body, design: .monospaced))
            }

            // Add newline except for last line
            if lineIndex < lines.count - 1 {
                result = result + Text("\n")
                    .foregroundColor(Color(red: 0.85, green: 0.90, blue: 0.95))
                    .font(.system(.body, design: .monospaced))
            }
        }

        return result
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

    // MARK: - Content Cleaning

    private func cleanContent(_ text: String) -> String {
        var cleaned = text

        // Remove common AI response artifacts that appear at the start
        let artifacts = [
            "^A:\\s*",           // "A: "
            "^Assistant:\\s*",   // "Assistant: "
            "^AI:\\s*",          // "AI: "
            "^Response:\\s*"     // "Response: "
        ]

        for artifact in artifacts {
            if let regex = try? NSRegularExpression(pattern: artifact, options: [.anchorsMatchLines]) {
                cleaned = regex.stringByReplacingMatches(
                    in: cleaned,
                    options: [],
                    range: NSRange(location: 0, length: cleaned.utf16.count),
                    withTemplate: ""
                )
            }
        }

        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Content Parsing

    private func parseContent() -> [ContentBlock] {
        // Clean up content first - remove common AI response artifacts
        let cleanedContent = cleanContent(content)

        var blocks: [ContentBlock] = []
        let lines = cleanedContent.components(separatedBy: .newlines)
        var i = 0

        while i < lines.count {
            let line = lines[i]

            // Code block detection (```) - MUST be checked first and be strict
            // Only match if ``` is at the start of the line (after whitespace)
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            if trimmedLine.hasPrefix("```") && !trimmedLine.hasPrefix("`````") {
                let language = trimmedLine
                    .replacingOccurrences(of: "```", with: "")
                    .trimmingCharacters(in: .whitespaces)

                var codeLines: [String] = []
                i += 1

                // Collect all lines until we find the closing ```
                while i < lines.count {
                    let codeLine = lines[i]
                    let trimmedCodeLine = codeLine.trimmingCharacters(in: .whitespaces)
                    if trimmedCodeLine.hasPrefix("```") {
                        break
                    }
                    codeLines.append(codeLine)
                    i += 1
                }

                let code = codeLines.joined(separator: "\n")
                print("📦 Code block extracted: \(codeLines.count) lines, \(code.count) chars")
                print("📝 Code block preview: \(code.prefix(100))...")
                print("📝 Code block END: ...\(code.suffix(100))")
                blocks.append(.codeBlock(code: code, language: language.isEmpty ? nil : language))
                i += 1
                continue
            }

            // Heading detection (must be at line start)
            if line.hasPrefix("#") {
                let level = line.prefix(while: { $0 == "#" }).count
                let text = line.dropFirst(level).trimmingCharacters(in: .whitespaces)
                blocks.append(.heading(text: text, level: level))
                i += 1
                continue
            }

            // Lines with inline code, bold, or italic formatting
            // This handles mixed content like "Use `const` or `let` for variables"
            if line.contains("`") || line.contains("*") {
                let inlineBlocks = parseInlineFormatting(line)
                // Only create inline formatted line if we have content
                if !inlineBlocks.isEmpty {
                    blocks.append(.inlineFormattedLine(inlineBlocks))
                }
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

    private func parseInlineFormatting(_ text: String) -> [InlineBlock] {
        var blocks: [InlineBlock] = []
        var currentText = ""
        var i = text.startIndex

        while i < text.endIndex {
            let char = text[i]

            // Inline code (`code`) - single backticks only
            if char == "`" {
                // Make sure it's not a triple backtick (which shouldn't happen here, but safety check)
                let remainingText = String(text[i...])
                if remainingText.hasPrefix("```") {
                    // This is a code block marker, treat as regular text
                    currentText.append(char)
                    i = text.index(after: i)
                    continue
                }
                
                if !currentText.isEmpty {
                    blocks.append(.plainText(currentText))
                    currentText = ""
                }

                i = text.index(after: i)
                var code = ""
                
                // Find the closing backtick
                while i < text.endIndex && text[i] != "`" {
                    code.append(text[i])
                    i = text.index(after: i)
                }
                
                // Only create inline code if we found a closing backtick
                if i < text.endIndex && text[i] == "`" {
                    blocks.append(.code(code))
                    i = text.index(after: i)
                } else {
                    // No closing backtick found, treat as regular text
                    currentText.append("`")
                    currentText.append(code)
                }
                continue
            }

            // Bold (**text**) - must have two asterisks
            if char == "*" && i < text.index(before: text.endIndex) && text[text.index(after: i)] == "*" {
                // Check it's not more than two asterisks
                let nextIndex = text.index(i, offsetBy: 2, limitedBy: text.endIndex)
                let isTripleAsterisk = nextIndex != nil && nextIndex! < text.endIndex && text[nextIndex!] == "*"
                
                if isTripleAsterisk {
                    // Three or more asterisks, treat as regular text
                    currentText.append(char)
                    i = text.index(after: i)
                    continue
                }
                
                if !currentText.isEmpty {
                    blocks.append(.plainText(currentText))
                    currentText = ""
                }

                i = text.index(i, offsetBy: 2)
                var bold = ""
                
                // Find closing **
                while i < text.index(before: text.endIndex) {
                    if text[i] == "*" && text[text.index(after: i)] == "*" {
                        break
                    }
                    bold.append(text[i])
                    i = text.index(after: i)
                }
                
                if i < text.endIndex && text[i] == "*" {
                    blocks.append(.boldText(bold))
                    i = text.index(i, offsetBy: 2, limitedBy: text.endIndex) ?? text.endIndex
                } else {
                    // No closing **, treat as regular text
                    currentText.append("**")
                    currentText.append(bold)
                }
                continue
            }

            // Italic (*text*) - single asterisk
            if char == "*" {
                if !currentText.isEmpty {
                    blocks.append(.plainText(currentText))
                    currentText = ""
                }

                i = text.index(after: i)
                var italic = ""
                
                // Find closing *
                while i < text.endIndex && text[i] != "*" {
                    italic.append(text[i])
                    i = text.index(after: i)
                }
                
                if i < text.endIndex && text[i] == "*" {
                    blocks.append(.italicText(italic))
                    i = text.index(after: i)
                } else {
                    // No closing *, treat as regular text
                    currentText.append("*")
                    currentText.append(italic)
                }
                continue
            }

            currentText.append(char)
            i = text.index(after: i)
        }

        if !currentText.isEmpty {
            blocks.append(.plainText(currentText))
        }

        return blocks
    }
}

// MARK: - Content Block Types
enum ContentBlock {
    case text(String)
    case codeBlock(code: String, language: String?)
    case inlineFormattedLine([InlineBlock])  // New: for lines with mixed inline formatting
    case heading(text: String, level: Int)
    // Legacy cases - kept for backward compatibility
    case inlineCode(String)
    case bold(String)
    case italic(String)
}

// MARK: - Inline Block Types (for mixed formatting on a single line)
enum InlineBlock {
    case plainText(String)
    case code(String)
    case boldText(String)
    case italicText(String)
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
            
            To use this code, call `runCode()` or use the **Run** button. You can also use `insertCodeAtCursor()` for *inline* insertion.
            """,
            isUser: false
        )
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(16)
        .padding()
    }
}
