//
//  File.swift
//
//
//  Created by po_miyasaka on 2023/05/28.
//

import ComposableArchitecture
import Item
import Roulette
import Setting
import SwiftUI
import TableLayout
import Utility

public struct TableLayoutView: View {
    @ObservedObject var tableLayoutViewStore: ViewStoreOf<TableLayout>
    @ObservedObject var rouletteViewStore: ViewStoreOf<Roulette>
    @ObservedObject var settingViewStore: ViewStoreOf<Setting>
    let rouletteStore: StoreOf<Roulette>
    let settingStore: StoreOf<Setting>

    public init(rouletteStore: StoreOf<Roulette>, settingStore: StoreOf<Setting>) {
        rouletteViewStore = ViewStore(rouletteStore)
        settingViewStore = ViewStore(settingStore)
        self.rouletteStore = rouletteStore
        self.settingStore = settingStore
        tableLayoutViewStore = ViewStore(rouletteStore.tableLayoutStore)
    }

    public var body: some View {
        let predictedData = layoutData(roulette: rouletteViewStore.state, setting: settingViewStore.state)
        let zeroColumn = Array(repeating: GridItem(.flexible(), spacing: 3), count: settingViewStore.rule.zeroCount)
        let numbersColumn = Array(repeating: GridItem(.flexible(), spacing: 3), count: 3)

        VStack(alignment: .center, spacing: 3) {
            Spacer(minLength: 20)
            LazyVGrid(columns: zeroColumn, alignment: .center, spacing: 0, content: {
                ForEach(0 ..< settingViewStore.rule.zeroCount, id: \.self) { i in
                    makeLayoutCell(predictedData: predictedData, index: i)
                }
                }).offset(y: 0)
                .padding(.horizontal, 50)
            LazyVGrid(columns: numbersColumn, spacing: 3, content: {
                ForEach(settingViewStore.rule.zeroCount ..< predictedData.endIndex, id: \.self) { i in
                    makeLayoutCell(predictedData: predictedData, index: i)
                }
                })
        }
    }

    @ViewBuilder
    func makeLayoutCell(predictedData: [ItemWithWeight], index: Int) -> some View {
        let item = predictedData[index]
        LayoutCell(isSelected: tableLayoutViewStore.selectedItemForAdding == item.item, data: item) { item in

            tableLayoutViewStore.send(.select(item))
        }
        .extend {
            #if os(macOS)
                $0.border(Color(nsColor: .separatorColor), width: 1)
            #else
                $0.border(Color(uiColor: .separator), width: 1)
            #endif
        }

        .border(item.item.number == rouletteViewStore.history.limitedHistory.last?.item.number ? .yellow : .clear, width: 2)
    }
}

struct LayoutCell: View {
    let isSelected: Bool
    let data: ItemWithWeight
    let tapAction: (ItemWithWeight) -> Void

    @ViewBuilder
    var body: some View {
        ZStack {
            if data.candidated {
                Color.orange.opacity(1)
            } else {
//                data.item.color.value.opacity((Double(data.weight) / 100.0) + 0.05)
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

public func layoutData(
    roulette: Roulette.State,
    setting: Setting.State
) -> [ItemWithWeight] {
    makeLayoutData(
        history: roulette.history.limitedHistory.map(\.item),
        weightWidthForSelecting: setting.weightWidthForPrediction,
        weightWidthForHistory: setting.weightWidthForHistory,
        rule: setting.rule,
        selectedItem: roulette.selectedForPrediction
    )
}
