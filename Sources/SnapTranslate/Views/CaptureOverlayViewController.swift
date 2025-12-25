import AppKit

class SimpleOverlayView: NSView {
    var onRegionSelected: ((CGRect) -> Void)?
    
    private var startPoint = NSPoint.zero
    private var endPoint = NSPoint.zero
    private var isDrawing = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        print("✅ SimpleOverlayView awake from nib")
        updateCursor()
    }
    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        updateCursor()
    }
    
    private func updateCursor() {
        // Set crosshair cursor immediately
        DispatchQueue.main.async {
            NSCursor.crosshair.push()
        }
    }
    
    override var acceptsFirstResponder: Bool {
        return true
    }
    
    override func resignFirstResponder() -> Bool {
        // Keep first responder even if focus tries to change
        return false
    }
    
    // MOUSE DOWN
    override func mouseDown(with event: NSEvent) {
        // Convert window coordinates to screen coordinates
        let screenLoc = self.window?.convertPoint(toScreen: event.locationInWindow) ?? event.locationInWindow
        startPoint = screenLoc
        endPoint = startPoint
        isDrawing = true
        
        LogService.shared.debug("🖱️ Mouse DOWN - window: \(event.locationInWindow) → screen: \(startPoint)")
        if let window = self.window {
            LogService.shared.debug("  Window frame: \(window.frame), level: \(window.level)")
        }
    }
    
    // MOUSE DRAGGED
    override func mouseDragged(with event: NSEvent) {
        guard isDrawing else { return }
        let screenLoc = self.window?.convertPoint(toScreen: event.locationInWindow) ?? event.locationInWindow
        endPoint = screenLoc
        self.needsDisplay = true
    }
    
    // MOUSE UP
    override func mouseUp(with event: NSEvent) {
        guard isDrawing else { return }
        
        let screenLoc = self.window?.convertPoint(toScreen: event.locationInWindow) ?? event.locationInWindow
        endPoint = screenLoc
        isDrawing = false
        
        LogService.shared.debug("🖱️ Mouse UP at: \(endPoint)")
        
        let selectedRect = CGRect(
            x: min(startPoint.x, endPoint.x),
            y: min(startPoint.y, endPoint.y),
            width: abs(endPoint.x - startPoint.x),
            height: abs(endPoint.y - startPoint.y)
        )
        
        LogService.shared.info("📸 Selection rect: origin=(\(Int(selectedRect.origin.x)), \(Int(selectedRect.origin.y))), size=\(Int(selectedRect.width))×\(Int(selectedRect.height))")
        
        if selectedRect.width > 10 && selectedRect.height > 10 {
            LogService.shared.info("✅ Valid selection, capturing...")
            onRegionSelected?(selectedRect)
        } else {
            LogService.shared.error("⚠️ Selection too small: \(Int(selectedRect.width))×\(Int(selectedRect.height))")
        }
    }
    
    // KEYBOARD
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 {  // ESC
            print("🛑 ESC pressed")
            onRegionSelected?(.zero)
        }
    }
    
    // Change cursor to crosshair
    override func resetCursorRects() {
        super.resetCursorRects()
        addCursorRect(bounds, cursor: NSCursor.crosshair)
    }
    
    // DRAW
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Dark overlay
        NSColor.black.withAlphaComponent(0.3).setFill()
        bounds.fill()
        
        // Draw selection rectangle
        if isDrawing && abs(endPoint.x - startPoint.x) > 5 && abs(endPoint.y - startPoint.y) > 5 {
            let rect = CGRect(
                x: min(startPoint.x, endPoint.x),
                y: min(startPoint.y, endPoint.y),
                width: abs(endPoint.x - startPoint.x),
                height: abs(endPoint.y - startPoint.y)
            )
            
            // Blue fill
            NSColor.blue.withAlphaComponent(0.1).setFill()
            rect.fill()
            
            // Blue dashed border
            NSColor.blue.setStroke()
            let path = NSBezierPath(rect: rect)
            path.lineWidth = 2
            let dashes: [CGFloat] = [5, 5]  // 5px dash, 5px gap
            path.setLineDash(dashes, count: dashes.count, phase: 0)
            path.stroke()
            
            // Size text
            let sizeText = "\(Int(rect.width)) × \(Int(rect.height))"
            let attrs: [NSAttributedString.Key: Any] = [
                .font: NSFont.monospacedSystemFont(ofSize: 12, weight: .regular),
                .foregroundColor: NSColor.white,
                .backgroundColor: NSColor.black.withAlphaComponent(0.6)
            ]
            let attrString = NSAttributedString(string: sizeText, attributes: attrs)
            attrString.draw(at: NSPoint(x: rect.maxX - 80, y: rect.maxY - 20))
        }
        
        // Instructions - single line + multilingual
        if !isDrawing {
            let style = NSMutableParagraphStyle()
            style.alignment = .center
            style.lineSpacing = 8
            
            let attrs: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 16, weight: .semibold),
                .foregroundColor: NSColor.white,
                .paragraphStyle: style
            ]
            
            let text = """
Drag to select, Press ESC to cancel
拖动选择，按 ESC 取消
Kéo để chọn, Nhấn ESC để hủy
"""
            
            let attrString = NSAttributedString(string: text, attributes: attrs)
            let size = attrString.size()
            attrString.draw(at: NSPoint(x: bounds.midX - size.width / 2, y: bounds.midY + 40))
        }
    }
}
