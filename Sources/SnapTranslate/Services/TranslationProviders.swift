import Foundation

// MARK: - Unified Response Model
struct TranslationResponse {
    let text: String
    let sourceLanguage: String
    let targetLanguage: String
    let provider: String
    let error: String?
    
    var isSuccess: Bool { error == nil }
}

// MARK: - Provider Protocol
protocol TranslationProvider {
    var name: String { get }
    var maxCharacters: Int { get }
    var supportedLanguages: [String] { get }
    
    func translate(_ text: String, from: String, to: String) async -> TranslationResponse
}

// MARK: - LibreTranslate Provider
class LibreTranslateProvider: TranslationProvider {
    let name = "LibreTranslate"
    let maxCharacters = 50000
    let supportedLanguages = [
        "auto", "en", "es", "fr", "de", "it", "pt", "ru", "ja", "ko", "zh", "vi", "th", "ar", "hi", "id"
    ]
    
    private let baseURL = "https://libretranslate.com/translate"  // Using main instance
    private let apiKey: String? = nil  // Free tier doesn't require key
    
    func translate(_ text: String, from: String, to: String) async -> TranslationResponse {
        guard !text.isEmpty else {
            return TranslationResponse(text: "", sourceLanguage: from, targetLanguage: to, provider: name, error: "Empty text")
        }
        
        guard text.count <= maxCharacters else {
            return TranslationResponse(text: text, sourceLanguage: from, targetLanguage: to, provider: name, error: "Exceeds \(maxCharacters) chars limit")
        }
        
        do {
            guard let url = URL(string: baseURL) else {
                return TranslationResponse(text: text, sourceLanguage: from, targetLanguage: to, provider: name, error: "Invalid URL")
            }
            
            print("  [LibreTranslate] Request: \(text.prefix(60))...")
            
            // Create multipart/form-data body
            let boundary = "----WebKitFormBoundary\(UUID().uuidString)"
            var body = ""
            
            let params: [String: String] = [
                "q": text,
                "source": from.isEmpty || from == "auto" ? "auto" : from,
                "target": to,
                "format": "text",
                "alternatives": "3"
            ]
            
            for (key, value) in params {
                body += "--\(boundary)\r\n"
                body += "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n"
                body += "\(value)\r\n"
            }
            
            body += "--\(boundary)--\r\n"
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
            request.timeoutInterval = 30
            request.httpBody = body.data(using: .utf8)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return TranslationResponse(text: text, sourceLanguage: from, targetLanguage: to, provider: name, error: "Invalid HTTP response")
            }
            
            print("  [LibreTranslate] HTTP Status: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 429 {
                print("  [LibreTranslate] ⚠️  RATE LIMIT EXCEEDED (429)")
                return TranslationResponse(text: text, sourceLanguage: from, targetLanguage: to, provider: name, error: "Rate limit exceeded (429)")
            }
            
            if httpResponse.statusCode != 200 {
                if let responseStr = String(data: data, encoding: .utf8) {
                    print("  [LibreTranslate] ❌ HTTP \(httpResponse.statusCode): \(responseStr.prefix(150))...")
                }
                return TranslationResponse(text: text, sourceLanguage: from, targetLanguage: to, provider: name, error: "HTTP error \(httpResponse.statusCode)")
            }
            
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let translatedText = json["translatedText"] as? String {
                print("  [LibreTranslate] ✅ Parsed: \(translatedText.prefix(60))...")
                return TranslationResponse(text: translatedText, sourceLanguage: from, targetLanguage: to, provider: name, error: nil)
            }
            
            if let responseStr = String(data: data, encoding: .utf8) {
                print("  [LibreTranslate] ❌ Parse error - Response: \(responseStr.prefix(150))...")
            }
            return TranslationResponse(text: text, sourceLanguage: from, targetLanguage: to, provider: name, error: "Parse error - Invalid JSON format")
        } catch {
            print("  [LibreTranslate] ❌ Exception: \(error.localizedDescription)")
            return TranslationResponse(text: text, sourceLanguage: from, targetLanguage: to, provider: name, error: "Exception: \(error.localizedDescription)")
        }
    }
}

