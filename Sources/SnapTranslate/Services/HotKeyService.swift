import Foundation
#if os(macOS)
import AppKit
import Carbon

class HotKeyService: NSObject {
    static let shared = HotKeyService()
    
    private var hotKeyRef: EventHotKeyRef?
    var onHotKeyPressed: (() -> Void)?
    
    override init() {
        super.init()
    }
    
    func start() {
        print("\n" + String(repeating: "=", count: 70))
        print("🎯 HotKeyService.start() - Global Hotkey Listener (Carbon API)")
        print("📝 Using RegisterEventHotKey (no permissions required)")
        print(String(repeating: "=", count: 70) + "\n")
        
        registerGlobalHotkey()
    }
    
    // MARK: - Carbon Event Handler
    
    private func registerGlobalHotkey() {
        // Register the keyboard event handler
        var eventType = EventTypeSpec()
        eventType.eventClass = OSType(kEventClassKeyboard)
        eventType.eventKind = OSType(kEventHotKeyPressed)
        
        let status = InstallEventHandler(
            GetApplicationEventTarget(),
            { (nextHandler, theEvent, userData) -> OSStatus in
                let hotKeyService = Unmanaged<HotKeyService>.fromOpaque(userData!).takeUnretainedValue()
                hotKeyService.handleHotKeyEvent(theEvent)
                return noErr
            },
            1,
            &eventType,
            Unmanaged.passUnretained(self).toOpaque(),
            nil
        )
        
        guard status == noErr else {
            print("❌ Failed to install event handler")
            return
        }
        
        // Register the actual hotkey: Cmd + Ctrl + C
        let keyCode: UInt32 = 8  // C key
        let modifiers: UInt32 = UInt32(cmdKey | controlKey)
        
        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = OSType("snap".fourCharCodeValue)
        hotKeyID.id = 1
        
        let registerStatus = RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        
        guard registerStatus == noErr else {
            print("❌ Failed to register hotkey")
            return
        }
        
        print("✅ Global hotkey registered successfully")
        print("✅ Listening for: Cmd + Ctrl + C")
        print("✅ Works in ANY app (global hotkey)")
        print("✅ NO permissions required!\n")
    }
    
    // MARK: - Event Handling
    
    private func handleHotKeyEvent(_ event: EventRef?) {
        guard let event = event else { return }
        
        var hotKeyID = EventHotKeyID()
        let paramSize = MemoryLayout<EventHotKeyID>.size
        
        let status = GetEventParameter(
            event,
            EventParamName(kEventParamDirectObject),
            EventParamType(typeEventHotKeyID),
            nil,
            paramSize,
            nil,
            &hotKeyID
        )
        
        guard status == noErr else {
            return
        }
        
        // Verify this is our hotkey
        if hotKeyID.id == 1 {
            print("\n" + String(repeating: "🔥", count: 40))
            print("🔥🔥🔥 GLOBAL HOTKEY: Cmd + Ctrl + C DETECTED 🔥🔥🔥")
            print(String(repeating: "🔥", count: 40) + "\n")
            
            if onHotKeyPressed != nil {
                print("✅ Calling hotkey handler")
                DispatchQueue.main.async {
                    self.onHotKeyPressed?()
                }
            } else {
                print("❌ ERROR: Handler is nil!")
            }
        }
    }
    
    func stop() {
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
            hotKeyRef = nil
        }
        print("🛑 HotKeyService stopped")
    }
    
    deinit {
        stop()
    }
}

// MARK: - Helper Extension

extension String {
    /// Converts string to OSType (4-character code)
    /// Example: "snap" → 0x736E6170
    var fourCharCodeValue: Int {
        var result: Int = 0
        if let data = self.data(using: String.Encoding.macOSRoman) {
            data.withUnsafeBytes { rawBytes in
                let bytes = rawBytes.bindMemory(to: UInt8.self)
                for i in 0 ..< data.count {
                    result = result << 8 + Int(bytes[i])
                }
            }
        }
        return result
    }
}

#endif
