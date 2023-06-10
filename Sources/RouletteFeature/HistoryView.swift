//
//  File.swift
//
//
//  Created by po_miyasaka on 2023/05/28.
//

import ComposableArchitecture
import Item
import SwiftUI
import UserDefaultsClient

public struct History: ReducerProtocol {
    @Dependency(\.userDefaults) var userDefaults: UserDefaultsClient
    @Dependency(\.uuid) var uuid

    public struct State: Equatable {
        var items: [HistoryItem] = []
        var displayLimit: Double = 16

        var limitedHistory: [HistoryItem] {
            let count = items.count
            let start = count - Int(displayLimit) > 0 ? count - Int(displayLimit) : 0
            return Array(items[start ..< count])
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
    
    public struct HistoryItem: Equatable {
        public var item: Item
        public var isHit: Bool
    }
}

public struct HistoryView: View {
    public let store: StoreOf<History>

    @ViewBuilder
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 0) {
                ZStack(alignment: .trailing) {
                    Color.white.opacity(0.1)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .center, spacing: 4, content: {
                            ForEach(
                                Array(
                                    Array(
                                        viewStore.items.reversed()
                                    ).enumerated()
                                ),
                                id: \.offset
                            ) { index, data in
                                let highlighted = index < Int(viewStore.displayLimit)
                                Text(
                                    data.item.number.str)
                                    .font(.caption2)
                                    .bold()
                                    .padding(2).foregroundColor(highlighted ? .white : .black
                                    )
                                    .background(highlighted ? data.item.color.value.opacity(0.7) : .clear)
                                    .border(data.isHit ? .yellow : .clear, width: 2)
                            }
                        })
                            .padding(.horizontal, 8)
                    }
                }
                .frame(maxHeight: 20)
                .padding(.top, 8)

                HStack(alignment: .center, spacing: 8) {
                    Slider(
                        value: viewStore.binding(get: { $0.displayLimit }, send: { value in
                            History.Action.change(value)
                        }),
                        in: 0 ... Double(max(viewStore.items.count, 1)),
                        step: 1
                    )

                    Text(
                        "\(Int(min(Double(viewStore.items.count), viewStore.displayLimit))) / \(viewStore.items.count)").font(.caption
                    )
                }.padding(.horizontal, 8)
            }
        }
    }
}
