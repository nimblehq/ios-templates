import SwiftUI

struct SettingsView: View {

    var body: some View {
        VStack(spacing: 20.0) {
            Image(systemName: "gearshape")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)
            Text("settings.title")
                .font(.title2.bold())
            Text("settings.message")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
        .navigationTitle("settings.title")
    }
}
