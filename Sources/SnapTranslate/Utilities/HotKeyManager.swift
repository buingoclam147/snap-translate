import Foundation
#if os(macOS)
import Carbon
#endif

/// Manages hotkey storage and retrieval
class HotKeyManager {
    static let shared = HotKeyManager()
    
    private let defaults = UserDefaults.standard
    private let key = "SnapTranslateHotKey"
    
    /// Get current saved hotkey string (default: "Cmd+Shift+C")
    func getSavedHotKey() -> String {
        return defaults.string(forKey: key) ?? "Cmd+Shift+C"
    }
    
    /// Save hotkey to UserDefaults
    func saveHotKey(_ hotKey: String) {
        defaults.set(hotKey, forKey: key)
        print("💾 Hotkey saved: \(hotKey)")
    }
    
    /// Parse hotkey string to (keyCode, modifiers)
    /// Format: "Cmd+Shift+C" → (8, 393216)
    func parseHotKey(_ hotKeyString: String) -> (keyCode: UInt32, modifiers: UInt32) {
        let parts = hotKeyString.components(separatedBy: "+")
        
        var modifiers: UInt32 = 0
        var keyCode: UInt32 = 8  // Default to C
        
        for part in parts {
            switch part.lowercased() {
            case "cmd":
                modifiers |= UInt32(cmdKey)
            case "shift":
                modifiers |= UInt32(shiftKey)
            case "ctrl":
                modifiers |= UInt32(controlKey)
            case "opt", "option":
                modifiers |= UInt32(optionKey)
            default:
                keyCode = getKeyCode(for: part)
            }
        }
        
        return (keyCode, modifiers)
    }
    
    /// Convert key name to Carbon key code
    private func getKeyCode(for keyName: String) -> UInt32 {
        switch keyName.lowercased() {
        case "c": return 8
        case "x": return 7
        case "v": return 9
        case "s": return 1
        case "d": return 2
        case "f": return 3
        case "a": return 0
        case "b": return 11
        case "e": return 14
        case "g": return 5
        case "h": return 4
        case "i": return 34
        case "j": return 38
        case "k": return 40
        case "l": return 37
        case "m": return 46
        case "n": return 45
        case "o": return 31
        case "p": return 35
        case "q": return 12
        case "r": return 15
        case "t": return 17
        case "u": return 32
        case "w": return 13
        case "y": return 16
        case "z": return 6
        default: return 8  // Default to C
        }
    }
}
