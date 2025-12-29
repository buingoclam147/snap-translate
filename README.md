# TSnap - Instant Screenshot Translation for macOS

![TSnap](https://img.shields.io/badge/macOS-12.0+-blue?style=flat-square)
![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)

> **Translate screenshots and selected text instantly with a single hotkey. No subscriptions, no limits, 100% privacy-friendly.**

## 🎯 Quick Start

### ⚡ Default Hotkeys
- **`Cmd + Ctrl + C`** - Capture screenshot & auto-translate
- **`Cmd + Shift + X`** - Translate selected text
- **`Esc`** - Close popover / Cancel capture

### 📥 Download & Install

#### Option 1: Download Pre-built App (Recommended for Users)
```bash
# Download the latest release
curl -L https://download.tsnap.tech/TSnap-1.0.1.dmg -o ~/Downloads/TSnap.dmg

# Open DMG and drag TSnap.app to Applications folder
open ~/Downloads/TSnap.dmg
```

#### Option 2: Build from Source (For Developers)

**Prerequisites:**
- macOS 12.0 or later
- Xcode 14.0+ or Swift 5.9+

**Clone & Build:**
```bash
# Clone repository
git clone https://github.com/buingoclam147/snap-translate.git
cd snap-translate

# Run debug build
./run-debug.sh

# Or build release
./build-release.sh
```

---

## 🚀 Features

### 🖼️ Screenshot Capture + OCR
- Press `Cmd + Ctrl + C` to capture any region
- Automatic text extraction (English + Vietnamese)
- Confidence score for each text block
- One-click cancellation with ESC

### 🌐 Instant Translation
- **4 Smart Translation Engines:**
  - MyMemory (most stable, free)
  - LibreTranslate (open-source)
  - Google Translate (fast, reverse-engineered)
  - DeepL (highest quality)
- Automatic provider fallback on failure
- 3 automatic retry attempts
- Supports 15+ languages

### 🔊 Text-to-Speech
- Native macOS speech synthesis
- 15+ language voices
- Adjustable speech speed
- Play/Pause/Stop controls

### ⚙️ Smart Features
- Real-time translation (2s debounce)
- Language swap in one click
- Copy to clipboard
- Paste from clipboard
- Translate selected text (Cmd+Shift+X)
- Custom hotkey support
- Auto language detection

---

## 💻 Usage Examples

### Example 1: Translate Screenshot
```
1. Press Cmd + Ctrl + C
2. Drag to select area with text
3. Text appears in Translator
4. Result auto-translates
5. Click Copy or Speak
```

### Example 2: Translate Selected Text
```
1. Select any text on screen
2. Press Cmd + Shift + X
3. Translation appears instantly
```

### Example 3: Manual Translation
```
1. Click TSnap icon on menu bar
2. Type or paste text
3. Choose source/target language
4. Real-time translation appears
```

---

## 📱 System Requirements

| Requirement | Details |
|-------------|---------|
| **OS** | macOS 12.0 or later |
| **RAM** | 50-100 MB |
| **Disk** | ~20 MB |
| **Screen Recording** | Required (auto-requested on first launch) |
| **Accessibility** | NOT required (uses Carbon API) |
| **Internet** | Public endpoints only |

---

## 🔑 First Time Launch

When you open TSnap for the first time:

### ✅ What to Expect

1. **Gatekeeper Warning** (Expected)
   ```
   "TSnap" is damaged and can't be opened. 
   You should move it to the Trash.
   ```
   
   **This is normal!** The app is not signed with Apple's certificates.

2. **How to Fix:**
   
   **Option A: Right-click Open (Easy)**
   ```
   1. Right-click TSnap.app in Applications folder
   2. Click "Open"
   3. Click "Open" in the dialog that appears
   4. App is now permanently allowed
   ```
   
   **Option B: Terminal Command (Advanced)**
   ```bash
   xattr -d com.apple.quarantine /Applications/TSnap.app
   ```

3. **Screen Recording Permission**
   - First time you use capture, you'll be prompted
   - Grant permission in: System Settings → Privacy & Security → Screen & System Audio Recording
   - Polling timeout: 3 minutes

4. **Done!**
   - All hotkeys now work
   - Translator available via menu bar icon
   - Full functionality enabled

---

## 🛠️ Development & Building

### Build Scripts

#### Debug Build (Development)
```bash
./run-debug.sh
```
- Clears build cache
- Builds in debug mode
- Runs app directly
- Useful for testing changes

#### Release Build (Distribution)
```bash
./build-release.sh
```
- Creates proper app bundle
- Generates DMG (macOS standard)
- Creates ZIP (alternative format)
- Output in `releases/` folder

### Project Structure
```
snap-translate/
├── Sources/SnapTranslate/
│   ├── App/              # App entry point
│   ├── Services/         # Backend logic
│   ├── ViewModels/       # State management
│   ├── Views/            # UI components
│   └── Utilities/        # Helper functions
├── run-debug.sh          # Development script
├── build-release.sh      # Release script
├── Package.swift         # Swift Package manifest
├── FEATURES.md           # Detailed features (English)
├── APP_FEATURES.md       # Detailed features (Vietnamese)
└── README.md             # This file
```

### Available Services
- **TranslationService** - Translation with retry logic
- **OCRService** - Text extraction from images
- **CaptureService** - Screen capture
- **SpeechService** - Text-to-speech
- **HotKeyService** - Global hotkey listener
- **EscapeKeyService** - ESC key & translate hotkey

---

## 🔐 Security & Privacy

✅ **Privacy Features:**
- No user tracking
- No analytics
- No data collection
- 100% client-side processing
- Public API endpoints only

✅ **Permission Transparency:**
| Permission | Required | Why |
|-----------|----------|-----|
| Screen Recording | Yes | Capture screenshots |
| Accessibility | No | Not needed - uses Carbon API |
| Internet | No | System-level only |
| Microphone | No | Speaker output only |
| Camera | No | Not used |

✅ **API Security:**
- MyMemory: Free public API
- LibreTranslate: Open-source service
- Google Translate: Reverse-engineered (no official API)
- DeepL: Optional API key (user-provided)

---

## ⚡ Performance

| Metric | Value |
|--------|-------|
| OCR Processing | < 500ms |
| Translation | 500ms - 2s |
| UI Response | < 100ms |
| Memory Usage | 50-100 MB |
| CPU (Idle) | < 5% |

---

## 🎨 Customization

### Change Hotkeys

1. Open TSnap
2. Click ⚙️ (Settings) in popover
3. Customize OCR hotkey
4. Settings auto-saved

### Change Languages

Translator automatically remembers your language choices:
- Source language: Default English
- Target language: Default Vietnamese

---

## 📚 File Guide

| File | Purpose |
|------|---------|
| `FEATURES.md` | Detailed English feature documentation |
| `APP_FEATURES.md` | Detailed Vietnamese feature documentation |
| `README.md` | This file - quick start & overview |
| `run-debug.sh` | Development build & run |
| `build-release.sh` | Production release builder |
| `Package.swift` | Swift Package definition |

---

## 🤝 Support & Contributions

### ☕ Support Development

Love TSnap? Help support development:

- **[GitHub Sponsors](https://github.com/sponsors/buingoclam147)** - Direct monthly support
- **[Buy Me a Coffee](https://buymeacoffee.com/buingoclam147)** - One-time donation

Your support helps:
- Add new translation providers
- Improve OCR accuracy
- Expand language support
- Maintain free & open development

### 🐛 Bug Reports & Features

Found a bug or have a feature request?

- **GitHub Issues**: [Report here](https://github.com/buingoclam147/snap-translate/issues)
- **Email**: buingoclam00@gmail.com
- **LinkedIn**: [Bui Lam Frontend](https://www.linkedin.com/in/bui-lam-frontend/)

### 📝 Contributions

Want to contribute?

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

---

## 📄 License

TSnap is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

---

## 🗺️ Roadmap

### Coming Soon
- [ ] Context menu integration
- [ ] Hotkey indicator
- [ ] Translation history
- [ ] Multiple captures in one session
- [ ] Batch translation
- [ ] Custom dictionary support
- [ ] Offline translation mode

### Under Consideration
- [ ] iOS/iPadOS companion app
- [ ] Cloud sync (optional)
- [ ] Pro version with advanced features
- [ ] Plugin support

---

## 📊 Statistics

- **Supported Languages**: 15+
- **Translation Providers**: 4
- **Code Size**: ~2000 lines of Swift
- **Build Time**: ~30 seconds
- **App Size**: ~20 MB

---

## ❓ FAQ

### Q: Does TSnap require internet?
**A:** No, but translation providers do. You can use offline by typing instead of capturing.

### Q: Is my data safe?
**A:** Yes! TSnap is 100% client-side. No data is stored or sent anywhere except to public translation APIs.

### Q: Can I use custom hotkeys?
**A:** Yes! Open Settings (⚙️) in the popover to customize hotkeys.

### Q: What languages are supported?
**A:** Translation: 15+ languages. OCR: English & Vietnamese.

### Q: Why is the app "damaged"?
**A:** The app isn't signed with Apple's developer certificate. This is normal for unsigned apps. See "First Time Launch" section above.

### Q: Can I use multiple translation providers?
**A:** Yes! TSnap automatically falls back to other providers if one fails.

### Q: How do I uninstall TSnap?
**A:** Drag TSnap.app to Trash, or run: `rm -rf /Applications/TSnap.app`

### Q: Is there a paid version?
**A:** No, TSnap is completely free and open-source.

---

## 🎓 Technical Details

### Architecture
- **Frontend**: SwiftUI + AppKit
- **Backend**: Async/await + GCD
- **Networking**: URLSession
- **OCR**: Vision Framework
- **TTS**: AVFoundation
- **Hotkeys**: Carbon API
- **Storage**: UserDefaults

### Translation Providers
| Provider | Limit | Latency | Quality |
|----------|-------|---------|---------|
| MyMemory | 500 chars | 300-500ms | Good |
| LibreTranslate | 50,000 chars | 500ms-1s | Good |
| Google | 5,000 chars | 200-400ms | Excellent |
| DeepL | 50,000 chars | 500ms-2s | Excellent |

---

## 🙏 Credits

### Built With
- [Swift](https://swift.org/)
- [SwiftUI](https://developer.apple.com/swiftui/)
- [AppKit](https://developer.apple.com/appkit/)
- [Vision Framework](https://developer.apple.com/vision/)

### Translation Providers
- [MyMemory Translated](https://mymemory.translated.net/)
- [LibreTranslate](https://libretranslate.com/)
- [Google Translate](https://translate.google.com/)
- [DeepL](https://www.deepl.com/)

---

## 📞 Contact & Social

- **GitHub**: [@buingoclam147](https://github.com/buingoclam147)
- **LinkedIn**: [Bui Lam Frontend](https://www.linkedin.com/in/bui-lam-frontend/)
- **Email**: buingoclam00@gmail.com
- **Sponsors**: [GitHub Sponsors](https://github.com/sponsors/buingoclam147)
- **Coffee**: [Buy Me a Coffee](https://buymeacoffee.com/buingoclam147)

---

## 📈 Version History

### v1.0.1 (Current)
- Initial public release
- 4 translation providers
- 15+ language support
- Text-to-speech
- Custom hotkeys
- Full privacy-focused

---

## ⚖️ Disclaimer

TSnap uses public translation APIs. Usage is subject to each provider's terms of service:
- MyMemory: [Terms](https://mymemory.translated.net/doc/spec)
- LibreTranslate: [Terms](https://github.com/LibreTranslate/LibreTranslate)
- Google: Reverse-engineered, use at your own discretion
- DeepL: Requires valid API key

---

<div align="center">

**Made with ❤️ by [Bui Lam](https://github.com/buingoclam147)**

[![GitHub Sponsors](https://img.shields.io/badge/Sponsor-GitHub-green?style=for-the-badge&logo=github)](https://github.com/sponsors/buingoclam147)
[![Buy Me Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-FFDD00?style=for-the-badge&logo=buymeacoffee)](https://buymeacoffee.com/buingoclam147)

⭐ If TSnap helps you, please consider giving it a star on GitHub!

</div>
