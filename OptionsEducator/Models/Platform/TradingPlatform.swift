import Foundation

/// Represents a trading platform that supports options trading.
///
/// This model contains comprehensive information about a platform's
/// options trading capabilities, permission levels, and features.
struct TradingPlatform: Identifiable, Codable, Hashable {
    // MARK: - Properties
    
    /// Unique identifier for the platform
    let id: String
    
    /// Display name of the platform
    let name: String
    
    /// Brief description of the platform
    let description: String
    
    /// Website URL
    let websiteURL: String
    
    /// Logo image name
    let logoImageName: String
    
    /// Permission levels offered by this platform
    let permissionLevels: [PermissionLevel]
    
    /// Key features of the platform
    let features: [String]
    
    /// Advantages of using this platform
    let pros: [String]
    
    /// Disadvantages or limitations
    let cons: [String]
    
    /// Fee structure
    let feeStructure: FeeStructure
    
    /// Account requirements
    let requirements: AccountRequirements
    
    /// Supported account types
    let supportedAccountTypes: [AccountType]
    
    /// Platform ratings
    let ratings: PlatformRatings
    
    // MARK: - Computed Properties
    
    /// Returns the total number of permission levels
    var levelCount: Int {
        return permissionLevels.count
    }
    
    /// Returns the most advanced level name
    var highestLevelName: String {
        return permissionLevels.last?.name ?? "Unknown"
    }
    
    /// Indicates if the platform offers commission-free trading
    var isCommissionFree: Bool {
        return feeStructure.optionsCommission == 0
    }
    
    // MARK: - Types
    
    /// Represents a permission level within a platform
    struct PermissionLevel: Identifiable, Codable, Hashable {
        let id: String
        let name: String
        let displayName: String
        let description: String
        let allowedStrategies: [String]
        let requirements: LevelRequirements
        let restrictions: [String]?
        
        struct LevelRequirements: Codable, Hashable {
            let minimumExperience: String?
            let minimumNetWorth: Decimal?
            let minimumAccountValue: Decimal?
            let requiresMargin: Bool
            let additionalCriteria: [String]?
        }
    }
    
    /// Fee structure for the platform
    struct FeeStructure: Codable, Hashable {
        /// Commission per options contract
        let optionsCommission: Decimal
        
        /// Regulatory fees per contract
        let regulatoryFees: Decimal?
        
        /// Assignment/exercise fees
        let assignmentFee: Decimal?
        
        /// Additional notes about fees
        let notes: String?
        
        /// Computed total cost per contract
        var totalPerContract: Decimal {
            let regulatory = regulatoryFees ?? 0
            let assignment = assignmentFee ?? 0
            return optionsCommission + regulatory + assignment
        }
    }
    
    /// Account requirements for options trading
    struct AccountRequirements: Codable, Hashable {
        let minimumDeposit: Decimal?
        let minimumAge: Int
        let identificationRequired: Bool
        let taxInformationRequired: Bool
        let additionalRequirements: [String]?
    }
    
    /// Platform ratings across different categories
    struct PlatformRatings: Codable, Hashable {
        /// Overall rating (0-5)
        let overall: Double
        
        /// Ease of use rating (0-5)
        let easeOfUse: Double
        
        /// Educational resources rating (0-5)
        let education: Double
        
        /// Customer support rating (0-5)
        let support: Double
        
        /// Platform features rating (0-5)
        let features: Double
        
        /// Mobile app rating (0-5)
        let mobileApp: Double
    }
    
    /// Types of trading accounts supported
    enum AccountType: String, Codable, CaseIterable {
        case individual = "Individual"
        case joint = "Joint"
        case ira = "IRA"
        case rothIRA = "Roth IRA"
        case margin = "Margin"
        case cash = "Cash"
        case trust = "Trust"
        case corporate = "Corporate"
        
        var description: String {
            return rawValue
        }
    }
}

// MARK: - Extensions

extension TradingPlatform {
    /// Checks if a specific strategy is available at any level
    /// - Parameter strategyId: The strategy identifier to check
    /// - Returns: True if the strategy is available
    func supportsStrategy(_ strategyId: String) -> Bool {
        return permissionLevels.contains { level in
            level.allowedStrategies.contains(strategyId)
        }
    }
    
    /// Finds the minimum level required for a specific strategy
    /// - Parameter strategyId: The strategy identifier
    /// - Returns: The permission level, or nil if not supported
    func minimumLevelFor(strategy strategyId: String) -> PermissionLevel? {
        return permissionLevels.first { level in
            level.allowedStrategies.contains(strategyId)
        }
    }
    
    /// Returns all strategies available at a specific level
    /// - Parameter levelId: The level identifier
    /// - Returns: Array of strategy identifiers
    func strategiesAt(level levelId: String) -> [String] {
        return permissionLevels.first { $0.id == levelId }?.allowedStrategies ?? []
    }
    
    /// Creates a sample platform for previews and testing
    static var sample: TradingPlatform {
        TradingPlatform(
            id: "robinhood",
            name: "Robinhood",
            description: "Commission-free trading platform with user-friendly mobile app",
            websiteURL: "https://robinhood.com",
            logoImageName: "robinhood_logo",
            permissionLevels: [
                PermissionLevel(
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
                    requirements: PermissionLevel.LevelRequirements(
                        minimumExperience: "Some options knowledge",
                        minimumNetWorth: nil,
                        minimumAccountValue: 2000,
                        requiresMargin: false,
                        additionalCriteria: ["Instant or Gold account"]
                    ),
                    restrictions: ["No naked options", "No complex spreads"]
                ),
                PermissionLevel(
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
                    requirements: PermissionLevel.LevelRequirements(
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
            feeStructure: FeeStructure(
                optionsCommission: 0,
                regulatoryFees: 0.02,
                assignmentFee: 0,
                notes: "Regulatory fees only"
            ),
            requirements: AccountRequirements(
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
            ratings: PlatformRatings(
                overall: 4.2,
                easeOfUse: 4.8,
                education: 3.5,
                support: 3.0,
                features: 3.8,
                mobileApp: 4.7
            )
        )
    }
}

// MARK: - Comparable Conformance

extension TradingPlatform: Comparable {
    static func < (lhs: TradingPlatform, rhs: TradingPlatform) -> Bool {
        return lhs.name < rhs.name
    }
}
