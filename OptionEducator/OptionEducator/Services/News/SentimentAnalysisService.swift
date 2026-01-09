import Foundation

/// Service for analyzing news sentiment and identifying potential stock impact.
final class SentimentAnalysisService {
    
    enum Sentiment: String {
        case bullish = "Bullish"
        case bearish = "Bearish"
        case neutral = "Neutral"
        
        var colorName: String {
            switch self {
            case .bullish: return "green"
            case .bearish: return "red"
            case .neutral: return "gray"
            }
        }
    }
    
    struct ImpactAnalysis {
        let sentiment: Sentiment
        let score: Double // -1.0 to 1.0
        let affectedStocks: [String]
        let reasoning: String
    }
    
    /// Analyzes an article to determine sentiment and stock impact
    static func analyze(_ article: MediastackArticle) -> ImpactAnalysis {
        let text = (article.title + " " + (article.description ?? "")).lowercased()
        
        // 1. Identify Affected Stocks/Sectors
        var stocks: Set<String> = []
        let stockKeywords: [String: [String]] = [
            "AAPL": ["apple", "iphone", "macbook", "ios"],
            "MSFT": ["microsoft", "windows", "azure", "xbox"],
            "TSLA": ["tesla", "ev", "elon musk", "model 3"],
            "NVDA": ["nvidia", "gpu", "ai", "chips", "h100"],
            "AMZN": ["amazon", "aws", "retail", "prime"],
            "GOOGL": ["google", "alphabet", "search", "android"],
            "META": ["meta", "facebook", "instagram", "zuckerberg"],
            "NFLX": ["netflix", "streaming"],
            "AMD": ["amd", "ryzen"],
            "INTC": ["intel", "semiconductor"]
        ]
        
        for (symbol, keywords) in stockKeywords {
            for keyword in keywords {
                if text.contains(keyword) {
                    stocks.insert(symbol)
                    break
                }
            }
        }
        
        // 2. Determine Sentiment
        let bullishKeywords = ["growth", "profit", "surge", "buy", "upgrade", "record", "success", "innovation", "partnership", "gain", "higher", "positive"]
        let bearishKeywords = ["loss", "drop", "fall", "decline", "sell", "downgrade", "lawsuit", "failure", "negative", "lower", "risk", "warning", "layoff"]
        
        var bullishCount = 0
        var bearishCount = 0
        
        for word in bullishKeywords {
            if text.contains(word) { bullishCount += 1 }
        }
        
        for word in bearishKeywords {
            if text.contains(word) { bearishCount += 1 }
        }
        
        let score: Double
        let sentiment: Sentiment
        
        if bullishCount > bearishCount {
            score = Double(bullishCount - bearishCount) / 5.0
            sentiment = .bullish
        } else if bearishCount > bullishCount {
            score = Double(bullishCount - bearishCount) / 5.0
            sentiment = .bearish
        } else {
            score = 0
            sentiment = .neutral
        }
        
        // 3. Generate Reasoning
        let reasoning: String
        if sentiment == .bullish {
            reasoning = "The news highlights positive developments like \(bullishKeywords.first { text.contains($0) } ?? "growth"), which typically drives investor confidence."
        } else if sentiment == .bearish {
            reasoning = "The mention of \(bearishKeywords.first { text.contains($0) } ?? "risk") suggests potential headwinds and downward pressure on the stock price."
        } else {
            reasoning = "The news appears to be informational or balanced, with no clear immediate impact on stock direction."
        }
        
        return ImpactAnalysis(
            sentiment: sentiment,
            score: max(-1.0, min(1.0, score)),
            affectedStocks: Array(stocks).sorted(),
            reasoning: reasoning
        )
    }
}
