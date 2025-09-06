import Foundation
import SwiftUI

/// Enum for all the main tabs in the app
enum AppTab {
    case recents
    case categories
    case search
    case settings
}

/// ObservableObject that manages the active tab
final class AppNavigation: ObservableObject {
    @Published var currentTab: AppTab = .recents
}

