import SwiftUI
@testable import Home

/// Test double for `HomeScreen`.
struct HomeScreenMock: View {

    init() {}

    var body: some View {
        Text("Mock HomeScreen")
            .font(.headline)
            .foregroundStyle(.secondary)
    }
}
