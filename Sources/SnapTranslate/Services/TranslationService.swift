import Foundation

class TranslationService {
    static let shared = TranslationService()
    
    // Custom Translation API Server (Render.com)
    // POST /api/translate with JSON body
    private let apiURL = "https://esnap-translation-api.onrender.com/api/translate"
    private let maxCharacters = 1500  // Server limit is 1500 characters
    
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
        print("✅ TranslationService initialized - Multi-language via Custom API Server")
    }
    
    /// Translate English text to target language using custom translation API
    func translate(_ text: String, to languageCode: String) async -> String {
        guard !text.isEmpty else { return "" }
        
        let charCount = text.count
        print("📊 Text has \(charCount) characters")
        
        // Check character limit (1500 chars max per server)
        if charCount > maxCharacters {
            print("⚠️ Text exceeds \(maxCharacters) character limit")
            return "[Translation error: Text exceeds \(maxCharacters) character limit. Please use shorter text.]"
        }
        
        return await translateText(text, languageCode: languageCode)
    }
    
    /// Translate text using custom API server
    private func translateText(_ text: String, languageCode: String) async -> String {
        do {
            guard let url = URL(string: apiURL) else {
                print("⚠️ Invalid API URL")
                return text
            }
            
            print("📤 Sending to translation API: \(text.prefix(60))...")
            
            // Build request body
            let requestBody: [String: Any] = [
                "text": text,
                "target_language": languageCode
            ]
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.timeoutInterval = 30  // 30 second timeout
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("⚠️ Invalid response type from translation API")
                return text
            }
            
            guard httpResponse.statusCode == 200 else {
                print("⚠️ Translation API error: HTTP \(httpResponse.statusCode)")
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorMsg = json["message"] as? String {
                    print("   Error: \(errorMsg)")
                }
                return text
            }
            
            // Parse response
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let success = json["success"] as? Bool,
               success,
               let translatedText = json["translated_text"] as? String,
               !translatedText.isEmpty {
                
                let processingTime = json["processing_time_ms"] as? Int ?? 0
                print("✅ Translation to \(languageCode) completed in \(processingTime)ms: \(text.prefix(50))... → \(translatedText.prefix(50))...")
                return translatedText
            }
            
            print("⚠️ Failed to parse translation response")
            return text
            
        } catch {
            print("❌ Translation error: \(error.localizedDescription)")
            return text
        }
    }
}
