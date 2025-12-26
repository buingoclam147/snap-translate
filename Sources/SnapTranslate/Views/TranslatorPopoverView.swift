import SwiftUI

class TranslatorViewModel: ObservableObject {
    static let shared = TranslatorViewModel()
    
    @Published var capturedImage: NSImage? {
        didSet {
            if capturedImage != nil {
                // Perform OCR on captured image
                performOCR()
            }
        }
    }
    @Published var isProcessing: Bool = false
    
    @Published var sourceText: String = "" {
        didSet {
            // Cancel previous debounce timer
            debounceTimer?.invalidate()
            
            // Debounce translation - wait 2 seconds before translating
            // But NOT if text was set from OCR or hotkey (translate immediately)
            if !sourceText.isEmpty {
                if isFromOCR || isFromHotkey {
                    // Translate immediately for OCR and hotkey
                    isFromOCR = false
                    isFromHotkey = false
                    performTranslation()
                } else {
                    // Debounce for manual typing
                    debounceTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
                        self?.performTranslation()
                    }
                }
            } else {
                translatedText = ""
            }
        }
    }
    
    @Published var translatedText: String = ""
    @Published var sourceLanguage: String = "en" {
        didSet {
            UserDefaults.standard.set(sourceLanguage, forKey: "translatorSourceLanguage")
            // Debounce language changes to prevent multiple API calls
            debounceLanguageChange()
        }
    }
    @Published var targetLanguage: String = "vi" {
        didSet {
            UserDefaults.standard.set(targetLanguage, forKey: "translatorTargetLanguage")
            // Debounce language changes to prevent multiple API calls
            debounceLanguageChange()
        }
    }
    @Published var isTranslating: Bool = false
    
    private var debounceTimer: Timer?
    private var languageChangeTimer: Timer?
    private var isFromOCR = false
    private var isFromHotkey = false
    
    private init() {
        // Load saved preferences
        if let saved = UserDefaults.standard.string(forKey: "translatorSourceLanguage") {
            sourceLanguage = saved
        }
        if let saved = UserDefaults.standard.string(forKey: "translatorTargetLanguage") {
            targetLanguage = saved
        }
    }
    
    private func debounceLanguageChange() {
        // Cancel previous language change timer
        languageChangeTimer?.invalidate()
        
        // Only trigger translation if text is not empty
        guard !sourceText.isEmpty else { return }
        
        // Debounce language changes by 0.3 seconds
        // This prevents multiple API calls when swap button is clicked (2 didSet triggers)
        languageChangeTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
            self?.performTranslation()
        }
    }
    
    private func performTranslation() {
        guard !sourceText.isEmpty else { return }
        
        isTranslating = true
        
        Task {
            let translated = await TranslationService.shared.translate(sourceText, from: sourceLanguage, to: targetLanguage)
            
            DispatchQueue.main.async { [weak self] in
                self?.translatedText = translated
                self?.isTranslating = false
            }
        }
    }
    
    func swapLanguages() {
        // Swap language codes
        let tempLang = sourceLanguage
        sourceLanguage = targetLanguage
        targetLanguage = tempLang
        
        // Swap text contents
        let tempText = sourceText
        sourceText = translatedText
        translatedText = tempText
    }
    
    func copySourceText() {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(sourceText, forType: .string)
        #endif
    }
    
    func copyTranslatedText() {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(translatedText, forType: .string)
        #endif
    }
    
    func clearSourceText() {
        sourceText = ""
    }
    
    func pasteFromClipboard() {
        #if os(macOS)
        if let pastedText = NSPasteboard.general.string(forType: .string) {
            isFromHotkey = true
            sourceText = pastedText
        }
        #endif
    }
    
    private func performOCR() {
        guard let image = capturedImage else { return }
        
        isProcessing = true
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let text = OCRService.shared.extractText(from: image)
            
            DispatchQueue.main.async { [weak self] in
                self?.isFromOCR = true
                self?.sourceText = text
                self?.isProcessing = false
                print("✅ OCR completed, text populated to input")
            }
        }
    }
    
    func setTextFromHotkey(_ text: String) {
        isFromHotkey = true
        sourceText = text
    }
}

