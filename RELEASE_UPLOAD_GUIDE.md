# 📤 TSnap v2.1.1 Upload Guide

## Status: Ready to Upload! ✅

Everything is prepared. Just follow these **3 simple steps** to upload to GitHub!

---

## Step 1️⃣: Open GitHub Releases Page

**Go to:** https://github.com/buingoclam147/snap-translate/releases

You should see this:
```
📦 v2.1.1 (tag created, waiting for release)
```

---

## Step 2️⃣: Create/Edit Release

### If You See a Draft:
1. Click on **v2.1.1** 
2. Click **Edit** button
3. Skip to Step 3

### If You Don't See a Draft:
1. Click **"Draft a new release"** button
2. In "Choose a tag" field, select **v2.1.1**
3. Title: `TSnap v2.1.1`
4. Continue to Step 3

---

## Step 3️⃣: Add Release Details & Upload Files

### A. Add Release Notes

In the description field, paste this:

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
4. Done!

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

### B. Upload Files

Scroll down and look for **"Attachments"** section that says:
```
"Attach binaries by dropping them here or selecting them"
```

Click and select these 2 files:

**File 1:**
- Path: `/Users/lamngoc/tsnap/snap-translate/releases/TSnap.dmg`
- Size: 863 KB

**File 2:**
- Path: `/Users/lamngoc/tsnap/snap-translate/releases/TSnap.zip`
- Size: 617 KB

Wait for upload to complete (you'll see checkmarks ✅)

---

## Step 4️⃣: Publish Release

Scroll down and click the **"Publish release"** button

That's it! 🎉 Your release is live!

---

## Verify Upload Worked

After publishing, you should see:

✅ Release page shows v2.1.1
✅ Description is visible
✅ Both files listed:
   - TSnap.dmg (863 KB)
   - TSnap.zip (617 KB)
✅ Download buttons work

---

## Test Downloads

Open a terminal and verify files download correctly:

```bash
# Test DMG
curl -L https://github.com/buingoclam147/snap-translate/releases/download/v2.1.1/TSnap.dmg -O
ls -lh TSnap.dmg

# Test ZIP
curl -L https://github.com/buingoclam147/snap-translate/releases/download/v2.1.1/TSnap.zip -O
ls -lh TSnap.zip
```

Both should show the correct file sizes:
- TSnap.dmg: 863 KB
- TSnap.zip: 617 KB

---

## Share the Release! 📢

Once live, you can share:

**Release Link:** 
```
https://github.com/buingoclam147/snap-translate/releases/tag/v2.1.1
```

**Direct Download Links:**
```
DMG: https://github.com/buingoclam147/snap-translate/releases/download/v2.1.1/TSnap.dmg
ZIP: https://github.com/buingoclam147/snap-translate/releases/download/v2.1.1/TSnap.zip
```

---

## Troubleshooting

### "Can't find v2.1.1 tag"
- Tag was created ✅ 
- Try refreshing the page (F5)
- Or manually type "v2.1.1" in the tag field

### "Upload button not visible"
- Make sure you're editing an existing release (not creating new)
- Scroll down - upload section is below description

### "Upload stuck/failing"
- Try refreshing the page
- Try uploading one file at a time
- Use web interface instead of CLI

### "File size doesn't match"
Verify files are correct:
```bash
ls -lh ~/tsnap/snap-translate/releases/
```

Should show:
- TSnap.dmg: 863 KB (or similar)
- TSnap.zip: 617 KB (or similar)

---

## That's All! 🎉

Release is complete once you hit "Publish release"

Your users can now:
1. Visit: https://github.com/buingoclam147/snap-translate/releases
2. Click v2.1.1
3. Download DMG or ZIP
4. Install and use

---

## Files Being Released

### TSnap.dmg (863 KB)
- Standard macOS DMG installer
- Recommended for users
- Double-click to open, drag app to Applications

### TSnap.zip (617 KB)
- App bundle ZIP archive
- Alternative format
- Unzip and move to Applications

Both contain the exact same app - just different formats!

---

## Questions?

If you run into issues:
1. Check this guide again (most common issues covered)
2. Look at your browser console for error messages
3. Try incognito/private mode if browser caching issues
4. Try a different browser

---

**✨ You're all set! Good luck with the release! ✨**
