import SwiftUI
#if os(macOS)
import AppKit
#endif

class ResultViewModel: ObservableObject {
    static let shared = ResultViewModel()
    
    @Published var capturedImage: NSImage?
    @Published var extractedText: String = ""           // Original text (English)
    @Published var translatedText: String = ""          // Translated text (Vietnamese) - Phase 2
    @Published var isProcessing: Bool = false
    @Published var isTranslating: Bool = false          // Phase 2: Translation loading state
    @Published var showResult: Bool = false
    @Published var errorMessage: String?
    
    private var resultWindow: ResultWindow?
    
    private init() {
        // Observe showResult changes to show/hide window
        observeShowResult()
    }
    
    private func observeShowResult() {
        // This will be called whenever showResult changes
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
                
                // Phase 2: Trigger translation
                self?.translateExtractedText(text)
                
                // Show result window
                self?.showResultWindow()
            }
        }
    }
    
    // Phase 2: Translate extracted text to Vietnamese
    private func translateExtractedText(_ englishText: String) {
        guard !englishText.isEmpty else { return }
        
        isTranslating = true
        
        Task {
            let vietnameseText = await TranslationService.shared.translateToVietnamese(englishText)
            
            DispatchQueue.main.async { [weak self] in
                self?.translatedText = vietnameseText
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
        translatedText = ""
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
