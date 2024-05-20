//
//  AppFeatureTests.swift
//  ComposableArchitectureTutorial-iOSTests
//
//  Created by Ari on 5/21/24.
//

import ComposableArchitecture
import XCTest

@testable import ComposableArchitectureTutorial_iOS

@MainActor
final class AppFeatureTests: XCTestCase {
    
    func testIncrementInFirstTab() async {
        // Feature의 initialState를 제공하고 Feature를 구동하는 Reducer를 지정하여 수행됩니다.
        let store = TestStore(initialState: AppFeature.State()) {
            AppFeature()
        }
        
        // 사용자가 첫 번째 탭에서 증분 버튼을 탭하는 것을 emulate하기 위해 TestStore에 Action을 전송합니다.
        await store.send(\.tab1.incrementButtonTapped) {
            // 테스트를 통과하려면 store.send에서 후행 클로저를 열고 이전 버전의 Feature State를 변경하여 작업이 전송된 후의 State와 일치하도록 해야 합니다.
            $0.tab1.count = 1
        }
    }
    
}
