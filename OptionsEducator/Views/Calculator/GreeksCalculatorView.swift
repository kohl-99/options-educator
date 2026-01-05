import SwiftUI

/// Calculator for options Greeks (Delta, Gamma, Theta, Vega, Rho).
///
/// Helps users understand how different factors affect option prices
/// and manage risk in their options positions.
struct GreeksCalculatorView: View {
    // MARK: - State
    
    @State private var optionType: OptionType = .call
    @State private var stockPrice: String = "100"
    @State private var strikePrice: String = "100"
    @State private var daysToExpiration: String = "30"
    @State private var volatility: String = "30"
    @State private var riskFreeRate: String = "5"
    
    @State private var greeks: Greeks?
    @State private var showResults = false
    
    // MARK: - Types
    
    enum OptionType: String, CaseIterable {
        case call = "Call"
        case put = "Put"
    }
    
    struct Greeks {
        let delta: Double
        let gamma: Double
        let theta: Double
        let vega: Double
        let rho: Double
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Option type selector
                Picker("Option Type", selection: $optionType) {
                    ForEach(OptionType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Input fields
                VStack(spacing: 16) {
                    InputField(
                        title: "Stock Price",
                        value: $stockPrice,
                        placeholder: "100.00",
                        suffix: "$"
                    )
                    
                    InputField(
                        title: "Strike Price",
                        value: $strikePrice,
                        placeholder: "100.00",
                        suffix: "$"
                    )
                    
                    InputField(
                        title: "Days to Expiration",
                        value: $daysToExpiration,
                        placeholder: "30",
                        suffix: "days"
                    )
                    
                    InputField(
                        title: "Implied Volatility",
                        value: $volatility,
                        placeholder: "30",
                        suffix: "%"
                    )
                    
                    InputField(
                        title: "Risk-Free Rate",
                        value: $riskFreeRate,
                        placeholder: "5.0",
                        suffix: "%"
                    )
                }
                .padding(.horizontal)
                
                // Calculate button
                Button(action: calculate) {
                    Text("Calculate Greeks")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Results
                if showResults, let greeks = greeks {
                    GreeksResultsView(greeks: greeks, optionType: optionType)
                }
                
                // Educational content
                GreeksEducationalSection()
            }
            .padding(.vertical)
        }
    }
    
    // MARK: - Methods
    
    private func calculate() {
        guard let S = Double(stockPrice),
              let K = Double(strikePrice),
              let T = Double(daysToExpiration),
              let sigma = Double(volatility),
              let r = Double(riskFreeRate) else {
            return
        }
        
        // Convert inputs to proper units
        let timeToExpiration = T / 365.0
        let volatilityDecimal = sigma / 100.0
        let rateDecimal = r / 100.0
        
        // Calculate Greeks
        greeks = calculateGreeks(
            S: S,
            K: K,
            T: timeToExpiration,
            sigma: volatilityDecimal,
            r: rateDecimal,
            type: optionType
        )
        
        showResults = true
    }
    
    /// Calculate all Greeks
    private func calculateGreeks(S: Double, K: Double, T: Double, sigma: Double, r: Double, type: OptionType) -> Greeks {
        let d1 = (log(S / K) + (r + 0.5 * sigma * sigma) * T) / (sigma * sqrt(T))
        let d2 = d1 - sigma * sqrt(T)
        
        let Nd1 = cumulativeNormalDistribution(d1)
        let Nd2 = cumulativeNormalDistribution(d2)
        let nd1 = normalDistribution(d1)
        
        // Delta
        let delta: Double
        if type == .call {
            delta = Nd1
        } else {
            delta = Nd1 - 1
        }
        
        // Gamma (same for calls and puts)
        let gamma = nd1 / (S * sigma * sqrt(T))
        
        // Theta
        let theta: Double
        if type == .call {
            theta = (-S * nd1 * sigma / (2 * sqrt(T)) - r * K * exp(-r * T) * Nd2) / 365.0
        } else {
            theta = (-S * nd1 * sigma / (2 * sqrt(T)) + r * K * exp(-r * T) * (1 - Nd2)) / 365.0
        }
        
        // Vega (same for calls and puts)
        let vega = S * nd1 * sqrt(T) / 100.0
        
        // Rho
        let rho: Double
        if type == .call {
            rho = K * T * exp(-r * T) * Nd2 / 100.0
        } else {
            rho = -K * T * exp(-r * T) * (1 - Nd2) / 100.0
        }
        
        return Greeks(delta: delta, gamma: gamma, theta: theta, vega: vega, rho: rho)
    }
    
