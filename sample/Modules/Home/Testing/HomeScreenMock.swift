import HomeInterface
import SwiftUI

/// Test double for `HomeScreenProtocol`.
public struct HomeScreenMock: HomeScreenProtocol {

    public init() {}

    public var body: some View {
        Text("Mock HomeScreen")
            .font(.headline)
            .foregroundStyle(.secondary)
    }
}
