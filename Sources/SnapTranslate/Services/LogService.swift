import Foundation

class LogService: ObservableObject {
    static let shared = LogService()
    
    @Published var logs: [LogEntry] = []
    
    struct LogEntry {
        let timestamp: Date
        let message: String
        let level: String
    }
    
    func log(_ message: String, level: String = "INFO") {
        let entry = LogEntry(timestamp: Date(), message: message, level: level)
        DispatchQueue.main.async {
            self.logs.append(entry)
            print("[\(level)] \(message)")
            // Keep only last 100 logs
            if self.logs.count > 100 {
                self.logs.removeFirst()
            }
        }
    }
    
    func debug(_ message: String) {
        log(message, level: "DEBUG")
    }
    
    func info(_ message: String) {
        log(message, level: "INFO")
    }
    
    func error(_ message: String) {
        log(message, level: "ERROR")
    }
    
    func clear() {
        DispatchQueue.main.async {
            self.logs.removeAll()
        }
    }
}
