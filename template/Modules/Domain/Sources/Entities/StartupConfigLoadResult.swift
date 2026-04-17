//
//  StartupConfigLoadResult.swift
//

public enum StartupConfigLoadResult: Equatable, Sendable {

    /// Remote config refresh completed successfully.
    ///
    /// Note: this does not guarantee a "network fetch" happened - only that the configured
    /// RemoteConfigSource did not throw during refresh.
    case refreshed
    case usedLocalDefaults
}
