import SwiftUI

struct SignedOutView: View {
    var onContinue: () -> Void = {}

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)
            Text("Signed Out")
                .font(.title2.bold())
            Text("A generated project now starts from an unauthenticated state and can transition into a signed-in flow with a local demo session.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button("Continue with Demo Session", action: onContinue)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
