import Foundation

/// Service for fetching real-time stock and index data from Marketstack API.
@MainActor
final class MarketstackService: ObservableObject {
    // MARK: - Properties
    
    private let apiKey = "b5d99ff456c9d60cd3c15a6d0ae699d1"
    private let baseURL = "https://api.marketstack.com/v1"
    
    @Published var currentPrice: Double?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Methods
    
    /// Fetches the latest price for a given symbol
    /// - Parameter symbol: The stock or index symbol (e.g., "AAPL", "SPX")
    func fetchLatestPrice(for symbol: String) async {
        guard !symbol.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        let urlString = "\(baseURL)/tickers/\(symbol)/intraday/latest?access_key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                errorMessage = "Failed to fetch data from Marketstack"
                isLoading = false
                return
            }
            
            let decoder = JSONDecoder()
            let result = try decoder.decode(MarketstackResponse.self, from: data)
            
            if let lastPrice = result.last {
                self.currentPrice = lastPrice
            } else {
                errorMessage = "No price data available for \(symbol)"
            }
        } catch {
            errorMessage = "Error: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

// MARK: - Response Models

struct MarketstackResponse: Codable {
    let open: Double?
    let high: Double?
    let low: Double?
    let last: Double?
    let close: Double?
    let volume: Double?
    let date: String?
    let symbol: String?
}
