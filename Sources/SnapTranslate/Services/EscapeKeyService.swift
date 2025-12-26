import AppKit

class EscapeKeyService: NSObject {
    static let shared = EscapeKeyService()
    
    private var escapeMonitor: Any?
    var onEscapePressed: (() -> Void)?
    
    override init() {
        super.init()
    }
    
    func start() {
        print("\n" + String(repeating: "=", count: 70))
        print("🎯 EscapeKeyService.start() - GLOBAL ESC Key Listener")
        print("📝 Using addGlobalMonitorForEvents (works from anywhere)")
        print("📝 Listening for ESC (keyCode 53) globally")
        print(String(repeating: "=", count: 70) + "\n")
        
        setupEscapeMonitor()
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
    
    func stop() {
        if let monitor = escapeMonitor {
            NSEvent.removeMonitor(monitor)
            escapeMonitor = nil
            print("🛑 EscapeKeyService stopped")
        }
    }
    
    deinit {
        stop()
    }
}
