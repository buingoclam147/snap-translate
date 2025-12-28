# SnapTranslate - Tính Năng Ứng Dụng

## 📋 Tổng Quan
TSnap là ứng dụng macOS cho phép dịch nhanh các đoạn văn bản từ hình ảnh chụp được. Ứng dụng hoạt động hoàn toàn ngoài nền (background) và không yêu cầu hỗ trợ online liên tục.

---

## 🎯 Tính Năng Chính

### 1. **Chụp Màn Hình OCR và dịch (Screen Capture)**
- Hotkey toàn cục: **Cmd + Shift + C** (có thể tùy chỉnh)
- Kéo chuột để chọn vùng cần chụp trên bất kỳ ứng dụng nào
- Hỗ trợ đa ngôn ngữ, Trích xuất text từ hình ảnh chụp được
- Hiển thị confidence score (% độ tin cậy) cho mỗi block text
- Sử dụng CGDisplayCreateImage để chụp layer thực tế (bypass window layers)
- ESC để hủy chụp bất cứ lúc nào

### 2. **Dịch Thuật (Translation)**
- sử dụng hotkey **Cmd + Shift + X để mở popover dịch hoặc click icon app trên menu bar
- nhập nội dung đa ngông ngữ và có thể switch ngôn ngữ cũng như nội dung
- đọc văn bản
- copy và dán văn bản

- **3 provider dịch thuật với fallback tự động:**

  **a) MyMemory Translation**
  - Ổn định nhất, miễn phí
  - Giới hạn: 500 ký tự/request
  - Tự động chia nhỏ text (auto-chunking)
  - Hỗ trợ URL encoding

  **b) LibreTranslate**
  - Máy chủ mã nguồn mở
  - Giới hạn: 50,000 ký tự
  - Multipart form-data requests

  **c) Google Translate**
  - Endpoint không chính thức (reverse-engineered)
  - Miễn phí
  - Giới hạn: 5,000 ký tự
  - **Smart routing:** Ưu tiên khi text ≤100 ký tự

  **d) DeepL (DeepLX)**
  - Yêu cầu API key
  - Chất lượng cao nhất
  - Giới hạn: 50,000 ký tự

- **Smart Language Selection:**
  - Văn bản ngắn (≤100 ký tự) → Google Translate
  - Văn bản dài (>100 ký tự) → MyMemory
  - Fallback tự động nếu provider chính fail

- **Retry Mechanism:** 3 lần thử tự động nếu dịch fail
- **Provider Priority Order:**
  1. Provider được chọn thủ công (nếu có)
  2. Provider smart-selected (dựa vào độ dài text)
  3. Các provider khác để fallback

### 4. **Đọc Văn Bản (Text-to-Speech)**
- Sử dụng AVSpeechSynthesizer (macOS native)
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
- Điều chỉnh tốc độ (rate)
- Dừng/Tạm dừng/Tiếp tục phát âm

### 5. **Hotkey & Keyboard Controls**
- **Global Hotkey:** Cmd + Shift + C (tùy chỉnh được, không cần permission)
- **ESC Key:** 
  - Hủy chụp trong chế độ kéo chọn
  - Đóng popover dịch
  - Dừng OCR đang xử lý
- Carbon API (macOS native) - không cần quyền hệ thống

### 6. **Giao Diện (UI/UX)**

**a) Status Bar Menu**
- Icon ứng dụng trong menu bar (top-right)
- Menu dropdown với các tùy chọn
- Popover dịch nhanh
- Settings/Preferences

**b) Translator Popover**
- Nhập/chỉnh sửa văn bản nguồn
- Chọn ngôn ngữ nguồn & đích
- Nút trao đổi ngôn ngữ (swap)
- Đọc text bằng TTS
- Copy to clipboard
- Real-time translation (debounce 2 giây khi gõ)
- Real-time language change debounce (0.3 giây)

**c) Result Window** (Legacy OCR Mode)
- Hiển thị hình ảnh chụp được
- Extracted text (English)
- Editable text field
- Translated text
- Copy button
- Thay đổi ngôn ngữ dịch trực tiếp

### 7. **Lưu Trữ & Tùy Chỉnh**
- UserDefaults:
  - Ngôn ngữ dịch được chọn
  - Hotkey tùy chỉnh
  - Ngôn ngữ nguồn & đích (translator)
- Lưu preferences tự động

### 8. **Quyền Hệ Thống**
- **Cần:** Screen Recording Permission (cho capture)
  - Yêu cầu tự động lần đầu
  - Hỗ trợ macOS 13+ (modern API)
  - Fallback cho macOS < 13 (legacy API)
  - Polling mechanism với timeout 3 phút
  
- **Không cần:** Accessibility Permission (sử dụng Carbon API cho hotkey)

