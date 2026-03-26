import HomeInterface
import SwiftUI

/// Home feature's root screen.
public struct HomeScreen: HomeScreenProtocol {

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
    HomeScreen()
}