struct TranslatorPopoverView: View {
    @ObservedObject var viewModel = TranslatorViewModel.shared
    @FocusState private var isInputFocused: Bool
    var onClose: (() -> Void)?
    var onOCRTapped: (() -> Void)?
    var onSupportTapped: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Translate")
                    .font(.system(size: 16, weight: .semibold))
                
                Spacer()
                
                // OCR Button
                Button(action: { onOCRTapped?() }) {
                    Image(systemName: "text.viewfinder")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
                .help("Capture & OCR")
                
                // Support Button
                Button(action: { onSupportTapped?() }) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
                .help("Support & Help")
                
                // Settings Button
                Button(action: {
                    NotificationCenter.default.post(name: NSNotification.Name("OpenTranslatorSettings"), object: nil)
                }) {
                    Image(systemName: "gear")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
                .help("Settings")
                
                // Minimize Button
                Button(action: {
                    print("\n" + String(repeating: "📦", count: 40))
                    print("📦📦📦 MINIMIZE BUTTON TAPPED - CLOSING Popover 📦📦📦")
                    print(String(repeating: "📦", count: 40) + "\n")
                    onClose?()
                }) {
                    Image(systemName: "minus.circle")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
                .help("Minimize")
            }
            .padding(12)
            .background(Color(NSColor.controlBackgroundColor))
            .borderBottom()
            
            // Image Preview (if captured via OCR)
            if let image = viewModel.capturedImage {
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "photo")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.blue)
                        Text("Screenshot")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Spacer()
                        
                        // Close button (X)
                        Button(action: {
                            viewModel.capturedImage = nil
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        .buttonStyle(.plain)
                        .help("Close screenshot")
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 150)
                        .padding(8)
                }
                .background(Color(NSColor.windowBackgroundColor))
                .borderBottom()
            }
            
