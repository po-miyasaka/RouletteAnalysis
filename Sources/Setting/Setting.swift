//
//  File.swift
//
//
//  Created by po_miyasaka on 2023/06/20.
//

import ComposableArchitecture
import InAppPurchase
import Item
import SwiftUI
import UserDefaultsClient
import Utility

// TODO: SettingとしてRouletteの情報を外に出していることでアプリ全体では扱いにくくなってる感ある。基本は各Reducerにインジェクトしたい情報はdependenciesを使うのが意味的にも良いかもしれない。それ以外の設定をこのSettingに任せるとかがいいかも
public struct Setting: ReducerProtocol {
    @Dependency(\.userDefaults) var userDefaults
    @Dependency(\.inAppPurchase) var inAppPurchase
    public init() {}
    public struct State: Equatable {
        public var weightWidthForPrediction: WeightWidth = .seven
        public var weightWidthForHistory: WeightWidth = .five
        public var rule: Rule = .theStar
        public var defaultDisplayedHistoryLimit: Int = 16
        public var screenLayout: ScreenLayout = .tab
        public var activeAlert: ActiveAlert?
        public var isHidingAd: Bool = false
        public var isConnecting: Bool = false
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
        case buyHiddingAd
        case restore
        case hideAd
        case setConnecting(Bool)
    }

    public enum ActiveAlert: Equatable, Identifiable {
        public var id: String { displayText }
        case change(Rule)
        case purchase(String)

        public var displayText: String {
            switch self {
            case .change:
                return "Changing a rule deletes past data. \n Would you like to change the rule ?"
            case let .purchase(text):
                return text
            }
        }

        public var rule: Rule? {
            switch self {
            case let .change(rule):
                return rule
            case .purchase:
                return nil
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
                await userDefaults.setWeightWidthForPrediction(weightForPrediction.rawValue)
            }
        case let .changeWeightForHistory(weightForHistory):
            state.weightWidthForHistory = weightForHistory
            return .fireAndForget {
                await userDefaults.setWeightWidthForHistory(weightForHistory.rawValue)
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
            state.isHidingAd = userDefaults.isHidingAd
            state.screenLayout = userDefaults.screenLayout.flatMap(ScreenLayout.init(rawValue:)) ?? .tab
            return .none
        case let .alert(value):
            state.activeAlert = value
            return .none

        case .hideAd:
            state.isHidingAd = true
            return .none
        case .buyHiddingAd:

            return .run { send in
                await send(.setConnecting(true))
                let result = await inAppPurchase.buy(.adFree)
                switch result {
                case .purchased, .restored:
                    await userDefaults.setIsHidingAd(true)
                    await send(.hideAd)
                case .failed:
                    break
                }
                await send(.setConnecting(false))
                await send(.alert(.purchase(result.userMessage)))
            }
        case .restore:
            return .run { send in
                await send(.setConnecting(true))
                let result = await inAppPurchase.restore()
                switch result {
                case .purchased, .restored:
                    await userDefaults.setIsHidingAd(true)
                    await send(.hideAd)
                case .failed:
                    break
                }
                await send(.setConnecting(false))
                await send(.alert(.purchase(result.userMessage)))
            }
        case let .setConnecting(value):
            state.isConnecting = value
            return .none
        }
    }

    public enum ScreenLayout: String, CaseIterable {
        case tab
        case vertical
    }
}
