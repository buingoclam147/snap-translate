# TSnap v2.1.1 Release Notes

**Release Date:** January 9, 2025

## 🎉 What's New

### ✨ Major Fixes & Improvements

#### 1. **Fixed Segmentation Fault on Multi-translate** 
- Fixed critical crash (Segmentation fault: 11) when translating multiple times
- App no longer crashes when user presses Cmd+Shift+X repeatedly
- Improved memory management and window lifecycle handling

#### 2. **Smart Popover Reuse**
- Popover now reuses existing window instead of creating duplicates
- Pressing Cmd+Shift+X multiple times only updates the content
- No more multiple popover windows cluttering the screen
- Much faster and cleaner user experience

#### 3. **Auto-close Popover Configuration**
- Removed unstable "Quick Notification" feature
- Added configurable "Auto-close Popover" setting (1-3600 seconds)
- Default: 10 seconds - popover automatically closes after translation completes
- Range: 1-3600 seconds (up to 1 hour)
- Users can customize in Settings → Popover Options

#### 4. **Improved Timer Management**
- Fixed timer cleanup issues
- Proper cancellation of auto-close timer when user manually closes popover
- No more memory leaks from dangling timers

### 📝 Changes

- ❌ Removed: Quick Notification toast feature (caused crashes)
- ✨ Added: Auto-close delay configuration in Settings
- ✨ Added: Smart popover reuse for better UX
- 🔧 Improved: Window lifecycle and memory management
- 🐛 Fixed: Segmentation fault on repeated translations
- 📖 Updated: README with current features and usage

### 📦 Downloads

- **TSnap.dmg** - macOS DMG installer (recommended)
- **TSnap.zip** - App bundle ZIP (alternative)

## 🔧 Installation

### From DMG (Recommended)
1. Download `TSnap.dmg`
2. Open the DMG file
3. Drag `TSnap.app` to the Applications folder
4. Done! App will be in Applications

### From ZIP
1. Download `TSnap.zip`
2. Unzip the file
3. Move `TSnap.app` to Applications folder
4. Run the app

## ⚡ Quick Start

**Default Hotkeys:**
- `Cmd + Ctrl + C` - Capture screenshot & auto-translate
- `Cmd + Shift + X` - Translate selected text
- `Esc` - Close popover / Cancel capture

**Settings:**
- Click TSnap icon in menu bar
- Click ⚙️ Settings button
- Customize hotkeys and auto-close delay

## 🐛 Known Issues

- None reported

## 🙏 Thanks

Thanks to all users for testing and providing feedback!

---

Made with ❤️ by [Bui Lam](https://github.com/buingoclam147)

**Support Development:** [GitHub Sponsors](https://github.com/sponsors/buingoclam147) | [Buy Me a Coffee](https://buymeacoffee.com/buingoclam147)
