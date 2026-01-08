import SwiftUI

/// The main entry point for the Options Educator iOS application.
///
/// This app provides comprehensive education on stock options trading strategies,
/// platform comparisons, real-time market news, and interactive calculators.
@main
struct OptionEducatorApp: App {
    // MARK: - Properties
    
    /// The app coordinator manages navigation throughout the application
    @StateObject private var coordinator = AppCoordinator()
    
    /// Shared services injected as environment objects
    @StateObject private var strategyDataService = StrategyDataService()
    @StateObject private var platformDataService = PlatformDataService()
    @StateObject private var newsService = NewsService()
    @StateObject private var marketstackService = MarketstackService()
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(coordinator)
                .environmentObject(strategyDataService)
                .environmentObject(platformDataService)
                .environmentObject(newsService)
                .environmentObject(marketstackService)
                .onAppear {
                    setupApp()
                }
        }
    }
    
    // MARK: - Private Methods
    
    /// Performs initial app setup tasks
    private func setupApp() {
        configureAppearance()
        loadInitialData()
    }
    
    /// Configures global app appearance settings
    private func configureAppearance() {
        // Configure navigation bar appearance
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = UIColor(named: "PrimaryBackground")
        navigationBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor(named: "PrimaryText") ?? .label
        ]
        
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().compactAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        
        // Configure tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(named: "PrimaryBackground")
        
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    /// Loads initial data required for app functionality
    private func loadInitialData() {
        Task {
            // Load strategy data from bundled JSON
            await strategyDataService.loadStrategies()
            
            // Load platform data from bundled JSON
            await platformDataService.loadPlatforms()
            
            // Fetch initial news feed
            await newsService.fetchLatestNews()
        }
    }
}
