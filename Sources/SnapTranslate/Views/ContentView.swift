import SwiftUI
#if os(macOS)
import AppKit
#endif

struct ContentView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Logo/Title
            VStack(spacing: 8) {
                Image(systemName: "text.viewfinder")
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundColor(.blue)
                
                Text("SnapTranslate")
                    .font(.system(size: 32, weight: .bold))
                
                Text("Instant OCR & Translation")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 24)
            
            // Buttons
            VStack(spacing: 12) {
                // Capture Button
                Button(action: {
                    print("🔧 [UI] Capture button clicked")
                    CaptureViewModel.shared.startCapture()
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text("Capture & Translate")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(12)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .keyboardShortcut("c", modifiers: [.command, .control])
                
                // Settings Button
                Button(action: { openSystemPreferences() }) {
                    HStack(spacing: 12) {
                        Image(systemName: "gear")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text("Open Settings")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(12)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .padding(.horizontal, 32)
            
            Spacer()
            
            // Footer
            VStack(spacing: 4) {
                Text("Press Cmd+Ctrl+C to capture anywhere")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.gray)
                
                Text("Phase 2: UI + Translation")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.gray.opacity(0.6))
            }
            .padding(.bottom, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    private func openSystemPreferences() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }
}

#Preview {
    ContentView()
}
