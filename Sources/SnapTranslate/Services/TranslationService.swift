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
    func translate(_ text: String, to languageCode: String) async -> String {
        guard !text.isEmpty else { return "" }
        
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
}
