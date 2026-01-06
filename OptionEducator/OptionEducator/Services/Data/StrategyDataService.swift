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
        // Initialize with data
        Task {
            await loadStrategies()
        }
    }
    
    // MARK: - Public Methods
    
    /// Loads strategies from bundled JSON file
    func loadStrategies() async {
        isLoading = true
        error = nil
        
        do {
            // In a real app, this would load from a bundled JSON file
            // For now, we'll create expanded sample data
            strategies = createExpandedStrategies()
            filteredStrategies = strategies
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
    
    /// Filters strategies based on provided criteria
    func filterStrategies(
        category: StrategyCategory? = nil,
        complexity: Int? = nil,
        outlook: MarketOutlook? = nil,
        searchText: String = ""
    ) {
        var filtered = strategies
        
        if let category = category {
            filtered = filtered.filter { $0.category == category }
        }
        
        if let complexity = complexity {
            filtered = filtered.filter { $0.complexityLevel == complexity }
        }
        
        if let outlook = outlook {
            filtered = filtered.filter { $0.marketOutlook == outlook }
        }
        
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
    func strategy(withId id: String) -> OptionStrategy? {
        return strategies.first { $0.id == id }
    }
    
    // MARK: - Private Methods
    
    /// Creates an expanded list of options strategies
    private func createExpandedStrategies() -> [OptionStrategy] {
        return [
            // 1. Covered Call
            createCoveredCall(),
            // 2. Cash-Secured Put
            createCashSecuredPut(),
            // 3. Long Call
            createLongCall(),
            // 4. Long Put
            createLongPut(),
            // 5. Bull Call Spread
            createBullCallSpread(),
            // 6. Bear Put Spread
            createBearPutSpread(),
            // 7. Iron Condor
            createIronCondor(),
            // 8. Straddle
            createStraddle(),
            // 9. Strangle
            createStrangle(),
            // 10. Butterfly Spread
            createButterflySpread(),
            // 11. Calendar Spread
            createCalendarSpread(),
            // 12. Protective Put
            createProtectivePut(),
            // 13. Iron Butterfly
            createIronButterfly(),
            // 14. Poor Man's Covered Call
            createPoorMansCoveredCall()
        ]
    }
    
    // MARK: - Strategy Creation Helpers
    
    private func createCoveredCall() -> OptionStrategy {
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
                OptionStrategy.StrategyComponent(optionType: .stock, position: .long, strikeRelation: .atTheMoney, quantity: 100, expiration: "Current"),
                OptionStrategy.StrategyComponent(optionType: .call, position: .short, strikeRelation: .outOfTheMoney, quantity: 1, expiration: "30 days")
            ],
            platformAvailability: [
                OptionStrategy.PlatformAvailability(platformId: "robinhood", platformName: "Robinhood", requiredLevel: "Level 2", isAvailable: true, notes: nil),
                OptionStrategy.PlatformAvailability(platformId: "fidelity", platformName: "Fidelity", requiredLevel: "Tier 1", isAvailable: true, notes: nil),
                OptionStrategy.PlatformAvailability(platformId: "interactive-brokers", platformName: "Interactive Brokers", requiredLevel: "Level 1", isAvailable: true, notes: nil)
            ],
            examples: [
                StrategyExample(id: "ex-cc-1", title: "Income Generation", scenario: "Own 100 shares of XYZ at $50", setup: "Sell $55 Call for $2.00", outcome: "Stock stays at $52, keep $200 premium", profitLoss: 200, lessonLearned: "Effective for generating yield on stagnant positions")
            ],
            keyPoints: ["Generates income", "Caps upside", "Provides minor downside protection"],
            whenToUse: ["Neutral to slightly bullish outlook", "Want to generate income"],
            whenToAvoid: ["Strongly bullish outlook", "High volatility expected"],
            relatedStrategyIds: ["poor-mans-covered-call", "protective-collar"],
            tags: ["income", "beginner", "conservative"]
        )
    }
    
    private func createCashSecuredPut() -> OptionStrategy {
        OptionStrategy(
            id: "cash-secured-put",
            name: "Cash-Secured Put",
            shortDescription: "Sell puts with cash to buy stock at a discount",
            longDescription: "Selling a put option while keeping enough cash to buy the stock if assigned. This strategy generates income and allows you to potentially acquire stock at a lower price than current market value.",
            category: .income,
            complexityLevel: 1,
            marketOutlook: .neutral,
            riskProfile: OptionStrategy.RiskProfile(
                maxLoss: 4800,
                maxProfit: 200,
                breakeven: [48.00],
                riskLevel: .moderate,
                profitProbability: 0.70
            ),
            components: [
                OptionStrategy.StrategyComponent(optionType: .put, position: .short, strikeRelation: .outOfTheMoney, quantity: 1, expiration: "30 days")
            ],
            platformAvailability: [
                OptionStrategy.PlatformAvailability(platformId: "robinhood", platformName: "Robinhood", requiredLevel: "Level 2", isAvailable: true, notes: nil),
                OptionStrategy.PlatformAvailability(platformId: "fidelity", platformName: "Fidelity", requiredLevel: "Tier 1", isAvailable: true, notes: nil),
                OptionStrategy.PlatformAvailability(platformId: "interactive-brokers", platformName: "Interactive Brokers", requiredLevel: "Level 1", isAvailable: true, notes: nil)
            ],
            examples: [
                StrategyExample(id: "ex-csp-1", title: "Buying the Dip", scenario: "Stock at $50, want to buy at $45", setup: "Sell $45 Put for $1.50", outcome: "Stock drops to $44, assigned at $45 (net cost $43.50)", profitLoss: -150, lessonLearned: "Great way to enter positions at a discount")
            ],
            keyPoints: ["Generates income", "Obligation to buy stock", "Bullish to neutral"],
            whenToUse: ["Want to buy stock at lower price", "Neutral to bullish outlook"],
            whenToAvoid: ["Strongly bearish outlook", "Don't want to own the stock"],
            relatedStrategyIds: ["covered-call", "bull-put-spread"],
            tags: ["income", "beginner", "entry-strategy"]
        )
    }
    
    private func createLongCall() -> OptionStrategy {
        OptionStrategy(
            id: "long-call",
            name: "Long Call",
            shortDescription: "Buy call for unlimited bullish potential",
            longDescription: "Buying a call option gives you the right to buy stock at a specific price. It offers unlimited profit potential with limited risk (the premium paid).",
            category: .bullish,
            complexityLevel: 1,
            marketOutlook: .stronglyBullish,
            riskProfile: OptionStrategy.RiskProfile(maxLoss: 300, maxProfit: nil, breakeven: [103.00], riskLevel: .moderate, profitProbability: 0.35),
            components: [
                OptionStrategy.StrategyComponent(optionType: .call, position: .long, strikeRelation: .atTheMoney, quantity: 1, expiration: "30 days")
            ],
            platformAvailability: [
                OptionStrategy.PlatformAvailability(platformId: "robinhood", platformName: "Robinhood", requiredLevel: "Level 2", isAvailable: true, notes: nil),
                OptionStrategy.PlatformAvailability(platformId: "fidelity", platformName: "Fidelity", requiredLevel: "Tier 1", isAvailable: true, notes: nil),
                OptionStrategy.PlatformAvailability(platformId: "interactive-brokers", platformName: "Interactive Brokers", requiredLevel: "Level 1", isAvailable: true, notes: nil)
            ],
            examples: [],
            keyPoints: ["Unlimited profit", "Limited risk", "Leverage"],
            whenToUse: ["Strongly bullish outlook", "Expect high volatility"],
            whenToAvoid: ["Neutral outlook", "High time decay expected"],
            relatedStrategyIds: ["bull-call-spread", "long-straddle"],
            tags: ["bullish", "beginner", "leverage"]
        )
    }
    
    private func createLongPut() -> OptionStrategy {
        OptionStrategy(
            id: "long-put",
            name: "Long Put",
            shortDescription: "Buy put to profit from stock price drops",
            longDescription: "Buying a put option gives you the right to sell stock at a specific price. It's a bearish strategy that profits as the stock price falls.",
            category: .bearish,
            complexityLevel: 1,
            marketOutlook: .stronglyBearish,
            riskProfile: OptionStrategy.RiskProfile(maxLoss: 250, maxProfit: 9750, breakeven: [97.50], riskLevel: .moderate, profitProbability: 0.35),
            components: [
                OptionStrategy.StrategyComponent(optionType: .put, position: .long, strikeRelation: .atTheMoney, quantity: 1, expiration: "30 days")
            ],
            platformAvailability: [
                OptionStrategy.PlatformAvailability(platformId: "robinhood", platformName: "Robinhood", requiredLevel: "Level 2", isAvailable: true, notes: nil),
                OptionStrategy.PlatformAvailability(platformId: "fidelity", platformName: "Fidelity", requiredLevel: "Tier 1", isAvailable: true, notes: nil),
                OptionStrategy.PlatformAvailability(platformId: "interactive-brokers", platformName: "Interactive Brokers", requiredLevel: "Level 1", isAvailable: true, notes: nil)
            ],
            examples: [],
            keyPoints: ["Profits from downside", "Limited risk", "Alternative to shorting"],
            whenToUse: ["Strongly bearish outlook", "Hedging a long position"],
            whenToAvoid: ["Bullish outlook", "Low volatility expected"],
            relatedStrategyIds: ["bear-put-spread", "protective-put"],
            tags: ["bearish", "beginner", "hedging"]
        )
    }
    
    private func createBullCallSpread() -> OptionStrategy {
        OptionStrategy(
            id: "bull-call-spread",
            name: "Bull Call Spread",
            shortDescription: "Bullish strategy with lower cost and capped profit",
            longDescription: "Buying one call and selling another call at a higher strike price. This reduces the cost of the trade but also caps the maximum profit.",
            category: .bullish,
            complexityLevel: 2,
            marketOutlook: .moderatelyBullish,
            riskProfile: OptionStrategy.RiskProfile(maxLoss: 200, maxProfit: 300, breakeven: [102.00], riskLevel: .moderate, profitProbability: 0.50),
            components: [
                OptionStrategy.StrategyComponent(optionType: .call, position: .long, strikeRelation: .atTheMoney, quantity: 1, expiration: "30 days"),
                OptionStrategy.StrategyComponent(optionType: .call, position: .short, strikeRelation: .outOfTheMoney, quantity: 1, expiration: "30 days")
            ],
            platformAvailability: [
                OptionStrategy.PlatformAvailability(platformId: "robinhood", platformName: "Robinhood", requiredLevel: "Level 3", isAvailable: true, notes: nil),
                OptionStrategy.PlatformAvailability(platformId: "fidelity", platformName: "Fidelity", requiredLevel: "Tier 2", isAvailable: true, notes: nil),
                OptionStrategy.PlatformAvailability(platformId: "interactive-brokers", platformName: "Interactive Brokers", requiredLevel: "Level 2", isAvailable: true, notes: nil)
            ],
            examples: [],
            keyPoints: ["Lower cost than long call", "Capped profit", "Defined risk"],
            whenToUse: ["Moderately bullish outlook", "Want to reduce cost of long call"],
            whenToAvoid: ["Strongly bullish outlook", "Very low volatility"],
            relatedStrategyIds: ["long-call", "bull-put-spread"],
            tags: ["bullish", "intermediate", "spread"]
        )
    }
    
    private func createBearPutSpread() -> OptionStrategy {
        OptionStrategy(
            id: "bear-put-spread",
            name: "Bear Put Spread",
            shortDescription: "Bearish strategy with lower cost and capped profit",
            longDescription: "Buying one put and selling another put at a lower strike price. This reduces the cost of the trade but also caps the maximum profit.",
            category: .bearish,
            complexityLevel: 2,
            marketOutlook: .moderatelyBearish,
            riskProfile: OptionStrategy.RiskProfile(maxLoss: 200, maxProfit: 300, breakeven: [98.00], riskLevel: .moderate, profitProbability: 0.50),
            components: [
                OptionStrategy.StrategyComponent(optionType: .put, position: .long, strikeRelation: .atTheMoney, quantity: 1, expiration: "30 days"),
                OptionStrategy.StrategyComponent(optionType: .put, position: .short, strikeRelation: .outOfTheMoney, quantity: 1, expiration: "30 days")
            ],
            platformAvailability: [
                OptionStrategy.PlatformAvailability(platformId: "robinhood", platformName: "Robinhood", requiredLevel: "Level 3", isAvailable: true, notes: nil),
                OptionStrategy.PlatformAvailability(platformId: "fidelity", platformName: "Fidelity", requiredLevel: "Tier 2", isAvailable: true, notes: nil),
                OptionStrategy.PlatformAvailability(platformId: "interactive-brokers", platformName: "Interactive Brokers", requiredLevel: "Level 2", isAvailable: true, notes: nil)
            ],
            examples: [],
            keyPoints: ["Lower cost than long put", "Capped profit", "Defined risk"],
            whenToUse: ["Moderately bearish outlook", "Want to reduce cost of long put"],
            whenToAvoid: ["Strongly bearish outlook", "Very low volatility"],
            relatedStrategyIds: ["long-put", "bear-call-spread"],
            tags: ["bearish", "intermediate", "spread"]
        )
    }
    
    private func createIronCondor() -> OptionStrategy {
        OptionStrategy(
            id: "iron-condor",
            name: "Iron Condor",
            shortDescription: "Profit from stock staying in a range",
            longDescription: "Selling a bear call spread and a bull put spread simultaneously. Profits if the stock price stays between the two short strikes at expiration.",
            category: .neutral,
            complexityLevel: 3,
            marketOutlook: .neutral,
            riskProfile: OptionStrategy.RiskProfile(maxLoss: 350, maxProfit: 150, breakeven: [93.50, 106.50], riskLevel: .moderate, profitProbability: 0.75),
            components: [
                OptionStrategy.StrategyComponent(optionType: .put, position: .long, strikeRelation: .outOfTheMoney, quantity: 1, expiration: "30 days"),
                OptionStrategy.StrategyComponent(optionType: .put, position: .short, strikeRelation: .outOfTheMoney, quantity: 1, expiration: "30 days"),
                OptionStrategy.StrategyComponent(optionType: .call, position: .short, strikeRelation: .outOfTheMoney, quantity: 1, expiration: "30 days"),
                OptionStrategy.StrategyComponent(optionType: .call, position: .long, strikeRelation: .outOfTheMoney, quantity: 1, expiration: "30 days")
            ],
            platformAvailability: [
                OptionStrategy.PlatformAvailability(platformId: "robinhood", platformName: "Robinhood", requiredLevel: "Level 3", isAvailable: true, notes: nil),
                OptionStrategy.PlatformAvailability(platformId: "fidelity", platformName: "Fidelity", requiredLevel: "Tier 2", isAvailable: true, notes: nil),
                OptionStrategy.PlatformAvailability(platformId: "interactive-brokers", platformName: "Interactive Brokers", requiredLevel: "Level 2", isAvailable: true, notes: nil)
            ],
            examples: [],
            keyPoints: ["High probability", "Defined risk", "Profits from time decay"],
            whenToUse: ["Neutral outlook", "High implied volatility expected to drop"],
            whenToAvoid: ["Strong directional move expected", "Earnings announcements"],
            relatedStrategyIds: ["iron-butterfly", "strangle"],
            tags: ["neutral", "advanced", "income"]
        )
    }
    
    private func createStraddle() -> OptionStrategy {
        OptionStrategy(
            id: "straddle",
            name: "Long Straddle",
            shortDescription: "Profit from a large move in either direction",
            longDescription: "Buying a call and a put at the same strike price and expiration. Profits if the stock makes a significant move up or down.",
            category: .volatile,
            complexityLevel: 2,
            marketOutlook: .highVolatility,
            riskProfile: OptionStrategy.RiskProfile(maxLoss: 500, maxProfit: nil, breakeven: [95.00, 105.00], riskLevel: .high, profitProbability: 0.30),
            components: [
                OptionStrategy.StrategyComponent(optionType: .call, position: .long, strikeRelation: .atTheMoney, quantity: 1, expiration: "30 days"),
                OptionStrategy.StrategyComponent(optionType: .put, position: .long, strikeRelation: .atTheMoney, quantity: 1, expiration: "30 days")
            ],
            platformAvailability: [
                OptionStrategy.PlatformAvailability(platformId: "robinhood", platformName: "Robinhood", requiredLevel: "Level 3", isAvailable: true, notes: nil),
                OptionStrategy.PlatformAvailability(platformId: "fidelity", platformName: "Fidelity", requiredLevel: "Tier 1", isAvailable: true, notes: nil),
                OptionStrategy.PlatformAvailability(platformId: "interactive-brokers", platformName: "Interactive Brokers", requiredLevel: "Level 1", isAvailable: true, notes: nil)
            ],
            examples: [],
            keyPoints: ["Direction neutral", "Unlimited profit", "High cost"],
            whenToUse: ["Expect large move but unsure of direction", "Before major news events"],
            whenToAvoid: ["Neutral outlook", "High implied volatility"],
            relatedStrategyIds: ["strangle", "iron-condor"],
            tags: ["volatile", "intermediate", "earnings"]
        )
    }
    
    private func createStrangle() -> OptionStrategy {
        OptionStrategy(
            id: "strangle",
            name: "Long Strangle",
            shortDescription: "Cheaper alternative to straddle for large moves",
            longDescription: "Buying an out-of-the-money call and an out-of-the-money put. Profits if the stock makes a very large move in either direction.",
            category: .volatile,
            complexityLevel: 2,
            marketOutlook: .highVolatility,
            riskProfile: OptionStrategy.RiskProfile(maxLoss: 200, maxProfit: nil, breakeven: [93.00, 107.00], riskLevel: .high, profitProbability: 0.25),
            components: [
                OptionStrategy.StrategyComponent(optionType: .call, position: .long, strikeRelation: .outOfTheMoney, quantity: 1, expiration: "30 days"),
                OptionStrategy.StrategyComponent(optionType: .put, position: .long, strikeRelation: .outOfTheMoney, quantity: 1, expiration: "30 days")
            ],
            platformAvailability: [
                OptionStrategy.PlatformAvailability(platformId: "robinhood", platformName: "Robinhood", requiredLevel: "Level 3", isAvailable: true, notes: nil),
                OptionStrategy.PlatformAvailability(platformId: "fidelity", platformName: "Fidelity", requiredLevel: "Tier 1", isAvailable: true, notes: nil),
                OptionStrategy.PlatformAvailability(platformId: "interactive-brokers", platformName: "Interactive Brokers", requiredLevel: "Level 1", isAvailable: true, notes: nil)
            ],
            examples: [],
            keyPoints: ["Lower cost than straddle", "Requires larger move", "Limited risk"],
            whenToUse: ["Expect extreme move", "Low implied volatility"],
            whenToAvoid: ["Small moves expected", "High time decay"],
            relatedStrategyIds: ["straddle", "iron-condor"],
            tags: ["volatile", "intermediate", "speculation"]
        )
    }
    
    private func createButterflySpread() -> OptionStrategy {
        OptionStrategy(
            id: "butterfly-spread",
            name: "Butterfly Spread",
            shortDescription: "Neutral strategy with very high risk/reward ratio",
            longDescription: "Combining a bull spread and a bear spread with a shared middle strike. Profits if the stock is exactly at the middle strike at expiration.",
            category: .neutral,
            complexityLevel: 3,
            marketOutlook: .neutral,
            riskProfile: OptionStrategy.RiskProfile(maxLoss: 50, maxProfit: 450, breakeven: [95.50, 104.50], riskLevel: .moderate, profitProbability: 0.20),
            components: [
                OptionStrategy.StrategyComponent(optionType: .call, position: .long, strikeRelation: .outOfTheMoney, quantity: 1, expiration: "30 days"),
                OptionStrategy.StrategyComponent(optionType: .call, position: .short, strikeRelation: .atTheMoney, quantity: 2, expiration: "30 days"),
                OptionStrategy.StrategyComponent(optionType: .call, position: .long, strikeRelation: .inTheMoney, quantity: 1, expiration: "30 days")
            ],
            platformAvailability: [
                OptionStrategy.PlatformAvailability(platformId: "robinhood", platformName: "Robinhood", requiredLevel: "Level 3", isAvailable: true, notes: nil),
                OptionStrategy.PlatformAvailability(platformId: "fidelity", platformName: "Fidelity", requiredLevel: "Tier 2", isAvailable: true, notes: nil),
                OptionStrategy.PlatformAvailability(platformId: "interactive-brokers", platformName: "Interactive Brokers", requiredLevel: "Level 2", isAvailable: true, notes: nil)
            ],
            examples: [],
            keyPoints: ["Low cost", "High potential return", "Narrow profit window"],
            whenToUse: ["Very neutral outlook", "Low volatility expected"],
            whenToAvoid: ["Directional move expected", "High volatility"],
            relatedStrategyIds: ["iron-butterfly", "iron-condor"],
            tags: ["neutral", "advanced", "low-cost"]
        )
    }
    
    private func createCalendarSpread() -> OptionStrategy {
        OptionStrategy(
            id: "calendar-spread",
            name: "Calendar Spread",
            shortDescription: "Profit from time decay differences between expirations",
            longDescription: "Selling a short-term option and buying a long-term option at the same strike. Profits from the faster time decay of the short-term option.",
            category: .neutral,
            complexityLevel: 3,
            marketOutlook: .neutral,
            riskProfile: OptionStrategy.RiskProfile(maxLoss: 150, maxProfit: 200, breakeven: [97.00, 103.00], riskLevel: .moderate, profitProbability: 0.55),
            components: [
                OptionStrategy.StrategyComponent(optionType: .call, position: .short, strikeRelation: .atTheMoney, quantity: 1, expiration: "30 days"),
                OptionStrategy.StrategyComponent(optionType: .call, position: .long, strikeRelation: .atTheMoney, quantity: 1, expiration: "60 days")
            ],
            platformAvailability: [
                OptionStrategy.PlatformAvailability(platformId: "robinhood", platformName: "Robinhood", requiredLevel: "Not Available", isAvailable: false, notes: "Robinhood does not support multi-expiration spreads"),
                OptionStrategy.PlatformAvailability(platformId: "fidelity", platformName: "Fidelity", requiredLevel: "Tier 2", isAvailable: true, notes: nil),
                OptionStrategy.PlatformAvailability(platformId: "interactive-brokers", platformName: "Interactive Brokers", requiredLevel: "Level 2", isAvailable: true, notes: nil)
            ],
            examples: [],
            keyPoints: ["Profits from time decay", "Neutral to slightly bullish/bearish", "Defined risk"],
            whenToUse: ["Neutral outlook", "Expect low volatility in short term"],
            whenToAvoid: ["Large move expected soon", "High volatility"],
            relatedStrategyIds: ["diagonal-spread", "poor-mans-covered-call"],
            tags: ["neutral", "advanced", "time-decay"]
        )
    }
    
    private func createProtectivePut() -> OptionStrategy {
        OptionStrategy(
            id: "protective-put",
            name: "Protective Put",
            shortDescription: "Insurance for your stock positions",
            longDescription: "Buying a put option for a stock you already own. This acts as insurance, capping your maximum potential loss if the stock price crashes.",
            category: .hedging,
            complexityLevel: 1,
            marketOutlook: .moderatelyBullish,
            riskProfile: OptionStrategy.RiskProfile(maxLoss: 500, maxProfit: nil, breakeven: [105.00], riskLevel: .low, profitProbability: 0.60),
            components: [
                OptionStrategy.StrategyComponent(optionType: .stock, position: .long, strikeRelation: .atTheMoney, quantity: 100, expiration: "Current"),
                OptionStrategy.StrategyComponent(optionType: .put, position: .long, strikeRelation: .atTheMoney, quantity: 1, expiration: "30 days")
            ],
            platformAvailability: [
                OptionStrategy.PlatformAvailability(platformId: "robinhood", platformName: "Robinhood", requiredLevel: "Level 2", isAvailable: true, notes: nil),
                OptionStrategy.PlatformAvailability(platformId: "fidelity", platformName: "Fidelity", requiredLevel: "Tier 1", isAvailable: true, notes: nil),
                OptionStrategy.PlatformAvailability(platformId: "interactive-brokers", platformName: "Interactive Brokers", requiredLevel: "Level 1", isAvailable: true, notes: nil)
            ],
            examples: [],
            keyPoints: ["Caps downside risk", "Maintains upside potential", "Costs premium (insurance)"],
            whenToUse: ["Own stock and fear short-term drop", "During high market uncertainty"],
            whenToAvoid: ["No downside risk expected", "Premium is too expensive"],
            relatedStrategyIds: ["long-put", "protective-collar"],
            tags: ["hedging", "beginner", "insurance"]
        )
    }
    
    private func createIronButterfly() -> OptionStrategy {
        OptionStrategy(
            id: "iron-butterfly",
            name: "Iron Butterfly",
            shortDescription: "Aggressive neutral strategy with high credit",
            longDescription: "A combination of an at-the-money credit spread and an out-of-the-money debit spread. It's like an iron condor but with the short strikes at the same price.",
            category: .neutral,
            complexityLevel: 3,
            marketOutlook: .neutral,
            riskProfile: OptionStrategy.RiskProfile(maxLoss: 200, maxProfit: 300, breakeven: [97.00, 103.00], riskLevel: .moderate, profitProbability: 0.45),
            components: [
                OptionStrategy.StrategyComponent(optionType: .put, position: .long, strikeRelation: .outOfTheMoney, quantity: 1, expiration: "30 days"),
                OptionStrategy.StrategyComponent(optionType: .put, position: .short, strikeRelation: .atTheMoney, quantity: 1, expiration: "30 days"),
                OptionStrategy.StrategyComponent(optionType: .call, position: .short, strikeRelation: .atTheMoney, quantity: 1, expiration: "30 days"),
                OptionStrategy.StrategyComponent(optionType: .call, position: .long, strikeRelation: .outOfTheMoney, quantity: 1, expiration: "30 days")
            ],
            platformAvailability: [
                OptionStrategy.PlatformAvailability(platformId: "robinhood", platformName: "Robinhood", requiredLevel: "Level 3", isAvailable: true, notes: nil),
                OptionStrategy.PlatformAvailability(platformId: "fidelity", platformName: "Fidelity", requiredLevel: "Tier 2", isAvailable: true, notes: nil),
                OptionStrategy.PlatformAvailability(platformId: "interactive-brokers", platformName: "Interactive Brokers", requiredLevel: "Level 2", isAvailable: true, notes: nil)
            ],
            examples: [],
            keyPoints: ["High credit received", "Narrow profit zone", "Defined risk"],
            whenToUse: ["Expect stock to stay very close to strike", "High volatility expected to crush"],
            whenToAvoid: ["Directional move expected", "Low implied volatility"],
            relatedStrategyIds: ["iron-condor", "butterfly-spread"],
            tags: ["neutral", "advanced", "high-reward"]
        )
    }
    
    private func createPoorMansCoveredCall() -> OptionStrategy {
        OptionStrategy(
            id: "poor-mans-covered-call",
            name: "Poor Man's Covered Call",
            shortDescription: "Synthetic covered call using a long-term call",
            longDescription: "Buying a deep in-the-money long-term call (LEAPS) and selling short-term out-of-the-money calls against it. Mimics a covered call with much less capital.",
            category: .income,
            complexityLevel: 3,
            marketOutlook: .moderatelyBullish,
            riskProfile: OptionStrategy.RiskProfile(maxLoss: 1500, maxProfit: 300, breakeven: [85.00], riskLevel: .moderate, profitProbability: 0.60),
            components: [
                OptionStrategy.StrategyComponent(optionType: .call, position: .long, strikeRelation: .inTheMoney, quantity: 1, expiration: "1-2 years"),
                OptionStrategy.StrategyComponent(optionType: .call, position: .short, strikeRelation: .outOfTheMoney, quantity: 1, expiration: "30 days")
            ],
            platformAvailability: [
                OptionStrategy.PlatformAvailability(platformId: "robinhood", platformName: "Robinhood", requiredLevel: "Not Available", isAvailable: false, notes: "Robinhood does not support diagonal spreads"),
                OptionStrategy.PlatformAvailability(platformId: "fidelity", platformName: "Fidelity", requiredLevel: "Tier 2", isAvailable: true, notes: nil),
                OptionStrategy.PlatformAvailability(platformId: "interactive-brokers", platformName: "Interactive Brokers", requiredLevel: "Level 2", isAvailable: true, notes: nil)
            ],
            examples: [],
            keyPoints: ["Capital efficient", "Generates income", "Bullish bias"],
            whenToUse: ["Bullish long-term outlook", "Want to generate income with less capital"],
            whenToAvoid: ["Bearish outlook", "High volatility in short term"],
            relatedStrategyIds: ["covered-call", "calendar-spread"],
            tags: ["income", "advanced", "leverage"]
        )
    }
}