// MARK: - DeepLX Provider
class DeepLXProvider: TranslationProvider {
    let name = "DeepLX"
    let maxCharacters = 50000
    let supportedLanguages = [
        "auto", "en", "es", "fr", "de", "it", "pt", "ru", "ja", "ko", "zh", "vi", "ar", "hi", "id"
    ]
    
    private let baseURL = "https://api-free.deepl.com/v1/translate"
    // Get free API key from https://www.deepl.com/pro#developer
    private let apiKey: String? = "df4385c2-33de-e423-4134-ca1f7b3ea8b7"
    
    func translate(_ text: String, from: String, to: String) async -> TranslationResponse {
        guard !text.isEmpty else {
            return TranslationResponse(text: "", sourceLanguage: from, targetLanguage: to, provider: name, error: "Empty text")
        }
        
        guard text.count <= maxCharacters else {
            return TranslationResponse(text: text, sourceLanguage: from, targetLanguage: to, provider: name, error: "Exceeds \(maxCharacters) chars limit")
        }
        
        guard let apiKey = apiKey else {
            return TranslationResponse(text: text, sourceLanguage: from, targetLanguage: to, provider: name, error: "No API key configured - Visit https://www.deepl.com/pro#developer")
        }
        
        do {
            guard let url = URL(string: baseURL) else {
                return TranslationResponse(text: text, sourceLanguage: from, targetLanguage: to, provider: name, error: "Invalid URL")
            }
            
            print("  [DeepLX] Request: \(text.prefix(60))...")
            
            let targetLang = to.uppercased()  // DeepL requires uppercase lang codes
            let requestBody: [String: Any] = [
                "text": [text],
                "target_lang": targetLang
            ]
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("DeepL-Auth-Key \(apiKey)", forHTTPHeaderField: "Authorization")
            request.timeoutInterval = 30
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return TranslationResponse(text: text, sourceLanguage: from, targetLanguage: to, provider: name, error: "Invalid HTTP response")
            }
            
            print("  [DeepLX] HTTP Status: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 429 {
                print("  [DeepLX] ⚠️  RATE LIMIT EXCEEDED (429)")
                return TranslationResponse(text: text, sourceLanguage: from, targetLanguage: to, provider: name, error: "Rate limit exceeded (429)")
            }
            
            if httpResponse.statusCode == 403 {
                print("  [DeepLX] ⚠️  FORBIDDEN (403) - Invalid API key")
                return TranslationResponse(text: text, sourceLanguage: from, targetLanguage: to, provider: name, error: "Forbidden (403) - Invalid API key")
            }
            
            if httpResponse.statusCode != 200 {
                if let responseStr = String(data: data, encoding: .utf8) {
                    print("  [DeepLX] ❌ HTTP \(httpResponse.statusCode): \(responseStr.prefix(150))...")
                }
                return TranslationResponse(text: text, sourceLanguage: from, targetLanguage: to, provider: name, error: "HTTP error \(httpResponse.statusCode)")
            }
            
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let translations = json["translations"] as? [[String: Any]],
               let translatedText = translations.first?["text"] as? String {
                return TranslationResponse(text: translatedText, sourceLanguage: from, targetLanguage: to, provider: name, error: nil)
            }
            
            if let responseStr = String(data: data, encoding: .utf8) {
                print("  [DeepLX] ❌ Parse error - Response: \(responseStr.prefix(150))...")
            }
            return TranslationResponse(text: text, sourceLanguage: from, targetLanguage: to, provider: name, error: "Parse error - Invalid JSON format")
        } catch {
            print("  [DeepLX] ❌ Exception: \(error.localizedDescription)")
            return TranslationResponse(text: text, sourceLanguage: from, targetLanguage: to, provider: name, error: "Exception: \(error.localizedDescription)")
        }
    }
}

// MARK: - Google Translate (Unofficial) Provider
class GoogleTranslateProvider: TranslationProvider {
    let name = "Google Translate"
    let maxCharacters = 5000
    let supportedLanguages = [
        "auto", "en", "es", "fr", "de", "it", "pt", "ru", "ja", "ko", "zh", "vi", "th", "ar", "hi", "id"
    ]
    
