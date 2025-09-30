import { useAppStore } from '@/store/app-store'

export interface AIResponse {
  content: string
  model: string
  usage?: {
    prompt_tokens: number
    completion_tokens: number
    total_tokens: number
  }
}

export interface StreamingResponse {
  content: string
  done: boolean
}

export class AIService {
  private static instance: AIService
  
  public static getInstance(): AIService {
    if (!AIService.instance) {
      AIService.instance = new AIService()
    }
    return AIService.instance
  }

  async generateResponse(
    prompt: string,
    options: {
      provider: string
      model: string
      apiKey: string
      temperature?: number
      topP?: number
      systemPrompt?: string
      maxTokens?: number
    }
  ): Promise<AIResponse> {
    const { provider, model, apiKey, temperature = 0.7, topP = 0.9, systemPrompt = '', maxTokens = 2048 } = options

    if (!apiKey || apiKey.trim() === '') {
      throw new Error(`API key required for ${provider}`)
    }

    switch (provider) {
      case 'together':
        return this.callTogetherAI({ prompt, model, apiKey, temperature, topP, systemPrompt, maxTokens })
      case 'openai':
        return this.callOpenAI({ prompt, model, apiKey, temperature, topP, systemPrompt, maxTokens })
      case 'anthropic':
        return this.callAnthropic({ prompt, model, apiKey, temperature, topP, systemPrompt, maxTokens })
      default:
        throw new Error(`Unsupported AI provider: ${provider}`)
    }
  }

  async generateStreamingResponse(
    prompt: string,
    options: {
      provider: string
      model: string
      apiKey: string
      temperature?: number
      topP?: number
      systemPrompt?: string
      maxTokens?: number
    },
    onChunk: (chunk: StreamingResponse) => void
  ): Promise<void> {
    const { provider, model, apiKey, temperature = 0.7, topP = 0.9, systemPrompt = '', maxTokens = 2048 } = options

    if (!apiKey || apiKey.trim() === '') {
      throw new Error(`API key required for ${provider}`)
    }

    switch (provider) {
      case 'together':
        return this.streamTogetherAI({ prompt, model, apiKey, temperature, topP, systemPrompt, maxTokens }, onChunk)
      case 'openai':
        return this.streamOpenAI({ prompt, model, apiKey, temperature, topP, systemPrompt, maxTokens }, onChunk)
      case 'anthropic':
        return this.streamAnthropic({ prompt, model, apiKey, temperature, topP, systemPrompt, maxTokens }, onChunk)
      default:
        throw new Error(`Unsupported AI provider: ${provider}`)
    }
  }

