//
//  File.swift
//  
//
//  Created by po_miyasaka on 2023/06/28.
//

import Foundation
import Dependencies

public extension DependencyValues {
    var inAppPurchase: InAppPurchaseService {
        get { self[InAppPurchaseService.self] }
        set { self[InAppPurchaseService.self] = newValue }
    }
}

extension InAppPurchaseService: DependencyKey {
    public static var liveValue: InAppPurchaseService = {
        .default
    }()
    
    public static var testValue: InAppPurchaseService = {
        var testValue = InAppPurchaseService.default
        testValue.buy = { purchase in .purchased }
        testValue.restore = { .restored }
        return testValue
    }()
}