### 9. **Logging & Debugging**
- LogService: In log chi tiết cho mỗi thao tác
  - Debug logs: Thông tin chi tiết
  - Info logs: Thông tin quan trọng
  - Error logs: Các lỗi xảy ra
- Console output cho monitoring
- Timestamps trong log

### 10. **Performance & Optimization**
- Async/await cho tất cả API calls
- GCD (Grand Central Dispatch) cho background tasks
- Debounce timers để tránh API spam
- Efficient image processing (Retina display aware)
- Memory management với weak references
- Cancel support cho OCR & capture

### 11. **Error Handling**
- Network error handling
- Rate limit detection (429 HTTP)
- Invalid API key detection (403 HTTP)
- Service unavailable handling (503 HTTP)
- Fallback providers nếu fail
- User-friendly error messages (Tiếng Việt + Tiếng Anh)

### 12. **Multi-Language Support**
- UI hiển thị bằng ngôn ngữ hệ thống
- Supported translation languages: 15+
- Error messages: Tiếng Anh & Tiếng Việt

---

## 🏗️ Kiến Trúc Ứng Dụng

### Services (Backend Logic)
- **TranslationService**: Quản lý dịch thuật với retry logic
- **OCRService**: Nhận dạng chữ từ hình ảnh
- **CaptureService**: Chụp vùng màn hình
- **SpeechService**: Text-to-speech
- **HotKeyService**: Global hotkey listener
- **EscapeKeyService**: ESC key handler
- **StatusBarManager**: Menu bar UI
- **TranslationProviders**: 4 engine dịch tích hợp
- **LogService**: Logging system
- **HotKeyManager**: Hotkey storage & parsing

### ViewModels (State Management)
- **CaptureViewModel**: Trạng thái capture & OCR
- **ResultViewModel**: Kết quả OCR & translation
- **TranslatorViewModel**: Translator popover state
- **HotKeyViewModel**: Hotkey settings state

### Views (UI Components)
- **TranslatorPopoverView**: Popover dịch nhanh
- **ResultPopoverView**: Popover kết quả
- **ResultWindow**: Window kết quả (legacy)
- **HotKeySettingsView**: Settings hotkey
- **LogView**: Debug log viewer
- **CaptureOverlayViewController**: Overlay chụp

---

## 📱 User Workflows

### Workflow 1: Quick Translation (Hotkey Mode)
1. Nhấn Cmd + Shift + C
2. Kéo chọn vùng cần chụp
3. Ứng dụng tự động OCR & dịch
4. Xem kết quả trong popover

### Workflow 2: Manual Text Input
1. Mở translator popover
2. Gõ hoặc paste text
3. Chọn ngôn ngữ
4. Xem kết quả dịch real-time

### Workflow 3: Text-to-Speech
1. Có text đã dịch
2. Click nút "Speak"
3. Nghe phát âm

---

## 🔧 Technical Stack
- **Language**: Swift 5.9+
- **Framework**: SwiftUI, AppKit
- **macOS Support**: 12.0+
- **OCR**: Vision Framework
- **TTS**: AVFoundation
- **Networking**: URLSession
- **Storage**: UserDefaults
- **Hotkey**: Carbon API
- **Screen Capture**: CoreGraphics

---

## 📊 Supported Languages (Translation)
- Vietnamese (vi)
- English (en)
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
- Menu bar integration
- Popover for quick access
- Dark mode support (system theme)
- Keyboard shortcuts
- Real-time translation feedback
- Loading indicators
- Error notifications
- Copyable results
- Language swap button
- Voice playback controls

---

## ⚙️ Configuration
- Hotkey: Customizable (Cmd+Shift+C default)
- Language preferences: Saved automatically
- Retry attempts: 3
- Debounce delay (typing): 2 seconds
- Debounce delay (language change): 0.3 seconds
- OCR languages: English + Vietnamese
- Default translation language: Vietnamese

---

## 🚀 Key Innovations
1. **Smart Provider Routing**: Chọn provider tối ưu dựa vào độ dài text
2. **Automatic Fallback**: Tự động chuyển provider nếu fail
3. **Zero-Permission Hotkey**: Dùng Carbon API, không cần Accessibility
4. **Debounce Strategy**: Tránh spam API với debouncing thông minh
5. **Retry Mechanism**: 3 lần thử tự động khi fail
6. **URL Encoding Handling**: Xử lý encoding đặc biệt cho MyMemory
7. **Multi-Chunk Support**: Tự động chia text lớn thành chunks

---

## 📝 Notes
- Ứng dụng không lưu trữ API keys cơ bản (except DeepL)
- Tất cả API calls là public endpoints
- Không có backend server, hoàn toàn client-side
- Privacy-friendly: Không theo dõi user
