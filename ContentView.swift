import SwiftUI

struct ContentView: View {
    @EnvironmentObject var nav: AppNavigation   // Global navigation state

    var body: some View {
        ZStack(alignment: .bottom) {
            // Switch screens based on current tab
            switch nav.currentTab {
            case .recents:
                RecentsView()
            case .categories:
                CategoriesView()
            case .search:
                SearchView()
            case .settings:
                SettingsView()
            }

            // Bottom menu (always present)
            PhotoStyleAppMenu()
        }
        .navigationBarHidden(true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppNavigation()) // ✅ needed for previews
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}

