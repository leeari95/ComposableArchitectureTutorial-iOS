//
//  CounterFeature.swift
//  ComposableArchitectureTutorial-iOS
//
//  Created by Ari on 5/17/24.
//

import ComposableArchitecture
import Foundation

/// https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/reducer()/
/// https://pointfreeco.github.io/swift-composable-architecture/main/documentation/composablearchitecture/reducers#Using-the-Reducer-macro
@Reducer
struct CounterFeature {
    
    /// Feature가 작업을 수행하는 데 필요한 State를 저장하는 타입
    @ObservableState
    // SwiftUI에서 State를 관찰하려는 경우에는 ObservableState() 매크로를 사용하여 주석을 달아야한다.
    // Composable Architecture의 @Observable 버전으로 값 타입에 맞춰져 있다.
      struct State {
          var count = 0
          var fact: String?
          var isLoading = false
      }
      
    /// 사용자가 Feature에서 수행할 수 있는 모든 동작을 포함하는 타입
      enum Action {
          // 사용자가 UI에서 실제로 수행하는 동작을 따라 Action 케이스를 이름 짓는 것이 가장 좋다.
          // 예를 들어, `incrementCount`와 같은 논리를 수행하려는 동작보다는 `incrementButtonTapped`처럼 명명하는 것이 좋다.
          case decrementButtonTapped
          case factButtonTapped
          case factResponse(String)
          case incrementButtonTapped
      }
    
    //  Reducer를 완전히 준수하려면 사용자가 수행한 액션을 받아 현재 상태를 다음 값으로 진화시키고, 기능이 외부 세계에서 실행하려는 모든 effect를 반환하는 Reduce 리듀서를 사용하여 `body` 프로퍼티를 구현해야 한다.
    //  이 작업은 거의 항상 들어오는 액션을 스위칭하여 수행해야 할 로직을 결정하는 것으로 시작되며, 상태는 `inout`으로 제공되므로 직접 변형을 수행할 수 있습니다.
    var body: some ReducerOf<Self> {
        Reduce { state, action in
          switch action {
              // 외부 세계에서 실행할 효과를 나타내는 Effect 값을 반환해야 하지만, 이 경우에는 실행할 필요가 없습니다.
              // 따라서 실행할 효과가 없음을 나타내기 위해 특별한 .none 값을 반환할 수 있습니다.
          case .decrementButtonTapped:
              state.count -= 1
              state.fact = nil
              return .none
              
          case .factButtonTapped:
              state.fact = nil
              state.isLoading = true
              return .run { [count = state.count] send in
                  // ✅ 여기에서 비동기 작업을 수행하고 작업을 시스템으로 다시 보냅니다.
                  
                  // 그러나 네트워크에서 데이터를 가져온 후 이펙트의 state.fact를 변경할 수는 없습니다.
                  // 이는 컴파일러에 의해 엄격하게 적용되는데, 전송 가능한 클로저는 인아웃 상태를 캡처할 수 없기 때문입니다.
                  // 이것은 라이브러리가 reducer가 수행하는 멋지고 단순하며 순수한 상태 변형을 지저분하고 복잡한 이펙트로부터 분리하는 방법을 보여줍니다.
                  let (data, _) = try await URLSession.shared
                      .data(from: URL(string: "http://numbersapi.com/\(count))")!)
                  print(data)
                  let fact = String(decoding: data, as: UTF8.self)
                  await send(.factResponse(fact))
              }
              
          case let .factResponse(fact):
            state.fact = fact
            state.isLoading = false
            return .none
              
          case .incrementButtonTapped:
              state.count += 1
              state.fact = nil
              return .none
          }
        }
      }
}
