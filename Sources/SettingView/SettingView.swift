//
//  SwiftUIView.swift
//
//
//  Created by po_miyasaka on 2023/05/31.
//

import ComposableArchitecture
import Feedback
import Item
import Setting
import SwiftUI
import Tutorial
import Utility

#if canImport(Ad)
    import Ad
#endif

public struct SettingView: View {
    // 汎用的なSettingにViewのロジックが含まれないようにするために試しに専用のReducerをつくってみた。
    // BindingなどでStateとActionの型がきまっているために、Reducer同士で連携するのは厳しそう。
    public struct ViewReducer: ReducerProtocol {
        public struct State: Equatable, Identifiable {
            public init() {}
            public var id: String { activeSheet?.rawValue ?? "" }
            public var activeSheet: ActiveSheet?
        }

        public enum Action {
            case setActiveSheet(ActiveSheet?)
        }

        public enum ActiveSheet: String, Identifiable {
            public var id: String { rawValue }
            case tutorial
            case feedback
        }

        public func reduce(into state: inout State, action: Action) -> ComposableArchitecture.EffectTask<Action> {
            switch action {
            case let .setActiveSheet(activeSheet):
                state.activeSheet = activeSheet
                return .none
            }
        }
    }

    @ObservedObject var settingsViewStore: ViewStore<Setting.State, Setting.Action>
    @StateObject var viewStore: ViewStore<ViewReducer.State, ViewReducer.Action> = .init(StoreOf<ViewReducer>(initialState: ViewReducer.State(), reducer: ViewReducer()), observe: { $0 })
    public init(store: Store<Setting.State, Setting.Action>) {
        settingsViewStore = ViewStore(store)
    }

    @Environment(\.dismiss) var dismiss

    public var body: some View {
        #if os(macOS)
            WithCloseButton(dismissAction: { dismiss() }) {
                form()
                    .sheet(
                        item: viewStore.binding(
                            get: { state in
                                state.activeSheet
                            },
                            send: { ViewReducer.Action.setActiveSheet($0) }
                        )
                    ) {
                        switch $0 {
                        case .tutorial:
                            TutorialView().padding()
                        case .feedback:
                            FeedbackView(store: .init(initialState: .init(), reducer: FeedbackFeature())).padding()
                        }
                    }
            }

        #else
            NavigationView {
                VStack {
                    form().formStyle(GroupedFormStyle())
                    #if canImport(Ad)
                        if !settingsViewStore.isHidingAd {
                            AdBannerView(place: .settingBottom).background(.gray).frame(height: 300)
                        }
                    #endif
                }
            }
            .overlay {
                if settingsViewStore.isConnecting {
                    ProgressView().progressViewStyle(CircularProgressViewStyle())
                }
            }
        #endif
    }

    @ViewBuilder
    func form() -> some View {
        Form {
            Section {
                Picker("Roulette Type", selection: settingsViewStore.binding(get: \.rule, send: Setting.Action.showChangeRuleAlert)) {
                    ForEach(Rule.allCases, id: \.self) { rule in
                        Text(rule.displayName)
                    }
                }

                Picker("Prediction width", selection: settingsViewStore.binding(get: \.weightWidthForPrediction, send: Setting.Action.changeWeightForPrediction)) {
                    ForEach(WeightWidth.allCases, id: \.self) { weight in
                        Text(weight.displayValue)
                    }
                }

                Picker("History width", selection: settingsViewStore.binding(get: \.weightWidthForHistory, send: Setting.Action.changeWeightForHistory)) {
                    ForEach(WeightWidth.allCases, id: \.self) { weight in
                        Text(weight.displayValue)
                    }
                }

                Picker("Default Displayed History Limit", selection: settingsViewStore.binding(get: \.defaultDisplayedHistoryLimit, send: Setting.Action.changeDefaultDisplayedHistoryLimit)) {
                    ForEach(1 ... 100, id: \.self) { displayedLimit in
                        Text("\(displayedLimit)")
                    }
                }
                #if os(macOS)
                #else
                    Picker("Screen Layout", selection: settingsViewStore.binding(get: \.screenLayout, send: Setting.Action.changeScreenLayout)) {
                        ForEach(Setting.ScreenLayout.allCases, id: \.self) { screenLayout in
                            Text("\(screenLayout.rawValue)")
                        }
                    }
                #endif
            }

            #if !os(macOS)
                hideAdSection()
            #endif

            feedbackSection()
            tutorialSection()
        }
        .extend {
            #if os(macOS)

                $0.alert(item: settingsViewStore.binding(get: { $0.activeAlert }, send: { v in Setting.Action.alert(v) }), content: { alert in
                    Alert(title: Text(alert.displayText), primaryButton:
                        .destructive(Text("Change")) {
                            if let rule = alert.rule { settingsViewStore.send(.changeRule(rule)) }
                        },
                          secondaryButton: .cancel())
            })
            #else
                $0.actionSheet(item: settingsViewStore.binding(get: { $0.activeAlert }, send: { v in Setting.Action.alert(v) }), content: { alert in

                    ActionSheet(title: Text(alert.displayText), buttons: [
                        .destructive(Text("Change")) {
                            if let rule = alert.rule { settingsViewStore.send(.changeRule(rule)) }
                        },
                        .cancel()
                    ])
            })
                    .alert(item: settingsViewStore.binding(get: { $0.activeAlert }, send: { v in Setting.Action.alert(v) }), content: { alert in
                        Alert(title: Text(alert.displayText))
            })
            #endif
        }
    }

    @ViewBuilder
    func hideAdSection() -> some View {
        #if os(macOS)
            EmptyView()
        #else
            Section {
                Button("Hide Advertisement", action: {
                    settingsViewStore.send(.buyHiddingAd)
            })

                Button("Restore purchase", action: {
                    settingsViewStore.send(.restore)
            })
            }
        #endif
    }

    @ViewBuilder
    func feedbackSection() -> some View {
        Section {
            #if os(macOS)
                Button("Request / Feedback", action: {
                    viewStore.send(.setActiveSheet(.feedback))
            })

            #else
                NavigationLink<Text, FeedbackView>("Request / Feedback", destination: {
                    FeedbackView(store: .init(initialState: .init(), reducer: FeedbackFeature()))
            })
            #endif
        }
    }

    @ViewBuilder
    func tutorialSection() -> some View {
        Section(
            content: {
                #if os(macOS)
                    Button("Tutorial", action: {
                        viewStore.send(.setActiveSheet(.tutorial))
                })

                #else
                    NavigationLink("Tutorial", destination: {
                        TutorialView()
                })
                #endif
            },
            footer: {
                HStack {
                    Spacer()
                    Text("Version: \(Bundle.main.releaseVersionNumber)")
                    Spacer()
                }
                .padding()
            }
        )
    }
}
