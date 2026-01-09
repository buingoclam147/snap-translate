# ✅ TSnap v2.1.1 Release Checklist

## ✅ Pre-Release (COMPLETED)

### Code Changes
- [x] Fixed segmentation fault issue
- [x] Implemented smart popover reuse
- [x] Added configurable auto-close delay
- [x] Removed Quick Notification feature
- [x] Updated all affected files:
  - [x] QuickNotificationWindow.swift
  - [x] StatusBarManager.swift
  - [x] HotKeySettingsView.swift
  - [x] TranslatorPopoverView.swift
  - [x] SnapTranslateApp.swift

### Version Updates
- [x] Updated Info.plist
  - [x] CFBundleShortVersionString: 2.1.1
  - [x] CFBundleVersion: 211
- [x] Updated README.md
  - [x] Updated feature list
  - [x] Updated download instructions
  - [x] Updated customization section
  - [x] Updated version history

### Build & Packaging
- [x] Clean build in release mode
- [x] Created app bundle
- [x] Created DMG installer (863 KB)
- [x] Created ZIP archive (617 KB)
- [x] Verified file integrity
- [x] Confirmed file sizes correct

### Git & Tags
- [x] Committed all code changes (5af6685)
- [x] Pushed to main branch
- [x] Created v2.1.1 tag
- [x] Pushed tag to origin
- [x] Release notes prepared (RELEASE_v2.1.1.md)

### Documentation
- [x] RELEASE_v2.1.1.md - Full release notes
- [x] RELEASE_UPLOAD_GUIDE.md - Step-by-step upload guide
- [x] RELEASE_STEPS.md - Alternative methods
- [x] UPLOAD_RELEASE.md - Web interface instructions
- [x] v2.1.1_SUMMARY.md - Complete summary
- [x] This checklist file

---

## ⏳ Release (IN PROGRESS)

### Upload to GitHub
- [ ] **1. Open GitHub Releases**
  - URL: https://github.com/buingoclam147/snap-translate/releases
  
- [ ] **2. Find or Create v2.1.1 Release**
  - Look for v2.1.1 in releases
  - Click Edit or Draft new release
  - Select tag: v2.1.1
  
- [ ] **3. Add Release Information**
  - Title: TSnap v2.1.1
  - Description: (Copy from RELEASE_v2.1.1.md)
  - Mark as latest release (check box)
  
- [ ] **4. Upload Files**
  - Upload TSnap.dmg (863 KB)
  - Upload TSnap.zip (617 KB)
  - Wait for upload completion
  
- [ ] **5. Publish Release**
  - Click "Publish release" button
  - Verify release is live

### Verification
- [ ] Release page shows v2.1.1
- [ ] Description is visible and formatted correctly
- [ ] Both files are listed and downloadable
- [ ] Download links work
- [ ] File sizes are correct:
  - TSnap.dmg: 863 KB
  - TSnap.zip: 617 KB

---

## 📢 Post-Release

### Testing
- [ ] Test DMG download and installation
- [ ] Test ZIP download and installation
- [ ] Verify app launches without errors
- [ ] Test key features work:
  - [x] Cmd+Ctrl+C (capture)
  - [x] Cmd+Shift+X (translate)
  - [x] Settings access
  - [x] Auto-close setting

### Announcements
- [ ] Share release link with users
- [ ] Post on social media (optional)
- [ ] Update sponsors/supporters
- [ ] Share in relevant communities (optional)

### Post-Release Documentation
- [ ] Create release notes in GitHub
- [ ] Link to full documentation
- [ ] Update any external websites

---

## 📋 File Locations

### Built Files
```
/Users/lamngoc/tsnap/snap-translate/releases/
├── TSnap.dmg      (863 KB)    ✅ Ready
└── TSnap.zip      (617 KB)    ✅ Ready
```

### Source Code
```
/Users/lamngoc/tsnap/snap-translate/
├── Sources/SnapTranslate/
│   ├── App/
│   │   └── SnapTranslateApp.swift          ✅ Updated
│   ├── Services/
│   │   └── StatusBarManager.swift          ✅ Updated
│   ├── Views/
│   │   ├── HotKeySettingsView.swift        ✅ Updated
│   │   ├── QuickNotificationWindow.swift   ✅ Updated
│   │   └── TranslatorPopoverView.swift     ✅ Updated
│   └── Info.plist                          ✅ Updated (v2.1.1)
├── README.md                               ✅ Updated
└── Package.swift                           ✅ Current
```

### Documentation
```
├── RELEASE_v2.1.1.md           ✅ Release notes
├── RELEASE_UPLOAD_GUIDE.md     ✅ Step-by-step guide
├── RELEASE_STEPS.md            ✅ Alternative methods
├── UPLOAD_RELEASE.md           ✅ Web interface guide
├── v2.1.1_SUMMARY.md           ✅ Complete summary
└── RELEASE_CHECKLIST.md        ✅ This file
```

---

## 🔗 Release Links

**Repo:** https://github.com/buingoclam147/snap-translate

**Release Page:** https://github.com/buingoclam147/snap-translate/releases

**v2.1.1 Release:** https://github.com/buingoclam147/snap-translate/releases/tag/v2.1.1

**Download DMG:** https://github.com/buingoclam147/snap-translate/releases/download/v2.1.1/TSnap.dmg

**Download ZIP:** https://github.com/buingoclam147/snap-translate/releases/download/v2.1.1/TSnap.zip

---

## 📊 Release Summary

| Component | Status | Details |
|-----------|--------|---------|
| Code Changes | ✅ Done | All fixes and features implemented |
| Version Updated | ✅ Done | 2.1.1 in Info.plist |
| Build Created | ✅ Done | DMG & ZIP ready |
| Documentation | ✅ Done | All guides prepared |
| GitHub Tag | ✅ Done | v2.1.1 pushed |
| Files Ready | ✅ Done | Both files in releases/ |
| Files Uploaded | ⏳ TODO | Pending GitHub release |
| Release Published | ⏳ TODO | Ready to publish |
| Announced | ⏳ TODO | Share with users |

---

## 🎯 Quick Upload Instructions

### Fastest Way (2-5 minutes):

1. Open: https://github.com/buingoclam147/snap-translate/releases
2. Click on v2.1.1 (or "Draft a new release")
3. Add release notes (copy from RELEASE_v2.1.1.md)
4. Upload files:
   - `/Users/lamngoc/tsnap/snap-translate/releases/TSnap.dmg`
   - `/Users/lamngoc/tsnap/snap-translate/releases/TSnap.zip`
5. Click "Publish release"
6. ✅ Done!

---

## ✨ That's All!

Once you complete the release upload checklist, your v2.1.1 release is live and ready for users to download!

**Questions?** See RELEASE_UPLOAD_GUIDE.md for detailed step-by-step instructions.

---

**Created:** January 9, 2025
**Release Version:** TSnap v2.1.1
**Status:** Ready to publish
