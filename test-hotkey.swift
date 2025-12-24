#!/usr/bin/env swift
// Simple hotkey test - run this to see if global hotkey monitoring works

import AppKit
import Foundation

print("""
======================================================================
🔬 SnapTranslate Hotkey Test
======================================================================

This script will test if NSEvent.addGlobalMonitorForEvents works
on your system.

Instructions:
1. This script will print EVERY keystroke you make for 15 seconds
2. Press Cmd+Ctrl+C and watch the console
3. Check if it detects the keyCode for C

======================================================================
""")

let app = NSApplication.shared

var keyCount = 0
let startTime = Date()
let maxDuration: TimeInterval = 15  // seconds

let monitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
    keyCount += 1
    
    let cmd = event.modifierFlags.contains(.command)
    let ctrl = event.modifierFlags.contains(.control)
    let shift = event.modifierFlags.contains(.shift)
    let opt = event.modifierFlags.contains(.option)
    
    let char = String(UnicodeScalar(event.keyCode)!)
    
    print("[\(keyCount)] keyCode: \(String(format: "%2d", event.keyCode)) | Cmd:\(cmd ? "Y" : "N") Ctrl:\(ctrl ? "Y" : "N") Shift:\(shift ? "Y" : "N") Opt:\(opt ? "Y" : "N")")
    
    if cmd && ctrl {
        if event.keyCode == 8 {
            print("   ✅ This is C key (keyCode 8) with Cmd+Ctrl!")
        } else {
            print("   ⚠️ Cmd+Ctrl combo, but NOT C (keyCode 8). Got keyCode \(event.keyCode)")
        }
    }
}

if monitor == nil {
    print("❌ FAILED: NSEvent.addGlobalMonitorForEvents returned nil")
    print("   Accessibility permission might not be granted")
    exit(1)
}

print("✅ Monitor registered successfully")
print("📢 Now press keys. Test: Cmd+Ctrl+C")
print("⏱️  Listening for 15 seconds...\n")

// Keep app running for 15 seconds
DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(maxDuration)) {
    print("\n\n======================================================================")
    print("⏱️ Test complete!")
    print("Total keys captured: \(keyCount)")
    if keyCount > 0 {
        print("✅ Hotkey monitoring IS working on this system")
    } else {
        print("❌ No keys captured. Accessibility permission might not be granted")
    }
    print("======================================================================\n")
    exit(0)
}

// Run runloop
RunLoop.main.run()