    /// Normal distribution probability density function
    private func normalDistribution(_ x: Double) -> Double {
        return exp(-0.5 * x * x) / sqrt(2 * .pi)
    }
    
    /// Cumulative normal distribution function
    private func cumulativeNormalDistribution(_ x: Double) -> Double {
        return 0.5 * (1.0 + erf(x / sqrt(2.0)))
    }
}

// MARK: - Supporting Views

/// Greeks results display
struct GreeksResultsView: View {
    let greeks: GreeksCalculatorView.Greeks
    let optionType: GreeksCalculatorView.OptionType
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Greeks")
                .font(.headline)
            
            VStack(spacing: 12) {
                GreekRow(
                    name: "Delta (Δ)",
                    value: String(format: "%.4f", greeks.delta),
                    description: "Price change per $1 move in stock",
                    color: .blue
                )
                
                GreekRow(
                    name: "Gamma (Γ)",
                    value: String(format: "%.4f", greeks.gamma),
                    description: "Delta change per $1 move in stock",
                    color: .green
                )
                
                GreekRow(
                    name: "Theta (Θ)",
                    value: String(format: "%.4f", greeks.theta),
                    description: "Price change per day (time decay)",
                    color: .red
                )
                
                GreekRow(
                    name: "Vega (ν)",
                    value: String(format: "%.4f", greeks.vega),
                    description: "Price change per 1% volatility change",
                    color: .purple
                )
                
                GreekRow(
                    name: "Rho (ρ)",
                    value: String(format: "%.4f", greeks.rho),
                    description: "Price change per 1% rate change",
                    color: .orange
                )
            }
            .padding()
            .background(Color.gray.opacity(0.05))
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
}

/// Individual Greek row
struct GreekRow: View {
    let name: String
    let value: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
                
                Spacer()
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(color.opacity(0.05))
        .cornerRadius(8)
    }
}

/// Educational section explaining Greeks
struct GreeksEducationalSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Understanding the Greeks")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 12) {
                GreekExplanation(
                    name: "Delta (Δ)",
                    explanation: "Measures the rate of change in option price relative to changes in the underlying stock price. A delta of 0.50 means the option price will change by $0.50 for every $1 move in the stock.",
                    color: .blue
                )
                
                GreekExplanation(
                    name: "Gamma (Γ)",
                    explanation: "Measures the rate of change in delta. High gamma means delta changes rapidly, increasing risk and opportunity. Gamma is highest for at-the-money options near expiration.",
                    color: .green
                )
                
                GreekExplanation(
                    name: "Theta (Θ)",
                    explanation: "Measures time decay - how much value the option loses each day. Theta accelerates as expiration approaches. Long options have negative theta (lose value over time).",
                    color: .red
                )
                
                GreekExplanation(
                    name: "Vega (ν)",
                    explanation: "Measures sensitivity to volatility changes. Higher vega means the option price is more sensitive to changes in implied volatility. Long options benefit from volatility increases.",
                    color: .purple
                )
                
                GreekExplanation(
                    name: "Rho (ρ)",
                    explanation: "Measures sensitivity to interest rate changes. Generally the least important Greek for short-term options, but more significant for long-term LEAPS.",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

/// Greek explanation card
struct GreekExplanation: View {
    let name: String
    let explanation: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
            
            Text(explanation)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(color.opacity(0.05))
        .cornerRadius(8)
    }
}

// MARK: - Preview

#Preview {
    GreeksCalculatorView()
}
