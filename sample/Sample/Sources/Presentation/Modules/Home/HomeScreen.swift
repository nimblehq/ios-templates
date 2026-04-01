import SwiftUI

private enum HomeScreenUI {

    static let backgroundGradientColors: [Color] = [
        Color(red: 0.06, green: 0.18, blue: 0.39),
        Color(red: 0.12, green: 0.36, blue: 0.59),
        Color(red: 0.42, green: 0.65, blue: 0.79)
    ]

    static let contentSpacing: CGFloat = 20.0
    static let contentPadding: CGFloat = 20.0
    static let searchPanelSpacing: CGFloat = 12.0
    static let searchTitleOpacity = 0.9
    static let searchCaptionOpacity = 0.78
    static let searchPanelPadding: CGFloat = 18.0
    static let searchPanelBackgroundOpacity = 0.16
    static let searchPanelCornerRadius: CGFloat = 24.0
    static let searchPanelBorderOpacity = 0.14
    static let panelBorderLineWidth: CGFloat = 1.0
    static let searchFieldSpacing: CGFloat = 10.0
    static let searchFieldHorizontalPadding: CGFloat = 14.0
    static let searchFieldVerticalPadding: CGFloat = 12.0
    static let searchFieldCornerRadius: CGFloat = 16.0
    static let searchButtonMinWidth: CGFloat = 52.0
    static let searchButtonTint = Color(red: 0.95, green: 0.62, blue: 0.23)
    static let loadingPanelSpacing: CGFloat = 14.0
    static let loadingPanelVerticalPadding: CGFloat = 40.0
    static let secondaryPanelBackgroundOpacity = 0.12
    static let secondaryPanelCornerRadius: CGFloat = 28.0
    static let emptyStateSpacing: CGFloat = 12.0
    static let emptyStateIconSize: CGFloat = 36.0
    static let secondaryMessageOpacity = 0.82
    static let emptyStatePadding: CGFloat = 24.0
    static let forecastPanelSpacing: CGFloat = 14.0
    static let forecastRowsSpacing: CGFloat = 12.0
    static let forecastPanelPadding: CGFloat = 18.0
    static let forecastPanelBackgroundOpacity = 0.18
    static let forecastPanelBorderOpacity = 0.08
    static let statusBannerSpacing: CGFloat = 12.0
    static let statusBannerTextSpacing: CGFloat = 4.0
    static let statusBannerPadding: CGFloat = 16.0
    static let statusBannerBackgroundOpacity = 0.18
    static let statusBannerCornerRadius: CGFloat = 20.0
    static let statusIconColor = Color(red: 1.0, green: 0.84, blue: 0.36)
}

struct HomeScreen: View {
    @ObservedObject private var viewModel: WeatherViewModel
    @Environment(\.colorScheme)
    private var colorScheme
    @FocusState private var isSearchFieldFocused: Bool

