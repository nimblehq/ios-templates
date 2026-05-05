import Analytics
import SwiftUI

@main
struct {PROJECT_NAME}App: App {

    @StateObject private var router = AppRouter()

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
                .environmentObject(router)
        }
    }
}
