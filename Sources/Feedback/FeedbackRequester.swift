//
//  File.swift
//
//
//  Created by po_miyasaka on 2023/06/08.
//

import APIClient
import ComposableArchitecture
import Foundation

extension String: Error {}
public struct FeedbackRequester {
    var send: FeedbackData async -> Result<Void, String>
}

extension DependencyValues {
    public var feedbackRequester: FeedbackRequester {
        get { self[FeedbackRequester.self] }
        set { self[FeedbackRequester.self] = newValue }
    }
}

extension FeedbackRequester: DependencyKey {
    public static var liveValue: FeedbackRequester = {
        .init { requestData in
            let endpoint = FeedbackEndpoint(data: requestData)
            do {
                try await APIClient.default.request(endpoint: endpoint)
                return .success(())
            } catch let e as APIClient.E {
                switch e {
                case .response:
                    return .failure("Sorry. An error occured. Please try again later. (500)")
                case .decode:
                    return .failure("Sorry. An error occured.(403.1)")
                case .request:
                    return .failure("Sorry. An error occured. (403.2)")
                case .invalidURL:
                    return .failure("Sorry. An error occured.  (404)")
                case .makeURLRequest:
                    return .failure("Sorry. An error occured.(403.3)")
                }
            } catch {
                return .failure("unexpected error")
            }
        }

    }()
}
