//
//  ComposableArchitectureTutorial_iOSTests.swift
//  ComposableArchitectureTutorial-iOSTests
//
//  Created by Ari on 5/17/24.
//

import XCTest
@testable import ComposableArchitectureTutorial_iOS
import ComposableArchitecture

@MainActor
final class CounterFeatureTests: XCTestCase {
    func testCounter() async {
        let store = TestStore(initialState: CounterFeature.State()) {
            CounterFeature()
        }
        await store.send(.incrementButtonTapped) {
            $0.count = 1
        }
        await store.send(.decrementButtonTapped) {
            $0.count = 0
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
