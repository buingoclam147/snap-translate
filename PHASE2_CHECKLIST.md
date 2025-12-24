# Phase 2: Implementation Checklist

## ✅ Completed (Session 1)

### UI/UX Improvements
- [x] Redesign result window layout
  - [x] Image on top (responsive 280px height)
  - [x] Split bilingual text below (EN left, VI right)
  - [x] Window size: 900x650
- [x] Simplify home screen
  - [x] Only 2 buttons: Capture & Settings
  - [x] Clean title + subtitle
  - [x] Remove all status indicators
- [x] Add copy buttons
  - [x] Copy EN button
  - [x] Copy VI button

### Translation Integration
- [x] Evaluate solutions (decided: LibreTranslate)
- [x] Create TranslationService
  - [x] LibreTranslate API integration
  - [x] POST request handling
  - [x] Error handling + fallback
- [x] Auto-translate after OCR
  - [x] Async/await implementation
  - [x] Loading state (isTranslating)
  - [x] Display translated text

### Code Quality
- [x] Build successful (0 errors, 3 warnings)
- [x] Update documentation (common.md, PHASE2_CHANGES.md)
- [x] No new external dependencies

---

## 📋 Remaining Tasks (Phase 2.3+)

### Stage 3: Settings/Preferences (Phase 2.3)
- [ ] Create PreferencesWindow
- [ ] Settings persistence (UserDefaults)
  - [ ] Default language pair (EN → VI)
  - [ ] Hotkey customization
  - [ ] Auto-copy behavior toggle
  - [ ] Theme selection
- [ ] Preferences UI components
  - [ ] Language pair selector
  - [ ] Hotkey recorder
  - [ ] Toggle switches

### Stage 4: Menu Bar Integration (Phase 2.4)
- [ ] Create status bar icon
- [ ] Menu bar menu with:
  - [ ] Quick Capture option
  - [ ] Open Settings option
  - [ ] Quit option
- [ ] App lifecycle management
  - [ ] Hide dock icon option
  - [ ] Minimize to menu bar
  - [ ] Window state persistence

### Performance & Polish (Phase 2.5)
- [ ] Translation caching
  - [ ] Store recent translations
  - [ ] Avoid redundant API calls
  - [ ] Cache size limit
- [ ] Network timeout handling
  - [ ] Configurable timeout (default 5s)
  - [ ] Retry logic
  - [ ] User feedback on failure
- [ ] UI Polish
  - [ ] Smooth transitions
  - [ ] Better error messages
  - [ ] Loading skeleton placeholders

### Testing (Phase 2.6)
- [ ] Unit tests
  - [ ] TranslationService tests
  - [ ] ViewModel logic tests
- [ ] Integration tests
  - [ ] Capture → OCR → Translation flow
  - [ ] Network error handling
- [ ] Manual QA
  - [ ] Cross-browser capture
  - [ ] Different text lengths
  - [ ] Network edge cases

---

## 📊 Progress Summary

```
Phase 2 Total: 38 tasks
Completed:     18 tasks (47%)
Remaining:     20 tasks (53%)

Stage 1 (UI/UX):       100% ✅
Stage 2 (Translation): 100% ✅  
Stage 3 (Settings):      0% 📋
Stage 4 (Menu Bar):      0% 📋
Stage 5 (Polish):        0% 📋
Stage 6 (Testing):       0% 📋
```

---

## 🎯 Next Session Priority

1. **High Priority:**
   - [ ] Menu bar integration (most visible feature)
   - [ ] Settings window (user expectations)

2. **Medium Priority:**
   - [ ] Translation caching (performance)
   - [ ] Network timeout (reliability)

3. **Low Priority:**
   - [ ] Unit tests (coverage)
   - [ ] UI polish (refinements)

---

## 📝 Build Commands (Quick Reference)

```bash
# Build only
swift build

# Build + Run
./run-app.sh

# Clean build
rm -rf .build && swift build

# Check diagnostics
swift build --diagnostic-style=pretty
```

---

## 🔗 Related Files

- `common.md` - Overall project specs + Phase 2 details
- `PHASE2_CHANGES.md` - Implementation details (what was done)
- `Sources/SnapTranslate/Services/TranslationService.swift` - Translation logic
- `Sources/SnapTranslate/Views/ResultPopoverView.swift` - New result UI
- `Sources/SnapTranslate/Views/ContentView.swift` - Simplified home screen
- `Sources/SnapTranslate/ViewModels/ResultViewModel.swift` - Enhanced with translation

