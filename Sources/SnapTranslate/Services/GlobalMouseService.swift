import AppKit

class GlobalMouseService: NSObject {
    static let shared = GlobalMouseService()
    
    private var mouseDownMonitor: Any?
    private var mouseDraggedMonitor: Any?
    private var mouseUpMonitor: Any?
    
    var onMouseDown: ((NSPoint) -> Void)?
    var onMouseDragged: ((NSPoint) -> Void)?
    var onMouseUp: ((NSPoint) -> Void)?
    
    override init() {
        super.init()
    }
    
    func start() {
        print("\n" + String(repeating: "=", count: 70))
        print("🖱️ GlobalMouseService.start() - GLOBAL Mouse Listener")
        print("📝 Using addGlobalMonitorForEvents (works from anywhere)")
        print("📝 Listening for mouse events globally")
        print(String(repeating: "=", count: 70) + "\n")
        
        setupMouseMonitor()
    }
    
    private func setupMouseMonitor() {
        guard mouseDownMonitor == nil else {
            print("✅ Mouse monitor already installed, skipping...")
            return
        }
        
        print("🔴 Setting up fresh mouse monitors...")
        
        // Mouse Down - Global
        mouseDownMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { [weak self] event in
            let point = NSEvent.mouseLocation
            print("🌍 GLOBAL MOUSE DOWN at: \(point)")
            if self?.onMouseDown != nil {
                DispatchQueue.main.async {
                    self?.onMouseDown?(point)
                }
            } else {
                print("⚠️ onMouseDown callback not set!")
            }
        }
        
        // Mouse Dragged - Global
        mouseDraggedMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDragged) { [weak self] event in
            let point = NSEvent.mouseLocation
            print("🌍 GLOBAL MOUSE DRAGGED at: \(point)")
            if self?.onMouseDragged != nil {
                DispatchQueue.main.async {
                    self?.onMouseDragged?(point)
                }
            }
        }
        
        // Mouse Up - Global
        mouseUpMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseUp) { [weak self] event in
            let point = NSEvent.mouseLocation
            print("🌍 GLOBAL MOUSE UP at: \(point)")
            if self?.onMouseUp != nil {
                DispatchQueue.main.async {
                    self?.onMouseUp?(point)
                }
            } else {
                print("⚠️ onMouseUp callback not set!")
            }
        }
        
        print("✅ GLOBAL mouse monitor installed successfully")
        print("✅ Listening for mouse events - GLOBALLY")
        print("✅ Will work even when app is not focused\n")
    }
    
    func stop() {
        if let monitor = mouseDownMonitor {
            NSEvent.removeMonitor(monitor)
            mouseDownMonitor = nil
        }
        if let monitor = mouseDraggedMonitor {
            NSEvent.removeMonitor(monitor)
            mouseDraggedMonitor = nil
        }
        if let monitor = mouseUpMonitor {
            NSEvent.removeMonitor(monitor)
            mouseUpMonitor = nil
        }
        print("🛑 GlobalMouseService stopped")
    }
    
    deinit {
        stop()
    }
}