    private let chunkSize = 1500  // URL-safe chunk size for Google Translate
    
    func translate(_ text: String, from: String, to: String) async -> TranslationResponse {
        guard !text.isEmpty else {
            return TranslationResponse(text: "", sourceLanguage: from, targetLanguage: to, provider: name, error: "Empty text")
        }
        
        guard text.count <= maxCharacters else {
            return TranslationResponse(text: text, sourceLanguage: from, targetLanguage: to, provider: name, error: "Exceeds \(maxCharacters) chars limit")
        }
        
        // Split text into chunks if needed
        let chunks = splitText(text, size: chunkSize)
        print("  [Google Translate] Splitting: \(text.count) chars → \(chunks.count) chunks")
        
        if chunks.count == 1 {
            // Single chunk, translate directly
            return await translateChunk(chunks[0], from: from, to: to)
        } else {
            // Multiple chunks, translate each and combine
            print("  [Google Translate] Multi-chunk mode")
            var translatedChunks: [String] = []
            
            for (index, chunk) in chunks.enumerated() {
                print("  [Google Translate] Chunk \(index + 1)/\(chunks.count): \(chunk.count) chars")
                let result = await translateChunk(chunk, from: from, to: to)
                if result.isSuccess {
                    print("  [Google Translate] Chunk \(index + 1) ✅: \(result.text.count) chars")
                    translatedChunks.append(result.text)
                } else {
                    // If any chunk fails, return error
                    print("  [Google Translate] Chunk \(index + 1) ❌: \(result.error ?? "Unknown error")")
                    return result
                }
            }
            
            // Combine translated chunks
            let combinedText = translatedChunks.joined(separator: " ")
            print("  [Google Translate] Combined: \(combinedText.count) chars from \(chunks.count) chunks")
            return TranslationResponse(text: combinedText, sourceLanguage: from, targetLanguage: to, provider: name, error: nil)
        }
    }
    
    /// Split text into chunks
    private func splitText(_ text: String, size: Int) -> [String] {
        var chunks: [String] = []
        var currentChunk = ""
        let safeSize = Int(Double(size) * 0.7)  // Use 70% of limit for safety
        
        let words = text.split(separator: " ", omittingEmptySubsequences: false).map { String($0) }
        
        for word in words {
            let testChunk = currentChunk.isEmpty ? word : currentChunk + " " + word
            
            // Check if adding this word would exceed safe limit
            if testChunk.count > safeSize && !currentChunk.isEmpty {
                chunks.append(currentChunk)
                currentChunk = word
            } else {
                currentChunk = testChunk
            }
        }
        
        if !currentChunk.isEmpty {
            chunks.append(currentChunk)
        }
        
        return chunks.isEmpty ? [text] : chunks
    }
    
