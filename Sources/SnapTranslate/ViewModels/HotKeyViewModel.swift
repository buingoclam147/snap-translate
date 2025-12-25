import Foundation
import Combine

class HotKeyViewModel: ObservableObject {
    static let shared = HotKeyViewModel()
    
    @Published var currentHotKey: String = "Cmd+Shift+C"
    
    private var cancellable: AnyCancellable?
    
    init() {
        loadCurrentHotKey()
        
        // Listen for hotkey changes from settings
        cancellable = NotificationCenter.default.publisher(
            for: NSNotification.Name("HotKeyChanged")
        )
        .sink { notification in
            if let hotKey = notification.object as? String {
                self.currentHotKey = hotKey
                print("✅ HotKey updated to: \(hotKey)")
            }
        }
    }
    
    func loadCurrentHotKey() {
        currentHotKey = HotKeyManager.shared.getSavedHotKey()
    }
    
    deinit {
        cancellable?.cancel()
    }
}
