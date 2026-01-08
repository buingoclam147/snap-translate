import SwiftUI
#if os(macOS)
import AppKit
#endif

class ResultViewModel: ObservableObject {
    static let shared = ResultViewModel()
    
    @Published var capturedImage: NSImage?
    @Published var extractedText: String = ""           // Original text (English)
    @Published var editedEnglishText: String = "" {     // Editable English text
        didSet {
            // Cancel previous debounce timer
            debounceTimer?.invalidate()
            
            // Only translate if text actually changed
            if editedEnglishText != oldValue && !editedEnglishText.isEmpty {
                // Start new debounce timer (2 seconds)
                debounceTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
                    self?.translateExtractedText(self?.editedEnglishText ?? "")
                }
            }
        }
    }
    @Published var translatedText: String = ""          // Translated text
    @Published var isProcessing: Bool = false
    @Published var isTranslating: Bool = false
    @Published var showResult: Bool = false
    @Published var errorMessage: String?
    @Published var selectedLanguage: String = "vi" {    // Default to Vietnamese
        didSet {
            // Save preference
            UserDefaults.standard.set(selectedLanguage, forKey: "preferredLanguage")
            // Re-translate with new language
            if !editedEnglishText.isEmpty {
                translateExtractedText(editedEnglishText)
            }
        }
    }
    
    private var resultWindow: ResultWindow?
    private var debounceTimer: Timer?
    
    private init() {
        // Load saved language preference
        if let saved = UserDefaults.standard.string(forKey: "preferredLanguage") {
            selectedLanguage = saved
        }
    }
    
    func processImage(_ image: NSImage) {
        isProcessing = true
        capturedImage = image
        errorMessage = nil
        translatedText = ""
        
        print("🔄 Starting OCR processing...")
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let startTime = Date()
            let text = OCRService.shared.extractText(from: image)
            let duration = Date().timeIntervalSince(startTime)
            
            DispatchQueue.main.async {
                self?.extractedText = text
                self?.editedEnglishText = text  // Initialize editable text
                self?.isProcessing = false
                self?.showResult = true
                
                if text.isEmpty {
                    self?.errorMessage = "No text detected in image"
                    print("⚠️ OCR: No text found")
                } else {
                    let lineCount = text.components(separatedBy: "\n").count
                    print("✅ OCR completed in \(String(format: "%.2f", duration))s - \(lineCount) lines extracted")
                    print("📄 Extracted text preview: \(text.prefix(100))...")
                }
                
                // Check if should use quick notification
                let useQuickNotification = UserDefaults.standard.bool(forKey: "SnapTranslateUseQuickNotification")
                if useQuickNotification && text.count < 150 {
                    // Show quick notification instead of popover
                    self?.showQuickNotificationForOCR(text: text)
                } else {
                    // Show result window (popover)
                    self?.translateExtractedText(text)
                    self?.showResultWindow()
                }
            }
        }
    }
    
    private func showQuickNotificationForOCR(text: String) {
        print("📢 Using quick notification for OCR (short text: \(text.count) chars)")
        
        let sourceLanguageName = "English"
        let targetLanguageName = getLanguageName(selectedLanguage)
        
        // Show notification immediately (with loading state)
        NotificationCenter.default.post(
            name: NSNotification.Name("ShowQuickNotificationForOCR"),
            object: nil,
            userInfo: [
                "sourceText": text,
                "sourceLang": sourceLanguageName,
                "targetLang": targetLanguageName,
                "targetLanguageCode": selectedLanguage
            ]
        )
        
        // Translate in background
        Task {
            let translated = await TranslationService.shared.translate(text, from: "en", to: selectedLanguage)
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: NSNotification.Name("UpdateQuickNotificationTranslation"),
                    object: translated
                )
            }
        }
    }
    
    private func getLanguageName(_ code: String) -> String {
        let languageNames: [String: String] = [
            "en": "English",
            "vi": "Vietnamese",
            "zh": "Chinese",
            "zh-Hans": "Chinese (Simplified)",
            "zh-Hant": "Chinese (Traditional)",
            "es": "Spanish",
            "fr": "French",
            "de": "German",
            "ja": "Japanese",
            "ko": "Korean",
            "pt": "Portuguese",
            "ru": "Russian",
            "ar": "Arabic",
            "th": "Thai",
            "id": "Indonesian"
        ]
        return languageNames[code] ?? code
    }
    
    // Translate extracted text to selected language
    private func translateExtractedText(_ englishText: String) {
        guard !englishText.isEmpty else { return }
        
        isTranslating = true
        
        Task {
            let translatedText = await TranslationService.shared.translate(englishText, from: "en", to: selectedLanguage)
            
            DispatchQueue.main.async { [weak self] in
                self?.translatedText = translatedText
                self?.isTranslating = false
                print("✅ Translation displayed")
            }
        }
    }
    
    func copyToClipboard() {
        #if os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(extractedText, forType: .string)
        #endif
        print("📋 Text copied to clipboard")
    }
    
    func closeResult() {
        hideResultWindow()
        showResult = false
        capturedImage = nil
        extractedText = ""
        editedEnglishText = ""
        translatedText = ""
        debounceTimer?.invalidate()
        print("✖️ Result closed")
    }
    
    func showResultWindow() {
        DispatchQueue.main.async { [weak self] in
            if self?.resultWindow == nil {
                self?.resultWindow = ResultWindow(viewModel: self ?? ResultViewModel.shared)
            }
            self?.resultWindow?.makeKeyAndOrderFront(nil)
            NSApplication.shared.activate(ignoringOtherApps: true)
            print("📊 Result window displayed")
        }
    }
    
    func hideResultWindow() {
        DispatchQueue.main.async { [weak self] in
            self?.resultWindow?.orderOut(nil)
        }
    }
}
