import Foundation

/// Represents a financial news article with associated trading insights.
///
/// This model captures news articles and provides context for how options
/// traders might respond to different types of market events.
struct NewsArticle: Identifiable, Codable, Hashable {
    // MARK: - Properties
    
    /// Unique identifier for the article
    let id: String
    
    /// Article headline
    let headline: String
    
    /// Brief summary of the article
    let summary: String
    
    /// Full article content (if available)
    let content: String?
    
    /// Source of the news
    let source: NewsSource
    
    /// Publication date and time
    let publishedAt: Date
    
    /// Related stock symbols
    let relatedSymbols: [String]
    
    /// News category
    let category: NewsCategory
    
    /// Article URL for full content
    let url: String
    
    /// Image URL (if available)
    let imageURL: String?
    
    /// Sentiment analysis (if available)
    let sentiment: Sentiment?
    
    /// Suggested trading strategies based on this news
    let suggestedStrategies: [StrategySuggestion]
    
    /// Historical context or similar events
    let historicalContext: String?
    
    // MARK: - Computed Properties
    
    /// Returns a relative time string (e.g., "2 hours ago")
    var relativeTimeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: publishedAt, relativeTo: Date())
    }
    
    /// Indicates if this is breaking news (published within last hour)
    var isBreaking: Bool {
        let oneHourAgo = Date().addingTimeInterval(-3600)
        return publishedAt > oneHourAgo
    }
    
    /// Returns the primary symbol if available
    var primarySymbol: String? {
        return relatedSymbols.first
    }
    
    // MARK: - Types
    
    /// News source information
    struct NewsSource: Codable, Hashable {
        let id: String
        let name: String
        let logoURL: String?
    }
    
    /// Category of financial news
    enum NewsCategory: String, Codable, CaseIterable {
        case earnings = "Earnings"
        case mergers = "Mergers & Acquisitions"
        case fda = "FDA Approvals"
        case economic = "Economic Data"
        case analyst = "Analyst Ratings"
        case legal = "Legal & Regulatory"
        case product = "Product Launches"
        case management = "Management Changes"
        case general = "General News"
        
        var iconName: String {
            switch self {
            case .earnings: return "chart.bar.fill"
            case .mergers: return "building.2.crop.circle.fill"
            case .fda: return "cross.circle.fill"
            case .economic: return "globe.americas.fill"
            case .analyst: return "person.text.rectangle.fill"
            case .legal: return "hammer.fill"
            case .product: return "shippingbox.fill"
            case .management: return "person.2.fill"
            case .general: return "newspaper.fill"
            }
        }
        
        var color: String {
            switch self {
            case .earnings: return "Blue"
            case .mergers: return "Purple"
            case .fda: return "Green"
            case .economic: return "Orange"
            case .analyst: return "Indigo"
            case .legal: return "Red"
            case .product: return "Teal"
            case .management: return "Pink"
            case .general: return "Gray"
            }
        }
    }
    
    /// Sentiment analysis of the news
    enum Sentiment: String, Codable {
        case positive = "Positive"
        case neutral = "Neutral"
        case negative = "Negative"
        
        var iconName: String {
            switch self {
            case .positive: return "arrow.up.circle.fill"
            case .neutral: return "minus.circle.fill"
            case .negative: return "arrow.down.circle.fill"
            }
        }
        
        var color: String {
            switch self {
            case .positive: return "Green"
            case .neutral: return "Gray"
            case .negative: return "Red"
            }
        }
    }
    
    /// Suggested trading strategy based on news
    struct StrategySuggestion: Identifiable, Codable, Hashable {
        let id: String
        let strategyId: String
        let strategyName: String
        let rationale: String
        let timing: String
        let riskLevel: String
        let expectedOutcome: String
        let platformAvailability: [String]
        
        /// Confidence level of this suggestion (0-1)
        let confidence: Double
    }
}

// MARK: - Extensions

