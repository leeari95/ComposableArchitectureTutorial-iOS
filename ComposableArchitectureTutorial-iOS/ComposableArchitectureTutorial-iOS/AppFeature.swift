//
//  AppFeature.swift
//  ComposableArchitectureTutorial-iOS
//
//  Created by Ari on 5/21/24.
//

import SwiftUI
import ComposableArchitecture

struct AppView: View {
    
    // 컴포저블 아키텍처에서는 여러 개의 독립된 스토어가 아닌 하나의 스토어에서 기능을 함께 구성하고 뷰를 제공하는 것을 선호합니다.
    // 이렇게 하면 기능이 서로 통신하기가 매우 쉬워지고 통신이 제대로 작동하는지 테스트도 작성할 수 있습니다.
    let store1: StoreOf<CounterFeature>
    let store2: StoreOf<CounterFeature>
    
    var body: some View {
        TabView {
            CounterView(store: store1)
                .tabItem {
                    Text("Counter 1")
                }
            
            CounterView(store: store2)
                .tabItem {
                    Text("Counter 2")
                }
        }
    }
}
