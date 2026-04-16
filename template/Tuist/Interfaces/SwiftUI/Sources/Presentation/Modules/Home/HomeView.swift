import SwiftUI

struct HomeView: View {

    @StateObject private var viewModel: HomeViewModel
    var onSignOut: () -> Void = {}

    init(viewModel: HomeViewModel = HomeViewModel(), onSignOut: @escaping () -> Void = {}) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onSignOut = onSignOut
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "person.crop.circle.badge.checkmark")
                    .font(.system(size: 48))
                    .foregroundColor(.accentColor)

                Text("Signed In")
                    .font(.title2.bold())

                Text(viewModel.configuration.welcomeMessage)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)

                Text("Configuration loaded from remote config")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .font(.caption)

                ConfigurationCard(
                    configuration: ConfigurationCardUIModel(
                        isFeatureEnabled: viewModel.configuration.isFeatureEnabled,
                        maxRetryCount: viewModel.configuration.maxRetryCount,
                        apiTimeout: viewModel.configuration.apiTimeout
                    )
                )

                Spacer()

                Button("Sign Out", action: onSignOut)
                    .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct ConfigurationCard: View {

    let configuration: ConfigurationCardUIModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("App Configuration")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 8) {
                ConfigurationRow(
                    title: "Feature Enabled",
                    value: configuration.isFeatureEnabled ? "Yes" : "No",
                    systemImage: configuration.isFeatureEnabled ? "checkmark.circle.fill" : "xmark.circle.fill",
                    color: configuration.isFeatureEnabled ? .green : .red
                )
                
                ConfigurationRow(
                    title: "Max Retry Count",
                    value: "\(configuration.maxRetryCount)",
                    systemImage: "arrow.clockwise",
                    color: .blue
                )
                
                ConfigurationRow(
                    title: "API Timeout",
                    value: "\(configuration.apiTimeout, default: "%.1f")s",
                    systemImage: "clock",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

private struct ConfigurationCardUIModel {

    let isFeatureEnabled: Bool
    let maxRetryCount: Int
    let apiTimeout: Double

    init(
        isFeatureEnabled: Bool = false,
        maxRetryCount: Int = 3,
        apiTimeout: Double = 30.0
    ) {
        self.isFeatureEnabled = isFeatureEnabled
        self.maxRetryCount = maxRetryCount
        self.apiTimeout = apiTimeout
    }
}

private struct ConfigurationRow: View {

    let title: String
    let value: String
    let systemImage: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
    }
}
