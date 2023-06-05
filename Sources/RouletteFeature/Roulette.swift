//
//  File.swift
//  
//
//  Created by po_miyasaka on 2023/05/28.
//

import Foundation
import ComposableArchitecture
import Item
import UserDefaultsClient

public struct Roulette: ReducerProtocol {
    public init() {}
    @Dependency(\.userDefaults) var userDefaults
    public struct State: Equatable {
        public init() {}
        public var history: History.State = .init()
        public var layout: Layout.State = .init() // Layoutに閉じたプロパティしか持っていなくてもここに定義してScopeとして登録しないとReducerとしてはつかえない。
        public var selectedForPrediction: Item?
        public var settings: Settings.State = .init()
        
        public var wheelData: [ItemWithOmomi] {
            makeWheelData(history: history.limitedHistory.map(\.item),
                          omomiWidthForSelecting: settings.omomiWidthForPrediction,
                          omomiWidthForHistory: settings.omomiWidthForHistory,
                          rule: settings.rule,
                                           selectedItem: selectedForPrediction)
            
        }
        
        public var layoutData: [ItemWithOmomi] {
            makeLayoutData(history: history.limitedHistory.map(\.item), omomiWidthForSelecting: settings.omomiWidthForPrediction, omomiWidthForHistory: settings.omomiWidthForHistory, rule: settings.rule, selectedItem: selectedForPrediction)
        }
        
        
        public var activeSheet: ActiveSheet? = nil
        public enum ActiveSheet: String, Equatable, Identifiable {
            public var id: String { self.rawValue }
            case settings
            case tutorial
        }
    }
    
    public enum Action {
        case history(History.Action)
        case layout(Layout.Action)
        case wheel(Wheel.Action)
        case settings(Settings.Action)
        case setSettingsViewPresent
        case launch
        case showTutorial
        case hideSheet
    }
    
    public var body: some ReducerProtocol<State, Action>  {
        Scope(state: \.history, action: /Roulette.Action.history) {
            History()
        }
        // これによりLayout内のReducerが呼ばれる。これが無いと呼ばれない。これがpullbackか
        Scope(state: \.layout, action: /Roulette.Action.layout) {
            Layout()
        }
        
        Scope(state: \.settings , action: /Roulette.Action.settings) {
            Settings()
        }
        
        Reduce { state, action in
            switch action {
            case .wheel(.select(let item)):
                state.selectedForPrediction = item
                
            case .history(_):
                break
            case .layout(.add(let item)):
                let addedItem: History.HistoryItem = .init(item: item,
                                                           isHit: state.layoutData.filter { $0.candidated }
                    .contains(where: { $0.item.number == item.number })
                )
                return .task {
                    .history(.add(addedItem))
                }
            case .layout:
                break
            case .settings(.changeRule):
                state.history.items = []
            case .settings:
                break
            case .setSettingsViewPresent:
                state.activeSheet = .settings
            case .launch:
                return .run { send in
                    await send(.settings(.setup))
                    await send(.history(.setup))
                    if !userDefaults.didFirstLaunch {
                        await send(.showTutorial)
                        
                        await userDefaults.setDidFirstLaunch()
                    }
                }
            case .showTutorial:
                state.activeSheet = .tutorial
                
            case .hideSheet:
                state.activeSheet = nil
            }
            return .none
        }
        
    }
    
    
}
