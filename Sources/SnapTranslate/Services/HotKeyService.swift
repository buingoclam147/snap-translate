import Foundation
#if os(macOS)
import AppKit

class HotKeyService: NSObject {
    static let shared = HotKeyService()
    
    private var monitor: Any?
    var onHotKeyPressed: (() -> Void)?
    
    override init() {
        super.init()
    }
    
    func start() {
        print("\n" + String(repeating: "=", count: 70))
        print("🎯 HotKeyService.start() - Registering keyboard listener")
        print("📝 onHotKeyPressed handler set? \(onHotKeyPressed != nil)")
        print(String(repeating: "=", count: 70) + "\n")
        
        // Try BOTH monitors - global + local
        var globalRegistered = false
        var localRegistered = false
        
        // Try GLOBAL monitor first (works when app is background)
        monitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyEvent(event, isGlobal: true)
        }
        
        if monitor != nil {
            globalRegistered = true
            print("✅ Global keyboard monitor registered")
        } else {
            print("⚠️ Global monitor failed")
        }
        
        // ALSO try local monitor (works when app is foreground)
        let localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyEvent(event, isGlobal: false)
            return event
        }
        
        if localMonitor != nil {
            localRegistered = true
            print("✅ Local keyboard monitor registered")
            // Keep local monitor reference
            if monitor == nil {
                monitor = localMonitor
            }
        } else {
            print("⚠️ Local monitor failed")
        }
        
        print("")
        
        if !globalRegistered && !localRegistered {
            print("❌ FATAL ERROR: Both global and local monitors failed!")
            print("   Accessibility permission might not be granted")
        } else {
            print("✅ Keyboard listener ACTIVE")
            if globalRegistered && localRegistered {
                print("   (Both global + local monitors)")
            } else if globalRegistered {
                print("   (Global monitor only)")
            } else {
                print("   (Local monitor only - app must stay focused)")
            }
            print("✅ Listening for: Cmd + Shift + C (keyCode 8)")
            print("\n📢 Press Cmd+Shift+C now\n")
        }
    }
    
    private func handleKeyEvent(_ event: NSEvent, isGlobal: Bool) {
        let cmdPressed = event.modifierFlags.contains(.command)
        let shiftPressed = event.modifierFlags.contains(.shift)
        let cKeyPressed = event.keyCode == 8  // C key = keyCode 8
        
        let monitorType = isGlobal ? "🌍 Global" : "🔒 Local"
        
        // Log EVERY keystroke
        print("\(monitorType) ⌨️ KEY: keyCode=\(event.keyCode) | Cmd:\(cmdPressed ? "Y" : "N") Shift:\(shiftPressed ? "Y" : "N")")
        
        // Special log for Cmd+Shift combos
        if cmdPressed && shiftPressed {
            print("   ⚡ Cmd+Shift combo! keyCode=\(event.keyCode) (C=8)")
        }
        
        // Check for exact match: Cmd + Shift + C
        if cmdPressed && shiftPressed && cKeyPressed {
            print("\n" + String(repeating: "🔥", count: 40))
            print("🔥🔥🔥 HOTKEY: Cmd + Shift + C DETECTED 🔥🔥🔥")
            print(String(repeating: "🔥", count: 40) + "\n")
            
            if onHotKeyPressed != nil {
                print("✅ Calling hotkey handler")
                onHotKeyPressed?()
            } else {
                print("❌ ERROR: Handler is nil!")
            }
        }
    }
    
    func stop() {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
            print("🛑 HotKeyService stopped")
        }
    }
    
    deinit {
        stop()
    }
}
#endif
