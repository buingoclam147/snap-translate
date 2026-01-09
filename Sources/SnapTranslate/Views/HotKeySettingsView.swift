import SwiftUI
import AppKit

struct HotKeySettingsView: View {
    @State private var ocrHotkey = ""
    @State private var translateHotkey = ""
    @State private var prioritizeChineseOCR = false
    @State private var autoCloseDelay: Double = 10
    @State private var isRecordingOCR = false
    @State private var isRecordingTranslate = false
    @State private var recordingText = ""
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
            
            // OCR Hotkey Section
            VStack(alignment: .leading, spacing: 8) {
                Text("OCR Hotkey")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                
                if !isRecordingOCR {
                    HStack {
                        Text(ocrHotkey)
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            .padding(8)
                            .background(Color(nsColor: .controlBackgroundColor))
                            .cornerRadius(4)
                        
                        Spacer()
                        
                        Button(action: startRecordingOCR) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(.plain)
                        .help("Edit OCR hotkey")
                    }
                } else {
                    recordingSection(title: "Recording OCR hotkey...", isOCR: true)
                }
            }
            
            Divider()
            
            // Translate Hotkey Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Translate Hotkey")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                
                if !isRecordingTranslate {
                    HStack {
                        Text(translateHotkey)
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            .padding(8)
                            .background(Color(nsColor: .controlBackgroundColor))
                            .cornerRadius(4)
                        
                        Spacer()
                        
                        Button(action: startRecordingTranslate) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(.plain)
                        .help("Edit translate hotkey")
                    }
                } else {
                    recordingSection(title: "Recording translate hotkey...", isOCR: false)
                }
            }
            
            Divider()
            
            // Popover Options Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Popover Options")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("Auto-close after (seconds):")
                        .font(.system(size: 11))
                    
                    TextField("", value: $autoCloseDelay, format: .number)
                        .font(.system(size: 11, design: .monospaced))
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                        .onChange(of: autoCloseDelay) { newValue in
                            let clamped = max(1, min(newValue, 3600))
                            autoCloseDelay = clamped
                            UserDefaults.standard.set(clamped, forKey: "SnapTranslateAutoCloseDelay")
                            print("⏱️ Auto-close delay set to: \(clamped) seconds")
                        }
                }
                
                Text("Enter delay in seconds (1-3600). Popover closes automatically after translation completes.")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            Divider()
            
            // OCR Options Section
            VStack(alignment: .leading, spacing: 8) {
                Text("OCR Options")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                
                Toggle("Prioritize Chinese Recognition", isOn: $prioritizeChineseOCR)
                    .font(.system(size: 11))
                    .onChange(of: prioritizeChineseOCR) { newValue in
                        HotKeyManager.shared.savePrioritizeChineseOCR(newValue)
                        print("🇨🇳 Chinese prioritization toggled: \(newValue)")
                        
                        // Auto-set languages when prioritization is enabled
                        if newValue {
                            TranslatorViewModel.shared.setPrioritizeChineseLanguages()
                            print("🇨🇳 Source language set to Chinese, target set to English")
                        }
                    }
                
                Text("When enabled, OCR will prioritize Chinese (Simplified & Traditional) character recognition")
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            Divider()
            
            // Reset Hotkey button
            Button(action: resetHotkeys) {
                Label("Reset to Default", systemImage: "arrow.counterclockwise")
                    .font(.system(size: 11))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            
            Divider()
            
            // Close App button
            Button(action: closeApp) {
                Label("Close App", systemImage: "xmark.circle.fill")
                    .font(.system(size: 11))
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .foregroundColor(.white)
            .tint(.red)
        }
        .padding(12)
        .frame(width: 320, height: 500)
        .onAppear(perform: loadHotkeys)
        .onDisappear(perform: stopRecording)
    }
    
    // MARK: - Recording Section Component
    
    @ViewBuilder
    private func recordingSection(title: String, isOCR: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "circle.fill")
                    .font(.system(size: 6))
                    .foregroundColor(.red)
                Text(title)
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
                    isRecordingOCR = false
                    isRecordingTranslate = false
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button("Save") {
                    saveRecordedHotkey(isOCR: isOCR)
                    stopRecording()
                    isRecordingOCR = false
                    isRecordingTranslate = false
                }
                .buttonStyle(.borderedProminent)
                .disabled(recordingText == "Press keys...")
            }
            .font(.system(size: 11))
        }
    }
    
    // MARK: - Recording Handlers
    
    private func startRecordingOCR() {
        isRecordingOCR = true
        recordingText = "Press keys..."
        startRecording()
    }
    
    private func startRecordingTranslate() {
        isRecordingTranslate = true
        recordingText = "Press keys..."
        startRecording()
    }
    
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
    
    // MARK: - Save & Reset Logic
    
    private func saveRecordedHotkey(isOCR: Bool) {
        if isOCR {
            ocrHotkey = recordingText
            HotKeyManager.shared.saveOCRHotKey(recordingText)
            print("💾 OCR Hotkey saved: \(recordingText)")
            
            // Update HotKeyService to re-register the hotkey
            HotKeyService.shared.updateAndRegisterHotkey(for: "ocr", hotKey: recordingText)
            
            NotificationCenter.default.post(name: NSNotification.Name("OCRHotKeyChanged"), object: recordingText)
        } else {
            translateHotkey = recordingText
            HotKeyManager.shared.saveTranslateHotKey(recordingText)
            print("💾 Translate Hotkey saved: \(recordingText)")
            
            // Update hotkey for translate
            updateTranslateHotkey(recordingText)
            
            NotificationCenter.default.post(name: NSNotification.Name("TranslateHotKeyChanged"), object: recordingText)
        }
    }
    
    private func resetHotkeys() {
        ocrHotkey = "Cmd+Shift+C"
        translateHotkey = "Cmd+Shift+X"
        
        HotKeyManager.shared.saveOCRHotKey("Cmd+Shift+C")
        HotKeyManager.shared.saveTranslateHotKey("Cmd+Shift+X")
        
        HotKeyService.shared.updateAndRegisterHotkey(for: "ocr", hotKey: "Cmd+Shift+C")
        updateTranslateHotkey("Cmd+Shift+X")
        
        print("🔄 All hotkeys reset to default")
        
        NotificationCenter.default.post(name: NSNotification.Name("OCRHotKeyChanged"), object: "Cmd+Shift+C")
        NotificationCenter.default.post(name: NSNotification.Name("TranslateHotKeyChanged"), object: "Cmd+Shift+X")
    }
    
    private func closeApp() {
        NSApplication.shared.terminate(nil)
    }
    
    private func loadHotkeys() {
        ocrHotkey = HotKeyManager.shared.getOCRHotKey()
        translateHotkey = HotKeyManager.shared.getTranslateHotKey()
        prioritizeChineseOCR = HotKeyManager.shared.getPrioritizeChineseOCR()
        autoCloseDelay = UserDefaults.standard.double(forKey: "SnapTranslateAutoCloseDelay")
        if autoCloseDelay == 0 {
            autoCloseDelay = 10 // Default to 10 seconds
        }
    }
    
    private func updateTranslateHotkey(_ hotKey: String) {
        // Parse and update EscapeKeyService with new hotkey
        let parts = hotKey.components(separatedBy: "+")
        var keyCode: UInt16 = 7  // Default to X
        var modifiers = NSEvent.ModifierFlags()
        
        for part in parts {
            switch part.lowercased() {
            case "cmd":
                modifiers.insert(.command)
            case "shift":
                modifiers.insert(.shift)
            case "ctrl":
                modifiers.insert(.control)
            case "opt", "option":
                modifiers.insert(.option)
            case "x":
                keyCode = 7
            case "c":
                keyCode = 8
            case "v":
                keyCode = 9
            default:
                break
            }
        }
        
        // Store in UserDefaults for EscapeKeyService to use
        UserDefaults.standard.set(hotKey, forKey: "SnapTranslateHotKey")
        
        print("✅ Translate hotkey updated to: \(hotKey)")
    }
}

#Preview {
    HotKeySettingsView()
}
