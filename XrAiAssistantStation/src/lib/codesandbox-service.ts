interface DefineAPIOptions {
  files: Record<string, { code: string }>
  template: string
  dependencies?: Record<string, string>
  devDependencies?: Record<string, string>
}

interface SandboxResponse {
  sandbox_id: string
  url: string
}

export class CodeSandboxService {
  private static instance: CodeSandboxService
  private readonly API_BASE = 'https://codesandbox.io/api/v1'
  private apiKey: string | null = null
  
  public static getInstance(): CodeSandboxService {
    if (!CodeSandboxService.instance) {
      CodeSandboxService.instance = new CodeSandboxService()
    }
    return CodeSandboxService.instance
  }

  setApiKey(apiKey: string | null) {
    this.apiKey = apiKey
  }

  async createSandbox(options: DefineAPIOptions): Promise<string> {
    try {
      const headers: Record<string, string> = {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      }

      // Add authorization header if API key is available
      if (this.apiKey && this.apiKey.trim() !== '') {
        headers['Authorization'] = `Bearer ${this.apiKey}`
      }

      const response = await fetch(`${this.API_BASE}/sandboxes/define`, {
        method: 'POST',
        headers,
        body: JSON.stringify(options)
      })

      if (!response.ok) {
        throw new Error(`CodeSandbox API error: ${response.status} - ${response.statusText}`)
      }

      const data: SandboxResponse = await response.json()
      return `https://codesandbox.io/s/${data.sandbox_id}`
    } catch (error) {
      console.error('Failed to create CodeSandbox:', error)
      throw new Error(`Failed to create sandbox: ${error instanceof Error ? error.message : 'Unknown error'}`)
    }
  }
  
  generateR3FFiles(userCode: string, templateType: 'basic' | 'advanced' | 'vr' = 'basic'): DefineAPIOptions {
    const files: Record<string, { code: string }> = {
      'src/App.js': { 
        code: this.wrapR3FComponent(userCode) 
      },
      'src/index.js': { 
        code: this.getReactIndex() 
      },
      'package.json': { 
        code: JSON.stringify(this.getR3FDependencies(), null, 2) 
      },
      'public/index.html': {
        code: this.getIndexHTML('XRAiAssistant R3F Scene')
      }
    }

    // Add template-specific files
    if (templateType === 'advanced') {
      files['src/utils/helpers.js'] = { code: this.getR3FHelpers() }
      files['src/components/UI.js'] = { code: this.getR3FUI() }
    } else if (templateType === 'vr') {
      files['src/utils/xr-helpers.js'] = { code: this.getXRHelpers() }
    }

    return {
      files,
      template: 'create-react-app'
    }
  }

  generateReactFiles(userCode: string): DefineAPIOptions {
    return {
      files: {
        'src/App.js': { 
          code: userCode 
        },
        'src/index.js': { 
          code: this.getReactIndex() 
        },
        'package.json': { 
          code: JSON.stringify(this.getReactDependencies(), null, 2) 
        },
        'public/index.html': {
          code: this.getIndexHTML('XRAiAssistant React App')
        }
      },
      template: 'create-react-app'
    }
  }
  
  private wrapR3FComponent(userCode: string): string {
    // Check if userCode already has a complete App component
    if (userCode.includes('export default') && userCode.includes('Canvas')) {
      return userCode
    }

    // Check if userCode defines a component or is just JSX
    const hasComponentDefinition = userCode.includes('function ') || userCode.includes('const ') || userCode.includes('export')
    
    if (hasComponentDefinition) {
      // User code contains components, wrap in Canvas
      return `import React from 'react'
import { Canvas } from '@react-three/fiber'
import { OrbitControls, Environment, Stats } from '@react-three/drei'

${userCode}

export default function App() {
  return (
    <div style={{ width: '100vw', height: '100vh' }}>
      <Canvas 
        camera={{ position: [0, 0, 5], fov: 75 }}
        shadows
        dpr={[1, 2]}
      >
        <color attach="background" args={['#f0f0f0']} />
        <fog attach="fog" args={['#f0f0f0', 10, 50]} />
        
        {/* Lighting setup */}
        <ambientLight intensity={0.4} />
        <directionalLight 
          position={[10, 10, 5]} 
          intensity={1}
          castShadow
          shadow-mapSize={[1024, 1024]}
        />
        
        {/* User components */}
        <Scene />
        
        {/* Controls and helpers */}
        <OrbitControls makeDefault />
        <Environment preset="city" />
        <Stats />
      </Canvas>
    </div>
  )
}`
    } else {
      // User code is JSX elements, wrap in a Scene component
      return `import React, { useRef } from 'react'
import { Canvas, useFrame } from '@react-three/fiber'
import { OrbitControls, Environment, Stats } from '@react-three/drei'

function Scene() {
  return (
    <group>
      ${userCode}
    </group>
  )
}

export default function App() {
  return (
    <div style={{ width: '100vw', height: '100vh' }}>
      <Canvas 
        camera={{ position: [0, 0, 5], fov: 75 }}
        shadows
        dpr={[1, 2]}
      >
        <color attach="background" args={['#f0f0f0']} />
        <fog attach="fog" args={['#f0f0f0', 10, 50]} />
        
        {/* Lighting setup */}
        <ambientLight intensity={0.4} />
        <directionalLight 
          position={[10, 10, 5]} 
          intensity={1}
          castShadow
          shadow-mapSize={[1024, 1024]}
        />
        
        {/* User scene */}
        <Scene />
        
        {/* Controls and helpers */}
        <OrbitControls makeDefault />
        <Environment preset="city" />
        <Stats />
      </Canvas>
    </div>
  )
}`
    }
  }

