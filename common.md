# 📱 ESnap

**Instant OCR & Translation Overlay for macOS**

---

## 🎯 1. Product Vision

ESnap is a native macOS application that allows users to:

- Press a global shortcut (Cmd + Ctrl + C)
- Drag to select any region on screen
- Capture the selected area from any app/UI
- Extract all text using OCR
- Display a popover overlay in the center of screen showing:
  - **Left panel**: Original screenshot
  - **Right panel**: Extracted text (OCR)

### Phase 2 (Future) - Translation

- Auto-translate to bilingual:
  - Top: English (original)
  - Bottom: Vietnamese (translated)

### Core Principles

- ⚡ Fast (instant feedback)
- 🍎 Native macOS (Swift + SwiftUI)
- 🏪 App Store compatible

---

## 🧠 2. User Flow (Phase 1 - MVP)

### Capture & OCR Flow

1. User presses **Cmd + Shift + S**
2. Screen darkens (fullscreen overlay appears)
3. Cursor changes to crosshair
4. User drags from **top-left → bottom-right** to select region
5. On mouse release:
   - App captures selected area as PNG
   - Runs OCR (Vision Framework)
   - Displays popover with image + text
6. User can:
   - Copy extracted text
   - Close with ESC or Click X

---

## 🖥️ 3. UI/UX Layout

### Capture Mode
```
┌─────────────────────────────────────┐
│                                     │
│     Fullscreen Overlay              │
│     (Transparent, dark dimming)     │
│                                     │
│     Cursor: Crosshair               │
│     Draw: Rectangle on drag         │
│                                     │
└─────────────────────────────────────┘
```

### Result Popover (Center of Screen)
```
┌─────────────────────────────────────┐
│  [Image Preview] │  OCR Text        │
│                  │  ────────────    │
│  (500x600px)     │  English plain   │
│                  │  text here       │
│                  │                  │
│  Buttons:        │  [Copy] [Close]  │
│  • Copy All      │                  │
│  • Close (ESC)   │                  │
└─────────────────────────────────────┘
```

**Window Properties:**
- Always centered on screen
- Always on top
- No modal behavior (allow background interaction)
- Auto-close on ESC or X button

---

## 🛠️ 4. Tech Stack (Phase 1)

### ✅ VERIFIED TECH

| Component | Tech | Status | Notes |
|-----------|------|--------|-------|
| **Language** | Swift | ✅ | Native, App Store approved |
| **UI Framework** | SwiftUI | ✅ | Modern, maintainable |
| **Global Hotkey** | NSEvent.addGlobalMonitorForEvents | ✅ | Apple official, needs accessibility permission |
| **Screen Capture** | ScreenCaptureKit (macOS 13.2+) | ✅ | Modern, but requires Screen Recording entitlement |
| **Screen Capture (Fallback)** | CoreGraphics (CGDisplayCreateImageForRect) | ✅ | Works without special entitlements |
| **Overlay Window** | NSWindow (AppKit) + SwiftUI | ✅ | Borderless, transparent, fullscreen |
| **OCR Engine** | Vision Framework (VNRecognizeTextRequest) | ✅ | Built-in, offline, supports EN + VI |
| **Result Display** | SwiftUI Views | ✅ | Native |
| **Permissions** | Info.plist + Privacy policy | ⚠️ | Accessibility for hotkey, Screen Recording for capture |

### 🔹 Global Hotkey Implementation

**Approach 1 (Recommended for Phase 1):**
```
NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
    if event.keyCode == 1 && event.modifierFlags.contains([.command, .shift]) {
        // Cmd + Shift + S detected
    }
}
```

**Notes:**
- Requires "Accessibility" permission (user-friendly)
- No external dependencies needed
- Works reliably on macOS 10.15+

**Alternative (if needed later):**
- `KeyboardShortcuts` package (Swift Package Manager) - lightweight, SwiftUI-friendly
- Not necessary for MVP

### 🔹 Screen Capture Decision

| Method | Pros | Cons | Phase 1? |
|--------|------|------|----------|
| **ScreenCaptureKit** | Modern API, clean code | Requires Screen Recording entitlement | ❌ Later |
| **CoreGraphics** | Works without special permission, instant | Slightly lower-level | ✅ Use this |

