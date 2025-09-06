import SwiftUI
import CoreData

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showConfirmReset = false

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Button(role: .destructive) {
                        showConfirmReset = true
                    } label: {
                        Text("Reset All Screenshots")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarHidden(true)
            .padding(.bottom, 100) // leave space for PhotoStyleAppMenu
            .alert("Are you sure?", isPresented: $showConfirmReset) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("This will permanently delete all screenshots.")
            }
        }
    }

    // MARK: - Reset Core Data
    private func resetAllData() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ScreenshotEntity")
        let batchDelete = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try viewContext.execute(batchDelete)
            try viewContext.save()
            print("✅ All screenshots deleted.")
        } catch {
            print("❌ Failed to reset screenshots: \(error)")
        }
    }
}
