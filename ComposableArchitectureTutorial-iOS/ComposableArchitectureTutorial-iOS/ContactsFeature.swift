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
        @Presents var alert: AlertState<Action.Alert>?
        var contacts: IdentifiedArrayOf<Contact> = []
    }
    enum Action {
        case addButtonTapped
        case addContact(PresentationAction<AddContactFeature.Action>) // 부모는 자식 Feature에서 보낸 모든 Action을 관찰할 수 있습니다.
        case alert(PresentationAction<Alert>)
        case deleteButtonTapped(id: Contact.ID) // 연락처 목록의 행에서 삭제 버튼을 탭할 때 전송될 새 작업을 추가
        
        
        enum Alert: Equatable {
            case confirmDeletion(id: Contact.ID)
        }
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

            // AddContactFeature 내에서 'Save' 버튼을 탭하면 해당 Feature를 해제할 뿐만 아니라
            // 새 연락처를 ContactsFeature.State에 보관된 연락처 모음에 추가하고 싶습니다.
            case let .addContact(.presented(.delegate(.saveContact(contact)))):
              state.contacts.append(contact)
              return .none
                
            case .addContact:
              return .none
                
                
            case let .alert(.presented(.confirmDeletion(id: id))):
              state.contacts.remove(id: id)
              return .none
              
            case .alert:
              return .none

            case let .deleteButtonTapped(id: id):
              // 삭제 버튼을 탭하면 사용자에게 연락처 삭제를 확인하도록 요청하기 위해 AlertState를 채울 수 있습니다.
              state.alert = AlertState {
                TextState("Are you sure?")
              } actions: {
                ButtonState(role: .destructive, action: .confirmDeletion(id: id)) {
                  TextState("Delete")
                }
              }
              return .none
            }
        }
        // 이렇게 하면 자식 Action이 시스템에 들어올 때 자식 Reducer를 실행하고 모든 Action에 대해 부모 Reducer를 실행하는 새 Reducer가 생성됩니다.
        // 또한 자식 Feature가 해제될 때 effact 취소 등을 자동으로 처리합니다. 자세한 내용은 문서를 참조하세요.
        .ifLet(\.$addContact, action: \.addContact) {
          AddContactFeature()
        }
        .ifLet(\.$alert, action: \.alert) // Alert 로직을 ContactsFeature에 통합하기.
    }
}
