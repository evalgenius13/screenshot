import SwiftUI
import CoreData

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var backgroundImport = true
    private let importer = ScreenshotImporter(context: PersistenceController.shared.container.viewContext)

    var body: some View {
        NavigationView {
            Form {
                Toggle("Enable Background Import", isOn: $backgroundImport)

                Button("Refresh Screenshots Now") {
                    importer.importScreenshots()
                }

                Button(role: .destructive) {
                    clearCache()
                } label: {
                    Text("Clear Cache (Delete All Screenshots)")
                }
            }
            .navigationTitle("Settings")
        }
    }

    private func clearCache() {
        let fetch: NSFetchRequest<NSFetchRequestResult> = ScreenshotEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetch)
        do {
            try viewContext.execute(deleteRequest)
            try viewContext.save()
        } catch {
            print("❌ Failed to clear cache: \(error)")
        }
    }
}

