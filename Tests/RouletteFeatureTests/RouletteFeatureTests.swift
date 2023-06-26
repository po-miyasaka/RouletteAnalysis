import ComposableArchitecture
import Item
@testable import App
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
        
        await appStore.send(.onAppear) {
            $0.current = .init(id: UUID(1))
            $0.roulettes = [.init(id: UUID(1))]
        }
        await appStore.receive(.settings(.setup))
        await appStore.receive(.showTutorial, timeout: 3) {
            $0.activeSheet = .tutorial
        }
        XCTAssertTrue(appStore.dependencies.userDefaults.didFirstLaunch)
        await appStore.finish()
    }

    func testLaunchAfterTheSecondTime() async throws {

        let appStore =
        TestStore(initialState: .init()) {
            AppFeature()
        } withDependencies: {
            $0.finishLaunchingAfterTheSecondTime()
            $0.uuid = UUIDGenerator { UUID(1) }
        }

        await appStore.send(.onAppear) {
            $0.current = .init(id: UUID(1))
            $0.roulettes = [.init(id: UUID(1))]
        }
        await appStore.receive(.settings(.setup))
    }

    func testTapSettings() async {
        let appStore =
        TestStore(initialState: .init()) {
            AppFeature()
        } withDependencies: {
            $0.finishLaunchingAfterTheSecondTime()
            $0.uuid = UUIDGenerator { UUID(1) }
        }

        // 関係ないDependencyは定義する必要がない。もし暗黙的に使われた場合も自動的に検知されて失敗になる。
        await appStore.send(AppFeature.Action.setSettingViewPresent) {
            $0.activeSheet = .settings
        }
    }
    
}

extension DependencyValues {
    mutating func firstLaunching() {
        userDefaults.override(bool: false, forKey: didFirstLaunchKey)
        userDefaults.override(integer: 5, forKey: weightWidthForHistoryKey)
        userDefaults.override(integer: 7, forKey: weightWidthForPredictionKey)
        userDefaults.override(string: "the star", forKey: ruleKey)
        userDefaults.override(data: Data(), forKey: roulettesKey)
        userDefaults.override(string: "tab", forKey: screenLayoutKey)
    }

    mutating func finishLaunchingAfterTheSecondTime() {
        userDefaults.override(bool: true, forKey: didFirstLaunchKey)
        userDefaults.override(integer: 5, forKey: weightWidthForHistoryKey)
        userDefaults.override(integer: 7, forKey: weightWidthForPredictionKey)
        userDefaults.override(string: "the star", forKey: ruleKey)
        
        
        userDefaults.override(data: Data(), forKey: roulettesKey)
        
        userDefaults.override(string: "tab", forKey: screenLayoutKey)
    }
}
