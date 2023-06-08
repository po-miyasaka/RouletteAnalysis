//
//  File.swift
//
//
//  Created by po_miyasaka on 2023/06/08.
//

import Foundation

import ComposableArchitecture
@testable import Feedback
import Item
import XCTest

@MainActor
final class FeedbackTests: XCTestCase {
    func testSubmit_success() async {
        let store = TestStore(
            initialState: .init(),
            reducer: FeedbackFeature.init,
            withDependencies: {
                $0.feedbackRequester = .init(send: { _ in
                    .success(())
            })
            }
        )

        await store.send(.submit)
        await store.receive(/FeedbackFeature.Action.connecting) {
            $0.isConnecting = true
        }
        await store.receive(/FeedbackFeature.Action.setAlertMessage) {
            $0.alertMessage = "Thanks for your feedback!"
        }
        await store.receive(/FeedbackFeature.Action.finishConnecting) {
            $0.isConnecting = false
        }
    }

    func testSubmit_failure() async {
        let store = TestStore(
            initialState: .init(),
            reducer: FeedbackFeature.init,
            withDependencies: {
                $0.feedbackRequester = .init(send: { _ in
                    .failure("failure")
            })
            }
        )

        await store.send(.submit)
        await store.receive(/FeedbackFeature.Action.connecting) {
            $0.isConnecting = true
        }
        await store.receive(/FeedbackFeature.Action.setAlertMessage) {
            $0.alertMessage = "failure"
        }
        await store.receive(/FeedbackFeature.Action.finishConnecting) {
            $0.isConnecting = false
        }
    }
}
