import SwiftUI

/// Interactive options pricing calculator using Black-Scholes model.
///
/// Allows users to input parameters and calculate theoretical option prices,
/// break-even points, and profit/loss scenarios with visual charts.
struct OptionCalculatorView: View {
    // MARK: - State
    
    @State private var optionType: OptionType = .call
    @State private var stockPrice: String = "100"
    @State private var strikePrice: String = "100"
    @State private var daysToExpiration: String = "30"
    @State private var volatility: String = "30"
    @State private var riskFreeRate: String = "5"
    @State private var dividendYield: String = "0"
    
    @State private var calculatedPrice: Double?
    @State private var showResults = false
    @State private var plDataPoints: [PLDataPoint] = []
    @State private var breakevenPrices: [Double] = []
    
    // MARK: - Types
    
    enum OptionType: String, CaseIterable {
        case call = "Call"
        case put = "Put"
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
                    
                    InputField(
                        title: "Dividend Yield",
                        value: $dividendYield,
                        placeholder: "0.0",
                        suffix: "%"
                    )
                }
                .padding(.horizontal)
                
                // Calculate button
                Button(action: calculate) {
                    Text("Calculate & Visualize")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Results and Chart
                if showResults, let price = calculatedPrice {
                    VStack(spacing: 24) {
                        // P/L Chart
                        ProfitLossChartView(
                            dataPoints: plDataPoints,
                            currentPrice: Double(stockPrice) ?? 0,
                            breakevenPrices: breakevenPrices
                        )
                        .padding(.horizontal)
                        
                        // Numeric Results
                        ResultsView(
                            optionType: optionType,
                            price: price,
                            stockPrice: Double(stockPrice) ?? 0,
                            strikePrice: Double(strikePrice) ?? 0
                        )
                    }
                }
                
                // Educational content
                EducationalSection()
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
              let r = Double(riskFreeRate),
              let q = Double(dividendYield) else {
            return
        }
        
        // Convert inputs to proper units
        let timeToExpiration = T / 365.0
        let volatilityDecimal = sigma / 100.0
        let rateDecimal = r / 100.0
        let dividendDecimal = q / 100.0
        
        // Calculate using Black-Scholes
        let price = blackScholes(
            S: S,
            K: K,
            T: timeToExpiration,
            sigma: volatilityDecimal,
            r: rateDecimal,
            q: dividendDecimal,
            type: optionType
        )
        
        calculatedPrice = price
        
        // Generate P/L data points for the chart
        generatePLData(S: S, K: K, price: price)
        
        // Calculate breakeven
        breakevenPrices = [optionType == .call ? K + price : K - price]
        
        showResults = true
    }
    
    private func generatePLData(S: Double, K: Double, price: Double) {
        let range = S * 0.4 // Show 40% range around current price
        let start = max(0, S - range)
        let end = S + range
        let step = (end - start) / 50.0
        
        var points: [PLDataPoint] = []
        for i in 0...50 {
            let stockPriceAtExp = start + Double(i) * step
            let pl: Double
            
            switch optionType {
            case .call:
                pl = (max(0, stockPriceAtExp - K) - price) * 100.0 // 100 shares per contract
            case .put:
                pl = (max(0, K - stockPriceAtExp) - price) * 100.0
            }
            
            points.append(PLDataPoint(stockPrice: stockPriceAtExp, profitLoss: pl))
        }
        
        plDataPoints = points
    }
    
    /// Black-Scholes option pricing formula
    private func blackScholes(S: Double, K: Double, T: Double, sigma: Double, r: Double, q: Double, type: OptionType) -> Double {
        // Handle T=0 case
        if T <= 0 {
            switch type {
            case .call: return max(0, S - K)
            case .put: return max(0, K - S)
            }
        }
        
        let d1 = (log(S / K) + (r - q + 0.5 * sigma * sigma) * T) / (sigma * sqrt(T))
        let d2 = d1 - sigma * sqrt(T)
        
        switch type {
        case .call:
            return S * exp(-q * T) * cumulativeNormalDistribution(d1) - K * exp(-r * T) * cumulativeNormalDistribution(d2)
        case .put:
            return K * exp(-r * T) * cumulativeNormalDistribution(-d2) - S * exp(-q * T) * cumulativeNormalDistribution(-d1)
        }
    }
    
    /// Cumulative normal distribution function
    private func cumulativeNormalDistribution(_ x: Double) -> Double {
        return 0.5 * (1.0 + erf(x / sqrt(2.0)))
    }
}

// MARK: - Supporting Views

/// Input field for calculator
struct InputField: View {
    let title: String
    @Binding var value: String
    let placeholder: String
    let suffix: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack {
                TextField(placeholder, text: $value)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
                
                Text(suffix)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

/// Results display view
struct ResultsView: View {
    let optionType: OptionCalculatorView.OptionType
    let price: Double
    let stockPrice: Double
    let strikePrice: Double
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Numeric Analysis")
                .font(.headline)
            
            VStack(spacing: 12) {
                ResultRow(
                    label: "Theoretical Price",
                    value: String(format: "$%.2f", price)
                )
                
                ResultRow(
                    label: "Intrinsic Value",
                    value: String(format: "$%.2f", intrinsicValue)
                )
                
                ResultRow(
                    label: "Time Value",
                    value: String(format: "$%.2f", timeValue)
                )
                
                ResultRow(
                    label: "Break-Even",
                    value: String(format: "$%.2f", breakEven)
                )
                
                ResultRow(
                    label: "Max Profit",
                    value: maxProfit
                )
                
                ResultRow(
                    label: "Max Loss",
                    value: String(format: "$%.2f", price * 100.0)
                )
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
        }
        .padding(.horizontal)
    }
    
    private var intrinsicValue: Double {
        switch optionType {
        case .call:
            return max(0, stockPrice - strikePrice)
        case .put:
            return max(0, strikePrice - stockPrice)
        }
    }
    
    private var timeValue: Double {
        return price - intrinsicValue
    }
    
    private var breakEven: Double {
        switch optionType {
        case .call:
            return strikePrice + price
        case .put:
            return strikePrice - price
        }
    }
    
    private var maxProfit: String {
        switch optionType {
        case .call:
            return "Unlimited"
        case .put:
            return String(format: "$%.2f", (strikePrice - price) * 100.0)
        }
    }
}

/// Result row displaying label and value
struct ResultRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
    }
}

/// Educational section explaining the calculator
struct EducationalSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("About This Calculator")
                .font(.headline)
            
            Text("This calculator uses the Black-Scholes model to estimate theoretical option prices. The model assumes:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 8) {
                BulletPoint(text: "European-style options (exercise only at expiration)")
                BulletPoint(text: "No dividends during the option's life (or constant dividend yield)")
                BulletPoint(text: "Efficient markets with no transaction costs")
                BulletPoint(text: "Constant volatility and risk-free rate")
                BulletPoint(text: "Log-normal distribution of stock prices")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            Text("Note: Real-world options prices may differ due to market conditions, liquidity, and other factors not captured by the model.")
                .font(.caption)
                .foregroundColor(.orange)
                .padding(.top, 8)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

/// Bullet point view
struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
            Text(text)
        }
    }
}

// MARK: - Preview

#Preview {
    OptionCalculatorView()
}
