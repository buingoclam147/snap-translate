import AppKit
import SwiftUI

class QuickNotificationWindow: NSWindow {
    var hostingController: NSHostingController<QuickNotificationView>?
    var viewModel: QuickNotificationViewModel?
    
    init(sourceText: String, sourceLang: String, targetLang: String, targetLanguageCode: String) {
        let screen = NSScreen.main ?? NSScreen.screens.first
        let screenFrame = screen?.frame ?? CGRect(x: 0, y: 0, width: 1440, height: 900)
        
        // Position at top-center of screen
        let windowWidth: CGFloat = 380
        let windowHeight: CGFloat = 120
        let topPadding: CGFloat = 60  // Distance from top of screen
        
        let x = screenFrame.midX - (windowWidth / 2)
        let y = screenFrame.maxY - (windowHeight + topPadding)
        
        let rect = CGRect(x: x, y: y, width: windowWidth, height: windowHeight)
        
        super.init(
            contentRect: rect,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        self.level = .floating
        self.isOpaque = false
        self.backgroundColor = NSColor.clear
        self.hasShadow = true
        self.isExcludedFromWindowsMenu = true
        self.canHide = false
        
        // Create view model
        let viewModel = QuickNotificationViewModel()
        self.viewModel = viewModel
        
        // Create and set hosting controller
        let notificationView = QuickNotificationView(
            sourceText: sourceText,
            sourceLang: sourceLang,
            targetLang: targetLang,
            targetLanguageCode: targetLanguageCode,
            onClose: {
                // Use dispatch to avoid retain cycle
                DispatchQueue.main.async {
                    self.orderOut(nil)
                    self.close()
                }
            },
            viewModel: viewModel
        )
        
        let hostingController = NSHostingController(rootView: notificationView)
        self.contentViewController = hostingController
        self.hostingController = hostingController
        
        print("✅ QuickNotificationWindow created at position: (\(x), \(y))")
    }
    
    func show() {
        self.makeKeyAndOrderFront(nil)
        NSApplication.shared.activate(ignoringOtherApps: false)
        print("✅ QuickNotificationWindow displayed - waiting for translation...")
    }
    
    func updateTranslation(_ translatedText: String) {
        viewModel?.translatedText = translatedText
        viewModel?.isTranslating = false
        print("✅ Translation received - updating notification")
    }
    
    func autoClose(after delay: TimeInterval = 10.0) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.orderOut(nil)
            self?.close()
        }
    }
    
    deinit {
        print("🗑️ QuickNotificationWindow deallocated")
    }
}
