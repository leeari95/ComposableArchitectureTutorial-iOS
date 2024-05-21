//
//  AppFeature.swift
//  ComposableArchitectureTutorial-iOS
//
//  Created by Ari on 5/21/24.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct AppFeature {
    struct State: Equatable {
        var tab1 = CounterFeature.State()
        var tab2 = CounterFeature.State()
    }

    enum Action {
        case tab1(CounterFeature.Action)
        case tab2(CounterFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        // CounterFeature를 AppFeature로 구성하려면 Scope Reducer를 사용할 수 있습니다.
        Scope(state: \.tab1, action: \.tab1) {
            CounterFeature()
        }
        Scope(state: \.tab2, action: \.tab2) {
            CounterFeature()
        }
        Reduce { state, action in
            // 앱 기능의 핵심 로직
            return .none
        }
    }
}

struct AppView: View {
    
    // 컴포저블 아키텍처에서는 여러 개의 독립된 스토어가 아닌 하나의 스토어에서 기능을 함께 구성하고 뷰를 제공하는 것을 선호합니다.
    // 이렇게 하면 기능이 서로 통신하기가 매우 쉬워지고 통신이 제대로 작동하는지 테스트도 작성할 수 있습니다.
    let store: StoreOf<AppFeature>
    
    var body: some View {
        TabView {
            // Store에서 scope(state:action:) 메서드를 사용하여 tab1 도메인에만 초점을 맞춘 하위 store를 도출합니다.
            // 이 작업은 key path 구문을 사용하여 state 필드와 action 열거형의 대/소문자를 구분하여 수행합니다.
            
            CounterView(store: store.scope(state: \.tab1, action: \.tab1))
                .tabItem {
                    Text("Counter 1")
                }
            
            CounterView(store: store.scope(state: \.tab2, action: \.tab2))
                .tabItem {
                    Text("Counter 2")
                }
        }
    }
}
