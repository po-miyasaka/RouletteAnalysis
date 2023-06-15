//
//  File.swift
//
//
//  Created by po_miyasaka on 2023/05/28.
//

import ComposableArchitecture
import Foundation
import Item
import SwiftUI
import UserDefaultsClient

public struct Roulette: ReducerProtocol {
    public init() {}
    @Dependency(\.userDefaults) var userDefaults
    public struct State: Identifiable, Equatable, Codable {
        public init(id: UUID, color: ColorData = .init()) {
            self.id = id
            self.color = color
        }

        public var id: UUID
        public var color: ColorData
        public var history: History.State = .init()
        public var wheel: Wheel.State = .init()
        public var layout: Layout.State = .init() // Layoutに閉じたプロパティしか持っていなくてもここに定義してScopeとして登録しないとReducerとしてはつかえない。
        public var selectedForPrediction: Item?
    }

    public enum Action: Equatable {
        case history(History.Action)
        case layout(Layout.Action)
        case wheel(Wheel.Action)
        case onAppear
    }

    public var body: some ReducerProtocol<State, Action> {
        Scope(state: \.history, action: /Roulette.Action.history) {
            History()
        }
        // これによりLayout内のReducerが呼ばれる。これが無いと呼ばれない。これがpullbackか
        Scope(state: \.layout, action: /Roulette.Action.layout) {
            Layout()
        }

        Scope(state: \.wheel, action: /Roulette.Action.wheel) {
            Wheel()
        }

        Reduce { state, action in
            switch action {
            case let .wheel(.select(item)):
                state.selectedForPrediction = item
            case .wheel:
                break
            case .history:
                break
            case let .layout(.add(item)):

                return .task {
                    .history(.add(item.item, isHit: item.candidated))
                }
            case .layout:
                break

            case .onAppear:
                return .run { send in
                    await send(.history(.setup))
                }
            }
            return .none
        }
    }
}

public struct ColorData: Equatable, Codable {
    
    var red: Double = 0
    var blue: Double = 0
    var green: Double = 0
    
    // Randomにしたいけどデザイン決まってないので保留
    public init(
//        red: Double = 1 / Double((1 ... 10).randomElement() ?? 0),
//        blue: Double = 1 / Double((1 ... 10).randomElement() ?? 0),
//        green: Double = 1 / Double((1 ... 10).randomElement() ?? 0)
    ) {
//        self.red = red
//        self.blue = blue
//        self.green = green
    }
    var color: Color {
        print(self)
        return .init(red: red, green: green, blue: blue)
    }
}
