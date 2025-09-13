# XRAiAssistant Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added - Multi-3D Library Support (Phase 1: Core Architecture)
- **Core Architecture** ✅
  - Library3D protocol for extensible 3D library support
  - Library3DManager for centralized library management  
  - Dynamic system prompt switching based on selected library
  - Real-time playground environment switching
  - Type-erased Library3D wrapper for Swift compatibility

- **Three.js Integration** ✅
  - Complete Three.js r160+ support with dedicated system prompts
  - playground-threejs.html template with WebGL renderer setup
  - Three.js-specific default scene code and examples
  - Proper scene/camera/renderer management patterns
  - OrbitControls integration for interactive camera control

- **A-Frame Integration** 🚧
  - A-Frame v1.4+ support for VR/AR development (implementation in progress)
  - playground-aframe.html template with VR-enabled interface
  - HTML-based declarative 3D scene development
  - VR-specific system prompts and interaction patterns

- **Enhanced Babylon.js Integration** ✅
  - Enhanced Babylon.js integration to use new Library3D protocol
  - Comprehensive system prompt with creative guidelines
  - Full feature set mapping (WebGL, WebXR, VR, AR, Physics, etc.)
  - Maintained backwards compatibility with existing scenes

### Added - Library Feature System ✅
- **Feature Detection**
  - Comprehensive Library3DFeature enumeration
  - Per-library supported feature tracking
  - Feature comparison system across libraries
  - Smart feature-based recommendations

- **Code Language Support**
  - JavaScript support for Babylon.js and Three.js
  - HTML support for A-Frame declarative syntax
  - TypeScript compatibility for enhanced development
  - Monaco editor language switching per library

### Added - Library Management System ✅
- **Library3DManager**
  - Centralized library registration and management
  - Persistent library selection across app sessions
  - Dynamic system prompt generation per library
  - Library-specific welcome message generation

- **Library3DFactory**
  - Factory pattern for library instantiation
  - Easy addition of new 3D libraries
  - Default library configuration
  - Library lookup and validation

### Technical Implementation Details ✅
- **Created Files:**
  - `Library3D/Library3D.swift` - Core protocol and types
  - `Library3D/BabylonJSLibrary.swift` - Enhanced Babylon.js implementation
  - `Library3D/ThreeJSLibrary.swift` - Complete Three.js implementation
  - `Library3D/AFrameLibrary.swift` - A-Frame VR implementation
  - `Library3D/Library3DManager.swift` - Centralized management system
  - `Resources/playground-threejs.html` - Three.js playground template

### Changed
- Enhanced Babylon.js integration to use new Library3D protocol
- Updated system prompt structure for improved AI code generation
- Modified playground template architecture for multi-library support
- Improved error handling and fallback scene creation

### Completed - Phase 2: UI Integration ✅
- **ChatViewModel Library Integration** ✅
  - Added Library3DManager property for centralized 3D library management
  - Dynamic welcome messages based on selected library (Babylon.js, Three.js, A-Frame)
  - Library-specific system prompt generation with automatic switching
  - Real-time library switching with automatic message updates
  - Comprehensive library selection methods (selectLibrary, getCurrentLibrary, etc.)
  
- **Library-Aware AI System** ✅
  - Replaced hardcoded Babylon.js system prompts with dynamic library-specific prompts
  - AI responses now automatically tailored to selected 3D library
  - System prompt includes library-specific code patterns and examples
  - Code language detection (JavaScript for Babylon.js/Three.js, HTML for A-Frame)

### Completed - Phase 3: Dynamic Playground System ✅
- **Library Selection UI Components** ✅
  - Added library selection dropdown in chat interface next to model selector
  - Added library selection in settings panel with version and feature indicators
  - Real-time library switching with visual feedback and confirmation
  - Library-specific icons and color coding (green for library, blue for model)

