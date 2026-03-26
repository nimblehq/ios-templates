import HomeInterface
import SwiftUI

/// Test double for `HomeViewProtocol`.
///
/// Use this in unit tests and the `HomeExample` app to avoid depending
/// on the real `HomeView` implementation.
public struct HomeViewMock: HomeViewProtocol {

    public init() {}

    public var body: some View {
        Text("Mock HomeView")
            .font(.headline)
            .foregroundStyle(.secondary)
    }
}
