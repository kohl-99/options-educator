import SwiftUI

/// Interactive options pricing calculator supporting multi-leg strategies and real-time market data.
struct OptionCalculatorView: View {
    // MARK: - Environment
    
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var marketstack: MarketstackService
    
    // MARK: - State
    
    @State private var symbol: String = ""
    @State private var stockPrice: String = "100"
    @State private var daysToExpiration: String = "30"
    @State private var volatility: String = "30"
    @State private var riskFreeRate: String = "5"
    @State private var dividendYield: String = "0"
    
    @State private var legs: [OptionLeg] = [OptionLeg()]
    @State private var showResults = false
    @State private var plDataPoints: [PLDataPoint] = []
    @State private var breakevenPrices: [Double] = []
    @State private var totalStrategyPrice: Double = 0
    
    // MARK: - Types
    
    struct OptionLeg: Identifiable {
        let id = UUID()
        var type: OptionType = .call
        var position: Position = .long
        var strikePrice: String = "100"
        var quantity: String = "1"
        
        enum OptionType: String, CaseIterable {
            case call = "Call"
            case put = "Put"
        }
        
        enum Position: String, CaseIterable {
            case long = "Long"
            case short = "Short"
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Real-Time Data Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Real-World Simulation")
                        .font(.headline)
                    
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Symbol (Stock/Index)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("e.g. AAPL, SPX", text: $symbol)
                                .textFieldStyle(.roundedBorder)
                                .autocapitalization(.allCharacters)
                                .disableAutocorrection(true)
                        }
                        
                        Button(action: fetchPrice) {
                            if marketstack.isLoading {
                                ProgressView()
                                    .padding(.horizontal, 12)
                            } else {
                                Text("Get Price")
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                        .disabled(symbol.isEmpty || marketstack.isLoading)
                    }
                    
                    if let error = marketstack.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.05))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Global Parameters
                VStack(alignment: .leading, spacing: 16) {
                    Text("Market Parameters")
                        .font(.headline)
                    
                    HStack(spacing: 16) {
                        InputField(title: "Stock Price", value: $stockPrice, placeholder: "100", suffix: "$")
                        InputField(title: "Days to Exp", value: $daysToExpiration, placeholder: "30", suffix: "d")
                    }
                    
                    HStack(spacing: 16) {
                        InputField(title: "Volatility", value: $volatility, placeholder: "30", suffix: "%")
                        InputField(title: "Risk-Free Rate", value: $riskFreeRate, placeholder: "5", suffix: "%")
                    }
                }
                .padding(.horizontal)
                
