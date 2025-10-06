import { create } from 'zustand'
import { persist } from 'zustand/middleware'

export type ViewType = 'chat' | 'playground'

export interface Library3D {
  id: string
  name: string
  version: string
  description: string
  cdnUrls: string[]
  systemPrompt: string
  codeTemplate: string
}

export interface AIProvider {
  id: string
  name: string
  baseUrl: string
  models: Array<{
    id: string
    name: string
    description: string
    pricing: string
  }>
}

export interface ChatMessage {
  id: string
  role: 'user' | 'assistant'
  content: string
  timestamp: number
  library?: string
  hasCode?: boolean
}

export interface AppSettings {
  apiKeys: Record<string, string>
  selectedProvider: string
  selectedModel: string
  selectedLibrary: string
  temperature: number
  topP: number
  systemPrompt: string
  theme: 'light' | 'dark' | 'system'
}

interface AppState {
  // View state
  currentView: ViewType
  setCurrentView: (view: ViewType) => void
  
  // Chat state
  messages: ChatMessage[]
  isLoading: boolean
  addMessage: (message: Omit<ChatMessage, 'id' | 'timestamp'>) => void
  setLoading: (loading: boolean) => void
  clearMessages: () => void
  
  // Code state
  currentCode: string
  setCurrentCode: (code: string) => void
  
  // Settings state
  settings: AppSettings
  updateSettings: (settings: Partial<AppSettings>) => void
  
  // Library state
  libraries: Library3D[]
  setLibraries: (libraries: Library3D[]) => void
  getCurrentLibrary: () => Library3D | undefined
  
  // AI Provider state
  providers: AIProvider[]
  setProviders: (providers: AIProvider[]) => void
  getCurrentProvider: () => AIProvider | undefined
  getCurrentModel: () => AIProvider['models'][0] | undefined
}

