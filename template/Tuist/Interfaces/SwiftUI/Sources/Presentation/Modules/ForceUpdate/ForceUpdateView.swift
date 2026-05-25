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
            Text("force_update.title")
                .font(.title.bold())
            Text("force_update.message")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button("force_update.button.update_now", action: onUpdate)
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .interactiveDismissDisabled()
    }
}
