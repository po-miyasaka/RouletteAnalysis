//
//  File.swift
//
//
//  Created by po_miyasaka on 2023/05/28.
//

import ComposableArchitecture
import History
import Item
import SwiftUI
import UserDefaultsClient

public struct HistoryView: View {
    public let store: StoreOf<History>
    public init(store: StoreOf<History>) { self.store = store }
    @ViewBuilder
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in

            VStack(spacing: 0) {
                HStack {
                    Button {
                        if !viewStore.items.isEmpty {
                            viewStore.send(.removeLast)
                        }
                    } label: {
                        Image(systemName: "trash")
                    }.disabled(viewStore.items.isEmpty)

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
                    }
                }
                .frame(maxHeight: 20)
                .padding(.top, 8)
                .padding(.horizontal, 8)

                HStack(alignment: .center, spacing: 8) {
                    Slider(
                        value: viewStore.binding(
                            get: { $0.displayLimit },
                            send: { value in
                                History.Action.change(value)
                            }
                        ),
                        in: 0 ... Double(max(viewStore.items.count, 1)),
                        step: 1
                    )

                    Text(
                        "\(Int(min(Double(viewStore.items.count), viewStore.displayLimit))) / \(viewStore.items.count)").font(.caption
                    )

                }.padding(8)
            }
        }
    }
}
