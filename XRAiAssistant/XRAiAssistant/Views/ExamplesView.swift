import SwiftUI

struct ExamplesView: View {
    @ObservedObject var library3DManager: Library3DManager
    let onExampleSelected: (CodeExample) -> Void
    @Environment(\.dismiss) var dismiss

    @State private var searchText = ""
    @State private var selectedCategory: ExampleCategory? = nil
    @State private var selectedDifficulty: ExampleDifficulty? = nil

    var filteredExamples: [CodeExample] {
        let examples = library3DManager.selectedLibrary.examples

        var filtered = examples

        // Filter by search text (title, description, keywords)
        if !searchText.isEmpty {
            filtered = filtered.filter { example in
                example.title.localizedCaseInsensitiveContains(searchText) ||
                example.description.localizedCaseInsensitiveContains(searchText) ||
                example.keywords.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }

        // Filter by category
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }

        // Filter by difficulty
        if let difficulty = selectedDifficulty {
            filtered = filtered.filter { $0.difficulty == difficulty }
        }

        return filtered
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search examples or keywords...", text: $searchText)
                        .textFieldStyle(.plain)
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))

                // Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // Category filter
                        Menu {
                            Button("All Categories") {
                                selectedCategory = nil
                            }
                            Divider()
                            ForEach(ExampleCategory.allCases, id: \.self) { category in
                                Button(action: {
                                    selectedCategory = category
                                }) {
                                    Label(category.rawValue, systemImage: category.icon)
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: selectedCategory?.icon ?? "square.grid.2x2")
                                Text(selectedCategory?.rawValue ?? "Category")
                                    .lineLimit(1)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedCategory != nil ? Color.blue : Color(.systemGray5))
                            .foregroundColor(selectedCategory != nil ? .white : .primary)
                            .cornerRadius(8)
                        }

                        // Difficulty filter
                        Menu {
                            Button("All Levels") {
                                selectedDifficulty = nil
                            }
                            Divider()
                            ForEach([ExampleDifficulty.beginner, .intermediate, .advanced], id: \.self) { difficulty in
                                Button(difficulty.rawValue) {
                                    selectedDifficulty = difficulty
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "chart.bar")
                                Text(selectedDifficulty?.rawValue ?? "Difficulty")
                                    .lineLimit(1)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedDifficulty != nil ? Color.orange : Color(.systemGray5))
                            .foregroundColor(selectedDifficulty != nil ? .white : .primary)
                            .cornerRadius(8)
                        }

                        // Clear filters
                        if selectedCategory != nil || selectedDifficulty != nil {
                            Button(action: {
                                selectedCategory = nil
                                selectedDifficulty = nil
                            }) {
                                Text("Clear")
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                .background(Color(.systemGray6))

                // Results count
                HStack {
                    Text("\(filteredExamples.count) example\(filteredExamples.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(library3DManager.selectedLibrary.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.vertical, 4)

                // Examples list
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredExamples) { example in
                            ExampleCard(example: example) {
                                onExampleSelected(example)
                                dismiss()
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Examples")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ExampleCard: View {
    let example: CodeExample
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Text(example.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    difficultyBadge
                }

                // Description
                Text(example.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                // Keywords (if present)
                if !example.keywords.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(example.keywords.prefix(5), id: \.self) { keyword in
                                Text(keyword)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(4)
                            }
                            if example.keywords.count > 5 {
                                Text("+\(example.keywords.count - 5)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }

                // Footer
                HStack {
                    Label(example.category.rawValue, systemImage: example.category.icon)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    if example.aiPromptHints != nil {
                        Image(systemName: "sparkles")
                            .font(.caption)
                            .foregroundColor(.purple)
                    }

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    var difficultyBadge: some View {
        let color: Color = {
            switch example.difficulty {
            case .beginner: return .green
            case .intermediate: return .orange
            case .advanced: return .red
            }
        }()

        return Text(example.difficulty.rawValue)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(4)
    }
}

// Preview
struct ExamplesView_Previews: PreviewProvider {
    static var previews: some View {
        ExamplesView(
            library3DManager: Library3DManager(),
            onExampleSelected: { _ in }
        )
    }
}
