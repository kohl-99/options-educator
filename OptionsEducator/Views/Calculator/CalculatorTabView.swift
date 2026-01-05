import SwiftUI

/// Tab view for different calculator types.
///
/// Provides access to options pricing calculator and Greeks calculator.
struct CalculatorTabView: View {
    // MARK: - State
    
    @State private var selectedCalculator: CalculatorType = .optionPricing
    
    // MARK: - Types
    
    enum CalculatorType: String, CaseIterable {
        case optionPricing = "Option Pricing"
        case greeks = "Greeks"
        
        var iconName: String {
            switch self {
            case .optionPricing: return "dollarsign.circle.fill"
            case .greeks: return "function"
            }
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Calculator type picker
                Picker("Calculator", selection: $selectedCalculator) {
                    ForEach(CalculatorType.allCases, id: \.self) { type in
                        Label(type.rawValue, systemImage: type.iconName)
                            .tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Calculator content
                TabView(selection: $selectedCalculator) {
                    OptionCalculatorView()
                        .tag(CalculatorType.optionPricing)
                    
                    GreeksCalculatorView()
                        .tag(CalculatorType.greeks)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle("Calculators")
        }
    }
}

// MARK: - Preview

#Preview {
    CalculatorTabView()
}
