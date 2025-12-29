# SnapTranslate (TSnap) - Tính Năng Ứng Dụng

## 📋 Tổng Quan
**TSnap** là ứng dụng macOS cho phép dịch nhanh các đoạn văn bản từ hình ảnh chụp được hoặc text được chọn trên màn hình. Ứng dụng hoạt động hoàn toàn ngoài nền (background), không cần kết nối internet liên tục và xử lý ngôn ngữ một cách thông minh.

---

## 🎯 Tính Năng Chính

### 1. **Chụp Màn Hình + OCR (Screen Capture)**
- **Hotkey:** `Cmd + Ctrl + C` (có thể tùy chỉnh)
- Kéo chuột để chọn vùng cần chụp trên bất kỳ ứng dụng nào
- Hỗ trợ đa ngôn ngữ (English + Vietnamese)
- Trích xuất text từ hình ảnh chụp được
- Sử dụng **CGDisplayCreateImage** (bypass window layers) - capture chính xác những gì hiển thị
- **ESC để hủy** chụp bất cứ lúc nào
- Hiển thị confidence score (%) cho mỗi block text OCR

### 2. **Dịch Thuật Real-Time (Translation)**
- **Mở Translator Popover:** 
  - Cmd + Shift + X (dịch text được chọn)
  - Click icon app trên menu bar
- Nhập nội dung đa ngôn ngữ
- Switch ngôn ngữ nguồn/đích
- Copy & dán text
- **Real-time translation:** Debounce 2 giây khi gõ

**4 Translation Providers với Auto-Fallback:**

| Provider | Giới hạn | Đặc điểm |
|----------|---------|---------|
| **MyMemory** | 500 ký tự/request | Ổn định nhất, miễn phí, tự động chia nhỏ text |
| **LibreTranslate** | 50,000 ký tự | Mã nguồn mở, multipart form-data |
| **Google Translate** | 5,000 ký tự | Reverse-engineered, nhanh cho text ngắn (≤100 ký tự) |
| **DeepL** | 50,000 ký tự | Chất lượng cao nhất, cần API key |

**Smart Provider Routing:**
- Text ≤ 100 ký tự → Google Translate
- Text > 100 ký tự → MyMemory
- Fallback tự động khi provider fail

**Retry Mechanism:** 3 lần thử tự động nếu dịch fail

### 3. **Đọc Văn Bản (Text-to-Speech)**
- Sử dụng **AVSpeechSynthesizer** (macOS native)
- Hỗ trợ 15+ ngôn ngữ:
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
- Điều chỉnh tốc độ phát âm (rate: 0.0 ~ 1.0)
- Dừng/Tạm dừng/Tiếp tục phát âm

### 4. **Hotkey & Keyboard Controls**
- **Global Hotkey OCR:** Cmd + Ctrl + C (tùy chỉnh được)
- **Translate Hotkey:** Cmd + Shift + X (dịch text được chọn)
- **ESC Key:**
  - Hủy chụp trong chế độ kéo chọn
  - Đóng popover dịch
- **Carbon API** cho OCR hotkey (no permissions needed)
- **Global Event Monitor** cho translate hotkey (no permissions needed)

### 5. **Giao Diện (UI/UX)**

**a) Status Bar Menu**
- Icon ứng dụng trong menu bar (top-right)
- Click để mở Translator Popover
- Support & Help menu
- Quit app

**b) Translator Popover**
- Input field: nhập/chỉnh sửa text
- Language selector: chọn ngôn ngữ nguồn & đích
- Swap button: trao đổi ngôn ngữ + text
- Speak button: đọc text bằng TTS
- Copy buttons: copy source/translated text
- Paste button: dán từ clipboard
- Clear button: xóa source text
- OCR button: chụp hình từ popover
- Real-time translation (debounce 2s)
- Real-time language change (debounce 0.3s)

**c) Capture Overlay**
- Full-screen overlay khi drag mode
- Drag để chọn vùng cần chụp
- ESC để hủy
- Không che phủ UI (borderless, transparent)

### 6. **Lưu Trữ & Tùy Chỉnh**
- **UserDefaults** lưu trữ:
  - Source/Target language (translator)
  - Hotkey tùy chỉnh (OCR hotkey)
- Lưu preferences **tự động**
- Không lưu API keys (except DeepL - optional)

### 7. **Quyền Hệ Thống**
- **Cần:** Screen Recording Permission
  - Yêu cầu tự động lần đầu
  - macOS 13+ sử dụng ScreenCaptureKit
  - macOS < 13 fallback CGDisplayCreateImage
  - Polling mechanism với timeout 3 phút
- **Không cần:** 
  - Accessibility Permission (sử dụng Carbon API + Global Event Monitor)
  - Internet permission (public endpoints)

### 8. **Logging & Debugging**
- **LogService:** In log chi tiết cho mỗi thao tác
  - Debug logs: thông tin chi tiết
  - Info logs: thông tin quan trọng
  - Error logs: các lỗi xảy ra
- Console output cho monitoring
- Timestamps trong log

### 9. **Performance & Optimization**
- **Async/await** cho tất cả API calls
- **GCD** (Grand Central Dispatch) cho background tasks
- **Debounce timers** để tránh API spam (2s translation, 0.3s language change)
- **Efficient image processing** (Retina display aware)
- Memory management với weak references
- Cancel support cho OCR & capture

