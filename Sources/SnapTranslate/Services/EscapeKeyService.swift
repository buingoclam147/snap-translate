import AppKit

class EscapeKeyService: NSObject {
    static let shared = EscapeKeyService()
    
    private var escapeMonitor: Any?
    private var mouseMonitor: Any?
    private var hotkeyMonitor: Any?
    
    var onEscapePressed: (() -> Void)?
    var onMouseDown: ((NSEvent) -> Void)?
    var onMouseDragged: ((NSEvent) -> Void)?
    var onMouseUp: ((NSEvent) -> Void)?
    var onTranslateHotkey: ((String) -> Void)?  // Called with selected text
    
    override init() {
        super.init()
    }
    
    func start() {
        print("\n" + String(repeating: "=", count: 70))
        print("🎯 EscapeKeyService.start() - GLOBAL Event Listener")
        print("📝 Using addGlobalMonitorForEvents (works from anywhere)")
        print("📝 Listening for ESC (keyCode 53) globally")
        print("📝 Listening for Cmd+Shift+X (translate selected text)")
        print(String(repeating: "=", count: 70) + "\n")
        
        setupEscapeMonitor()
        setupHotkeyMonitor()
    }
    
    func startMouseMonitoring() {
        print("\n" + String(repeating: "=", count: 70))
        print("🖱️  EscapeKeyService.startMouseMonitoring() - GLOBAL Mouse Events")
        print("📝 Listening for mouseDown, mouseDragged, mouseUp globally")
        print(String(repeating: "=", count: 70) + "\n")
        
        setupMouseMonitor()
    }
    
    func stopMouseMonitoring() {
        if let monitor = mouseMonitor {
            NSEvent.removeMonitor(monitor)
            mouseMonitor = nil
            print("🛑 EscapeKeyService mouse monitoring stopped\n")
        }
    }
    
    private func getSelectedText() -> String {
        // Simulate Cmd+C to copy selected text to pasteboard
        let source = CGEventSource(stateID: .combinedSessionState)
        
        // Press Cmd+C
        let keyDownCmd = CGEvent(keyboardEventSource: source, virtualKey: 8, keyDown: true)  // 'c' key
        keyDownCmd?.flags = .maskCommand
        
        let keyUpCmd = CGEvent(keyboardEventSource: source, virtualKey: 8, keyDown: false)
        keyUpCmd?.flags = .maskCommand
        
        keyDownCmd?.post(tap: .cghidEventTap)
        usleep(50000)  // 50ms delay
        keyUpCmd?.post(tap: .cghidEventTap)
        usleep(50000)  // Wait for copy to complete
        
        // Get copied text from pasteboard
        let pasteboard = NSPasteboard.general
        let copiedText = pasteboard.string(forType: .string) ?? ""
        
        return copiedText
    }
    
    private func setupEscapeMonitor() {
        guard escapeMonitor == nil else {
            print("✅ ESC monitor already installed, skipping...")
            return
        }
        
        // Use GLOBAL monitor so it works even when app is not focused
        escapeMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            print("🌍 GLOBAL ESC monitor received keyDown: keyCode=\(event.keyCode)")
            
            if event.keyCode == 53 {  // ESC key code
                print("\n" + String(repeating: "🔑", count: 40))
                print("🔑🔑🔑 GLOBAL ESC KEY DETECTED 🔑🔑🔑")
                print(String(repeating: "🔑", count: 40) + "\n")
                
                if self?.onEscapePressed != nil {
                    print("✅ Calling ESC handler")
                    DispatchQueue.main.async {
                        self?.onEscapePressed?()
                    }
                } else {
                    print("⚠️  No ESC handler registered")
                }
            }
        }
        
