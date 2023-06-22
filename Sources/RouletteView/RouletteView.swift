//
//  ContentView.swift
//  RouletteAnalysis
//
//  Created by po_miyasaka on 2023/05/27.
//

import ComposableArchitecture
import Item
import SwiftUI
import Roulette
import Setting
import HistoryView
import WheelView
import TableLayoutView

public struct RouletteView: View {

    @ObservedObject var rouletteViewStore: ViewStoreOf<Roulette>
    @ObservedObject var settingViewStore: ViewStoreOf<Setting>
    let rouletteStore: StoreOf<Roulette>
    let settingStore: StoreOf<Setting>
    public init(rouletteStore: StoreOf<Roulette>, settingStore: StoreOf<Setting>) {
        self.rouletteViewStore = ViewStore(rouletteStore)
        self.settingViewStore = ViewStore(settingStore)
        self.rouletteStore = rouletteStore
        self.settingStore = settingStore
    }

    @ViewBuilder
    public var body: some View {
        Group {
            #if os(macOS)
                ScrollView {
                    mainContents
                }
            #else

                if settingViewStore.screenLayout == .tab {
                    TabView {
                        mainContents
                    }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .always)) // this makes it a paging scroll view
                        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                } else {
                    ScrollView {
                        mainContents
                    }
                }

            #endif
        }

        .onAppear {
            rouletteViewStore.send(.onAppear)
        }
        .safeAreaInset(edge: .top, alignment: .center, spacing: 0) {
            
            HistoryView(store: rouletteStore.historyStore).extend {
                    #if os(macOS)
                        $0.padding(.horizontal, 8)
                    #else
                        $0
                    #endif
                }
            
            
        }
        .extend {
            #if os(iOS)
                if #available(iOS 16.0, *) {
                    $0.toolbar(.visible, for: ToolbarPlacement.navigationBar)
                }
            #else
                $0
            #endif
        }
    }

    @ViewBuilder
    var mainContents: some View {

        ScrollView(showsIndicators: false) {
            TableLayoutView(rouletteStore: rouletteStore, settingStore: settingStore).padding(.bottom, 44).padding(8)
        }
        WheelView(rouletteStore: rouletteStore, settingStore: settingStore).frame(width: 330)
    }
}

extension Bool: Identifiable {
    public var id: Bool { self }
}


public func layoutData(roulette: Roulette.State, setting: Setting.State) -> [ItemWithWeight] {
        makeLayoutData(
            history: roulette.history.limitedHistory.map(\.item),
            weightWidthForSelecting: setting.weightWidthForPrediction,
            weightWidthForHistory: setting.weightWidthForHistory,
            rule: setting.rule,
            selectedItem: roulette.selectedForPrediction
        )
}
