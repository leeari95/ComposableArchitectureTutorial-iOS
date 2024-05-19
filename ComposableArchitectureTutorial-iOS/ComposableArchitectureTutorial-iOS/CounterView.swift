//
//  CounterView.swift
//  ComposableArchitectureTutorial-iOS
//
//  Created by Ari on 5/17/24.
//

import ComposableArchitecture
import SwiftUI

struct CounterView: View {
    /// State를 업데이트 하기 위해 Action을 처리할 수 있는 객체
    /// Effact를 실행하고 해당 Effact의 데이터를 다시 시스템으로 공급할 수 있음.
    /// 데이터 관찰은 ObservableState() 매크로를 통해 자동으로 이루어진다.
  let store: StoreOf<CounterFeature>
  
  var body: some View {
      VStack {
          Text("\(store.count)") // State의 프로퍼티 읽기
              .font(.largeTitle)
              .padding()
              .background(Color.black.opacity(0.1))
              .cornerRadius(10)
          HStack {
              Button("-") {
                  store.send(.decrementButtonTapped) // store에 action 전송하기
              }
              .font(.largeTitle)
              .padding()
              .background(Color.black.opacity(0.1))
              .cornerRadius(10)
              
              Button("+") {
                  store.send(.incrementButtonTapped) // store에 action 전송하기
              }
              .font(.largeTitle)
              .padding()
              .background(Color.black.opacity(0.1))
              .cornerRadius(10)
              
          // 첫 번째 기능에서 만든 카운터 기능에 새로운 기능을 추가해 보겠습니다. 버튼을 탭하면 현재 표시된 숫자에 대한 사실을 가져오기 위해 네트워크에 요청하는 버튼을 추가하겠습니다.
          }
          Button("Fact") {
              store.send(.factButtonTapped)
          }
          .font(.largeTitle)
          .padding()
          .background(Color.black.opacity(0.1))
          .cornerRadius(10)
          
          // 또한 하단에 ProgressView를 추가하여 fact을 load하는 동안 표시하고, 옵셔널을 언래핑하여 fact을 표시할 것입니다.
          if store.isLoading {
              ProgressView()
          } else if let fact = store.fact {
              Text(fact)
                  .font(.largeTitle)
                  .multilineTextAlignment(.center)
                  .padding()
          }
      }
  }
}

#Preview {
    /*
     5단계

     다음으로 실제로 feature을 실행해 보겠습니다. Preview부터 시작하겠습니다. 이를 위해 CounterView를 구성하고, 이를 위해 StoreOf<CounterFeature>를 구성해야 합니다. Store는 feature을 시작하려는 initialState와 feature을 구동하는 Reducer를 지정하는 후행 클로저를 제공하여 구성할 수 있습니다.

     이렇게 하면 Preview를 실행하여 "+" 및 "-" 버튼을 탭하면 UI에 표시되는 count가 실제로 변경되는지 확인할 수 있습니다.

     예를 들어, Preview에서 Reducer를 주석 처리하면 Store에 상태 변경이나 효과를 수행하지 않는 Reducer가 제공됩니다. 이를 통해 로직이나 동작에 대한 걱정 없이 feature의 디자인을 미리 볼 수 있습니다.

     참고

     동영상에서는 버튼을 탭해도 count가 증가하거나 감소하지 않는 것을 확인할 수 있습니다. 이는 Preview에서 빈 Reducer를 사용하고 있기 때문입니다.
     */
  CounterView(
    store: Store(initialState: CounterFeature.State()) {
      CounterFeature()
    }
  )
}
