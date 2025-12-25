import SwiftUI
import AppKit

struct HotKeySettingsView: View {
    @State private var hotKeyDisplay = ""
    @State private var isRecording = false
    @State private var recordedKeys: [String] = []
    @State private var recordingText = ""
    @State private var reminderEnabled = false
    @State private var eventMonitor: Any?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 16) {
            // Title
            HStack {
                Text("Settings")
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12))
                }
                .buttonStyle(.plain)
            }
            
            Divider()
            
            // Hotkey Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Hotkey")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                
                if !isRecording {
                    // Display mode
                    HStack {
                        Text(hotKeyDisplay)
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            .padding(8)
                            .background(Color(nsColor: .controlBackgroundColor))
                            .cornerRadius(4)
                        
                        Spacer()
                        
                        Button(action: {
                            isRecording = true
                            recordedKeys = []
                            recordingText = "Press keys..."
                            startRecording()
                        }) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    // Recording mode
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 6))
                                .foregroundColor(.red)
                            Text("Recording - Press hotkey combination")
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                        
                        Text(recordingText)
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            .padding(8)
                            .background(Color(nsColor: .controlBackgroundColor))
                            .cornerRadius(4)
                            .frame(maxWidth: .infinity)
                        
                        HStack(spacing: 8) {
                            Button("Cancel") {
                                stopRecording()
                                isRecording = false
                            }
                            .keyboardShortcut(.cancelAction)
                            
                            Spacer()
                            
                            Button("Save") {
                                hotKeyDisplay = recordingText
                                HotKeyManager.shared.saveHotKey(recordingText)
                                // Notify home screen to update
                                NotificationCenter.default.post(name: NSNotification.Name("HotKeyChanged"), object: recordingText)
                                stopRecording()
                                isRecording = false
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(recordingText == "Press keys...")
                        }
                        .font(.system(size: 11))
                    }
                }
            }
            
            Divider()
            
            // Reset button
            Button(action: {
                let defaultKey = "Cmd+Shift+C"
                hotKeyDisplay = defaultKey
                HotKeyManager.shared.saveHotKey(defaultKey)
                NotificationCenter.default.post(name: NSNotification.Name("HotKeyChanged"), object: defaultKey)
            }) {
                Label("Reset to Default", systemImage: "arrow.counterclockwise")
                    .font(.system(size: 11))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            
            Spacer()
        }
        .padding(12)
        .frame(width: 300)
        .onAppear {
            hotKeyDisplay = HotKeyManager.shared.getSavedHotKey()
            reminderEnabled = UserDefaults.standard.bool(forKey: "SnapTranslateReminder")
        }
        .onDisappear {
            stopRecording()
        }
    }
    
    // MARK: - Key Recording
    
    private func startRecording() {
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let modifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            handleKeyPress(event.keyCode, modifiers: modifiers)
            return nil // Consume event
        }
    }
    
    private func stopRecording() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
    
    private func handleKeyPress(_ keyCode: UInt16, modifiers: NSEvent.ModifierFlags) {
        var display = ""
        
        if modifiers.contains(.command) { display += "Cmd+" }
        if modifiers.contains(.shift) { display += "Shift+" }
        if modifiers.contains(.control) { display += "Ctrl+" }
        if modifiers.contains(.option) { display += "Opt+" }
        
        if let keyName = getKeyName(for: keyCode) {
            display += keyName
            recordingText = display
            recordedKeys = [keyName]
        }
    }
    
    private func getKeyName(for keyCode: UInt16) -> String? {
        switch keyCode {
        case 0: return "A"
        case 1: return "S"
        case 2: return "D"
        case 3: return "F"
        case 4: return "H"
        case 5: return "G"
        case 6: return "Z"
        case 7: return "X"
        case 8: return "C"
        case 9: return "V"
        case 11: return "B"
        case 12: return "Q"
        case 13: return "W"
        case 14: return "E"
        case 15: return "R"
        case 16: return "Y"
        case 17: return "T"
        case 31: return "O"
        case 32: return "U"
        case 34: return "I"
        case 35: return "P"
        case 37: return "L"
        case 38: return "J"
        case 40: return "K"
        case 45: return "N"
        case 46: return "M"
        default: return nil
        }
    }
}

#Preview {
    HotKeySettingsView()
}
