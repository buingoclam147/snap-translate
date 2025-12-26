import SwiftUI
#if os(macOS)
import AppKit

class CaptureViewModel: NSObject, ObservableObject {
    static let shared = CaptureViewModel()
    
    @Published var isCapturing = false
    @Published var selectedRect: CGRect = .zero
    @Published var capturedImage: NSImage?
    
    private var captureWindow: NSWindow?
    private var escapeMonitor: Any?
    private var captureCallback: ((NSImage) -> Void)?
    private var isProcessing = false
    
    override init() {
        super.init()
        print("🔧 CaptureViewModel.init() - Instance created")
    }
    
    func startCapture(completion: ((NSImage) -> Void)? = nil) {
        captureCallback = completion
        LogService.shared.info("\n" + String(repeating: "=", count: 50))
        LogService.shared.info("🚀 CAPTURE START - Drag Mode (OCR)")
        LogService.shared.info("🔑 Press ESC to cancel")
        LogService.shared.info(String(repeating: "=", count: 50))
        
        guard !isCapturing else { 
            LogService.shared.error("⚠️ Already capturing")
            return 
        }
        
        isCapturing = true
        
        // Set up ESC handler for drag mode
        EscapeKeyService.shared.onEscapePressed = {
            LogService.shared.info("\n" + String(repeating: "🛑", count: 40))
            LogService.shared.info("🛑🛑🛑 DRAG MODE: ESC Pressed - CANCELLING Capture 🛑🛑🛑")
            LogService.shared.info(String(repeating: "🛑", count: 40) + "\n")
            
            // Cancel OCR if it's processing
            if self.isProcessing {
                OCRService.shared.cancelOCR()
            }
            
            self.endCapture()
        }
        
        guard let screen = NSScreen.main else {
            LogService.shared.error("❌ No main screen")
            return
        }
        
        let screenFrame = screen.frame
        LogService.shared.debug("  Screen frame: \(screenFrame)")
        LogService.shared.debug("  Screen visible frame: \(screen.visibleFrame)")
        
        // Create fullscreen window with custom subclass to handle keyboard events
        let window = CaptureWindow(contentRect: screenFrame, styleMask: [.borderless], backing: .buffered, defer: false)
        window.level = NSWindow.Level(rawValue: NSWindow.Level.screenSaver.rawValue + 10)
        window.backgroundColor = NSColor.clear
        window.isOpaque = false
        window.ignoresMouseEvents = false
        window.acceptsMouseMovedEvents = true
        window.isReleasedWhenClosed = false
        captureWindow = window
        
        LogService.shared.info("✅ Overlay window created - level: \(captureWindow?.level.rawValue ?? 0)")
        
        // Create overlay view - MUST have same frame as window
        let overlayView = SimpleOverlayView(frame: screenFrame)
        overlayView.onRegionSelected = { [weak self] rect in
            if rect == .zero {
                LogService.shared.info("❌ Capture cancelled")
                self?.endCapture()
            } else {
                LogService.shared.info("➡️ Selection made, starting capture process")
                self?.captureBounds(rect)
            }
        }
        
        captureWindow?.contentView = overlayView
        
        // Hide main window
        if let mainWindow = AppDelegate.mainWindow {
            mainWindow.orderOut(nil)
            LogService.shared.debug("  ✅ Main window hidden")
        }
        
        // Show and focus - order matters!
        captureWindow?.makeKeyAndOrderFront(nil)
        captureWindow?.makeFirstResponder(overlayView)
        // Force first responder again to ensure keyboard focus
        DispatchQueue.main.async { [weak self] in
            self?.captureWindow?.makeFirstResponder(overlayView)
        }
        NSApplication.shared.activate(ignoringOtherApps: true)
        
        // Add GLOBAL ESC key monitor (works even when app is not focused)
        escapeMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            LogService.shared.debug("🌍 GLOBAL key monitor: keyCode=\(event.keyCode), isCapturing=\(self?.isCapturing ?? false)")
            if event.keyCode == 53 {  // ESC key
                LogService.shared.info("🛑 ESC pressed (GLOBAL monitor) - cancelling capture")
                // Cancel OCR if processing
                if self?.isProcessing == true {
                    LogService.shared.info("⏹️  Cancelling OCR processing...")
                    OCRService.shared.cancelOCR()
                }
                self?.endCapture()
                // Note: Global monitor cannot consume events, but that's OK for ESC
            }
        }
        
        LogService.shared.info("✅ Overlay ready - drag to select")
    }
    
    func endCapture() {
        LogService.shared.debug("🏁 endCapture() called")
        isCapturing = false
        
        // Clean up ESC handler
        EscapeKeyService.shared.onEscapePressed = nil
        LogService.shared.debug("  ESC handler cleared")
        
        // Remove escape monitor
        if let monitor = escapeMonitor {
            NSEvent.removeMonitor(monitor)
            escapeMonitor = nil
            LogService.shared.debug("  Local ESC monitor removed")
        }
        
        if let window = captureWindow {
            window.orderOut(nil)
            captureWindow = nil
            LogService.shared.debug("  Overlay hidden")
        }
        
        if let mainWindow = AppDelegate.mainWindow {
            mainWindow.makeKeyAndOrderFront(nil)
            LogService.shared.debug("  Main window restored")
        }
    }
    
    func captureBounds(_ rect: CGRect) {
        LogService.shared.info("📸 captureBounds START: \(rect)")
        
        // IMPORTANT: Close overlay COMPLETELY before capture (not just hide)
        // This ensures CGDisplayCreateImage captures what's actually visible
        let closeTime = Date()
        if let window = captureWindow {
            window.close()
            captureWindow = nil
            LogService.shared.info("✅ Overlay closed - \(Date().timeIntervalSince(closeTime)*1000)ms")
        }
        
        // Small delay to ensure window is closed and display is updated
        let delayTime: TimeInterval = 0.1
        LogService.shared.debug("⏱️ Waiting \(Int(delayTime*1000))ms before capture...")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delayTime) { [weak self] in
            LogService.shared.info("🎬 Calling captureRegion...")
            let captureStart = Date()
            
            guard let image = CaptureService.shared.captureRegion(rect) else {
                LogService.shared.error("❌ Capture failed - captureRegion returned nil")
                self?.endCapture()
                return
            }
            
            let captureTime = Date().timeIntervalSince(captureStart)
            LogService.shared.info("✅ Image captured in \(Int(captureTime*1000))ms")
            
            self?.capturedImage = image
            self?.isProcessing = true
            self?.endCapture()
            
            // Check if callback is set (for translator view) or use ResultViewModel (for result window)
            if let callback = self?.captureCallback {
                LogService.shared.info("🎯 Calling capture callback (translator mode)")
                callback(image)
                self?.isProcessing = false
            } else {
                // OCR with ResultViewModel (legacy mode)
                LogService.shared.info("🚀 Starting OCR...")
                ResultViewModel.shared.processImage(image)
                LogService.shared.info("✅ OCR processing started")
                self?.isProcessing = false
            }
        }
    }
}

// Custom NSWindow subclass to handle keyboard events properly
class CaptureWindow: NSWindow {
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return true
    }
}
#endif
