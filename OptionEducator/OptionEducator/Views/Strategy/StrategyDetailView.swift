import SwiftUI

/// Detailed view for a specific options trading strategy.
///
/// Displays comprehensive information including description, components,
/// risk profile, platform availability, examples, and educational content.
struct StrategyDetailView: View {
    // MARK: - Environment
    
    @EnvironmentObject private var strategyService: StrategyDataService
    @EnvironmentObject private var coordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Properties
    
    let strategyId: String
    
    // MARK: - State
    
    @State private var strategy: OptionStrategy?
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if let strategy = strategy {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header Section
                        headerSection(strategy)
                        
                        // Try Strategy Button
                        Button(action: {
                            coordinator.tryStrategy(strategy)
                        }) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                Text("Try This Strategy")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
                        Divider()
                        
                        // Description
                        descriptionSection(strategy)
                        
                        // Components
                        if !strategy.components.isEmpty {
                            componentsSection(strategy)
                        }
                        
                        // Risk Profile
                        riskProfileSection(strategy)
                        
                        // Platform Availability
                        platformSection(strategy)
                        
                        // When to Use / Avoid
                        usageSection(strategy)
                        
                        // Key Points
                        if !strategy.keyPoints.isEmpty {
                            keyPointsSection(strategy)
                        }
                        
                        // Examples
                        if !strategy.examples.isEmpty {
                            examplesSection(strategy)
                        }
                        
                        // Related Strategies
                        if !strategy.relatedStrategyIds.isEmpty {
                            relatedStrategiesSection(strategy)
                        }
                    }
                    .padding()
                }
                .navigationTitle(strategy.name)
                .navigationBarTitleDisplayMode(.large)
            } else {
                ContentUnavailableView(
                    "Strategy Not Found",
                    systemImage: "exclamationmark.triangle",
                    description: Text("The requested strategy could not be loaded.")
                )
            }
        }
        .onAppear {
            loadStrategy()
        }
    }
    
    // MARK: - View Components
    
    private func headerSection(_ strategy: OptionStrategy) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: strategy.category.iconName)
                    .font(.title2)
                    .foregroundColor(categoryColor(strategy.category))
                
                Text(strategy.category.rawValue)
                    .font(.headline)
                    .foregroundColor(categoryColor(strategy.category))
                
                Spacer()
                
                ComplexityBadge(level: strategy.complexityLevel)
            }
            
            Text(strategy.shortDescription)
                .font(.title3)
                .foregroundColor(.secondary)
        }
    }
    
    private func descriptionSection(_ strategy: OptionStrategy) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Description")
                .font(.headline)
            
            Text(strategy.longDescription)
                .font(.body)
        }
    }
    
    private func componentsSection(_ strategy: OptionStrategy) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Strategy Components")
                .font(.headline)
            
            VStack(spacing: 8) {
                ForEach(Array(strategy.components.enumerated()), id: \.offset) { index, component in
                    ComponentRow(component: component, number: index + 1)
                }
            }
        }
    }
    
    private func riskProfileSection(_ strategy: OptionStrategy) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Risk Profile")
                .font(.headline)
            
            VStack(spacing: 12) {
                RiskDetailRow(
                    label: "Risk Level",
                    value: strategy.riskProfile.riskLevel.rawValue.capitalized,
                    color: riskLevelColor(strategy.riskProfile.riskLevel)
                )
                
                RiskDetailRow(
                    label: "Max Loss",
                    value: strategy.riskProfile.maxLoss != nil ? String(format: "$%.2f", NSDecimalNumber(decimal: strategy.riskProfile.maxLoss!).doubleValue) : "Unlimited",
                    color: strategy.hasUnlimitedRisk ? .red : .orange
                )
                
                RiskDetailRow(
                    label: "Max Profit",
                    value: strategy.riskProfile.maxProfit != nil ? String(format: "$%.2f", NSDecimalNumber(decimal: strategy.riskProfile.maxProfit!).doubleValue) : "Unlimited",
                    color: strategy.hasUnlimitedProfit ? .green : .blue
                )
                
                if !strategy.riskProfile.breakeven.isEmpty {
                    RiskDetailRow(
                        label: "Break-Even",
                        value: strategy.riskProfile.breakeven.map { String(format: "$%.2f", NSDecimalNumber(decimal: $0).doubleValue) }.joined(separator: ", "),
                        color: .gray
                    )
                }
                
                if let probability = strategy.riskProfile.profitProbability {
                    RiskDetailRow(
                        label: "Profit Probability",
                        value: String(format: "%.0f%%", probability * 100),
                        color: .blue
                    )
                }
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
        }
    }
    
    private func platformSection(_ strategy: OptionStrategy) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Platform Availability")
                .font(.headline)
            
            VStack(spacing: 8) {
                ForEach(strategy.platformAvailability, id: \.platformId) { platform in
                    PlatformAvailabilityRow(platform: platform)
                }
            }
        }
    }
    
    private func usageSection(_ strategy: OptionStrategy) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // When to Use
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("When to Use")
                        .font(.headline)
                }
                
                ForEach(strategy.whenToUse, id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                        Text(item)
                            .font(.subheadline)
                    }
                }
            }
            .padding()
            .background(Color.green.opacity(0.05))
            .cornerRadius(12)
            
            // When to Avoid
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                    Text("When to Avoid")
                        .font(.headline)
                }
                
                ForEach(strategy.whenToAvoid, id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                        Text(item)
                            .font(.subheadline)
                    }
                }
            }
            .padding()
            .background(Color.red.opacity(0.05))
            .cornerRadius(12)
        }
    }
    
    private func keyPointsSection(_ strategy: OptionStrategy) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Key Points")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(strategy.keyPoints, id: \.self) { point in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        Text(point)
                            .font(.subheadline)
                    }
                }
            }
            .padding()
            .background(Color.yellow.opacity(0.05))
            .cornerRadius(12)
        }
    }
    
    private func examplesSection(_ strategy: OptionStrategy) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Examples")
                .font(.headline)
            
            ForEach(strategy.examples) { example in
                ExampleCard(example: example)
            }
        }
    }
    
    private func relatedStrategiesSection(_ strategy: OptionStrategy) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Related Strategies")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(strategy.relatedStrategyIds, id: \.self) { relatedId in
                        if let relatedStrategy = strategyService.strategy(withId: relatedId) {
                            RelatedStrategyCard(strategy: relatedStrategy)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func loadStrategy() {
        strategy = strategyService.strategy(withId: strategyId)
    }
    
    private func categoryColor(_ category: StrategyCategory) -> Color {
        switch category {
        case .bullish: return .green
        case .bearish: return .red
        case .neutral: return .gray
        case .volatile: return .orange
        case .income: return .blue
        case .hedging: return .purple
        case .synthetic: return .indigo
        }
    }
    
    private func riskLevelColor(_ level: OptionStrategy.RiskProfile.RiskLevel) -> Color {
        switch level {
        case .low: return .green
        case .moderate: return .yellow
        case .high: return .orange
        case .veryHigh: return .red
        }
    }
}

