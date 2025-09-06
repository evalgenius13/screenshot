import CoreData

struct CategorySeeder {
    static let defaultCategories = [
        "Food", "Fashion", "Home", "Beauty",
        "Fitness", "Education", "Quotes", "Music",
        "Entertainment", "Art", "Travel", "Other"
    ]

    static func seedIfNeeded(context: NSManagedObjectContext) {
        let request: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        let existing = (try? context.fetch(request)) ?? []
        let existingNames = Set(existing.compactMap { $0.name })

        for (index, name) in defaultCategories.enumerated() {
            if !existingNames.contains(where: { $0.caseInsensitiveCompare(name) == .orderedSame }) {
                let category = CategoryEntity(context: context)
                category.id = UUID()
                category.name = name
                category.isSystem = (name.caseInsensitiveCompare("Other") == .orderedSame)
                category.sortOrder = Int64(index)
            }
        }

        try? context.save()
    }
}

