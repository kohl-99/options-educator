import SwiftUI

/// A card view displaying a news article with strategy suggestions.
///
/// Shows article headline, summary, metadata, and suggested trading strategies
/// based on the news type and market impact.
struct NewsCardView: View {
    // MARK: - Properties
    
    let article: NewsArticle
    var isCompact: Bool = false
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Category and time
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
                
                Text(article.relativeTimeString)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Headline
            Text(article.headline)
                .font(isCompact ? .subheadline : .headline)
                .fontWeight(.semibold)
                .lineLimit(isCompact ? 2 : 3)
            
            // Summary
            if !isCompact {
                Text(article.summary)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            // Related symbols
            if !article.relatedSymbols.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(article.relatedSymbols, id: \.self) { symbol in
                            Text(symbol)
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(6)
                        }
                    }
                }
            }
            
            // Sentiment
            if let sentiment = article.sentiment {
                HStack(spacing: 4) {
                    Image(systemName: sentiment.iconName)
                        .font(.caption)
                    Text(sentiment.rawValue)
                        .font(.caption)
                }
                .foregroundColor(sentimentColor(sentiment))
            }
            
            // Strategy suggestions preview
            if !isCompact && !article.suggestedStrategies.isEmpty {
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Suggested Strategies")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    ForEach(article.suggestedStrategies.prefix(2)) { suggestion in
                        StrategySuggestionRow(suggestion: suggestion)
                    }
                    
                    if article.suggestedStrategies.count > 2 {
                        Text("+\(article.suggestedStrategies.count - 2) more")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    // MARK: - Helper Methods
    
    private func sentimentColor(_ sentiment: NewsArticle.Sentiment) -> Color {
        switch sentiment {
        case .positive: return .green
        case .neutral: return .gray
        case .negative: return .red
        }
    }
}

// MARK: - Supporting Views

/// Category badge for news articles
struct CategoryBadge: View {
    let category: NewsArticle.NewsCategory
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: category.iconName)
            Text(category.rawValue)
        }
        .font(.caption)
        .fontWeight(.medium)
        .foregroundColor(categoryColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(categoryColor.opacity(0.1))
        .cornerRadius(6)
    }
    
    private var categoryColor: Color {
        switch category {
        case .earnings: return .blue
        case .mergers: return .purple
        case .fda: return .green
        case .economic: return .orange
        case .analyst: return .indigo
        case .legal: return .red
        case .product: return .teal
        case .management: return .pink
        case .general: return .gray
        }
    }
}

/// Strategy suggestion row
struct StrategySuggestionRow: View {
    let suggestion: NewsArticle.StrategySuggestion
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "lightbulb.fill")
                .font(.caption)
                .foregroundColor(.yellow)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(suggestion.strategyName)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text(suggestion.rationale)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            ConfidenceMeter(confidence: suggestion.confidence)
        }
        .padding(8)
        .background(Color.yellow.opacity(0.05))
        .cornerRadius(8)
    }
}

/// Confidence meter showing strategy suggestion confidence
struct ConfidenceMeter: View {
    let confidence: Double
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(Int(confidence * 100))%")
                .font(.caption2)
                .fontWeight(.bold)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                    
                    Rectangle()
                        .fill(confidenceColor)
                        .frame(width: geometry.size.width * confidence)
                }
            }
            .frame(height: 4)
            .cornerRadius(2)
        }
        .frame(width: 40)
    }
    
    private var confidenceColor: Color {
        if confidence >= 0.7 {
            return .green
        } else if confidence >= 0.5 {
            return .yellow
        } else {
            return .orange
        }
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            NewsCardView(article: .sample)
            NewsCardView(article: .sampleBreaking, isCompact: true)
        }
        .padding()
    }
}