  private getReactIndex(): string {
    return `import React from 'react'
import { createRoot } from 'react-dom/client'
import App from './App'

const container = document.getElementById('root')
const root = createRoot(container)

root.render(<App />)`
  }

  private getIndexHTML(title: string): string {
    return `<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="theme-color" content="#000000" />
    <meta name="description" content="Generated with XRAiAssistant" />
    <title>${title}</title>
  </head>
  <body>
    <noscript>You need to enable JavaScript to run this app.</noscript>
    <div id="root"></div>
  </body>
</html>`
  }
  
  private getR3FDependencies() {
    return {
      name: 'xraiassistant-r3f-scene',
      version: '1.0.0',
      description: 'React Three Fiber scene generated with XRAiAssistant',
      dependencies: {
        '@react-three/fiber': '^8.17.10',
        '@react-three/drei': '^9.109.0',
        '@react-three/postprocessing': '^2.16.2',
        'react': '^18.2.0',
        'react-dom': '^18.2.0',
        'three': '^0.171.0',
        'leva': '^0.9.35',
        'zustand': '^4.4.7'
      },
      scripts: {
        start: 'react-scripts start',
        build: 'react-scripts build',
        test: 'react-scripts test',
        eject: 'react-scripts eject'
      },
      browserslist: {
        production: ['>0.2%', 'not dead', 'not op_mini all'],
        development: ['last 1 chrome version', 'last 1 firefox version', 'last 1 safari version']
      }
    }
  }

  private getReactDependencies() {
    return {
      name: 'xraiassistant-react-app',
      version: '1.0.0',
      description: 'React app generated with XRAiAssistant',
      dependencies: {
        'react': '^18.2.0',
        'react-dom': '^18.2.0'
      },
      scripts: {
        start: 'react-scripts start',
        build: 'react-scripts build',
        test: 'react-scripts test',
        eject: 'react-scripts eject'
      },
      browserslist: {
        production: ['>0.2%', 'not dead', 'not op_mini all'],
        development: ['last 1 chrome version', 'last 1 firefox version', 'last 1 safari version']
      }
    }
  }

  generateEmbedCode(sandboxUrl: string): string {
    const sandboxId = this.extractSandboxId(sandboxUrl)
    if (!sandboxId) {
      throw new Error('Invalid sandbox URL')
    }

    return `<iframe 
  src="https://codesandbox.io/embed/${sandboxId}" 
  width="100%" 
  height="500px" 
  title="XRAiAssistant Generated Scene"
  allow="accelerometer; ambient-light-sensor; camera; encrypted-media; geolocation; gyroscope; hid; microphone; midi; payment; usb; vr; xr-spatial-tracking"
  sandbox="allow-forms allow-modals allow-popups allow-presentation allow-same-origin allow-scripts"
></iframe>`
  }

  private extractSandboxId(sandboxUrl: string): string | null {
    const match = sandboxUrl.match(/codesandbox\.io\/s\/([a-zA-Z0-9-]+)/)
    return match ? match[1] : null
  }

  async shareToSocialMedia(sandboxUrl: string, platform: 'twitter' | 'linkedin'): Promise<void> {
    const message = this.generateSocialMessage(sandboxUrl, platform)
    const shareUrl = this.buildShareUrl(platform, message, sandboxUrl)
    window.open(shareUrl, '_blank', 'width=600,height=400')
  }

  private generateSocialMessage(sandboxUrl: string, platform: string): string {
    const baseMessage = "Check out this 3D scene I created with XRAiAssistant! 🚀"
    const hashtags = "#XRAiAssistant #ReactThreeFiber #WebXR #AI #3D"
    
    return platform === 'twitter' 
      ? `${baseMessage} ${sandboxUrl} ${hashtags}`
      : `${baseMessage}\n\nCreated with AI-powered XR development tools.\n\n${sandboxUrl}\n\n${hashtags}`
  }

  private buildShareUrl(platform: string, message: string, url: string): string {
    const encodedMessage = encodeURIComponent(message)
    const encodedUrl = encodeURIComponent(url)

    switch (platform) {
      case 'twitter':
        return `https://twitter.com/intent/tweet?text=${encodedMessage}`
      case 'linkedin':
        return `https://www.linkedin.com/sharing/share-offsite/?url=${encodedUrl}&summary=${encodedMessage}`
      default:
        throw new Error(`Unsupported platform: ${platform}`)
    }
  }

