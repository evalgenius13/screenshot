import Foundation

struct Category: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
}

class CategoryStore: ObservableObject {
    @Published var categories: [Category] = []
    @Published var assignments: [String: UUID] = [:] // screenshot id -> category id

    private let categoriesKey = "categories_list"
    private let assignmentsKey = "category_assignments"

    init() {
        loadCategories()
        loadAssignments()
    }

    func addCategory(name: String) {
        let newCategory = Category(name: name)
        categories.append(newCategory)
        saveCategories()
    }

    func assignScreenshot(screenshotId: String, category: Category) {
        assignments[screenshotId] = category.id
        saveAssignments()
    }

    func categoryForScreenshot(screenshotId: String) -> Category? {
        guard let categoryId = assignments[screenshotId] else { return nil }
        return categories.first(where: { $0.id == categoryId })
    }

    private func loadCategories() {
        if let data = UserDefaults.standard.data(forKey: categoriesKey),
           let saved = try? JSONDecoder().decode([Category].self, from: data) {
            categories = saved
        }
    }

    private func saveCategories() {
        if let data = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(data, forKey: categoriesKey)
        }
    }

    private func loadAssignments() {
        if let data = UserDefaults.standard.data(forKey: assignmentsKey),
           let saved = try? JSONDecoder().decode([String: UUID].self, from: data) {
            assignments = saved
        }
    }

    private func saveAssignments() {
        if let data = try? JSONEncoder().encode(assignments) {
            UserDefaults.standard.set(data, forKey: assignmentsKey)
        }
    }
}