    var body: some View {
        NavigationStack {
            screenContent
                .navigationTitle(L10n.weatherScreenTitle)
                .toolbarBackground(.hidden, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .task {
                    await viewModel.load()
                }
                .refreshable {
                    await viewModel.refresh()
                }
        }
    }

    private var screenContent: some View {
        ZStack {
            backgroundGradient

            ScrollView {
                content
            }
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: HomeScreenUI.backgroundGradientColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: HomeScreenUI.contentSpacing) {
            searchPanel

            if let errorMessage = viewModel.errorMessage {
                statusBanner(message: errorMessage)
            }

            weatherContent
        }
        .padding(HomeScreenUI.contentPadding)
    }

    @ViewBuilder private var weatherContent: some View {
        if let weather = viewModel.weather {
            WeatherSummaryCard(viewData: weather)
            forecastPanel(viewData: weather)
        } else {
            placeholderPanel
        }
    }

    private var searchPanel: some View {
        VStack(alignment: .leading, spacing: HomeScreenUI.searchPanelSpacing) {
            Text(L10n.weatherSearchTitle)
                .font(.headline)
                .foregroundStyle(.white.opacity(HomeScreenUI.searchTitleOpacity))

            HStack(spacing: HomeScreenUI.searchPanelSpacing) {
                searchField
                searchButton
            }

            Text(L10n.weatherSearchCaption)
                .font(.footnote)
                .foregroundStyle(.white.opacity(HomeScreenUI.searchCaptionOpacity))
        }
        .padding(HomeScreenUI.searchPanelPadding)
        .background(Color.white.opacity(HomeScreenUI.searchPanelBackgroundOpacity))
        .clipShape(RoundedRectangle(cornerRadius: HomeScreenUI.searchPanelCornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: HomeScreenUI.searchPanelCornerRadius, style: .continuous)
                .stroke(
                    Color.white.opacity(HomeScreenUI.searchPanelBorderOpacity),
                    lineWidth: HomeScreenUI.panelBorderLineWidth
                )
        )
    }

    private var searchField: some View {
        HStack(spacing: HomeScreenUI.searchFieldSpacing) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField(L10n.weatherSearchPlaceholder, text: $viewModel.searchText)
                .textInputAutocapitalization(.words)
                .disableAutocorrection(true)
                .focused($isSearchFieldFocused)
                .submitLabel(.search)
                .onSubmit(submitSearch)
                .accessibilityIdentifier("home.searchField")
        }
        .padding(.horizontal, HomeScreenUI.searchFieldHorizontalPadding)
        .padding(.vertical, HomeScreenUI.searchFieldVerticalPadding)
        .background(searchFieldBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: HomeScreenUI.searchFieldCornerRadius, style: .continuous))
    }

    private var searchFieldBackgroundColor: Color {
        if colorScheme == .dark {
            Color.black.opacity(0.32)
        } else {
            Color.white
        }
    }

    private var searchButton: some View {
        Button(action: submitSearch) {
            Text(L10n.weatherSearchAction)
                .fontWeight(.semibold)
                .frame(minWidth: HomeScreenUI.searchButtonMinWidth)
        }
        .buttonStyle(.borderedProminent)
        .tint(HomeScreenUI.searchButtonTint)
        .disabled(viewModel.canSearch == false)
        .accessibilityIdentifier("home.searchButton")
    }

    @ViewBuilder private var placeholderPanel: some View {
        if viewModel.isLoading {
            loadingPlaceholderPanel
        } else {
            emptyPlaceholderPanel
        }
    }

    private var loadingPlaceholderPanel: some View {
        VStack(spacing: HomeScreenUI.loadingPanelSpacing) {
            ProgressView()
                .progressViewStyle(.circular)
                .tint(.white)

            Text(L10n.weatherLoadingState)
                .font(.headline)
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, HomeScreenUI.loadingPanelVerticalPadding)
        .background(Color.white.opacity(HomeScreenUI.secondaryPanelBackgroundOpacity))
        .clipShape(RoundedRectangle(cornerRadius: HomeScreenUI.secondaryPanelCornerRadius, style: .continuous))
    }

    private var emptyPlaceholderPanel: some View {
        VStack(alignment: .leading, spacing: HomeScreenUI.emptyStateSpacing) {
            Image(systemName: "cloud.sun.rain.fill")
                .font(.system(size: HomeScreenUI.emptyStateIconSize))
                .foregroundStyle(.white)

            Text(L10n.weatherEmptyStateTitle)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)

            Text(placeholderMessage)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(HomeScreenUI.secondaryMessageOpacity))
        }
        .padding(HomeScreenUI.emptyStatePadding)
        .background(Color.white.opacity(HomeScreenUI.secondaryPanelBackgroundOpacity))
        .clipShape(RoundedRectangle(cornerRadius: HomeScreenUI.secondaryPanelCornerRadius, style: .continuous))
    }

    private var placeholderMessage: String {
        L10n.weatherEmptyStateMessage
    }

    init(viewModel: WeatherViewModel) {
        self.viewModel = viewModel
    }

    private func forecastPanel(viewData: WeatherViewData) -> some View {
        VStack(alignment: .leading, spacing: HomeScreenUI.forecastPanelSpacing) {
            Text(L10n.weatherForecastTitle)
                .font(.headline)
                .foregroundStyle(.white)

            VStack(spacing: HomeScreenUI.forecastRowsSpacing) {
                ForEach(viewData.dailyForecasts) { forecast in
                    DailyForecastRowView(viewData: forecast)
                }
            }
        }
        .padding(HomeScreenUI.forecastPanelPadding)
        .background(Color.black.opacity(HomeScreenUI.forecastPanelBackgroundOpacity))
        .clipShape(RoundedRectangle(cornerRadius: HomeScreenUI.searchPanelCornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: HomeScreenUI.searchPanelCornerRadius, style: .continuous)
                .stroke(
                    Color.white.opacity(HomeScreenUI.forecastPanelBorderOpacity),
                    lineWidth: HomeScreenUI.panelBorderLineWidth
                )
        )
    }

    private func statusBanner(message: String) -> some View {
        HStack(alignment: .top, spacing: HomeScreenUI.statusBannerSpacing) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(HomeScreenUI.statusIconColor)

            VStack(alignment: .leading, spacing: HomeScreenUI.statusBannerTextSpacing) {
                Text(L10n.weatherStatusTitle)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(HomeScreenUI.secondaryMessageOpacity))
            }
        }
        .padding(HomeScreenUI.statusBannerPadding)
        .background(Color.black.opacity(HomeScreenUI.statusBannerBackgroundOpacity))
        .clipShape(RoundedRectangle(cornerRadius: HomeScreenUI.statusBannerCornerRadius, style: .continuous))
    }

    private func submitSearch() {
        guard viewModel.canSearch else { return }

        isSearchFieldFocused = false

        Task {
            await viewModel.search()
        }
    }
}
