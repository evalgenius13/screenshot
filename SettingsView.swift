import SwiftUI
import CoreData

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var context

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Data")) {
                    Button(role: .destructive) {
                        resetDatabase()
                    } label: {
                        Label("Reset", systemImage: "arrow.clockwise")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }

    // MARK: - Reset Action
    private func resetDatabase() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ScreenshotEntity.fetchRequest()
        let batchDelete = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        _ = try? context.execute(batchDelete)

        let categoryFetch: NSFetchRequest<NSFetchRequestResult> = CategoryEntity.fetchRequest()
        let categoryDelete = NSBatchDeleteRequest(fetchRequest: categoryFetch)
        _ = try? context.execute(categoryDelete)

        try? context.save()
        print("✅ Database reset")
    }
}

