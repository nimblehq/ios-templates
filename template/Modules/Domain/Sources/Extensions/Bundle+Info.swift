import Foundation

extension Bundle {

    public var info: BundleInfo { BundleInfo(bundle: self) }
}

public struct BundleInfo: Sendable {

    fileprivate let bundle: Bundle

    fileprivate init(bundle: Bundle) {
        self.bundle = bundle
    }

    public var shortVersion: String? {
        bundle.infoDictionary?["CFBundleShortVersionString"] as? String
    }
}
