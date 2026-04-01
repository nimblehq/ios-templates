//
//  WeatherSummaryCard.swift
//

import SwiftUI

private enum WeatherSummaryCardUI {

    static let metricChipSpacing: CGFloat = 6.0
    static let metricChipTitleOpacity = 0.72
    static let metricChipPadding: CGFloat = 12.0
    static let metricChipBackgroundOpacity = 0.14
    static let metricChipCornerRadius: CGFloat = 18.0
    static let cardSpacing: CGFloat = 18.0
    static let cardPadding: CGFloat = 24.0
    static let cardCornerRadius: CGFloat = 28.0
    static let cardBorderOpacity = 0.12
    static let cardBorderLineWidth: CGFloat = 1.0
    static let cardShadowOpacity = 0.18
    static let cardShadowRadius: CGFloat = 14.0
    static let cardShadowYOffset: CGFloat = 10.0
    static let locationHeaderSpacing: CGFloat = 4.0
    static let locationSubtitleOpacity = 0.74
    static let temperatureSectionSpacing: CGFloat = 16.0
    static let temperatureTextsSpacing: CGFloat = 4.0
    static let currentTemperatureFontSize: CGFloat = 72.0
    static let apparentTemperatureOpacity = 0.78
    static let conditionSymbolFontSize: CGFloat = 56.0
    static let conditionSymbolOpacity = 0.96
    static let metricsSectionSpacing: CGFloat = 12.0
    static let cardBackgroundColors: [Color] = [
        Color(red: 0.98, green: 0.62, blue: 0.27),
        Color(red: 0.95, green: 0.42, blue: 0.31),
        Color(red: 0.79, green: 0.28, blue: 0.38)
    ]
}

private struct MetricChip: View {

    let iconName: String
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: WeatherSummaryCardUI.metricChipSpacing) {
            Label(title, systemImage: iconName)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(WeatherSummaryCardUI.metricChipTitleOpacity))

            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
        }
        .padding(WeatherSummaryCardUI.metricChipPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(WeatherSummaryCardUI.metricChipBackgroundOpacity))
        .clipShape(RoundedRectangle(cornerRadius: WeatherSummaryCardUI.metricChipCornerRadius, style: .continuous))
    }
}

struct WeatherSummaryCard: View {

    let viewData: WeatherViewData

    var body: some View {
        VStack(alignment: .leading, spacing: WeatherSummaryCardUI.cardSpacing) {
            locationHeader
            temperatureSection
            metricsSection
        }
        .padding(WeatherSummaryCardUI.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: WeatherSummaryCardUI.cardCornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: WeatherSummaryCardUI.cardCornerRadius, style: .continuous)
                .stroke(
                    Color.white.opacity(WeatherSummaryCardUI.cardBorderOpacity),
                    lineWidth: WeatherSummaryCardUI.cardBorderLineWidth
                )
        )
        .foregroundStyle(.white)
        .shadow(
            color: Color.black.opacity(WeatherSummaryCardUI.cardShadowOpacity),
            radius: WeatherSummaryCardUI.cardShadowRadius,
            y: WeatherSummaryCardUI.cardShadowYOffset
        )
    }

    private var locationHeader: some View {
        VStack(alignment: .leading, spacing: WeatherSummaryCardUI.locationHeaderSpacing) {
            Text(viewData.locationName)
                .font(.title2.weight(.semibold))

            if viewData.locationSubtitle.isEmpty == false {
                Text(viewData.locationSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(WeatherSummaryCardUI.locationSubtitleOpacity))
            }
        }
    }

    private var temperatureSection: some View {
        HStack(alignment: .top, spacing: WeatherSummaryCardUI.temperatureSectionSpacing) {
            VStack(alignment: .leading, spacing: WeatherSummaryCardUI.temperatureTextsSpacing) {
                Text(viewData.currentTemperature)
                    .font(
                        .system(
                            size: WeatherSummaryCardUI.currentTemperatureFontSize,
                            weight: .bold,
                            design: .rounded
                        )
                    )
                    .monospacedDigit()

                Text(viewData.conditionTitle)
                    .font(.title3.weight(.semibold))

                Text(viewData.apparentTemperature)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(WeatherSummaryCardUI.apparentTemperatureOpacity))
            }

            Spacer(minLength: .zero)

            Image(systemName: viewData.conditionSymbolName)
                .font(.system(size: WeatherSummaryCardUI.conditionSymbolFontSize))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.white.opacity(WeatherSummaryCardUI.conditionSymbolOpacity))
        }
    }

    private var metricsSection: some View {
        HStack(spacing: WeatherSummaryCardUI.metricsSectionSpacing) {
            MetricChip(
                iconName: "thermometer.medium",
                title: L10n.weatherMetricToday,
                value: viewData.highLow
            )

            MetricChip(
                iconName: "wind",
                title: L10n.weatherMetricWind,
                value: viewData.windSpeed
            )
        }
    }

    private var cardBackground: some View {
        LinearGradient(
            colors: WeatherSummaryCardUI.cardBackgroundColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
