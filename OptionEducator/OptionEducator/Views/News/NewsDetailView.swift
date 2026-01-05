import SwiftUI

/// Detailed view for a news article with strategy suggestions.
///
/// Displays the full article content, related symbols, sentiment analysis,
/// and educational strategy suggestions based on the news type.
struct NewsDetailView: View {
    // MARK: - Environment
    
    @EnvironmentObject private var newsService: NewsService
    @EnvironmentObject private var coordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    
    // MARK: - Properties
    
    let newsId: String
    
    // MARK: - State
    
    @State private var article: NewsArticle?
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if let article = article {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        headerSection(article)
                        
                        Divider()
                        
                        // Article Content
                        contentSection(article)
                        
                        // Related Symbols
                        if !article.relatedSymbols.isEmpty {
                            symbolsSection(article)
                        }
                        
                        // Sentiment
                        if let sentiment = article.sentiment {
                            sentimentSection(sentiment)
                        }
                        
                        // Strategy Suggestions
                        if !article.suggestedStrategies.isEmpty {
                            strategySuggestionsSection(article)
                        }
                        
                        // Historical Context
                        if let context = article.historicalContext {
                            historicalContextSection(context)
                        }
                        
                        // Source Link
                        sourceLinkSection(article)
                    }
                    .padding()
                }
                .navigationTitle("News Detail")
                .navigationBarTitleDisplayMode(.inline)
            } else {
                ContentUnavailableView(
                    "Article Not Found",
                    systemImage: "exclamationmark.triangle",
                    description: Text("The requested article could not be loaded.")
                )
            }
        }
        .onAppear {
            loadArticle()
        }
    }
    
    // MARK: - View Components
    
    private func headerSection(_ article: NewsArticle) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category and Breaking Badge
            HStack {
                CategoryBadge(category: article.category)
                
                if article.isBreaking {
                    Text("BREAKING")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red)
                        .cornerRadius(4)
                }
                
                Spacer()
            }
            
            // Headline
            Text(article.headline)
                .font(.title2)
                .fontWeight(.bold)
            
            // Metadata
            HStack {
                Text(article.source.name)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("•")
                    .foregroundColor(.secondary)
                
                Text(article.relativeTimeString)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func contentSection(_ article: NewsArticle) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Summary")
                .font(.headline)
            
            Text(article.summary)
                .font(.body)
            
            if let content = article.content {
                Text("Full Article")
                    .font(.headline)
                    .padding(.top, 8)
                
                Text(content)
                    .font(.body)
            }
        }
    }
    
    private func symbolsSection(_ article: NewsArticle) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Related Symbols")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(article.relatedSymbols, id: \.self) { symbol in
                        SymbolChip(symbol: symbol)
                    }
                }
            }
        }
    }
    
    private func sentimentSection(_ sentiment: NewsArticle.Sentiment) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Market Sentiment")
                .font(.headline)
            
            HStack {
                Image(systemName: sentiment.iconName)
                    .font(.title2)
                    .foregroundColor(sentimentColor(sentiment))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(sentiment.rawValue)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(sentimentColor(sentiment))
                    
                    Text(sentimentDescription(sentiment))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .background(sentimentColor(sentiment).opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    private func strategySuggestionsSection(_ article: NewsArticle) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Strategy Suggestions")
                .font(.headline)
            
            Text("Based on this type of news event, here are some educational examples of how options traders might respond:")
                .font(.caption)
                .foregroundColor(.secondary)
            
            ForEach(article.suggestedStrategies) { suggestion in
                StrategySuggestionCard(suggestion: suggestion)
            }
        }
    }
    
    private func historicalContextSection(_ context: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundColor(.blue)
                Text("Historical Context")
                    .font(.headline)
            }
            
            Text(context)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func sourceLinkSection(_ article: NewsArticle) -> some View {
        Button {
            if let url = URL(string: article.url) {
                openURL(url)
            }
        } label: {
            HStack {
                Image(systemName: "link")
                Text("Read Full Article on \(article.source.name)")
                Spacer()
                Image(systemName: "arrow.up.right")
            }
            .font(.subheadline)
            .foregroundColor(.blue)
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadArticle() {
        article = newsService.article(withId: newsId)
    }
    
    private func sentimentColor(_ sentiment: NewsArticle.Sentiment) -> Color {
        switch sentiment {
        case .positive: return .green
        case .neutral: return .gray
        case .negative: return .red
        }
    }
    
    private func sentimentDescription(_ sentiment: NewsArticle.Sentiment) -> String {
        switch sentiment {
        case .positive:
            return "This news is generally viewed as positive for the stock"
        case .neutral:
            return "This news has mixed or uncertain implications"
        case .negative:
            return "This news is generally viewed as negative for the stock"
        }
    }
}

// MARK: - Supporting Views

struct SymbolChip: View {
    let symbol: String
    
    var body: some View {
        Text(symbol)
            .font(.subheadline)
            .fontWeight(.semibold)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(20)
    }
}

struct StrategySuggestionCard: View {
    let suggestion: NewsArticle.StrategySuggestion
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                
                Text(suggestion.strategyName)
                    .font(.headline)
                
                Spacer()
                
                ConfidenceMeter(confidence: suggestion.confidence)
            }
            
            // Rationale
            VStack(alignment: .leading, spacing: 8) {
                Text("Rationale")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                Text(suggestion.rationale)
                    .font(.subheadline)
            }
            
            // Details Grid
            VStack(spacing: 8) {
                DetailRow(label: "Timing", value: suggestion.timing, icon: "clock")
                DetailRow(label: "Risk Level", value: suggestion.riskLevel, icon: "exclamationmark.triangle")
                DetailRow(label: "Expected Outcome", value: suggestion.expectedOutcome, icon: "target")
            }
            
            // Platform Availability
            VStack(alignment: .leading, spacing: 8) {
                Text("Available On")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(suggestion.platformAvailability, id: \.self) { platform in
                            Text(platform)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green.opacity(0.1))
                                .foregroundColor(.green)
                                .cornerRadius(6)
                        }
                    }
                }
            }
            
            // Disclaimer
            Text("⚠️ This is educational content only. Always conduct your own research and consider your risk tolerance before trading.")
                .font(.caption2)
                .foregroundColor(.orange)
                .padding(.top, 4)
        }
        .padding()
        .background(Color.yellow.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
        )
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        NewsDetailView(newsId: "news-001")
            .environmentObject(NewsService())
            .environmentObject(AppCoordinator())
    }
}
