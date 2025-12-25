import AppKit
import SwiftUI

print("\n" + String(repeating: "=", count: 70))
print("🚀 ESnap Starting (StatusBar Mode)")
print(String(repeating: "=", count: 70) + "\n")

fflush(stdout)
fflush(stderr)

// Create and configure app delegate
let appDelegate = AppDelegate()
let app = NSApplication.shared
app.delegate = appDelegate

print("✅ AppDelegate initialized\n")

// No main window - status bar app only
print("✅ Status bar only mode - no main window\n")

// Setup hotkeys
print("⏱️ Scheduling hotkey setup...\n")
DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
    print("🎯 Setting up hotkeys now\n")
    appDelegate.setupHotkeys()
}

print("▶️ App running (background mode) - press Cmd+Ctrl+C or click status bar icon\n")

// Run
app.run()
