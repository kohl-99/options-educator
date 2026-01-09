import SwiftUI

/// A detailed view for a news article, featuring sentiment analysis and stock impact.
struct NewsDetailView: View {
    let article: MediastackArticle
    
    var body: some View {
        let analysis = SentimentAnalysisService.analyze(article)
        
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header Section
                VStack(alignment: .leading, spacing: 12) {
                    Text(article.source)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    
                    Text(article.title)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Published on \(formatDate(article.published_at))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Sentiment Analysis Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Market Sentiment")
                            .font(.headline)
                        Spacer()
                        SentimentBadge(sentiment: analysis.sentiment)
                    }
                    
                    Text(analysis.reasoning)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Sentiment Meter
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(sentimentColor(analysis.sentiment))
                                .frame(width: geo.size.width * CGFloat((analysis.score + 1.0) / 2.0), height: 8)
                        }
                    }
                    .frame(height: 8)
                    
                    HStack {
                        Text("Bearish")
                        Spacer()
                        Text("Neutral")
                        Spacer()
                        Text("Bullish")
                    }
                    .font(.caption2)
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.05))
                .cornerRadius(12)
                
                // Stock Impact Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Potential Stock Impact")
                        .font(.headline)
                    
                    if analysis.affectedStocks.isEmpty {
                        Text("No specific stocks identified in this article. The impact may be broader across the \(article.category) sector.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        HStack(spacing: 8) {
                            ForEach(analysis.affectedStocks, id: \.self) { stock in
                                Text(stock)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(20)
                            }
                        }
                    }
                }
                
                // Strategy Suggestions
                VStack(alignment: .leading, spacing: 16) {
                    Text("Recommended Strategies")
                        .font(.headline)
                    
                    ForEach(suggestedStrategies(for: analysis.sentiment), id: \.self) { strategy in
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.orange)
                            Text(strategy)
                                .font(.subheadline)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // Article Content
                VStack(alignment: .leading, spacing: 12) {
                    Text("Article Summary")
                        .font(.headline)
                    
                    Text(article.description ?? "No description available.")
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    if let url = URL(string: article.url) {
                        Link(destination: url) {
                            Text("Read Full Article on \(article.source)")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                        .padding(.top, 12)
                    }
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formatDate(_ dateString: String) -> String {
        return String(dateString.prefix(10))
    }
    
    private func sentimentColor(_ sentiment: SentimentAnalysisService.Sentiment) -> Color {
        switch sentiment {
        case .bullish: return .green
        case .bearish: return .red
        case .neutral: return .gray
        }
    }
    
    private func suggestedStrategies(for sentiment: SentimentAnalysisService.Sentiment) -> [String] {
        switch sentiment {
        case .bullish:
            return ["Bull Call Spread", "Long Call", "Cash-Secured Put"]
        case .bearish:
            return ["Bear Put Spread", "Long Put", "Covered Call"]
        case .neutral:
            return ["Iron Condor", "Iron Butterfly", "Calendar Spread"]
        }
    }
}
