import SwiftUI
import AppKit
import CoreGraphics

#if os(macOS)
import ScreenCaptureKit
#endif

// App is now started from main.swift instead of @main decorator
// This gives us more control over window creation and hotkey setup

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    static var mainWindow: NSWindow?
    private var permissionCheckTimer: Timer?
    
    func setupHotkeys() {
        print("\n" + String(repeating: "=", count: 70))
        print("🎯 AppDelegate.setupHotkeys() called")
        print("📝 Step 1: Setup hotkey listener (Carbon API - no permissions)")
        print("📝 Step 2: Setup ESC key listener (close popover / cancel drag)")
        print("📝 Step 3: Check Screen Recording permission (for capture)")
        print(String(repeating: "=", count: 70) + "\n")
        
        // Step 1: Start hotkey listener (uses Carbon API - no permissions needed)
        print("🔧 Step 1: Setting up global hotkey listener...\n")
        startHotKeyListener()
        
        // Step 2: Start ESC key listener (for closing popover and cancelling drag)
        print("🔧 Step 2: Setting up ESC key listener...\n")
        startEscapeKeyListener()
        
        // Step 3: Check and request Screen Recording permission (needed for capture)
        print("🔧 Step 3: Checking Screen Recording permission...\n")
        checkAndRequestScreenRecordingPermission()
    }
    
    // MARK: - Screen Recording Permission
    
    private func checkAndRequestScreenRecordingPermission() {
        print("📊 Checking Screen Recording permission...\n")
        
        // Try to check permission
        if #available(macOS 13.0, *) {
            Task {
                let hasPermission = await checkScreenRecordingPermissionModern()
                
                DispatchQueue.main.async {
                    print("📊 Permission Status:")
                    print("   • Screen & System Audio Recording: \(hasPermission ? "✅" : "❌")\n")
                    
                    if !hasPermission {
                        print("📍 Requesting permission...\n")
                        self.requestScreenRecordingPermissionModern()
                    } else {
                        print("✅ Screen Recording permission already granted!\n")
                    }
                }
            }
        } else {
            // Fallback for older macOS
            let hasPermission = checkScreenRecordingPermissionLegacy()
            
            print("📊 Permission Status:")
            print("   • Screen & System Audio Recording: \(hasPermission ? "✅" : "❌")\n")
            
            if !hasPermission {
                print("📍 Requesting permission...\n")
                requestScreenRecordingPermissionLegacy()
            } else {
                print("✅ Screen Recording permission already granted!\n")
            }
        }
    }
    
    // MARK: - Modern Permission (macOS 13+)
    
    @available(macOS 13.0, *)
    private func checkScreenRecordingPermissionModern() async -> Bool {
        do {
            _ = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: false)
            return true
        } catch {
            print("⚠️  No Screen Recording permission: \(error.localizedDescription)")
            return false
        }
    }
    
    @available(macOS 13.0, *)
    private func requestScreenRecordingPermissionModern() {
        Task {
            do {
                print("🎥 Requesting Screen & System Audio Recording permission...\n")
                _ = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: false)
                print("✅ Screen Recording permission GRANTED!\n")
            } catch {
                print("❌ Screen Recording permission DENIED or error: \(error.localizedDescription)\n")
                print("📍 User can enable in: System Settings → Privacy & Security → Screen & System Audio Recording\n")
            }
        }
    }
    
    // MARK: - Legacy Permission (macOS < 13)
    
    private func checkScreenRecordingPermissionLegacy() -> Bool {
        // For older macOS, try to use CGDisplayCreateImage
        let displayID = CGMainDisplayID()
        return CGDisplayCreateImage(displayID) != nil
    }
    
    private func requestScreenRecordingPermissionLegacy() {
        // Trigger permission request on background thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let displayID = CGMainDisplayID()
            _ = CGDisplayCreateImage(displayID)
            
            // Start polling to check if permission is granted
            DispatchQueue.main.async {
                self?.startPermissionPolling()
            }
        }
    }
    
    private func startPermissionPolling() {
        print("📡 Polling for permission (checking every 1 second)...\n")
        
        permissionCheckTimer?.invalidate()
        
        var pollCount = 0
        let maxPolls = 180 // 3 minutes
        
        permissionCheckTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            pollCount += 1
            
            let hasPermission = self?.checkScreenRecordingPermissionLegacy() ?? false
            
            if pollCount % 10 == 0 {
                print("⏱️  Polling (\(pollCount)s)... Permission: \(hasPermission ? "✅" : "❌")")
            }
            
            if hasPermission {
                print("\n✅ Screen Recording permission DETECTED!\n")
                self?.permissionCheckTimer?.invalidate()
                self?.permissionCheckTimer = nil
            } else if pollCount >= maxPolls {
                print("\n⏱️  Permission polling timed out (3 min)\n")
                self?.permissionCheckTimer?.invalidate()
                self?.permissionCheckTimer = nil
                self?.showTimeoutAlert()
            }
        }
    }
    
    private func showTimeoutAlert() {
        let alert = NSAlert()
        alert.messageText = "Screen Recording Permission"
        alert.informativeText = "Please grant Screen Recording permission in System Settings to use capture feature.\n\nSystem Settings → Privacy & Security → Screen & System Audio Recording"
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "OK")
        alert.alertStyle = .informational
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenRecording") {
                NSWorkspace.shared.open(url)
            }
        }
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("📱 applicationDidFinishLaunching called")
        
        // Setup status bar after app finishes launching
        DispatchQueue.main.async {
            print("🎯 Setting up status bar in applicationDidFinishLaunching")
            StatusBarManager.shared.setupStatusBar()
        }
    }
    
    private func startHotKeyListener() {
        print("🎯 HotKeyService setup starting...")
        
        HotKeyService.shared.onHotKeyPressed = {
            print("\n🔥🔥🔥 HOTKEY TRIGGERED - Cmd+Ctrl+C DETECTED 🔥🔥🔥\n")
            // Trigger capture with callback to show translator popover
            DispatchQueue.main.async {
                print("✅ Starting capture from hotkey")
                
                CaptureViewModel.shared.startCapture { image in
                    print("📸 Hotkey capture completed - showing translator popover")
                    // Set captured image directly to translator view model
                    TranslatorViewModel.shared.capturedImage = image
                    
                    // Show translator popover from menu bar
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        StatusBarManager.shared.showTranslatorPopover()
                    }
                }
            }
        }
        
        HotKeyService.shared.start()
        print("✅ HotKeyService is now ACTIVE - listening for Cmd+Ctrl+C\n")
    }
    
    private func startEscapeKeyListener() {
        print("🎯 EscapeKeyService setup starting...")
        
        EscapeKeyService.shared.start()
        print("✅ EscapeKeyService is now ACTIVE - listening for ESC key\n")
    }
}
