//
//  DailyForecastRowView.swift
//

import SwiftUI

private enum DailyForecastRowViewUI {

    static let rowSpacing: CGFloat = 14.0
    static let dayColumnWidth: CGFloat = 48.0
    static let conditionSpacing: CGFloat = 10.0
    static let conditionIconWidth: CGFloat = 24.0
    static let conditionOpacity = 0.92
    static let horizontalPadding: CGFloat = 16.0
    static let verticalPadding: CGFloat = 14.0
    static let backgroundOpacity = 0.08
    static let cornerRadius: CGFloat = 18.0
}

struct DailyForecastRowView: View {

    let viewData: DailyForecastRowViewData

    var body: some View {
        HStack(spacing: DailyForecastRowViewUI.rowSpacing) {
            Text(viewData.dayTitle)
                .font(.headline)
                .frame(width: DailyForecastRowViewUI.dayColumnWidth, alignment: .leading)

            HStack(spacing: DailyForecastRowViewUI.conditionSpacing) {
                Image(systemName: viewData.symbolName)
                    .frame(width: DailyForecastRowViewUI.conditionIconWidth)
                Text(viewData.conditionTitle)
                    .font(.subheadline)
            }
            .foregroundStyle(.white.opacity(DailyForecastRowViewUI.conditionOpacity))

            Spacer()

            Text(viewData.temperatureRange)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .monospacedDigit()
        }
        .padding(.horizontal, DailyForecastRowViewUI.horizontalPadding)
        .padding(.vertical, DailyForecastRowViewUI.verticalPadding)
        .background(Color.white.opacity(DailyForecastRowViewUI.backgroundOpacity))
        .clipShape(RoundedRectangle(cornerRadius: DailyForecastRowViewUI.cornerRadius, style: .continuous))
    }
}
