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
    
    func testTimer() async {
        let clock = TestClock() // 시간을 제어할 수 있도록 기능의 감속기에서 사용할 시계가 될 것
        let store = TestStore(initialState: CounterFeature.State()) {
            CounterFeature()
        } withDependencies: { // 이를 위해 TestStore에 withDependencies라는 또 다른 후행 클로저를 제공하며, 이를 통해 원하는 종속성을 재정의할 수 있습니다.
            $0.continuousClock = clock
        }
        await store.send(.toggleTimerButtonTapped) {
            $0.isTimerRunning = true
            
        }
        await clock.advance(by: .seconds(1)) //  timerTick 액션을 받기 전에 테스트 시계에 1초씩 진행하도록 지시합니다.
        await store.receive(\.timerTick) {
          $0.count = 1
        }
        await store.send(.toggleTimerButtonTapped) {
          $0.isTimerRunning = false
        }
    }
}
