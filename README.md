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
# Download the latest release from GitHub
# Visit: https://github.com/buingoclam147/snap-translate/releases

# Or download directly with curl:
curl -L https://github.com/buingoclam147/snap-translate/releases/download/v2.1.1/TSnap.dmg -o ~/Downloads/TSnap.dmg

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

## 🚀 Core Features

### 📸 Screenshot Capture + OCR
- Press `Cmd + Ctrl + C` to capture any region on screen
- Automatic text extraction (supports English + Vietnamese)
- High-accuracy character recognition
- Confidence scoring for each text block
- One-click cancellation with `ESC` key
- Instant display in Translator popover

### 🌐 Instant Translation
- **4 Smart Translation Engines with Auto-Fallback:**
  - MyMemory (most stable, free, recommended)
  - LibreTranslate (open-source, self-hosted option)
  - Google Translate (fast, reverse-engineered)
  - DeepL (highest quality, requires API key)
- Automatic provider fallback on failure
- 3 automatic retry attempts
- Supports 15+ languages
- Real-time translation (2s debounce)

### 🔊 Text-to-Speech (Multiple Provider Support)
- Native macOS speech synthesis (AVSpeechSynthesizer)
- 15+ language voices with native pronunciation
- Adjustable speech speed (optimized rates for words vs. sentences)
- Single-word optimization for dictionary-style pronunciation
- Full-sentence optimization for natural speech
- Play/Pause/Stop controls

### ✨ Translator Popover (Main Interface)
- Real-time translation as you type
- Language swap in one click
- Copy translation to clipboard
- Paste text from clipboard
- Manual text input
- Auto language detection
- Translation history display
- Speaker icon for text-to-speech
- Custom language selection
- Visual source/target language indicators

### ⚙️ Smart Features
- **Translate Selected Text** - Press `Cmd + Shift + X` on any highlighted text
- **Auto Language Detection** - Automatically detects source language
- **Custom Hotkeys** - Customize all hotkeys in settings
- **Auto-close Popover** - Set custom auto-close delay (1-3600 seconds, default 10s)
- **Language Memory** - App remembers your last used languages
- **Persistent Settings** - All preferences saved automatically
- **Dark Mode Support** - Full light/dark theme support
- **Smart Popover Reuse** - Pressing translate hotkey again fills new text instead of opening duplicate window

---

## 🔧 Setup & Permissions

TSnap is designed for Apple Silicon. To unlock its full potential, grant the following permissions:

### 🎬 Screen & System Recording (Required)

**Purpose:** Needed for screenshot capture and OCR text extraction.

**How to Enable:**
1. Open **System Settings**
2. Navigate to **Privacy & Security** (left sidebar)
3. Scroll down and click **Screen & System Audio Recording**
4. Click the **+ (plus)** button
5. Select **TSnap** from Applications folder
6. Click **Open**

**Alternative:** When you first use the capture feature (`Cmd + Ctrl + C`), macOS will prompt you automatically.

**Polling Timeout:** If you don't grant permission within 3 minutes, you'll need to manually enable it.

### ⌨️ Accessibility Access (Required for Selected Text Translation)

**Purpose:** Needed for `Cmd + Shift + X` hotkey to detect text you've highlighted in other apps.

**How to Enable:**
1. Open **System Settings**
2. Navigate to **Privacy & Security** (left sidebar)
3. Scroll down and click **Accessibility**
4. Click the **+ (plus)** button
5. Select **TSnap** from Applications folder
6. Click **Open**

**Note:** Without this permission, `Cmd + Shift + X` won't work, but you can still use `Cmd + Ctrl + C` to capture screenshots.

---

## 💻 Usage Examples

### Example 1: Translate Screenshot
```
1. Press Cmd + Ctrl + C
2. Drag to select area with text
3. Text appears in Translator popover
4. Result auto-translates
5. Click speaker icon to hear pronunciation
6. Click copy button to copy to clipboard
```

### Example 2: Translate Selected Text
```
1. Select any text on screen in ANY app
2. Press Cmd + Shift + X
3. Translation appears in popover
4. Popover auto-closes after 10 seconds (configurable)
5. Click speaker icon or copy button as needed
```

### Example 3: Manual Translation via Translator
```
1. Click TSnap icon on menu bar
2. Type or paste text in input field
3. Choose source/target language
4. Real-time translation appears instantly
5. Use speaker or copy as needed
```

---

## 📱 System Requirements

