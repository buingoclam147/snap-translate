# Translation Debugging Improvements

## Problem
Translation requests were failing, but logs were unclear:
- Showed generic "HTTP error" without status code
- No details about which provider failed and why
- No specific error messages (rate limit? parse error? network error?)
- Hard to debug what went wrong

## Solution
Added detailed logging at each stage of the translation pipeline, including:
- HTTP status codes (200, 429, 403, 503, etc.)
- Response body when errors occur
- Provider-specific error messages
- Clear indicators for rate limits, API issues, etc.

## Changes

### 1. TranslationManager.translate() 
**File:** `Sources/SnapTranslate/Services/TranslationProviders.swift`

**Added:**
- Log when each provider is tried
- Show success/failure for each provider
- Collect all errors with provider names
- Final error report showing which provider failed and why

**Example Output:**
```
🔄🔄🔄 TranslationManager.translate() - Trying providers 🔄🔄🔄
📍 Trying all providers in fallback order:
   → MyMemory... ❌ Parse error
   → Google Translate... ❌ HTTP error
   → LibreTranslate... ❌ Network timeout
   → DeepLX... ❌ No API key configured

❌ ALL PROVIDERS FAILED - Details:
  • MyMemory: Parse error
  • Google Translate: HTTP error
  • LibreTranslate: Network timeout
  • DeepLX: No API key configured
```

### 2. TranslationService.translateWithRetry()
**File:** `Sources/SnapTranslate/Services/TranslationService.swift`

**Added:**
- Clear section headers for each retry attempt
- Show exact error details from manager
- Better formatting with emojis for quick scanning
- Wait timer between retries

**Example Output:**
```
📡📡📡 TranslationService.translateWithRetry() 📡📡📡
📤 Sending to translation API: hello bro...
   Input length: 31 chars
   Lang: vi → en

🔁 ATTEMPT 1/3:
   ❌ This attempt failed!
   Error details:
   All providers failed:
   • MyMemory: Parse error

⏳ Waiting 1 second before retry...
🔄 Retrying with next attempt...

🔁 ATTEMPT 2/3:
   [...]

⚠️ ALL 3 ATTEMPTS FAILED
```

### 3. Error Handling
**File:** `Sources/SnapTranslate/Services/TranslationService.swift`

**Changed:**
- More accurate error message (not "API limit exceeded")
- Better explanation in Vietnamese + English
- Shows it's a network/API issue, not quota issue

## How to Debug Now

When translation fails:
1. Look for `🔄🔄🔄 TranslationManager.translate()` section
   - Check which providers failed and their specific errors
2. Look for `📡📡📡 TranslationService.translateWithRetry()` section
   - See each retry attempt and why it failed
3. Look for final `❌ FINAL FAILURE` section
   - Language pair and text that failed

## Detailed Provider Logging

Each provider now logs:

### MyMemory Provider
```
[MyMemory] Request: hello bro ...
[MyMemory API] URL: https://api.mymemory.translated.net/...
[MyMemory API] HTTP Status: 429
[MyMemory API] ⚠️  RATE LIMIT EXCEEDED (429)
```

### Google Translate Provider
```
[Google Translate] Request: hello bro ...
[Google Translate] HTTP Status: 200
[Google Translate] ❌ Parse error - Response: {...}
```

### LibreTranslate Provider
```
[LibreTranslate] Request: hello bro ...
[LibreTranslate] HTTP Status: 503
[LibreTranslate] ⚠️  SERVICE UNAVAILABLE (503)
```

### DeepLX Provider
```
[DeepLX] Request: hello bro ...
[DeepLX] HTTP Status: 403
[DeepLX] ⚠️  FORBIDDEN (403) - Invalid API key
```

## Common Error Scenarios

### Scenario 1: Rate Limit (429)
```
[MyMemory API] HTTP Status: 429
[MyMemory API] ⚠️  RATE LIMIT EXCEEDED (429)
   → MyMemory: Rate limit exceeded (429) - Too many requests
```
**Solution:** Wait 30-60 seconds and try again

### Scenario 2: Service Unavailable (503)
```
[LibreTranslate] HTTP Status: 503
[LibreTranslate] ⚠️  SERVICE UNAVAILABLE (503)
```
**Solution:** Server is down, try another provider or wait

### Scenario 3: Parse Error
```
[Google Translate] ❌ Parse error - Response: {"error":"Invalid format"}
   → Google Translate: Parse error - Invalid JSON format
```
**Solution:** API response format changed or unexpected data

### Scenario 4: Invalid API Key
```
[DeepLX] HTTP Status: 403
[DeepLX] ⚠️  FORBIDDEN (403) - Invalid API key
```
**Solution:** Setup valid DeepL API key or visit https://www.deepl.com/pro#developer

### Scenario 5: Network Timeout
```
[MyMemory API] ❌ Exception: The request timed out.
```
**Solution:** Check internet connection, try again later

## Testing
```bash
./run-debug.sh
```

Then try translating text with broken providers or no internet to see detailed logs.
