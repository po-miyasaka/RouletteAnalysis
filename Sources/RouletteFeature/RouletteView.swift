//
//  ContentView.swift
//  RouletteAnalysis
//
//  Created by po_miyasaka on 2023/05/27.
//

import ComposableArchitecture
import Item
import SwiftUI
import Tutorial
import Utility

public struct RouletteView: View {
    public struct ViewState: Equatable {
        var roulette: Roulette.State
        var settings: Settings.State

        init(roulette: Roulette.State, settings: Settings.State) {
            self.roulette = roulette
            self.settings = settings
        }

        public var wheelData: [ItemWithOmomi] {
            makeWheelData(history: roulette.history.limitedHistory.map(\.item),
                          omomiWidthForSelecting: settings.omomiWidthForPrediction,
                          omomiWidthForHistory: settings.omomiWidthForHistory,
                          rule: settings.rule,
                          selectedItem: roulette.selectedForPrediction)
        }

        public var layoutData: [ItemWithOmomi] {
            makeLayoutData(history: roulette.history.limitedHistory.map(\.item), omomiWidthForSelecting: settings.omomiWidthForPrediction, omomiWidthForHistory: settings.omomiWidthForHistory, rule: settings.rule, selectedItem: roulette.selectedForPrediction)
        }

        public var activeSheet: ActiveSheet?
        public enum ActiveSheet: String, Equatable, Identifiable {
            public var id: String { rawValue }
            case settings
            case tutorial
        }
    }

    let store: Store<ViewState, Roulette.Action>
    @ObservedObject var viewStore: ViewStore<ViewState, Roulette.Action>

    public init(store: Store<ViewState, Roulette.Action>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    @ViewBuilder
    public var body: some View {
        Group {
            #if os(macOS)
                ScrollView {
                    mainContents
                }
            #else

                if viewStore.settings.screenLayout == .tab {
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
            viewStore.send(.onAppear)
        }
        .safeAreaInset(edge: .top, alignment: .center, spacing: 0) {
            let historyStore = store.scope(state: \.roulette.history, action: Roulette.Action.history)
            HistoryView(store: historyStore).extend {
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
        let wheelStore = store.scope(state: {
            WheelView.ViewState(
                calucuratedData: $0.wheelData,
                selectedItem: $0.roulette.selectedForPrediction,
                lastItem: viewStore.roulette.history.limitedHistory.last?.item,
                mode: viewStore.roulette.wheel.mode,
                omomiWidthForPrediction: $0.settings.omomiWidthForPrediction
            )
        }, action: { Roulette.Action.wheel($0) })

        let layoutStore = store.scope(state: {
            LayoutView.ViewState(
                rule: $0.settings.rule,
                predictedData: $0.layoutData,
                selectedItem: $0.roulette.layout.selectedItemForAdding,
                lastItem: viewStore.roulette.history.limitedHistory.last?.item
            )
        }, action: { Roulette.Action.layout($0) })
        ScrollView(showsIndicators: false) {
            LayoutView(store: layoutStore).padding(.bottom, 44).padding(8)
        }
        WheelView(store: wheelStore).frame(width: 330)
    }
}

extension Bool: Identifiable {
    public var id: Bool { self }
}
