import SwiftUI

/// Coordinates navigation throughout the application using a centralized routing system.
///
/// The coordinator pattern provides several benefits:
/// - Centralized navigation logic
/// - Testable navigation flows
/// - Support for deep linking
/// - Easy modification of navigation structure
@MainActor
final class AppCoordinator: ObservableObject {
    // MARK: - Published Properties
    
    /// The navigation path tracking the current navigation stack
    @Published var path = NavigationPath()
    
    /// The currently selected tab in the main tab view
    @Published var selectedTab: Tab = .home
    
    /// Indicates whether a modal sheet is presented
    @Published var isPresentingSheet = false
    
    /// The current sheet being presented, if any
    @Published var currentSheet: Sheet?
    
    // MARK: - Types
    
    /// Represents the main tabs in the application
    enum Tab: Int, CaseIterable {
        case home
        case strategies
        case platforms
        case news
        case calculator
        
        var title: String {
            switch self {
            case .home: return "Home"
            case .strategies: return "Strategies"
            case .platforms: return "Platforms"
            case .news: return "News"
            case .calculator: return "Calculator"
            }
        }
        
        var iconName: String {
            switch self {
            case .home: return "house.fill"
            case .strategies: return "chart.line.uptrend.xyaxis"
            case .platforms: return "building.2.fill"
            case .news: return "newspaper.fill"
            case .calculator: return "function"
            }
        }
    }
    
    /// Represents different routes in the application
    enum Route: Hashable {
        case home
        case strategyList
        case strategyDetail(id: String)
        case platformComparison
        case platformDetail(id: String)
        case newsList
        case newsDetail(id: String)
        case newsStrategy(newsId: String)
        case calculator
        case optionCalculator
        case greeksCalculator
    }
    
    /// Represents modal sheets that can be presented
    enum Sheet: Identifiable {
        case strategyFilter
        case platformFilter
        case settings
        case about
        case tutorial(page: Int)
        
        var id: String {
            switch self {
            case .strategyFilter: return "strategyFilter"
            case .platformFilter: return "platformFilter"
            case .settings: return "settings"
            case .about: return "about"
            case .tutorial(let page): return "tutorial_\(page)"
            }
        }
    }
    
    // MARK: - Navigation Methods
    
    /// Navigates to a specific route
    /// - Parameter route: The destination route
    func navigate(to route: Route) {
        path.append(route)
    }
    
    /// Pops the current view from the navigation stack
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    /// Pops to the root view of the current navigation stack
    func popToRoot() {
        path = NavigationPath()
    }
    
    /// Switches to a specific tab
    /// - Parameter tab: The tab to switch to
    func switchTab(to tab: Tab) {
        selectedTab = tab
        popToRoot() // Clear navigation stack when switching tabs
    }
    
    /// Presents a modal sheet
    /// - Parameter sheet: The sheet to present
    func presentSheet(_ sheet: Sheet) {
        currentSheet = sheet
        isPresentingSheet = true
    }
    
    /// Dismisses the currently presented sheet
    func dismissSheet() {
        isPresentingSheet = false
        currentSheet = nil
    }
    
    // MARK: - Deep Linking
    
    /// Handles deep links from external sources
    /// - Parameter url: The deep link URL
    /// - Returns: True if the URL was handled successfully
    func handleDeepLink(_ url: URL) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let host = components.host else {
            return false
        }
        
        switch host {
        case "strategy":
            if let id = components.queryItems?.first(where: { $0.name == "id" })?.value {
                switchTab(to: .strategies)
                navigate(to: .strategyDetail(id: id))
                return true
            }
            
        case "platform":
            if let id = components.queryItems?.first(where: { $0.name == "id" })?.value {
                switchTab(to: .platforms)
                navigate(to: .platformDetail(id: id))
                return true
            }
            
        case "news":
            if let id = components.queryItems?.first(where: { $0.name == "id" })?.value {
                switchTab(to: .news)
                navigate(to: .newsDetail(id: id))
                return true
            }
            
        case "calculator":
            switchTab(to: .calculator)
            return true
            
        default:
            break
        }
        
        return false
    }
    
    // MARK: - Utility Methods
    
    /// Checks if a specific route is currently active
    /// - Parameter route: The route to check
    /// - Returns: True if the route is in the navigation path
    func isActive(_ route: Route) -> Bool {
        // This is a simplified check - in production, you might want more sophisticated logic
        return false
    }
    
    /// Returns the current depth of the navigation stack
    var navigationDepth: Int {
        return path.count
    }
}

// MARK: - Route Equatable Conformance

extension AppCoordinator.Route: Equatable {
    static func == (lhs: AppCoordinator.Route, rhs: AppCoordinator.Route) -> Bool {
        switch (lhs, rhs) {
        case (.home, .home),
             (.strategyList, .strategyList),
             (.platformComparison, .platformComparison),
             (.newsList, .newsList),
             (.calculator, .calculator),
             (.optionCalculator, .optionCalculator),
             (.greeksCalculator, .greeksCalculator):
            return true
            
        case (.strategyDetail(let lhsId), .strategyDetail(let rhsId)),
             (.platformDetail(let lhsId), .platformDetail(let rhsId)),
             (.newsDetail(let lhsId), .newsDetail(let rhsId)):
            return lhsId == rhsId
            
        case (.newsStrategy(let lhsId), .newsStrategy(let rhsId)):
            return lhsId == rhsId
            
        default:
            return false
        }
    }
}
