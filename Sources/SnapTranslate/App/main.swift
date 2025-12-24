import AppKit
import SwiftUI

print("\n" + String(repeating: "=", count: 70))
print("🚀 SnapTranslate Starting")
print(String(repeating: "=", count: 70) + "\n")

// Create and configure app delegate
let appDelegate = AppDelegate()
let app = NSApplication.shared
app.delegate = appDelegate

print("✅ AppDelegate initialized\n")

// Create main window
let mainWindow = NSWindow(
    contentRect: NSRect(x: 0, y: 0, width: 500, height: 350),
    styleMask: [.titled, .closable, .miniaturizable, .resizable],
    backing: .buffered,
    defer: false
)

mainWindow.title = "SnapTranslate"
mainWindow.isReleasedWhenClosed = false
mainWindow.identifier = NSUserInterfaceItemIdentifier("mainWindow")

// Store reference globally so CaptureViewModel can access it
AppDelegate.mainWindow = mainWindow

// Content view
let contentView = ContentView()
let hostingView = NSHostingView(rootView: contentView)
mainWindow.contentView = hostingView

// Center on screen
if let screen = NSScreen.main {
    let frame = screen.visibleFrame
    mainWindow.setFrame(
        NSRect(
            x: frame.midX - 250,
            y: frame.midY - 175,
            width: 500,
            height: 350
        ),
        display: true
    )
}

print("✅ Window created\n")

// Show window
mainWindow.makeKeyAndOrderFront(nil)
app.activate(ignoringOtherApps: true)

print("✅ Window displayed\n")

// Setup hotkeys
print("⏱️ Waiting 0.5s before setting up hotkeys...\n")
DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
    print("🎯 Setting up hotkeys now\n")
    appDelegate.setupHotkeys()
}

print("▶️ App running - press Cmd+Ctrl+C to test\n")

// Run
app.run()
