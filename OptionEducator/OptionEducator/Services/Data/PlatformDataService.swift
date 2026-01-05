import Foundation
import Combine

/// Service responsible for managing trading platform data.
///
/// Loads platform information from bundled JSON files and provides
/// comparison and filtering capabilities.
@MainActor
final class PlatformDataService: ObservableObject {
    // MARK: - Published Properties
    
    /// All available platforms
    @Published private(set) var platforms: [TradingPlatform] = []
    
    /// Loading state
    @Published private(set) var isLoading = false
    
    /// Error state
    @Published private(set) var error: Error?
    
    // MARK: - Initialization
    
    init() {
        // Initialize with empty data
        // Data will be loaded via loadPlatforms()
    }
    
    // MARK: - Public Methods
    
    /// Loads platforms from bundled JSON file
    func loadPlatforms() async {
        isLoading = true
        error = nil
        
        do {
            // In a real app, this would load from a bundled JSON file
            // For now, we'll create sample data based on our research
            platforms = createSamplePlatforms()
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
    
    /// Finds a platform by its ID
    /// - Parameter id: The platform identifier
    /// - Returns: The platform if found, nil otherwise
    func platform(withId id: String) -> TradingPlatform? {
        return platforms.first { $0.id == id }
    }
    
    /// Checks which platforms support a specific strategy
    /// - Parameter strategyId: The strategy identifier
    /// - Returns: Array of platforms that support the strategy
    func platformsSupporting(strategy strategyId: String) -> [TradingPlatform] {
        return platforms.filter { $0.supportsStrategy(strategyId) }
    }
    
    /// Returns platforms sorted by overall rating
    var platformsByRating: [TradingPlatform] {
        return platforms.sorted { $0.ratings.overall > $1.ratings.overall }
    }
    
    /// Returns platforms with commission-free trading
    var commissionFreePlatforms: [TradingPlatform] {
        return platforms.filter { $0.isCommissionFree }
    }
    
    // MARK: - Private Methods
    
    /// Creates sample platforms based on research data
    private func createSamplePlatforms() -> [TradingPlatform] {
        return [
            createRobinhoodPlatform(),
            createFidelityPlatform(),
            createInteractiveBrokersPlatform()
        ]
    }
    
    private func createRobinhoodPlatform() -> TradingPlatform {
        return TradingPlatform(
            id: "robinhood",
            name: "Robinhood",
            description: "Commission-free trading platform with user-friendly mobile app, ideal for beginners.",
            websiteURL: "https://robinhood.com",
            logoImageName: "robinhood_logo",
            permissionLevels: [
                TradingPlatform.PermissionLevel(
                    id: "level-2",
                    name: "Level 2",
                    displayName: "Basic Options Strategies",
                    description: "Access to basic options strategies including covered calls and cash-secured puts",
                    allowedStrategies: [
                        "long-call",
                        "long-put",
                        "covered-call",
                        "cash-secured-put"
                    ],
                    requirements: TradingPlatform.PermissionLevel.LevelRequirements(
                        minimumExperience: "Some options knowledge",
                        minimumNetWorth: nil,
                        minimumAccountValue: 2000,
                        requiresMargin: false,
                        additionalCriteria: ["Instant or Gold account"]
                    ),
                    restrictions: ["No naked options", "No complex spreads"]
                ),
                TradingPlatform.PermissionLevel(
                    id: "level-3",
                    name: "Level 3",
                    displayName: "Advanced Options Strategies",
                    description: "Access to spreads and advanced multi-leg strategies",
                    allowedStrategies: [
                        "long-call",
                        "long-put",
                        "covered-call",
                        "cash-secured-put",
                        "vertical-spread",
                        "iron-condor",
                        "straddle",
                        "strangle"
                    ],
                    requirements: TradingPlatform.PermissionLevel.LevelRequirements(
                        minimumExperience: "Significant options experience",
                        minimumNetWorth: nil,
                        minimumAccountValue: 2000,
                        requiresMargin: true,
                        additionalCriteria: ["Instant or Gold account", "Options trading experience"]
                    ),
                    restrictions: ["No naked options"]
                )
            ],
            features: [
                "Commission-free options trading",
                "User-friendly mobile app",
                "Options strategy builder",
                "Real-time market data",
                "Instant deposits"
            ],
            pros: [
                "No commission fees",
                "Simple, intuitive interface",
                "Great for beginners",
                "Excellent mobile experience",
                "Low barrier to entry"
            ],
            cons: [
                "Limited advanced strategies",
                "Only 2 permission levels",
                "No phone support",
                "Limited research tools",
                "Options not available in Cash accounts"
            ],
            feeStructure: TradingPlatform.FeeStructure(
                optionsCommission: 0,
                regulatoryFees: 0.02,
                assignmentFee: 0,
                notes: "Regulatory fees only"
            ),
            requirements: TradingPlatform.AccountRequirements(
                minimumDeposit: nil,
                minimumAge: 18,
                identificationRequired: true,
                taxInformationRequired: true,
                additionalRequirements: ["U.S. resident", "Valid SSN"]
            ),
            supportedAccountTypes: [
                .individual,
                .joint,
                .ira,
                .rothIRA,
                .margin,
                .cash
            ],
            ratings: TradingPlatform.PlatformRatings(
                overall: 4.2,
                easeOfUse: 4.8,
                education: 3.5,
                support: 3.0,
                features: 3.8,
                mobileApp: 4.7
            )
        )
    }
    
    private func createFidelityPlatform() -> TradingPlatform {
        return TradingPlatform(
            id: "fidelity",
            name: "Fidelity",
            description: "Full-service broker with comprehensive research tools and educational resources.",
            websiteURL: "https://www.fidelity.com",
            logoImageName: "fidelity_logo",
            permissionLevels: [
                TradingPlatform.PermissionLevel(
                    id: "tier-1",
                    name: "Tier 1",
                    displayName: "Basic Options",
                    description: "Entry-level options trading with covered strategies",
                    allowedStrategies: [
                        "long-call",
                        "long-put",
                        "covered-call",
                        "cash-secured-put",
                        "straddle",
                        "strangle"
                    ],
                    requirements: TradingPlatform.PermissionLevel.LevelRequirements(
                        minimumExperience: "Basic options knowledge",
                        minimumNetWorth: nil,
                        minimumAccountValue: nil,
                        requiresMargin: false,
                        additionalCriteria: nil
                    ),
                    restrictions: nil
                ),
                TradingPlatform.PermissionLevel(
                    id: "tier-2",
                    name: "Tier 2",
                    displayName: "Intermediate Spreads",
                    description: "Access to spread strategies with defined risk",
                    allowedStrategies: [
                        "long-call",
                        "long-put",
                        "covered-call",
                        "cash-secured-put",
                        "straddle",
                        "strangle",
                        "vertical-spread",
                        "iron-condor",
                        "butterfly-spread"
                    ],
                    requirements: TradingPlatform.PermissionLevel.LevelRequirements(
                        minimumExperience: "Intermediate options knowledge",
                        minimumNetWorth: nil,
                        minimumAccountValue: nil,
                        requiresMargin: true,
                        additionalCriteria: ["Margin account required"]
                    ),
                    restrictions: nil
                ),
                TradingPlatform.PermissionLevel(
                    id: "tier-3",
                    name: "Tier 3",
                    displayName: "Advanced Strategies",
                    description: "Full access including naked options",
                    allowedStrategies: [
                        "long-call",
                        "long-put",
                        "covered-call",
                        "cash-secured-put",
                        "straddle",
                        "strangle",
                        "vertical-spread",
                        "iron-condor",
                        "butterfly-spread",
                        "naked-call",
                        "naked-put",
                        "short-straddle"
                    ],
                    requirements: TradingPlatform.PermissionLevel.LevelRequirements(
                        minimumExperience: "Extensive options experience",
                        minimumNetWorth: 100000,
                        minimumAccountValue: 25000,
                        requiresMargin: true,
                        additionalCriteria: ["Significant net worth", "High income"]
                    ),
                    restrictions: nil
                )
            ],
            features: [
                "Comprehensive research tools",
                "Active Trader Pro platform",
                "Extensive educational resources",
                "24/7 customer support",
                "IRA options trading"
            ],
            pros: [
                "Three-tier system for progression",
                "Excellent research and education",
                "Professional trading platforms",
                "Great customer support",
                "IRA options available"
            ],
            cons: [
                "$0.65 per contract commission",
                "More complex interface",
                "Margin required for Tier 2+",
                "Higher barriers for advanced tiers"
            ],
            feeStructure: TradingPlatform.FeeStructure(
                optionsCommission: 0.65,
                regulatoryFees: 0.02,
                assignmentFee: 0,
                notes: "$0.65 per contract plus regulatory fees"
            ),
            requirements: TradingPlatform.AccountRequirements(
                minimumDeposit: nil,
                minimumAge: 18,
                identificationRequired: true,
                taxInformationRequired: true,
                additionalRequirements: ["U.S. resident"]
            ),
            supportedAccountTypes: [
                .individual,
                .joint,
                .ira,
                .rothIRA,
                .margin,
                .cash,
                .trust,
                .corporate
            ],
            ratings: TradingPlatform.PlatformRatings(
                overall: 4.6,
                easeOfUse: 3.8,
                education: 4.9,
                support: 4.7,
                features: 4.8,
                mobileApp: 4.2
            )
        )
    }
    
    private func createInteractiveBrokersPlatform() -> TradingPlatform {
        return TradingPlatform(
            id: "interactive-brokers",
            name: "Interactive Brokers",
            description: "Professional-grade platform with global market access and advanced tools.",
            websiteURL: "https://www.interactivebrokers.com",
            logoImageName: "ibkr_logo",
            permissionLevels: [
                TradingPlatform.PermissionLevel(
                    id: "level-1",
                    name: "Level 1",
                    displayName: "Covered Strategies",
                    description: "Basic covered options strategies",
                    allowedStrategies: [
                        "covered-call",
                        "cash-secured-put"
                    ],
                    requirements: TradingPlatform.PermissionLevel.LevelRequirements(
                        minimumExperience: "Basic knowledge",
                        minimumNetWorth: nil,
                        minimumAccountValue: nil,
                        requiresMargin: false,
                        additionalCriteria: nil
                    ),
                    restrictions: nil
                ),
                TradingPlatform.PermissionLevel(
                    id: "level-2",
                    name: "Level 2",
                    displayName: "Long Options & Spreads",
                    description: "Buying options and spread strategies",
                    allowedStrategies: [
                        "covered-call",
                        "cash-secured-put",
                        "long-call",
                        "long-put",
                        "vertical-spread",
                        "butterfly-spread",
                        "iron-condor"
                    ],
                    requirements: TradingPlatform.PermissionLevel.LevelRequirements(
                        minimumExperience: "Intermediate knowledge",
                        minimumNetWorth: nil,
                        minimumAccountValue: 2000,
                        requiresMargin: false,
                        additionalCriteria: nil
                    ),
                    restrictions: nil
                ),
                TradingPlatform.PermissionLevel(
                    id: "level-3",
                    name: "Level 3",
                    displayName: "Uncovered Strategies",
                    description: "Advanced strategies including naked options",
                    allowedStrategies: [
                        "covered-call",
                        "cash-secured-put",
                        "long-call",
                        "long-put",
                        "vertical-spread",
                        "butterfly-spread",
                        "iron-condor",
                        "naked-call",
                        "naked-put",
                        "straddle",
                        "strangle"
                    ],
                    requirements: TradingPlatform.PermissionLevel.LevelRequirements(
                        minimumExperience: "Advanced knowledge",
                        minimumNetWorth: 50000,
                        minimumAccountValue: 10000,
                        requiresMargin: true,
                        additionalCriteria: ["Margin account", "Risk acknowledgment"]
                    ),
                    restrictions: nil
                ),
                TradingPlatform.PermissionLevel(
                    id: "level-4",
                    name: "Level 4",
                    displayName: "Professional Strategies",
                    description: "Full access to all options strategies",
                    allowedStrategies: [
                        "covered-call",
                        "cash-secured-put",
                        "long-call",
                        "long-put",
                        "vertical-spread",
                        "butterfly-spread",
                        "iron-condor",
                        "naked-call",
                        "naked-put",
                        "straddle",
                        "strangle",
                        "ratio-spread",
                        "calendar-spread"
                    ],
                    requirements: TradingPlatform.PermissionLevel.LevelRequirements(
                        minimumExperience: "Professional experience",
                        minimumNetWorth: 100000,
                        minimumAccountValue: 25000,
                        requiresMargin: true,
                        additionalCriteria: ["Portfolio margin eligible", "Extensive experience"]
                    ),
                    restrictions: nil
                )
            ],
            features: [
                "Global market access",
                "Professional trading tools",
                "Low commission rates",
                "Advanced order types",
                "Portfolio margin available"
            ],
            pros: [
                "Four-level progression system",
                "Professional-grade platform",
                "Global market access",
                "Competitive pricing",
                "Advanced tools and analytics"
            ],
            cons: [
                "Complex interface for beginners",
                "Inactivity fees may apply",
                "Steep learning curve",
                "Higher requirements for advanced levels"
            ],
            feeStructure: TradingPlatform.FeeStructure(
                optionsCommission: 0.65,
                regulatoryFees: 0.02,
                assignmentFee: 0,
                notes: "$0.65 per contract, volume discounts available"
            ),
            requirements: TradingPlatform.AccountRequirements(
                minimumDeposit: nil,
                minimumAge: 18,
                identificationRequired: true,
                taxInformationRequired: true,
                additionalRequirements: ["Valid identification"]
            ),
            supportedAccountTypes: [
                .individual,
                .joint,
                .ira,
                .rothIRA,
                .margin,
                .cash,
                .trust,
                .corporate
            ],
            ratings: TradingPlatform.PlatformRatings(
                overall: 4.7,
                easeOfUse: 3.5,
                education: 4.2,
                support: 4.0,
                features: 4.9,
                mobileApp: 4.1
            )
        )
    }
}
