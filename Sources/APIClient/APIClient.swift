//
//  File.swift
//
//
//  Created by po_miyasaka on 2023/06/08.
//

import Foundation

public protocol Endpoint {
    associatedtype ResponseData
    func makeURLRequest() throws -> URLRequest
    func result(data: Data) throws -> ResponseData
}

public class APIClient {
    public enum E: Error {
        case decode
        case response
        case request
        case invalidURL
        case makeURLRequest
    }

    public static let `default` = APIClient()
    private init() {}

    public func request<T: Endpoint>(endpoint: T) async throws -> T.ResponseData {
        let urlRequest: URLRequest

        urlRequest = try endpoint.makeURLRequest()

        let data: Data
        do {
            let (d, response) = try await URLSession.shared.data(for: urlRequest)
            print(String(data: d, encoding: .utf8) ?? "no data")
            print(response)
            data = d

        } catch let e as NSError {
            switch e.code {
            case 400 ... 499:
                throw E.request
            default:
                throw E.response
            }
        }

        do {
            return try endpoint.result(data: data)
        } catch {
            throw E.decode
        }
    }
}
