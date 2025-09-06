import SwiftUI

@main
struct ScreenshotApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var nav = AppNavigation()   // ✅ global navigation state

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(nav)   // ✅ inject once at root
        }
    }
}

