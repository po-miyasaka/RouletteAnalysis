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
        
        let item = Item(number: .n0, color: .black)
        let itemWithOmomi = ItemWithOmomi(item: item, omomi: 9)
        await layoutStore.send(.select(itemWithOmomi)) {
            $0.selectedItemForAdding = itemWithOmomi.item
        }
    }
}
    
    // ViewStateをテストするためには依存元の環境自体を作り込む必要がありそう。
    // TestはStoreに指定StateとActionをテストするもん。
//    func testSelectNumber_aroundApp() async throws {
//        let appStore =
//        TestStore(initialState: .init()) {
//            AppFeature()
//        } withDependencies: {
//            $0.finishLaunchingAfterTheSecondTime()
//            $0.uuid = UUIDGenerator { UUID(1) }
//        }
//        // TODO: Fix for the following warning
//        // 'scope(state:)' is deprecated: Use 'TestStore.init(initialState:reducer:observe:)' to scope a test store's state.
//        
//        await appStore.send(.onAppear)
//        
//        let rouletteStore = appStore.scope(
//            state: {
//                
//                RouletteView.ViewState(roulette: $0.current!, settings: $0.settings)
//            }
//        )
//        
//        let layoutStore =  rouletteStore.scope(
//            state: {
//                LayoutView.ViewState(
//                                    rule: $0.settings.rule,
//                                    predictedData: $0.layoutData,
//                                    selectedItem: $0.roulette.layout.selectedItemForAdding,
//                                    lastItem: nil
//                                )
//                
//            }
//        )
//        
//        let item = Item(number: .n0, color: .black)
//        let itemWithOmomi = ItemWithOmomi(item: item, omomi: 9)
//        await layoutStore.send(.roulette(.layout(.select(itemWithOmomi)))) {
//            $0.selectedItem = itemWithOmomi.item
//        }
//        
//        await layoutStore.send(.roulette(.layout(.select(itemWithOmomi))))
//        await layoutStore.receive(.roulette( .layout(.add(itemWithOmomi)))) {
//            $0.selectedItem = nil
//        }
//        await layoutStore.receive(.roulette( .history(.add(item, isHit: false)))) {
//            $0.predictedData[0].omomi = 8
//            $0.predictedData[4].omomi = 6
//            $0.predictedData[16].omomi = 6
//            $0.predictedData[27].omomi = 7
//            $0.predictedData[33].omomi = 7
//        }
//    }
//}