- **Dynamic Playground Template Loading** ✅
  - Enhanced WebView to accept dynamic playground template parameter
  - Automatic template switching based on selected library
  - Three playground templates: playground.html (Babylon.js), playground-threejs.html, playground-aframe.html
  - Library-specific code language detection (JavaScript, HTML)

- **WebView Integration** ✅
  - Updated WebViewCoordinator to support dynamic template loading
  - ContentView integration with ChatViewModel.getPlaygroundTemplate()
  - Seamless switching between Babylon.js, Three.js, and A-Frame playgrounds
  - Real-time template updates when user changes library selection

- **Complete A-Frame Playground** ✅
  - Created playground-aframe.html with VR/AR scene support
  - Monaco editor with HTML syntax highlighting for A-Frame
  - Interactive VR examples (basic scene, interactive objects, animations, VR controls)
  - WebXR-ready interface with hand tracking and controller support

### Fixed - API Key Configuration & User Experience 🔧
- **Enhanced Error Messages** ✅
  - Clear, actionable error messages for API key configuration issues
  - User-friendly guidance pointing to Settings panel (gear icon)
  - Direct links to Together.ai API key generation page
  - Specific error handling for 401 authentication failures

- **Proactive API Key Validation** ✅
  - Welcome message includes setup instructions when API key is not configured
  - Real-time validation in welcome screen for immediate user feedback
  - Clear distinction between "changeMe" default and actual configuration errors

### Fixed - Monaco Editor Injection Reliability & WebView Template Loading 🔧
- **Enhanced Editor Readiness Detection** ✅
  - Improved readiness check across all playground templates (Babylon.js, Three.js, A-Frame)
  - Added comprehensive validation for Monaco editor, DOM state, and injection functions
  - Increased retry attempts from 3 to 6 with adaptive delay timing
  - Enhanced debugging with detailed readiness state logging

- **Multi-Level Injection Fallback System** ✅
  - Strategy 1: Standard Monaco setValue with content verification
  - Strategy 2: Direct Monaco model manipulation
  - Strategy 3: Emergency retry with delay and error recovery
  - Library-specific logging and error reporting (babylonjs, threejs, aframe)
  - Intelligent result reporting and error handling per method

- **Enhanced WebView Template Loading** ✅
  - Multi-strategy template loading with comprehensive fallback system
  - Strategy 1: Direct bundle path lookup with proper error handling
  - Strategy 2: Resources subdirectory search for template files
  - Strategy 3: Automatic fallback to default playground template
  - Strategy 4: Emergency HTML generation with detailed error reporting
  - Bundle content debugging for troubleshooting template loading issues

- **Robust Error Handling** ✅
  - Eliminated "Monaco editor not ready for injection" alerts
  - Fixed "Failed to load HTML file" errors for Three.js and A-Frame templates
  - Graceful degradation with multiple injection and loading strategies
  - Comprehensive testing functions for debugging injection issues
  - Better user feedback with specific success/failure reporting per library

### System Status: Multi-3D Library Support Complete 🚀
- **Frontend**: Library selection UI in both chat and settings
- **Backend**: Library-specific system prompts and code generation  
- **Playground**: Dynamic template loading for all supported libraries with reliable injection
- **AI Integration**: Context-aware responses for Babylon.js, Three.js, and A-Frame

---

## [2.0.0] - 2025-09-13

### Added - Multi-Provider AI Support
- **Revolutionary AI Provider Expansion**
  - Support for Together.ai, OpenAI, and Anthropic AI providers
  - 15+ AI models across three providers with detailed metadata
  - Smart provider routing with automatic model detection
  - Graceful fallback to legacy Together.ai integration

- **Professional Settings Architecture**
  - Multi-provider API key management with secure storage
  - Visual status indicators for provider configuration
  - Organized model dropdowns grouped by provider
  - Real-time configuration feedback and validation

- **Enhanced AI Integration**
  - Protocol-based AIProvider interface for extensibility
  - Streaming responses from all supported providers
  - Intelligent retry logic and error handling per provider
  - Dynamic model selection with pricing information

