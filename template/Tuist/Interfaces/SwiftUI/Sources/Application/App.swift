import Analytics
import SwiftUI

@main
struct {PROJECT_NAME}App: App {

    init() {
        #if DEBUG
        Analytics.shared.configure(
            trackers: [ConsoleAnalyticsTracker(type: .console)],
            additionalParameters: nil
        )
        #else
        Analytics.shared.configure(trackers: [], additionalParameters: nil)
        #endif
    }

    var body: some Scene {
        WindowGroup {
            LandingView()
        }
    }
}
