import Foundation
import Vision
import UIKit

/// Result of OCR + categorization
struct OCRResult {
    let text: String
    let category: String
}

class OCRCategorizer {

    /// Runs OCR on a UIImage and returns recognized text + category
    static func process(image: UIImage, completion: @escaping (OCRResult?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }

        let request = VNRecognizeTextRequest { request, error in
            guard error == nil else {
                print("OCR failed: \(error!.localizedDescription)")
                completion(nil)
                return
            }

            let observations = request.results as? [VNRecognizedTextObservation] ?? []
            let rawText = observations
                .compactMap { $0.topCandidates(1).first?.string }
                .joined(separator: " ")

            // ✅ Clean out jibberish
            let recognizedText = cleanOCRText(rawText)

            // Use simple fallback categorizer
            let category = categorize(text: recognizedText)
            let result = OCRResult(text: recognizedText, category: category)
            completion(result)
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try requestHandler.perform([request])
        } catch {
            print("Error performing OCR: \(error)")
            completion(nil)
        }
    }

    // MARK: - Text Cleaning
    private static func cleanOCRText(_ text: String) -> String {
        // 1. Strip non-alphanumeric (except punctuation & space)
        let pattern = "[^a-zA-Z0-9\\s.,!?-]"
        let cleaned = text.replacingOccurrences(of: pattern, with: " ", options: .regularExpression)

        // 2. Collapse multiple spaces
        return cleaned.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
                      .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Simple Fallback Categorizer
    static func simpleCategorize(_ text: String) -> String {
        return categorize(text: text)
    }

    private static func categorize(text: String) -> String {
        let lower = text.lowercased()
        if lower.contains("recipe") || lower.contains("tsp") || lower.contains("cup") {
            return "Recipes"
        } else if lower.contains("meme") || lower.contains("😂") || lower.contains("lol") {
            return "Memes"
        } else if lower.contains("meeting") || lower.contains("project") || lower.contains("work") {
            return "Work"
        } else if lower.contains("http") || lower.contains("article") || lower.contains("news") {
            return "Articles"
        } else {
            return "Other"
        }
    }
}

