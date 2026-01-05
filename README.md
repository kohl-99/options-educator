# Options Educator iOS App

An educational iOS application designed to teach users about stock options trading, featuring real-time news analysis, interactive calculators, and comprehensive strategy guides for popular trading platforms.

## Features

- **Strategy Library**: A comprehensive library of 50+ options trading strategies, from beginner to advanced, with detailed explanations, risk/reward profiles, and use cases.
- **Platform Comparison**: An in-depth comparison of options trading capabilities across major platforms: Interactive Brokers, Robinhood, and Fidelity. See which strategies are available at each permission level.
- **News & Insights**: Real-time financial news feed that connects market events to actionable trading strategies, providing educational examples of how news can impact trading decisions.
- **Interactive Calculators**: Powerful calculators for theoretical option pricing (Black-Scholes model) and risk management (Greeks: Delta, Gamma, Theta, Vega, Rho).
- **Educational Content**: Rich educational content integrated throughout the app to explain core concepts, from understanding options basics to advanced risk management techniques.
- **Swift Best Practices**: Built with a modern technology stack following Swift best practices, including SwiftUI, MVVM architecture, and async/await.

## Architecture

The app is built using a modern and scalable architecture, emphasizing separation of concerns, testability, and maintainability.

- **UI Framework**: SwiftUI
- **Architecture Pattern**: Model-View-ViewModel (MVVM)
- **Navigation**: Centralized `AppCoordinator` using `NavigationStack` for programmatic navigation and deep linking.
- **Services**: Protocol-oriented services for data management (strategies, platforms) and networking (news).
- **Dependency Management**: Swift Package Manager (SPM) for any future third-party libraries.

### Project Structure

The project is organized into the following directories:

```
OptionsEducator/
├── App/         # App entry point & coordinator
├── Models/      # Data models (Strategy, Platform, News)
├── ViewModels/  # Presentation logic and state management
├── Views/       # SwiftUI views and UI components
├── Services/    # Data and network services
├── Utilities/   # Extensions, helpers, and constants
├── Resources/   # Assets and bundled data (JSON)
└── Tests/       # Unit and UI tests
```

For a more detailed breakdown, see the [ARCHITECTURE.md](ARCHITECTURE.md) file.

## Core Concepts

### Options Trading Strategies

The app includes a wide range of options trading strategies, categorized by market outlook:

| Category      | Description                                      |
|---------------|--------------------------------------------------|
| **Bullish**   | Strategies that profit from an upward market trend.    |
| **Bearish**   | Strategies that profit from a downward market trend.   |
| **Neutral**   | Strategies that profit from low volatility or a sideways market. |
| **Volatile**  | Strategies that profit from large price swings in either direction. |
| **Income**    | Strategies designed to generate regular income from premiums. |
| **Hedging**   | Strategies used to protect existing positions from adverse price movements. |

### Platform Comparison

The app provides a detailed breakdown of the options trading permission levels for Interactive Brokers, Robinhood, and Fidelity, helping users understand which strategies they can trade on each platform.

| Platform              | Beginner Level (Tier/Level 1-2)                                    | Advanced Level (Tier/Level 3+)                                      |
|-----------------------|--------------------------------------------------------------------|-----------------------------------------------------------------------|
| **Interactive Brokers** | Covered Calls, Cash-Secured Puts, Long Calls/Puts, Basic Spreads | Uncovered (Naked) Options, Complex Spreads, Professional Strategies   |
| **Robinhood**         | Covered Calls, Cash-Secured Puts, Long Calls/Puts                  | Spreads (Verticals, Iron Condors), Straddles, Strangles                |
| **Fidelity**          | Covered Calls, Cash-Secured Puts, Long Calls/Puts, Straddles       | Spreads (Verticals, Iron Condors), Uncovered (Naked) Options          |

*This is a simplified summary. The app contains detailed information on each level's requirements and allowed strategies.*

### News Integration

The news feed is designed to be an educational tool. When a significant market event occurs (e.g., an earnings report, FDA approval, or merger announcement), the app provides:

1.  **The News**: A summary of the event.
2.  **Analysis**: The potential impact on the stock and market.
3.  **Strategy Suggestions**: Examples of options strategies that could be used to trade based on this type of news, along with the rationale and risk considerations.

### Interactive Calculators

- **Option Pricing Calculator**: Uses the Black-Scholes model to estimate the theoretical price of a call or put option based on stock price, strike price, time to expiration, volatility, and interest rates.
- **Greeks Calculator**: Calculates the primary options Greeks to help with risk management:
    - **Delta**: Measures the option's sensitivity to the underlying stock price.
    - **Gamma**: Measures the rate of change of Delta.
    - **Theta**: Measures the rate of time decay.
    - **Vega**: Measures sensitivity to changes in implied volatility.
    - **Rho**: Measures sensitivity to changes in interest rates.

## Getting Started

To build and run the project:

1.  **Clone the repository**:
    ```bash
    git clone https://github.com/<your-username>/options-educator.git
    cd options-educator
    ```

2.  **Open in Xcode**:
    Open the `OptionsEducator.xcodeproj` file in Xcode 14 or later.

3.  **Build and Run**:
    Select a simulator or a connected iOS device and press the "Run" button.

## Technology Stack

- **Swift 5.9+**
- **SwiftUI**
- **Combine** (for future reactive pipelines)
- **XCTest** (for testing)

## Swift Best Practices

This project adheres to modern Swift best practices, including:

- **MVVM Architecture**: For a clean separation of concerns.
- **Protocol-Oriented Programming**: Services are defined by protocols for testability and dependency injection.
- **Value Types**: Using `struct` for models to promote immutability and prevent side effects.
- **`async/await`**: For modern, structured concurrency.
- **`Codable`**: For easy and safe JSON parsing.
- **Property Wrappers**: Leveraging SwiftUI's property wrappers (`@State`, `@StateObject`, `@EnvironmentObject`) for state management.
- **Comprehensive Documentation**: All public types and methods are documented.

## Future Enhancements

- **User Accounts**: To save favorite strategies and calculator presets.
- **Paper Trading Simulator**: To practice trading with virtual money.
- **Push Notifications**: For breaking news and market alerts.
- **Advanced Charting**: For visualizing profit/loss diagrams and historical data.
- **Localization**: To support multiple languages.

## Contributing

Contributions are welcome! Please feel free to submit a pull request or open an issue.

1.  Fork the repository.
2.  Create a new branch (`git checkout -b feature/your-feature`).
3.  Make your changes.
4.  Commit your changes (`git commit -m 'feat: Add some feature'`).
5.  Push to the branch (`git push origin feature/your-feature`).
6.  Open a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