| Requirement | Details |
|-------------|---------|
| **OS** | macOS 12.0 or later |
| **Processor** | Apple Silicon (recommended) |
| **RAM** | 50-100 MB |
| **Disk Space** | ~20 MB |
| **Screen Recording** | Required (for screenshot capture) |
| **Accessibility** | Required (for `Cmd + Shift + X`) |
| **Internet** | Required for translation APIs |

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

3. **Permission Prompts**
   - Screen Recording: Grant when prompted or set manually (see Setup & Permissions)
   - Accessibility: Grant when prompted or set manually (see Setup & Permissions)

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
│   ├── App/              # App entry point & delegate
│   ├── Services/         # Backend services
│   │   ├── TranslationService.swift
│   │   ├── OCRService.swift
│   │   ├── CaptureService.swift
│   │   ├── SpeechService.swift
│   │   ├── HotKeyService.swift
│   │   └── EscapeKeyService.swift
│   ├── ViewModels/       # State management
│   ├── Views/            # UI components
│   │   ├── TranslatorPopoverView.swift
│   │   ├── ResultPopoverView.swift
│   │   └── QuickNotificationView.swift
│   ├── Assets.xcassets/  # Images & icons
│   └── Utilities/        # Helper functions
├── run-debug.sh          # Development script
├── build-release.sh      # Release script
├── Package.swift         # Swift Package manifest
├── README.md             # This file
└── FEATURES.md           # Detailed documentation
```

### Available Services
- **TranslationService** - Translation with retry logic & provider fallback
- **OCRService** - Text extraction from images using Vision Framework
- **CaptureService** - Screen capture with region selection
- **SpeechService** - Text-to-speech with multiple language support
- **HotKeyService** - Global hotkey listener (Carbon API)
- **EscapeKeyService** - ESC key & translate hotkey detection

---

## 🔐 Security & Privacy

✅ **Privacy Features:**
- No user tracking
- No analytics
- No data collection
- 100% client-side processing
- Public API endpoints only
- Open-source & verifiable

✅ **Permission Transparency:**
| Permission | Required | Why |
|-----------|----------|-----|
| Screen Recording | Yes | Capture screenshots & OCR |
| Accessibility | Yes | Detect selected text (Cmd+Shift+X) |
| Internet | Yes | Translation APIs |
| Microphone | No | Speaker output only |
| Camera | No | Not used |
| Contacts | No | Not used |
| Files | No | Not used |

✅ **API Security:**
- **MyMemory**: Free public API, no authentication needed
- **LibreTranslate**: Open-source service, can be self-hosted
- **Google Translate**: Reverse-engineered API (use at your own discretion)
- **DeepL**: Optional premium API key (user-provided, encrypted in UserDefaults)

---

## ⚡ Performance

| Metric | Value |
|--------|-------|
| OCR Processing | < 500ms |
| Translation | 500ms - 2s (depends on provider) |
| UI Response | < 100ms |
| Memory Usage | 50-100 MB |
| CPU (Idle) | < 5% |
| App Launch | ~1-2 seconds |

---

## 🎨 Customization

### Change Hotkeys

1. Open TSnap (click menu bar icon)
2. Click **⚙️ Settings** button in popover
3. Customize OCR & Translate hotkeys
4. Settings auto-saved to UserDefaults

### Auto-close Popover

Configure how long the popover stays open after translation completes:
1. Click **⚙️ Settings** in the popover
2. Under "Popover Options", enter desired delay in seconds (1-3600)
3. Default is 10 seconds
4. Example: Set to 30 for longer reading time, or 3600 to disable auto-close

### Change Languages

TSnap automatically remembers your language choices:
- Source language: Default English
- Target language: Default Vietnamese
- Changes persist across sessions

### Chinese OCR Prioritization

Enable in Settings under "OCR Options" to prioritize Chinese character recognition (Simplified & Traditional)

---

## 📚 File Guide

| File | Purpose |
|------|---------|
| `README.md` | Quick start & overview (this file) |
| `FEATURES.md` | Detailed documentation |
| `run-debug.sh` | Development build & run script |
| `build-release.sh` | Production release builder |
| `Package.swift` | Swift Package definition |
| `XCODE_SETUP.md` | Xcode project setup guide |
| `DEEPL_API_SETUP.md` | DeepL API configuration |

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
- Add new features
- Maintain free & open development

### 🐛 Bug Reports & Features

Found a bug or have a feature request?

- **GitHub Issues**: [Report here](https://github.com/buingoclam147/snap-translate/issues)
- **Email**: buingoclam00@gmail.com
- **LinkedIn**: [Bui Lam Frontend](https://www.linkedin.com/in/bui-lam-frontend/)

---

## 📄 License

TSnap is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

---

## 📊 Statistics

- **Supported Languages**: 15+
- **Translation Providers**: 4 (MyMemory, LibreTranslate, Google, DeepL)
- **TTS Languages**: 15+
- **Code Size**: ~2000+ lines of Swift
- **Build Time**: ~30 seconds
- **App Size**: ~20 MB
- **Open Source**: Yes
- **Subscription Required**: No

---

## ❓ FAQ

### Q: Does TSnap require internet?
**A:** Yes, translation requires internet connection. Screenshot capture and basic UI work offline.

### Q: Is my data safe?
**A:** Yes! TSnap is 100% client-side. No data is stored or sent anywhere except to public translation APIs. All processing happens on your device.

### Q: Can I use custom hotkeys?
**A:** Yes! Open Settings (⚙️) in the popover to customize all hotkeys.

### Q: What languages are supported?
**A:** Translation: 15+ languages (English, Vietnamese, Spanish, French, German, Italian, Portuguese, Russian, Japanese, Korean, Chinese, Thai, Arabic, Hindi, Indonesian). OCR: English & Vietnamese.

### Q: Why is the app "damaged"?
**A:** The app isn't signed with Apple's developer certificate. This is normal for unsigned apps. See "First Time Launch" section above.

### Q: Can I use multiple translation providers?
**A:** Yes! TSnap automatically falls back to other providers if one fails, ensuring translation always works.

### Q: How do I uninstall TSnap?
**A:** Drag TSnap.app to Trash, or run: `rm -rf /Applications/TSnap.app`

### Q: Is there a paid version?
**A:** No, TSnap is completely free and open-source.

### Q: Does TSnap work with DeepL?
**A:** Yes! You can configure a DeepL API key in settings for higher quality translations.

### Q: Why does text-to-speech sometimes sound odd?
**A:** TSnap uses macOS native voices. Quality varies by language. You can adjust speech speed in settings.

---

## 🎓 Technical Details

### Architecture
- **Frontend**: SwiftUI + AppKit
- **Backend**: Async/await + GCD
- **Networking**: URLSession
- **OCR**: Vision Framework
- **TTS**: AVFoundation (AVSpeechSynthesizer)
- **Hotkeys**: Carbon API
- **Storage**: UserDefaults
- **Pattern**: MVVM + Services

### Translation Providers
| Provider | Limit | Latency | Quality | Auth |
|----------|-------|---------|---------|------|
| MyMemory | 500 chars | 300-500ms | Good | None |
| LibreTranslate | 50,000 chars | 500ms-1s | Good | Optional |
| Google | 5,000 chars | 200-400ms | Excellent | None |
| DeepL | 50,000 chars | 500ms-2s | Excellent | API Key |

### Supported Languages
English, Vietnamese, Spanish, French, German, Italian, Portuguese, Russian, Japanese, Korean, Chinese (Simplified), Thai, Arabic, Hindi, Indonesian

---

## 🙏 Credits

### Built With
- [Swift](https://swift.org/)
- [SwiftUI](https://developer.apple.com/swiftui/)
- [AppKit](https://developer.apple.com/appkit/)
- [Vision Framework](https://developer.apple.com/vision/)
- [AVFoundation](https://developer.apple.com/avfoundation/)

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

### v2.0+ (Current)
- Screenshot capture with OCR (English + Vietnamese)
- 4 translation providers with auto-fallback
- 15+ language support
- Text-to-speech with optimized rates
- Selected text translation (Cmd+Shift+X)
- Custom hotkeys (OCR & Translate)
- Configurable auto-close popover (1-3600 seconds)
- Smart popover reuse (no duplicate windows)
- Chinese OCR prioritization option
- Full privacy-focused, no tracking

---

## ⚖️ Disclaimer

TSnap uses public translation APIs. Usage is subject to each provider's terms of service:
- **MyMemory**: [Terms](https://mymemory.translated.net/doc/spec)
- **LibreTranslate**: [Terms](https://github.com/LibreTranslate/LibreTranslate)
- **Google**: Reverse-engineered API, use at your own discretion
- **DeepL**: Requires valid API key and complies with [DeepL Terms](https://www.deepl.com/en/privacy)

---

<div align="center">

**Made with ❤️ by [Bui Lam](https://github.com/buingoclam147)**

[![GitHub Sponsors](https://img.shields.io/badge/Sponsor-GitHub-green?style=for-the-badge&logo=github)](https://github.com/sponsors/buingoclam147)
[![Buy Me Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-FFDD00?style=for-the-badge&logo=buymeacoffee)](https://buymeacoffee.com/buingoclam147)

⭐ If TSnap helps you, please consider giving it a star on GitHub!

</div>
