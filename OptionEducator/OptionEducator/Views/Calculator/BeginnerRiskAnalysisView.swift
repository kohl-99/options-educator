import SwiftUI

/// A beginner-friendly breakdown of the risk and reward profile for an options strategy.
struct BeginnerRiskAnalysisView: View {
    let maxProfit: Double
    let maxLoss: Double
    let breakevens: [Double]
    let currentPrice: Double
    let strategyName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Beginner's Risk Analysis")
                .font(.headline)
                .padding(.bottom, 4)
            
            // 1. Maximum Reward
            AnalysisCard(
                title: "What's the most I can earn?",
                content: maxProfitDescription,
                icon: "arrow.up.right.circle.fill",
                color: .green
            )
            
            // 2. Maximum Risk
            AnalysisCard(
                title: "What's the most I can lose?",
                content: maxLossDescription,
                icon: "exclamationmark.triangle.fill",
                color: .red
            )
            
            // 3. Breakeven Logic
            AnalysisCard(
                title: "When do I start making money?",
                content: breakevenDescription,
                icon: "checkmark.circle.fill",
                color: .orange
            )
            
            // 4. Summary Tip
            VStack(alignment: .leading, spacing: 8) {
                Text("💡 Pro Tip for Beginners")
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text("Always check the 'Max Loss' before entering a trade. In options, you can lose 100% of your investment very quickly if the stock doesn't move in your favor.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.blue.opacity(0.05))
            .cornerRadius(12)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Descriptions
    
    private var maxProfitDescription: String {
        if maxProfit > 1000000 {
            return "Your profit potential is unlimited! The higher the stock price goes, the more money you make."
        } else if maxProfit <= 0 {
            return "This strategy has no profit potential at these levels. Check your strikes."
        } else {
            return "The most you can earn is $\(String(format: "%.2f", maxProfit)). This happens if the stock price moves exactly where you predicted."
        }
    }
    
    private var maxLossDescription: String {
        if maxLoss > 1000000 {
            return "Warning: Your risk is unlimited! If the stock moves against you, you could lose significantly more than your initial investment."
        } else {
            return "The most you can lose is $\(String(format: "%.2f", maxLoss)). This is your 'defined risk'—you cannot lose more than this amount."
        }
    }
    
    private var breakevenDescription: String {
        if breakevens.isEmpty {
            return "Based on current numbers, this trade is not profitable at any price. Adjust your strikes or entry price."
        } else if breakevens.count == 1 {
            let be = breakevens[0]
            let direction = be > currentPrice ? "above" : "below"
            return "You start making a profit when the stock price moves \(direction) $\(String(format: "%.2f", be))."
        } else {
            let sorted = breakevens.sorted()
            return "You are profitable as long as the stock price stays between $\(String(format: "%.2f", sorted[0])) and $\(String(format: "%.2f", sorted[1]))."
        }
    }
}

struct AnalysisCard: View {
    let title: String
    let content: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text(content)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
