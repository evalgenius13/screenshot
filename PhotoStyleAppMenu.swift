import SwiftUI

struct PhotoStyleAppMenu: View {
    @EnvironmentObject var nav: AppNavigation   // Shared navigation state

    var body: some View {
        HStack {
            Spacer()
            MenuButton(icon: "clock", label: "Recents", tab: .recents, currentTab: nav.currentTab) {
                nav.currentTab = .recents
            }
            Spacer()
            MenuButton(icon: "square.grid.2x2", label: "Categories", tab: .categories, currentTab: nav.currentTab) {
                nav.currentTab = .categories
            }
            Spacer()
            MenuButton(icon: "magnifyingglass", label: "Search", tab: .search, currentTab: nav.currentTab) {
                nav.currentTab = .search
            }
            Spacer()
            MenuButton(icon: "gearshape", label: "Settings", tab: .settings, currentTab: nav.currentTab) {
                nav.currentTab = .settings
            }
            Spacer()
        }
        .padding(.vertical, 14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .padding(.horizontal, 12)
        .shadow(color: Color.black.opacity(0.10), radius: 10)
        .ignoresSafeArea(edges: .bottom)
    }
}

// MARK: - Menu Button
struct MenuButton: View {
    let icon: String
    let label: String
    let tab: AppTab
    let currentTab: AppTab
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(currentTab == tab ? .blue : .gray)
                Text(label)
                    .font(.caption2)
                    .foregroundColor(currentTab == tab ? .blue : .gray)
            }
        }
    }
}

