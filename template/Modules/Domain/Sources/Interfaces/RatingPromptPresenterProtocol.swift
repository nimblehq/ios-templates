//
//  RatingPromptPresenterProtocol.swift
//

public protocol RatingPromptPresenterProtocol: Sendable {

    func show() async -> Bool
}
