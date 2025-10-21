import { type ClassValue, clsx } from 'clsx'
import { twMerge } from 'tailwind-merge'

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

export function formatTimestamp(timestamp: number): string {
  const date = new Date(timestamp)
  const now = new Date()
  
  // If it's today, show time
  if (date.toDateString() === now.toDateString()) {
    return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
  }
  
  // If it's this year, show month and day
  if (date.getFullYear() === now.getFullYear()) {
    return date.toLocaleDateString([], { month: 'short', day: 'numeric' })
  }
  
  // Otherwise show full date
  return date.toLocaleDateString([], { year: 'numeric', month: 'short', day: 'numeric' })
}

export function extractCodeFromMessage(content: string): string | null {
  // Look for code blocks with various languages (TRIPLE backticks only)
  // This regex is strict: matches ```language\ncode\n``` pattern
  const codeBlockRegex = /```(?:javascript|js|typescript|ts|jsx|tsx|html|css)?\s*\n([\s\S]*?)\n\s*```/g
  const match = codeBlockRegex.exec(content)
  
  if (match) {
    return match[1].trim()
  }
  
  // Fallback: try without language specifier but still require triple backticks
  const genericCodeBlockRegex = /```\s*\n([\s\S]*?)\n\s*```/g
  const genericMatch = genericCodeBlockRegex.exec(content)
  
  if (genericMatch) {
    return genericMatch[1].trim()
  }
  
  // DO NOT extract inline code (single backticks) for Monaco editor
  // Inline code like `const x = 5` is for display only, not execution
  
  return null
}

export function generateId(): string {
  return Math.random().toString(36).substr(2, 9)
}

export function debounce<T extends (...args: any[]) => any>(
  func: T,
  wait: number
): (...args: Parameters<T>) => void {
  let timeout: NodeJS.Timeout | null = null
  
  return (...args: Parameters<T>) => {
    if (timeout) clearTimeout(timeout)
    timeout = setTimeout(() => func(...args), wait)
  }
}

export function throttle<T extends (...args: any[]) => any>(
  func: T,
  limit: number
): (...args: Parameters<T>) => void {
  let inThrottle: boolean
  
  return (...args: Parameters<T>) => {
    if (!inThrottle) {
      func(...args)
      inThrottle = true
      setTimeout(() => (inThrottle = false), limit)
    }
  }
}

export function isValidUrl(string: string): boolean {
  try {
    new URL(string)
    return true
  } catch (_) {
    return false
  }
}

export function copyToClipboard(text: string): Promise<boolean> {
  if (navigator.clipboard && window.isSecureContext) {
    return navigator.clipboard.writeText(text).then(() => true).catch(() => false)
  } else {
    // Fallback for non-secure contexts
    const textArea = document.createElement('textarea')
    textArea.value = text
    textArea.style.position = 'absolute'
    textArea.style.left = '-999999px'
    document.body.appendChild(textArea)
    textArea.focus()
    textArea.select()
    
    try {
      document.execCommand('copy')
      textArea.remove()
      return Promise.resolve(true)
    } catch (error) {
      textArea.remove()
      return Promise.resolve(false)
    }
  }
}

export function downloadTextFile(content: string, filename: string): void {
  const blob = new Blob([content], { type: 'text/plain' })
  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = filename
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)
  URL.revokeObjectURL(url)
}

export function getParameterDescription(temperature: number, topP: number): string {
  switch (true) {
    case temperature >= 0.0 && temperature <= 0.3 && topP >= 0.1 && topP <= 0.5:
      return "Precise & Focused - Perfect for debugging"
    case temperature >= 0.4 && temperature <= 0.8 && topP >= 0.6 && topP <= 0.9:
      return "Balanced Creativity - Ideal for most scenes"
    case temperature >= 0.9 && temperature <= 2.0 && topP >= 0.9 && topP <= 1.0:
      return "Experimental Mode - Maximum innovation"
    default:
      return "Custom Configuration"
  }
}

export function validateApiKey(apiKey: string, provider: string): { isValid: boolean; message: string } {
  if (!apiKey || apiKey.trim() === '') {
    return { isValid: false, message: 'API key is required' }
  }
  
  if (apiKey === 'changeMe') {
    return { isValid: false, message: `Please replace "changeMe" with your actual ${provider} API key` }
  }
  
  // Basic format validation
  switch (provider) {
    case 'together':
      if (!apiKey.startsWith('sk-') || apiKey.length < 20) {
        return { isValid: false, message: 'Together AI key should start with "sk-" and be at least 20 characters' }
      }
      break
    case 'openai':
      if (!apiKey.startsWith('sk-') || apiKey.length < 20) {
        return { isValid: false, message: 'OpenAI key should start with "sk-" and be at least 20 characters' }
      }
      break
    case 'anthropic':
      if (!apiKey.startsWith('sk-ant-') || apiKey.length < 20) {
        return { isValid: false, message: 'Anthropic key should start with "sk-ant-" and be at least 20 characters' }
      }
      break
  }
  
  return { isValid: true, message: 'API key format looks valid' }
}