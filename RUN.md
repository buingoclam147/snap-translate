# SnapTranslate - Run Instructions

## ✅ Quick Start

```bash
./run-app.sh
```

This will:
1. Build the app if needed
2. Create a proper macOS app bundle (.app)
3. Launch the app
4. Clear accessibility cache to avoid repeated permission prompts

---

## 🔍 What You'll See

### First Run
```
==================================
🚀 SnapTranslate App Launcher
==================================

📦 Building SnapTranslate...
✅ App bundle ready at:
   /Users/lamngoc/snap-translate/.build/debug/SnapTranslate.app

▶️  Launching app...

🔐 Clearing accessibility cache...

✅ App launched!
```

### Console Output from App
```
======================================================================
🚀 SnapTranslate Starting
======================================================================

✅ AppDelegate initialized

✅ Window created

✅ Window displayed

⏱️ Waiting 0.5s before setting up hotkeys...

🎯 Setting up hotkeys now

======================================================================
🎯 AppDelegate.setupHotkeys() called - initializing hotkeys
======================================================================

🔐 checkAccessibilityPermission() -> false
⚠️ Accessibility permission NEEDED
📍 Please enable in: System Settings → Privacy & Security → Accessibility
📍 Add SnapTranslate to the list
🔐 Requesting accessibility permission with prompt...
```

### Permission Dialog
When first run, you'll see:
```
"SnapTranslate" would like to control this computer
using accessibility features.
```

**IMPORTANT**: 
- Click **"Open System Preferences"** (or go manually to System Settings > Privacy & Security > Accessibility)
- Add the SnapTranslate app to the list
- **Close the app completely** (not just window, but Cmd+Q)
- **Run the script again**: `./run-app.sh`

---

## 🎯 Test the Hotkey

After permission is granted and app is reopened:

1. You should see in console:
```
🔐 checkAccessibilityPermission() -> true
✅ Accessibility permission CONFIRMED - starting hotkey listener

🎯 HotKeyService setup starting...
✅ HotKeyService is now ACTIVE - listening for Cmd+Ctrl+C

▶️ App running - press Cmd+Ctrl+C to test
```

2. **Press Cmd + Ctrl + C** on your keyboard

3. You should see:
```
DEBUG: Cmd+Ctrl pressed, keyCode=8, cKeyPressed=true, shiftPressed=false
🔥🔥🔥 HOTKEY TRIGGERED - Cmd+Ctrl+C DETECTED 🔥🔥🔥

----------------------------------------------------------------------
🚀🚀🚀 CaptureViewModel.startCapture() called 🚀🚀🚀
----------------------------------------------------------------------

📷 Starting capture mode...
✅ Capture overlay displayed
```

4. Screen should darken - drag to select a region
5. Release mouse - region captures and shows result window

---

## ❌ Troubleshooting

### Permission Keeps Asking After Running Script
The script clears the cache, but if it still asks:
1. **Manually remove from System Settings:**
   - System Settings > Privacy & Security > Accessibility
   - Find SnapTranslate and click **-** to remove it
2. Run script again
3. Grant permission

### App Window Doesn't Show
- Check console for error messages
- Verify window centering code is correct
- Try Cmd+Tab to switch to app window if it's hidden

### Hotkey Doesn't Work
- Console must show `✅ HotKeyService is now ACTIVE`
- If it shows `❌ checkAccessibilityPermission() -> false`, permission not granted
- Try pressing Cmd+Ctrl+C in different apps to test
- Check if another app is intercepting the hotkey

### Capture Overlay Appears But Won't Respond
- Try dragging a larger area (min 10×10 pixels)
- Console should show `🖱️ Mouse down at` when you click
- If not, mouse events not received

---

## 🔧 Manual Build & Run (Advanced)

```bash
# Build only
cd /Users/lamngoc/snap-translate
swift build

# Create app bundle manually
mkdir -p .build/debug/SnapTranslate.app/Contents/MacOS
mkdir -p .build/debug/SnapTranslate.app/Contents/Resources

cp .build/debug/SnapTranslate .build/debug/SnapTranslate.app/Contents/MacOS/
cp Sources/SnapTranslate/Info.plist .build/debug/SnapTranslate.app/Contents/
cp Sources/SnapTranslate/SnapTranslate.entitlements .build/debug/SnapTranslate.app/Contents/

# Run
open .build/debug/SnapTranslate.app
```

---

## 📋 Checklist

- [ ] Run `./run-app.sh`
- [ ] See app window with SnapTranslate title
- [ ] Grant accessibility permission when prompted
- [ ] Close app completely
- [ ] Run script again
- [ ] See "HotKeyService is now ACTIVE" in console
- [ ] Press Cmd+Ctrl+C
- [ ] Screen darkens with overlay
- [ ] Drag to select region
- [ ] Result window shows with screenshot + text

**If all ✅, then app is working!**
