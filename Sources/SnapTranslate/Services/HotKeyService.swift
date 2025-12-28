import Foundation
#if os(macOS)
import AppKit
import Carbon

class HotKeyService: NSObject {
    static let shared = HotKeyService()
    
    private var hotKeyRef: EventHotKeyRef?
    private var eventHandlerRef: EventHandlerRef?
    var onHotKeyPressed: (() -> Void)?
    
    override init() {
        super.init()
    }
    
    func start() {
        print("\n" + String(repeating: "=", count: 70))
        print("🎯 HotKeyService.start() - Global Hotkey Listener (Carbon API)")
        print("📝 Using RegisterEventHotKey (no permissions required)")
        print(String(repeating: "=", count: 70) + "\n")
        
        installEventHandlerOnce()
        registerGlobalHotkey()
    }
    
    // MARK: - Install Event Handler (Once Only)
    
    private func installEventHandlerOnce() {
        guard eventHandlerRef == nil else {
            print("✅ Event handler already installed, skipping...")
            return
        }
        
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
            &eventHandlerRef
        )
        
        guard status == noErr else {
            print("❌ Failed to install event handler")
            return
        }
        
        print("✅ Event handler installed successfully")
    }
    
    // MARK: - Register Hotkey
    
    private func registerGlobalHotkey() {
        // Unregister old hotkey if exists
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
            hotKeyRef = nil
            print("🔄 Old hotkey unregistered")
        }
        
        // Get hotkey from saved settings
        let savedHotKey = HotKeyManager.shared.getSavedHotKey()
        let (keyCode, modifiers) = HotKeyManager.shared.parseHotKey(savedHotKey)
        
        print("📍 Registering hotkey: \(savedHotKey) (keyCode=\(keyCode), modifiers=\(modifiers))")
        
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
            print("❌ Failed to register hotkey: \(registerStatus)")
            return
        }
        
        print("✅ Global hotkey registered successfully")
        print("✅ Listening for: \(savedHotKey)")
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
    
    /// Update hotkey and re-register it immediately
    func updateAndRegisterHotkey(for type: String, hotKey: String) {
        print("\n" + String(repeating: "🔄", count: 35))
        print("🔄 Updating hotkey: \(hotKey)")
        print(String(repeating: "🔄", count: 35) + "\n")
        
        // Unregister old hotkey
        if let ref = hotKeyRef {
            UnregisterEventHotKey(ref)
            hotKeyRef = nil
            print("✅ Old hotkey unregistered")
        }
        
        // Save new hotkey
        HotKeyManager.shared.saveOCRHotKey(hotKey)
        
        // Re-register with new hotkey
        registerGlobalHotkey()
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
