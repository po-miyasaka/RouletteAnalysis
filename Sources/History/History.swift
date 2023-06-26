//
//  File.swift
//  
//
//  Created by po_miyasaka on 2023/06/20.
//

import ComposableArchitecture
import Item
import SwiftUI
import UserDefaultsClient

public struct History: ReducerProtocol {
    @Dependency(\.userDefaults) var userDefaults: UserDefaultsClient
    @Dependency(\.uuid) var uuid
    public init() {}

    public struct State: Equatable, Codable {
        public var items: [HistoryItem] = []
        public var displayLimit: Double = 16
        public init() {}

        public var limitedHistory: [HistoryItem] {
            let count = items.count
            let start = count - Int(displayLimit) > 0 ? count - Int(displayLimit) : 0
            return Array(items[start ..< count])
        }

        public var displayName: String {
            items.prefix(10).reduce("") { "\($0 + $1.item.number.str)" }
        }
    }

    public enum Action: Equatable {
        case change(Double)
        case add(Item, isHit: Bool)
        case removeLast
        case setup
    }

    public func reduce(into state: inout State, action: Action) -> ComposableArchitecture.EffectTask<Action> {
        switch action {
        case let .change(value):
            state.displayLimit = value
        case let .add(item, isHit):

            let addedItem: HistoryItem = .init(item: .init(number: item.number, color: item.color, id: uuid()), isHit: isHit)
            state.items.append(addedItem)

        case .removeLast:
            state.items.removeLast()
        case .setup:
            state.displayLimit = Double(userDefaults.defaultDisplayedHistoryLimit ?? 16)
        }
        return .none
    }

    public struct HistoryItem: Equatable, Codable {
        public var item: Item
        public var isHit: Bool
    }
}
