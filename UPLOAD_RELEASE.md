# Upload v2.1.1 Release to GitHub

## Quick Summary

✅ **Đã hoàn thành:**
- [x] Commit code changes
- [x] Push code to main branch
- [x] Create & push v2.1.1 tag
- [x] Build DMG & ZIP files

❌ **Cần làm tiếp:**
- [ ] Upload DMG & ZIP files to GitHub release

---

## How to Upload Files

### Method 1: Using GitHub Web Interface (Easiest)

1. **Open Release Page**
   - Go to: https://github.com/buingoclam147/snap-translate/releases

2. **Find v2.1.1 Draft**
   - You should see "v2.1.1" in draft status
   - Click on it to edit

3. **Upload Files**
   - Scroll down to "Attachments" section
   - Click "Attach binaries by dropping them here or selecting them"
   - Select these files:
     - `/Users/lamngoc/tsnap/snap-translate/releases/TSnap.dmg` (863 KB)
     - `/Users/lamngoc/tsnap/snap-translate/releases/TSnap.zip` (617 KB)

4. **Add Release Notes**
   - Copy content from `RELEASE_v2.1.1.md`
   - Paste into release description

5. **Publish Release**
   - Click "Publish release"

---

## Release Notes to Copy

Copy everything below and paste into GitHub release:

```
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
```

---

## Files to Attach

### File 1: TSnap.dmg
- **Path:** `/Users/lamngoc/tsnap/snap-translate/releases/TSnap.dmg`
- **Size:** 863 KB
- **Format:** macOS DMG (recommended for users)

### File 2: TSnap.zip
- **Path:** `/Users/lamngoc/tsnap/snap-translate/releases/TSnap.zip`
- **Size:** 617 KB
- **Format:** ZIP archive (alternative)

---

## Verify Files Exist

Run this to confirm files are ready:
```bash
ls -lh /Users/lamngoc/tsnap/snap-translate/releases/
```

Should show:
```
-rw-r--r--  TSnap.dmg   (863 KB)
-rw-r--r--  TSnap.zip   (617 KB)
```

---

## After Publishing

### 1. Verify Release Page
Visit: https://github.com/buingoclam147/snap-translate/releases/tag/v2.1.1

✓ Check that:
- Title shows "v2.1.1"
- Description is correct
- Both files (DMG & ZIP) are listed
- Download links work

### 2. Test Downloads
```bash
# Download and verify
curl -L https://github.com/buingoclam147/snap-translate/releases/download/v2.1.1/TSnap.dmg -O
curl -L https://github.com/buingoclam147/snap-translate/releases/download/v2.1.1/TSnap.zip -O

# Check file sizes
ls -lh TSnap.*
```

### 3. Update Version in README (Optional)
- Download link in README now shows v2.1.1
- Already updated ✅

---

## That's It! 🎉

Release is live and ready for users to download!

**Release Page:** https://github.com/buingoclam147/snap-translate/releases

Users can now:
- Download TSnap v2.1.1 from GitHub
- Get automatic notifications about the new release
- Choose between DMG or ZIP format
