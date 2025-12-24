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
                // Load từ Resources folder trong app bundle
                if let resourcePath = Bundle.main.resourcePath,
                   let nsImage = NSImage(contentsOfFile: "\(resourcePath)/ESnap.png") {
                    Image(nsImage: nsImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                } else {
                    // Fallback nếu không tìm thấy
                    Image(systemName: "text.viewfinder")
                        .font(.system(size: 48, weight: .semibold))
                        .foregroundColor(.blue)
                }
                
                Text("ESnap")
                    .font(.system(size: 32, weight: .bold))
                
                Text("Instant OCR & Translation")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 16)
            
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
                        
                        Text("Capture & Translate (Cmd+Ctrl+C)")
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
