import SwiftUI

struct LogView: View {
    @ObservedObject var logService = LogService.shared
    @State private var autoScroll = true
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Logs")
                    .font(.headline)
                Spacer()
                Toggle("Auto scroll", isOn: $autoScroll)
                    .toggleStyle(.checkbox)
                Button("Clear") {
                    logService.clear()
                }
                .padding(.horizontal, 8)
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)
            
            ScrollViewReader { proxy in
                List(logService.logs, id: \.timestamp) { entry in
                    HStack(alignment: .top, spacing: 8) {
                        Text(entry.level)
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(colorForLevel(entry.level))
                            .frame(width: 50, alignment: .leading)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.message)
                                .font(.system(.caption, design: .monospaced))
                                .lineLimit(nil)
                            
                            Text(formatTime(entry.timestamp))
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundColor(.gray)
                        }
                    }
                    .id(entry.timestamp)
                }
                .onChange(of: logService.logs.count) { _ in
                    if autoScroll, let last = logService.logs.last {
                        proxy.scrollTo(last.timestamp, anchor: .bottom)
                    }
                }
            }
        }
        .background(Color(.controlBackgroundColor))
    }
    
    private func colorForLevel(_ level: String) -> Color {
        switch level {
        case "ERROR":
            return .red
        case "INFO":
            return .blue
        case "DEBUG":
            return .gray
        default:
            return .primary
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: date)
    }
}

#Preview {
    LogView()
        .frame(height: 200)
}
