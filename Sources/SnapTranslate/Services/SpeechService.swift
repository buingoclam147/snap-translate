import Foundation
#if os(macOS)
import AppKit
import AVFoundation

class SpeechService: NSObject, AVSpeechSynthesizerDelegate {
    static let shared = SpeechService()
    
    nonisolated(unsafe) private let synthesizer = AVSpeechSynthesizer()
    nonisolated(unsafe) private var currentUtterance: AVSpeechUtterance?
    
    // Supported languages mapping
    let supportedLanguages: [String: (name: String, locale: String)] = [
        "en": ("English", "en-US"),
        "vi": ("Vietnamese", "vi-VN"),
        "es": ("Spanish", "es-ES"),
        "fr": ("French", "fr-FR"),
        "de": ("German", "de-DE"),
        "it": ("Italian", "it-IT"),
        "pt": ("Portuguese", "pt-BR"),
        "ru": ("Russian", "ru-RU"),
        "ja": ("Japanese", "ja-JP"),
        "ko": ("Korean", "ko-KR"),
        "zh": ("Chinese", "zh-CN"),
        "th": ("Thai", "th-TH"),
        "ar": ("Arabic", "ar-SA"),
        "hi": ("Hindi", "hi-IN"),
        "id": ("Indonesian", "id-ID")
    ]
    
    override init() {
        super.init()
        synthesizer.delegate = self
        print("✅ SpeechService initialized - Text-to-Speech ready")
    }
    
    /// Speak text in specified language
    func speak(_ text: String, languageCode: String, rate: Float = 0.5) {
        guard !text.isEmpty else { return }
        
        // Stop current speech if any
        synthesizer.stopSpeaking(at: .immediate)
        
        let utterance = AVSpeechUtterance(string: text)
        
        // Set language
        if let localeString = supportedLanguages[languageCode]?.locale {
            utterance.voice = AVSpeechSynthesisVoice(language: localeString)
        } else {
            // Fallback to English
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        }
        
        // Configure speech
        utterance.rate = rate  // 0.0 = slowest, 1.0 = fastest, 0.5 = normal
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        currentUtterance = utterance
        
        print("🔊 Speaking \(supportedLanguages[languageCode]?.name ?? "Unknown"): \(text.prefix(60))...")
        synthesizer.speak(utterance)
    }
    
    /// Stop current speech
    func stopSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
            print("⏹️ Speech stopped")
        }
    }
    
    /// Pause speech
    func pauseSpeaking() {
        if synthesizer.isSpeaking {
            synthesizer.pauseSpeaking(at: .immediate)
            print("⏸️ Speech paused")
        }
    }
    
    /// Resume speech
    func continueSpeaking() {
        if synthesizer.isPaused {
            synthesizer.continueSpeaking()
            print("▶️ Speech resumed")
        }
    }
    
    /// Check if currently speaking
    var isSpeaking: Bool {
        return synthesizer.isSpeaking
    }
    
    var isPaused: Bool {
        return synthesizer.isPaused
    }
    
    // MARK: - AVSpeechSynthesizerDelegate
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print("✅ Speech finished")
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        print("❌ Speech cancelled")
    }
}
#endif
