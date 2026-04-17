//
//  ForceUpdateView.swift
//

import SwiftUI

struct ForceUpdateView: View {

    var onUpdate: () -> Void = {}

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.up.circle")
                .font(.system(size: 64))
                .foregroundStyle(Color.accentColor)
            Text("Update Required")
                .font(.title.bold())
            Text("A new version of the app is required to continue. Please update to the latest version.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("Update Now", action: onUpdate)
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .interactiveDismissDisabled()
    }
}