**Phase 1 Plan:**
- Use **CoreGraphics** (CGDisplayCreateImageForRect) for instant capture
- No extra permission needed beyond Accessibility
- Can upgrade to ScreenCaptureKit in Phase 2

### 🔹 OCR (Vision Framework)

```swift
import Vision

let request = VNRecognizeTextRequest()
request.recognitionLanguages = ["en", "vi"]
request.usesCoreMLModel = false

try VNImageRequestHandler(cgImage: image).perform([request])
let results = request.results as? [VNRecognizedTextObservation]
```

**Status:** ✅ Perfect for Phase 1
- Offline 100%
- Fast (~200-500ms for typical screenshots)
- Supports English + Vietnamese
- App Store approved

---

## 📦 5. Architecture (Modular for Xcode Testing)

### Module Breakdown

```
ESnap/
├── App/
│   └── SnapTranslateApp.swift        (Entry point)
│
├── Services/
│   ├── HotKeyService.swift           (Cmd+Shift+S listener)
│   ├── CaptureService.swift          (Screen capture)
│   └── OCRService.swift              (Vision Framework wrapper)
│
├── ViewModels/
│   ├── CaptureViewModel.swift        (Overlay state)
│   └── ResultViewModel.swift         (OCR results)
│
├── Views/
│   ├── CaptureOverlayView.swift      (Selection UI)
│   ├── ResultPopoverView.swift       (Results display)
│   └── Components/
│       ├── ImagePreviewView.swift
│       ├── TextDisplayView.swift
│       └── ControlButtonsView.swift
│
└── Utilities/
    └── ImageUtils.swift              (Helper functions)
```

---

## 📅 6. Development Timeline (Phase 1 - MVP)

### Stage 1: Core Setup (Day 1)
- [x] Create SwiftUI app project
- [x] Configure Info.plist for permissions (accessibility request)
- [x] Create basic app structure (App, Services, ViewModels, Views)
- [x] **Xcode Test:** App launches ✅

### Stage 2: Capture Overlay (Days 2-3)
- [x] Connect HotKeyService to app delegate
- [x] Implement NSWindow fullscreen overlay
- [x] Mouse drag detection (crosshair cursor)
- [x] Draw selection rectangle on drag (with size indicator)
- [x] Capture selected region to NSImage
- [x] **Xcode Test:** Press Cmd+Shift+S, drag on screen, capture works ✅

### Stage 3: OCR Integration (Day 4)
- [x] Wrap Vision Framework in OCRService (already done)
- [x] Connect OCR trigger after image capture
- [x] Process captured image → extract text (async with timing)
- [x] Handle multiple languages (EN + VI) with confidence scores
- [x] **Xcode Test:** OCR results print to console ✅

### Stage 4: Result UI (Days 5-6)
- [x] Design ResultPopoverView (SwiftUI)
- [x] Image + Text panels (950x580 window)
- [x] Copy button (NSPasteboard integration)
- [x] Close button with Cmd+W shortcut
- [x] ResultWindow floating panel (always on top)
- [x] **Xcode Test:** Full flow works end-to-end ✅

### Stage 5: Polish & Testing (Days 7-8)
- [x] Error handling (permission dialogs)
- [x] Performance optimization
- [x] UI refinements
- [x] macOS 11+ compatibility
- [x] **Xcode Test:** Full app testing, prepare for App Store review

**Total Estimate:** 5-8 days for one dev ✅ **COMPLETED**

---

## 🚀 Phase 2: Enhanced UI + Translation

### Stage 1: UI/UX Improvements (Days 1-3)
- [x] Redesign result window layout:
  - [x] Top section: Full image preview (responsive height)
  - [x] Bottom section: Split bilingual text (EN left, VI right)
  - [x] Adjust window aspect ratio (900x650) for better visual hierarchy
- [x] Simplify home screen:
  - [x] Remove clutter, keep only 2 buttons:
    - [x] `Capture & Translate` button (trigger capture)
    - [x] `Open Settings` button (open system preferences)
  - [x] Added title, subtitle, and footer hints
