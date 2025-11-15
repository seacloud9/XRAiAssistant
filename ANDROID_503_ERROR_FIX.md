# Android 503 Service Unavailable Error - FIXED ✅

## Issue Summary

**Problem**: Together.ai API returning 503 Service Unavailable errors, causing chat requests to fail immediately with no retry logic.

**Error Log Evidence**:
```
2025-11-09 17:16:12.134  okhttp.OkHttpClient  <-- 503 https://api.together.xyz/v1/chat/completions (5377ms)
retry-after: 6
x-api-retries: 10

{
  "error": {
    "message": "Service unavailable",
    "type": "service_unavailable"
  }
}
```

## Root Cause

The Together.ai API backend was temporarily unavailable (503 error). The server already retried 10 times internally and instructed the client to retry after 6 seconds, but **the Android app had no retry logic implemented**, so it failed immediately.

**Important**: SSL configuration is working perfectly! The issue was not with the SSL changes, but with missing retry logic for transient API failures.

---

## Solution Implemented

### 1. Automatic Retry with Exponential Backoff

**File**: `XRAiAssistantAndroid/app/src/main/java/com/xraiassistant/data/remote/RealAIProviderService.kt`

**Changes**:
- ✅ Added retry loop with max 3 attempts (configurable via `MAX_RETRIES`)
- ✅ Respects server's `retry-after` header when provided
- ✅ Falls back to exponential backoff: 1s, 2s, 4s, 8s (capped at 30s)
- ✅ Retries on transient errors: 503, 429, 408, 500+ status codes
- ✅ Retries on network errors: SocketTimeout, SocketException, IOException
- ✅ Better user-facing error messages

**Retry Logic Flow**:
```kotlin
// Retry strategy
MAX_RETRIES = 3
INITIAL_RETRY_DELAY_MS = 1000L (1 second)
MAX_RETRY_DELAY_MS = 30000L (30 seconds)

Attempt 1 → 503 error → Wait 6s (from retry-after header) → Retry
Attempt 2 → 503 error → Wait 2s (exponential backoff) → Retry
Attempt 3 → 503 error → Wait 4s → Retry
Attempt 4 → Max retries exceeded → Show user-friendly error
```

**Retryable Errors**:
- `503 Service Unavailable` (Together.ai backend down)
- `429 Too Many Requests` (rate limiting)
- `408 Request Timeout`
- `500+` (server errors)
- Network timeouts and connection failures

**Non-Retryable Errors** (fail immediately):
- `401 Unauthorized` (bad API key)
- `400 Bad Request` (invalid input)
- `404 Not Found`
- SSL handshake failures (emulator certificate issues)

### 2. Helper Functions

**`isRetryableError(code: Int): Boolean`**
- Checks if HTTP status code warrants a retry

**`calculateRetryDelay(retryCount: Int, retryAfterSeconds: Int): Long`**
- Respects server's `retry-after` header
- Falls back to exponential backoff
- Caps delay at 30 seconds

### 3. Enhanced Logging

**Before**:
```
❌ Together.ai API error: 503 - {...}
```

**After**:
```
📡 Calling Together.ai API... (attempt 1/4)
❌ Together.ai API error: 503 - {...}
⏳ Service temporarily unavailable. Retrying in 6000ms...
📡 Calling Together.ai API... (attempt 2/4)
✅ Together.ai API response received, streaming chunks...
```

### 4. UI State for Status Messages

**File**: `XRAiAssistantAndroid/app/src/main/java/com/xraiassistant/ui/viewmodels/ChatViewModel.kt`

Added `statusMessage` StateFlow to display retry status in the UI:
```kotlin
private val _statusMessage = MutableStateFlow<String?>(null)
val statusMessage: StateFlow<String?> = _statusMessage.asStateFlow()
```

---

## Configuration

**Retry Settings** (in `RealAIProviderService.kt`):
```kotlin
companion object {
    private const val MAX_RETRIES = 3              // Total attempts = 4 (1 initial + 3 retries)
    private const val INITIAL_RETRY_DELAY_MS = 1000L  // 1 second
    private const val MAX_RETRY_DELAY_MS = 30000L     // 30 seconds max delay
}
```

