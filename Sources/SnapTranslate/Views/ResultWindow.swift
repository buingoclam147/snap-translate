#if os(macOS)
import AppKit
import SwiftUI

class ResultWindow: NSWindow {
    convenience init(viewModel: ResultViewModel) {
        print("📊 ResultWindow.init() - Creating result window")
        let contentView = ResultPopoverView(viewModel: viewModel)
        print("✅ ResultPopoverView created")
        let hostingView = NSHostingView(rootView: contentView)
        print("✅ NSHostingView created")
        
        let width: CGFloat = 900
        let height: CGFloat = 550
        
        // Center on screen
        let screen = NSScreen.main ?? NSScreen.screens[0]
        let centerX = screen.frame.midX - (width / 2)
        let centerY = screen.frame.midY - (height / 2)
        let frame = NSRect(x: centerX, y: centerY, width: width, height: height)
        print("📍 Window frame: \(frame)")
        
        self.init(
            contentRect: frame,
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        
        self.contentView = hostingView
        self.title = "OCR Result"
        self.level = .floating  // Always on top
        self.isReleasedWhenClosed = false
        self.appearance = NSAppearance(named: .aqua)
        
        print("✅ ResultWindow initialized and configured")
    }
}
#endif
