//
//  File.swift
//
//
//  Created by po_miyasaka on 2023/06/08.
//

import Dependencies
import Foundation

extension FeedbackRequester: TestDependencyKey {
    public static var testValue: FeedbackRequester = {
        .init { _ in
            .success(())
        }
    }()
}
