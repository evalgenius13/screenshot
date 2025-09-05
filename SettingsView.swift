import SwiftUI
import CoreData

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var context

    // Importer is a lightweight helper — no need for @StateObject
    private var importer: ScreenshotImporter {
        ScreenshotImporter(context: context)
    }

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

                Section(header: Text("Import")) {
                    Button {
                        importSampleScreenshot()
                    } label: {
                        Label("Import Sample Screenshot", systemImage: "square.and.arrow.down")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }

    // MARK: - Actions

    private func resetDatabase() {
        // Delete all screenshots
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ScreenshotEntity.fetchRequest()
        let batchDelete = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        _ = try? context.execute(batchDelete)

        // Delete all categories
        let categoryFetch: NSFetchRequest<NSFetchRequestResult> = CategoryEntity.fetchRequest()
        let categoryDelete = NSBatchDeleteRequest(fetchRequest: categoryFetch)
        _ = try? context.execute(categoryDelete)

        try? context.save()
    }

    private func importSampleScreenshot() {
        // Use a simple SF Symbol as a sample screenshot
        if let sampleImage = UIImage(systemName: "photo"),
           let data = sampleImage.jpegData(compressionQuality: 0.8) {
            importer.importScreenshot(data: data, category: nil)
        }
    }
}

