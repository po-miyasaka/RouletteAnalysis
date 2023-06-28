//
//  File.swift
//
//
//  Created by po_miyasaka on 2023/06/20.
//

import ComposableArchitecture
import Item
import SwiftUI

public struct Wheel: ReducerProtocol {
    public init() {}
    public struct State: Equatable, Codable {
        public var mode: Mode = .deepest
        public init() {}
    }

    public enum Action: Equatable {
        case select(Item)
        case selectWithTap(Item)
        case change(Mode)
    }

    public func reduce(into state: inout State, action: Action) -> ComposableArchitecture.EffectTask<Action> {
        switch action {
        case let .change(mode):
            state.mode = mode
        case .select:
            break
        case let .selectWithTap(item):
            return .run { send in
                await send(.change(.selectByYourself))
                await send(.select(item))
            }
        }

        return .none
    }

    public enum Mode: String, CaseIterable, Codable {
        case deepest = "Deepest"
        case lightest = "Lightest"
        case selectByYourself = "Select by yourself"

        public var searchType: SearchType? {
            switch self {
            case .deepest:
                return .deepeset
            case .lightest:
                return .lightest
            default:
                return nil
            }
        }
    }
}
