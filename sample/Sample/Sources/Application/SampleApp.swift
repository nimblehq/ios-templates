import SwiftUI
import Data
import Domain

@main
struct SampleApp: App {
    @StateObject private var weatherViewModel: WeatherViewModel

    var body: some Scene {
        WindowGroup {
            HomeScreen(viewModel: weatherViewModel)
        }
    }

    @MainActor
    init() {
        let weatherRepository = WeatherRepository()
        let fetchWeatherUseCase = FetchWeatherUseCase(repository: weatherRepository)

        _weatherViewModel = StateObject(
            wrappedValue: WeatherViewModel(fetchWeatherUseCase: fetchWeatherUseCase)
        )
    }
}
