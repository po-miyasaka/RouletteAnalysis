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
    }

    public enum Action: Equatable {
        case changeRule(Rule)
        case changeOmomiForPrediction(OmomiWidth)
        case changeOmomiForHistory(OmomiWidth)
        case changeDefaultDisplayedHistoryLimit(Int)
        case setup
    }

    public func reduce(into state: inout State, action: Action) -> ComposableArchitecture.EffectTask<Action> {
        switch action {
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
        case .setup:
            state.rule = userDefaults.rule.flatMap(Rule.init(rawValue:)) ?? .theStar
            state.omomiWidthForPrediction = userDefaults.omomiWidthForPrediction.flatMap(OmomiWidth.init(rawValue:)) ?? .seven
            state.omomiWidthForHistory = userDefaults.omomiWidthForHistory.flatMap(OmomiWidth.init(rawValue:)) ?? .five

            state.defaultDisplayedHistoryLimit = userDefaults.defaultDisplayedHistoryLimit ?? 16
            return .none
        case let .changeDefaultDisplayedHistoryLimit(value):
            state.defaultDisplayedHistoryLimit = value
            return .fireAndForget {
                await userDefaults.setDefaultDisplayedHistoryLimitKey(value)
            }
        }
    }
}

struct SettingsView: View {
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
                Picker("Roulette Type", selection: settingsViewStore.binding(get: \.rule, send: Settings.Action.changeRule)) {
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
            }
            feedbackSection()

            tutorialSection()
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
                    Text("Version: \(Bundle.main.releaseVersionNumber ?? "Unknown")")
                    Spacer()
                }
                .padding()
            }
        )
    }
}

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }

    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
