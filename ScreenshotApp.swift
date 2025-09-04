import SwiftUI
import BackgroundTasks
import CoreData
import Foundation

@main
struct ScreenshotApp: App {
    let persistenceController = PersistenceController.shared
    @StateObject private var store = CategoryStore()
    private var importer: ScreenshotImporter

    init() {
        importer = ScreenshotImporter(context: persistenceController.container.viewContext)
        registerBackgroundTasks()
        scheduleAppRefresh()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(store)
                .onAppear {
                    // Run import automatically on launch
                    importer.importScreenshots()
                }
        }
    }

    // MARK: - Background Tasks
    private func registerBackgroundTasks() {
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "com.devo.Screenshot.refresh",
            using: nil
        ) { task in
            handleAppRefresh(task: task as! BGAppRefreshTask)
        }
    }

    private func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.devo.Screenshot.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        try? BGTaskScheduler.shared.submit(request)
    }

    private func handleAppRefresh(task: BGAppRefreshTask) {
        scheduleAppRefresh()
        importer.importScreenshots()
        task.setTaskCompleted(success: true)
    }
}

