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
        let store =
            TestStore(initialState: .init()) {
                Roulette()
            } withDependencies: {
                $0.firstLaunching()
            }

        await store.send(.launch)
        await store.receive(.settings(.setup))
        await store.receive(.history(.setup))
        await store.receive(.showTutorial, timeout: 3) {
            $0.activeSheet = .tutorial
        }
        XCTAssertTrue(store.dependencies.userDefaults.didFirstLaunch)
        await store.finish()
    }

    func testUsualLaunch() async throws {
        let store =
            TestStore(initialState: .init()) {
                Roulette()
            } withDependencies: {
                $0.finishLaunching()
            }

        await store.send(.launch)
        await store.receive(.settings(.setup))
        await store.receive(.history(.setup))
    }

    func testTapSettings() async {
        let store =
            TestStore(initialState: .init()) {
                Roulette()
            }
        // 関係ないDependencyは定義する必要がない。もし使われた場合も自動的に検知されて失敗になる。
        await store.send(.setSettingsViewPresent) {
            $0.activeSheet = .settings
        }
    }

    func testAddHistory() async {
        let store =
            TestStore(initialState: .init()) {
                Roulette()
            } withDependencies: {
                $0.uuid = UUIDGenerator { UUID(123) }
            }

        let item = Item(number: .n0, color: .black, id: UUID(123))
        await store.send(.layout(.add(item)))
        await store.receive(.history(.add(item, isHit: false))) {
            $0.history = .init(
                items: [.init(item: item, isHit: false)],
                displayLimit: 16
            )
        }
    }
}

extension DependencyValues {
    mutating func firstLaunching() {
        userDefaults.override(bool: false, forKey: didFirstLaunchKey)
        userDefaults.override(integer: 5, forKey: omomiWidthForHistoryKey)
        userDefaults.override(integer: 7, forKey: omomiWidthForPredictionKey)
        userDefaults.override(string: "the star", forKey: ruleKey)
    }

    mutating func finishLaunching() {
        userDefaults.override(bool: true, forKey: didFirstLaunchKey)
        userDefaults.override(integer: 5, forKey: omomiWidthForHistoryKey)
        userDefaults.override(integer: 7, forKey: omomiWidthForPredictionKey)
        userDefaults.override(string: "the star", forKey: ruleKey)
    }
}
