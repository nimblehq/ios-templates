import SwiftUI

struct HomeView: View {

    var onSignOut: () -> Void = {}
    var onShowSettings: () -> Void = {}
    var onPresentSettings: () -> Void = {}

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.checkmark")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)
            Text("home.title")
                .font(.title2.bold())
            Text("home.message")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button("home.button.open_settings", action: onShowSettings)
                .buttonStyle(.bordered)

            Button("home.button.present_settings_full_screen", action: onPresentSettings)
                .buttonStyle(.bordered)

            Button("home.button.sign_out", action: onSignOut)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
