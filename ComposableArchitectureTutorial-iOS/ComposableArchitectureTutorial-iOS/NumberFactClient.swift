//
//  NumberFactClient.swift
//  ComposableArchitectureTutorial-iOS
//
//  Created by Ari on 5/21/24.
//

import Foundation
import ComposableArchitecture

struct NumberFactClient {
    var fetch: (Int) async throws -> String
}

extension NumberFactClient: DependencyKey {
    /// 이 값은 기능이 시뮬레이터와 기기에서 실행될 때 사용되는 값으로, 실시간 네트워크 요청을 하는 데 적합한 곳
    static let liveValue = Self(
        fetch: { number in
            let (data, _) = try await URLSession.shared
                .data(from: URL(string: "http://numbersapi.com/\(number)")!)
            return String(decoding: data, as: UTF8.self)
        }
    )
}

extension DependencyValues {
    /// 이것이 바로 리듀서에서 @Dependency(\.numberFact) 구문을 사용할 수 있는 이유입니다.
    var numberFact: NumberFactClient {
        get { self[NumberFactClient.self] }
        set { self[NumberFactClient.self] = newValue }
    }
}

/// 라이브러리에 종속성을 등록하는 것은 환경 값을 등록하는 것과 다르지 않습니다. 
/// 환경 값을 등록하려면 EnvironmentKey를 준수하여 기본값을 제공하고, 계산된 속성을 제공하려면 EnvironmentValues를 확장해야 합니다.
