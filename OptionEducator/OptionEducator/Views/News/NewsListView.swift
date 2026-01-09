import SwiftUI

/// A view that displays a list of real-time business and technology news articles.
struct NewsListView: View {
    // MARK: - Environment
    
    @EnvironmentObject private var mediastack: MediastackService
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            Group {
                if mediastack.isLoading && mediastack.articles.isEmpty {
                    ProgressView("Fetching latest news...")
                } else if let error = mediastack.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text(error)
                            .multilineTextAlignment(.center)
                        Button("Try Again") {
                            Task { await mediastack.fetchNews() }
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                } else {
                    List(mediastack.articles) { article in
                        NavigationLink(destination: NewsDetailView(article: article)) {
                            NewsCardView(article: article)
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await mediastack.fetchNews()
                    }
                }
            }
            .navigationTitle("Market News")
            .onAppear {
                if mediastack.articles.isEmpty {
                    Task { await mediastack.fetchNews() }
                }
            }
        }
    }
}

struct NewsCardView: View {
    let article: MediastackArticle
    
    var body: some View {
        let analysis = SentimentAnalysisService.analyze(article)
        
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(article.source)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Spacer()
                
                // Sentiment Badge
                Text(analysis.sentiment.rawValue)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(sentimentColor(analysis.sentiment).opacity(0.1))
                    .foregroundColor(sentimentColor(analysis.sentiment))
                    .cornerRadius(4)
            }
            
            Text(article.title)
                .font(.headline)
                .lineLimit(2)
            
            if let desc = article.description {
                Text(desc)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            HStack {
                Label(article.category.capitalized, systemImage: "tag")
                Spacer()
                Text(formatDate(article.published_at))
            }
            .font(.caption2)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    private func sentimentColor(_ sentiment: SentimentAnalysisService.Sentiment) -> Color {
        switch sentiment {
        case .bullish: return .green
        case .bearish: return .red
        case .neutral: return .gray
        }
    }
    
    private func formatDate(_ dateString: String) -> String {
        return String(dateString.prefix(10))
    }
}
