# Claude 4.5 Quick Reference Card 📋

## Model IDs (Copy-Paste Ready)

```kotlin
// Latest Anthropic models (2025)
"claude-sonnet-4-5-20250929"  // Recommended - Best balance
"claude-opus-4-1-20250805"    // Most powerful
"claude-haiku-4-5-20251001"   // Fastest/cheapest
```

---

## Quick Comparison

| Model | Speed | Quality | Input Cost | Output Cost | Best For |
|-------|-------|---------|------------|-------------|----------|
| **Haiku 4.5** | ⚡⚡⚡ | ⭐⭐⭐ | $1/1M | $5/1M | Quick tasks, high volume |
| **Sonnet 4.5** | ⚡⚡ | ⭐⭐⭐⭐⭐ | $3/1M | $15/1M | General coding (default) |
| **Opus 4.1** | ⚡ | ⭐⭐⭐⭐⭐⭐ | $15/1M | $75/1M | Complex reasoning |

---

## Basic API Request

```kotlin
val request = AnthropicRequest(
    model = "claude-sonnet-4-5-20250929",
    messages = listOf(
        APIChatMessage(role = "user", content = "Create a 3D cube")
    ),
    temperature = 0.7,
    topP = null,  // IMPORTANT: Claude 4.5+ only accepts temperature OR top_p, not both!
    stream = true,
    maxTokens = 4096,
    system = "You are a Babylon.js expert"
)
```

⚠️ **Important**: Claude 4.5+ models don't allow both `temperature` and `top_p`. Always set `topP = null`.

---

## Extended Thinking (Optional)

**When to use**: Complex coding, debugging, multi-step reasoning

```kotlin
val request = AnthropicRequest(
    model = "claude-sonnet-4-5-20250929",
    messages = messages,
    maxTokens = 16000,  // Higher for thinking
    thinking = AnthropicRequest.ThinkingConfig(
        type = "enabled",
        budgetTokens = 10000  // Max thinking tokens
    )
)
```

**Rules**:
- `budget_tokens` ≥ 1,024
- `budget_tokens` < `max_tokens`
- Increases cost (thinking uses input pricing)

---

## Cost Calculator

```
Input tokens × $rate/1M = Input cost
Output tokens × $rate/1M = Output cost
Thinking tokens × $input_rate/1M = Thinking cost

Total = Input + Output + Thinking
```

**Example** (Sonnet 4.5 with thinking):
```
5,000 input × $3/1M = $0.015
2,000 output × $15/1M = $0.030
3,000 thinking × $3/1M = $0.009
─────────────────────────────────
Total = $0.054
```

---

## Feature Matrix

|  | Haiku 4.5 | Sonnet 4.5 | Opus 4.1 |
|---|-----------|------------|----------|
| **Context** | 200K | 200K (1M beta) | 200K |
| **Streaming** | ✅ | ✅ | ✅ |
| **Extended Thinking** | ❌ | ✅ | ✅ |
| **Function Calling** | ❌ | ✅ | ✅ |
| **Vision** | ✅ | ✅ | ✅ |

---

## Common Use Cases

### 🎯 Babylon.js Scene Generation
**Model**: Sonnet 4.5 (default)
**Thinking**: No (unless complex)
**Expected tokens**: 500 input, 2000 output
**Cost**: ~$0.03

### 🔍 Code Debugging
**Model**: Sonnet 4.5
**Thinking**: Yes (`budget_tokens: 5000`)
**Expected tokens**: 1000 input, 1500 output, 3000 thinking
**Cost**: ~$0.04

### ⚡ Quick Snippets
**Model**: Haiku 4.5
**Thinking**: No
**Expected tokens**: 200 input, 500 output
**Cost**: ~$0.003

### 🧠 Complex Architecture
**Model**: Opus 4.1
**Thinking**: Yes (`budget_tokens: 10000`)
**Expected tokens**: 2000 input, 3000 output, 8000 thinking
**Cost**: ~$0.37

---

## Error Codes

| Code | Meaning | Solution |
|------|---------|----------|
| 401 | Invalid API key | Check key starts with `sk-ant-` |
| 403 | No access to model | Verify account has Claude 4.5 access |
| 429 | Rate limit | Wait & retry (auto-handled) |
| 503 | Service unavailable | Auto-retry (up to 3 times) |

---

## Testing Commands

### cURL (Basic)
```bash
curl -X POST "https://api.anthropic.com/v1/messages" \
  -H "x-api-key: sk-ant-YOUR_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-sonnet-4-5-20250929",
    "messages": [{"role": "user", "content": "Hello"}],
    "max_tokens": 1024
  }'
```

### cURL (With Thinking)
```bash
curl -X POST "https://api.anthropic.com/v1/messages" \
  -H "x-api-key: sk-ant-YOUR_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-sonnet-4-5-20250929",
    "messages": [{"role": "user", "content": "Complex problem..."}],
    "max_tokens": 16000,
    "thinking": {"type": "enabled", "budget_tokens": 10000}
  }'
```

---

## Kotlin Code Constants

```kotlin
object ClaudeModels {
    // Model IDs
    const val SONNET_4_5 = "claude-sonnet-4-5-20250929"
    const val OPUS_4_1 = "claude-opus-4-1-20250805"
    const val HAIKU_4_5 = "claude-haiku-4-5-20251001"

    // Pricing (per 1M tokens)
    object Pricing {
        val SONNET_INPUT = 3.0
        val SONNET_OUTPUT = 15.0
        val OPUS_INPUT = 15.0
        val OPUS_OUTPUT = 75.0
        val HAIKU_INPUT = 1.0
        val HAIKU_OUTPUT = 5.0
    }

    // Limits
    const val CONTEXT_WINDOW = 200_000
    const val MIN_THINKING_TOKENS = 1_024
    const val MAX_TOKENS_NO_STREAM = 21_333
}
```

---

## Decision Tree

```
Need AI response?
├─ Simple task (cube, basic scene)?
│  └─ Use Haiku 4.5 ⚡
├─ Complex coding (procedural, physics)?
│  ├─ Standard quality needed?
│  │  └─ Use Sonnet 4.5 (no thinking) ⭐
│  └─ Best quality needed?
│     └─ Use Sonnet 4.5 (with thinking) 🧠
└─ Research-level complexity?
   └─ Use Opus 4.1 (with thinking) 🚀
```

---

## Checklist for Production

- [ ] API key configured
- [ ] Default model set (Sonnet 4.5 recommended)
- [ ] Retry logic enabled (503 errors)
- [ ] Token usage monitoring
- [ ] Cost alerts configured
- [ ] Extended thinking toggle in UI (optional)
- [ ] User documentation updated
- [ ] Error messages user-friendly

---

## Links

- 📚 [Full Upgrade Guide](./ANDROID_CLAUDE_4_5_UPGRADE.md)
- 🌐 [Official Docs](https://docs.claude.com/en/docs/about-claude/models)
- 💰 [Pricing](https://anthropic.com/pricing)
- 🧪 [API Console](https://console.anthropic.com/)
