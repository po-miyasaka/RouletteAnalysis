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
                _bodyForMac()
            #else
                _bodyForiOS()
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
    func _bodyForMac() -> some View {
        ScrollView {
            ScrollView(showsIndicators: false) {
                TableLayoutView(rouletteStore: rouletteStore, settingStore: settingStore).padding(.bottom, 44).padding(8)
            }
            WheelView(rouletteStore: rouletteStore, settingStore: settingStore).frame(width: 330)
        }
    }

    @ViewBuilder
    func _bodyForiOS() -> some View {
        if settingViewStore.screenLayout == .tab {
            tabLayout()
        } else {
            scrollLayout()
        }
    }

    @ViewBuilder
    func tabLayout() -> some View {
        TabView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 8) {
                    TableLayoutView(rouletteStore: rouletteStore, settingStore: settingStore).padding(.horizontal, 8)
                    #if canImport(Ad)
                        if !settingViewStore.isHidingAd {
                            Text("Ad").font(.caption)
                            AdBannerView(place: .rouletteTab).background(.gray).frame(height: 400)
                        }
                    #endif
                }
            }
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    WheelView(rouletteStore: rouletteStore, settingStore: settingStore).frame(width: 330).padding(.top, 24)

                    #if canImport(Ad)
                        if !settingViewStore.isHidingAd {
                            AdBannerView(place: .wheelTabBottom).background(.gray).frame(height: 400)
                        }
                    #endif
                }
            }

        }.extend {
            #if !os(macOS)
            $0.tabViewStyle(PageTabViewStyle(indexDisplayMode: .always)) // this makes it a paging scroll view
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            #else
            $0
            #endif
        }
        
    }

    func scrollLayout() -> some View {
        ScrollView {
            VStack(spacing: 16) {
                ScrollView(showsIndicators: false) {
                    TableLayoutView(rouletteStore: rouletteStore, settingStore: settingStore).padding(.bottom, 44).padding(.horizontal, 8)
                }
                WheelView(rouletteStore: rouletteStore, settingStore: settingStore).frame(width: 330)

                #if canImport(Ad)
                    if !settingViewStore.isHidingAd {
                        AdBannerView(place: .rouletteTab).frame(width: 320, height: 500).background(.gray)
                    }
                #endif
            }
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
