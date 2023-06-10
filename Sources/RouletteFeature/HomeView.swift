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

public struct HomeView: View {
    let store: Store<Roulette.State, Roulette.Action>
    @ObservedObject var viewStore: ViewStore<Roulette.State, Roulette.Action>

    public init(store: Store<Roulette.State, Roulette.Action>) {
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

        .sheet(
            item: viewStore.binding(get: \.activeSheet, send: { _ in
                Roulette.Action.hideSheet
            })
        ) { activeSheet in
            switch activeSheet {
            case .settings:
                let settingsStore = store.scope(state: \.settings, action: Roulette.Action.settings)
                SettingsView(store: settingsStore).extend {
#if os(macOS)
                    $0.padding()
#else
                    $0
#endif
                }
            case .tutorial:
                TutorialView()
            }
        }

        .onAppear {
            viewStore.send(.launch)
        }
        .safeAreaInset(edge: .top, alignment: .center, spacing: 0) {
            let historyStore = store.scope(state: \.history, action: Roulette.Action.history)
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
        .toolbar {
            ToolbarItem(placement: .navigation, content: {
                Button {
                    viewStore.send(.setSettingsViewPresent)
                } label: {
                    Image(systemName: "gear")
                }
            })

            ToolbarItem(placement: .navigation, content: {
                Button {
                    if !viewStore.history.items.isEmpty {
                        viewStore.send(.history(.removeLast))
                    }
                } label: {
                    Image(systemName: "trash")
                }.disabled(viewStore.history.items.isEmpty)
            })
        }
    }

    @ViewBuilder
    var mainContents: some View {

        let wheelStore = store.scope(state: {
            WheelView.ViewState(
                calucuratedData: $0.wheelData,
                selectedItem: $0.selectedForPrediction,
                lastItem: viewStore.history.limitedHistory.last?.item,
                mode: viewStore.wheel.mode,
                omomiWidthForPrediction: $0.settings.omomiWidthForPrediction
            )
        }, action: { Roulette.Action.wheel($0) })

        let layoutStore = store.scope(state: {
            LayoutView.ViewState(
                rule: $0.settings.rule,
                predictedData: $0.layoutData,
                selectedItem: $0.layout.selectedItemForAdding,
                lastItem: viewStore.history.limitedHistory.last?.item
            )
        }, action: { Roulette.Action.layout($0) })
        LayoutView(store: layoutStore).padding(.bottom, 44).padding(8)
        WheelView(store: wheelStore).frame(width: 330)

    }
}

extension Bool: Identifiable {
    public var id: Bool { self }
}
