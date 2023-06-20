//
//  File.swift
//
//
//  Created by po_miyasaka on 2023/05/28.
//

import ComposableArchitecture
import Item
import SwiftUI
import TableLayout
import Utility


public struct TableLayoutView: View {
    public struct ViewState: Equatable {
        public var rule: Rule
        public var predictedData: [ItemWithOmomi]
        public var selectedItem: Item?
        public var lastItem: Item?

        public init(rule: Rule, predictedData: [ItemWithOmomi], selectedItem: Item?, lastItem: Item?) {
            self.rule = rule
            self.predictedData = predictedData
            self.selectedItem = selectedItem
            self.lastItem = lastItem
        }
    }

    @ObservedObject var viewStore: ViewStore<ViewState, TableLayout.Action>

    public init(store: Store<ViewState, TableLayout.Action>) {
        viewStore = ViewStore(store)
    }

    public var body: some View {
        let zeroColumn = Array(repeating: GridItem(.flexible(), spacing: 3), count: viewStore.rule.zeroCount)
        let numbersColumn = Array(repeating: GridItem(.flexible(), spacing: 3), count: 3)

        VStack(alignment: .center, spacing: 3) {
            Spacer(minLength: 20)
            LazyVGrid(columns: zeroColumn, alignment: .center, spacing: 0, content: {
                ForEach(0 ..< viewStore.rule.zeroCount, id: \.self) { i in
                    makeLayoutCell(index: i)
                }
                }).offset(y: 0)
                .padding(.horizontal, 50)
            LazyVGrid(columns: numbersColumn, spacing: 3, content: {
                ForEach(viewStore.rule.zeroCount ..< viewStore.predictedData.endIndex, id: \.self) { i in
                    makeLayoutCell(index: i)
                }
                })
        }
    }

    @ViewBuilder
    func makeLayoutCell(index: Int) -> some View {
        let item = viewStore.predictedData[index]
        LayoutCell(isSelected: viewStore.selectedItem == item.item, data: item) { item in

            viewStore.send(.select(item))
        }
        .extend {
            #if os(macOS)
                $0.border(Color(nsColor: .separatorColor), width: 1)
            #else
                $0.border(Color(uiColor: .separator), width: 1)
            #endif
        }

        .border(item.item.number == viewStore.lastItem?.number ? .yellow : .clear, width: 2)
    }
}

struct LayoutCell: View {
    let isSelected: Bool
    let data: ItemWithOmomi
    let tapAction: (ItemWithOmomi) -> Void

    @ViewBuilder
    var body: some View {
        ZStack {
            if data.candidated {
                Color.orange.opacity(1)
            } else {
//                data.item.color.value.opacity((Double(data.omomi) / 100.0) + 0.05)
                data.item.color.value.opacity(0.1)
            }
            if isSelected { Color.accentColor }
            Text("\(data.item.number.str)")
                .foregroundColor(isSelected ? .white : .black)
                .padding(10)

        }.onTapGesture {
            tapAction(data)
        }.cornerRadius(4)
    }
}
