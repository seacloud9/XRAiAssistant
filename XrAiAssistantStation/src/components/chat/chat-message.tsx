'use client'

import { Bot, User, Code, Copy, Download, ExternalLink } from 'lucide-react'
import { ChatMessage as ChatMessageType } from '@/store/app-store'
import { formatTimestamp, extractCodeFromMessage } from '@/lib/utils'
import ReactMarkdown from 'react-markdown'
import { Prism as SyntaxHighlighter } from 'react-syntax-highlighter'
import { oneDark, oneLight } from 'react-syntax-highlighter/dist/cjs/styles/prism'
import { useTheme } from 'next-themes'

interface ChatMessageProps {
  message: ChatMessageType
  onExtractCode?: () => void
  onCopy?: () => void
  onDownload?: () => void
}

export function ChatMessage({ message, onExtractCode, onCopy, onDownload }: ChatMessageProps) {
  const { theme } = useTheme()
  const isUser = message.role === 'user'
  const hasCode = extractCodeFromMessage(message.content) !== null

  return (
    <div className={`flex gap-3 ${isUser ? 'flex-row-reverse' : 'flex-row'}`}>
      {/* Avatar */}
      <div className={`flex-shrink-0 w-8 h-8 rounded-full flex items-center justify-center ${
        isUser 
          ? 'bg-blue-600 text-white' 
          : 'bg-gray-200 dark:bg-gray-700 text-gray-600 dark:text-gray-300'
      }`}>
        {isUser ? <User size={16} /> : <Bot size={16} />}
      </div>

      {/* Message content */}
      <div className={`flex-1 max-w-[80%] ${isUser ? 'text-right' : 'text-left'}`}>
        <div className={`inline-block p-3 rounded-lg ${
          isUser
            ? 'bg-blue-600 text-white'
            : 'bg-gray-100 dark:bg-gray-800 text-gray-900 dark:text-white'
        }`}>
          {isUser ? (
            <p className="whitespace-pre-wrap">{message.content}</p>
          ) : (
            <div className="prose prose-sm dark:prose-invert max-w-none">
              <ReactMarkdown
                components={{
                  code({ className, children, ...props }: any) {
                    const match = /language-(\w+)/.exec(className || '')
                    const language = match ? match[1] : ''
                    const isInline = !props.node || props.node.tagName === 'code'
                    
                    if (!isInline && language) {
                      return (
                        <SyntaxHighlighter
                          style={theme === 'dark' ? oneDark : oneLight}
                          language={language}
                          PreTag="div"
                          {...props}
                        >
                          {String(children).replace(/\n$/, '')}
                        </SyntaxHighlighter>
                      )
                    }
                    
                    return (
                      <code className={className} {...props}>
                        {children}
                      </code>
                    )
                  }
                }}
              >
                {message.content}
              </ReactMarkdown>
            </div>
          )}
        </div>

        {/* Message metadata and actions */}
        <div className={`flex items-center gap-2 mt-1 text-xs text-gray-500 dark:text-gray-400 ${
          isUser ? 'justify-end' : 'justify-start'
        }`}>
          <span>{formatTimestamp(message.timestamp)}</span>
          
          {message.library && (
            <span className="bg-gray-200 dark:bg-gray-700 px-2 py-0.5 rounded">
              {message.library}
            </span>
          )}
          
          {!isUser && (
            <div className="flex items-center gap-1">
              {hasCode && (
                <button
                  onClick={onExtractCode}
                  className="p-1 hover:bg-gray-200 dark:hover:bg-gray-700 rounded transition-colors"
                  title="Send to playground"
                >
                  <Code size={12} />
                </button>
              )}
              
              {hasCode && (
                <button
                  onClick={onDownload}
                  className="p-1 hover:bg-gray-200 dark:hover:bg-gray-700 rounded transition-colors"
                  title="Download code"
                >
                  <Download size={12} />
                </button>
              )}
              
              <button
                onClick={onCopy}
                className="p-1 hover:bg-gray-200 dark:hover:bg-gray-700 rounded transition-colors"
                title="Copy message"
              >
                <Copy size={12} />
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}