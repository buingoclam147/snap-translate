import SwiftUI

struct ResultPopoverView: View {
    @ObservedObject var viewModel: ResultViewModel
    
    init(viewModel: ResultViewModel) {
        print("🎨 ResultPopoverView.init() - Creating result popover UI (Phase 2)")
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "text.viewfinder")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue)
                    
                    Text("OCR & Translation")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                if viewModel.isProcessing || viewModel.isTranslating {
                    ProgressView()
                        .scaleEffect(0.8)
                }
                
                Button(action: { viewModel.closeResult() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
                .help("Close (Cmd+W)")
            }
            .padding(12)
            .background(Color(NSColor.controlBackgroundColor))
            
            // Content: Image on top, Text below
            VStack(spacing: 12) {
                // Top: Image preview (responsive height)
                VStack(spacing: 4) {
                    Text("Screenshot")
                        .font(.caption)
                        .fontWeight(.semibold)
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
                        
                        ScrollView {
                            if viewModel.extractedText.isEmpty {
                                Text("Extracting text...")
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.gray)
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .topLeading)
                            } else {
                                Text(viewModel.extractedText)
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
                    
                    // Right: Vietnamese
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Vietnamese")
                                .font(.caption)
                                .fontWeight(.semibold)
                            
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
            
            HStack(spacing: 10) {
                Button(action: { viewModel.copyToClipboard() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "doc.on.doc")
                        Text("Copy EN")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                Button(action: { copyVietnameseToClipboard() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "doc.on.doc")
                        Text("Copy VI")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                Button(action: { viewModel.closeResult() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "xmark")
                        Text("Close")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .keyboardShortcut("w")
            }
            .padding(12)
        }
        .frame(width: 900, height: 650)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    private func copyVietnameseToClipboard() {
        #if os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(viewModel.translatedText, forType: .string)
        #endif
        print("📋 Vietnamese text copied to clipboard")
    }
}

#Preview {
    ResultPopoverView(viewModel: ResultViewModel.shared)
}