    /// Translate a single chunk
    private func translateChunk(_ text: String, from: String, to: String) async -> TranslationResponse {
        do {
            // Using alternative free Google Translate endpoint
            let urlString = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=\(from)&tl=\(to)&dt=t&q=\(text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
            
            guard let url = URL(string: urlString) else {
                return TranslationResponse(text: text, sourceLanguage: from, targetLanguage: to, provider: name, error: "Invalid URL")
            }
            
            print("    [Google Translate API] Request: \(text.prefix(60))...")
            
            var request = URLRequest(url: url)
            request.setValue("Mozilla/5.0", forHTTPHeaderField: "User-Agent")
            request.timeoutInterval = 30
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return TranslationResponse(text: text, sourceLanguage: from, targetLanguage: to, provider: name, error: "Invalid HTTP response")
            }
            
            print("    [Google Translate API] HTTP Status: \(httpResponse.statusCode)")
            
            if httpResponse.statusCode == 429 {
                print("    [Google Translate API] ⚠️  RATE LIMIT EXCEEDED (429)")
                return TranslationResponse(text: text, sourceLanguage: from, targetLanguage: to, provider: name, error: "Rate limit exceeded (429)")
            }
            
            if httpResponse.statusCode != 200 {
                if let responseStr = String(data: data, encoding: .utf8) {
                    print("    [Google Translate API] ❌ HTTP \(httpResponse.statusCode): \(responseStr.prefix(150))...")
                }
                return TranslationResponse(text: text, sourceLanguage: from, targetLanguage: to, provider: name, error: "HTTP error \(httpResponse.statusCode)")
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                // Parse JSON array: [[["translated text", "original text", null, null, 0], ...], ...]
                if let jsonData = responseString.data(using: .utf8),
                   let jsonArray = try JSONSerialization.jsonObject(with: jsonData) as? [Any] {
                    
                    // First element should be array of translations
                    if let translationsArray = jsonArray.first as? [[Any]] {
                        // Get first translation pair
                        for translationSet in translationsArray {
                            if !translationSet.isEmpty,
                               let translatedText = translationSet[0] as? String {
                                print("    [Google Translate API] ✅ Parsed: \(translatedText.prefix(60))...")
                                return TranslationResponse(text: translatedText, sourceLanguage: from, targetLanguage: to, provider: name, error: nil)
                            }
                        }
                    }
                }
            }
            
            if let responseStr = String(data: data, encoding: .utf8) {
                print("    [Google Translate API] ❌ Parse error - Response: \(responseStr.prefix(200))...")
            }
            return TranslationResponse(text: text, sourceLanguage: from, targetLanguage: to, provider: name, error: "Parse error - Invalid JSON format")
        } catch {
            print("    [Google Translate API] ❌ Exception: \(error.localizedDescription)")
            return TranslationResponse(text: text, sourceLanguage: from, targetLanguage: to, provider: name, error: "Exception: \(error.localizedDescription)")
        }
    }
}

// MARK: - MyMemory Provider (Auto-chunking for large text)
class MyMemoryProvider: TranslationProvider {
    let name = "MyMemory"
    let maxCharacters = 10000  // Support up to 10k chars via chunking
    let supportedLanguages = [
        "en", "es", "fr", "de", "it", "pt", "ru", "ja", "ko", "zh", "vi", "ar", "hi", "id"
    ]
    
    private let baseURL = "https://api.mymemory.translated.net/get"
    private let chunkSize = 480  // Slightly under 500 limit for safety
    
    func translate(_ text: String, from: String, to: String) async -> TranslationResponse {
        guard !text.isEmpty else {
            return TranslationResponse(text: "", sourceLanguage: from, targetLanguage: to, provider: name, error: "Empty text")
        }
        
        guard text.count <= maxCharacters else {
            return TranslationResponse(text: text, sourceLanguage: from, targetLanguage: to, provider: name, error: "Exceeds \(maxCharacters) chars limit")
        }
        
        // Split text into chunks if needed
        let chunks = splitText(text, size: chunkSize)
        print("  [MyMemory] Splitting: \(text.count) chars → \(chunks.count) chunks (safeSize: \(Int(Double(chunkSize) * 0.7)))")
        
        if chunks.count == 1 {
            // Single chunk, translate directly
            print("  [MyMemory] Single chunk mode")
            return await translateChunk(chunks[0], from: from, to: to)
        } else {
            // Multiple chunks, translate each and combine
            print("  [MyMemory] Multi-chunk mode")
            var translatedChunks: [String] = []
            
            for (index, chunk) in chunks.enumerated() {
                print("  [MyMemory] Chunk \(index + 1)/\(chunks.count): \(chunk.count) chars")
                let result = await translateChunk(chunk, from: from, to: to)
                if result.isSuccess {
                    print("  [MyMemory] Chunk \(index + 1) ✅: \(result.text.count) chars")
                    translatedChunks.append(result.text)
                } else {
                    // If any chunk fails, return error
                    print("  [MyMemory] Chunk \(index + 1) ❌: \(result.error ?? "Unknown error")")
                    return result
                }
            }
            
            // Combine translated chunks
            let combinedText = translatedChunks.joined(separator: " ")
            print("  [MyMemory] Combined: \(combinedText.count) chars from \(chunks.count) chunks")
            return TranslationResponse(text: combinedText, sourceLanguage: from, targetLanguage: to, provider: name, error: nil)
        }
    }
    
