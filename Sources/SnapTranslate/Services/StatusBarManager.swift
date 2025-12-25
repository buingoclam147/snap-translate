import AppKit

class StatusBarManager {
    static let shared = StatusBarManager()
    
    private var statusItem: NSStatusItem?
    
    func setupStatusBar() {
        // Create status bar item
        let statusBar = NSStatusBar.system
        statusItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)
        
        print("📍 StatusBar item created: \(statusItem != nil)")
        
        if let button = statusItem?.button {
            print("📍 StatusBar button found: \(button)")
            
            // Set icon
            let resourcePath = Bundle.main.resourcePath ?? "?"
            print("📍 Resource path: \(resourcePath)")
            
            if let resourcePath = Bundle.main.resourcePath {
                let imagePath = "\(resourcePath)/ESnap.png"
                print("📍 Trying to load image from: \(imagePath)")
                
                if let nsImage = NSImage(contentsOfFile: imagePath) {
                    print("✅ Image loaded successfully")
                    // Resize image for status bar
                    let resizedImage = NSImage(size: NSSize(width: 18, height: 18))
                    resizedImage.lockFocus()
                    nsImage.draw(in: NSRect(x: 0, y: 0, width: 18, height: 18),
                                from: NSRect.zero,
                                operation: .sourceOver,
                                fraction: 1.0)
                    resizedImage.unlockFocus()
                    resizedImage.isTemplate = true
                    button.image = resizedImage
                    print("✅ Status bar icon set from ESnap.png")
                } else {
                    print("❌ Failed to load image from \(imagePath)")
                    // Fallback: use system icon
                    let image = NSImage(systemSymbolName: "text.viewfinder", accessibilityDescription: "ESnap")
                    image?.isTemplate = true
                    button.image = image
                    print("✅ Using fallback system icon")
                }
            } else {
                print("❌ Resource path not found")
                // Fallback: use system icon
                let image = NSImage(systemSymbolName: "text.viewfinder", accessibilityDescription: "ESnap")
                image?.isTemplate = true
                button.image = image
                print("✅ Using fallback system icon")
            }
        } else {
            print("❌ Failed to get status bar button")
        }
        
        // Create menu
        let menu = NSMenu()
        
        // Capture & Translate item
        let captureItem = NSMenuItem(
            title: "Capture & Translate",
            action: #selector(captureAndTranslate),
            keyEquivalent: "c"
        )
        captureItem.keyEquivalentModifierMask = [.command, .control]
        captureItem.target = self
        menu.addItem(captureItem)
        
        // Settings item
        let settingsItem = NSMenuItem(
            title: "Settings",
            action: #selector(openSettings),
            keyEquivalent: ","
        )
        settingsItem.keyEquivalentModifierMask = [.command]
        settingsItem.target = self
        menu.addItem(settingsItem)
        
        // Separator
        menu.addItem(NSMenuItem.separator())
        
        // Quit item
        let quitItem = NSMenuItem(
            title: "Quit ESnap",
            action: #selector(quitApp),
            keyEquivalent: "q"
        )
        quitItem.keyEquivalentModifierMask = [.command]
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem?.menu = menu
        
        print("✅ Status bar icon created")
    }
    
    @objc private func captureAndTranslate() {
        print("🔥 Capture & Translate from menu")
        CaptureViewModel.shared.startCapture()
    }
    
    @objc private func openSettings() {
        print("⚙️ Opening settings")
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        }
    }
    
    @objc private func quitApp() {
        print("👋 Quitting app")
        NSApplication.shared.terminate(nil)
    }
}
