import { codeSandboxService } from './codesandbox-service'
import { copyToClipboard } from './utils'
import toast from 'react-hot-toast'

// Store reference for API key management
let globalApiKeys: Record<string, string> = {}

export interface ShareOptions {
  title?: string
  description?: string
  hashtags?: string[]
  via?: string
}

export interface ShareResult {
  success: boolean
  url?: string
  platform?: string
  error?: string
}

export class SharingService {
  private static instance: SharingService

  public static getInstance(): SharingService {
    if (!SharingService.instance) {
      SharingService.instance = new SharingService()
    }
    return SharingService.instance
  }

  setApiKeys(apiKeys: Record<string, string>) {
    globalApiKeys = apiKeys
    // Set CodeSandbox API key in the service
    codeSandboxService.setApiKey(apiKeys.codesandbox || null)
  }

  async shareCodeSandbox(
    code: string, 
    platform: 'twitter' | 'linkedin' | 'reddit' | 'discord' | 'copy' | 'email',
    options: ShareOptions = {}
  ): Promise<ShareResult> {
    try {
      // Validate inputs
      if (!code || code.trim().length === 0) {
        throw new Error('Code content is required for sharing')
      }

      if (!['twitter', 'linkedin', 'reddit', 'discord', 'copy', 'email'].includes(platform)) {
        throw new Error(`Unsupported platform: ${platform}`)
      }

      // Create CodeSandbox first with retry logic
      let sandboxUrl: string
      let retryCount = 0
      const maxRetries = 3

      while (retryCount < maxRetries) {
        try {
          const sandboxOptions = codeSandboxService.generateR3FFiles(code)
          sandboxUrl = await codeSandboxService.createSandbox(sandboxOptions)
          break
        } catch (error) {
          retryCount++
          if (retryCount >= maxRetries) {
            throw new Error(`Failed to create sandbox after ${maxRetries} attempts: ${error instanceof Error ? error.message : 'Unknown error'}`)
          }
          
          // Wait before retrying (exponential backoff)
          await new Promise(resolve => setTimeout(resolve, Math.pow(2, retryCount) * 1000))
        }
      }

      // Generate share content
      const shareContent = this.generateShareContent(sandboxUrl!, platform, options)

      // Handle different sharing platforms
      switch (platform) {
        case 'twitter':
          return this.shareToTwitter(shareContent)
        case 'linkedin':
          return this.shareToLinkedIn(shareContent)
        case 'reddit':
          return this.shareToReddit(shareContent)
        case 'discord':
          return this.shareToDiscord(shareContent)
        case 'copy':
          return this.copyToClipboard(shareContent)
        case 'email':
          return this.shareViaEmail(shareContent)
        default:
          throw new Error(`Unsupported platform: ${platform}`)
      }
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error occurred'
      console.error('Sharing service error:', error)
      
      return {
        success: false,
        error: errorMessage,
        platform
      }
    }
  }

  generateEmbedCode(sandboxUrl: string, options: {
    width?: string
    height?: string
    theme?: 'dark' | 'light'
    view?: 'editor' | 'preview' | 'split'
  } = {}): string {
    const sandboxId = this.extractSandboxId(sandboxUrl)
    if (!sandboxId) {
      throw new Error('Invalid CodeSandbox URL')
    }

    const {
      width = '100%',
      height = '500px',
      theme = 'dark',
      view = 'split'
    } = options

    const embedUrl = new URL(`https://codesandbox.io/embed/${sandboxId}`)
    embedUrl.searchParams.set('theme', theme)
    embedUrl.searchParams.set('view', view)
    embedUrl.searchParams.set('codemirror', '1')

    return `<iframe
  src="${embedUrl.toString()}"
  width="${width}"
  height="${height}"
  title="XRAiAssistant React Three Fiber Scene"
  allow="accelerometer; ambient-light-sensor; camera; encrypted-media; geolocation; gyroscope; hid; microphone; midi; payment; usb; vr; xr-spatial-tracking"
  sandbox="allow-forms allow-modals allow-popups allow-presentation allow-same-origin allow-scripts"
  style="width: ${width}; height: ${height}; border: 0; border-radius: 8px; overflow: hidden;"
></iframe>`
  }

  generateMarkdownEmbed(sandboxUrl: string, title = 'XRAiAssistant Scene'): string {
    return `## ${title}

Created with [XRAiAssistant](https://github.com/seacloud9/XRAiAssistant) - AI-powered React Three Fiber development.

[🚀 Open in CodeSandbox](${sandboxUrl})

${this.generateEmbedCode(sandboxUrl, { height: '400px' })}

### Tech Stack
- React Three Fiber
- @react-three/drei
- Three.js
- AI-generated content

---
*Built with XRAiAssistant - The future of XR development* ✨`
  }

  private generateShareContent(
    sandboxUrl: string, 
    platform: string, 
    options: ShareOptions
  ): ShareContent {
    const defaultTitle = "Check out this interactive 3D scene! 🚀"
    const defaultDescription = "Created with XRAiAssistant - AI-powered React Three Fiber development"
    const defaultHashtags = ['XRAiAssistant', 'ReactThreeFiber', 'WebXR', 'AI', 'ThreeJS', '3D']

    const title = options.title || defaultTitle
    const description = options.description || defaultDescription
    const hashtags = options.hashtags || defaultHashtags
    const via = options.via || 'XRAiAssistant'

    return {
      title,
      description,
      url: sandboxUrl,
      hashtags,
      via,
      fullMessage: this.buildFullMessage(title, description, sandboxUrl, hashtags, platform)
    }
  }

