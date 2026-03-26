import HomeInterface
import SwiftUI

/// Home feature's root view.
///
/// This is the implementation target (`Home`). Consumers should reference
/// `HomeViewProtocol` from `HomeInterface` rather than this type directly,
/// keeping cross-feature dependencies on the interface only.
public struct HomeView: HomeViewProtocol {

    public init() {}

    public var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.accent)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    HomeView()
}
