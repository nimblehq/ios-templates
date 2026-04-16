import Data
import FactoryKit
import SwiftUI

@main
struct {PROJECT_NAME}App: App {

    @Injected(\.exampleAppConfig) private var appConfig: AppConfig<ExampleAppConfiguration>

    init() {
        appConfig.setUp()
    }

    var body: some Scene {
        WindowGroup {
            LandingView()
        }
    }
}