  private getR3FHelpers(): string {
    return `import { useRef, useEffect } from 'react'
import { useFrame, useThree } from '@react-three/fiber'
import * as THREE from 'three'

// Custom hooks for React Three Fiber
export function useRotation(speed = 1) {
  const ref = useRef()
  useFrame((state, delta) => {
    if (ref.current) {
      ref.current.rotation.x += delta * speed
      ref.current.rotation.y += delta * speed * 0.5
    }
  })
  return ref
}

export function useMousePosition() {
  const { viewport, camera } = useThree()
  const ref = useRef()
  
  useFrame((state) => {
    if (ref.current) {
      const x = (state.mouse.x * viewport.width) / 2
      const y = (state.mouse.y * viewport.height) / 2
      ref.current.position.set(x, y, 0)
    }
  })
  
  return ref
}

export function usePulse(min = 0.5, max = 1.5, speed = 2) {
  const ref = useRef()
  useFrame((state) => {
    if (ref.current) {
      const scale = min + (max - min) * (Math.sin(state.clock.elapsedTime * speed) + 1) / 2
      ref.current.scale.setScalar(scale)
    }
  })
  return ref
}

// Utility functions
export const colors = {
  primary: '#4f46e5',
  secondary: '#06b6d4',
  accent: '#f59e0b',
  success: '#10b981',
  warning: '#f59e0b',
  error: '#ef4444'
}

export function randomPosition(range = 5) {
  return [
    (Math.random() - 0.5) * range,
    (Math.random() - 0.5) * range,
    (Math.random() - 0.5) * range
  ]
}

export function randomColor() {
  return new THREE.Color().setHSL(Math.random(), 0.7, 0.6)
}`
  }

  private getR3FUI(): string {
    return `import React from 'react'
import { Html } from '@react-three/drei'

export function FloatingUI({ position = [0, 2, 0], children }) {
  return (
    <Html position={position} center>
      <div style={{
        background: 'rgba(0, 0, 0, 0.8)',
        color: 'white',
        padding: '10px 15px',
        borderRadius: '8px',
        fontSize: '14px',
        fontFamily: 'Arial, sans-serif',
        minWidth: '120px',
        textAlign: 'center',
        backdropFilter: 'blur(10px)',
        border: '1px solid rgba(255, 255, 255, 0.1)'
      }}>
        {children}
      </div>
    </Html>
  )
}

export function PerformanceMonitor() {
  return (
    <Html position={[-4, 3, 0]} transform={false}>
      <div style={{
        position: 'fixed',
        top: '10px',
        left: '10px',
        background: 'rgba(0, 0, 0, 0.7)',
        color: '#00ff00',
        padding: '8px',
        borderRadius: '4px',
        fontFamily: 'monospace',
        fontSize: '12px',
        zIndex: 1000
      }}>
        <div>FPS: {Math.round(performance.now() / 16.67) || 60}</div>
        <div>Objects: Auto-detected</div>
      </div>
    </Html>
  )
}

export function Instructions({ children }) {
  return (
    <Html position={[0, -3, 0]} center>
      <div style={{
        background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
        color: 'white',
        padding: '15px 20px',
        borderRadius: '12px',
        fontSize: '16px',
        fontFamily: 'Arial, sans-serif',
        maxWidth: '300px',
        textAlign: 'center',
        boxShadow: '0 8px 32px rgba(0, 0, 0, 0.3)',
        border: '1px solid rgba(255, 255, 255, 0.2)'
      }}>
        {children}
      </div>
    </Html>
  )
}`
  }

  private getXRHelpers(): string {
    return `import { useXR } from '@react-three/xr'
import { useFrame } from '@react-three/fiber'
import { useRef } from 'react'

// XR-specific hooks and utilities
export function useXRControllers() {
  const { controllers } = useXR()
  return controllers
}

export function useXRHands() {
  const { hands } = useXR()
  return hands
}

export function useXRRaycast() {
  const ref = useRef()
  const { controllers } = useXR()
  
  useFrame(() => {
    if (controllers.length > 0 && ref.current) {
      // Basic raycast implementation
      const controller = controllers[0]
      if (controller) {
        // Ray casting logic would go here
        console.log('XR Controller detected')
      }
    }
  })
  
  return ref
}

// VR-optimized components
export function VRTeleport() {
  return (
    <mesh position={[0, -1, 0]} rotation={[-Math.PI / 2, 0, 0]}>
      <planeGeometry args={[50, 50]} />
      <meshStandardMaterial color="#4ade80" transparent opacity={0.8} />
    </mesh>
  )
}

export function VRPointer({ controller }) {
  return (
    <group>
      <mesh position={[0, 0, -2]}>
        <cylinderGeometry args={[0.01, 0.01, 4]} />
        <meshBasicMaterial color="#ff6b6b" />
      </mesh>
    </group>
  )
}

// XR Environment presets
export const XREnvironments = {
  space: {
    background: '#000011',
    fog: ['#000011', 50, 200],
    ambient: 0.1
  },
  underwater: {
    background: '#006994',
    fog: ['#006994', 10, 50],
    ambient: 0.3
  },
  forest: {
    background: '#2d5016',
    fog: ['#2d5016', 20, 80],
    ambient: 0.4
  }
}`
  }
}

export const codeSandboxService = CodeSandboxService.getInstance()