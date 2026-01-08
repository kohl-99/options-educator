import SwiftUI
import Charts

/// A view that visualizes the Profit and Loss (P/L) of an options strategy.
///
/// Displays a line chart with green for profit and red for loss,
/// helping users understand the risk/reward profile at different stock prices.
struct ProfitLossChartView: View {
    // MARK: - Properties
    
    /// Data points for the P/L chart
    let dataPoints: [PLDataPoint]
    
    /// The current stock price for reference
    let currentPrice: Double
    
    /// The break-even price(s)
    let breakevenPrices: [Double]
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Profit & Loss Visualization")
                .font(.headline)
            
            Chart {
                // P/L Line
                ForEach(dataPoints) { point in
                    LineMark(
                        x: .value("Stock Price", point.stockPrice),
                        y: .value("Profit/Loss", point.profitLoss)
                    )
                    .foregroundStyle(point.profitLoss >= 0 ? .green : .red)
                    .interpolationMethod(.catmullRom)
                }
                
                // Area under the curve (Profit)
                ForEach(dataPoints) { point in
                    AreaMark(
                        x: .value("Stock Price", point.stockPrice),
                        y: .value("Profit/Loss", point.profitLoss)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                point.profitLoss >= 0 ? .green.opacity(0.3) : .red.opacity(0.3),
                                .clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                
                // Zero Line (Breakeven)
                RuleMark(y: .value("Breakeven", 0))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                    .foregroundStyle(.gray)
                
                // Current Price Indicator
                RuleMark(x: .value("Current Price", currentPrice))
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .foregroundStyle(.blue)
                    .annotation(position: .top) {
                        Text("Current: $\(currentPrice, specifier: "%.2f")")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .padding(4)
                            .background(Color(.systemBackground).opacity(0.8))
                            .cornerRadius(4)
                    }
                
                // Breakeven Indicators
                ForEach(breakevenPrices, id: \.self) { price in
                    RuleMark(x: .value("Breakeven", price))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [2]))
                        .foregroundStyle(.orange)
                        .annotation(position: .bottom) {
                            Text("BE: $\(price, specifier: "%.2f")")
                                .font(.caption2)
                                .foregroundColor(.orange)
                        }
                }
            }
            .frame(height: 250)
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 5)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let price = value.as(Double.self) {
                            Text("$\(price, specifier: "%.0f")")
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(values: .automatic(desiredCount: 5)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let pl = value.as(Double.self) {
                            Text("\(pl >= 0 ? "+" : "")$ \(pl, specifier: "%.0f")")
                                .foregroundColor(pl >= 0 ? .green : .red)
                        }
                    }
                }
            }
            
            // Legend
            HStack(spacing: 20) {
                LegendItem(color: .green, label: "Profit")
                LegendItem(color: .red, label: "Loss")
                LegendItem(color: .blue, label: "Current Price")
                LegendItem(color: .orange, label: "Breakeven")
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Supporting Views

struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Data Models

struct PLDataPoint: Identifiable {
    let id = UUID()
    let stockPrice: Double
    let profitLoss: Double
}

// MARK: - Preview

struct ProfitLossChartView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleData: [PLDataPoint] = (80...120).map { price in
            let pl = (Double(price) - 100.0) * 100.0 - 200.0
            return PLDataPoint(stockPrice: Double(price), profitLoss: pl)
        }
        
        ProfitLossChartView(
            dataPoints: sampleData,
            currentPrice: 100.0,
            breakevenPrices: [102.0]
        )
        .padding()
    }
}
