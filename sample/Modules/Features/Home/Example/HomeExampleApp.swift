import Home
import SwiftUI

/// Standalone sandbox app for developing the Home feature in isolation.
///
/// Run the `HomeExample` scheme to launch this app without the full `Sample`
/// app shell. Useful for rapid UI iteration, previews, and debugging.
@main
struct HomeExampleApp: App {

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}
