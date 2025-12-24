import Foundation
#if os(macOS)
import AppKit
import CoreGraphics

class CaptureService {
    static let shared = CaptureService()
    
    /// Capture a region of the screen including all windows
    /// Uses CGDisplayCreateImage to capture the actual display (bypasses window layers)
    func captureRegion(_ rect: CGRect) -> NSImage? {
        LogService.shared.debug("🎬 CaptureService.captureRegion START - rect: \(rect)")
        
        let displayID = CGMainDisplayID()
        LogService.shared.debug("  DisplayID: \(displayID)")
        
        // Get the scale factor (Retina displays have scale > 1)
        let scaleFactor = NSScreen.main?.backingScaleFactor ?? 1.0
        LogService.shared.debug("  Scale factor: \(scaleFactor)")
        
        // Get display bounds to handle multi-monitor setups
        let displayBounds = CGDisplayBounds(displayID)
        LogService.shared.debug("  Display bounds: \(displayBounds)")
        
        // Use CGDisplayCreateImage to capture the main display directly
        // This bypasses all window layers and captures what's actually visible
        guard let cgImage = CGDisplayCreateImage(displayID) else {
            LogService.shared.error("❌ CGDisplayCreateImage failed")
            return nil
        }
        
        LogService.shared.debug("  Full display captured: \(cgImage.width) × \(cgImage.height)")
        
        // Convert screen coordinates to display pixel coordinates
        // Y-axis flip: macOS screen coords have Y=0 at bottom, increasing upward
        // but cropping needs top-left origin, so flip: displayY = displayHeight - screenY - screenHeight
        let displayHeight = displayBounds.height
        
        let displayRect = CGRect(
            x: (rect.origin.x - displayBounds.origin.x) * scaleFactor,
            y: (displayHeight - displayBounds.origin.y - rect.origin.y - rect.height) * scaleFactor,
            width: rect.width * scaleFactor,
            height: rect.height * scaleFactor
        )
        
        LogService.shared.debug("  Screen rect: \(rect)")
        LogService.shared.debug("  Display bounds: origin=(\(Int(displayBounds.origin.x)), \(Int(displayBounds.origin.y))), height=\(Int(displayHeight))")
        LogService.shared.debug("  Display pixel rect: \(displayRect)")
        
        // Crop to the selected region
        guard let croppedImage = cgImage.cropping(to: displayRect) else {
            LogService.shared.error("❌ Failed to crop to region: \(displayRect)")
            return nil
        }
        
        let nsImage = NSImage(cgImage: croppedImage, size: .zero)
        LogService.shared.info("✅ Region captured: \(Int(rect.width))×\(Int(rect.height)) from (\(Int(rect.origin.x)), \(Int(rect.origin.y)))")
        LogService.shared.debug("  Cropped image: \(croppedImage.width) × \(croppedImage.height)")
        
        return nsImage
    }
}
#endif