- [ ] Add macOS menu bar integration (Phase 2.4):
  - [ ] Status bar icon with dropdown menu
  - [ ] Quick capture from menu bar
  - [ ] Settings/Preferences from menu

### Stage 2: Translation Integration (Days 3-5)
- [x] Evaluate translation solutions:
  - [x] **Selected: LibreTranslate** (free API, no authentication needed)
  - ℹ️ Notes: Apple Translate Framework requires macOS 15.0+, not feasible for v12
- [x] Implement translation method
  - [x] TranslationService created with LibreTranslate API integration
  - [x] POST request to https://libretranslate.de/translate
  - [x] Error handling with fallback to original text
- [x] Add EN→VI translation after OCR
  - [x] Triggered automatically after OCR extraction
  - [x] Async/await for non-blocking UI
- [ ] Cache translations (performance optimization - Phase 2.5)
- [x] Error handling for translation failures

### Stage 3: Settings/Preferences (Days 5-6)
- [ ] Create preferences window:
  - [ ] Choose default translation language pair
  - [ ] Hotkey customization
  - [ ] Auto-copy behavior toggle
  - [ ] Theme (light/dark mode)
- [ ] Persist settings to UserDefaults
- [ ] System preferences shortcut

### Stage 4: Menu Bar Integration (Days 6-7)
- [ ] Replace dock icon with status bar icon
- [ ] Menu bar app behavior:
  - [ ] Always accessible from menu bar
  - [ ] Quick settings access
  - [ ] Window state management
- [ ] **Xcode Test:** Full Phase 2 flow end-to-end

**Total Estimate:** 5-7 days for one dev

---

## 🔌 7. Phase 1 Offline Feasibility

| Component | Offline? | Notes |
|-----------|----------|-------|
| Hotkey Listener | ✅ | Local OS event |
| Screen Capture | ✅ | Local screen buffer |
| OCR (Vision) | ✅ | Built-in, no network |
| UI Overlay | ✅ | Local drawing |
| **Phase 1 Total** | ✅ **100% OFFLINE** | Zero internet required |

**Phase 2 (Translation) will require optional internet**
- Option A: Apple Translate Framework (offline if language pack installed)
- Option B: API-based (Google/OpenAI) - requires internet

---

## 🏪 8. App Store Readiness (Phase 1)

### ✅ Approved Features
- [x] Global hotkey (with Accessibility permission)
- [x] Screen capture (offline, no data transmission)
- [x] OCR processing (offline)
- [x] UI overlay (native)

### ⚠️ Required for Submission

1. **Privacy Policy**
   - State: "No data is transmitted. OCR happens on-device only."
   - No analytics
   - No logging of captured images

2. **Info.plist Entries**
   ```xml
   <key>NSHumanReadableCopyright</key>
   <string>© 2025 Your Name</string>
   
   <key>NSAccessibilityUsageDescription</key>
   <string>SnapTranslate needs accessibility permission to listen for the global shortcut (Cmd+Shift+S).</string>
   ```

3. **Code Signing**
   - Sign with Apple Developer certificate
   - Notarization required (automatic if using Xcode)

---

## 📦 9. Dependencies (SPM)

```swift
// Package.swift
.package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0")
// (only if needed for debugging)

// Most features use Apple frameworks:
// - Vision
// - AppKit
// - Combine
// - SwiftUI
```

**Goal:** Zero external dependencies for Phase 1 MVP

---

## 🚀 10. Conclusion

### Feasibility: ✅ 100% VIABLE

**Why Phase 1 is doable:**
- All tech is proven & stable
- Zero external dependencies
- Offline-first = simple logic
- Native APIs only
- Xcode has built-in tools for each component

**Why this matters:**
- Fast to build (~5-8 days)
- Easy to maintain
- App Store friendly
- No vendor lock-in
- Can iterate weekly with TestFlight

**Next Step:** Start Stage 1 (Project Setup)

---

## 💡 Tech Stack Summary

