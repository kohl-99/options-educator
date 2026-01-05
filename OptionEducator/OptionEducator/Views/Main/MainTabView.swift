import SwiftUI

/// The main tab view container for the application.
///
/// Provides navigation between the five main sections of the app:
/// Home, Strategies, Platforms, News, and Calculator.
struct MainTabView: View {
    // MARK: - Environment
    
    @EnvironmentObject private var coordinator: AppCoordinator
    
    // MARK: - Body
    
    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            HomeView()
                .tabItem {
                    Label(AppCoordinator.Tab.home.title,
                          systemImage: AppCoordinator.Tab.home.iconName)
                }
                .tag(AppCoordinator.Tab.home)
            
            StrategyListView()
                .tabItem {
                    Label(AppCoordinator.Tab.strategies.title,
                          systemImage: AppCoordinator.Tab.strategies.iconName)
                }
                .tag(AppCoordinator.Tab.strategies)
            
            PlatformComparisonView()
                .tabItem {
                    Label(AppCoordinator.Tab.platforms.title,
                          systemImage: AppCoordinator.Tab.platforms.iconName)
                }
                .tag(AppCoordinator.Tab.platforms)
            
            NewsListView()
                .tabItem {
                    Label(AppCoordinator.Tab.news.title,
                          systemImage: AppCoordinator.Tab.news.iconName)
                }
                .tag(AppCoordinator.Tab.news)
            
            CalculatorTabView()
                .tabItem {
                    Label(AppCoordinator.Tab.calculator.title,
                          systemImage: AppCoordinator.Tab.calculator.iconName)
                }
                .tag(AppCoordinator.Tab.calculator)
        }
        .accentColor(.blue)
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
        .environmentObject(AppCoordinator())
        .environmentObject(StrategyDataService())
        .environmentObject(PlatformDataService())
        .environmentObject(NewsService())
}
