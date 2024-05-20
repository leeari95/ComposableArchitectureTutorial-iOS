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
    
    func testNumberFact() async {
        let store = TestStore(initialState: CounterFeature.State()) {
            CounterFeature()
        } withDependencies: { // withDependencies 후행 클로저를 열어 테스트스토어의 종속성을 재정의합니다. 
            // 이 클로저에는 현재 종속성을 나타내는 인수가 전달되며, 이를 변경하여 원하는 대로 종속성을 변경할 수 있습니다.
            // 특히, numberFact.fetch 엔드포인트를 재정의하여 하드 코딩된 문자열을 즉시 반환합니다.
            // 엔드포인트에서 실제 비동기 또는 요청 작업이 수행되지 않는다는 점에 유의하세요.
            $0.numberFact.fetch = { "\($0) is a good number." }
        }
        
        await store.send(.factButtonTapped) {
            $0.isLoading = true
        }
        
        // 항상 예측 가능한 것을 반환하도록 numberFact 클라이언트를 재정의했으므로 수신 시간 제한을 삭제하고 상태 변경 방법을 올바르게 어설션할 수 있습니다.
        await store.receive(\.factResponse) {
            $0.isLoading = false
            $0.fact = "0 is a good number." // 서버에서 항상 다른 값을 반환하기 때문에 테스트가 항상 실패한다.
        }
    }
}
