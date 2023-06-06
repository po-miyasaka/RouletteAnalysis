import XCTest
import ComposableArchitecture
@testable import RouletteFeature

final class RouletteAnalysisTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        let store: StoreOf<Roulette> = Store(initialState: .init(), reducer: Roulette())
        let viewStore = ViewStore(store)
        XCTAssertEqual(viewStore.state.settings.rule, .theStar)
    }
}
