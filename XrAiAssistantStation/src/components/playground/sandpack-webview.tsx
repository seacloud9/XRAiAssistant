'use client'

import { useState, useEffect, useRef } from 'react'
import { 
  SandpackProvider, 
  SandpackCodeEditor, 
  SandpackPreview,
  SandpackConsole,
  SandpackLayout 
} from "@codesandbox/sandpack-react"
import { Share, ExternalLink, Eye, EyeOff, Terminal, TerminalSquare, Copy, Mail, MessageCircle } from 'lucide-react'
import { codeSandboxService } from '@/lib/codesandbox-service'
import { sharingService } from '@/lib/sharing-service'
import { copyToClipboard } from '@/lib/utils'
import { SandpackErrorBoundary, useErrorHandler } from './error-boundary'
import { useAppStore } from '@/store/app-store'
import toast from 'react-hot-toast'

interface SandpackWebViewProps {
  initialCode: string
  framework: 'react' | 'react-three-fiber'
  onCodeChange?: (code: string) => void
  onSandboxCreated?: (sandboxUrl: string) => void
  showConsole?: boolean
  showPreview?: boolean
  autoReload?: boolean
}

export function SandpackWebView({ 
  initialCode, 
  framework, 
  onCodeChange, 
  onSandboxCreated,
  showConsole = false,
  showPreview = true,
  autoReload = true 
}: SandpackWebViewProps) {
  const [files, setFiles] = useState<Record<string, string>>({})
  const [template, setTemplate] = useState<string>('react')
  const [dependencies, setDependencies] = useState<Record<string, string>>({})
  const [localShowConsole, setLocalShowConsole] = useState(showConsole)
  const [localShowPreview, setLocalShowPreview] = useState(showPreview)
  const [isCreatingSandbox, setIsCreatingSandbox] = useState(false)
  const [showShareMenu, setShowShareMenu] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [isRetrying, setIsRetrying] = useState(false)
  const shareMenuRef = useRef<HTMLDivElement>(null)
  const handleError = useErrorHandler()
  const { settings } = useAppStore()

  // Initialize sharing service with API keys
  useEffect(() => {
    sharingService.setApiKeys(settings.apiKeys)
    // Also initialize CodeSandbox service with API key
    codeSandboxService.setApiKey(settings.apiKeys.codesandbox || null)
  }, [settings.apiKeys])
  
  useEffect(() => {
    try {
      setError(null) // Clear any previous errors
      
      if (framework === 'react-three-fiber') {
        const r3fFiles = codeSandboxService.generateR3FFiles(initialCode)
        const filesObj: Record<string, string> = {}
        
        Object.entries(r3fFiles.files).forEach(([path, fileData]) => {
          if (!fileData || !fileData.code) {
            throw new Error(`Invalid file data for ${path}`)
          }
          filesObj[path] = fileData.code
        })
        
        setFiles(filesObj)
        setTemplate('create-react-app')
        
        const deps = codeSandboxService.generateR3FFiles(initialCode)
        const packageJson = JSON.parse(deps.files['package.json'].code)
        setDependencies(packageJson.dependencies || {})
      } else {
        // Standard React setup
        const reactFiles = codeSandboxService.generateReactFiles(initialCode)
        const filesObj: Record<string, string> = {}
        
        Object.entries(reactFiles.files).forEach(([path, fileData]) => {
          if (!fileData || !fileData.code) {
            throw new Error(`Invalid file data for ${path}`)
          }
          filesObj[path] = fileData.code
        })
        
        setFiles(filesObj)
        setTemplate('create-react-app')
        
        const packageJson = JSON.parse(reactFiles.files['package.json'].code)
        setDependencies(packageJson.dependencies || {})
      }
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error'
      handleError(error as Error, 'Sandpack initialization')
      setError(`Failed to setup code environment: ${errorMessage}`)
      toast.error('Failed to initialize code environment')
    }
  }, [initialCode, framework])

  // Close share menu when clicking outside
  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (shareMenuRef.current && !shareMenuRef.current.contains(event.target as Node)) {
        setShowShareMenu(false)
      }
    }

    if (showShareMenu) {
      document.addEventListener('mousedown', handleClickOutside)
      return () => document.removeEventListener('mousedown', handleClickOutside)
    }
  }, [showShareMenu])

  const retryInitialization = () => {
    setIsRetrying(true)
    setError(null)
    
    setTimeout(() => {
      setIsRetrying(false)
      // Re-trigger the useEffect by changing a dependency
      const currentCode = initialCode
      if (currentCode) {
        // Force re-initialization
        window.location.reload()
      }
    }, 1000)
  }
  
  const handleCodeChange = (code: string) => {
    onCodeChange?.(code)
    if (autoReload) {
      // Update files state to trigger Sandpack reload
      setFiles(prev => ({
        ...prev,
        'src/App.js': code
      }))
    }
  }
  
  const handleCreateSandbox = async () => {
    if (isCreatingSandbox) return
    
    setIsCreatingSandbox(true)
    try {
      const options = framework === 'react-three-fiber' 
        ? codeSandboxService.generateR3FFiles(files['src/App.js'] || initialCode)
        : codeSandboxService.generateReactFiles(files['src/App.js'] || initialCode)
      
      const sandboxUrl = await codeSandboxService.createSandbox(options)
      onSandboxCreated?.(sandboxUrl)
      
      await copyToClipboard(sandboxUrl)
      toast.success('Sandbox created! URL copied to clipboard.')
    } catch (error) {
      console.error('Failed to create sandbox:', error)
      toast.error(`Failed to create sandbox: ${error instanceof Error ? error.message : 'Unknown error'}`)
    } finally {
      setIsCreatingSandbox(false)
    }
  }

  const handleShareToSocial = async (platform: 'twitter' | 'linkedin' | 'reddit' | 'discord' | 'copy' | 'email') => {
    if (isCreatingSandbox) return
    
    try {
      setIsCreatingSandbox(true)
      const currentCode = files['src/App.js'] || initialCode
      
      const result = await sharingService.shareCodeSandbox(currentCode, platform, {
        title: `Interactive ${framework === 'react-three-fiber' ? 'React Three Fiber' : 'React'} Scene`,
        description: 'Created with XRAiAssistant - AI-powered 3D development',
        hashtags: ['XRAiAssistant', 'ReactThreeFiber', 'WebXR', 'AI', '3D']
      })
      
      if (result.success) {
        onSandboxCreated?.(result.url || '')
        toast.success(`Successfully shared to ${platform}!`)
      } else {
        toast.error(result.error || 'Failed to share')
      }
      
      setShowShareMenu(false)
    } catch (error) {
      console.error('Failed to share to social media:', error)
      toast.error(`Failed to share: ${error instanceof Error ? error.message : 'Unknown error'}`)
    } finally {
      setIsCreatingSandbox(false)
    }
  }
  
  // Error state rendering
  if (error) {
    return (
      <div className="h-full flex flex-col items-center justify-center p-8 bg-red-50 dark:bg-red-900/20">
        <div className="text-center max-w-md">
          <div className="w-16 h-16 mx-auto mb-4 bg-red-100 dark:bg-red-900/40 rounded-full flex items-center justify-center">
            <span className="text-red-600 dark:text-red-400 text-2xl">⚠️</span>
          </div>
          <h3 className="text-lg font-semibold text-red-800 dark:text-red-200 mb-2">
            Sandpack Error
          </h3>
          <p className="text-red-600 dark:text-red-300 mb-4 text-sm">
            {error}
          </p>
          <div className="space-y-2">
            <button
              onClick={retryInitialization}
              disabled={isRetrying}
              className="px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors text-sm"
            >
              {isRetrying ? (
                <>
                  <div className="inline-block w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin mr-2"></div>
                  Retrying...
                </>
              ) : (
                'Retry'
              )}
            </button>
            <p className="text-xs text-red-500 dark:text-red-400">
              If the problem persists, try refreshing the page or check the browser console for more details.
            </p>
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="h-full flex flex-col">
      {/* Toolbar */}
      <div className="flex items-center justify-between p-3 bg-gray-100 dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700">
        <div className="flex items-center space-x-2">
          <span className="text-sm font-medium text-gray-700 dark:text-gray-300">
            {framework === 'react-three-fiber' ? 'React Three Fiber' : 'React'} Sandbox
          </span>
          {framework === 'react-three-fiber' && (
            <span className="px-2 py-1 text-xs bg-purple-100 dark:bg-purple-900 text-purple-700 dark:text-purple-300 rounded">
              R3F
            </span>
          )}
          <span className="px-2 py-1 text-xs bg-blue-100 dark:bg-blue-900 text-blue-700 dark:text-blue-300 rounded">
            Sandpack Live
          </span>
        </div>
        
        <div className="flex items-center space-x-2">
          <button
            onClick={() => setLocalShowConsole(!localShowConsole)}
            className="flex items-center space-x-1 px-3 py-1 text-sm rounded bg-gray-200 dark:bg-gray-700 hover:bg-gray-300 dark:hover:bg-gray-600 transition-colors"
            title={localShowConsole ? 'Hide Console' : 'Show Console'}
          >
            {localShowConsole ? <TerminalSquare size={14} /> : <Terminal size={14} />}
            <span>{localShowConsole ? 'Hide' : 'Console'}</span>
          </button>

          <button
            onClick={() => setLocalShowPreview(!localShowPreview)}
            className="flex items-center space-x-1 px-3 py-1 text-sm rounded bg-gray-200 dark:bg-gray-700 hover:bg-gray-300 dark:hover:bg-gray-600 transition-colors"
            title={localShowPreview ? 'Hide Preview' : 'Show Preview'}
          >
            {localShowPreview ? <EyeOff size={14} /> : <Eye size={14} />}
            <span>{localShowPreview ? 'Hide' : 'Preview'}</span>
          </button>
          
          <div className="w-px h-6 bg-gray-300 dark:bg-gray-600"></div>
          
          <button
            onClick={handleCreateSandbox}
            disabled={isCreatingSandbox}
            className="flex items-center space-x-1 px-3 py-1 text-sm rounded bg-blue-600 text-white hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          >
            {isCreatingSandbox ? (
              <>
                <div className="w-3 h-3 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                <span>Creating...</span>
              </>
            ) : (
              <>
                <ExternalLink size={14} />
                <span>Deploy</span>
              </>
            )}
          </button>

          <div className="relative" ref={shareMenuRef}>
            <button
              onClick={() => setShowShareMenu(!showShareMenu)}
              disabled={isCreatingSandbox}
              className="flex items-center space-x-1 px-3 py-1 text-sm rounded bg-green-600 text-white hover:bg-green-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              title="Share to social media"
            >
              <Share size={14} />
              <span>Share</span>
            </button>

            {showShareMenu && (
              <div className="absolute right-0 top-full mt-1 bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg shadow-lg z-50 min-w-48">
                <div className="py-1">
                  <button
                    onClick={() => handleShareToSocial('twitter')}
                    disabled={isCreatingSandbox}
                    className="w-full text-left px-3 py-2 text-sm hover:bg-gray-100 dark:hover:bg-gray-700 flex items-center space-x-2"
                  >
                    <ExternalLink size={14} className="text-sky-500" />
                    <span>Twitter</span>
                  </button>
                  <button
                    onClick={() => handleShareToSocial('linkedin')}
                    disabled={isCreatingSandbox}
                    className="w-full text-left px-3 py-2 text-sm hover:bg-gray-100 dark:hover:bg-gray-700 flex items-center space-x-2"
                  >
                    <ExternalLink size={14} className="text-blue-600" />
                    <span>LinkedIn</span>
                  </button>
                  <button
                    onClick={() => handleShareToSocial('reddit')}
                    disabled={isCreatingSandbox}
                    className="w-full text-left px-3 py-2 text-sm hover:bg-gray-100 dark:hover:bg-gray-700 flex items-center space-x-2"
                  >
                    <ExternalLink size={14} className="text-orange-500" />
                    <span>Reddit</span>
                  </button>
                  <button
                    onClick={() => handleShareToSocial('discord')}
                    disabled={isCreatingSandbox}
                    className="w-full text-left px-3 py-2 text-sm hover:bg-gray-100 dark:hover:bg-gray-700 flex items-center space-x-2"
                  >
                    <MessageCircle size={14} className="text-indigo-500" />
                    <span>Discord</span>
                  </button>
                  <div className="border-t border-gray-200 dark:border-gray-600 my-1"></div>
                  <button
                    onClick={() => handleShareToSocial('copy')}
                    disabled={isCreatingSandbox}
                    className="w-full text-left px-3 py-2 text-sm hover:bg-gray-100 dark:hover:bg-gray-700 flex items-center space-x-2"
                  >
                    <Copy size={14} className="text-gray-500" />
                    <span>Copy Link</span>
                  </button>
                  <button
                    onClick={() => handleShareToSocial('email')}
                    disabled={isCreatingSandbox}
                    className="w-full text-left px-3 py-2 text-sm hover:bg-gray-100 dark:hover:bg-gray-700 flex items-center space-x-2"
                  >
                    <Mail size={14} className="text-gray-500" />
                    <span>Email</span>
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
      
      {/* Sandpack Container */}
      <div className="flex-1 overflow-hidden">
        <SandpackErrorBoundary
          onError={(error, errorInfo) => {
            handleError(error, 'Sandpack runtime')
            console.error('Sandpack runtime error:', error, errorInfo)
          }}
        >
          <SandpackProvider
          template="react"
          files={files}
          customSetup={{
            dependencies
          }}
          options={{
            autorun: autoReload
          }}
          theme="auto"
        >
          <SandpackLayout>
            <SandpackCodeEditor 
              showTabs
              showLineNumbers
              showInlineErrors
              wrapContent
              closableTabs={false}
              style={{
                height: localShowConsole ? 'calc(100% - 200px)' : '100%'
              }}
            />
            
            {localShowPreview && (
              <SandpackPreview
                showRefreshButton
                showOpenInCodeSandbox
                style={{
                  height: localShowConsole ? 'calc(100% - 200px)' : '100%'
                }}
              />
            )}
          </SandpackLayout>
          
          {localShowConsole && (
            <div className="h-48 border-t border-gray-200 dark:border-gray-700">
              <SandpackConsole 
                showHeader
                showSyntaxError
                maxMessageCount={100}
              />
            </div>
          )}
        </SandpackProvider>
        </SandpackErrorBoundary>
      </div>
    </div>
  )
}