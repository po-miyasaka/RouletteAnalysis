//
//  File.swift
//  
//
//  Created by po_miyasaka on 2023/06/09.
//

import ComposableArchitecture
import Item
@testable import TableLayout
@testable import Roulette
@testable import History
import XCTest

@MainActor
final class LayoutTests: XCTestCase {
    
    func testSelectNumber() async throws {
        let layoutStore = TestStore(initialState: .init()
                                    , reducer: {
            TableLayout()
        })
        
        let item = Item(number: .n0, color: .black)
        let itemWithWeight = ItemWithWeight(item: item, weight: 9)
        await layoutStore.send(.select(itemWithWeight)) {
            $0.selectedItemForAdding = itemWithWeight.item
        }
    }
    
    
    // ViewStateをテストするためには依存元の環境自体を作り込む必要がありそう。
    // TestはStoreに指定StateとActionをテストするもの。
    
    func testAddNumber_aroundRoulette() async throws {
        
        let uuid = UUID(1)
        let rouletteStore = TestStore(initialState: .init(id: uuid), reducer: Roulette.init, withDependencies: {
            $0.uuid = UUIDGenerator({uuid})
        })
        let item: ItemWithWeight = .init(item: .init(number: .n0, color: .green, id: uuid), weight: 1)
        await rouletteStore.send(.layout(.select(.init(item: item.item, weight: 1)))) {
            $0.layout.selectedItemForAdding = item.item
        }
        
        await rouletteStore.send(.layout(.select(.init(item: item.item, weight: 1))))
        await rouletteStore.receive(.layout(.add(item))) {
            $0.layout.selectedItemForAdding = nil
        }
        await rouletteStore.receive(.history(.add(item.item, isHit: false))) {
            var state = History.State()
            state.items = [.init(item: item.item, isHit: false)]
            $0.history = state
        }
        let uuid2 = UUID(2)
        rouletteStore.dependencies.uuid = UUIDGenerator({uuid2})
        var item2 = item
        item2.item.id = uuid2
        await rouletteStore.send(.layout(.select(.init(item: item2.item, weight: 1)))) {
            $0.layout.selectedItemForAdding = item2.item
        }
        await rouletteStore.send(.layout(.select(.init(item: item2.item, weight: 1, candidated: true))))
        await rouletteStore.receive(.layout(.add(.init(item: item2.item, weight: item2.weight, candidated: true)))) {
            $0.layout.selectedItemForAdding = nil
        }
        
        await rouletteStore.receive(.history(.add(item2.item, isHit: true))) {
            var state = History.State()
            state.items = [
                .init(item: item.item, isHit: false),
                .init(item: item2.item, isHit: true)
            ]
            $0.history = state
        }
        
        
        
    }
}