### Added - Provider Implementations
- **Together.ai Provider**
  - DeepSeek R1 70B (FREE), Llama 3.3 70B (FREE)
  - Llama 3 8B Lite, Qwen 2.5 models
  - Cost-effective options with free tier access

- **OpenAI Provider**
  - GPT-4o, GPT-4o Mini, GPT-4 Turbo, GPT-3.5 Turbo
  - Industry-leading model quality and reliability
  - Native API integration with streaming support

- **Anthropic Provider**
  - Claude 3.5 Sonnet, Claude 3.5 Haiku, Claude 3 Opus
  - Advanced reasoning capabilities for complex tasks
  - Direct API integration with proper message formatting

### Added - User Experience Enhancements
- **Organized Model Selection**
  - Provider-grouped dropdowns with pricing display
  - Visual provider indicators and configuration status
  - Smart model recommendations based on use case
  - Legacy model support for backwards compatibility

- **Professional Settings Panel**
  - Dedicated API key inputs per provider
  - Progressive disclosure design for advanced settings
  - Settings persistence with auto-restore functionality
  - Visual confirmation of setting changes

### Added - Developer Experience
- **Comprehensive Testing**
  - 25+ new test cases for multi-provider functionality
  - Provider-specific model validation tests
  - API key management and settings persistence tests
  - Error handling and fallback scenario tests

- **Complete Documentation**
  - MultiProviderSetup.md with detailed configuration guides
  - Provider comparison tables and feature matrices
  - Migration guide from single-provider setup
  - Troubleshooting documentation for common issues

### Fixed - Bug Resolutions
- **TogetherAI Provider Compilation**
  - Fixed 'Role' type member compilation error
  - Corrected AIProxy TogetherAIMessage.Role usage
  - Implemented proper role mapping patterns

- **SwiftUI Property Wrapper Issues**
  - Resolved @StateObject usage in non-View contexts
  - Fixed actor isolation conflicts with nested ObservableObjects
  - Added proper SwiftUI imports where needed

- **Architecture Improvements**
  - Removed unnecessary @MainActor annotations
  - Simplified provider management patterns
  - Enhanced error handling and retry logic

### Technical Details
- Created AIProvider protocol with concrete implementations
- Implemented AIProviderManager for centralized orchestration
- Added comprehensive multi-provider test suite
- Enhanced ChatViewModel with smart provider routing
- Updated ContentView with organized provider UI sections

---

## [1.0.0] - 2025-09-12

### Added - Initial Release
- **Core XRAiAssistant Features**
  - AI-powered Babylon.js scene generation
  - Real-time 3D preview with WebGL rendering
  - Professional Monaco code editor with TypeScript support
  - Together.ai integration with multiple model options

- **Babylon.js Integration**
  - Complete Babylon.js v6+ support
  - Intelligent code generation and correction
  - Real-time scene visualization
  - Professional parameter control (temperature, top-p)

- **User Interface**
  - SwiftUI-based iOS application
  - Dual-pane interface (code editor + 3D preview)
  - Settings panel with API key management
  - Chat interface for conversational 3D development

- **AI Features**
  - Context-aware Babylon.js code generation
  - Automatic code correction and optimization
  - Creative scene enhancement suggestions
  - Real-time streaming responses

### Technical Foundation
- Swift 5.9+ with SwiftUI declarative UI
- WebKit integration for 3D playground
- AIProxy Swift for Together.ai API integration
- LlamaStackClient for advanced model support
- Comprehensive test suite with XCTest

---

## Legend

### Types of Changes
- **Added** for new features
- **Changed** for changes in existing functionality  
- **Deprecated** for soon-to-be removed features
- **Removed** for now removed features
- **Fixed** for any bug fixes
- **Security** for vulnerability fixes

### Priority Levels
- **🚀 Major** - Significant new functionality or breaking changes
- **✨ Minor** - New features and enhancements
- **🔧 Patch** - Bug fixes and minor improvements
- **📚 Documentation** - Documentation updates and improvements