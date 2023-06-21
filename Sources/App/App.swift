//
//  File.swift
//
//
//  Created by po_miyasaka on 2023/06/12.
//

import ComposableArchitecture
import SwiftUI
import UserDefaultsClient
import Setting
import Roulette
import Item

public struct AppFeature: ReducerProtocol {
    public init() {}
    @Dependency(\.userDefaults) var userDefaults
    @Dependency(\.uuid) var uuid
    public struct State: Equatable {
        public init() {}
        public var settings: Setting.State = .init()
        public var current: Roulette.State?
        public var activeSheet: ActiveSheet?
        public var roulettes: [Roulette.State] = []
        public var activeAlert: ActiveAlert?
        
    }

    public enum Action: Equatable {
        case settings(Setting.Action)
        case roulette(Roulette.Action)
        case setSettingViewPresent
        case select(Roulette.State.ID)
        case showTutorial
        case hideSheet
        case onAppear
        case newRoulette
        case closeRoulette
        case reset
        case alert(ActiveAlert?)
        case save
    }

    public enum ActiveSheet: String, Equatable, Identifiable {
        public var id: String { rawValue }
        case settings
        case tutorial
    }

    public enum ActiveAlert: String, Equatable, Identifiable {
        public var id: String { rawValue }
        case close = "Would you like to close this roulette?"
    }

    public var body: some ReducerProtocol<State, Action> {
        Scope(state: \.settings, action: /AppFeature.Action.settings) {
            Setting()
        }

        Reduce { state, action in

            func cacheCurrent() {
                if let currentIndex = state.roulettes.firstIndex(where: { $0.id == state.current?.id }), let current = state.current {
                    state.roulettes[currentIndex] = current
                }
            }

            switch action {
            case .roulette:
                break
            case .onAppear:

                let roulettes = roulettes()
                state.roulettes = roulettes

                if let first = roulettes.first {
                    state.current = first
                } else {
                    let new = Roulette.State(id: uuid())
                    state.current = new
                    state.roulettes += [new]
                }

                return .run { send in
                    await send(.settings(.setup))

                    if !userDefaults.didFirstLaunch {
                        await send(.showTutorial)
                        await userDefaults.setDidFirstLaunch()
                    }
                }

            case .settings(.changeRule):
                return .task {
                    return .reset
                }
            case .reset:

                state.roulettes = []
                let new = Roulette.State(id: uuid())
                state.current = new
                state.roulettes += [new]

                return .fireAndForget {
                    await userDefaults.setRoulettes(data: nil)
                }

            case .settings:
                break

            case .showTutorial:
                state.activeSheet = .tutorial

            case .hideSheet:
                state.activeSheet = nil

            case .setSettingViewPresent:
                state.activeSheet = .settings
            case .newRoulette:

                cacheCurrent()

                let new = Roulette.State(id: uuid())
                state.current = new
                state.roulettes += [new]

            case let .select(id):

                cacheCurrent()

                state.current = state.roulettes.first(where: { $0.id == id })

            case .closeRoulette:
                if let currentIndex = state.roulettes.firstIndex(where: { $0.id == state.current?.id }) {
                    state.roulettes.remove(at: currentIndex)

                    if let last = state.roulettes.last {
                        state.current = last
                    } else {
                        let new = Roulette.State(id: uuid())
                        state.current = new
                        state.roulettes += [new]
                    }
                }

                state.activeSheet = nil
            case let .alert(value):
                state.activeAlert = value
            case .save:
                cacheCurrent()
                return .fireAndForget { [roulettes = state.roulettes] in
                    let encoder = JSONEncoder()
                    if let data = try? encoder.encode(roulettes) {
                        await userDefaults.setRoulettes(data: data)
                    }
                }
            }
            return .none
        }.ifLet(\.current, action: /AppFeature.Action.roulette, then: {
            Roulette()
        })
    }

    
    func roulettes() -> [Roulette.State] {
        guard let roulettesData = userDefaults.roulettes,
            let roulettes = try? JSONDecoder().decode([Roulette.State].self, from: roulettesData) else { return [] }
        return roulettes
    }
}

public extension StoreOf<AppFeature> {
    var settingStore: StoreOf<Setting> {
        scope(state: \.settings, action: AppFeature.Action.settings)
    }
}
