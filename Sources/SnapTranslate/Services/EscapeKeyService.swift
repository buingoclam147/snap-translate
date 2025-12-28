import AppKit

class EscapeKeyService: NSObject {
    static let shared = EscapeKeyService()
    
    private var escapeMonitor: Any?
    private var mouseMonitor: Any?
    
    var onEscapePressed: (() -> Void)?
    var onMouseDown: ((NSEvent) -> Void)?
    var onMouseDragged: ((NSEvent) -> Void)?
    var onMouseUp: ((NSEvent) -> Void)?
    
    override init() {
        super.init()
    }
    
    func start() {
        print("\n" + String(repeating: "=", count: 70))
        print("🎯 EscapeKeyService.start() - GLOBAL Event Listener")
        print("📝 Using addGlobalMonitorForEvents (works from anywhere)")
        print("📝 Listening for ESC (keyCode 53) globally")
        print(String(repeating: "=", count: 70) + "\n")
        
        setupEscapeMonitor()
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
    
    func stop() {
        if let monitor = escapeMonitor {
            NSEvent.removeMonitor(monitor)
            escapeMonitor = nil
            print("🛑 EscapeKeyService stopped")
        }
        stopMouseMonitoring()
    }
    
    deinit {
        stop()
    }
}
