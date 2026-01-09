# GitHub Release Upload Steps for v2.1.1

## Prerequisites
- Git configured with GitHub
- GitHub CLI installed (optional but easier) OR use web interface

## Option 1: Using GitHub CLI (Easiest)

### Step 1: Install GitHub CLI (if not already installed)
```bash
brew install gh
```

### Step 2: Authenticate with GitHub
```bash
gh auth login
# Follow the prompts - choose GitHub.com, HTTPS, authenticate
```

### Step 3: Create Release with Files
```bash
cd /Users/lamngoc/tsnap/snap-translate

# Create release v2.1.1 with both DMG and ZIP files
gh release create v2.1.1 \
  --title "TSnap v2.1.1" \
  --notes-file RELEASE_v2.1.1.md \
  releases/TSnap.dmg \
  releases/TSnap.zip
```

That's it! Release is created and files are uploaded automatically.

### Verify Release
```bash
gh release view v2.1.1
```

---

## Option 2: Using Web Interface (GitHub.com)

### Step 1: Open GitHub Releases Page
Go to: https://github.com/buingoclam147/snap-translate/releases

### Step 2: Click "Create a new release"
- Click the "Draft a new release" button

### Step 3: Fill in Release Details
- **Tag version:** `v2.1.1`
- **Release title:** `TSnap v2.1.1`
- **Description:** Copy content from `RELEASE_v2.1.1.md`

### Step 4: Upload Assets
Click "Attach binaries by dropping them here or selecting them"
- Upload `releases/TSnap.dmg`
- Upload `releases/TSnap.zip`

### Step 5: Publish
- Click "Publish release"

---

## Option 3: Using Git + GitHub Web UI (Manual)

### Step 1: Commit Changes
```bash
cd /Users/lamngoc/tsnap/snap-translate

git add -A
git commit -m "chore: release v2.1.1

- Fixed segmentation fault on repeated translations
- Added smart popover reuse
- Added configurable auto-close delay (1-3600s, default 10s)
- Removed unstable Quick Notification feature
- Updated README with current features"

git push origin main
```

### Step 2: Create Tag
```bash
git tag -a v2.1.1 -m "Release v2.1.1"
git push origin v2.1.1
```

### Step 3: Create Release on Web
- Go to: https://github.com/buingoclam147/snap-translate/releases
- Click "Create a new release"
- Select tag: `v2.1.1`
- Add title and description (copy from `RELEASE_v2.1.1.md`)
- Upload files: `TSnap.dmg` and `TSnap.zip`
- Click "Publish release"

---

## Files to Upload

Located in: `/Users/lamngoc/tsnap/snap-translate/releases/`

1. **TSnap.dmg** (863 KB)
   - Standard macOS installer format
   - Recommended for users

2. **TSnap.zip** (617 KB)
   - App bundle ZIP
   - Alternative format

---

## Release Checklist

- [x] Version updated in Info.plist (2.1.1)
- [x] Version updated in README.md
- [x] Build created successfully
- [x] DMG file generated (863 KB)
- [x] ZIP file generated (617 KB)
- [x] Release notes created (`RELEASE_v2.1.1.md`)
- [ ] Release created on GitHub
- [ ] Files uploaded to GitHub
- [ ] Release published

---

## After Release

### 1. Verify Release Page
Visit: https://github.com/buingoclam147/snap-translate/releases/tag/v2.1.1

Check:
- Title is correct
- Description is clear
- Both files (DMG & ZIP) are uploaded
- Download links work

### 2. Test Downloads
```bash
# Test DMG download
curl -L https://github.com/buingoclam147/snap-translate/releases/download/v2.1.1/TSnap.dmg -O

# Test ZIP download
curl -L https://github.com/buingoclam147/snap-translate/releases/download/v2.1.1/TSnap.zip -O
```

### 3. Announce Release
- Post on your social media
- Update sponsors/supporters
- Share in any relevant communities

---

## Troubleshooting

### "gh release create" fails with authentication error
```bash
gh auth logout
gh auth login
# Re-authenticate with GitHub
```

### "gh release create" fails with tag already exists
```bash
# Delete the tag if needed
gh release delete v2.1.1 --yes
git tag -d v2.1.1
git push origin --delete v2.1.1

# Then recreate
```

### Files didn't upload
- Check file paths are correct
- Ensure files exist: `ls -lh releases/`
- Try uploading through web interface instead

### Need to edit release after publishing
- Go to release page
- Click "Edit"
- Make changes
- Click "Update release"

---

## Release Complete! 🎉

Once released, users can:
- Download from: https://github.com/buingoclam147/snap-translate/releases
- Get instant notifications about new release
- Download DMG or ZIP directly

Users can update by:
1. Download new version
2. Drag to Applications to replace old version
3. Done!