  private async callTogetherAI(options: {
    prompt: string
    model: string
    apiKey: string
    temperature: number
    topP: number
    systemPrompt: string
    maxTokens: number
  }): Promise<AIResponse> {
    const { prompt, model, apiKey, temperature, topP, systemPrompt, maxTokens } = options

    const messages = []
    if (systemPrompt) {
      messages.push({ role: 'system', content: systemPrompt })
    }
    messages.push({ role: 'user', content: prompt })

    const response = await fetch('https://api.together.xyz/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`
      },
      body: JSON.stringify({
        model,
        messages,
        temperature,
        top_p: topP,
        max_tokens: maxTokens,
        stream: false
      })
    })

    if (!response.ok) {
      const error = await response.text()
      throw new Error(`Together AI API error: ${response.status} - ${error}`)
    }

    const data = await response.json()
    return {
      content: data.choices[0].message.content,
      model: data.model,
      usage: data.usage
    }
  }

  private async streamTogetherAI(
    options: {
      prompt: string
      model: string
      apiKey: string
      temperature: number
      topP: number
      systemPrompt: string
      maxTokens: number
    },
    onChunk: (chunk: StreamingResponse) => void
  ): Promise<void> {
    const { prompt, model, apiKey, temperature, topP, systemPrompt, maxTokens } = options

    const messages = []
    if (systemPrompt) {
      messages.push({ role: 'system', content: systemPrompt })
    }
    messages.push({ role: 'user', content: prompt })

    const response = await fetch('https://api.together.xyz/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`
      },
      body: JSON.stringify({
        model,
        messages,
        temperature,
        top_p: topP,
        max_tokens: maxTokens,
        stream: true
      })
    })

    if (!response.ok) {
      const error = await response.text()
      throw new Error(`Together AI API error: ${response.status} - ${error}`)
    }

    const reader = response.body?.getReader()
    if (!reader) {
      throw new Error('No response body reader available')
    }

    const decoder = new TextDecoder()
    let buffer = ''

    try {
      while (true) {
        const { done, value } = await reader.read()
        if (done) break

        buffer += decoder.decode(value, { stream: true })
        const lines = buffer.split('\n')
        buffer = lines.pop() || ''

        for (const line of lines) {
          if (line.startsWith('data: ')) {
            const data = line.slice(6).trim()
            if (data === '[DONE]') {
              onChunk({ content: '', done: true })
              return
            }

            try {
              const parsed = JSON.parse(data)
              const content = parsed.choices[0]?.delta?.content || ''
              if (content) {
                onChunk({ content, done: false })
              }
            } catch (e) {
              // Skip invalid JSON
            }
          }
        }
      }
    } finally {
      reader.releaseLock()
    }
  }

  private async callOpenAI(options: {
    prompt: string
    model: string
    apiKey: string
    temperature: number
    topP: number
    systemPrompt: string
    maxTokens: number
  }): Promise<AIResponse> {
    const { prompt, model, apiKey, temperature, topP, systemPrompt, maxTokens } = options

    const messages = []
    if (systemPrompt) {
      messages.push({ role: 'system', content: systemPrompt })
    }
    messages.push({ role: 'user', content: prompt })

    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`
      },
      body: JSON.stringify({
        model,
        messages,
        temperature,
        top_p: topP,
        max_tokens: maxTokens
      })
    })

    if (!response.ok) {
      const error = await response.text()
      throw new Error(`OpenAI API error: ${response.status} - ${error}`)
    }

    const data = await response.json()
    return {
      content: data.choices[0].message.content,
      model: data.model,
      usage: data.usage
    }
  }

  private async streamOpenAI(
    options: {
      prompt: string
      model: string
      apiKey: string
      temperature: number
      topP: number
      systemPrompt: string
      maxTokens: number
    },
    onChunk: (chunk: StreamingResponse) => void
  ): Promise<void> {
    // Similar to Together AI streaming but with OpenAI endpoint
    // Implementation would be very similar to streamTogetherAI
    throw new Error('OpenAI streaming not implemented yet')
  }

  private async callAnthropic(options: {
    prompt: string
    model: string
    apiKey: string
    temperature: number
    topP: number
    systemPrompt: string
    maxTokens: number
  }): Promise<AIResponse> {
    const { prompt, model, apiKey, temperature, topP, systemPrompt, maxTokens } = options

    const response = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`,
        'anthropic-version': '2023-06-01'
      },
      body: JSON.stringify({
        model,
        max_tokens: maxTokens,
        temperature,
        top_p: topP,
        system: systemPrompt,
        messages: [{ role: 'user', content: prompt }]
      })
    })

    if (!response.ok) {
      const error = await response.text()
      throw new Error(`Anthropic API error: ${response.status} - ${error}`)
    }

    const data = await response.json()
    return {
      content: data.content[0].text,
      model: data.model,
      usage: data.usage
    }
  }

  private async streamAnthropic(
    options: {
      prompt: string
      model: string
      apiKey: string
      temperature: number
      topP: number
      systemPrompt: string
      maxTokens: number
    },
    onChunk: (chunk: StreamingResponse) => void
  ): Promise<void> {
    // Similar streaming implementation for Anthropic
    throw new Error('Anthropic streaming not implemented yet')
  }
}