extension NewsArticle {
    /// Creates a sample news article for previews and testing
    static var sample: NewsArticle {
        NewsArticle(
            id: "news-001",
            headline: "Apple Reports Record Q4 Earnings, Beats Expectations",
            summary: "Apple Inc. announced quarterly earnings that exceeded analyst expectations, driven by strong iPhone sales and services revenue growth.",
            content: "Apple Inc. (AAPL) reported fourth-quarter earnings that beat Wall Street estimates on both revenue and earnings per share. The company posted revenue of $89.5 billion, up 8% year-over-year, while EPS came in at $1.46 versus the expected $1.39...",
            source: NewsSource(
                id: "bloomberg",
                name: "Bloomberg",
                logoURL: "https://example.com/bloomberg-logo.png"
            ),
            publishedAt: Date().addingTimeInterval(-7200), // 2 hours ago
            relatedSymbols: ["AAPL"],
            category: .earnings,
            url: "https://example.com/apple-earnings",
            imageURL: "https://example.com/apple-image.jpg",
            sentiment: .positive,
            suggestedStrategies: [
                StrategySuggestion(
                    id: "suggestion-1",
                    strategyId: "bull-call-spread",
                    strategyName: "Bull Call Spread",
                    rationale: "Strong earnings suggest continued upward momentum. A bull call spread limits risk while capturing upside potential.",
                    timing: "Enter within 1-2 trading days",
                    riskLevel: "Moderate",
                    expectedOutcome: "Profit if stock continues rally, limited loss if reversal occurs",
                    platformAvailability: ["Robinhood Level 3", "Fidelity Tier 2", "Interactive Brokers Level 2"],
                    confidence: 0.75
                ),
                StrategySuggestion(
                    id: "suggestion-2",
                    strategyId: "long-call",
                    strategyName: "Long Call",
                    rationale: "Positive earnings surprise often leads to continued price appreciation in the near term.",
                    timing: "Enter immediately",
                    riskLevel: "Moderate",
                    expectedOutcome: "Profit from continued upward movement",
                    platformAvailability: ["All Platforms - Basic Level"],
                    confidence: 0.65
                )
            ],
            historicalContext: "Historically, Apple stock has shown an average 3.2% gain in the week following positive earnings surprises. Similar earnings beats in Q4 2022 and Q4 2023 resulted in 5.1% and 4.3% gains respectively."
        )
    }
    
    /// Creates a sample breaking news article
    static var sampleBreaking: NewsArticle {
        NewsArticle(
            id: "news-002",
            headline: "FDA Approves Breakthrough Cancer Treatment",
            summary: "The FDA has granted accelerated approval for a novel cancer therapy, sending biotech stock soaring in after-hours trading.",
            content: nil,
            source: NewsSource(
                id: "reuters",
                name: "Reuters",
                logoURL: nil
            ),
            publishedAt: Date().addingTimeInterval(-1800), // 30 minutes ago
            relatedSymbols: ["BIOTECH"],
            category: .fda,
            url: "https://example.com/fda-approval",
            imageURL: nil,
            sentiment: .positive,
            suggestedStrategies: [
                StrategySuggestion(
                    id: "suggestion-3",
                    strategyId: "long-call",
                    strategyName: "Long Call",
                    rationale: "FDA approval is a major catalyst. Long calls provide leveraged upside exposure.",
                    timing: "Enter at market open",
                    riskLevel: "High",
                    expectedOutcome: "Significant profit potential if rally continues",
                    platformAvailability: ["All Platforms - Basic Level"],
                    confidence: 0.80
                )
            ],
            historicalContext: "FDA approvals typically result in 15-30% stock price increases for biotech companies in the first week."
        )
    }
}

// MARK: - Comparable Conformance

extension NewsArticle: Comparable {
    static func < (lhs: NewsArticle, rhs: NewsArticle) -> Bool {
        return lhs.publishedAt < rhs.publishedAt
    }
}

// MARK: - Coding Keys

extension NewsArticle {
    enum CodingKeys: String, CodingKey {
        case id
        case headline
        case summary
        case content
        case source
        case publishedAt = "published_at"
        case relatedSymbols = "related_symbols"
        case category
        case url
        case imageURL = "image_url"
        case sentiment
        case suggestedStrategies = "suggested_strategies"
        case historicalContext = "historical_context"
    }
}
