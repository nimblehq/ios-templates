import SwiftUI

struct SettingsView: View {

    var body: some View {
        VStack(spacing: 20.0) {
            Image(systemName: "gearshape")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)
            Text("Settings")
                .font(.title2.bold())
            Text("This placeholder route gives generated apps a native NavigationStack destination to extend.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding()
        .navigationTitle("Settings")
    }
}
