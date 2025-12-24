import SwiftUI

struct ResultPopoverView: View {
    @ObservedObject var viewModel: ResultViewModel
    
    init(viewModel: ResultViewModel) {
        print("🎨 ResultPopoverView.init() - Creating result popover UI (Phase 2)")
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Removed header - now minimal design
            
            // Content: Image on top, Text below
            VStack(spacing: 12) {
                // Top: Image preview (responsive height)
                VStack(spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "text.viewfinder")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.blue)
                        
                        Text("Screenshot")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 8)
                    
                    if let image = viewModel.capturedImage {
                        Image(nsImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 280)
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(6)
                            .padding(8)
                    } else {
                        Color(NSColor.controlBackgroundColor)
                            .frame(height: 280)
                            .cornerRadius(6)
                            .padding(8)
                            .overlay(
                                Text("No image")
                                    .foregroundColor(.gray)
                            )
                    }
                }
                
                Divider()
                    .padding(.vertical, 4)
                
                // Bottom: Split bilingual text (EN left, VI right)
                HStack(spacing: 12) {
                    // Left: English
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("English")
                                .font(.caption)
                                .fontWeight(.semibold)
                            
                            if viewModel.isProcessing {
                                ProgressView()
                                    .scaleEffect(0.7)
                            }
                            
                            Spacer()
                        }
                        .padding(.bottom, 4)
                        
                        ZStack {
                            if viewModel.editedEnglishText.isEmpty {
                                Text("Extracting text...")
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.gray)
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .topLeading)
                            }
                            
                            TextEditor(text: $viewModel.editedEnglishText)
                                .font(.system(.body, design: .monospaced))
                                .lineSpacing(4)
                                .opacity(viewModel.editedEnglishText.isEmpty ? 0.5 : 1.0)
                                .padding(10)
                                .background(Color(NSColor.textBackgroundColor))
                                .cornerRadius(6)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(
                                            Color.blue.opacity(viewModel.editedEnglishText != viewModel.extractedText ? 0.5 : 0),
                                            lineWidth: 2
                                        )
                                )
                        }
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(6)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Right: Translated text
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Translation")
                                .font(.caption)
                                .fontWeight(.semibold)
                            
                            Picker("", selection: $viewModel.selectedLanguage) {
                                ForEach(Array(TranslationService.shared.supportedLanguages.sorted { $0.value < $1.value }), id: \.key) { code, name in
                                    Text(name).tag(code)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: 120)
                            
                            if viewModel.isTranslating {
                                ProgressView()
                                    .scaleEffect(0.7)
                            }
                            
                            Spacer()
                        }
                        
                        ScrollView {
                            if viewModel.translatedText.isEmpty {
                                Text("Translating...")
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.gray)
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .topLeading)
                            } else {
                                Text(viewModel.translatedText)
                                    .font(.system(.body, design: .monospaced))
                                    .lineSpacing(4)
                                    .padding(10)
                                    .frame(maxWidth: .infinity, alignment: .topLeading)
                            }
                        }
                        .background(Color(NSColor.textBackgroundColor))
                        .cornerRadius(6)
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(maxHeight: .infinity)
            }
            .padding(12)
            
            // Footer: Buttons
            Divider()
            
            HStack(spacing: 8) {
                // Copy EN
                Button(action: { viewModel.copyToClipboard() }) {
                    VStack(spacing: 2) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Copy EN")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(10)
                }
                .buttonStyle(.bordered)
                
                // Copy Translation
                Button(action: { copyTranslatedToClipboard() }) {
                    VStack(spacing: 2) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Copy Translation")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(10)
                }
                .buttonStyle(.bordered)
                
                // Read Content (merged button for both EN and Translation)
                Button(action: { toggleReadContent() }) {
                    VStack(spacing: 2) {
                        Image(systemName: SpeechService.shared.isSpeaking ? "speaker.wave.2.fill" : "speaker.wave.2")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Read")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(10)
                }
                .buttonStyle(.bordered)
                .keyboardShortcut("w")
            }
            .padding(12)
        }
        .frame(width: 900, height: 650)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    private func copyTranslatedToClipboard() {
        #if os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(viewModel.translatedText, forType: .string)
        #endif
        print("📋 Translated text copied to clipboard")
    }
    
    // Helper to show if text was edited
    private func isTextEdited() -> Bool {
        return viewModel.editedEnglishText != viewModel.extractedText
    }
    
    private func toggleReadContent() {
        if SpeechService.shared.isSpeaking {
            SpeechService.shared.stopSpeaking()
        } else {
            // Read current selected content (English first, then alternate to translation on next click)
            SpeechService.shared.speak(viewModel.editedEnglishText, languageCode: "en")
        }
    }
}

#Preview {
    ResultPopoverView(viewModel: ResultViewModel.shared)
}
