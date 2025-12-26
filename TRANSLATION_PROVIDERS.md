# Translation Providers

Unified interface để sử dụng nhiều dịch vụ dịch API công cộng với fallback mechanism.

## Supported Providers

### 1. LibreTranslate
- **URL**: https://libretranslate.com/translate
- **Max Characters**: 50,000
- **API Key**: Optional (free tier available)
- **Supported Languages**: auto, en, es, fr, de, it, pt, ru, ja, ko, zh, vi, th, ar, hi, id
- **Request Format**:
  ```json
  {
    "q": "text to translate",
    "source": "en",
    "target": "vi",
    "format": "text",
    "api_key": "" // optional
  }
  ```
- **Response Format**:
  ```json
  {
    "translatedText": "dịch"
  }
  ```

### 2. Google Translate (Unofficial)
- **URL**: https://translate.googleapis.com/translate_a/single
- **Max Characters**: 5,000
- **API Key**: Not required
- **Supported Languages**: auto, en, es, fr, de, it, pt, ru, ja, ko, zh, vi, th, ar, hi, id
- **Note**: Using unofficial free endpoint (may break anytime)
- **Query Parameters**: ?client=gtx&sl=en&tl=vi&dt=t&q=text

### 3. DeepL (Free API)
- **URL**: https://api-free.deepl.com/v1/translate
- **Max Characters**: 50,000
- **API Key**: Required (get free at https://www.deepl.com/pro#developer)
- **Supported Languages**: auto, en, es, fr, de, it, pt, ru, ja, ko, zh, vi, ar, hi, id
- **Request Format**:
  ```json
  {
    "text": ["text to translate"],
    "target_lang": "VI"
  }
  ```
- **Header**: Authorization: DeepL-Auth-Key {key}

### 4. MyMemory
- **URL**: https://api.mymemory.translated.net/get
- **Max Characters**: 500
- **API Key**: Not required
- **Supported Languages**: en, es, fr, de, it, pt, ru, ja, ko, zh, vi, ar, hi, id
- **Query Parameters**: ?q=text&langpair=en|vi
- **Response Format**:
  ```json
  {
    "responseData": {
      "translatedText": "dịch"
    }
  }
  ```

## Usage Examples

### Using TranslationManager (Automatic Fallback)
```swift
let manager = TranslationManager.shared

// Tries LibreTranslate → Google → MyMemory → DeepL in order
let response = await manager.translate(
    "Hello, world!",
    from: "en",
    to: "vi"
)

if response.isSuccess {
    print("✅ \(response.provider): \(response.text)")
} else {
    print("❌ Error: \(response.error ?? "")")
}
```

### Using Specific Provider
```swift
let provider = LibreTranslateProvider()
let response = await provider.translate(
    "Hello, world!",
    from: "en",
    to: "vi"
)
```

### With Preferred Provider
```swift
// Try DeepL first, fallback to others if fails
let response = await manager.translate(
    "Hello, world!",
    from: "en",
    to: "vi",
    preferredProvider: "DeepL"
)
```

## Running Tests

```swift
// Test all providers
await TranslationAPITester.runAllTests()

// Test language support matrix
await TranslationAPITester.testLanguageSupport()
```

## Response Model

```swift
struct TranslationResponse {
    let text: String              // Translated text
    let sourceLanguage: String    // Source language code
    let targetLanguage: String    // Target language code
    let provider: String          // Which provider was used
    let error: String?            // Error message if any
    var isSuccess: Bool           // Returns true if no error
}
```

## Character Limits Summary

| Provider | Max Characters |
|----------|---------------|
| LibreTranslate | 50,000 |
| DeepL | 50,000 |
| Google Translate | 5,000 |
| MyMemory | 500 |

## Supported Language Codes

```
en   - English
vi   - Vietnamese
es   - Spanish
fr   - French
de   - German
it   - Italian
pt   - Portuguese
ru   - Russian
ja   - Japanese
ko   - Korean
zh   - Chinese (Simplified)
th   - Thai
ar   - Arabic
hi   - Hindi
id   - Indonesian
```

## Configuration

To enable paid providers (e.g., DeepL), set their API keys in `TranslationProviders.swift`:

```swift
// DeepL Example
class DeepLXProvider: TranslationProvider {
    private let apiKey: String? = "your-api-key-here"  // Get from https://www.deepl.com/pro#developer
}
```

## Fallback Strategy

TranslationManager automatically tries providers in this order:
1. LibreTranslate (free, 50k chars)
2. Google Translate (free, 5k chars, may break)
3. MyMemory (free, 500 chars)
4. DeepL (requires API key, 50k chars)

If preferred provider fails, it moves to next one.

## Important Notes

- **Google Translate** uses unofficial free endpoint - not recommended for production
- **MyMemory** has low character limit (500)
- **LibreTranslate** is most reliable free option
- **DeepL** is highest quality but requires API key
- All requests include User-Agent header for compatibility
- Default timeout: 30 seconds per request

## Error Handling

```swift
let response = await manager.translate(text, from: "en", to: "vi")

if response.isSuccess {
    print(response.text)
} else {
    // Handle error - switch to manual fallback or show to user
    print("Translation failed: \(response.error ?? "Unknown error")")
    print("Last used provider: \(response.provider)")
}
```

## Future Improvements

- [ ] Add caching layer
- [ ] Add request queuing
- [ ] Add rate limiting
- [ ] Add language detection
- [ ] Add support for Microsoft Translator API
- [ ] Add support for Baidu Translate API
- [ ] Add support for Alibaba Translate API
