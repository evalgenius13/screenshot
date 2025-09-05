import SwiftUI
import CoreData

@main
struct ScreenshotApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var store = CategoryStore()
    private var importer: ScreenshotImporter

    init() {
        importer = ScreenshotImporter(context: persistenceController.container.viewContext)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(store)
                .onAppear {
                    importer.importAllScreenshots()
                }
        }
    }
}

