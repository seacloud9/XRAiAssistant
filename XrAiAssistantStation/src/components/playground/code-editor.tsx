'use client'

import { useEffect, useRef } from 'react'
import { Editor } from '@monaco-editor/react'
import { useTheme } from 'next-themes'
import { Library3D } from '@/store/app-store'

interface CodeEditorProps {
  value: string
  onChange: (value: string) => void
  language: string
  library: Library3D
}

export function CodeEditor({ value, onChange, language, library }: CodeEditorProps) {
  const { theme } = useTheme()
  const editorRef = useRef<any>(null)

  const handleEditorDidMount = (editor: any, monaco: any) => {
    editorRef.current = editor

    // Configure TypeScript/JavaScript settings
    monaco.languages.typescript.typescriptDefaults.setCompilerOptions({
      target: monaco.languages.typescript.ScriptTarget.ES2020,
      allowNonTsExtensions: true,
      moduleResolution: monaco.languages.typescript.ModuleResolutionKind.NodeJs,
      module: monaco.languages.typescript.ModuleKind.CommonJS,
      noEmit: true,
      esModuleInterop: true,
      jsx: monaco.languages.typescript.JsxEmit.React,
      reactNamespace: 'React',
      allowJs: true,
      typeRoots: ['node_modules/@types']
    })

    // Add library-specific type definitions
    if (library.id === 'babylonjs') {
      monaco.languages.typescript.typescriptDefaults.addExtraLib(`
        declare namespace BABYLON {
          class Engine {
            constructor(canvas: HTMLCanvasElement, antialias?: boolean);
            runRenderLoop(renderFunction: () => void): void;
            resize(): void;
          }
          
          class Scene {
            constructor(engine: Engine);
            render(): void;
            dispose(): void;
          }
          
          class ArcRotateCamera {
            constructor(name: string, alpha: number, beta: number, radius: number, target: Vector3, scene: Scene);
            attachToCanvas(canvas: HTMLCanvasElement, noPreventDefault?: boolean): void;
          }
          
          class HemisphericLight {
            constructor(name: string, direction: Vector3, scene: Scene);
            intensity: number;
          }
          
          class Vector3 {
            constructor(x?: number, y?: number, z?: number);
            static Zero(): Vector3;
          }
          
          class Box {
            static CreateBox(name: string, options: any, scene: Scene): Mesh;
          }
          
          class Mesh {
            position: Vector3;
            rotation: Vector3;
            scaling: Vector3;
          }
        }
      `, 'babylonjs.d.ts')
    } else if (library.id === 'threejs') {
      monaco.languages.typescript.typescriptDefaults.addExtraLib(`
        declare namespace THREE {
          class Scene {
            add(object: Object3D): void;
          }
          
          class PerspectiveCamera {
            constructor(fov: number, aspect: number, near: number, far: number);
            position: Vector3;
            aspect: number;
            updateProjectionMatrix(): void;
          }
          
          class WebGLRenderer {
            constructor(parameters?: any);
            setSize(width: number, height: number): void;
            render(scene: Scene, camera: Camera): void;
            domElement: HTMLCanvasElement;
          }
          
          class Vector3 {
            constructor(x?: number, y?: number, z?: number);
            set(x: number, y: number, z: number): Vector3;
          }
          
          class BoxGeometry {
            constructor(width?: number, height?: number, depth?: number);
          }
          
          class MeshBasicMaterial {
            constructor(parameters?: any);
          }
          
          class Mesh {
            constructor(geometry: Geometry, material: Material);
            position: Vector3;
            rotation: Euler;
          }
          
          class AmbientLight {
            constructor(color?: number, intensity?: number);
          }
          
          class DirectionalLight {
            constructor(color?: number, intensity?: number);
            position: Vector3;
          }
        }
      `, 'threejs.d.ts')
    }

    // Editor shortcuts
    editor.addCommand(monaco.KeyMod.CtrlCmd | monaco.KeyCode.KeyS, () => {
      // Save command - could trigger auto-save or download
      console.log('Save shortcut triggered')
    })

    editor.addCommand(monaco.KeyMod.CtrlCmd | monaco.KeyCode.Enter, () => {
      // Run command
      console.log('Run shortcut triggered')
    })
  }

  const editorOptions = {
    minimap: { enabled: false },
    scrollBeyondLastLine: false,
    fontFamily: 'JetBrains Mono, Consolas, Monaco, monospace',
    fontSize: 14,
    lineHeight: 20,
    tabSize: 2,
    insertSpaces: true,
    wordWrap: 'on' as const,
    automaticLayout: true,
    suggestOnTriggerCharacters: true,
    quickSuggestions: true,
    snippetSuggestions: 'top' as const,
    folding: true,
    foldingHighlight: true,
    bracketPairColorization: { enabled: true },
    guides: {
      bracketPairs: true,
      indentation: true
    },
    renderLineHighlight: 'line' as const,
    selectionHighlight: true,
    occurrencesHighlight: 'singleFile' as const,
    codeLens: false,
    contextmenu: true,
    mouseWheelZoom: true
  }

  return (
    <div className="h-full relative">
      {/* Library info header */}
      <div className="absolute top-0 left-0 right-0 z-10 bg-gray-100 dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700 px-4 py-2">
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-3">
            <span className="text-sm font-medium text-gray-900 dark:text-white">
              {library.name} v{library.version}
            </span>
            <span className="text-xs text-gray-500 dark:text-gray-400 bg-gray-200 dark:bg-gray-700 px-2 py-1 rounded">
              {language.toUpperCase()}
            </span>
          </div>
          <div className="text-xs text-gray-500 dark:text-gray-400">
            Press Ctrl+Enter to run
          </div>
        </div>
      </div>

      {/* Editor */}
      <div className="h-full pt-12">
        <Editor
          height="100%"
          language={language}
          value={value}
          onChange={(value) => onChange(value || '')}
          theme={theme === 'dark' ? 'vs-dark' : 'light'}
          options={editorOptions}
          onMount={handleEditorDidMount}
          loading={
            <div className="flex items-center justify-center h-full">
              <div className="text-gray-500 dark:text-gray-400">Loading editor...</div>
            </div>
          }
        />
      </div>
    </div>
  )
}