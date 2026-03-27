import SwiftUI

/// Test double for `HomeScreen`.
public struct HomeScreenMock: View {

    public init() {}

    public var body: some View {
        Text("Mock HomeScreen")
            .font(.headline)
            .foregroundStyle(.secondary)
    }
}
