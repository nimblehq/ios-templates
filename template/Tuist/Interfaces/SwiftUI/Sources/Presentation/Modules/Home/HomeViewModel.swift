import Combine
import Data
import Domain
import FactoryKit
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {

    @Published private(set) var configuration = ExampleAppConfiguration()

    private var disposeBag = Set<AnyCancellable>()

    @Injected(\.exampleAppConfig) private var appConfig: AppConfig<ExampleAppConfiguration>

    nonisolated init() {
        Task { @MainActor in
            appConfig.currentConfigPublisher
                .assign(to: \.configuration, on: self)
                .store(in: &disposeBag)
        }
    }
}