// Default libraries
const defaultLibraries: Library3D[] = [
  {
    id: 'babylonjs',
    name: 'Babylon.js',
    version: '8.22.3',
    description: 'Professional WebGL engine for 3D graphics',
    cdnUrls: [
      'https://cdn.babylonjs.com/babylon.js',
      'https://cdn.babylonjs.com/loaders/babylonjs.loaders.min.js'
    ],
    systemPrompt: `You are an expert Babylon.js v8.22.3 developer. Generate complete, working 3D scenes using modern Babylon.js APIs.

Key guidelines:
- Use BABYLON namespace for all classes
- Create scenes with proper camera, lighting, and materials
- Include proper disposal and cleanup
- Use modern ES6+ syntax
- Focus on performance and best practices
- Include helpful comments explaining key concepts`,
    codeTemplate: `// Babylon.js v8.22.3 Scene Template
const canvas = document.getElementById('renderCanvas');
const engine = new BABYLON.Engine(canvas, true);

const createScene = () => {
    const scene = new BABYLON.Scene(engine);
    
    // Camera
    const camera = new BABYLON.ArcRotateCamera("camera", -Math.PI / 2, Math.PI / 2.5, 10, BABYLON.Vector3.Zero(), scene);
    camera.attachToCanvas(canvas, true);
    
    // Light
    const light = new BABYLON.HemisphericLight("light", new BABYLON.Vector3(0, 1, 0), scene);
    light.intensity = 0.7;
    
    // Your code here
    
    return scene;
};

const scene = createScene();
engine.runRenderLoop(() => {
    scene.render();
});

window.addEventListener('resize', () => {
    engine.resize();
});`
  },
  {
    id: 'threejs',
    name: 'Three.js',
    version: 'r171',
    description: 'Lightweight 3D library with WebGL renderer',
    cdnUrls: [
      'https://unpkg.com/three@0.171.0/build/three.min.js'
    ],
    systemPrompt: `You are an expert Three.js r171 developer. Generate complete, working 3D scenes using modern Three.js APIs.

Key guidelines:
- Use THREE namespace for all classes
- Create scenes with proper camera, lighting, and materials
- Include proper cleanup and disposal
- Use modern ES6+ syntax and modules when possible
- Focus on performance optimization
- Include helpful comments explaining key concepts`,
    codeTemplate: `// Three.js r171 Scene Template
const scene = new THREE.Scene();
const camera = new THREE.PerspectiveCamera(75, window.innerWidth / window.innerHeight, 0.1, 1000);
const renderer = new THREE.WebGLRenderer();

renderer.setSize(window.innerWidth, window.innerHeight);
document.body.appendChild(renderer.domElement);

// Lighting
const ambientLight = new THREE.AmbientLight(0x404040, 0.6);
scene.add(ambientLight);

const directionalLight = new THREE.DirectionalLight(0xffffff, 0.8);
directionalLight.position.set(1, 1, 1);
scene.add(directionalLight);

// Your code here

camera.position.z = 5;

function animate() {
    requestAnimationFrame(animate);
    
    // Animation code here
    
    renderer.render(scene, camera);
}

animate();

window.addEventListener('resize', () => {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(window.innerWidth, window.innerHeight);
});`
  },
  {
    id: 'react-three-fiber',
    name: 'React Three Fiber',
    version: '8.17.10',
    description: 'React renderer for Three.js with live Sandpack preview and CodeSandbox deployment',
    cdnUrls: [
      'https://unpkg.com/three@0.171.0/build/three.min.js',
      'https://unpkg.com/@react-three/fiber@8.17.10/dist/index.esm.js'
    ],
    systemPrompt: `You are an expert React Three Fiber developer. Generate complete, working 3D scenes using React Three Fiber and modern React patterns.

Key guidelines:
- Use React Three Fiber components and hooks (useFrame, useThree, useRef)
- Implement proper React patterns (hooks, refs, state, context)
- Include interactive elements (onClick, onPointerOver, animations)
- Use @react-three/drei helpers (OrbitControls, Environment, Html, useGLTF, etc.)
- Focus on component composition and reusability
- Include performance optimizations (useMemo, useCallback, instancing)
- Add proper lighting (ambientLight, directionalLight, spotLight)
- Implement smooth animations and transitions
- Use proper TypeScript when applicable
- Include helpful comments explaining React Three Fiber concepts
- Consider XR/VR compatibility when possible
- Use modern Three.js patterns and geometries
- Implement responsive design for different screen sizes`,
    codeTemplate: `import React, { useRef, useState, useMemo } from 'react'
import { Canvas, useFrame } from '@react-three/fiber'
import { OrbitControls, Environment, Stats, Html } from '@react-three/drei'
import * as THREE from 'three'

function InteractiveCube({ position = [0, 0, 0] }) {
  const meshRef = useRef()
  const [hovered, setHover] = useState(false)
  const [active, setActive] = useState(false)

  // Smooth rotation animation
  useFrame((state, delta) => {
    if (meshRef.current) {
      meshRef.current.rotation.x += delta * 0.5
      meshRef.current.rotation.y += delta * 0.2
      
      // Gentle floating motion
      meshRef.current.position.y = position[1] + Math.sin(state.clock.elapsedTime) * 0.1
    }
  })

  // Memoized material for performance
  const material = useMemo(() => 
    new THREE.MeshStandardMaterial({ 
      color: hovered ? '#ff6b6b' : active ? '#4ecdc4' : '#45b7d1',
      roughness: 0.4,
      metalness: 0.8
    }), [hovered, active])

  return (
    <group position={position}>
      <mesh
        ref={meshRef}
        scale={active ? 1.3 : hovered ? 1.1 : 1}
        onClick={() => setActive(!active)}
        onPointerOver={() => setHover(true)}
        onPointerOut={() => setHover(false)}
        castShadow
        receiveShadow
        material={material}
      >
        <boxGeometry args={[1, 1, 1]} />
      </mesh>
      
      {/* Interactive label */}
      {hovered && (
        <Html position={[0, 1.5, 0]} center>
          <div style={{
            background: 'rgba(0,0,0,0.8)',
            color: 'white',
            padding: '8px 12px',
            borderRadius: '6px',
            fontSize: '14px'
          }}>
            {active ? 'Active!' : 'Click me!'}
          </div>
        </Html>
      )}
    </group>
  )
}

function Scene() {
  return (
    <>
      {/* Multiple interactive cubes */}
      <InteractiveCube position={[-2, 0, 0]} />
      <InteractiveCube position={[0, 0, 0]} />
      <InteractiveCube position={[2, 0, 0]} />
      
      {/* Ground plane */}
      <mesh position={[0, -2, 0]} rotation={[-Math.PI / 2, 0, 0]} receiveShadow>
        <planeGeometry args={[10, 10]} />
        <meshStandardMaterial color="#f0f0f0" />
      </mesh>
    </>
  )
}

export default function App() {
  return (
    <div style={{ width: '100vw', height: '100vh' }}>
      <Canvas
        camera={{ position: [5, 3, 5], fov: 60 }}
        shadows
        dpr={[1, 2]}
      >
        {/* Background and atmosphere */}
        <color attach="background" args={['#f0f8ff']} />
        <fog attach="fog" args={['#f0f8ff', 5, 20]} />
        
        {/* Lighting setup */}
        <ambientLight intensity={0.4} />
        <directionalLight
          position={[10, 10, 5]}
          intensity={1}
          castShadow
          shadow-mapSize={[1024, 1024]}
          shadow-camera-far={50}
          shadow-camera-left={-10}
          shadow-camera-right={10}
          shadow-camera-top={10}
          shadow-camera-bottom={-10}
        />
        <pointLight position={[-10, 0, -20]} color="#4ecdc4" intensity={0.5} />
        
        {/* Scene content */}
        <Scene />
        
        {/* Controls and environment */}
        <OrbitControls 
          makeDefault 
          enablePan={true}
          enableZoom={true}
          enableRotate={true}
          minDistance={3}
          maxDistance={20}
        />
        <Environment preset="city" />
        
        {/* Performance monitoring */}
        <Stats />
      </Canvas>
    </div>
  )
}`
  }
]

