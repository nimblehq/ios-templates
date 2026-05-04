import SwiftUI

struct SignOutView: View {

    var onContinue: () -> Void = {}

    var body: some View {
        VStack(spacing: 20.0) {
            Image(systemName: "person.crop.circle.badge.exclamationmark")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)
            Text("sign_out.title")
                .font(.title2.bold())
            Text("sign_out.message")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button("sign_out.button.continue_demo_session", action: onContinue)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
