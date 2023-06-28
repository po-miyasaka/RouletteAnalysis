//
//  ContentView.swift
//  RouletteAnalysis
//
//  Created by po_miyasaka on 2023/05/27.
//

import ComposableArchitecture
import HistoryView
import Item
import Roulette
import Setting
import SwiftUI
import TableLayoutView
import WheelView
#if canImport(Ad)
import Ad
#endif

public struct RouletteView: View {
    @ObservedObject var rouletteViewStore: ViewStoreOf<Roulette>
    @ObservedObject var settingViewStore: ViewStoreOf<Setting>
    let rouletteStore: StoreOf<Roulette>
    let settingStore: StoreOf<Setting>
    public init(rouletteStore: StoreOf<Roulette>, settingStore: StoreOf<Setting>) {
        rouletteViewStore = ViewStore(rouletteStore)
        settingViewStore = ViewStore(settingStore)
        self.rouletteStore = rouletteStore
        self.settingStore = settingStore
    }

    @ViewBuilder
    public var body: some View {
        Group {
#if os(macOS)
            ScrollView {
                ScrollView(showsIndicators: false) {
                    TableLayoutView(rouletteStore: rouletteStore, settingStore: settingStore).padding(.bottom, 44).padding(8)
                }
                WheelView(rouletteStore: rouletteStore, settingStore: settingStore).frame(width: 330)
            }
#else

            if settingViewStore.screenLayout == .tab {
                TabView {
                    ScrollView(showsIndicators: false) {
                        TableLayoutView(rouletteStore: rouletteStore, settingStore: settingStore).padding(.bottom, 44).padding(8)
                    }
                    if !settingViewStore.isHidingAd {
                        VStack {
                            Text("Ad").font(.caption).padding(4)
                            AdBannerView(place: .rouletteTab).background(.gray).frame(height: 500)
                        }

                    }
                    WheelView(rouletteStore: rouletteStore, settingStore: settingStore).frame(width: 330)

                }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .always)) // this makes it a paging scroll view
                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ScrollView(showsIndicators: false) {
                            TableLayoutView(rouletteStore: rouletteStore, settingStore: settingStore).padding(.bottom, 44).padding(.horizontal, 8)
                        }
                        WheelView(rouletteStore: rouletteStore, settingStore: settingStore).frame(width: 330)
                        if !settingViewStore.isHidingAd {
                            AdBannerView(place: .rouletteTab).frame(width: 320, height: 500).background(.gray)
                        }
                    }

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
