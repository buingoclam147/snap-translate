# SnapTranslate (TSnap) - Application Features

## 📋 Overview
**TSnap** is a macOS application that enables quick translation of text snippets from captured screenshots or selected text on the screen. The application runs completely in the background, doesn't require continuous internet connectivity, and intelligently processes multiple languages.

---

## 🎯 Main Features

### 1. **Screen Capture + OCR (Screen Capture)**
- **Hotkey:** `Cmd + Ctrl + C` (customizable)
- Drag to select the region to capture on any application
- Multi-language support (English + Vietnamese)
- Extract text from captured images
- Uses **CGDisplayCreateImage** (bypasses window layers) - captures exactly what's displayed
- **Press ESC to cancel** capture anytime
- Shows confidence score (%) for each OCR text block

### 2. **Real-Time Translation (Translation)**
- **Open Translator Popover:** 
  - Cmd + Shift + X (translate selected text)
  - Click app icon on menu bar
- Enter multi-language content
- Switch source/target languages
- Copy & paste text
- **Real-time translation:** 2-second debounce while typing

**4 Translation Providers with Auto-Fallback:**

| Provider | Limit | Features |
|----------|-------|----------|
| **MyMemory** | 500 chars/request | Most stable, free, auto text chunking |
| **LibreTranslate** | 50,000 chars | Open source, multipart form-data |
| **Google Translate** | 5,000 chars | Reverse-engineered, fast for short text (≤100 chars) |
| **DeepL** | 50,000 chars | Highest quality, requires API key |

**Smart Provider Routing:**
- Text ≤ 100 chars → Google Translate
- Text > 100 chars → MyMemory
- Auto-fallback when provider fails

**Retry Mechanism:** 3 automatic retry attempts on translation failure

### 3. **Text-to-Speech (Text-to-Speech)**
- Uses **AVSpeechSynthesizer** (macOS native)
- Supports 15+ languages:
  - English (en-US)
  - Vietnamese (vi-VN)
  - Spanish (es-ES)
  - French (fr-FR)
  - German (de-DE)
  - Italian (it-IT)
  - Portuguese (pt-BR)
  - Russian (ru-RU)
  - Japanese (ja-JP)
  - Korean (ko-KR)
  - Chinese (zh-CN)
  - Thai (th-TH)
  - Arabic (ar-SA)
  - Hindi (hi-IN)
  - Indonesian (id-ID)
- Adjustable speech rate (0.0 ~ 1.0)
- Stop/Pause/Resume speech playback

### 4. **Hotkey & Keyboard Controls**
- **Global OCR Hotkey:** Cmd + Ctrl + C (customizable)
- **Translate Hotkey:** Cmd + Shift + X (translate selected text)
- **ESC Key:**
  - Cancel capture in drag mode
  - Close translator popover
- **Carbon API** for OCR hotkey (no permissions needed)
- **Global Event Monitor** for translate hotkey (no permissions needed)

### 5. **User Interface (UI/UX)**

**a) Status Bar Menu**
- App icon in menu bar (top-right)
- Click to open Translator Popover
- Support & Help menu
- Quit app

**b) Translator Popover**
- Input field: enter/edit text
- Language selector: choose source & target languages
- Swap button: swap languages + text
- Speak button: read text via TTS
- Copy buttons: copy source/translated text
- Paste button: paste from clipboard
- Clear button: clear source text
- OCR button: capture image from popover
- Real-time translation (2s debounce)
- Real-time language change (0.3s debounce)

**c) Capture Overlay**
- Full-screen overlay in drag mode
- Drag to select capture region
- ESC to cancel
- Non-intrusive (borderless, transparent)

### 6. **Storage & Customization**
- **UserDefaults** stores:
  - Source/Target language (translator)
  - Custom hotkeys (OCR hotkey)
- Preferences saved **automatically**
- No API keys stored (except DeepL - optional)

### 7. **System Permissions**
- **Required:** Screen Recording Permission
  - Auto-requested on first launch
  - macOS 13+ uses ScreenCaptureKit
  - macOS < 13 fallback to CGDisplayCreateImage
  - Polling mechanism with 3-minute timeout
- **Not Required:** 
  - Accessibility Permission (uses Carbon API + Global Event Monitor instead)
  - Internet permission (public endpoints)

### 8. **Logging & Debugging**
- **LogService:** Detailed logging for each action
  - Debug logs: detailed information
  - Info logs: important information
  - Error logs: errors that occur
- Console output for monitoring
- Timestamps in logs

### 9. **Performance & Optimization**
- **Async/await** for all API calls
- **GCD** (Grand Central Dispatch) for background tasks
- **Debounce timers** to prevent API spam (2s translation, 0.3s language change)
- **Efficient image processing** (Retina display aware)
- Memory management with weak references
- Cancel support for OCR & capture

### 10. **Error Handling**
- Network error handling
- Rate limit detection (429 HTTP)
- Invalid API key detection (403 HTTP)
- Service unavailable handling (503 HTTP)
- Fallback providers on failure
- User-friendly error messages (English & Vietnamese)

### 11. **Multi-Language Support**
- UI display: system language
- Supported translation languages: 15+
- Error messages: English & Vietnamese
- OCR supports: English + Vietnamese

---

## 🏗️ Application Architecture

### Services (Backend Logic)
- **TranslationService**: Manages translation with retry logic
- **TranslationManager**: Provider fallback mechanism
- **OCRService**: Vision Framework OCR (English + Vietnamese)
- **CaptureService**: CGDisplayCreateImage screen capture
- **SpeechService**: Text-to-speech (AVSpeechSynthesizer)
- **HotKeyService**: Global hotkey listener (Carbon API)
- **EscapeKeyService**: ESC key + Translate hotkey listener
- **StatusBarManager**: Menu bar UI & popover management
- **LogService**: Logging system
- **TranslationProviders**: 4 providers (MyMemory, LibreTranslate, Google, DeepL)

