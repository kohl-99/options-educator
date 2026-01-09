import Foundation

/// Service for fetching real-time news from Mediastack API.
@MainActor
final class MediastackService: ObservableObject {
    // MARK: - Properties
    
    private let apiKey = "1e85b279a46a6c1a8544e2e684b8d7e3"
    private let baseURL = "http://api.mediastack.com/v1"
    
    @Published var articles: [MediastackArticle] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Methods
    
    /// Fetches the latest business and technology news
    func fetchNews() async {
        isLoading = true
        errorMessage = nil
        
        // Filter for business and technology categories, and English language
        let urlString = "\(baseURL)/news?access_key=\(apiKey)&categories=business,technology&languages=en&limit=20"
        
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                errorMessage = "Failed to fetch news from Mediastack"
                isLoading = false
                return
            }
            
            let decoder = JSONDecoder()
            let result = try decoder.decode(MediastackResponse.self, from: data)
            self.articles = result.data
        } catch {
            errorMessage = "Error: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

// MARK: - Response Models

struct MediastackResponse: Codable {
    let pagination: MediastackPagination
    let data: [MediastackArticle]
}

struct MediastackPagination: Codable {
    let limit: Int
    let offset: Int
    let count: Int
    let total: Int
}

struct MediastackArticle: Codable, Identifiable {
    var id: String { url }
    let author: String?
    let title: String
    let description: String?
    let url: String
    let source: String
    let image: String?
    let category: String
    let language: String
    let country: String
    let published_at: String
}