                // Strategy Legs
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Strategy Legs")
                            .font(.headline)
                        Spacer()
                        Button(action: addLeg) {
                            Label("Add Leg", systemImage: "plus.circle")
                                .font(.subheadline)
                        }
                    }
                    
                    ForEach($legs) { $leg in
                        LegInputView(leg: $leg, onDelete: { removeLeg(leg.id) })
                    }
                }
                .padding(.horizontal)
                
                // Calculate button
                Button(action: calculate) {
                    Text("Calculate Strategy Payoff")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Results and Chart
                if showResults {
                    VStack(spacing: 24) {
                        // P/L Chart
                        ProfitLossChartView(
                            dataPoints: plDataPoints,
                            currentPrice: Double(stockPrice) ?? 0,
                            breakevenPrices: breakevenPrices
                        )
                        .padding(.horizontal)
                        
                        // Beginner Risk Analysis
                        BeginnerRiskAnalysisView(
                            maxProfit: plDataPoints.map { $0.profitLoss }.max() ?? 0,
                            maxLoss: abs(plDataPoints.map { $0.profitLoss }.min() ?? 0),
                            breakevens: breakevenPrices,
                            currentPrice: Double(stockPrice) ?? 0,
                            strategyName: coordinator.prefilledStrategy?.name ?? "Custom Strategy"
                        )
                        .padding(.horizontal)
                        
                        // Technical Summary
                        VStack(spacing: 16) {
                            Text("Technical Summary")
                                .font(.headline)
                            
                            VStack(spacing: 12) {
                                ResultRow(
                                    label: "Total Net Cost/Credit",
                                    value: String(format: "$%.2f", totalStrategyPrice * 100.0)
                                )
                                
                                ResultRow(
                                    label: "Max Profit",
                                    value: calculateMaxProfit()
                                )
                                
                                ResultRow(
                                    label: "Max Loss",
                                    value: calculateMaxLoss()
                                )
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                }
                
                EducationalSection()
            }
            .padding(.vertical)
        }
        .onAppear {
            checkPrefilledStrategy()
        }
        .onChange(of: coordinator.prefilledStrategy) { _ in
            checkPrefilledStrategy()
        }
        .onChange(of: marketstack.currentPrice) { newPrice in
            if let price = newPrice {
                stockPrice = String(format: "%.2f", price)
                calculate()
            }
        }
    }
    
    // MARK: - Methods
    
    private func fetchPrice() {
        Task {
            await marketstack.fetchLatestPrice(for: symbol)
        }
    }
    
    private func addLeg() {
        legs.append(OptionLeg())
    }
    
    private func removeLeg(_ id: UUID) {
        if legs.count > 1 {
            legs.removeAll { $0.id == id }
        }
    }
    
    private func checkPrefilledStrategy() {
        guard let strategy = coordinator.prefilledStrategy else { return }
        
        legs = strategy.components.compactMap { component in
            var leg = OptionLeg()
            leg.type = component.optionType == .put ? .put : .call
            leg.position = component.position == .short ? .short : .long
            leg.quantity = "\(component.quantity)"
            
            let currentS = Double(stockPrice) ?? 100.0
            switch component.strikeRelation {
            case .atTheMoney: leg.strikePrice = String(format: "%.0f", currentS)
            case .outOfTheMoney: leg.strikePrice = String(format: "%.0f", component.optionType == .call ? currentS * 1.05 : currentS * 0.95)
            case .inTheMoney: leg.strikePrice = String(format: "%.0f", component.optionType == .call ? currentS * 0.95 : currentS * 1.05)
            default: leg.strikePrice = String(format: "%.0f", currentS)
            }
            
            return leg
        }
        
        coordinator.prefilledStrategy = nil
        calculate()
    }
    
    private func calculate() {
        guard let S = Double(stockPrice),
              let T = Double(daysToExpiration),
              let sigma = Double(volatility),
              let r = Double(riskFreeRate),
              let q = Double(dividendYield) else {
            return
        }
        
        let timeToExpiration = T / 365.0
        let volatilityDecimal = sigma / 100.0
        let rateDecimal = r / 100.0
        let dividendDecimal = q / 100.0
        
        totalStrategyPrice = 0
        for leg in legs {
            guard let K = Double(leg.strikePrice),
                  let qty = Double(leg.quantity) else { continue }
            
            let price = blackScholes(S: S, K: K, T: timeToExpiration, sigma: volatilityDecimal, r: rateDecimal, q: dividendDecimal, type: leg.type)
            let multiplier = leg.position == .long ? 1.0 : -1.0
            totalStrategyPrice += price * qty * multiplier
        }
        
        generatePLData(S: S)
        findBreakevens()
        showResults = true
    }
    
    private func generatePLData(S: Double) {
        let range = S * 0.5
        let start = max(0, S - range)
        let end = S + range
        let step = (end - start) / 100.0
        
        var points: [PLDataPoint] = []
        for i in 0...100 {
            let stockPriceAtExp = start + Double(i) * step
            var totalPL: Double = 0
            
            for leg in legs {
                guard let K = Double(leg.strikePrice),
                      let qty = Double(leg.quantity) else { continue }
                
                let valueAtExp: Double
                if leg.type == .call {
                    valueAtExp = max(0, stockPriceAtExp - K)
                } else {
                    valueAtExp = max(0, K - stockPriceAtExp)
                }
                
                let entryPrice = blackScholes(S: S, K: K, T: Double(daysToExpiration)! / 365.0, sigma: Double(volatility)! / 100.0, r: Double(riskFreeRate)! / 100.0, q: Double(dividendYield)! / 100.0, type: leg.type)
                
                let multiplier = leg.position == .long ? 1.0 : -1.0
                totalPL += (valueAtExp - entryPrice) * qty * multiplier * 100.0
            }
            
            points.append(PLDataPoint(stockPrice: stockPriceAtExp, profitLoss: totalPL))
        }
        
        plDataPoints = points
    }
    
    private func findBreakevens() {
        var bes: [Double] = []
        for i in 0..<(plDataPoints.count - 1) {
            let p1 = plDataPoints[i]
            let p2 = plDataPoints[i+1]
            
            if (p1.profitLoss <= 0 && p2.profitLoss > 0) || (p1.profitLoss >= 0 && p2.profitLoss < 0) {
                let fraction = abs(p1.profitLoss) / (abs(p1.profitLoss) + abs(p2.profitLoss))
                let be = p1.stockPrice + fraction * (p2.stockPrice - p1.stockPrice)
                bes.append(be)
            }
        }
        breakevenPrices = bes
    }
    
    private func calculateMaxProfit() -> String {
        let maxPL = plDataPoints.map { $0.profitLoss }.max() ?? 0
        if maxPL > 1000000 { return "Unlimited" }
        return String(format: "$%.2f", maxPL)
    }
    
    private func calculateMaxLoss() -> String {
        let minPL = plDataPoints.map { $0.profitLoss }.min() ?? 0
        if minPL < -1000000 { return "Unlimited" }
        return String(format: "$%.2f", abs(minPL))
    }
    
    private func blackScholes(S: Double, K: Double, T: Double, sigma: Double, r: Double, q: Double, type: OptionLeg.OptionType) -> Double {
        if T <= 0 {
            return type == .call ? max(0, S - K) : max(0, K - S)
        }
        let d1 = (log(S / K) + (r - q + 0.5 * sigma * sigma) * T) / (sigma * sqrt(T))
        let d2 = d1 - sigma * sqrt(T)
        
        if type == .call {
            return S * exp(-q * T) * cumulativeNormalDistribution(d1) - K * exp(-r * T) * cumulativeNormalDistribution(d2)
        } else {
            return K * exp(-r * T) * cumulativeNormalDistribution(-d2) - S * exp(-q * T) * cumulativeNormalDistribution(-d1)
        }
    }
    
    private func cumulativeNormalDistribution(_ x: Double) -> Double {
        return 0.5 * (1.0 + erf(x / sqrt(2.0)))
    }
}

// MARK: - Supporting Components

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

struct LegInputView: View {
    @Binding var leg: OptionCalculatorView.OptionLeg
    var onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Picker("Position", selection: $leg.position) {
                    ForEach(OptionCalculatorView.OptionLeg.Position.allCases, id: \.self) { pos in
                        Text(pos.rawValue).tag(pos)
                    }
                }
                .pickerStyle(.segmented)
                
                Picker("Type", selection: $leg.type) {
                    ForEach(OptionCalculatorView.OptionLeg.OptionType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            
            HStack(spacing: 16) {
                InputField(title: "Strike", value: $leg.strikePrice, placeholder: "100", suffix: "$")
                InputField(title: "Quantity", value: $leg.quantity, placeholder: "1", suffix: "x")
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
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
