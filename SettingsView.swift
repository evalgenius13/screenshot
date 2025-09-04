import SwiftUI

struct SettingsView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var importer: ScreenshotImporter

    init(context: NSManagedObjectContext) {
        _importer = StateObject(wrappedValue: ScreenshotImporter(context: context))
    }

    var body: some View {
        Form {
            Section(header: Text("Screenshots")) {
                Button(role: .destructive) {
                    importer.deleteAllScreenshots {
                        importer.importScreenshots()
                    }
                } label: {
                    Text("Reset & Reimport Screenshots")
                }
            }

            Section(header: Text("About")) {
                Text("ScreenClean – TestFlight MVP")
                Text("Version 1.0")
            }
        }
        .navigationTitle("Settings")
    }
}
