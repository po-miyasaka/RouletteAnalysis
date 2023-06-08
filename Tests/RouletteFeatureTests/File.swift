//
//  File.swift
//  
//
//  Created by po_miyasaka on 2023/06/09.
//

import ComposableArchitecture
import Item
@testable import RouletteFeature
import XCTest

@MainActor
final class LayoutTests: XCTestCase {
    
    func testSelectNumber() async throws {
        let layoutStore = TestStore(initialState: .init()
                                    , reducer: {
            Layout()
        })
        
        let num = Item(number: .n0, color: .black)
        await layoutStore.send(.select(num)) {
            $0.selectedItemForAdding = num
        }
    }
    
    // ViewStateをテストするためには依存元の環境自体を作り込む必要がありそう。
    // TestはStoreにしていされたStateとActionをテストするもん。
    func testSelectNumber_aroundApp() async throws {
        let appStore =
        TestStore(initialState: .init()) {
            Roulette()
        } withDependencies: {
            $0.finishLaunching()
            $0.uuid = UUIDGenerator { UUID(1) }
        }
        // TODO: Fix for the following warning
        // 'scope(state:)' is deprecated: Use 'TestStore.init(initialState:reducer:observe:)' to scope a test store's state.
        
        let layoutStore = appStore.scope(
            state: {
                LayoutView.ViewState(
                    rule: $0.settings.rule,
                    predictedData: $0.layoutData,
                    selectedItem: $0.layout.selectedItemForAdding,
                    lastItem: nil
                )
                
            }
        )
        
        let num = Item(number: .n0, color: .black)
        await layoutStore.send(.layout(.select(num))) {
            $0.selectedItem = num
        }
        
        await layoutStore.send(.layout(.select(num)))
        await layoutStore.receive(.layout(.add(num))) {
            $0.selectedItem = nil
        }
        await layoutStore.receive(.history(.add(num, isHit: false))) {
            $0.predictedData[0].omomi = 8
            $0.predictedData[4].omomi = 6
            $0.predictedData[16].omomi = 6
            $0.predictedData[27].omomi = 7
            $0.predictedData[33].omomi = 7
        }
    }
}
