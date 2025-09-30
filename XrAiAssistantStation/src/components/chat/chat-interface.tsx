'use client'

import { useState, useRef, useEffect } from 'react'
import { Send, Loader2, Code, Copy, Download } from 'lucide-react'
import { useAppStore } from '@/store/app-store'
import { AIService } from '@/lib/ai-service'
import { extractCodeFromMessage, copyToClipboard, downloadTextFile } from '@/lib/utils'
import { ChatMessage } from './chat-message'
import toast from 'react-hot-toast'

export function ChatInterface() {
  const {
    messages,
    addMessage,
    isLoading,
    setLoading,
    settings,
    getCurrentLibrary,
    getCurrentProvider,
    getCurrentModel,
    setCurrentCode,
    setCurrentView
  } = useAppStore()
  
  const [input, setInput] = useState('')
  const messagesEndRef = useRef<HTMLDivElement>(null)
  const inputRef = useRef<HTMLTextAreaElement>(null)
  const aiService = AIService.getInstance()

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' })
  }, [messages])

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!input.trim() || isLoading) return

    const userMessage = input.trim()
    setInput('')
    
    // Add user message
    addMessage({
      role: 'user',
      content: userMessage
    })

    const provider = getCurrentProvider()
    const model = getCurrentModel()
    const library = getCurrentLibrary()

    if (!provider || !model) {
      toast.error('Please configure AI provider and model in settings')
      return
    }

    const apiKey = settings.apiKeys[provider.id]
    if (!apiKey || apiKey.trim() === '') {
      toast.error(`Please set your ${provider.name} API key in settings`)
      return
    }

    setLoading(true)

    try {
      // Build enhanced prompt with library context
      let enhancedPrompt = userMessage
      
      if (library) {
        enhancedPrompt = `${library.systemPrompt}\n\nUser request: ${userMessage}`
        
        // Add library context
        enhancedPrompt += `\n\nLibrary: ${library.name} v${library.version}`
        enhancedPrompt += `\nDescription: ${library.description}`
        
        // Add code template if generating new code
        if (userMessage.toLowerCase().includes('create') || userMessage.toLowerCase().includes('make') || userMessage.toLowerCase().includes('generate')) {
          enhancedPrompt += `\n\nUse this as a starting template:\n\`\`\`javascript\n${library.codeTemplate}\n\`\`\``
        }
      }

      // Add placeholder for streaming response
      const assistantMessageId = `msg_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
      addMessage({
        role: 'assistant',
        content: '',
        library: library?.id,
        hasCode: false
      })

      let streamedContent = ''
      
      await aiService.generateStreamingResponse(enhancedPrompt, {
        provider: provider.id,
        model: model.id,
        apiKey,
        temperature: settings.temperature,
        topP: settings.topP,
        systemPrompt: settings.systemPrompt
      }, (chunk) => {
        if (!chunk.done) {
          streamedContent += chunk.content
          
          // Update the last message with streamed content
          const updatedMessages = [...useAppStore.getState().messages]
          const lastMessageIndex = updatedMessages.length - 1
          if (lastMessageIndex >= 0 && updatedMessages[lastMessageIndex].role === 'assistant') {
            updatedMessages[lastMessageIndex] = {
              ...updatedMessages[lastMessageIndex],
              content: streamedContent,
              hasCode: extractCodeFromMessage(streamedContent) !== null
            }
            useAppStore.setState({ messages: updatedMessages })
          }
        }
      })

      // Final update
      const hasCode = extractCodeFromMessage(streamedContent) !== null

      // Auto-extract and set code if found
      if (hasCode) {
        const extractedCode = extractCodeFromMessage(streamedContent)
        if (extractedCode) {
          setCurrentCode(extractedCode)
          toast.success('Code extracted and ready to run!')
        }
      }

    } catch (error) {
      console.error('AI API Error:', error)
      const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred'
      
      addMessage({
        role: 'assistant',
        content: `Sorry, I encountered an error: ${errorMessage}\n\nPlease check your API key and try again.`
      })
      
      toast.error(`AI Error: ${errorMessage}`)
    } finally {
      setLoading(false)
    }
  }

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      handleSubmit(e as any)
    }
  }

  const handleCodeExtract = (content: string) => {
    const code = extractCodeFromMessage(content)
    if (code) {
      setCurrentCode(code)
      setCurrentView('playground')
      toast.success('Code sent to playground!')
    } else {
      toast.error('No code found in this message')
    }
  }

  const handleCopyMessage = async (content: string) => {
    const success = await copyToClipboard(content)
    if (success) {
      toast.success('Message copied to clipboard')
    } else {
      toast.error('Failed to copy message')
    }
  }

  const handleDownloadCode = (content: string) => {
    const code = extractCodeFromMessage(content)
    if (code) {
      const library = getCurrentLibrary()
      const extension = library?.id === 'react-three-fiber' ? 'jsx' : 'js'
      downloadTextFile(code, `scene.${extension}`)
      toast.success('Code downloaded!')
    } else {
      toast.error('No code found to download')
    }
  }

  const currentLibrary = getCurrentLibrary()
  const currentModel = getCurrentModel()

  return (
    <div className="flex flex-col h-full">
      {/* Messages */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        {messages.length === 0 ? (
          <div className="flex flex-col items-center justify-center h-full text-center">
            <div className="w-16 h-16 bg-gradient-to-br from-blue-500 to-purple-600 rounded-full flex items-center justify-center mb-4">
              <span className="text-white font-bold text-xl">XR</span>
            </div>
            <h2 className="text-2xl font-bold text-gray-900 dark:text-white mb-2">
              Welcome to XRAiAssistant Station
            </h2>
            <p className="text-gray-600 dark:text-gray-400 mb-6 max-w-md">
              Start creating amazing 3D experiences with AI assistance. 
              Ask me to create scenes, explain concepts, or help with debugging.
            </p>
            
            {currentLibrary && (
              <div className="bg-blue-50 dark:bg-blue-900/20 rounded-lg p-4 max-w-md">
                <h3 className="font-semibold text-blue-900 dark:text-blue-100 mb-2">
                  Current Library: {currentLibrary.name} v{currentLibrary.version}
                </h3>
                <p className="text-sm text-blue-700 dark:text-blue-200">
                  {currentLibrary.description}
                </p>
              </div>
            )}
          </div>
        ) : (
          <>
            {messages.map((message) => (
              <ChatMessage
                key={message.id}
                message={message}
                onExtractCode={() => handleCodeExtract(message.content)}
                onCopy={() => handleCopyMessage(message.content)}
                onDownload={() => handleDownloadCode(message.content)}
              />
            ))}
            
            {isLoading && (
              <div className="flex items-center space-x-2 text-gray-600 dark:text-gray-400">
                <Loader2 size={16} className="animate-spin" />
                <span className="text-sm">
                  {currentModel?.name} is thinking...
                </span>
              </div>
            )}
          </>
        )}
        <div ref={messagesEndRef} />
      </div>

      {/* Input */}
      <div className="p-4 border-t border-gray-200 dark:border-gray-700">
        <form onSubmit={handleSubmit} className="flex items-end space-x-3">
          <div className="flex-1 relative">
            <textarea
              ref={inputRef}
              value={input}
              onChange={(e) => setInput(e.target.value)}
              onKeyDown={handleKeyDown}
              placeholder={`Ask me to create a 3D scene with ${currentLibrary?.name || '3D library'}...`}
              className="w-full p-3 pr-12 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400 resize-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              rows={Math.min(Math.max(input.split('\n').length, 1), 4)}
              disabled={isLoading}
            />
            
            {currentLibrary && (
              <div className="absolute bottom-3 right-3">
                <div className="text-xs text-gray-400 bg-gray-100 dark:bg-gray-700 px-2 py-1 rounded">
                  {currentLibrary.name}
                </div>
              </div>
            )}
          </div>
          
          <button
            type="submit"
            disabled={!input.trim() || isLoading}
            className="p-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          >
            {isLoading ? (
              <Loader2 size={20} className="animate-spin" />
            ) : (
              <Send size={20} />
            )}
          </button>
        </form>
        
        {currentModel && (
          <div className="mt-2 text-xs text-gray-500 dark:text-gray-400 text-center">
            Using {currentModel.name} • Temperature: {settings.temperature} • Top-p: {settings.topP}
          </div>
        )}
      </div>
    </div>
  )
}