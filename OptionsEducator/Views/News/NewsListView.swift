import SwiftUI

/// Displays a feed of financial news articles with strategy suggestions.
///
/// Shows real-time market news and provides educational context on how
/// options traders might respond to different types of events.
struct NewsListView: View {
    // MARK: - Environment
    
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var newsService: NewsService
    
    // MARK: - State
    
    @State private var selectedCategory: NewsArticle.NewsCategory?
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            ScrollView {
                VStack(spacing: 16) {
                    // Breaking news section
                    if !newsService.breakingNews.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Breaking News")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(newsService.breakingNews) { article in
                                NewsCardView(article: article)
                                    .padding(.horizontal)
                            }
                        }
                        
                        Divider()
                            .padding(.vertical)
                    }
                    
                    // All news
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Latest News")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(newsService.articles.sorted(by: >)) { article in
                            NewsCardView(article: article)
                                .padding(.horizontal)
                                .onTapGesture {
                                    coordinator.navigate(to: .newsDetail(id: article.id))
                                }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Market News")
            .refreshable {
                await newsService.fetchLatestNews()
            }
            .navigationDestination(for: AppCoordinator.Route.self) { route in
                switch route {
                case .newsDetail(let id):
                    NewsDetailView(newsId: id)
                default:
                    EmptyView()
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NewsListView()
        .environmentObject(AppCoordinator())
        .environmentObject(NewsService())
}
