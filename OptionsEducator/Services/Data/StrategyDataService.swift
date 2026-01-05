import Foundation
import Combine

/// Service responsible for managing options strategy data.
///
/// Loads strategies from bundled JSON files and provides
/// filtering, searching, and sorting capabilities.
@MainActor
final class StrategyDataService: ObservableObject {
    // MARK: - Published Properties
    
    /// All available strategies
    @Published private(set) var strategies: [OptionStrategy] = []
    
    /// Filtered strategies based on current filters
    @Published private(set) var filteredStrategies: [OptionStrategy] = []
    
    /// Loading state
    @Published private(set) var isLoading = false
    
    /// Error state
    @Published private(set) var error: Error?
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        // Initialize with empty data
        // Data will be loaded via loadStrategies()
    }
    
    // MARK: - Public Methods
    
    /// Loads strategies from bundled JSON file
    func loadStrategies() async {
        isLoading = true
        error = nil
        
        do {
            // In a real app, this would load from a bundled JSON file
            // For now, we'll create sample data
            strategies = createSampleStrategies()
            filteredStrategies = strategies
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
    
    /// Filters strategies based on provided criteria
    /// - Parameters:
    ///   - category: Optional category filter
    ///   - complexity: Optional complexity level filter
    ///   - outlook: Optional market outlook filter
    ///   - searchText: Optional search text
    func filterStrategies(
        category: StrategyCategory? = nil,
        complexity: Int? = nil,
        outlook: MarketOutlook? = nil,
        searchText: String = ""
    ) {
        var filtered = strategies
        
        // Apply category filter
        if let category = category {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Apply complexity filter
        if let complexity = complexity {
            filtered = filtered.filter { $0.complexityLevel == complexity }
        }
        
        // Apply outlook filter
        if let outlook = outlook {
            filtered = filtered.filter { $0.marketOutlook == outlook }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { strategy in
                strategy.name.localizedCaseInsensitiveContains(searchText) ||
                strategy.shortDescription.localizedCaseInsensitiveContains(searchText) ||
                strategy.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        filteredStrategies = filtered
    }
    
    /// Finds a strategy by its ID
    /// - Parameter id: The strategy identifier
    /// - Returns: The strategy if found, nil otherwise
    func strategy(withId id: String) -> OptionStrategy? {
        return strategies.first { $0.id == id }
    }
    
    /// Returns strategies for a specific category
    /// - Parameter category: The category to filter by
    /// - Returns: Array of strategies in that category
    func strategies(in category: StrategyCategory) -> [OptionStrategy] {
        return strategies.filter { $0.category == category }
    }
    
    /// Returns strategies suitable for beginners (complexity 1-2)
    var beginnerStrategies: [OptionStrategy] {
        return strategies.filter { $0.complexityLevel <= 2 }
    }
    
    /// Returns strategies suitable for advanced traders (complexity 4-5)
    var advancedStrategies: [OptionStrategy] {
        return strategies.filter { $0.complexityLevel >= 4 }
    }
    
    /// Resets all filters
    func resetFilters() {
        filteredStrategies = strategies
    }
    
    // MARK: - Private Methods
    
    /// Creates sample strategies for demonstration
    private func createSampleStrategies() -> [OptionStrategy] {
        return [
            // Covered Call
            OptionStrategy(
                id: "covered-call",
                name: "Covered Call",
                shortDescription: "Sell calls against owned stock for income",
                longDescription: "A covered call involves owning stock and selling call options against it. This strategy generates income from the option premium while potentially capping upside profit. It's ideal for neutral to slightly bullish market conditions.",
                category: .income,
                complexityLevel: 1,
                marketOutlook: .neutral,
                riskProfile: OptionStrategy.RiskProfile(
                    maxLoss: nil,
                    maxProfit: 500,
                    breakeven: [95.00],
                    riskLevel: .moderate,
                    profitProbability: 0.65
                ),
                components: [
                    OptionStrategy.StrategyComponent(
                        optionType: .stock,
                        position: .long,
                        strikeRelation: .atTheMoney,
                        quantity: 100,
                        expiration: "Current"
                    ),
                    OptionStrategy.StrategyComponent(
                        optionType: .call,
                        position: .short,
                        strikeRelation: .outOfTheMoney,
                        quantity: 1,
                        expiration: "30 days"
                    )
                ],
                platformAvailability: [
                    OptionStrategy.PlatformAvailability(
                        platformId: "robinhood",
                        platformName: "Robinhood",
                        requiredLevel: "Level 2",
                        isAvailable: true,
                        notes: nil
                    ),
                    OptionStrategy.PlatformAvailability(
                        platformId: "fidelity",
                        platformName: "Fidelity",
                        requiredLevel: "Tier 1",
                        isAvailable: true,
                        notes: nil
                    ),
                    OptionStrategy.PlatformAvailability(
                        platformId: "interactive-brokers",
                        platformName: "Interactive Brokers",
                        requiredLevel: "Level 1",
                        isAvailable: true,
                        notes: nil
                    )
                ],
                examples: [
                    StrategyExample(
                        id: "example-1",
                        title: "Tech Stock Covered Call",
                        scenario: "Own 100 shares of AAPL at $150",
                        setup: "Sell 1 AAPL $155 call for $2.00 premium",
                        outcome: "Stock stays below $155, keep premium",
                        profitLoss: 200,
                        lessonLearned: "Covered calls work best in sideways markets"
                    )
                ],
                keyPoints: [
                    "Generates income from owned stock",
                    "Limits upside potential",
                    "Provides downside protection equal to premium received"
                ],
                whenToUse: [
                    "You own stock and expect sideways movement",
                    "You want to generate additional income",
                    "You're willing to sell stock at higher price"
                ],
                whenToAvoid: [
                    "You expect strong upward movement",
                    "You don't own the underlying stock",
                    "You need maximum upside potential"
                ],
                relatedStrategyIds: ["cash-secured-put", "protective-collar"],
                tags: ["income", "beginner", "covered", "conservative"]
            ),
            
            // Long Call
            OptionStrategy(
                id: "long-call",
                name: "Long Call",
                shortDescription: "Buy call option for bullish speculation",
                longDescription: "Buying a call option gives you the right to purchase stock at a specific price. This strategy offers unlimited profit potential with limited risk, making it ideal for bullish market outlooks.",
                category: .bullish,
                complexityLevel: 1,
                marketOutlook: .stronglyBullish,
                riskProfile: OptionStrategy.RiskProfile(
                    maxLoss: 300,
                    maxProfit: nil,
                    breakeven: [103.00],
                    riskLevel: .moderate,
                    profitProbability: 0.40
                ),
                components: [
                    OptionStrategy.StrategyComponent(
                        optionType: .call,
                        position: .long,
                        strikeRelation: .atTheMoney,
                        quantity: 1,
                        expiration: "30 days"
                    )
                ],
                platformAvailability: [
                    OptionStrategy.PlatformAvailability(
                        platformId: "robinhood",
                        platformName: "Robinhood",
                        requiredLevel: "Level 2",
                        isAvailable: true,
                        notes: nil
                    ),
                    OptionStrategy.PlatformAvailability(
                        platformId: "fidelity",
                        platformName: "Fidelity",
                        requiredLevel: "Tier 1",
                        isAvailable: true,
                        notes: nil
                    ),
                    OptionStrategy.PlatformAvailability(
                        platformId: "interactive-brokers",
                        platformName: "Interactive Brokers",
                        requiredLevel: "Level 1",
                        isAvailable: true,
                        notes: nil
                    )
                ],
                examples: [],
                keyPoints: [
                    "Unlimited profit potential",
                    "Limited risk to premium paid",
                    "Leveraged exposure to stock movement"
                ],
                whenToUse: [
                    "You expect significant upward price movement",
                    "You want leveraged exposure with limited risk",
                    "Volatility is expected to increase"
                ],
                whenToAvoid: [
                    "Stock is expected to trade sideways",
                    "Time decay will erode value quickly",
                    "Implied volatility is very high"
                ],
                relatedStrategyIds: ["bull-call-spread", "long-put"],
                tags: ["bullish", "beginner", "directional", "leveraged"]
            ),
            
            // Iron Condor
            OptionStrategy(
                id: "iron-condor",
                name: "Iron Condor",
                shortDescription: "Profit from low volatility with defined risk",
                longDescription: "An iron condor combines a bull put spread and a bear call spread. This strategy profits when the underlying stays within a specific range, making it ideal for low volatility environments.",
                category: .neutral,
                complexityLevel: 3,
                marketOutlook: .lowVolatility,
                riskProfile: OptionStrategy.RiskProfile(
                    maxLoss: 400,
                    maxProfit: 100,
                    breakeven: [96.00, 104.00],
                    riskLevel: .moderate,
                    profitProbability: 0.70
                ),
                components: [
                    OptionStrategy.StrategyComponent(
                        optionType: .put,
                        position: .short,
                        strikeRelation: .outOfTheMoney,
                        quantity: 1,
                        expiration: "30 days"
                    ),
                    OptionStrategy.StrategyComponent(
                        optionType: .put,
                        position: .long,
                        strikeRelation: .outOfTheMoney,
                        quantity: 1,
                        expiration: "30 days"
                    ),
                    OptionStrategy.StrategyComponent(
                        optionType: .call,
                        position: .short,
                        strikeRelation: .outOfTheMoney,
                        quantity: 1,
                        expiration: "30 days"
                    ),
                    OptionStrategy.StrategyComponent(
                        optionType: .call,
                        position: .long,
                        strikeRelation: .outOfTheMoney,
                        quantity: 1,
                        expiration: "30 days"
                    )
                ],
                platformAvailability: [
                    OptionStrategy.PlatformAvailability(
                        platformId: "robinhood",
                        platformName: "Robinhood",
                        requiredLevel: "Level 3",
                        isAvailable: true,
                        notes: nil
                    ),
                    OptionStrategy.PlatformAvailability(
                        platformId: "fidelity",
                        platformName: "Fidelity",
                        requiredLevel: "Tier 2",
                        isAvailable: true,
                        notes: nil
                    ),
                    OptionStrategy.PlatformAvailability(
                        platformId: "interactive-brokers",
                        platformName: "Interactive Brokers",
                        requiredLevel: "Level 2",
                        isAvailable: true,
                        notes: nil
                    )
                ],
                examples: [],
                keyPoints: [
                    "Defined risk and reward",
                    "Profits from time decay",
                    "Works best in low volatility"
                ],
                whenToUse: [
                    "You expect the stock to trade in a range",
                    "Implied volatility is high (sell premium)",
                    "You want defined risk"
                ],
                whenToAvoid: [
                    "You expect large price movements",
                    "Earnings or major events are upcoming",
                    "Volatility is expected to increase"
                ],
                relatedStrategyIds: ["butterfly-spread", "straddle"],
                tags: ["neutral", "advanced", "income", "range-bound"]
            )
        ]
    }
}
