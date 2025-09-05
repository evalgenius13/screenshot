import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ScreenshotModel")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        seedSystemCategoriesIfNeeded(context: container.viewContext)
    }

    /// ✅ Always ensures all 12 system categories exist
    private func seedSystemCategoriesIfNeeded(context: NSManagedObjectContext) {
        let request: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
        let existing = (try? context.fetch(request)) ?? []
        let existingNames = Set(existing.compactMap { $0.name })

        let systemCategories = [
            "Food", "Fashion", "Home",
            "Beauty", "Sports & Fitness", "Education",
            "Quotes", "Music", "Entertainment",
            "Art", "Travel", "Other"
        ]

        for (index, name) in systemCategories.enumerated() {
            if !existingNames.contains(name) {
                let cat = CategoryEntity(context: context)
                cat.id = UUID()
                cat.name = name
                cat.isSystem = true
                cat.sortOrder = Int64(index)
            }
        }

        do {
            try context.save()
            print("✅ Ensured all system categories exist")
        } catch {
            print("❌ Failed to seed categories:", error.localizedDescription)
        }
    }
}