            // Language Selector (above text areas)
            HStack(spacing: 0) {
                // Source Language
                Picker("", selection: $viewModel.sourceLanguage) {
                    Text("English").tag("en")
                    ForEach(Array(TranslationService.shared.supportedLanguages.sorted { $0.value < $1.value }), id: \.key) { code, name in
                        Text(name).tag(code)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity)
                
                // Swap button
                Button(action: viewModel.swapLanguages) {
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.blue)
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)
                .help("Swap languages")
                
                // Target Language
                Picker("", selection: $viewModel.targetLanguage) {
                    Text("English").tag("en")
                    ForEach(Array(TranslationService.shared.supportedLanguages.sorted { $0.value < $1.value }), id: \.key) { code, name in
                        Text(name).tag(code)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(NSColor.windowBackgroundColor))
            .borderBottom()
            
            // Text Areas (split view)
            HStack(spacing: 12) {
                // Source Text Editor
                VStack(alignment: .leading, spacing: 0) {
                    ZStack(alignment: .topTrailing) {
                        if viewModel.sourceText.isEmpty {
                            Text("Enter text to translate...")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.gray)
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                        }
                        
                        TextEditor(text: $viewModel.sourceText)
                            .font(.system(.body, design: .default))
                            .lineSpacing(3)
                            .opacity(viewModel.sourceText.isEmpty ? 0.5 : 1.0)
                            .padding(10)
                            .background(Color(NSColor.textBackgroundColor))
                            .cornerRadius(6)
                            .focused($isInputFocused)
                            .onAppear {
                                isInputFocused = true
                            }
                            .addPasteShortcut(viewModel: viewModel)
                        
                        VStack(alignment: .trailing, spacing: 6) {
                            // Clear button (X) - top right
                            Button(action: viewModel.clearSourceText) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                            .buttonStyle(.plain)
                            .help("Clear input")
                            .disabled(viewModel.sourceText.isEmpty)
                            .padding(8)
                            
                            Spacer()
                            
                            // Bottom right buttons (Copy + Read)
                            HStack(spacing: 8) {
                                // Copy button
                                Button(action: viewModel.copySourceText) {
                                    Image(systemName: "doc.on.doc")
                                        .font(.system(size: 12))
                                        .foregroundColor(.blue)
                                }
                                .buttonStyle(.plain)
                                .help("Copy input text")
                                .disabled(viewModel.sourceText.isEmpty)
                                
                                // Read button
                                Button(action: { }) {
                                    Image(systemName: "speaker.wave.2")
                                        .font(.system(size: 12))
                                        .foregroundColor(.blue)
                                }
                                .buttonStyle(.plain)
                                .help("Read input text")
                                .disabled(viewModel.sourceText.isEmpty)
                            }
                            .padding(8)
                        }
                        .frame(maxHeight: .infinity, alignment: .topTrailing)
                    }
                }
                .frame(maxWidth: .infinity)
                
                // Translated Text
                VStack(alignment: .leading, spacing: 0) {
                    ZStack(alignment: .bottomTrailing) {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 0) {
                                if viewModel.sourceText.isEmpty {
                                    Text("Translation will appear here...")
                                        .font(.system(.caption, design: .monospaced))
                                        .foregroundColor(.gray)
                                        .padding(12)
                                } else if viewModel.translatedText.isEmpty {
                                    if viewModel.isTranslating {
                                        HStack {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                            Text("Translating...")
                                                .font(.system(.caption, design: .monospaced))
                                                .foregroundColor(.gray)
                                        }
                                        .padding(12)
                                    }
                                } else {
                                    Text(viewModel.translatedText)
                                        .font(.system(.body, design: .default))
                                        .lineSpacing(3)
                                        .padding(10)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                        }
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(6)
                        
                        // Copy button - floating bottom right
                        Button(action: viewModel.copyTranslatedText) {
                            Image(systemName: "doc.on.doc")
                                .font(.system(size: 12))
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(.plain)
                        .help("Copy translated text")
                        .disabled(viewModel.translatedText.isEmpty)
                        .padding(8)
                        }
                        }
                .frame(maxWidth: .infinity)
            }
            .padding(12)
        }
        .frame(width: 700, height: 450)
        .background(Color(NSColor.windowBackgroundColor))
        .onAppear {
            print("\n" + String(repeating: "=", count: 70))
            print("📝 TranslatorPopoverView.onAppear() - Setting up ESC listener")
            print("🔑 User can press ESC to close popover")
            print(String(repeating: "=", count: 70) + "\n")
            
            // Set up ESC key handler for closing popover
            EscapeKeyService.shared.onEscapePressed = {
                print("\n" + String(repeating: "✋", count: 40))
                print("✋✋✋ POPOVER: ESC Pressed - CLOSING Popover ✋✋✋")
                print(String(repeating: "✋", count: 40) + "\n")
                onClose?()
            }
        }
        .onDisappear {
            print("\n" + String(repeating: "-", count: 70))
            print("📝 TranslatorPopoverView.onDisappear() - Cleaning up ESC listener")
            print(String(repeating: "-", count: 70) + "\n")
            // Clear handler when popover closes
            EscapeKeyService.shared.onEscapePressed = nil
        }
    }
}

// Helper extension for border
extension View {
    func borderBottom() -> some View {
        self.border(Color(NSColor.separatorColor), width: 1)
    }
    
    func addPasteShortcut(viewModel: TranslatorViewModel) -> some View {
        #if os(macOS)
        if #available(macOS 14.0, *) {
            return AnyView(
                self.onKeyPress { keyPress in
                    if keyPress.modifiers.contains(.command) && keyPress.characters == "v" {
                        viewModel.pasteFromClipboard()
                        return .handled
                    }
                    return .ignored
                }
            )
        }
        #endif
        return AnyView(self)
    }
}

#Preview {
    TranslatorPopoverView()
}
