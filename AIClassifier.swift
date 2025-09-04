import Foundation

class AIClassifier {
    static func classifyText(_ text: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: "https://your-vercel-app-url.vercel.app/api/classify") else {
            completion("Other")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["text": text]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ classify error:", error.localizedDescription)
                completion("Other")
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let category = json["category"] as? String else {
                completion("Other")
                return
            }

            // ✅ Validation step
            if CATEGORY_LIST.contains(category) {
                completion(category)
            } else {
                print("⚠️ Invalid category from API:", category)
                completion("Other")
            }
        }.resume()
    }
}
