//
//  DummyNetworkModel.swift
//

import Foundation

struct DummyNetworkModel: Decodable {

    static let json =
        """
        {"message": "Hello"}
        """
    let message: String
}
