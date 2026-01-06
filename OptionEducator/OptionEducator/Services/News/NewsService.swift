import Foundation
import Combine

/// Service responsible for fetching and managing financial news.
///
/// Integrates with news APIs to provide real-time market news
/// and generates strategy suggestions based on news events.
@MainActor
final class NewsService: ObservableObject {
    // MARK: - Published Properties
    
    /// All fetched news articles
    @Published private(set) var articles: [NewsArticle] = []
    
    /// Loading state
    @Published private(set) var isLoading = false
    
    /// Error state
    @Published private(set) var error: Error?
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        Task {
            await fetchLatestNews()
        }
    }
    
    // MARK: - Public Methods
    
    /// Fetches the latest financial news
    func fetchLatestNews() async {
        isLoading = true
        error = nil
        
        do {
            // In a real app, this would call the news API
            // For now, we'll create classic case examples
            try await Task.sleep(nanoseconds: 500_000_000)
            articles = createClassicCaseNews()
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
    
    /// Finds an article by its ID
    func article(withId id: String) -> NewsArticle? {
        return articles.first { $0.id == id }
    }
    
    /// Returns breaking news articles
    var breakingNews: [NewsArticle] {
        return articles.filter { $0.isBreaking }.sorted(by: >)
    }
    
    // MARK: - Private Methods
    
    /// Creates classic case news articles for demonstration
    private func createClassicCaseNews() -> [NewsArticle] {
        let now = Date()
        
        return [
            // Case 1: Earnings Volatility Play
            createEarningsStraddleCase(now: now),
            // Case 2: Merger Arbitrage Play
            createMergerArbCase(now: now),
            // Case 3: FDA Approval Momentum Play
            createFDAMomentumCase(now: now),
            // Case 4: Economic Data Neutral Play
            createEconomicNeutralCase(now: now),
            // Case 5: Tech Sector Bullish Momentum
            createTechBullishCase(now: now)
        ]
    }
    
    private func createEarningsStraddleCase(now: Date) -> NewsArticle {
        NewsArticle(
            id: "case-earnings-001",
            headline: "NVIDIA Earnings Tonight: Market Expects 10% Move",
            summary: "NVIDIA is set to report earnings after the bell. Options pricing suggests a massive move in either direction, making it a classic case for volatility strategies.",
            content: "NVIDIA (NVDA) will report its quarterly results today. The stock has been highly volatile leading up to the announcement. Implied volatility is at yearly highs, and the options market is pricing in a nearly 10% move. This scenario is a textbook example of when traders consider straddles or strangles to profit from volatility regardless of the direction.",
            source: NewsArticle.NewsSource(id: "marketwatch", name: "MarketWatch", logoURL: nil),
            publishedAt: now.addingTimeInterval(-3600),
            relatedSymbols: ["NVDA"],
            category: .earnings,
            url: "https://example.com/nvda-earnings",
            imageURL: nil,
            sentiment: .neutral,
            suggestedStrategies: [
                NewsArticle.StrategySuggestion(
                    id: "sug-nvda-1",
                    strategyId: "straddle",
                    strategyName: "Long Straddle",
                    rationale: "Classic earnings play. When you expect a massive move but aren't sure of the direction, a straddle profits from the magnitude of the move.",
                    timing: "Enter 30 minutes before market close",
                    riskLevel: "High",
                    expectedOutcome: "Profit if NVDA moves more than 10% up or down",
                    platformAvailability: ["All Platforms"],
                    confidence: 0.85
                ),
                NewsArticle.StrategySuggestion(
                    id: "sug-nvda-2",
                    strategyId: "iron-condor",
                    strategyName: "Iron Condor",
                    rationale: "The 'Volatility Crush' play. If you believe the move will be smaller than the 10% priced in, you can sell volatility.",
                    timing: "Enter shortly before close",
                    riskLevel: "Moderate",
                    expectedOutcome: "Profit if NVDA moves less than 10% and volatility drops",
                    platformAvailability: ["Robinhood Level 3", "Fidelity Tier 2", "IBKR Level 2"],
                    confidence: 0.70
                )
            ],
            historicalContext: "In 4 of the last 5 earnings reports, NVDA has moved more than the market-implied percentage, rewarding straddle buyers."
        )
    }
    
    private func createMergerArbCase(now: Date) -> NewsArticle {
        NewsArticle(
            id: "case-merger-001",
            headline: "Microsoft to Acquire Gaming Giant in $69B Deal",
            summary: "Microsoft announces definitive agreement to acquire Activision Blizzard. The deal creates a classic merger arbitrage opportunity for options traders.",
            content: "Microsoft (MSFT) has announced it will acquire Activision Blizzard (ATVI) for $95 per share in cash. ATVI stock is currently trading at $82, representing a significant spread. This gap exists due to regulatory uncertainty and the time required to close the deal. Traders often use specific options strategies to capture this spread while hedging against deal failure.",
            source: NewsArticle.NewsSource(id: "reuters", name: "Reuters", logoURL: nil),
            publishedAt: now.addingTimeInterval(-14400),
            relatedSymbols: ["MSFT", "ATVI"],
            category: .mergers,
            url: "https://example.com/msft-atvi-merger",
            imageURL: nil,
            sentiment: .positive,
            suggestedStrategies: [
                NewsArticle.StrategySuggestion(
                    id: "sug-merger-1",
                    strategyId: "cash-secured-put",
                    strategyName: "Cash-Secured Put",
                    rationale: "Selling puts at a strike below the acquisition price ($95) allows you to collect premium while the deal is pending, with the acquisition price acting as a 'floor'.",
                    timing: "Post-announcement dip",
                    riskLevel: "Low",
                    expectedOutcome: "Collect premium as stock slowly drifts toward $95",
                    platformAvailability: ["All Platforms"],
                    confidence: 0.90
                ),
                NewsArticle.StrategySuggestion(
                    id: "sug-merger-2",
                    strategyId: "bull-call-spread",
                    strategyName: "Bull Call Spread",
                    rationale: "A defined-risk way to bet on the deal closing. Use strikes between current price and $95.",
                    timing: "Anytime during regulatory review",
                    riskLevel: "Moderate",
                    expectedOutcome: "Max profit if deal closes at $95",
                    platformAvailability: ["Intermediate Levels"],
                    confidence: 0.75
                )
            ],
            historicalContext: "Merger arbitrage spreads typically narrow as regulatory approvals are granted. Options can leverage this narrowing effect."
        )
    }
    
    private func createFDAMomentumCase(now: Date) -> NewsArticle {
        NewsArticle(
            id: "case-fda-001",
            headline: "Biotech Firm Receives FDA 'Fast Track' Designation",
            summary: "Small-cap biotech receives positive FDA news for its lead drug candidate. Momentum traders are eyeing options for leveraged upside.",
            content: "A small-cap biotech company has received FDA Fast Track designation for its experimental Alzheimer's treatment. This news often precedes significant price momentum. However, biotech stocks are notoriously volatile, making defined-risk options strategies preferable to direct stock ownership for many traders.",
            source: NewsArticle.NewsSource(id: "stat", name: "STAT News", logoURL: nil),
            publishedAt: now.addingTimeInterval(-7200),
            relatedSymbols: ["BIOT"],
            category: .fda,
            url: "https://example.com/biotech-fda",
            imageURL: nil,
            sentiment: .positive,
            suggestedStrategies: [
                NewsArticle.StrategySuggestion(
                    id: "sug-fda-1",
                    strategyId: "long-call",
                    strategyName: "Long Call",
                    rationale: "Pure momentum play. High leverage for a potential multi-day rally with risk limited to the premium paid.",
                    timing: "Immediate entry on news",
                    riskLevel: "Very High",
                    expectedOutcome: "Significant gains if stock continues to surge",
                    platformAvailability: ["All Platforms"],
                    confidence: 0.65
                ),
                NewsArticle.StrategySuggestion(
                    id: "sug-fda-2",
                    strategyId: "bull-call-spread",
                    strategyName: "Bull Call Spread",
                    rationale: "Reduces the cost of the high implied volatility typically found in biotech stocks while still allowing for profit on a move higher.",
                    timing: "After initial 15-minute volatility",
                    riskLevel: "Moderate",
                    expectedOutcome: "Profit on continued upward trend",
                    platformAvailability: ["Intermediate Levels"],
                    confidence: 0.80
                )
            ],
            historicalContext: "Fast Track designations often lead to a 'halo effect' where the stock rallies for 3-5 days following the announcement."
        )
    }
    
    private func createEconomicNeutralCase(now: Date) -> NewsArticle {
        NewsArticle(
            id: "case-econ-001",
            headline: "CPI Data Matches Expectations, Market Remains Sideways",
            summary: "Latest inflation data shows no surprises. With no major catalysts on the horizon, the market is expected to trade in a tight range.",
            content: "The Consumer Price Index (CPI) rose 0.2% last month, exactly matching economist forecasts. The lack of a surprise has led to a decrease in market volatility. In a sideways market with declining volatility, 'income' strategies that profit from time decay (Theta) are the classic choice for professional traders.",
            source: NewsArticle.NewsSource(id: "cnbc", name: "CNBC", logoURL: nil),
            publishedAt: now.addingTimeInterval(-10800),
            relatedSymbols: ["SPY", "QQQ"],
            category: .economic,
            url: "https://example.com/cpi-data",
            imageURL: nil,
            sentiment: .neutral,
            suggestedStrategies: [
                NewsArticle.StrategySuggestion(
                    id: "sug-econ-1",
                    strategyId: "iron-condor",
                    strategyName: "Iron Condor",
                    rationale: "The ultimate sideways market strategy. Profits as long as the market stays within a defined range while time passes.",
                    timing: "Mid-morning after data release",
                    riskLevel: "Moderate",
                    expectedOutcome: "Consistent profit from time decay",
                    platformAvailability: ["Advanced Levels"],
                    confidence: 0.95
                ),
                NewsArticle.StrategySuggestion(
                    id: "sug-econ-2",
                    strategyId: "covered-call",
                    strategyName: "Covered Call",
                    rationale: "If you own index ETFs, selling calls in a sideways market generates income while you wait for the next catalyst.",
                    timing: "Weekly or monthly cycles",
                    riskLevel: "Low",
                    expectedOutcome: "Yield enhancement on existing holdings",
                    platformAvailability: ["All Platforms"],
                    confidence: 0.85
                )
            ],
            historicalContext: "Sideways markets following CPI data often persist until the next Federal Reserve meeting."
        )
    }
    
    private func createTechBullishCase(now: Date) -> NewsArticle {
        NewsArticle(
            id: "case-tech-001",
            headline: "Cloud Adoption Surges, Boosting Enterprise Tech Sector",
            summary: "New industry report shows cloud spending is accelerating. Major tech players are seeing increased demand, supporting a bullish trend.",
            content: "A comprehensive report from Gartner indicates that enterprise cloud spending is set to grow by 20% this year. This secular trend is providing a strong tailwind for major technology companies. For long-term bulls, this presents an opportunity to use capital-efficient strategies to participate in the growth.",
            source: NewsArticle.NewsSource(id: "zdnet", name: "ZDNet", logoURL: nil),
            publishedAt: now.addingTimeInterval(-21600),
            relatedSymbols: ["MSFT", "AMZN", "GOOGL"],
            category: .product,
            url: "https://example.com/cloud-growth",
            imageURL: nil,
            sentiment: .positive,
            suggestedStrategies: [
                NewsArticle.StrategySuggestion(
                    id: "sug-tech-1",
                    strategyId: "poor-mans-covered-call",
                    strategyName: "Poor Man's Covered Call",
                    rationale: "A capital-efficient way to play a long-term bullish trend. Buy a LEAPS call and sell short-term calls against it for income.",
                    timing: "Strategic entry on minor dips",
                    riskLevel: "Moderate",
                    expectedOutcome: "Long-term capital appreciation plus monthly income",
                    platformAvailability: ["Advanced Levels"],
                    confidence: 0.80
                ),
                NewsArticle.StrategySuggestion(
                    id: "sug-tech-2",
                    strategyId: "bull-call-spread",
                    strategyName: "Bull Call Spread",
                    rationale: "Participate in the upward trend with defined risk and lower capital requirement than buying shares.",
                    timing: "Monthly expirations",
                    riskLevel: "Moderate",
                    expectedOutcome: "Steady gains as trend continues",
                    platformAvailability: ["Intermediate Levels"],
                    confidence: 0.75
                )
            ],
            historicalContext: "Enterprise tech has historically outperformed the broader market during periods of accelerating cloud adoption."
        )
    }
}
