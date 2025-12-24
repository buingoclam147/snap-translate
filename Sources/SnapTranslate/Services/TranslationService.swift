import Foundation

class TranslationService {
    static let shared = TranslationService()
    
    // MyMemory API endpoint (free, no authentication needed)
    // Format: https://api.mymemory.translated.net/get?q=text&langpair=en|vi
    private let apiURL = "https://api.mymemory.translated.net/get"
    
    // Supported language pairs (source=English, target=various)
    let supportedLanguages: [String: String] = [
        "vi": "Vietnamese",
        "es": "Spanish",
        "fr": "French",
        "de": "German",
        "it": "Italian",
        "pt": "Portuguese",
        "ru": "Russian",
        "ja": "Japanese",
        "ko": "Korean",
        "zh": "Chinese",
        "th": "Thai",
        "ar": "Arabic",
        "hi": "Hindi",
        "id": "Indonesian"
    ]
    
    private init() {
        print("✅ TranslationService initialized - Multi-language via MyMemory API")
    }
    
    /// Translate English text to target language using MyMemory API
    /// Splits text into chunks if exceeds 450 characters to avoid API URL length limits
    func translate(_ text: String, to languageCode: String) async -> String {
        guard !text.isEmpty else { return "" }
        
        let charCount = text.count
        print("📊 Text has \(charCount) characters")
        
        // MyMemory API has ~500 char limit for URL, use 450 to be safe
        if charCount < 450 {
            return await translateChunk(text, languageCode: languageCode)
        }
        
        // Split into chunks if text is too long
        print("⚠️ Text exceeds 450 chars, splitting into chunks...")
        let chunks = splitTextAtCharBoundary(text, maxChars: 450)
        print("📦 Split into \(chunks.count) chunks")
        
        // Translate each chunk
        var translatedChunks: [String] = []
        for (index, chunk) in chunks.enumerated() {
            print("🔄 Translating chunk \(index + 1)/\(chunks.count) (\(chunk.count) chars)...")
            let translated = await translateChunk(chunk, languageCode: languageCode)
            translatedChunks.append(translated)
        }
        
        // Join translated chunks with space
        let result = translatedChunks.joined(separator: " ")
        print("✅ All chunks translated and joined")
        return result
    }
    
    /// Translate a single chunk of text
    private func translateChunk(_ text: String, languageCode: String) async -> String {
        do {
            // Use URLComponents for proper query parameter encoding
            var components = URLComponents(string: apiURL)!
            components.queryItems = [
                URLQueryItem(name: "q", value: text),
                URLQueryItem(name: "langpair", value: "en|\(languageCode)")
            ]
            
            guard let url = components.url else {
                print("⚠️ Invalid URL for translation")
                return text
            }
            
            print("📤 Sending to translation API: \(text.prefix(60))...")
            
            // Make request (GET)
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.timeoutInterval = 10 // 10 second timeout
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("⚠️ Invalid response type from translation API")
                return text
            }
            
            guard httpResponse.statusCode == 200 else {
                print("⚠️ Translation API error: \(httpResponse.statusCode)")
                return text
            }
            
            // Parse response
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                let responseData = json["responseData"] as? [String: Any],
                let translatedText = responseData["translatedText"] as? String {
                
                // Verify we got a valid translation (not empty)
                guard !translatedText.isEmpty else {
                    print("⚠️ Empty translation received")
                    return text
                }
                
                // Decode URL-encoded text (MyMemory API returns encoded text)
                let decodedText = translatedText.removingPercentEncoding ?? translatedText
                
                print("✅ Translation to \(languageCode) completed: \(text.prefix(50))... → \(decodedText.prefix(50))...")
                return decodedText
            }
            
            print("⚠️ Failed to parse translation response")
            return text
            
        } catch {
            print("❌ Translation error: \(error.localizedDescription)")
            return text
        }
    }
    
    /// Split text into chunks at word boundaries to avoid exceeding maxChars
    /// Ensures chunks split at spaces, not in the middle of words
    private func splitTextAtCharBoundary(_ text: String, maxChars: Int) -> [String] {
        let words = text.split(separator: " ", omittingEmptySubsequences: true).map(String.init)
        
        var chunks: [String] = []
        var currentChunk: [String] = []
        var currentLength = 0
        
        for word in words {
            let wordLength = word.count
            let spaceLength = currentChunk.isEmpty ? 0 : 1  // Space before word
            
            // If adding this word would exceed maxChars, save current chunk and start new one
            if currentLength + spaceLength + wordLength > maxChars && !currentChunk.isEmpty {
                chunks.append(currentChunk.joined(separator: " "))
                currentChunk = [word]
                currentLength = wordLength
            } else {
                currentChunk.append(word)
                currentLength += spaceLength + wordLength
            }
        }
        
        // Add remaining chunk
        if !currentChunk.isEmpty {
            chunks.append(currentChunk.joined(separator: " "))
        }
        
        return chunks
    }
}
