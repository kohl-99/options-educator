import SwiftUI

/// Displays a comparison of different trading platforms.
///
/// Shows platform features, permission levels, fees, and strategy availability
/// in an easy-to-compare format.
struct PlatformComparisonView: View {
    // MARK: - Environment
    
    @EnvironmentObject private var platformService: PlatformDataService
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(platformService.platforms) { platform in
                    PlatformCard(platform: platform)
                }
            }
            .navigationTitle("Platforms")
        }
    }
}

/// Card displaying platform information
struct PlatformCard: View {
    let platform: TradingPlatform
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(platform.name)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                RatingView(rating: platform.ratings.overall)
            }
            
            Text(platform.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Levels
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.blue)
                Text("\(platform.levelCount) Levels")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if platform.isCommissionFree {
                    Text("Commission-Free")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(4)
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }
}

/// Star rating view
struct RatingView: View {
    let rating: Double
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: Double(index) <= rating ? "star.fill" : "star")
                    .font(.caption)
                    .foregroundColor(.yellow)
            }
            Text(String(format: "%.1f", rating))
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview

#Preview {
    PlatformComparisonView()
        .environmentObject(PlatformDataService())
}
