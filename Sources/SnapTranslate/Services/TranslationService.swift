import Foundation

class TranslationService {
    static let shared = TranslationService()
    
    // Translation manager with fallback mechanism
    private let manager = TranslationManager.shared
    
    // Retry configuration
    private let maxRetries = 3
    private let retryDelay: UInt64 = 1_000_000_000  // 1 second in nanoseconds
    
    // Supported language pairs
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
    
    // Track API status for user notifications
    private var lastErrorMessage: String = ""
    
    private init() {
        print("✅ TranslationService initialized - Using Public APIs with Fallback Mechanism")
    }
    
    /// Translate text between any languages with automatic fallback
    func translate(_ text: String, from sourceLanguage: String, to targetLanguage: String) async -> String {
        guard !text.isEmpty else { return "" }
        
        let charCount = text.count
        print("📊 Text has \(charCount) characters")
        print("   Debug: \(text) (bytes: \(text.utf8.count))")
        
        // Use translation manager with retry logic
        return await translateWithRetry(text, from: sourceLanguage, to: targetLanguage)
    }
    
    /// Translate with retry mechanism (try up to maxRetries times)
    private func translateWithRetry(_ text: String, from sourceLanguage: String, to targetLanguage: String) async -> String {
        print("\n" + String(repeating: "📡", count: 60))
        print("📡📡📡 TranslationService.translateWithRetry() 📡📡📡")
        print(String(repeating: "📡", count: 60))
        print("📤 Sending to translation API: \(text.prefix(60))...")
        print("   Input length: \(text.count) chars")
        print("   Lang: \(sourceLanguage) → \(targetLanguage)")
        
        for attempt in 1...maxRetries {
            print("\n🔁 ATTEMPT \(attempt)/\(maxRetries):")
            let result = await manager.translate(text, from: sourceLanguage, to: targetLanguage)
            
            if result.isSuccess {
                print("\n✅ Translation successful!")
                print("   Provider: \(result.provider)")
                print("   Output length: \(result.text.count) chars")
                print("   Output: \(result.text.prefix(100))...")
                print(String(repeating: "✅", count: 60) + "\n")
                return result.text
            }
            
            print("   ❌ This attempt failed!")
            if let error = result.error {
                print("   Error details:\n\(error)")
            }
            
            // Don't retry on the last attempt
            if attempt < maxRetries {
                try? await Task.sleep(nanoseconds: retryDelay)
                print("\n⏳ Waiting 1 second before retry...")
                print("🔄 Retrying with next attempt...\n")
            }
        }
        
        print("\n" + String(repeating: "⚠️", count: 60))
        print("⚠️ ALL \(maxRetries) ATTEMPTS FAILED")
        print(String(repeating: "⚠️", count: 60))
        
        // All retries failed - show error message
        return await handleAllProvidersFailed(text, from: sourceLanguage, to: targetLanguage)
    }
    
    /// Handle case when all providers fail
    private func handleAllProvidersFailed(_ text: String, from sourceLanguage: String, to targetLanguage: String) async -> String {
        print("\n" + String(repeating: "❌", count: 60))
        print("❌ FINAL FAILURE: All translation providers failed")
        print("❌ Language pair: \(sourceLanguage) → \(targetLanguage)")
        print("❌ Text: \(text.prefix(80))")
        print(String(repeating: "❌", count: 60) + "\n")
        
        let errorMessage = """
        ⚠️ Lỗi Dịch Thuật
        
        Không thể dịch văn bản lúc này. Các API dịch thuật đã fail sau 3 lần thử.
        Vui lòng kiểm tra kết nối mạng hoặc thử lại sau.
        
        Liên hệ hỗ trợ: buingoclam00@gmail.com
        
        ⚠️ Translation Error
        
        Failed to translate after 3 retry attempts.
        Please check your network connection or try again later.
        
        Contact support: buingoclam00@gmail.com
        """
        
        lastErrorMessage = errorMessage
        print(errorMessage)
        
        return text  // Return original text on complete failure
    }
    
    /// Get last error message (useful for UI display)
    func getLastError() -> String {
        return lastErrorMessage
    }
}
