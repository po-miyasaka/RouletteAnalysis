//
//  File.swift
//
//
//  Created by po_miyasaka on 2023/06/08.
//

import APIClient
import SwiftUI
import Utility

public struct FeedbackData: Codable {
    let content: String
    let address: String
    var appName: String = "RouletteAnalysis"
}





public struct FeedbackEndpoint: Endpoint {
    public typealias ResponseData = Void
    public init(data: FeedbackData) {
        self.data = data
    }

    let data: FeedbackData
    var urlString: String? {
        guard let path = Bundle.main.path(forResource: "ProductionInfo", ofType: "plist"),
            let productionInfoDict = NSDictionary(contentsOfFile: path) as? [String: Any],
            let requestURLString = productionInfoDict["FeedbackURL"] as? String
        else {
            return nil
        }
        return requestURLString
    }

    public func makeURLRequest() throws -> URLRequest {
        guard let urlString, let url = URL(string: urlString) else {
            throw APIClient.E.invalidURL
        }
        var urlRequest: URLRequest = .init(url: url)
        let data = try JSONEncoder().encode(data)
        urlRequest.httpBody = data
        urlRequest.httpMethod = "POST"

        return urlRequest
    }

    public func result(data _: Data) throws -> ResponseData {
        ()
    }
}
