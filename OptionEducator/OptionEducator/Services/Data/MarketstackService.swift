import Foundation

/// Service for fetching stock and index data from Marketstack API.
///
/// Note: Free tier accounts are restricted to the End-of-Day (EOD) endpoint
/// and may require HTTP instead of HTTPS in some configurations.
@MainActor
final class MarketstackService: ObservableObject {
    // MARK: - Properties
    
    private let apiKey = "b5d99ff456c9d60cd3c15a6d0ae699d1"
    
    // Using HTTP and EOD endpoint for maximum compatibility with Free Tier
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
        
        // Using /eod/latest as it's supported on all plans including Free
        let urlString = "\(baseURL)/eod/latest?access_key=\(apiKey)&symbols=\(symbol)"
        
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                errorMessage = "Invalid response from server"
                isLoading = false
                return
            }
            
            // Handle 403 specifically for better user feedback
            if httpResponse.statusCode == 403 {
                errorMessage = "Access Restricted: Free tier only supports End-of-Day data. Try using the EOD endpoint."
                isLoading = false
                return
            }
            
            guard httpResponse.statusCode == 200 else {
                errorMessage = "Server returned status code \(httpResponse.statusCode)"
                isLoading = false
                return
            }
            
            let decoder = JSONDecoder()
            let result = try decoder.decode(MarketstackEODResponse.self, from: data)
            
            if let firstData = result.data.first {
                // Use the close price as the "current" price for EOD data
                self.currentPrice = firstData.close
            } else {
                errorMessage = "No data found for symbol: \(symbol)"
            }
        } catch {
            errorMessage = "Connection Error: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

// MARK: - Response Models

struct MarketstackEODResponse: Codable {
    let pagination: MarketstackPagination
    let data: [MarketstackEODData]
}

struct MarketstackPagination: Codable {
    let limit: Int
    let offset: Int
    let count: Int
    let total: Int
}

struct MarketstackEODData: Codable {
    let open: Double?
    let high: Double?
    let low: Double?
    let close: Double?
    let volume: Double?
    let symbol: String
    let exchange: String
    let date: String
}
