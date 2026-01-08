import Foundation
#if os(macOS)
import AppKit
import Vision

class OCRService {
    static let shared = OCRService()
    
    private var currentTask: Task<String, Never>?
    var isCancelled = false
    
    /// Extract text from an image using Vision Framework
    /// - Parameter image: NSImage to process
    /// - Returns: Extracted text string
    func extractText(from image: NSImage) -> String {
        isCancelled = false
        guard let cgImage = image.toCGImage() else {
            print("❌ Failed to convert NSImage to CGImage")
            return ""
        }
        
        let request = VNRecognizeTextRequest()
        // Support English, Vietnamese, Chinese (Simplified & Traditional)
        // Language order depends on user preference
        let prioritizeChineseOCR = UserDefaults.standard.bool(forKey: "SnapTranslatePrioritizeChineseOCR")
        if prioritizeChineseOCR {
            request.recognitionLanguages = ["zh-Hans", "zh-Hant", "en", "vi", "zh"]
        } else {
            request.recognitionLanguages = ["en", "vi", "zh-Hans", "zh-Hant", "zh"]
        }
        request.usesLanguageCorrection = true  // Better accuracy
        
        // Set revision for better results
        if #available(macOS 13.0, *) {
            request.revision = VNRecognizeTextRequestRevision2
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
            
            guard let observations = request.results as [VNRecognizedTextObservation]? else {
                print("❌ No text observations found")
                return ""
            }
            
            // Extract text with confidence logging
            var recognizedStrings: [String] = []
            for observation in observations {
                if let topCandidate = observation.topCandidates(1).first {
                    recognizedStrings.append(topCandidate.string)
                    let confidence = Int(observation.confidence * 100)
                    print("   • Confidence: \(confidence)% - \(topCandidate.string.prefix(50))")
                }
            }
            
            let extractedText = recognizedStrings.joined(separator: "\n")
            print("✅ Vision OCR completed: extracted \(recognizedStrings.count) text blocks")
            print("📊 Languages: English, Vietnamese, Chinese (Simplified & Traditional) supported")
            return extractedText
        } catch {
            print("❌ OCR error: \(error.localizedDescription)")
            return ""
        }
    }
    
    func cancelOCR() {
        print("🛑 OCR cancelled by user")
        isCancelled = true
        currentTask?.cancel()
    }
}

// Helper extension to convert NSImage to CGImage
extension NSImage {
    func toCGImage() -> CGImage? {
        var proposedRect = CGRect(origin: .zero, size: self.size)
        return self.cgImage(forProposedRect: &proposedRect, context: nil, hints: nil)
    }
}
#endif
