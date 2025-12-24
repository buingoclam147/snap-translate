import SwiftUI
#if os(macOS)
import AppKit

class CaptureViewModel: NSObject, ObservableObject {
    static let shared = CaptureViewModel()
    
    @Published var isCapturing = false
    @Published var selectedRect: CGRect = .zero
    @Published var capturedImage: NSImage?
    
    private var captureWindow: NSWindow?
    
    override init() {
        super.init()
        print("🔧 CaptureViewModel.init() - Instance created")
    }
    
    func startCapture() {
        LogService.shared.info("\n" + String(repeating: "=", count: 50))
        LogService.shared.info("🚀 CAPTURE START")
        LogService.shared.info(String(repeating: "=", count: 50))
        
        guard !isCapturing else { 
            LogService.shared.error("⚠️ Already capturing")
            return 
        }
        
        isCapturing = true
        
        guard let screen = NSScreen.main else {
            LogService.shared.error("❌ No main screen")
            return
        }
        
        let screenFrame = screen.frame
        LogService.shared.debug("  Screen frame: \(screenFrame)")
        LogService.shared.debug("  Screen visible frame: \(screen.visibleFrame)")
        
        // Create fullscreen window
        captureWindow = NSWindow(contentRect: screenFrame, styleMask: [], backing: .buffered, defer: false)
        captureWindow?.level = NSWindow.Level(rawValue: NSWindow.Level.screenSaver.rawValue + 10)
        captureWindow?.backgroundColor = NSColor.clear
        captureWindow?.isOpaque = false
        captureWindow?.ignoresMouseEvents = false
        captureWindow?.acceptsMouseMovedEvents = true
        captureWindow?.isReleasedWhenClosed = false
        
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
        
        // Show and focus
        captureWindow?.makeKeyAndOrderFront(nil)
        captureWindow?.makeFirstResponder(overlayView)
        NSApplication.shared.activate(ignoringOtherApps: true)
        
        LogService.shared.info("✅ Overlay ready - drag to select")
    }
    
    func endCapture() {
        LogService.shared.debug("🏁 endCapture() called")
        isCapturing = false
        
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
            self?.endCapture()
            
            // OCR
            LogService.shared.info("🚀 Starting OCR...")
            ResultViewModel.shared.processImage(image)
            LogService.shared.info("✅ OCR processing started")
        }
    }
}
#endif
