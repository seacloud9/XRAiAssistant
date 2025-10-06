'use client'

import React, { Component, ErrorInfo, ReactNode } from 'react'
import { RefreshCw, AlertTriangle, Home, MessageCircle } from 'lucide-react'

interface Props {
  children: ReactNode
  fallback?: ReactNode
  onError?: (error: Error, errorInfo: ErrorInfo) => void
}

interface State {
  hasError: boolean
  error: Error | null
  errorInfo: ErrorInfo | null
}

export class SandpackErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props)
    this.state = { hasError: false, error: null, errorInfo: null }
  }

  static getDerivedStateFromError(error: Error): State {
    return { hasError: true, error, errorInfo: null }
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('Sandpack Error Boundary caught an error:', error, errorInfo)
    
    this.setState({
      error,
      errorInfo
    })

    // Call optional error handler
    this.props.onError?.(error, errorInfo)

    // Log to external service in production
    if (process.env.NODE_ENV === 'production') {
      // Example: Send to error tracking service
      // errorTrackingService.log(error, errorInfo)
    }
  }

  handleRetry = () => {
    this.setState({ hasError: false, error: null, errorInfo: null })
  }

  handleReload = () => {
    window.location.reload()
  }

  render() {
    if (this.state.hasError) {
      // Fallback UI with detailed error information
      return this.props.fallback || (
        <div className="h-full flex flex-col items-center justify-center p-8 bg-red-50 dark:bg-red-900/20">
          <div className="text-center max-w-lg">
            <div className="w-20 h-20 mx-auto mb-6 bg-red-100 dark:bg-red-900/40 rounded-full flex items-center justify-center">
              <AlertTriangle className="w-10 h-10 text-red-600 dark:text-red-400" />
            </div>
            
            <h2 className="text-xl font-bold text-red-800 dark:text-red-200 mb-3">
              Sandpack Component Error
            </h2>
            
            <p className="text-red-600 dark:text-red-300 mb-4 text-sm leading-relaxed">
              The React Three Fiber preview encountered an unexpected error. 
              This might be due to invalid code syntax, missing dependencies, or a temporary issue.
            </p>

            {this.state.error && (
              <details className="mb-6 text-left">
                <summary className="cursor-pointer text-sm font-medium text-red-700 dark:text-red-300 hover:text-red-800 dark:hover:text-red-200 mb-2">
                  Error Details
                </summary>
                <div className="bg-red-100 dark:bg-red-900/30 p-3 rounded-lg text-xs font-mono text-red-800 dark:text-red-200 overflow-auto max-h-32">
                  <div className="font-semibold mb-1">Error:</div>
                  <div className="mb-2">{this.state.error.message}</div>
                  {this.state.errorInfo && (
                    <>
                      <div className="font-semibold mb-1">Component Stack:</div>
                      <div className="whitespace-pre-wrap">
                        {this.state.errorInfo.componentStack}
                      </div>
                    </>
                  )}
                </div>
              </details>
            )}

            <div className="flex flex-col sm:flex-row gap-3 justify-center">
              <button
                onClick={this.handleRetry}
                className="flex items-center justify-center space-x-2 px-4 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors text-sm font-medium"
              >
                <RefreshCw size={16} />
                <span>Retry Component</span>
              </button>
              
              <button
                onClick={this.handleReload}
                className="flex items-center justify-center space-x-2 px-4 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors text-sm font-medium"
              >
                <Home size={16} />
                <span>Reload Page</span>
              </button>
            </div>

            <div className="mt-6 p-4 bg-gray-100 dark:bg-gray-800 rounded-lg">
              <h3 className="font-semibold text-gray-800 dark:text-gray-200 mb-2 text-sm">
                Troubleshooting Tips:
              </h3>
              <ul className="text-xs text-gray-600 dark:text-gray-400 space-y-1 text-left">
                <li>• Check if your code has valid React Three Fiber syntax</li>
                <li>• Ensure all imports are correct and dependencies are available</li>
                <li>• Try simplifying your scene to isolate the issue</li>
                <li>• Check the browser console for additional error details</li>
                <li>• Switch to a different framework (Babylon.js/Three.js) temporarily</li>
              </ul>
            </div>

            <div className="mt-4 text-xs text-gray-500 dark:text-gray-500">
              <div className="flex items-center justify-center space-x-1">
                <MessageCircle size={12} />
                <span>Need help? This error has been logged for debugging.</span>
              </div>
            </div>
          </div>
        </div>
      )
    }

    return this.props.children
  }
}

// Higher-order component for easier usage
export function withErrorBoundary<P extends object>(
  Component: React.ComponentType<P>,
  errorBoundaryProps?: Omit<Props, 'children'>
) {
  const WrappedComponent = (props: P) => (
    <SandpackErrorBoundary {...errorBoundaryProps}>
      <Component {...props} />
    </SandpackErrorBoundary>
  )

  WrappedComponent.displayName = `withErrorBoundary(${Component.displayName || Component.name})`
  
  return WrappedComponent
}

// Hook for error reporting
export function useErrorHandler() {
  const handleError = React.useCallback((error: Error, context?: string) => {
    console.error(`Error in ${context || 'component'}:`, error)
    
    // In production, you might want to send this to an error tracking service
    if (process.env.NODE_ENV === 'production') {
      // Example: errorTrackingService.log(error, { context })
    }
  }, [])

  return handleError
}