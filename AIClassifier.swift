import Foundation
import CoreData

class AIClassifier {
    static func classifyText(_ text: String, context: NSManagedObjectContext, completion: @escaping (String) -> Void) {
        guard let url = URL(string: "https://screenshot-gamma-seven.vercel.app/api/classify") else {
            completion(keywordFallback(for: text, context: context))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["text": text]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                print("❌ classify error:", error.localizedDescription)
                completion(keywordFallback(for: text, context: context))
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let category = json["category"] as? String else {
                print("⚠️ classify: invalid JSON response")
                completion(keywordFallback(for: text, context: context))
                return
            }

            // ✅ Validate against Core Data categories
            let validCategories = fetchCategoryNames(context: context)
            if validCategories.contains(where: { $0.caseInsensitiveCompare(category) == .orderedSame }) {
                print("🤖 GPT classified as:", category)
                completion(category)
            } else {
                print("⚠️ GPT returned invalid category:", category, "→ falling back")
                completion(keywordFallback(for: text, context: context))
            }
        }.resume()
    }

    // MARK: - Keyword Fallback
    private static func keywordFallback(for text: String, context: NSManagedObjectContext) -> String {
        let lower = text.lowercased()
            .replacingOccurrences(of: "#", with: " ")
            .replacingOccurrences(of: "[^a-z0-9 ]", with: " ", options: .regularExpression)

        // Food
        if lower.contains("recipe") || lower.contains("cook") || lower.contains("ingredient") ||
           lower.contains("food") || lower.contains("meal") || lower.contains("kitchen") ||
           lower.contains("taco") || lower.contains("pie") || lower.contains("chef") {
            print("🔁 Fallback → Food")
            return bestMatch("Food", context: context)
        }

        // Fashion
        if lower.contains("fashion") || lower.contains("clothes") || lower.contains("style") ||
           lower.contains("outfit") || lower.contains("wardrobe") {
            print("🔁 Fallback → Fashion")
            return bestMatch("Fashion", context: context)
        }

        // Home
        if lower.contains("home") || lower.contains("decor") || lower.contains("house") ||
           lower.contains("interior") || lower.contains("kitchen design") {
            print("🔁 Fallback → Home")
            return bestMatch("Home", context: context)
        }

        // Beauty
        if lower.contains("beauty") || lower.contains("makeup") || lower.contains("skincare") ||
           lower.contains("cosmetic") || lower.contains("hair") {
            print("🔁 Fallback → Beauty")
            return bestMatch("Beauty", context: context)
        }

        // Fitness
        if lower.contains("fitness") || lower.contains("workout") || lower.contains("exercise") ||
           lower.contains("gym") || lower.contains("yoga") {
            print("🔁 Fallback → Fitness")
            return bestMatch("Fitness", context: context)
        }

        // Education
        if lower.contains("education") || lower.contains("school") || lower.contains("learning") ||
           lower.contains("class") || lower.contains("study") {
            print("🔁 Fallback → Education")
            return bestMatch("Education", context: context)
        }

        // Quotes
        if lower.contains("quote") || lower.contains("lyrics") || lower.contains("inspiration") ||
           lower.contains("motivation") {
            print("🔁 Fallback → Quotes")
            return bestMatch("Quotes", context: context)
        }

        // Music
        if lower.contains("song") || lower.contains("album") || lower.contains("track") ||
           lower.contains("music") || lower.contains("artist") || lower.contains("band") {
            print("🔁 Fallback → Music")
            return bestMatch("Music", context: context)
        }

        // Entertainment (also captures sports terms)
        if lower.contains("movie") || lower.contains("film") || lower.contains("show") ||
           lower.contains("tv") || lower.contains("entertainment") ||
           lower.contains("sports") || lower.contains("game") ||
           lower.contains("team") || lower.contains("match") || lower.contains("player") {
            print("🔁 Fallback → Entertainment")
            return bestMatch("Entertainment", context: context)
        }

        // Art
        if lower.contains("art") || lower.contains("painting") || lower.contains("drawing") ||
           lower.contains("sketch") || lower.contains("gallery") {
            print("🔁 Fallback → Art")
            return bestMatch("Art", context: context)
        }

        // Travel
        if lower.contains("travel") || lower.contains("flight") || lower.contains("vacation") ||
           lower.contains("trip") || lower.contains("hotel") || lower.contains("journey") {
            print("🔁 Fallback → Travel")
            return bestMatch("Travel", context: context)
        }

        // Default → Other
        print("🔁 Fallback → Other")
        return bestMatch("Other", context: context)
    }

    // MARK: - Helpers
    private static func fetchCategoryNames(context: NSManagedObjectContext) -> [String] {
        let request: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        if let categories = try? context.fetch(request) {
            return categories.compactMap { $0.name }
        }
        return []
    }

    private static func bestMatch(_ fallback: String, context: NSManagedObjectContext) -> String {
        let validCategories = fetchCategoryNames(context: context)
        if validCategories.contains(where: { $0.caseInsensitiveCompare(fallback) == .orderedSame }) {
            return fallback
        }
        return validCategories.first ?? "Other"
    }
}

