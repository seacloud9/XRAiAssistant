'use client'

import { useEffect, useRef, useState } from 'react'
import { AlertCircle, Loader2, Eye, EyeOff } from 'lucide-react'
import { Library3D } from '@/store/app-store'

interface SceneRendererProps {
  code: string
  library: Library3D
  isRunning: boolean
}

export function SceneRenderer({ code, library, isRunning }: SceneRendererProps) {
  const iframeRef = useRef<HTMLIFrameElement>(null)
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [isVisible, setIsVisible] = useState(true)

  useEffect(() => {
    if (isRunning && code && iframeRef.current) {
      executeCode()
    }
  }, [isRunning, code, library])

  const executeCode = () => {
    if (!iframeRef.current) return

    setIsLoading(true)
    setError(null)

    try {
      const iframe = iframeRef.current
      
      // Create the HTML content for the iframe
      const htmlContent = createSceneHTML(code, library)
      
      // Write the content to the iframe
      const doc = iframe.contentDocument || iframe.contentWindow?.document
      if (doc) {
        doc.open()
        doc.write(htmlContent)
        doc.close()
        
        // Listen for errors from the iframe
        iframe.contentWindow?.addEventListener('error', (event) => {
          setError(`Runtime Error: ${event.error?.message || event.message}`)
          setIsLoading(false)
        })
        
        // Listen for successful load
        iframe.onload = () => {
          setIsLoading(false)
        }
      }
    } catch (err) {
      setError(`Execution Error: ${err instanceof Error ? err.message : 'Unknown error'}`)
      setIsLoading(false)
    }
  }

  const createSceneHTML = (userCode: string, library: Library3D): string => {
    const cdnLinks = library.cdnUrls.map(url => `<script src="${url}"></script>`).join('\n')
    
    let setupCode = ''
    let wrapperCode = userCode

    // Library-specific setup
    switch (library.id) {
      case 'babylonjs':
        setupCode = `
          <canvas id="renderCanvas" style="width: 100%; height: 100%; display: block;"></canvas>
        `
        break
        
      case 'threejs':
        setupCode = `
          <div id="scene-container" style="width: 100%; height: 100%;"></div>
        `
        // Modify Three.js code to render in container
        wrapperCode = userCode.replace(
          'document.body.appendChild(renderer.domElement)',
          'document.getElementById("scene-container").appendChild(renderer.domElement)'
        )
        break
        
      case 'react-three-fiber':
        setupCode = `
          <div id="root" style="width: 100%; height: 100%;"></div>
          <script src="https://unpkg.com/react@18/umd/react.development.js"></script>
          <script src="https://unpkg.com/react-dom@18/umd/react-dom.development.js"></script>
        `
        // Wrap React code
        wrapperCode = `
          const { createElement: h, useState, useRef } = React;
          const { createRoot } = ReactDOM;
          
          ${userCode}
          
          const root = createRoot(document.getElementById('root'));
          root.render(h(App));
        `
        break
    }

    return `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${library.name} Scene</title>
    <style>
        body {
            margin: 0;
            padding: 0;
            overflow: hidden;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif;
        }
        
        #error-overlay {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            background: rgba(239, 68, 68, 0.95);
            color: white;
            padding: 1rem;
            z-index: 1000;
            font-family: monospace;
            font-size: 14px;
            line-height: 1.4;
            display: none;
        }
        
        #loading-overlay {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.8);
            color: white;
            display: flex;
            align-items: center;
            justify-content: center;
            z-index: 999;
            font-size: 18px;
        }
        
        canvas, #scene-container, #root {
            width: 100% !important;
            height: 100% !important;
            display: block;
        }
    </style>
</head>
<body>
    <div id="loading-overlay">
        <div>Loading ${library.name} scene...</div>
    </div>
    
    <div id="error-overlay"></div>
    
    ${setupCode}
    
    ${cdnLinks}
    
    <script>
        // Error handling
        window.addEventListener('error', function(e) {
            const errorDiv = document.getElementById('error-overlay');
            errorDiv.innerHTML = \`
                <strong>Error in ${library.name} scene:</strong><br>
                \${e.error?.message || e.message}<br>
                <small>Line: \${e.lineno}, Column: \${e.colno}</small>
            \`;
            errorDiv.style.display = 'block';
            document.getElementById('loading-overlay').style.display = 'none';
        });
        
        // Hide loading overlay after a delay
        setTimeout(() => {
            const loadingDiv = document.getElementById('loading-overlay');
            if (loadingDiv) loadingDiv.style.display = 'none';
        }, 2000);
        
        // User code
        try {
            ${wrapperCode}
        } catch (error) {
            const errorDiv = document.getElementById('error-overlay');
            errorDiv.innerHTML = \`
                <strong>JavaScript Error:</strong><br>
                \${error.message}<br>
                <small>\${error.stack}</small>
            \`;
            errorDiv.style.display = 'block';
            document.getElementById('loading-overlay').style.display = 'none';
        }
    </script>
</body>
</html>`
  }

  if (!code.trim()) {
    return (
      <div className="h-full flex items-center justify-center bg-gray-100 dark:bg-gray-800">
        <div className="text-center">
          <div className="w-16 h-16 bg-gray-300 dark:bg-gray-600 rounded-lg flex items-center justify-center mb-4 mx-auto">
            <Eye size={24} className="text-gray-500 dark:text-gray-400" />
          </div>
          <h3 className="text-lg font-medium text-gray-900 dark:text-white mb-2">
            No Code to Render
          </h3>
          <p className="text-gray-600 dark:text-gray-400 text-sm">
            Write some {library.name} code and click Run to see your 3D scene.
          </p>
        </div>
      </div>
    )
  }

  return (
    <div className="h-full relative bg-gray-100 dark:bg-gray-800">
      {/* Controls */}
      <div className="absolute top-3 right-3 z-10 flex items-center space-x-2">
        <button
          onClick={() => setIsVisible(!isVisible)}
          className="p-2 bg-black/20 hover:bg-black/30 text-white rounded-lg transition-colors backdrop-blur-sm"
          title={isVisible ? 'Hide scene' : 'Show scene'}
        >
          {isVisible ? <EyeOff size={16} /> : <Eye size={16} />}
        </button>
      </div>

      {/* Loading indicator */}
      {isLoading && (
        <div className="absolute inset-0 bg-black/50 flex items-center justify-center z-20">
          <div className="bg-white dark:bg-gray-800 rounded-lg p-4 flex items-center space-x-3">
            <Loader2 size={20} className="animate-spin text-blue-600" />
            <span className="text-gray-900 dark:text-white">
              Executing {library.name} code...
            </span>
          </div>
        </div>
      )}

      {/* Error display */}
      {error && (
        <div className="absolute top-3 left-3 right-16 bg-red-600 text-white p-3 rounded-lg z-20 max-h-32 overflow-y-auto">
          <div className="flex items-start space-x-2">
            <AlertCircle size={16} className="mt-0.5 flex-shrink-0" />
            <div className="text-sm">
              <div className="font-medium mb-1">Execution Error</div>
              <div className="opacity-90">{error}</div>
            </div>
          </div>
        </div>
      )}

      {/* Scene iframe */}
      {isVisible && (
        <iframe
          ref={iframeRef}
          className="w-full h-full border-0"
          title={`${library.name} Scene`}
          sandbox="allow-scripts allow-same-origin"
        />
      )}

      {/* Hidden state */}
      {!isVisible && (
        <div className="h-full flex items-center justify-center">
          <div className="text-center">
            <EyeOff size={48} className="text-gray-400 mx-auto mb-4" />
            <p className="text-gray-600 dark:text-gray-400">Scene hidden</p>
          </div>
        </div>
      )}
    </div>
  )
}