// Default AI providers
const defaultProviders: AIProvider[] = [
  {
    id: 'together',
    name: 'Together AI',
    baseUrl: 'https://api.together.xyz/v1',
    models: [
      {
        id: 'deepseek-ai/DeepSeek-R1-Distill-Llama-70B-free',
        name: 'DeepSeek R1 70B',
        description: 'Advanced reasoning model (FREE)',
        pricing: 'Free'
      },
      {
        id: 'meta-llama/Llama-3.3-70B-Instruct-Turbo',
        name: 'Llama 3.3 70B',
        description: 'Latest Meta large model (FREE)',
        pricing: 'Free'
      },
      {
        id: 'meta-llama/Llama-3-8B-Instruct-Lite',
        name: 'Llama 3 8B Lite',
        description: 'Fast and efficient model',
        pricing: '$0.10/1M tokens'
      },
      {
        id: 'Qwen/Qwen2.5-7B-Instruct-Turbo',
        name: 'Qwen 2.5 7B Turbo',
        description: 'Fast coding specialist',
        pricing: '$0.30/1M tokens'
      },
      {
        id: 'Qwen/Qwen2.5-Coder-32B-Instruct',
        name: 'Qwen 2.5 Coder 32B',
        description: 'Advanced coding & XR specialist',
        pricing: '$0.80/1M tokens'
      }
    ]
  },
  {
    id: 'openai',
    name: 'OpenAI',
    baseUrl: 'https://api.openai.com/v1',
    models: [
      {
        id: 'gpt-4o',
        name: 'GPT-4o',
        description: 'Most capable multimodal model',
        pricing: '$5.00/1M tokens'
      },
      {
        id: 'gpt-4o-mini',
        name: 'GPT-4o Mini',
        description: 'Fast and affordable model',
        pricing: '$0.15/1M tokens'
      }
    ]
  },
  {
    id: 'anthropic',
    name: 'Anthropic',
    baseUrl: 'https://api.anthropic.com',
    models: [
      {
        id: 'claude-3-5-sonnet-20241022',
        name: 'Claude 3.5 Sonnet',
        description: 'Most capable model for complex tasks',
        pricing: '$3.00/1M tokens'
      },
      {
        id: 'claude-3-haiku-20240307',
        name: 'Claude 3 Haiku',
        description: 'Fast and affordable model',
        pricing: '$0.25/1M tokens'
      }
    ]
  },
  {
    id: 'codesandbox',
    name: 'CodeSandbox',
    baseUrl: 'https://codesandbox.io/api/v1',
    models: [
      {
        id: 'sandbox-deployment',
        name: 'Sandbox Deployment',
        description: 'Deploy React Three Fiber scenes to CodeSandbox',
        pricing: 'Free (with optional API key for advanced features)'
      }
    ]
  }
]

const defaultSettings: AppSettings = {
  apiKeys: {
    together: 'changeMe',
    openai: '',
    anthropic: '',
    codesandbox: ''
  },
  selectedProvider: 'together',
  selectedModel: 'deepseek-ai/DeepSeek-R1-Distill-Llama-70B-free',
  selectedLibrary: 'react-three-fiber',
  temperature: 0.7,
  topP: 0.9,
  systemPrompt: '',
  theme: 'system'
}

export const useAppStore = create<AppState>()(
  persist(
    (set, get) => ({
      // View state
      currentView: 'chat',
      setCurrentView: (view) => set({ currentView: view }),
      
      // Chat state
      messages: [],
      isLoading: false,
      addMessage: (message) => set((state) => ({
        messages: [...state.messages, {
          ...message,
          id: Math.random().toString(36).substr(2, 9),
          timestamp: Date.now()
        }]
      })),
      setLoading: (loading) => set({ isLoading: loading }),
      clearMessages: () => set({ messages: [] }),
      
      // Code state
      currentCode: '',
      setCurrentCode: (code) => set({ currentCode: code }),
      
      // Settings state
      settings: defaultSettings,
      updateSettings: (newSettings) => set((state) => ({
        settings: { ...state.settings, ...newSettings }
      })),
      
      // Library state
      libraries: defaultLibraries,
      setLibraries: (libraries) => set({ libraries }),
      getCurrentLibrary: () => {
        const { libraries, settings } = get()
        return libraries.find(lib => lib.id === settings.selectedLibrary)
      },
      
      // AI Provider state
      providers: defaultProviders,
      setProviders: (providers) => set({ providers }),
      getCurrentProvider: () => {
        const { providers, settings } = get()
        return providers.find(provider => provider.id === settings.selectedProvider)
      },
      getCurrentModel: () => {
        const { providers, settings } = get()
        const provider = providers.find(p => p.id === settings.selectedProvider)
        return provider?.models.find(m => m.id === settings.selectedModel)
      }
    }),
    {
      name: 'xrai-assistant-storage',
      partialize: (state) => ({
        settings: state.settings,
        messages: state.messages,
        currentCode: state.currentCode,
        libraries: state.libraries,
        providers: state.providers
      })
    }
  )
)