**To adjust retry behavior**:
- Increase `MAX_RETRIES` for more resilience (e.g., 5 for slower networks)
- Increase `INITIAL_RETRY_DELAY_MS` for longer initial delays
- Increase `MAX_RETRY_DELAY_MS` to wait longer between retries

---

## Testing

### Test Scenario 1: Temporary API Outage
1. Send a chat message
2. Together.ai returns 503
3. **Expected**: App retries automatically 3 times with exponential backoff
4. **Logs**: Should show retry attempts with delays

### Test Scenario 2: API Recovers on Retry
1. Send a chat message
2. First attempt: 503 error
3. Second attempt: Success
4. **Expected**: User sees the response, unaware of the retry

### Test Scenario 3: Max Retries Exceeded
1. Send a chat message
2. All 4 attempts fail with 503
3. **Expected**: User sees error: "Together.ai service unavailable after 3 retries. Please try again later."

### Test Scenario 4: Rate Limiting (429)
1. Send multiple messages rapidly
2. API returns 429 with `retry-after: 60`
3. **Expected**: App waits 60 seconds before retrying

---

## Verification Checklist

✅ **SSL Working**: Certificate validation succeeds in logs
```
NetworkModule: ✅ Server certificate trusted: GENERIC, chain length: 3
NetworkModule: ✅ Hostname verified: api.together.xyz
```

✅ **Retry Logic Added**: Automatic retry on 503 errors

✅ **Exponential Backoff**: Progressive delays (1s, 2s, 4s, 8s)

✅ **Respects `retry-after` Header**: Uses server-provided delay when available

✅ **User-Friendly Errors**: Clear messages for different failure scenarios

✅ **Logging Enhanced**: Detailed logs for debugging retry attempts

---

## API Key Validation

**Before using the app**, ensure your Together.ai API key is configured:

1. Open app → Settings (gear icon)
2. Replace `"changeMe"` with your actual API key from https://api.together.ai/settings/api-keys
3. Verify the key has sufficient credits/quota

**Common API Key Issues**:
- ❌ `401 Unauthorized` → Invalid API key
- ❌ `403 Forbidden` → API key doesn't have access to model
- ❌ `429 Too Many Requests` → Rate limit exceeded (retries automatically)
- ❌ `503 Service Unavailable` → Backend temporarily down (retries automatically)

---

## Next Steps (Optional Enhancements)

### 1. Add Retry Status to UI
Display retry attempts in the chat UI:
```kotlin
// In ChatScreen.kt
viewModel.statusMessage.collectAsState().value?.let { status ->
    Text(
        text = status,
        color = MaterialTheme.colorScheme.secondary,
        fontSize = 12.sp
    )
}
```

### 2. Make Retry Settings Configurable
Add settings UI for:
- Max retries (slider: 0-10)
- Initial delay (slider: 1s-10s)
- Enable/disable auto-retry

### 3. Fallback to Different Model
If primary model fails after retries, automatically try an alternative:
```kotlin
// Pseudo-code
try {
    streamTogetherAI(model = "Qwen/Qwen2.5-Coder-32B-Instruct", ...)
} catch (e: MaxRetriesExceededException) {
    // Fallback to free model
    streamTogetherAI(model = "deepseek-ai/DeepSeek-R1-Distill-Llama-70B-free", ...)
}
```

### 4. Circuit Breaker Pattern
After N consecutive failures, temporarily disable API calls to prevent hammering:
```kotlin
if (consecutiveFailures >= 5) {
    // Wait 5 minutes before allowing requests again
    circuitBreakerOpenUntil = System.currentTimeMillis() + 300_000
}
```

---

## Summary

**Problem**: 503 errors caused immediate failures with no retry logic.

**Solution**:
1. ✅ Automatic retry with exponential backoff
2. ✅ Respects `retry-after` header
3. ✅ Retries 3 times before failing
4. ✅ User-friendly error messages
5. ✅ Enhanced logging for debugging

**Result**: The app is now resilient to transient API outages and will automatically retry failed requests, providing a better user experience.

**Note**: The SSL configuration changes you made are working perfectly. The 503 error was a legitimate server-side issue from Together.ai's backend, not a problem with your SSL setup.