        print("✅ GLOBAL ESC key monitor installed successfully")
        print("✅ Listening for ESC (keyCode 53) - GLOBALLY")
        print("✅ Will work even when app is not focused\n")
    }
    
    private func setupMouseMonitor() {
        guard mouseMonitor == nil else {
            print("✅ Mouse monitor already installed, skipping...")
            return
        }
        
        // Monitor all mouse events globally
        mouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .leftMouseDragged, .leftMouseUp]) { [weak self] event in
            switch event.type {
            case .leftMouseDown:
                print("🖱️  GLOBAL Mouse DOWN at \(event.locationInWindow)")
                DispatchQueue.main.async {
                    self?.onMouseDown?(event)
                }
            case .leftMouseDragged:
                print("🖱️  GLOBAL Mouse DRAGGED to \(event.locationInWindow)")
                DispatchQueue.main.async {
                    self?.onMouseDragged?(event)
                }
            case .leftMouseUp:
                print("🖱️  GLOBAL Mouse UP at \(event.locationInWindow)")
                DispatchQueue.main.async {
                    self?.onMouseUp?(event)
                }
            default:
                break
            }
        }
        
        print("✅ GLOBAL mouse monitor installed successfully")
        print("✅ Listening for mouseDown, mouseDragged, mouseUp - GLOBALLY\n")
    }
    
    private func setupHotkeyMonitor() {
        guard hotkeyMonitor == nil else {
            print("✅ Hotkey monitor already installed, skipping...")
            return
        }
        
        // Monitor for translate hotkey
        hotkeyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            // Get current saved translate hotkey from UserDefaults
            let savedHotkey = UserDefaults.standard.string(forKey: "SnapTranslateTranslateHotKey") ?? "Cmd+Shift+X"
            
            // Check if the pressed key matches the configured hotkey
            if self?.matchesHotkey(event: event, hotkey: savedHotkey) ?? false {
                print("\n" + String(repeating: "⌨️ ", count: 25))
                print("⌨️  TRANSLATE HOTKEY DETECTED - \(savedHotkey)")
                print(String(repeating: "⌨️ ", count: 25) + "\n")
                
                // Get selected text by triggering Cmd+C
                let selectedText = self?.getSelectedText() ?? ""
                
                if !selectedText.isEmpty {
                    print("📝 Selected text: \(selectedText)")
                    DispatchQueue.main.async {
                        self?.onTranslateHotkey?(selectedText)
                    }
                } else {
                    print("⚠️  No text selected")
                }
            }
        }
        
        let savedHotkey = UserDefaults.standard.string(forKey: "SnapTranslateTranslateHotKey") ?? "Cmd+Shift+X"
        print("✅ GLOBAL hotkey monitor installed successfully")
        print("✅ Listening for \(savedHotkey) - GLOBALLY\n")
    }
    
    private func matchesHotkey(event: NSEvent, hotkey: String) -> Bool {
        let parts = hotkey.components(separatedBy: "+")
        
        var expectedModifiers = NSEvent.ModifierFlags()
        var expectedKeyCode: UInt16 = 7  // Default to X
        
        for part in parts {
            switch part.lowercased() {
            case "cmd":
                expectedModifiers.insert(.command)
            case "shift":
                expectedModifiers.insert(.shift)
            case "ctrl":
                expectedModifiers.insert(.control)
            case "opt", "option":
                expectedModifiers.insert(.option)
            case "x":
                expectedKeyCode = 7
            case "c":
                expectedKeyCode = 8
            case "v":
                expectedKeyCode = 9
            case "a": expectedKeyCode = 0
            case "s": expectedKeyCode = 1
            case "d": expectedKeyCode = 2
            case "f": expectedKeyCode = 3
            case "h": expectedKeyCode = 4
            case "g": expectedKeyCode = 5
            case "z": expectedKeyCode = 6
            case "b": expectedKeyCode = 11
            case "q": expectedKeyCode = 12
            case "w": expectedKeyCode = 13
            case "e": expectedKeyCode = 14
            case "r": expectedKeyCode = 15
            case "y": expectedKeyCode = 16
            case "t": expectedKeyCode = 17
            case "o": expectedKeyCode = 31
            case "u": expectedKeyCode = 32
            case "i": expectedKeyCode = 34
            case "p": expectedKeyCode = 35
            case "l": expectedKeyCode = 37
            case "j": expectedKeyCode = 38
            case "k": expectedKeyCode = 40
            case "n": expectedKeyCode = 45
            case "m": expectedKeyCode = 46
            default: break
            }
        }
        
        let eventModifiers = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        return event.keyCode == expectedKeyCode && eventModifiers == expectedModifiers
    }
    
    func stop() {
        if let monitor = escapeMonitor {
            NSEvent.removeMonitor(monitor)
            escapeMonitor = nil
            print("🛑 EscapeKeyService stopped")
        }
        
        if let monitor = hotkeyMonitor {
            NSEvent.removeMonitor(monitor)
            hotkeyMonitor = nil
            print("🛑 Hotkey monitor stopped")
        }
        
        stopMouseMonitoring()
    }
    
    deinit {
        stop()
    }
}
