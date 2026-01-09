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
                
                // Fallback: try to load TSnap.png if logo.png not found
                if nsImage == nil {
                    imagePath = "\(resourcePath)/TSnap.png"
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
                    let image = NSImage(systemSymbolName: "text.viewfinder", accessibilityDescription: "TSnap")
                    image?.isTemplate = true
                    button.image = image
                    print("✅ Using fallback system icon")
                }
            } else {
                print("❌ Resource path not found")
                // Fallback: use system icon
                let image = NSImage(systemSymbolName: "text.viewfinder", accessibilityDescription: "TSnap")
                image?.isTemplate = true
                button.image = image
                print("✅ Using fallback system icon")
            }
            
            // Set button action to show translator popover
            button.target = self
            button.action = #selector(buttonClicked)
        } else {
            print("❌ Failed to get status bar button")
        }
        
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
        
        print("✅ Status bar icon created")
    }
    
    private var translatorPopover: NSPopover?
    private var isPopoverVisible: Bool = false
    private var autoCloseTimer: Timer?
    
    @objc private func buttonClicked() {
        showTranslatorPopover()
    }
    
    func showTranslatorPopover() {
        print("📝 Opening translator popover")
        guard let button = statusItem?.button else { return }
        
        // Reuse existing popover if it's already visible
        if isPopoverVisible && translatorPopover != nil {
            print("♻️ Reusing existing popover")
            translatorPopover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        } else {
            print("🆕 Creating new popover")
            translatorPopover = NSPopover()
            translatorPopover?.contentViewController = NSHostingController(
                rootView: TranslatorPopoverView(
                    onClose: { [weak self] in
                       self?.isPopoverVisible = false
                       self?.cancelAutoClose()
                        self?.translatorPopover?.performClose(nil)
                    },
                    onOCRTapped: {
                        print("🎯 OCR tapped - hiding popover for capture")
                        // Hide translator popover before capturing
                        self.isPopoverVisible = false
                        self.translatorPopover?.performClose(nil)
                        
                        // Start capture
                        CaptureViewModel.shared.startCapture { image in
                            print("📸 Capture completed - showing popover again")
                            // Set captured image directly to translator view model
                            TranslatorViewModel.shared.capturedImage = image
                            
                            // Re-show popover after capture
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                self.showTranslatorPopover()
                            }
                        }
                    },
                    onSupportTapped: {
                        self.showSupportMenu()
                    }
                )
            )
            translatorPopover?.behavior = .transient
            translatorPopover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            isPopoverVisible = true
        }
    }
    
    private func showSupportMenu() {
        guard let button = statusItem?.button else { return }
        
        let supportMenu = NSMenu()
        
        let sponsorsItem = NSMenuItem(
            title: "Support Development",
            action: #selector(openSponsorsLink),
            keyEquivalent: ""
        )
        sponsorsItem.target = self
        supportMenu.addItem(sponsorsItem)
        
        let emailItem = NSMenuItem(
            title: "Email: buingoclam00@gmail.com",
            action: #selector(copyEmail),
            keyEquivalent: ""
        )
        emailItem.target = self
        supportMenu.addItem(emailItem)
        
        let linkedinItem = NSMenuItem(
            title: "LinkedIn Profile",
            action: #selector(openLinkedInLink),
            keyEquivalent: ""
        )
        linkedinItem.target = self
        supportMenu.addItem(linkedinItem)
        
        supportMenu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(
            title: "Quit TSnap",
            action: #selector(quitApp),
            keyEquivalent: ""
        )
        quitItem.target = self
        supportMenu.addItem(quitItem)
        
        // Create event for menu location
        if let event = NSApplication.shared.currentEvent {
            NSMenu.popUpContextMenu(supportMenu, with: event, for: button)
        }
    }
    
    @objc private func captureAndTranslate() {
        print("🔥 Capture & Translate from menu")
        CaptureViewModel.shared.startCapture()
    }
    
    @objc private func openSettings() {
        print("⚙️ Opening hotkey settings")
        showHotKeySettingsPopover()
    }
    
    func scheduleAutoClosePopover() {
        // Cancel existing timer
        cancelAutoClose()
        
        var delay = UserDefaults.standard.double(forKey: "SnapTranslateAutoCloseDelay")
        if delay == 0 {
            delay = 10 // Default to 10 seconds
        }
        
        print("⏱️ Scheduling auto-close in \(delay) seconds")
        autoCloseTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            print("⏱️ Auto-closing popover")
            self?.isPopoverVisible = false
            self?.translatorPopover?.performClose(nil)
        }
    }
    
    private func cancelAutoClose() {
        autoCloseTimer?.invalidate()
        autoCloseTimer = nil
    }
    
    func showHotKeySettingsPopover() {
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
