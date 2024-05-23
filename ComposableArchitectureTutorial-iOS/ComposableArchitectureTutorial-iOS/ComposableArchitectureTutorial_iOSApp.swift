//
//  ComposableArchitectureTutorial_iOSApp.swift
//  ComposableArchitectureTutorial-iOS
//
//  Created by Ari on 5/17/24.
//

import ComposableArchitecture
import SwiftUI

@main
struct ComposableArchitectureTutorial_iOSApp: App {
    /// 애플리케이션을 구동하는 스토어는 한 번만 생성해야 한다는 점에 유의해야 합니다. 
    /// 대부분의 애플리케이션에서는 씬의 루트에 있는 WindowGroup에 직접 생성하는 것으로 충분합니다.
    /// 그러나 정적 변수로 보관한 다음 씬에 제공할 수도 있습니다.
    static let store1 = Store(initialState: AppFeature.State()) {
        AppFeature()
            ._printChanges()
            // _printChanges() 함수를 사용하면 콘솔 로그에서 State 값이 어떻게 바뀌고 있는지 한눈에 볼 수 있으며, 어떤 Action이 발생했는지와 내부에서 어떤 Action이 전달되고 있는지를 확인할 수 있습니다.
    }
    static let store2 = Store(initialState: ContactsFeature.State()) {
        ContactsFeature()
            ._printChanges()
            // _printChanges() 함수를 사용하면 콘솔 로그에서 State 값이 어떻게 바뀌고 있는지 한눈에 볼 수 있으며, 어떤 Action이 발생했는지와 내부에서 어떤 Action이 전달되고 있는지를 확인할 수 있습니다.
    }

    var body: some Scene {
        WindowGroup {
//            AppView(store: ComposableArchitectureTutorial_iOSApp.store1)
            ContactsView(store: ComposableArchitectureTutorial_iOSApp.store2)
        }
    }
}