// MARK: - Supporting Views

struct ComponentRow: View {
    let component: OptionStrategy.StrategyComponent
    let number: Int
    
    var body: some View {
        HStack {
            Text("\(number).")
                .font(.headline)
                .foregroundColor(.blue)
                .frame(width: 30, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(component.position.rawValue.capitalized)
                        .fontWeight(.semibold)
                    Text(component.optionType.rawValue.capitalized)
                }
                .font(.subheadline)
                
                HStack {
                    Text("Strike: \(component.strikeRelation.rawValue)")
                    Text("•")
                    Text("Qty: \(component.quantity)")
                    Text("•")
                    Text("Exp: \(component.expiration)")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(8)
    }
}

struct RiskDetailRow: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

struct PlatformAvailabilityRow: View {
    let platform: OptionStrategy.PlatformAvailability
    
    var body: some View {
        HStack {
            Image(systemName: platform.isAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(platform.isAvailable ? .green : .red)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(platform.platformName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(platform.requiredLevel)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

struct ExampleCard: View {
    let example: StrategyExample
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(example.title)
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                ExampleRow(label: "Scenario", value: example.scenario)
                ExampleRow(label: "Setup", value: example.setup)
                ExampleRow(label: "Outcome", value: example.outcome)
                
                HStack {
                    Text("P/L:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Text(String(format: "$%.2f", NSDecimalNumber(decimal: example.profitLoss).doubleValue))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(NSDecimalNumber(decimal: example.profitLoss).doubleValue >= 0 ? .green : .red)
                }
            }
            
            Text("💡 \(example.lessonLearned)")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 4)
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
    }
}

struct ExampleRow: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
        }
    }
}

struct RelatedStrategyCard: View {
    let strategy: OptionStrategy
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: strategy.category.iconName)
                    .font(.caption)
                Spacer()
                ComplexityBadge(level: strategy.complexityLevel)
            }
            
            Text(strategy.name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(2)
            
            Text(strategy.shortDescription)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .frame(width: 180)
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        StrategyDetailView(strategyId: "covered-call")
            .environmentObject(StrategyDataService())
    }
}
