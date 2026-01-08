import SwiftUI
import AppKit

class QuickNotificationViewModel: ObservableObject {
    @Published var translatedText: String = ""
    @Published var isTranslating: Bool = true
}

struct QuickNotificationView: View {
    let sourceText: String
    let sourceLang: String
    let targetLang: String
    let targetLanguageCode: String
    var onClose: (() -> Void)?
    
    @ObservedObject var viewModel: QuickNotificationViewModel
    @State private var isVisible = true
    private let autoHideDuration: TimeInterval = 10.0
    
    var body: some View {
        HStack(spacing: 12) {
            // Logo
            if let nsImage = NSImage(named: "logo") {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .cornerRadius(6)
            }
            
            // Content Area
            VStack(alignment: .leading, spacing: 6) {
                // Top: Source text
                Text(sourceText)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.primary)
                    .lineLimit(3)
                    .textSelection(.enabled)
                
                Divider()
                    .padding(.vertical, 2)
                
                // Bottom: Translated text or loading state
                if viewModel.isTranslating {
                    HStack(spacing: 4) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Translating...")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text(viewModel.translatedText)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(3)
                        .textSelection(.enabled)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Right buttons: Speaker + Close
            VStack(spacing: 6) {
                // Speaker button (reads source text)
                Button(action: {
                    SpeechService.shared.speak(sourceText, languageCode: "en")
                }) {
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
                .help("Read source text")
                
                // Close button
                Button(action: {
                    DispatchQueue.main.async {
                        self.isVisible = false
                        self.onClose?()
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .buttonStyle(.plain)
                .help("Close")
            }
            .padding(.top, 4)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.windowBackgroundColor))
                .shadow(radius: 4)
        )
        .frame(width: 320, height: 100)
        .padding(16)
        .onAppear {
            // Auto-hide after duration
            DispatchQueue.main.asyncAfter(deadline: .now() + autoHideDuration) {
                if isVisible {
                    isVisible = false
                    onClose?()
                }
            }
        }
    }
}