  private buildFullMessage(
    title: string,
    description: string,
    url: string,
    hashtags: string[],
    platform: string
  ): string {
    const hashtagString = hashtags.map(tag => `#${tag}`).join(' ')
    
    switch (platform) {
      case 'twitter':
        // Twitter has character limits, keep it concise
        return `${title}\n\n${url}\n\n${hashtagString}`
      
      case 'linkedin':
        return `${title}\n\n${description}\n\n🔗 Try it live: ${url}\n\n${hashtagString}`
      
      case 'reddit':
        return `**${title}**\n\n${description}\n\n**Live Demo:** ${url}\n\nTags: ${hashtagString}`
      
      case 'discord':
        return `🚀 **${title}**\n${description}\n\n**Live Demo:** ${url}\n\n${hashtagString}`
      
      case 'email':
        return `Subject: ${title}\n\nHi!\n\n${description}\n\nCheck it out here: ${url}\n\nThis was created using XRAiAssistant, an AI-powered tool for React Three Fiber development.\n\n${hashtagString}`
      
      default:
        return `${title}\n\n${description}\n\n${url}\n\n${hashtagString}`
    }
  }

  private async shareToTwitter(content: ShareContent): Promise<ShareResult> {
    const tweetUrl = new URL('https://twitter.com/intent/tweet')
    tweetUrl.searchParams.set('text', content.fullMessage)
    
    window.open(tweetUrl.toString(), '_blank', 'width=600,height=400')
    
    return {
      success: true,
      url: content.url,
      platform: 'twitter'
    }
  }

  private async shareToLinkedIn(content: ShareContent): Promise<ShareResult> {
    const linkedInUrl = new URL('https://www.linkedin.com/sharing/share-offsite/')
    linkedInUrl.searchParams.set('url', content.url)
    linkedInUrl.searchParams.set('title', content.title)
    linkedInUrl.searchParams.set('summary', content.description)
    
    window.open(linkedInUrl.toString(), '_blank', 'width=600,height=500')
    
    return {
      success: true,
      url: content.url,
      platform: 'linkedin'
    }
  }

  private async shareToReddit(content: ShareContent): Promise<ShareResult> {
    const redditUrl = new URL('https://reddit.com/submit')
    redditUrl.searchParams.set('url', content.url)
    redditUrl.searchParams.set('title', content.title)
    
    window.open(redditUrl.toString(), '_blank', 'width=700,height=600')
    
    return {
      success: true,
      url: content.url,
      platform: 'reddit'
    }
  }

  private async shareToDiscord(content: ShareContent): Promise<ShareResult> {
    // Discord doesn't have a direct share URL, so we copy to clipboard
    await copyToClipboard(content.fullMessage)
    toast.success('Message copied to clipboard! Paste it in Discord.')
    
    return {
      success: true,
      url: content.url,
      platform: 'discord'
    }
  }

  private async copyToClipboard(content: ShareContent): Promise<ShareResult> {
    const shareText = `${content.title}\n\n${content.description}\n\n🔗 ${content.url}\n\n${content.hashtags.map(tag => `#${tag}`).join(' ')}`
    
    await copyToClipboard(shareText)
    toast.success('Share content copied to clipboard!')
    
    return {
      success: true,
      url: content.url,
      platform: 'copy'
    }
  }

  private async shareViaEmail(content: ShareContent): Promise<ShareResult> {
    const subject = encodeURIComponent(content.title)
    const body = encodeURIComponent(content.fullMessage.replace('Subject: ' + content.title + '\n\n', ''))
    
    const emailUrl = `mailto:?subject=${subject}&body=${body}`
    window.location.href = emailUrl
    
    return {
      success: true,
      url: content.url,
      platform: 'email'
    }
  }

  private extractSandboxId(sandboxUrl: string): string | null {
    const match = sandboxUrl.match(/codesandbox\.io\/s\/([a-zA-Z0-9-]+)/)
    return match ? match[1] : null
  }

  // Utility methods for different content formats
  generateShareableLinks(sandboxUrl: string) {
    return {
      codeplay: sandboxUrl,
      embed: sandboxUrl.replace('/s/', '/embed/'),
      preview: sandboxUrl + '?view=preview',
      editor: sandboxUrl + '?view=editor',
      fullscreen: sandboxUrl + '?view=preview&hidenavigation=1'
    }
  }

  generateQRCode(sandboxUrl: string): string {
    // Generate QR code URL using a free service
    return `https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${encodeURIComponent(sandboxUrl)}`
  }

  generateSocialPreview(sandboxUrl: string): SocialPreview {
    const sandboxId = this.extractSandboxId(sandboxUrl)
    
    return {
      title: 'Interactive 3D Scene - XRAiAssistant',
      description: 'AI-generated React Three Fiber scene with interactive elements and professional lighting.',
      image: `https://codesandbox.io/api/v1/sandboxes/${sandboxId}/screenshot.png`,
      url: sandboxUrl,
      type: 'website',
      siteName: 'CodeSandbox'
    }
  }
}

interface ShareContent {
  title: string
  description: string
  url: string
  hashtags: string[]
  via: string
  fullMessage: string
}

interface SocialPreview {
  title: string
  description: string
  image: string
  url: string
  type: string
  siteName: string
}

export const sharingService = SharingService.getInstance()