//
//  AddContactFeature.swift
//  ComposableArchitectureTutorial-iOS
//
//  Created by Ari on 5/21/24.
//

import SwiftUI
import ComposableArchitecture


@Reducer
struct AddContactFeature {
    @ObservableState
    struct State: Equatable {
        var contact: Contact
    }
    enum Action {
        case cancelButtonTapped
        case delegate(Delegate)
        case saveButtonTapped
        case setName(String)
        
        /// 부모가 수신하고 해석할 수 있는 모든 Action을 설명합니다. 이를 통해 하위 기능이 부모 기능에 원하는 작업을 직접 전달할 수 있습니다.
        enum Delegate: Equatable {
          case saveContact(Contact)
        }
        
    }
    
    /// 이 값은 자식 기능이 부모 기능과 직접 접촉하지 않고도 스스로 dismiss할 수 있도록 하는 값입니다.
    @Dependency(\.dismiss) var dismiss

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .cancelButtonTapped:
                return .run { _ in await self.dismiss() }

            case .delegate:
                return .none

            case .saveButtonTapped:
                return .run { [contact = state.contact] send in
                  await send(.delegate(.saveContact(contact)))
                  await self.dismiss()
                }
                
            case let .setName(name):
                state.contact.name = name
                return .none
            }
        }
    }
}

struct AddContactView: View {
    // 추가 연락처 기능의 저장소를 보유하는 뷰를 추가합니다.
    // 뷰에 텍스트 필드가 있을 것이므로 스토어에서 바인딩을 파생할 수 있어야 합니다.
    // 이를 위해 SwiftUI의 @Bindable 속성 래퍼를 사용합니다.
    @Bindable var store: StoreOf<AddContactFeature>
    
    var body: some View {
        Form {
            TextField("Name", text: $store.contact.name.sending(\.setName))
            Button("Save") {
                store.send(.saveButtonTapped)
            }
        }
        .toolbar {
            ToolbarItem {
                Button("Cancel") {
                    store.send(.cancelButtonTapped)
                }
            }
        }
    }
}