### 10. **Error Handling**
- Network error handling
- Rate limit detection (429 HTTP)
- Invalid API key detection (403 HTTP)
- Service unavailable handling (503 HTTP)
- Fallback providers nếu fail
- User-friendly error messages (Tiếng Việt + Tiếng Anh)

### 11. **Multi-Language Support**
- UI display: theo ngôn ngữ hệ thống
- Supported translation languages: 15+
- Error messages: Tiếng Anh & Tiếng Việt
- OCR supports: English + Vietnamese

---

## 🏗️ Kiến Trúc Ứng Dụng

### Services (Backend Logic)
- **TranslationService**: Quản lý dịch thuật với retry logic
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
- **TranslatorPopoverView**: Popover dịch nhanh (primary UI)
- **ResultPopoverView**: Popover kết quả (alternative)
- **ResultWindow**: Window kết quả (legacy mode)
- **HotKeySettingsView**: Settings hotkey
- **LogView**: Debug log viewer
- **CaptureOverlayViewController**: Overlay chụp (SimpleOverlayView)

---

## 📱 User Workflows

### Workflow 1: Quick Screen Capture OCR
1. Nhấn **Cmd + Ctrl + C**
2. Kéo chọn vùng cần chụp
3. Ứng dụng tự động OCR
4. Xem kết quả trong translator popover
5. Tự động dịch sang ngôn ngữ đã chọn

### Workflow 2: Translate Selected Text
1. Chọn text trên màn hình (bất kỳ ứng dụng nào)
2. Nhấn **Cmd + Shift + X**
3. Ứng dụng lấy text từ clipboard (via Cmd+C)
4. Xem kết quả dịch trong translator popover

### Workflow 3: Manual Text Input
1. Click icon app trên menu bar
2. Mở translator popover
3. Gõ hoặc paste text
4. Chọn ngôn ngữ
5. Xem kết quả dịch real-time (debounce 2s)

### Workflow 4: Text-to-Speech
1. Có text đã dịch
2. Click nút "Speak"
3. Nghe phát âm qua speaker
4. Có thể pause/resume/stop

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
| Setting | Value | Mục đích |
|---------|-------|---------|
| OCR Hotkey | Cmd + Ctrl + C | Chụp hình + OCR |
| Translate Hotkey | Cmd + Shift + X | Dịch text được chọn |
| Translation Debounce | 2 seconds | Tránh spam API khi gõ |
| Language Change Debounce | 0.3 seconds | Debounce khi swap language |
| Retry Attempts | 3 | Số lần thử lại khi fail |
| OCR Languages | English + Vietnamese | Ngôn ngữ nhận dạng |
| Default Target Language | Vietnamese | Ngôn ngữ dịch mặc định |
| Default Source Language | English | Ngôn ngữ nguồn mặc định |
| Permission Polling | 3 minutes max | Timeout kiểm tra permission |

---

## 🚀 Key Innovations
1. **Smart Provider Routing** - chọn provider tối ưu dựa vào độ dài text
2. **Automatic Fallback** - tự động chuyển provider nếu fail
3. **Zero-Permission Hotkey** - dùng Carbon API, không cần Accessibility
4. **Global Event Monitoring** - lắng nghe sự kiện từ bất kỳ ứng dụng nào
5. **Smart Debouncing** - debounce khác nhau cho typing (2s) vs language change (0.3s)
6. **Retry Mechanism** - 3 lần thử tự động khi fail
7. **URL Encoding Handling** - xử lý encoding đặc biệt cho MyMemory
8. **Multi-Chunk Support** - tự động chia text lớn thành chunks
9. **Native macOS Integration** - sử dụng AVSpeechSynthesizer, AppKit, Carbon
10. **Efficient OCR** - Vision Framework with confidence scoring

---

## 📝 Important Notes
- Ứng dụng **không lưu trữ API keys** của MyMemory, LibreTranslate, Google (dùng public endpoints)
- DeepL API key (optional) lưu trong UserDefaults - người dùng có thể config
- Tất cả API calls sử dụng **public endpoints** - không có backend server
- Privacy-friendly: **không theo dõi user, không gửi analytics**
- Capture sử dụng CGDisplayCreateImage - capture chính xác những gì thực tế hiển thị
- OCR kết quả phụ thuộc vào chất lượng hình ảnh được chụp

---

## 🔐 Permissions & Security
| Permission | Required | Used For |
|------------|----------|----------|
| Screen Recording | ✅ Yes | Chụp hình bằng CGDisplayCreateImage |
| Accessibility | ❌ No | Carbon API được dùng thay thế |
| Internet | ❌ No | URLSession (system level) |
| Microphone | ❌ No | TTS sử dụng speaker, không record |
| Camera | ❌ No | Dùng screen capture, không camera |

---

## 📈 Performance Metrics
- **OCR Processing:** < 500ms (depends on image size)
- **Translation API Call:** 500ms - 2s (depends on provider & text size)
- **UI Response Time:** < 100ms
- **Memory Usage:** ~50-100MB
- **CPU Usage:** Low (<5%) when idle, peaks during capture/OCR