### ViewModels (State Management)
- **CaptureViewModel**: Capture state, overlay management, OCR trigger
- **TranslatorViewModel**: Text/language state, translation/OCR, TTS
- **HotKeyViewModel**: Hotkey settings state
- **ResultViewModel**: Legacy result window state

### Views (UI Components)
- **TranslatorPopoverView**: Quick translation popover (primary UI)
- **ResultPopoverView**: Result popover (alternative)
- **ResultWindow**: Result window (legacy mode)
- **HotKeySettingsView**: Hotkey settings
- **LogView**: Debug log viewer
- **CaptureOverlayViewController**: Capture overlay (SimpleOverlayView)

---

## 📱 User Workflows

### Workflow 1: Quick Screen Capture OCR
1. Press **Cmd + Ctrl + C**
2. Drag to select region to capture
3. App automatically performs OCR
4. View results in translator popover
5. Auto-translate to selected language

### Workflow 2: Translate Selected Text
1. Select text on screen (any application)
2. Press **Cmd + Shift + X**
3. App gets text from clipboard (via Cmd+C)
4. View translation in translator popover

### Workflow 3: Manual Text Input
1. Click app icon on menu bar
2. Open translator popover
3. Type or paste text
4. Choose language
5. View real-time translation (2s debounce)

### Workflow 4: Text-to-Speech
1. Have translated text
2. Click "Speak" button
3. Listen to speech via speaker
4. Can pause/resume/stop

---

## 🔧 Technical Stack
- **Language**: Swift 5.9+
- **Framework**: SwiftUI, AppKit
- **macOS Support**: 12.0+
- **OCR**: Vision Framework (VNRecognizeTextRequest)
- **TTS**: AVFoundation (AVSpeechSynthesizer)
- **Networking**: URLSession (async/await)
- **Storage**: UserDefaults
- **Hotkey**: Carbon API (RegisterEventHotKey)
- **Screen Capture**: CoreGraphics (CGDisplayCreateImage)
- **Global Events**: NSEvent.addGlobalMonitorForEvents

---

## 📊 Supported Languages (Translation)
- Vietnamese (vi) - default target
- English (en) - default source
- Spanish (es)
- French (fr)
- German (de)
- Italian (it)
- Portuguese (pt)
- Russian (ru)
- Japanese (ja)
- Korean (ko)
- Chinese (zh)
- Thai (th)
- Arabic (ar)
- Hindi (hi)
- Indonesian (id)

---

## 🎨 UI/UX Features
- **Menu bar integration** - quick access
- **Popover interface** - floating translator
- **Dark mode support** - respects system theme
- **Keyboard shortcuts** - hotkeys for main actions
- **Real-time translation** - instant feedback
- **Loading indicators** - visual feedback during processing
- **Error notifications** - user-friendly messages
- **Copyable results** - quick clipboard copy
- **Language swap button** - swap source/target
- **Voice playback controls** - pause/resume/stop

---

## ⚙️ Configuration
| Setting | Value | Purpose |
|---------|-------|---------|
| OCR Hotkey | Cmd + Ctrl + C | Screenshot + OCR |
| Translate Hotkey | Cmd + Shift + X | Translate selected text |
| Translation Debounce | 2 seconds | Prevent API spam while typing |
| Language Change Debounce | 0.3 seconds | Debounce when swapping language |
| Retry Attempts | 3 | Number of retries on failure |
| OCR Languages | English + Vietnamese | Recognition languages |
| Default Target Language | Vietnamese | Default translation language |
| Default Source Language | English | Default source language |
| Permission Polling | 3 minutes max | Permission check timeout |

---

## 🚀 Key Innovations
1. **Smart Provider Routing** - selects optimal provider based on text length
2. **Automatic Fallback** - automatically switches provider on failure
3. **Zero-Permission Hotkey** - uses Carbon API, no Accessibility needed
4. **Global Event Monitoring** - listens to events from any application
5. **Smart Debouncing** - different debounce for typing (2s) vs language change (0.3s)
6. **Retry Mechanism** - 3 automatic retry attempts on failure
7. **URL Encoding Handling** - special encoding handling for MyMemory
8. **Multi-Chunk Support** - automatically splits large text into chunks
9. **Native macOS Integration** - uses AVSpeechSynthesizer, AppKit, Carbon
10. **Efficient OCR** - Vision Framework with confidence scoring

---

## 📝 Important Notes
- Application **does not store API keys** for MyMemory, LibreTranslate, Google (uses public endpoints)
- DeepL API key (optional) stored in UserDefaults - users can configure
- All API calls use **public endpoints** - no backend server
- Privacy-friendly: **no user tracking, no analytics**
- Capture uses CGDisplayCreateImage - captures exactly what's actually displayed
- OCR result quality depends on captured image quality

---

## 🔐 Permissions & Security
| Permission | Required | Used For |
|------------|----------|----------|
| Screen Recording | ✅ Yes | Screen capture using CGDisplayCreateImage |
| Accessibility | ❌ No | Carbon API used instead |
| Internet | ❌ No | URLSession (system level) |
| Microphone | ❌ No | TTS uses speaker, not recording |
| Camera | ❌ No | Uses screen capture, not camera |

---

## 📈 Performance Metrics
- **OCR Processing:** < 500ms (depends on image size)
- **Translation API Call:** 500ms - 2s (depends on provider & text size)
- **UI Response Time:** < 100ms
- **Memory Usage:** ~50-100MB
- **CPU Usage:** Low (<5%) when idle, peaks during capture/OCR
