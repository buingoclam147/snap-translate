# Minimize Button Feature

## Description
Thêm 1 icon **Minimize** ở cuối cùng bên phải header của popover translator. Khi người dùng ấn button này, popover sẽ tắt đi ngay lập tức.

## Changes

### File Modified
`Sources/SnapTranslate/Views/TranslatorPopoverView.swift`

### What's Added
- Thêm button **Minimize** trong header HStack
- Icon: `minus.circle` (hình tròn có dấu trừ)
- Khi ấn button → gọi `onClose?()` để đóng popover
- Log để tracking khi button được ấn

### Button Location
```
[Translate] [OCR] [?] [Settings] [Minimize] ← vị trí ngoài cùng bên phải
```

### Code
```swift
// Minimize Button
Button(action: {
    print("\n" + String(repeating: "📦", count: 40))
    print("📦📦📦 MINIMIZE BUTTON TAPPED - CLOSING Popover 📦📦📦")
    print(String(repeating: "📦", count: 40) + "\n")
    onClose?()
}) {
    Image(systemName: "minus.circle")
        .font(.system(size: 14, weight: .semibold))
        .foregroundColor(.gray)
}
.buttonStyle(.plain)
.help("Minimize")
```

## How to Use
1. Ấn hotkey (Cmd+Ctrl+C) để mở popover
2. Ấn icon **Minimize** ở góc phải trên cùng
3. Popover sẽ tắt ngay lập tức

## Logging
Khi button được ấn:
```
📦📦📦 MINIMIZE BUTTON TAPPED - CLOSING Popover 📦📦📦
```

## Testing
Chạy `./run-debug.sh` để test feature này.