    /// Split text into chunks, accounting for URL encoding expansion
    private func splitText(_ text: String, size: Int) -> [String] {
        var chunks: [String] = []
        var currentChunk = ""
        let safeSize = Int(Double(size) * 0.7)  // Use 70% of limit to account for URL encoding
        
        let words = text.split(separator: " ", omittingEmptySubsequences: false).map { String($0) }
        
        for word in words {
            let testChunk = currentChunk.isEmpty ? word : currentChunk + " " + word
            
            // Check if adding this word would exceed safe limit
            if testChunk.count > safeSize && !currentChunk.isEmpty {
                chunks.append(currentChunk)
                currentChunk = word
            } else {
                currentChunk = testChunk
            }
        }
        
        if !currentChunk.isEmpty {
            chunks.append(currentChunk)
        }
        
        return chunks.isEmpty ? [text] : chunks
    }
    
    /// Translate a single chunk
    private func translateChunk(_ text: String, from: String, to: String) async -> TranslationResponse {
        do {
            let langPair = "\(from)|\(to)"
            
            print("    [MyMemory API] Request: \(text.prefix(60))...")
            print("    [MyMemory API] Full text length: \(text.count)")
            
            // Use query parameter for URL
            var urlComponents = URLComponents(string: baseURL)
            urlComponents?.queryItems = [
                URLQueryItem(name: "q", value: text),
                URLQueryItem(name: "langpair", value: langPair)
            ]
            
            guard let url = urlComponents?.url else {
                return TranslationResponse(text: text, sourceLanguage: from, targetLanguage: to, provider: name, error: "Invalid URL")
            }
            
            print("    [MyMemory API] URL: \(url.absoluteString)")
            
            var request = URLRequest(url: url)
            request.timeoutInterval = 30
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return TranslationResponse(text: text, sourceLanguage: from, targetLanguage: to, provider: name, error: "Invalid HTTP response")
            }
            
            // Log HTTP status code
            print("    [MyMemory API] HTTP Status: \(httpResponse.statusCode)")
            
            // Handle different HTTP status codes
            if httpResponse.statusCode == 429 {
                print("    [MyMemory API] ⚠️  RATE LIMIT EXCEEDED (429)")
                return TranslationResponse(text: text, sourceLanguage: from, targetLanguage: to, provider: name, error: "Rate limit exceeded (429) - Too many requests")
            }
            
            if httpResponse.statusCode == 503 {
                print("    [MyMemory API] ⚠️  SERVICE UNAVAILABLE (503)")
                return TranslationResponse(text: text, sourceLanguage: from, targetLanguage: to, provider: name, error: "Service unavailable (503) - Server error")
            }
            
            if httpResponse.statusCode == 403 {
                print("    [MyMemory API] ⚠️  FORBIDDEN (403)")
                return TranslationResponse(text: text, sourceLanguage: from, targetLanguage: to, provider: name, error: "Forbidden (403) - Access denied")
            }
            
            if httpResponse.statusCode != 200 {
                // Log response body for debugging
                if let responseStr = String(data: data, encoding: .utf8) {
                    print("    [MyMemory API] ❌ HTTP \(httpResponse.statusCode) Response: \(responseStr.prefix(200))...")
                }
                return TranslationResponse(text: text, sourceLanguage: from, targetLanguage: to, provider: name, error: "HTTP error \(httpResponse.statusCode)")
            }
            
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let responseData = json["responseData"] as? [String: Any],
               var translatedText = responseData["translatedText"] as? String {
                
                print("    [MyMemory API] Raw response: \(translatedText.prefix(80))...")
                
                // Fix malformed encoding: replace "% 20" (space before 20) with "%20"
                translatedText = translatedText.replacingOccurrences(of: "% ", with: "%")
                
                // Decode URL-encoded characters - loop until no more encoding
                var previousText = ""
                var iterations = 0
                while previousText != translatedText && translatedText.contains("%") && iterations < 5 {
                    previousText = translatedText
                    translatedText = translatedText.removingPercentEncoding ?? translatedText
                    iterations += 1
                }
                
                // Convert %0A to newline
                translatedText = translatedText.replacingOccurrences(of: "%0A", with: "\n")
                
                print("    [MyMemory API] After decode (\(iterations) passes): \(translatedText.prefix(80))...")
                
                // Trim extra spaces but preserve newlines
                translatedText = translatedText.trimmingCharacters(in: .whitespaces)
                return TranslationResponse(text: translatedText, sourceLanguage: from, targetLanguage: to, provider: name, error: nil)
            }
            
            // Log response body when parse fails
            if let responseStr = String(data: data, encoding: .utf8) {
                print("    [MyMemory API] ❌ Parse error - Response: \(responseStr.prefix(200))...")
            }
            return TranslationResponse(text: text, sourceLanguage: from, targetLanguage: to, provider: name, error: "Parse error - Invalid JSON format")
        } catch {
            print("    [MyMemory API] ❌ Exception: \(error.localizedDescription)")
            return TranslationResponse(text: text, sourceLanguage: from, targetLanguage: to, provider: name, error: "Exception: \(error.localizedDescription)")
        }
    }
}

