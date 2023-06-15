//
//  SwiftUIView.swift
//
//
//  Created by po_miyasaka on 2023/05/31.
//

import ComposableArchitecture
import Feedback
import Item
import SwiftUI
import Tutorial
import UserDefaultsClient
import Utility

public struct Settings: ReducerProtocol {
    @Dependency(\.userDefaults) var userDefaults
    public struct State: Equatable {
        public var omomiWidthForPrediction: OmomiWidth = .seven
        public var omomiWidthForHistory: OmomiWidth = .five
        public var rule: Rule = .theStar
        public var defaultDisplayedHistoryLimit: Int = 16
        public var screenLayout: ScreenLayout = .tab
        public var activeAlert: ActiveAlert?
    }

    public enum Action: Equatable {
        case changeRule(Rule)
        case showChangeRuleAlert(Rule)
        case changeOmomiForPrediction(OmomiWidth)
        case changeOmomiForHistory(OmomiWidth)
        case changeDefaultDisplayedHistoryLimit(Int)
        case changeScreenLayout(ScreenLayout)
        case setup
        case alert(ActiveAlert?)
    }

    public enum ActiveAlert: Equatable, Identifiable {
        public var id: String { displayText }
        case change(Rule)

        var displayText: String {
            switch self {
            case .change:
                return "Changing a rule deletes past data. \n Would you like to change the rule?"
            }
        }

        var rule: Rule? {
            switch self {
            case let .change(rule):
                return rule
            }
        }
    }

    public func reduce(into state: inout State, action: Action) -> ComposableArchitecture.EffectTask<Action> {
        switch action {
        case let .showChangeRuleAlert(rule):

            return .task {
                return .alert(.change(rule))
            }
        case let .changeRule(rule):
            state.rule = rule
            return .fireAndForget {
                await userDefaults.setRule(rule.rawValue)
            }
        case let .changeOmomiForPrediction(omomiForPrediction):
            state.omomiWidthForPrediction = omomiForPrediction
            return .fireAndForget {
                await userDefaults.setOmoiWidthForPrediction(omomiForPrediction.rawValue)
            }
        case let .changeOmomiForHistory(omomiForHistory):
            state.omomiWidthForHistory = omomiForHistory
            return .fireAndForget {
                await userDefaults.setOmoiWidthForHistory(omomiForHistory.rawValue)
            }
        case let .changeDefaultDisplayedHistoryLimit(value):
            state.defaultDisplayedHistoryLimit = value
            return .fireAndForget {
                await userDefaults.setDefaultDisplayedHistoryLimit(value)
            }
        case let .changeScreenLayout(value):
            state.screenLayout = value
            return .fireAndForget {
                await userDefaults.setScreenLayout(value.rawValue)
            }
        case .setup:
            state.rule = userDefaults.rule.flatMap(Rule.init(rawValue:)) ?? .theStar
            state.omomiWidthForPrediction = userDefaults.omomiWidthForPrediction.flatMap(OmomiWidth.init(rawValue:)) ?? .seven
            state.omomiWidthForHistory = userDefaults.omomiWidthForHistory.flatMap(OmomiWidth.init(rawValue:)) ?? .five

            state.defaultDisplayedHistoryLimit = userDefaults.defaultDisplayedHistoryLimit ?? 16
            state.screenLayout = userDefaults.screenLayout.flatMap(ScreenLayout.init(rawValue:)) ?? .tab
            return .none
        case let .alert(value):
            state.activeAlert = value
            return .none
        }
    }

    public enum ScreenLayout: String, CaseIterable {
        case tab
        case vertical
    }
}

struct SettingsView: View {
    // 汎用的なSettingにViewのロジックが含まれないようにするために試しに専用のReducerをつくってみた。
    // BindingなどでStateとActionの型がきまっているために、Reducer同士で連携するのは厳しそう。
    struct ViewReducer: ReducerProtocol {
        struct State: Equatable, Identifiable {
            var id: String { activeSheet?.rawValue ?? "" }
            var activeSheet: ActiveSheet?
        }

        enum Action {
            case setActiveSheet(ActiveSheet?)
        }

        enum ActiveSheet: String, Identifiable {
            var id: String { rawValue }
            case tutorial
            case feedback
        }

        func reduce(into state: inout State, action: Action) -> ComposableArchitecture.EffectTask<Action> {
            switch action {
            case let .setActiveSheet(activeSheet):
                state.activeSheet = activeSheet
                return .none
            }
        }
    }

    @ObservedObject var settingsViewStore: ViewStore<Settings.State, Settings.Action>
    @StateObject var viewStore: ViewStore<ViewReducer.State, ViewReducer.Action> = .init(StoreOf<ViewReducer>(initialState: ViewReducer.State(), reducer: ViewReducer()), observe: { $0 })
    init(store: Store<Settings.State, Settings.Action>) {
        settingsViewStore = ViewStore(store)
    }

    @Environment(\.dismiss) var dismiss

    var body: some View {
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
            NavigationView { form().formStyle(GroupedFormStyle()) }
        #endif
    }

    @ViewBuilder
    func form() -> some View {
        Form {
            Section {
                Picker("Roulette Type", selection: settingsViewStore.binding(get: \.rule, send: Settings.Action.showChangeRuleAlert)) {
                    ForEach(Rule.allCases, id: \.self) { rule in
                        Text(rule.displayName)
                    }
                }

                Picker("Prediction width", selection: settingsViewStore.binding(get: \.omomiWidthForPrediction, send: Settings.Action.changeOmomiForPrediction)) {
                    ForEach(OmomiWidth.allCases, id: \.self) { omomi in
                        Text(omomi.displayValue)
                    }
                }

                Picker("History width", selection: settingsViewStore.binding(get: \.omomiWidthForHistory, send: Settings.Action.changeOmomiForHistory)) {
                    ForEach(OmomiWidth.allCases, id: \.self) { omomi in
                        Text(omomi.displayValue)
                    }
                }

                Picker("Default Displayed History Limit", selection: settingsViewStore.binding(get: \.defaultDisplayedHistoryLimit, send: Settings.Action.changeDefaultDisplayedHistoryLimit)) {
                    ForEach(1 ... 100, id: \.self) { displayedLimit in
                        Text("\(displayedLimit)")
                    }
                }
                #if os(macOS)
                #else
                    Picker("Screen Layout", selection: settingsViewStore.binding(get: \.screenLayout, send: Settings.Action.changeScreenLayout)) {
                        ForEach(Settings.ScreenLayout.allCases, id: \.self) { screenLayout in
                            Text("\(screenLayout.rawValue)")
                        }
                    }
                #endif
            }
            feedbackSection()

            tutorialSection()
        }
        .extend {
#if os(macOS)
            
            $0.alert(item: settingsViewStore.binding(get: { $0.activeAlert }, send: { v in Settings.Action.alert(v) }), content: { alert in
                
                Alert(title: Text(alert.displayText), primaryButton:
                    .destructive(Text("Change")) {
                        if let rule = alert.rule { settingsViewStore.send(.changeRule(rule)) }
                    },
                    secondaryButton: .cancel()
                )

            })
#else
            $0.actionSheet(item: settingsViewStore.binding(get: { $0.activeAlert }, send: { v in Settings.Action.alert(v) }), content: { alert in
                
                ActionSheet(title: Text(alert.displayText), buttons: [
                    .destructive(Text("Change")) {
                        if let rule = alert.rule { settingsViewStore.send(.changeRule(rule)) }
                    },
                    .cancel(),
                ])

            })
#endif
        }
        
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
