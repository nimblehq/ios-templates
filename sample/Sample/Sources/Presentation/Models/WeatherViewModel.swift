//
//  WeatherViewModel.swift
//

import Combine
import Domain
import Foundation

@MainActor
public final class WeatherViewModel: ObservableObject {

    @Published public var searchText: String
    @Published public private(set) var weather: WeatherViewData?
    @Published public private(set) var isLoading = false
    @Published public private(set) var errorMessage: String?

    private let fetchWeatherUseCase: any FetchWeatherUseCaseProtocol
    private let defaultQuery: String
    private var lastLoadedQuery: String

    public var canSearch: Bool {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false && isLoading == false
    }

    init(
        defaultQuery: String = Constants.Weather.defaultCityQuery,
        fetchWeatherUseCase: any FetchWeatherUseCaseProtocol
    ) {
        self.fetchWeatherUseCase = fetchWeatherUseCase
        self.defaultQuery = defaultQuery
        self.lastLoadedQuery = defaultQuery
        self.searchText = defaultQuery
    }

    public func load() async {
        guard weather == nil else { return }
        await performSearch(using: defaultQuery)
    }

    public func search() async {
        await performSearch(using: searchText)
    }

    public func refresh() async {
        let visibleQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let fallbackQuery = lastLoadedQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        await performSearch(
            using: visibleQuery.isEmpty ? fallbackQuery : visibleQuery,
            updateSearchText: false
        )
    }

    private func performSearch(
        using rawQuery: String,
        updateSearchText: Bool = true
    ) async {
        let query = rawQuery.trimmingCharacters(in: .whitespacesAndNewlines)

        guard query.isEmpty == false else {
            errorMessage = L10n.weatherErrorMessage(for: .emptyQuery)
            return
        }

        guard isLoading == false else { return }

        isLoading = true
        errorMessage = nil

        if updateSearchText {
            searchText = query
        }

        defer { isLoading = false }

        do {
            let report = try await fetchWeatherUseCase.execute(for: query)
            weather = WeatherViewData(report: report)
            lastLoadedQuery = query
        } catch is CancellationError {
            return
        } catch let error as WeatherLookupError {
            errorMessage = L10n.weatherErrorMessage(for: error)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
