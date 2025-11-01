package com.xraiassistant.data.repositories

import com.xraiassistant.domain.models.AFrameLibrary
import com.xraiassistant.domain.models.BabylonJSLibrary
import com.xraiassistant.domain.models.Library3D
import com.xraiassistant.domain.models.ReactThreeFiberLibrary
import com.xraiassistant.domain.models.ReactylonLibrary
import com.xraiassistant.domain.models.ThreeJSLibrary
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Library3D Repository
 * 
 * Manages available 3D libraries and provides access to their configurations
 * Equivalent to Library3DManager in iOS
 */
@Singleton
class Library3DRepository @Inject constructor() {
    
    private val libraries: List<Library3D> = listOf(
        BabylonJSLibrary(),
        ThreeJSLibrary(),
        ReactThreeFiberLibrary(),
        ReactylonLibrary(),
        AFrameLibrary()
    )
    
    private val defaultLibraryId = "babylonjs"
    
    /**
     * Get all available 3D libraries
     */
    fun getAllLibraries(): List<Library3D> = libraries
    
    /**
     * Get library by ID
     */
    fun getLibraryById(id: String): Library3D? {
        return libraries.find { it.id == id }
    }
    
    /**
     * Get default library (Babylon.js)
     */
    fun getDefaultLibrary(): Library3D {
        return getLibraryById(defaultLibraryId) ?: libraries.first()
    }
    
    /**
     * Get libraries that require build system
     */
    fun getBuildRequiredLibraries(): List<Library3D> {
        return libraries.filter { it.requiresBuild }
    }
    
    /**
     * Get libraries that use direct injection
     */
    fun getDirectInjectionLibraries(): List<Library3D> {
        return libraries.filter { !it.requiresBuild }
    }
    
    /**
     * Get library by framework name (for build system integration)
     */
    fun getFrameworkKind(library: Library3D): FrameworkKind? {
        return when (library.id) {
            "babylonjs" -> FrameworkKind.BABYLON
            "threejs" -> null // Three.js uses direct injection
            "aframe" -> FrameworkKind.AFRAME
            "reactThreeFiber" -> FrameworkKind.REACT_THREE_FIBER
            "reactylon" -> FrameworkKind.REACTYLON
            else -> null
        }
    }
}

/**
 * Framework kinds for build system
 * Equivalent to iOS FrameworkKind enum
 */
enum class FrameworkKind(val value: String) {
    BABYLON("babylon"),
    AFRAME("aFrame"),
    REACT_THREE_FIBER("reactThreeFiber"),
    REACTYLON("reactylon");
    
    val requiresBuild: Boolean
        get() = when (this) {
            BABYLON, AFRAME -> false
            REACT_THREE_FIBER, REACTYLON -> true
        }
    
    val codeLanguage: String
        get() = when (this) {
            BABYLON, AFRAME -> "javascript"
            REACT_THREE_FIBER, REACTYLON -> "typescript"
        }
    
    val entryFileName: String
        get() = when (this) {
            BABYLON, AFRAME -> "index.js"
            REACT_THREE_FIBER, REACTYLON -> "index.tsx"
        }
}