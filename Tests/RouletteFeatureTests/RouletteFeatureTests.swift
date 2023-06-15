import ComposableArchitecture
import Item
@testable import RouletteFeature
@testable import UserDefaultsClient
import XCTest

@MainActor
final class RouletteAnalysisTests: XCTestCase {
    override func setUp() async throws {
        UserDefaultsClient.reset()
        
    }

    
    func testFirstLaunch() async throws {
        
        let appStore =
        TestStore(initialState: .init()) {
            AppFeature()
        } withDependencies: {
            $0.firstLaunching()
            $0.uuid = UUIDGenerator { UUID(1) }
        }
        
        let rouletteStore = appStore.scope(
            state: {
                RouletteView.ViewState(roulette: try! XCTUnwrap($0.current), settings: $0.settings)
            }
        )
        
        await appStore.send(.onAppear) {
            $0.current = .init(id: UUID(1))
            $0.roulettes = [.init(id: UUID(1))]
        }
        await rouletteStore.receive(.settings(.setup))
        await appStore.receive(.showTutorial, timeout: 3) {
            $0.activeSheet = .tutorial
        }
        XCTAssertTrue(appStore.dependencies.userDefaults.didFirstLaunch)
        await appStore.finish()
    }

//    func testLaunchAfterTheSecondTime() async throws {
//
//        let appStore =
//        TestStore(initialState: .init()) {
//            AppFeature()
//        } withDependencies: {
//            $0.finishLaunchingAfterTheSecondTime()
//            $0.uuid = UUIDGenerator { UUID(1) }
//        }
//
//        let rouletteStore = appStore.scope(
//            state: {
//                RouletteView.ViewState(roulette: try! XCTUnwrap($0.current), settings: $0.settings)
//            }
//        )
//
//        await appStore.send(.onAppear) {
//            $0.current = .init(id: UUID(1))
//            $0.roulettes = [.init(id: UUID(1))]
//        }
//        await rouletteStore.receive(.settings(.setup))
//        await appStore.receive(.showTutorial, timeout: 3) {
//            $0.activeSheet = .tutorial
//        }
//        await appStore.send(.onAppear)
//        await appStore.receive(.settings(.setup))
//        await rouletteStore.receive(.roulette(.history(.setup)))
//    }

    func testTapSettings() async {
        let appStore =
        TestStore(initialState: .init()) {
            AppFeature()
        } withDependencies: {
            $0.finishLaunchingAfterTheSecondTime()
            $0.uuid = UUIDGenerator { UUID(1) }
        }

        // 関係ないDependencyは定義する必要がない。もし暗黙的に使われた場合も自動的に検知されて失敗になる。
        await appStore.send(.setSettingsViewPresent) {
            $0.activeSheet = .settings
        }
    }

//    func testAddHistory() async {
//
//        let appStore =
//        TestStore(initialState: .init()) {
//            AppFeature()
//        } withDependencies: {
//            $0.finishLaunchingAfterTheSecondTime()
//            $0.uuid = UUIDGenerator { UUID(1) }
//        }
//
//        await appStore.send(.onAppear) {
//            $0.roulettes = [.init(id: UUID(1))]
//            $0.current = $0.roulettes[0]
//        }
//        let rouletteStore = appStore.scope(
//            state: {
//
//                RouletteView.ViewState(roulette: $0.current!, settings: $0.settings)
//            }
//        )
//
//        let itemWithOmomi = ItemWithOmomi(item: Item(number: .n0, color: .black, id: UUID(123)), omomi: 7)
//        await rouletteStore.send(.roulette(.layout(.add(itemWithOmomi))))
//        await rouletteStore.receive(.roulette(.history(.add(itemWithOmomi.item, isHit: false)))) {
//            $0.roulette.history = .init(
//                items: [.init(item: itemWithOmomi.item, isHit: false)],
//                displayLimit: 16
//            )
//        }
//    }
//
}

extension DependencyValues {
    mutating func firstLaunching() {
        userDefaults.override(bool: false, forKey: didFirstLaunchKey)
        userDefaults.override(integer: 5, forKey: omomiWidthForHistoryKey)
        userDefaults.override(integer: 7, forKey: omomiWidthForPredictionKey)
        userDefaults.override(string: "the star", forKey: ruleKey)
        userDefaults.override(data: Data(), forKey: roulettesKey)
        userDefaults.override(string: "tab", forKey: screenLayoutKey)
    }

    mutating func finishLaunchingAfterTheSecondTime() {
        userDefaults.override(bool: true, forKey: didFirstLaunchKey)
        userDefaults.override(integer: 5, forKey: omomiWidthForHistoryKey)
        userDefaults.override(integer: 7, forKey: omomiWidthForPredictionKey)
        userDefaults.override(string: "the star", forKey: ruleKey)
        
//        Roulette.State()
        
        userDefaults.override(data: Data(), forKey: roulettesKey)
        
        userDefaults.override(string: "tab", forKey: screenLayoutKey)
    }
}
