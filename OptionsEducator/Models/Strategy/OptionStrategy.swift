import Foundation

/// Represents a stock options trading strategy with comprehensive details.
///
/// This model encapsulates all information about an options strategy including
/// its structure, risk profile, platform availability, and educational content.
struct OptionStrategy: Identifiable, Codable, Hashable {
    // MARK: - Properties
    
    /// Unique identifier for the strategy
    let id: String
    
    /// Display name of the strategy
    let name: String
    
    /// Brief one-line description
    let shortDescription: String
    
    /// Detailed explanation of the strategy
    let longDescription: String
    
    /// Category classification
    let category: StrategyCategory
    
    /// Complexity level (1-5, where 1 is beginner and 5 is expert)
    let complexityLevel: Int
    
    /// Market outlook required for this strategy
    let marketOutlook: MarketOutlook
    
    /// Risk profile of the strategy
    let riskProfile: RiskProfile
    
    /// Components that make up this strategy
    let components: [StrategyComponent]
    
    /// Platform availability information
    let platformAvailability: [PlatformAvailability]
    
    /// Example scenarios demonstrating the strategy
    let examples: [StrategyExample]
    
    /// Key characteristics and considerations
    let keyPoints: [String]
    
    /// When to use this strategy
    let whenToUse: [String]
    
    /// When to avoid this strategy
    let whenToAvoid: [String]
    
    /// Related strategies
    let relatedStrategyIds: [String]
    
    /// Tags for search and filtering
    let tags: [String]
    
    // MARK: - Computed Properties
    
    /// Returns a user-friendly complexity description
    var complexityDescription: String {
        switch complexityLevel {
        case 1: return "Beginner"
        case 2: return "Intermediate"
        case 3: return "Advanced"
        case 4: return "Expert"
        case 5: return "Professional"
        default: return "Unknown"
        }
    }
    
    /// Indicates if this is a multi-leg strategy
    var isMultiLeg: Bool {
        return components.count > 1
    }
    
    /// Indicates if this strategy has unlimited risk
    var hasUnlimitedRisk: Bool {
        return riskProfile.maxLoss == nil
    }
    
    /// Indicates if this strategy has unlimited profit potential
    var hasUnlimitedProfit: Bool {
        return riskProfile.maxProfit == nil
    }
    
    // MARK: - Types
    
    /// Represents a component of an options strategy
    struct StrategyComponent: Codable, Hashable {
        /// Type of option (call or put)
        let optionType: OptionType
        
        /// Position direction (long or short)
        let position: Position
        
        /// Strike price relative to current price
        let strikeRelation: StrikeRelation
        
        /// Number of contracts
        let quantity: Int
        
        /// Expiration timeframe
        let expiration: String
        
        enum OptionType: String, Codable {
            case call
            case put
            case stock
        }
        
        enum Position: String, Codable {
            case long
            case short
        }
        
        enum StrikeRelation: String, Codable {
            case atTheMoney = "ATM"
            case inTheMoney = "ITM"
            case outOfTheMoney = "OTM"
            case custom
        }
    }
    
    /// Risk and reward profile of the strategy
    struct RiskProfile: Codable, Hashable {
        /// Maximum potential loss (nil means unlimited)
        let maxLoss: Decimal?
        
        /// Maximum potential profit (nil means unlimited)
        let maxProfit: Decimal?
        
        /// Breakeven point(s)
        let breakeven: [Decimal]
        
        /// Risk level description
        let riskLevel: RiskLevel
        
        /// Probability of profit (if calculable)
        let profitProbability: Double?
        
        enum RiskLevel: String, Codable {
            case low
            case moderate
            case high
            case veryHigh
        }
    }
    
    /// Platform availability for this strategy
    struct PlatformAvailability: Codable, Hashable {
        /// Platform identifier
        let platformId: String
        
        /// Platform name
        let platformName: String
        
        /// Required permission level
        let requiredLevel: String
        
        /// Whether this strategy is available
        let isAvailable: Bool
        
        /// Additional notes or requirements
        let notes: String?
    }
}

// MARK: - Supporting Types

/// Categories of options strategies
enum StrategyCategory: String, Codable, CaseIterable {
    case bullish = "Bullish"
    case bearish = "Bearish"
    case neutral = "Neutral"
    case volatile = "Volatile"
    case income = "Income"
    case hedging = "Hedging"
    case synthetic = "Synthetic"
    
    var description: String {
        return rawValue
    }
    
    var iconName: String {
        switch self {
        case .bullish: return "arrow.up.right.circle.fill"
        case .bearish: return "arrow.down.right.circle.fill"
        case .neutral: return "arrow.left.and.right.circle.fill"
        case .volatile: return "waveform.circle.fill"
        case .income: return "dollarsign.circle.fill"
        case .hedging: return "shield.fill"
        case .synthetic: return "gearshape.2.fill"
        }
    }
}

/// Market outlook required for a strategy
enum MarketOutlook: String, Codable {
    case stronglyBullish = "Strongly Bullish"
    case moderatelyBullish = "Moderately Bullish"
    case neutral = "Neutral"
    case moderatelyBearish = "Moderately Bearish"
    case stronglyBearish = "Strongly Bearish"
    case highVolatility = "High Volatility"
    case lowVolatility = "Low Volatility"
    
    var iconName: String {
        switch self {
        case .stronglyBullish, .moderatelyBullish:
            return "arrow.up.circle.fill"
        case .neutral:
            return "arrow.left.and.right.circle.fill"
        case .moderatelyBearish, .stronglyBearish:
            return "arrow.down.circle.fill"
        case .highVolatility:
            return "waveform.path.ecg"
        case .lowVolatility:
            return "minus.circle.fill"
        }
    }
}

/// Example scenario demonstrating a strategy
struct StrategyExample: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let scenario: String
    let setup: String
    let outcome: String
    let profitLoss: Decimal
    let lessonLearned: String
}

// MARK: - Extensions

extension OptionStrategy {
    /// Creates a sample strategy for previews and testing
    static var sample: OptionStrategy {
        OptionStrategy(
            id: "covered-call",
            name: "Covered Call",
            shortDescription: "Sell calls against owned stock for income",
            longDescription: "A covered call involves owning stock and selling call options against it. This strategy generates income from the option premium while potentially capping upside profit.",
            category: .income,
            complexityLevel: 1,
            marketOutlook: .neutral,
            riskProfile: RiskProfile(
                maxLoss: nil,
                maxProfit: 500,
                breakeven: [95.00],
                riskLevel: .moderate,
                profitProbability: 0.65
            ),
            components: [
                StrategyComponent(
                    optionType: .stock,
                    position: .long,
                    strikeRelation: .atTheMoney,
                    quantity: 100,
                    expiration: "Current"
                ),
                StrategyComponent(
                    optionType: .call,
                    position: .short,
                    strikeRelation: .outOfTheMoney,
                    quantity: 1,
                    expiration: "30 days"
                )
            ],
            platformAvailability: [
                PlatformAvailability(
                    platformId: "robinhood",
                    platformName: "Robinhood",
                    requiredLevel: "Level 2",
                    isAvailable: true,
                    notes: nil
                ),
                PlatformAvailability(
                    platformId: "fidelity",
                    platformName: "Fidelity",
                    requiredLevel: "Tier 1",
                    isAvailable: true,
                    notes: nil
                ),
                PlatformAvailability(
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
        )
    }
}
