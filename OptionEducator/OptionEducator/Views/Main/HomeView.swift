import SwiftUI

/// The home dashboard view providing quick access to key features.
///
/// Displays featured strategies, recent news, and quick links to
/// calculators and platform comparisons.
struct HomeView: View {
    // MARK: - Environment
    
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var strategyService: StrategyDataService
    @EnvironmentObject private var newsService: NewsService
    
    // MARK: - State
    
    @State private var featuredStrategies: [OptionStrategy] = []
    @State private var recentNews: [NewsArticle] = []
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            ScrollView {
                VStack(spacing: 24) {
                    // Welcome Section
                    welcomeSection
                    
                    // Quick Actions
                    quickActionsSection
                    
                    // Featured Strategies
                    if !featuredStrategies.isEmpty {
                        featuredStrategiesSection
                    }
                    
                    // Recent News
                    if !recentNews.isEmpty {
                        recentNewsSection
                    }
                    
                    // Educational Resources
                    educationalSection
                }
                .padding()
            }
            .navigationTitle("Options Educator")
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await loadData()
            }
        }
        .task {
            await loadData()
        }
    }
    
    // MARK: - View Components
    
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Welcome to Options Educator")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Learn options trading strategies, compare platforms, and discover opportunities from market news.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                QuickActionCard(
                    title: "Browse Strategies",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .blue
                ) {
                    coordinator.switchTab(to: .strategies)
                }
                
                QuickActionCard(
                    title: "Compare Platforms",
                    icon: "building.2.fill",
                    color: .purple
                ) {
                    coordinator.switchTab(to: .platforms)
                }
                
                QuickActionCard(
                    title: "Market News",
                    icon: "newspaper.fill",
                    color: .orange
                ) {
                    coordinator.switchTab(to: .news)
                }
                
                QuickActionCard(
                    title: "Calculator",
                    icon: "function",
                    color: .green
                ) {
                    coordinator.switchTab(to: .calculator)
                }
            }
        }
    }
    
    private var featuredStrategiesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Featured Strategies")
                    .font(.headline)
                
                Spacer()
                
                Button("See All") {
                    coordinator.switchTab(to: .strategies)
                }
                .font(.subheadline)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(featuredStrategies.prefix(5)) { strategy in
                        StrategyCardView(strategy: strategy)
                            .frame(width: 280)
                    }
                }
            }
        }
    }
    
    private var recentNewsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent News")
                    .font(.headline)
                
                Spacer()
                
                Button("See All") {
                    coordinator.switchTab(to: .news)
                }
                .font(.subheadline)
            }
            
            VStack(spacing: 12) {
                ForEach(recentNews.prefix(3)) { article in
                    NewsCardView(article: article, isCompact: true)
                }
            }
        }
    }
    
    private var educationalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Learn More")
                .font(.headline)
            
            VStack(spacing: 12) {
                EducationalCard(
                    title: "Understanding Options",
                    description: "Learn the basics of call and put options",
                    icon: "book.fill",
                    color: .blue
                )
                
                EducationalCard(
                    title: "Risk Management",
                    description: "Master position sizing and risk control",
                    icon: "shield.fill",
                    color: .green
                )
                
                EducationalCard(
                    title: "Platform Selection",
                    description: "Choose the right broker for your needs",
                    icon: "building.2.fill",
                    color: .purple
                )
            }
        }
    }
    
    // MARK: - Methods
    
    private func loadData() async {
        // Load featured strategies (beginner-friendly ones)
        featuredStrategies = strategyService.strategies
            .filter { $0.complexityLevel <= 2 }
            .prefix(5)
            .map { $0 }
        
        // Load recent news
        recentNews = newsService.articles
            .sorted(by: >)
            .prefix(3)
            .map { $0 }
    }
}

// MARK: - Supporting Views

/// Quick action card for home screen
struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

/// Educational content card
struct EducationalCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(color.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Preview

#Preview {
    HomeView()
        .environmentObject(AppCoordinator())
        .environmentObject(StrategyDataService())
        .environmentObject(NewsService())
}