// MARK: - Translation Manager with Fallback
class TranslationManager {
    static let shared = TranslationManager()
    
    private let providers: [TranslationProvider] = [
        MyMemoryProvider(),  // Most stable, 500 chars
        LibreTranslateProvider(),  // Large limit, test this first
        GoogleTranslateProvider(),  // Free but may break
        DeepLXProvider()  // Requires API key
    ]
    
    func translate(_ text: String, from: String, to: String, preferredProvider: String? = nil) async -> TranslationResponse {
        guard !text.isEmpty else {
            return TranslationResponse(text: "", sourceLanguage: from, targetLanguage: to, provider: "N/A", error: "Empty text")
        }
        
        print("\n" + String(repeating: "🔄", count: 60))
        print("🔄🔄🔄 TranslationManager.translate() - Trying providers 🔄🔄🔄")
        print(String(repeating: "🔄", count: 60))
        
        var allErrors: [(provider: String, error: String)] = []
        
        // Try preferred provider first
        if let preferred = preferredProvider {
            if let provider = providers.first(where: { $0.name == preferred }) {
                print("📍 Trying preferred provider: \(provider.name)")
                let result = await provider.translate(text, from: from, to: to)
                if result.isSuccess {
                    print("✅ \(provider.name): SUCCESS\n")
                    return result
                } else {
                    let errorMsg = result.error ?? "Unknown error"
                    print("❌ \(provider.name): \(errorMsg)")
                    allErrors.append((provider.name, errorMsg))
                }
            }
        }
        
        // Try all providers in order, fallback on failure
        print("📍 Trying all providers in fallback order:")
        for provider in providers {
            // Skip if already tried as preferred
            if preferredProvider == provider.name {
                continue
            }
            
            print("   → \(provider.name)...", terminator: "")
            let result = await provider.translate(text, from: from, to: to)
            if result.isSuccess {
                print(" ✅ SUCCESS\n")
                return result
            } else {
                let errorMsg = result.error ?? "Unknown error"
                print(" ❌ \(errorMsg)")
                allErrors.append((provider.name, errorMsg))
            }
        }
        
        // All providers failed - detailed error logging
        print("\n" + String(repeating: "❌", count: 60))
        print("❌ ALL PROVIDERS FAILED - Details:")
        for (provider, error) in allErrors {
            print("  • \(provider): \(error)")
        }
        print(String(repeating: "❌", count: 60) + "\n")
        
        let detailedError = "All providers failed:\n" + allErrors.map { "• \($0.provider): \($0.error)" }.joined(separator: "\n")
        
        return TranslationResponse(
            text: text,
            sourceLanguage: from,
            targetLanguage: to,
            provider: "All",
            error: detailedError
        )
    }
}
