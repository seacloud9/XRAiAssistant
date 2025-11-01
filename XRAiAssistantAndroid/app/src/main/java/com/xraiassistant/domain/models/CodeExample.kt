package com.xraiassistant.domain.models

/**
 * CodeExample - Represents a pre-built code example for a 3D library
 *
 * Kotlin port of iOS CodeExample struct
 * Includes optional metadata for AI learning and user discovery
 */
data class CodeExample(
    val id: String? = null,              // Optional unique ID for special examples
    val title: String,                    // Display name (e.g., "Floating Crystal Gems")
    val description: String,              // Brief explanation of what the example demonstrates
    val code: String,                     // Complete working code
    val category: ExampleCategory,        // Categorization for filtering
    val difficulty: ExampleDifficulty,    // Skill level required
    val keywords: List<String>? = null,   // Searchable tags (optional)
    val aiPromptHints: String? = null     // Guidance for AI when generating similar scenes (optional)
)

/**
 * Example categories matching iOS implementation
 */
enum class ExampleCategory(val displayName: String) {
    BASIC("Basic Shapes"),
    ANIMATION("Animation"),
    LIGHTING("Lighting"),
    MATERIALS("Materials"),
    EFFECTS("Visual Effects"),
    PHYSICS("Physics"),
    INTERACTION("Interaction"),
    ADVANCED("Advanced"),
    VR("VR/XR")
}

/**
 * Difficulty levels for examples
 */
enum class ExampleDifficulty(val displayName: String) {
    BEGINNER("Beginner"),
    INTERMEDIATE("Intermediate"),
    ADVANCED("Advanced")
}
