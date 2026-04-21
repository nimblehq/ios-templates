//
//  RatingPromptPresenterProtocol.swift
//

public protocol RatingPromptPresenterProtocol: Sendable {

    @MainActor
    func show() async
}
