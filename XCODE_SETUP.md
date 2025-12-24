# SnapTranslate - Xcode Project Setup & Run Guide

## ✅ Xcode Project Created

The Xcode project file (`SnapTranslate.xcodeproj`) has been created and is now open.

---

## 🔧 Required Xcode Configuration

### **1. Set Signing & Capabilities**
1. **Select Target**: SnapTranslate (left sidebar)
2. **Go to**: Signing & Capabilities tab
3. **Team**: Select your Apple Developer Team (or leave blank for testing)
4. **Entitlements**: Should already reference `SnapTranslate/SnapTranslate.entitlements`

### **2. Verify Entitlements**
- File: `SnapTranslate/SnapTranslate.entitlements`
- Contains:
  ```xml
  <key>com.apple.security.automation</key>
  <true/>
  ```
  This allows access to accessibility APIs.

### **3. Verify Info.plist**
- File: `SnapTranslate/Info.plist`
- Contains:
  ```xml
  <key>NSAccessibilityUsageDescription</key>
  <string>SnapTranslate needs accessibility permission...</string>
  ```
  This permission string will be shown to the user.

---

## 🚀 Run the App

1. **Select Scheme**: Top bar → SnapTranslate
2. **Select Device**: My Mac
3. **Run**: Cmd+R or ▶ button

### **Expected Console Output** (immediately)
```
======================================================================
🚀 SnapTranslateApp.init() - Application Starting
======================================================================

✅ AppDelegate set

📱 ContentView appeared - Setting up hotkeys...

======================================================================
🎯 AppDelegate.setupHotkeys() called - initializing hotkeys
======================================================================

🔐 checkAccessibilityPermission() -> false
⚠️ Accessibility permission NEEDED
📍 Please enable in: System Settings → Privacy & Security → Accessibility
📍 Add SnapTranslate to the list
🔐 Requesting accessibility permission with prompt...
```

---

## 🔐 Grant Accessibility Permission

When the app first runs, it will show a dialog:
```
"SnapTranslate" would like to control this computer
using accessibility features.
```

**Click "Open System Preferences"** or go manually:

1. **System Settings** → **Privacy & Security**
2. **Scroll down** → **Accessibility**
3. **Click + button** at bottom
4. **Select** Applications → SnapTranslate
5. **Click Open**

### After granting permission:
- Quit and reopen the app (Cmd+Q then Cmd+R)
- Console should show:
```
🔐 checkAccessibilityPermission() -> true
✅ Accessibility permission CONFIRMED - starting hotkey listener

🎯 HotKeyService setup starting...
✅ HotKeyService is now ACTIVE - listening for Cmd+Ctrl+C
```

---

## 🎯 Test the Hotkey

### **If HotKeyService is active:**

1. **Press**: Cmd + Ctrl + C
2. **Expected**: Console shows:
```
🔥🔥🔥 HOTKEY TRIGGERED - Cmd+Ctrl+C DETECTED 🔥🔥🔥

----------------------------------------------------------------------
🚀🚀🚀 CaptureViewModel.startCapture() called 🚀🚀🚀
----------------------------------------------------------------------

📷 Starting capture mode...
✅ Capture overlay displayed
```

3. **Screen should darken** - Full screen overlay appears with crosshair cursor
4. **Drag to select** a region
5. **Release mouse** - Region captures and sends to OCR
6. **Result window** appears with screenshot + extracted text

---

## ❌ Troubleshooting

### **If permission dialog keeps appearing:**
- The app needs to be **signed with a development certificate**
- System remembers accessibility permissions by app **bundle ID + code signature**
- Fix: Go to Signing & Capabilities → ensure Team is set

### **If hotkey doesn't work:**
1. Check Accessibility permission is granted in System Settings
2. Try pressing Cmd+Ctrl+C in different apps to test
3. Check console for: `🔥🔥🔥 HOTKEY TRIGGERED` message
4. If you see DEBUG keyCode messages instead, let me know the keyCode value

### **If overlay appears but won't capture:**
- Drag a larger area (minimum 10×10 pixels)
- Check mouse events in console: `🖱️ Mouse down at`

### **If result window doesn't appear:**
- Check console for: `📊 ResultWindow.init()`
- Verify OCR completed: `✅ OCR completed in X.XXs`

---

## 📊 Full Flow Checklist

- [ ] App launches without crashing
- [ ] Console shows "AppDelegate set"
- [ ] Console shows accessibility permission prompt
- [ ] Grant permission in System Settings
- [ ] Reopen app
- [ ] Console shows "HotKeyService is now ACTIVE"
- [ ] Press Cmd+Ctrl+C
- [ ] Console shows "HOTKEY TRIGGERED"
- [ ] Screen darkens with overlay
- [ ] Drag to select region
- [ ] Overlay captures image
- [ ] Result window shows with screenshot + text

---

## 🔗 Key Files

| File | Purpose |
|------|---------|
| `SnapTranslate.xcodeproj` | Xcode project configuration |
| `SnapTranslate/Info.plist` | App metadata & permissions |
| `SnapTranslate/SnapTranslate.entitlements` | Security entitlements |
| `SnapTranslate/App/SnapTranslateApp.swift` | App entry point |
| `SnapTranslate/Services/HotKeyService.swift` | Global hotkey listener |
| `SnapTranslate/ViewModels/CaptureViewModel.swift` | Capture logic |

---

**Now open Xcode and click Cmd+R to run the app!**
