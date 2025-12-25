import AppKit
import SwiftUI

class StatusBarManager {
    static let shared = StatusBarManager()
    
    private var statusItem: NSStatusItem?
    private var captureMenuItem: NSMenuItem?
    
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
            
            // Try to load from Assets first
            if let statusBarImage = NSImage(named: "statusbar-icon") {
                print("✅ Status bar icon loaded from Assets")
                statusBarImage.isTemplate = true
                button.image = statusBarImage
                print("✅ Status bar icon set")
            } else if let resourcePath = Bundle.main.resourcePath {
                // Try to load logo.png first
                var imagePath = "\(resourcePath)/logo.png"
                print("📍 Trying to load logo from: \(imagePath)")
                
                var nsImage = NSImage(contentsOfFile: imagePath)
                
                // Fallback: try to load ESnap.png if logo.png not found
                if nsImage == nil {
                    imagePath = "\(resourcePath)/ESnap.png"
                    print("📍 Logo not found, trying fallback: \(imagePath)")
                    nsImage = NSImage(contentsOfFile: imagePath)
                }
                
                if let nsImage = nsImage {
                    print("✅ Image loaded successfully from: \(imagePath)")
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
                    print("✅ Status bar icon set")
                } else {
                    print("❌ Failed to load image from resources")
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
        captureMenuItem = NSMenuItem(
            title: "Capture & Translate",
            action: #selector(captureAndTranslate),
            keyEquivalent: ""
        )
        captureMenuItem?.target = self
        menu.addItem(captureMenuItem!)
        
        // Listen for hotkey changes to reload listener
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("HotKeyChanged"),
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let hotKey = notification.object as? String {
                // Reload hotkey listener when settings change
                self?.reloadHotKeyListener(hotKey)
            }
        }
        
        // Settings item - opens hotkey settings popover
        let settingsItem = NSMenuItem(
            title: "Hotkey Settings",
            action: #selector(openSettings),
            keyEquivalent: ""
        )
        settingsItem.target = self
        menu.addItem(settingsItem)
        
        // Support submenu
        let supportMenu = NSMenu()
        
        // Sponsors
        let sponsorsItem = NSMenuItem(
            title: "Support Development",
            action: #selector(openSponsorsLink),
            keyEquivalent: ""
        )
        sponsorsItem.target = self
        supportMenu.addItem(sponsorsItem)
        
        // Contact email
        let emailItem = NSMenuItem(
            title: "Email: buingoclam00@gmail.com",
            action: #selector(copyEmail),
            keyEquivalent: ""
        )
        emailItem.target = self
        supportMenu.addItem(emailItem)
        
        // LinkedIn
        let linkedinItem = NSMenuItem(
            title: "LinkedIn Profile",
            action: #selector(openLinkedInLink),
            keyEquivalent: ""
        )
        linkedinItem.target = self
        supportMenu.addItem(linkedinItem)
        
        // Support menu item
        let supportItem = NSMenuItem(title: "Support & Help", action: nil, keyEquivalent: "")
        supportItem.submenu = supportMenu
        menu.addItem(supportItem)
        
        // Separator
        menu.addItem(NSMenuItem.separator())
        
        // Quit item
        let quitItem = NSMenuItem(
            title: "Quit ESnap",
            action: #selector(quitApp),
            keyEquivalent: ""
        )
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
        print("⚙️ Opening hotkey settings")
        showHotKeySettingsPopover()
    }
    
    private func showHotKeySettingsPopover() {
        guard let button = statusItem?.button else { return }
        
        let popover = NSPopover()
        popover.contentViewController = NSHostingController(
            rootView: HotKeySettingsView()
        )
        popover.behavior = .transient
        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
    }
    
    @objc private func quitApp() {
        print("👋 Quitting app")
        NSApplication.shared.terminate(nil)
    }
    
    // MARK: - Hotkey Reload
    
    private func reloadHotKeyListener(_ hotKey: String) {
        print("🔄 Reloading hotkey listener with: \(hotKey)")
        
        // Unregister old hotkey and register new one
        HotKeyService.shared.stop()
        
        // Small delay to ensure unregister completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            HotKeyService.shared.start()
            print("✅ Hotkey listener reloaded")
        }
    }
    
    // MARK: - Support & Help Actions
    
    @objc private func openSponsorsLink() {
        if let url = URL(string: "https://github.com/sponsors/buingoclam147") {
            NSWorkspace.shared.open(url)
        }
    }
    
    @objc private func copyEmail() {
        let email = "buingoclam00@gmail.com"
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(email, forType: .string)
        showNotification(title: "Copied", message: email)
    }
    
    @objc private func copyPhone() {
        let phone = "0867655051"
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(phone, forType: .string)
        showNotification(title: "Copied", message: phone)
    }
    
    @objc private func openLinkedInLink() {
        if let url = URL(string: "https://www.linkedin.com/in/bui-lam-frontend/") {
            NSWorkspace.shared.open(url)
        }
    }
    
    private func showNotification(title: String, message: String) {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = message
        NSUserNotificationCenter.default.deliver(notification)
    }
}
