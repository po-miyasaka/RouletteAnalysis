//
//  File.swift
//  
//
//  Created by po_miyasaka on 2023/06/20.
//

import ComposableArchitecture
import Item
import SwiftUI
import UserDefaultsClient
import Utility

public struct Setting: ReducerProtocol {
    @Dependency(\.userDefaults) var userDefaults
    public init() {}
    public struct State: Equatable {
        public var weightWidthForPrediction: WeightWidth = .seven
        public var weightWidthForHistory: WeightWidth = .five
        public var rule: Rule = .theStar
        public var defaultDisplayedHistoryLimit: Int = 16
        public var screenLayout: ScreenLayout = .tab
        public var activeAlert: ActiveAlert?
        public init() {}
    }

    public enum Action: Equatable {
        case changeRule(Rule)
        case showChangeRuleAlert(Rule)
        case changeWeightForPrediction(WeightWidth)
        case changeWeightForHistory(WeightWidth)
        case changeDefaultDisplayedHistoryLimit(Int)
        case changeScreenLayout(ScreenLayout)
        case setup
        case alert(ActiveAlert?)
    }

    public enum ActiveAlert: Equatable, Identifiable {
        public var id: String { displayText }
        case change(Rule)

        public var displayText: String {
            switch self {
            case .change:
                return "Changing a rule deletes past data. \n Would you like to change the rule ?"
            }
        }

        public var rule: Rule? {
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
        case let .changeWeightForPrediction(weightForPrediction):
            state.weightWidthForPrediction = weightForPrediction
            return .fireAndForget {
                await userDefaults.setOmoiWidthForPrediction(weightForPrediction.rawValue)
            }
        case let .changeWeightForHistory(weightForHistory):
            state.weightWidthForHistory = weightForHistory
            return .fireAndForget {
                await userDefaults.setOmoiWidthForHistory(weightForHistory.rawValue)
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
            state.weightWidthForPrediction = userDefaults.weightWidthForPrediction.flatMap(WeightWidth.init(rawValue:)) ?? .seven
            state.weightWidthForHistory = userDefaults.weightWidthForHistory.flatMap(WeightWidth.init(rawValue:)) ?? .five

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