| Tier | Technology | Reason |
|------|-----------|--------|
| **Language** | Swift | Native, modern, App Store |
| **UI** | SwiftUI | Fast development, native feel |
| **Hotkey** | NSEvent API | No dependencies, reliable |
| **Capture** | CoreGraphics | Simple, instant, no entitlements |
| **OCR** | Vision Framework | Offline, accurate, EN+VI support |
| **Translation** | LibreTranslate API | Free, no auth, EN→VI support |
| **Distribution** | Mac App Store | Maximum reach + notarization |

---

## 📐 Phase 2: New UI Layout

### Home Screen (ContentView)
```
┌────────────────────────────────┐
│                                │
│    📸 [Icon]                   │
│    SnapTranslate               │
│    Instant OCR & Translation   │
│                                │
│  [Capture & Translate]         │
│  [Open Settings]               │
│                                │
│  Press Cmd+Ctrl+C to capture  │
│  Phase 2: UI + Translation     │
│                                │
└────────────────────────────────┘
```

### Result Popover (ResultPopoverView) - Phase 2 Redesign
```
┌──────────────────────────────────────────┐
│  OCR & Translation    [Progress] [X]     │
├──────────────────────────────────────────┤
│  Screenshot                              │
│  ┌────────────────────────────────────┐ │
│  │    [Image Preview - 280px height]  │ │
│  │    (Full width, responsive)        │ │
│  └────────────────────────────────────┘ │
├──────────────────────────────────────────┤
│  English              │    Vietnamese     │
│  ┌──────────────┐    │    ┌──────────┐  │
│  │ EN text      │[⟳] │[⟳] │ VI text  │  │
│  │ here...      │    │    │ here...  │  │
│  │              │    │    │          │  │
│  └──────────────┘    │    └──────────┘  │
│                                          │
│  [Copy EN] [Copy VI] [Close]             │
└──────────────────────────────────────────┘

Size: 900x650
Top image: Responsive (280px default)
Bottom split: 50/50 EN-VI
```

### Key Phase 2 Features Implemented
- ✅ Simplified home screen (2 buttons only)
- ✅ Bilingual layout (EN left, VI right)
- ✅ Image on top section
- ✅ Automatic translation via LibreTranslate
- ✅ Copy buttons for both languages
- ✅ Loading indicators for OCR & translation

---

## 🌐 Phase 2: Translation Solutions Comparison

### Recommended: **MyMemory API** (FREE, No Key) ✅
```swift
// MyMemory API - Simple GET request
let url = "https://api.mymemory.translated.net/get?q=\(text)&langpair=en|vi"
let response = try await URLSession.shared.data(from: url)
// Parse: response["responseData"]["translatedText"]
```

**Pros:**
- ✅ Completely FREE
- ✅ No API key required
- ✅ No authentication needed
- ✅ Simple GET request
- ✅ Works globally

**Cons:**
- ⚠️ Requires internet connection
- ⚠️ Rate limiting (but generous for typical use)

**Status:** ✅ **SELECTED FOR PHASE 2** (Currently Using)

---

### Alternative 1: **Google Translate API** (Online)
```swift
// Requires API key setup
// https://cloud.google.com/translate/docs/setup

let request = URLRequest(url: URL(string: "https://translation.googleapis.com/language/translate/v2?key=YOUR_KEY&source=en&target=vi&q=\(text)")!)
```

**Pros:**
- ✅ Higher accuracy
- ✅ More language support
- ✅ No offline dependency

**Cons:**
- ❌ Requires internet
- ❌ Costs money (pay-per-request)
- ❌ Privacy concerns (sends text to Google)
- ❌ Slower (network latency)

---

### Alternative 2: **LibreTranslate** (Self-hosted or API)
```
API: https://libretranslate.de/translate
Free tier available, no API key needed
Open-source, can self-host
```

**Pros:**
- ✅ Free tier available
- ✅ Open-source
- ✅ Privacy option (self-hosted)

**Cons:**
- ⚠️ Slower than Google
- ⚠️ Free tier rate-limited
- ❌ Requires internet

---

### **Phase 2 Selection (FINAL):**
1. **SELECTED: MyMemory API** ✅
   - Free, no key required
   - Works with macOS 12+
   - Reliable, proven service
2. **Backup option:** Google Translate (if premium tier added)
3. **Offline option:** Apple Translate (requires macOS 15.0+)

---
