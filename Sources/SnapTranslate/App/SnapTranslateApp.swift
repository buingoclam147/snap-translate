import SwiftUI
import AppKit


// App is now started from main.swift instead of @main decorator
// This gives us more control over window creation and hotkey setup

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    static var mainWindow: NSWindow?
    
    func setupHotkeys() {
        print("\n" + String(repeating: "=", count: 70))
        print("🎯 AppDelegate.setupHotkeys() called - initializing hotkeys")
        print(String(repeating: "=", count: 70) + "\n")
        
        // Check accessibility permission FIRST
        let accessibilityGranted = checkAccessibilityPermission()
        
        if !accessibilityGranted {
            print("⚠️ Accessibility permission NEEDED")
            print("📍 Please enable in: System Settings → Privacy & Security → Accessibility")
            print("📍 Add SnapTranslate to the list")
            requestAccessibilityPermission()
            return
        }
        
        print("✅ Accessibility permission CONFIRMED\n")
        
        // Request Screen Recording permission early (so popup happens once at startup, not during capture)
        print("🎥 Requesting Screen Recording permission...")
        requestScreenRecordingPermission()
        
        // Start hotkey listener
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.startHotKeyListener()
        }
    }
    
    private func requestScreenRecordingPermission() {
        print("🎥 Requesting Screen Recording permission at startup...")
        
        // Background thread to avoid blocking UI
        DispatchQueue.global(qos: .userInitiated).async {
            // Attempting to capture triggers the system permission dialog if not granted
            // This happens only once - future captures won't prompt
            if let _ = CGDisplayCreateImage(CGMainDisplayID()) {
                print("✅ Screen Recording permission already granted")
            } else {
                print("⚠️ Screen Recording permission may have been denied")
            }
        }
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("📱 applicationDidFinishLaunching called")
    }
    
    private func checkAccessibilityPermission() -> Bool {
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: false]
        let trusted = AXIsProcessTrustedWithOptions(options)
        print("🔐 checkAccessibilityPermission() -> \(trusted)")
        return trusted
    }
    
    private func requestAccessibilityPermission() {
        print("🔐 Requesting accessibility permission with prompt...")
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true]
        let trusted = AXIsProcessTrustedWithOptions(options)
        
        if trusted {
            print("✅ User GRANTED accessibility permission")
            // Now setup hotkeys
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.startHotKeyListener()
            }
        } else {
            print("❌ User DENIED accessibility permission")
        }
    }
    
    private func startHotKeyListener() {
        print("🎯 HotKeyService setup starting...")
        
        HotKeyService.shared.onHotKeyPressed = {
            print("\n🔥🔥🔥 HOTKEY TRIGGERED - Cmd+Ctrl+C DETECTED 🔥🔥🔥\n")
            // Access the global CaptureViewModel instance and trigger capture
            DispatchQueue.main.async {
                print("✅ Starting capture from hotkey")
                CaptureViewModel.shared.startCapture()
            }
        }
        
        HotKeyService.shared.start()
        print("✅ HotKeyService is now ACTIVE - listening for Cmd+Ctrl+C\n")
    }
}
