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
        
        // Monitor for Cmd+Shift+X hotkey
        hotkeyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            // Check if Cmd+Shift+X is pressed
            let cmdKey = event.modifierFlags.contains(.command)
            let shiftKey = event.modifierFlags.contains(.shift)
            let isXKey = event.keyCode == 7  // keyCode for 'x'
            
            if cmdKey && shiftKey && isXKey {
                print("\n" + String(repeating: "⌨️ ", count: 25))
                print("⌨️  CMD+SHIFT+X DETECTED - Translate Selected Text")
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
        
        print("✅ GLOBAL hotkey monitor installed successfully")
        print("✅ Listening for Cmd+Shift+X (keyCode 7) - GLOBALLY\n")
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
