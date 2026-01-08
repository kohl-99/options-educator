import SwiftUI

/// Interactive options pricing calculator supporting multi-leg strategies.
///
/// Allows users to input multiple option legs and calculate their combined
/// theoretical price, break-even points, and profit/loss scenarios.
struct OptionCalculatorView: View {
    // MARK: - Environment
    
    @EnvironmentObject private var coordinator: AppCoordinator
    
    // MARK: - State
    
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
                        
                        // Strategy Summary
                        VStack(spacing: 16) {
                            Text("Strategy Summary")
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
    }
    
    // MARK: - Methods
    
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
        
        // Update legs based on strategy components
        legs = strategy.components.compactMap { component in
            // Map strategy component to calculator leg
            var leg = OptionLeg()
            leg.type = component.optionType == .put ? .put : .call
            leg.position = component.position == .short ? .short : .long
            leg.quantity = "\(component.quantity)"
            
            // Set strike price based on relation (simplified for demo)
            let currentS = Double(stockPrice) ?? 100.0
            switch component.strikeRelation {
            case .atTheMoney: leg.strikePrice = String(format: "%.0f", currentS)
            case .outOfTheMoney: leg.strikePrice = String(format: "%.0f", component.optionType == .call ? currentS * 1.05 : currentS * 0.95)
            case .inTheMoney: leg.strikePrice = String(format: "%.0f", component.optionType == .call ? currentS * 0.95 : currentS * 1.05)
            default: leg.strikePrice = String(format: "%.0f", currentS)
            }
            
            return leg
        }
        
        // Clear prefilled strategy after use
        coordinator.prefilledStrategy = nil
        
        // Auto-calculate
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
        
        // Calculate total strategy price (net debit/credit)
        totalStrategyPrice = 0
        for leg in legs {
            guard let K = Double(leg.strikePrice),
                  let qty = Double(leg.quantity) else { continue }
            
            let price = blackScholes(S: S, K: K, T: timeToExpiration, sigma: volatilityDecimal, r: rateDecimal, q: dividendDecimal, type: leg.type)
            let multiplier = leg.position == .long ? 1.0 : -1.0
            totalStrategyPrice += price * qty * multiplier
        }
        
        // Generate P/L data points
        generatePLData(S: S)
        
        // Find breakevens (where P/L crosses zero)
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
                
                // Calculate leg price at expiration
                let valueAtExp: Double
                if leg.type == .call {
                    valueAtExp = max(0, stockPriceAtExp - K)
                } else {
                    valueAtExp = max(0, K - stockPriceAtExp)
                }
                
                // Calculate theoretical entry price for this leg
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
                // Linear interpolation for more accurate breakeven
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

// MARK: - Supporting Views

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
