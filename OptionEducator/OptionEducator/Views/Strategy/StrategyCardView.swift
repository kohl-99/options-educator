import SwiftUI

/// A card view displaying summary information about an options strategy.
///
/// Shows the strategy name, category, complexity, and key characteristics
/// in a visually appealing card format.
struct StrategyCardView: View {
    // MARK: - Properties
    
    let strategy: OptionStrategy
    var isCompact: Bool = false
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: strategy.category.iconName)
                    .foregroundColor(categoryColor)
                
                Text(strategy.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                ComplexityBadge(level: strategy.complexityLevel)
            }
            
            // Description
            Text(strategy.shortDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(isCompact ? 2 : 3)
            
            // Details
            if !isCompact {
                HStack(spacing: 16) {
                    DetailItem(
                        icon: "target",
                        text: strategy.marketOutlook.rawValue,
                        color: .blue
                    )
                    
                    DetailItem(
                        icon: "chart.bar.fill",
                        text: strategy.riskProfile.riskLevel.rawValue.capitalized,
                        color: riskLevelColor
                    )
                    
                    if strategy.isMultiLeg {
                        DetailItem(
                            icon: "arrow.triangle.branch",
                            text: "\(strategy.components.count) legs",
                            color: .purple
                        )
                    }
                }
                .font(.caption)
                
                // Platform availability
                PlatformBadges(availability: strategy.platformAvailability)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
    
    // MARK: - Computed Properties
    
    private var categoryColor: Color {
        switch strategy.category {
        case .bullish: return .green
        case .bearish: return .red
        case .neutral: return .gray
        case .volatile: return .orange
        case .income: return .blue
        case .hedging: return .purple
        case .synthetic: return .indigo
        }
    }
    
    private var riskLevelColor: Color {
        switch strategy.riskProfile.riskLevel {
        case .low: return .green
        case .moderate: return .yellow
        case .high: return .orange
        case .veryHigh: return .red
        }
    }
}

// MARK: - Supporting Views

/// Badge showing complexity level
struct ComplexityBadge: View {
    let level: Int
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { index in
                Circle()
                    .fill(index <= level ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: 6, height: 6)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

/// Detail item with icon and text
struct DetailItem: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(text)
                .foregroundColor(.secondary)
        }
    }
}

/// Platform availability badges
struct PlatformBadges: View {
    let availability: [OptionStrategy.PlatformAvailability]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(availability.filter { $0.isAvailable }, id: \.platformId) { platform in
                    PlatformBadge(
                        name: platform.platformName,
                        level: platform.requiredLevel
                    )
                }
            }
        }
    }
}

/// Individual platform badge
struct PlatformBadge: View {
    let name: String
    let level: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(name)
                .font(.caption2)
                .fontWeight(.medium)
            Text(level)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(6)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        StrategyCardView(strategy: .sample)
        StrategyCardView(strategy: .sample, isCompact: true)
    }
    .padding()
}
