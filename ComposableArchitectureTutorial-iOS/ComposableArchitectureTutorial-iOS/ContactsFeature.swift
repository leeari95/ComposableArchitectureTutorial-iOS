//
//  ContactsFeature.swift
//  ComposableArchitectureTutorial-iOS
//
//  Created by Ari on 5/21/24.
//

import Foundation
import ComposableArchitecture


struct Contact: Equatable, Identifiable {
    let id: UUID
    var name: String
}


@Reducer
struct ContactsFeature {
    @ObservableState
    struct State: Equatable {
        @Presents var addContact: AddContactFeature.State? // Presents() 매크로를 사용하여 옵셔널 값을 유지함으로써 Feature의 State를 함께 통합합니다.
        var contacts: IdentifiedArrayOf<Contact> = []
    }
    enum Action {
        case addButtonTapped
        case addContact(PresentationAction<AddContactFeature.Action>) // 부모는 자식 Feature에서 보낸 모든 Action을 관찰할 수 있습니다.
    }
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                // 연락처 목록 기능에서 '+' 버튼을 탭하면 이제 해당 Feature가 표시되어야 함을 나타내는 AddContactFeature를 채울 수 있습니다.
                state.addContact = AddContactFeature.State(
                  contact: Contact(id: UUID(), name: "")
                )
                return .none
                
            // AddContactFeature에서 'Cancel' 버튼을 누르면 해당 Feature를 해제하고 다른 작업을 수행하지 않으려 합니다.
            // 이 작업은 추가 연락처 상태를 nil로 처리하면 됩니다.
            case .addContact(.presented(.cancelButtonTapped)):
              state.addContact = nil
              return .none
                
            // AddContactFeature 내에서 'Save' 버튼을 탭하면 해당 Feature를 해제할 뿐만 아니라
            // 새 연락처를 ContactsFeature.State에 보관된 연락처 모음에 추가하고 싶습니다.
            case .addContact(.presented(.saveButtonTapped)):
              guard let contact = state.addContact?.contact
              else { return .none }
              state.contacts.append(contact)
              state.addContact = nil
              return .none
                
            case .addContact:
              return .none
            }
        }
        // 이렇게 하면 자식 Action이 시스템에 들어올 때 자식 Reducer를 실행하고 모든 Action에 대해 부모 Reducer를 실행하는 새 Reducer가 생성됩니다.
        // 또한 자식 Feature가 해제될 때 effact 취소 등을 자동으로 처리합니다. 자세한 내용은 문서를 참조하세요.
        .ifLet(\.$addContact, action: \.addContact) {
          AddContactFeature()
        }
    }
}
