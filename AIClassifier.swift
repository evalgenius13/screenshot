import Foundation

struct AIClassifier {
    static func classifyText(_ text: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: "https://screenshot-gamma-seven.vercel.app/api/classify") else {
            completion("Other")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["text": text]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else {
                completion("Other")
                return
            }
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let category = json["category"] as? String {
                completion(category)
            } else {
                completion("Other")
            }
        }.resume()
    }
}

