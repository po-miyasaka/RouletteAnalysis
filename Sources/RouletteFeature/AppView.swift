//
//  File.swift
//
//
//  Created by po_miyasaka on 2023/06/12.
//

import ComposableArchitecture
import Item
import SwiftUI
import Tutorial
import Utility

public struct AppView: View {
    let store: StoreOf<AppFeature>
    @ObservedObject var viewStore: ViewStore<AppFeature.State, AppFeature.Action>

    public init(store: StoreOf<AppFeature>) {
        self.store = store
        viewStore = ViewStore(store)
    }

    @ViewBuilder
    public var body: some View {
        Group {
            IfLetStore(store.scope(state: { state in
                state.current.flatMap { RouletteView.ViewState(roulette: $0, settings: state.settings) }
            }, action: AppFeature.Action.roulette), then: { store in
                RouletteView(store: store)
            }) // stateが無いときは何も返さないしonAppearも呼ばれない。
            EmptyView()
        }
        .onAppear {
            viewStore.send(.onAppear)
        }
        .extend {
            #if os(macOS)

                $0
            #else
                $0.onReceive(NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)) { _ in
                    // TODO: Dependency利用 (しなくてもいいかも)
                    viewStore.send(.save)
                }
            #endif
        }

        .extend {
            #if os(macOS)
                $0.alert(item: viewStore.binding(get: \.activeAlert, send: { value in AppFeature.Action.alert(value) }), content: { item in

                    Alert(title: Text(item.rawValue), primaryButton: .destructive(Text("Close this roulette")) {
                        viewStore.send(.closeRoulette)
                }, secondaryButton: .cancel(Text("Cancel")))

            })
            #else
                $0.actionSheet(item: viewStore.binding(get: \.activeAlert, send: { value in AppFeature.Action.alert(value) }), content: { item in

                    ActionSheet(title: Text(item.rawValue), buttons: [
                        .destructive(Text("Close this roulette")) {
                            viewStore.send(.closeRoulette)
                        },
                        .cancel(),
                    ])
            })
            #endif
        }

        .sheet(
            item: viewStore.binding(
                get: \.activeSheet,
                send: { _ in AppFeature.Action.hideSheet }
            )
        ) { activeSheet in
            switch activeSheet {
            case .settings:
                let settingsStore = store.scope(state: { $0.settings }, action: { AppFeature.Action.settings($0) })

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

        .toolbar {
            #if os(macOS)
                let placement: ToolbarItemPlacement = .navigation

            #elseif os(iOS)
                let placement: ToolbarItemPlacement = .navigationBarTrailing
            #endif

            ToolbarItem(placement: .navigation, content: {
                Button {
                    viewStore.send(.setSettingsViewPresent)
                } label: {
                    Image(systemName: "gear")
                }
            })
            ToolbarItem(placement: placement, content: {
                Picker(
                    "Select Roulette",
                    selection: viewStore.binding(get: { $0.current?.id ?? .init() }, send: { AppFeature.Action.select($0) }),
                    content: {
                        ForEach(
                            Array(zip(0 ..< viewStore.state.roulettes.endIndex, viewStore.state.roulettes)),
                            id: \.1.id
                        ) { num, data in
                            Text("No.\(num + 1) (\(String(data.id.uuidString.prefix(4))))").frame(alignment: .leading)
                        }
                    }
                ).pickerStyle(MenuPickerStyle())
            })
            ToolbarItem(placement: placement, content: {
                Button(action: {
                    viewStore.send(.newRoulette)
                }, label: {
                    Image(systemName: "plus.square.on.square.fill")
                })

            })

            ToolbarItem(placement: placement, content: {
                Button(action: {
                    viewStore.send(.alert(.close))
                }, label: {
                    Image(systemName: "xmark.circle")

                })

            })
        }
    }
}
