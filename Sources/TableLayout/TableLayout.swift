//
//  File.swift
//  
//
//  Created by po_miyasaka on 2023/06/20.
//


import ComposableArchitecture
import Item
import SwiftUI

public struct TableLayout: ReducerProtocol {
    public init() {}
    public struct State: Equatable, Codable {
        public var selectedItemForAdding: Item?
        public init() {}
    }

    public enum Action: Equatable {
        case select(ItemWithWeight)
        case add(ItemWithWeight)
    }

    public func reduce(into state: inout State, action: Action) -> ComposableArchitecture.EffectTask<Action> {
        switch action {
        case let .select(item):
            if state.selectedItemForAdding?.number == item.item.number {
                return .task {
                    return .add(item)
                }
            } else {
                state.selectedItemForAdding = item.item
            }
        case .add:
            state.selectedItemForAdding = nil
        }
        return .none
    }
}
