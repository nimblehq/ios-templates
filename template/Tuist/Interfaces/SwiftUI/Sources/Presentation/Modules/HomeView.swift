import SwiftUI

struct HomeView: View {
    var onSignOut: () -> Void = {}

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.checkmark")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)
            Text("Signed In")
                .font(.title2.bold())
            Text("This starter flow demonstrates the signed-in state that teams can build on with product-specific screens.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button("Sign Out", action: onSignOut)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
