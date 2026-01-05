import SwiftUI

/// Displays a list of all available options trading strategies.
///
/// Provides filtering, searching, and sorting capabilities to help
/// users find strategies that match their needs.
struct StrategyListView: View {
    // MARK: - Environment
    
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var strategyService: StrategyDataService
    
    // MARK: - State
    
    @State private var searchText = ""
    @State private var selectedCategory: StrategyCategory?
    @State private var selectedComplexity: Int?
    @State private var showFilters = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            List {
                if filteredStrategies.isEmpty {
                    ContentUnavailableView(
                        "No Strategies Found",
                        systemImage: "magnifyingglass",
                        description: Text("Try adjusting your search or filters")
                    )
                } else {
                    ForEach(filteredStrategies) { strategy in
                        StrategyCardView(strategy: strategy)
                            .onTapGesture {
                                coordinator.navigate(to: .strategyDetail(id: strategy.id))
                            }
                    }
                }
            }
            .navigationTitle("Strategies")
            .searchable(text: $searchText, prompt: "Search strategies")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showFilters.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $showFilters) {
                FilterView(
                    selectedCategory: $selectedCategory,
                    selectedComplexity: $selectedComplexity
                )
            }
            .onChange(of: searchText) { _, newValue in
                applyFilters()
            }
            .onChange(of: selectedCategory) { _, _ in
                applyFilters()
            }
            .onChange(of: selectedComplexity) { _, _ in
                applyFilters()
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var filteredStrategies: [OptionStrategy] {
        return strategyService.filteredStrategies
    }
    
    // MARK: - Methods
    
    private func applyFilters() {
        strategyService.filterStrategies(
            category: selectedCategory,
            complexity: selectedComplexity,
            searchText: searchText
        )
    }
}

/// Filter view for strategies
struct FilterView: View {
    @Binding var selectedCategory: StrategyCategory?
    @Binding var selectedComplexity: Int?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        Text("All").tag(nil as StrategyCategory?)
                        ForEach(StrategyCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category as StrategyCategory?)
                        }
                    }
                }
                
                Section("Complexity") {
                    Picker("Complexity", selection: $selectedComplexity) {
                        Text("All").tag(nil as Int?)
                        ForEach(1...5, id: \.self) { level in
                            Text("Level \(level)").tag(level as Int?)
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    StrategyListView()
        .environmentObject(AppCoordinator())
        .environmentObject(StrategyDataService())
}
