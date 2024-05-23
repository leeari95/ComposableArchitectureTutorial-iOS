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
//        @Presents var addContact: AddContactFeature.State? // Presents() 매크로를 사용하여 옵셔널 값을 유지함으로써 Feature의 State를 함께 통합합니다.
//        @Presents var alert: AlertState<Action.Alert>?
        /// 두 개의 Presents() 옵션을 Destination.State를 가리키는 하나의 옵션으로 바꿉니다.
        @Presents var destination: Destination.State?
        var contacts: IdentifiedArrayOf<Contact> = []
    }
    enum Action {
        case addButtonTapped
//        case addContact(PresentationAction<AddContactFeature.Action>) // 부모는 자식 Feature에서 보낸 모든 Action을 관찰할 수 있습니다.
//        case alert(PresentationAction<Alert>)
        case destination(PresentationAction<Destination.Action>)
        case deleteButtonTapped(id: Contact.ID) // 연락처 목록의 행에서 삭제 버튼을 탭할 때 전송될 새 작업을 추가
        
        
        enum Alert: Equatable {
            case confirmDeletion(id: Contact.ID)
        }
    }
    
    /// ContactsFeature에서 탐색할 수 있는 모든 Feature에 대한 도메인과 로직을 보유한다.
    @Reducer(state: .equatable) // Reducer(state:action:)의 state 인수를 사용하여 매크로에 Destination.State에 Equatable 적합성을 적용하도록 지시합니다.
    enum Destination {
        case addContact(AddContactFeature)
        case alert(AlertState<ContactsFeature.Action.Alert>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .addButtonTapped:
                // 연락처 목록 기능에서 '+' 버튼을 탭하면 이제 해당 Feature가 표시되어야 함을 나타내는 AddContactFeature를 채울 수 있습니다.
                state.destination = .addContact(
                    AddContactFeature.State(
                        contact: Contact(id: UUID(), name: "")
                    )
                )
                return .none

            // AddContactFeature 내에서 'Save' 버튼을 탭하면 해당 Feature를 해제할 뿐만 아니라
            // 새 연락처를 ContactsFeature.State에 보관된 연락처 모음에 추가하고 싶습니다.
            case let .destination(.presented(.addContact(.delegate(.saveContact(contact))))):
              state.contacts.append(contact)
              return .none
                
            case let .destination(.presented(.alert(.confirmDeletion(id: id)))):
              state.contacts.remove(id: id)
              return .none

            case .destination:
              return .none

            case let .deleteButtonTapped(id: id):
              // 삭제 버튼을 탭하면 사용자에게 연락처 삭제를 확인하도록 요청하기 위해 AlertState를 채울 수 있습니다.
                state.destination = .alert(
                    AlertState {
                        TextState("Are you sure?")
                    } actions: {
                        ButtonState(role: .destructive, action: .confirmDeletion(id: id)) {
                            TextState("Delete")
                        }
                    }
                )
                return .none
            }
        }
//        // 이렇게 하면 자식 Action이 시스템에 들어올 때 자식 Reducer를 실행하고 모든 Action에 대해 부모 Reducer를 실행하는 새 Reducer가 생성됩니다.
//        // 또한 자식 Feature가 해제될 때 effact 취소 등을 자동으로 처리합니다. 자세한 내용은 문서를 참조하세요.
//        .ifLet(\.$addContact, action: \.addContact) {
//          AddContactFeature()
//        }
//        .ifLet(\.$alert, action: \.alert) // Alert 로직을 ContactsFeature에 통합하기.
        
        /// 감속기 하단에 사용된 두 개의 ifLet을 Destination 도메인에 초점을 맞춘 하나의 ifLet으로 바꿉니다.
        /// 이 표현식에서 Destination 유형을 지정할 필요도 없는데, 이는 Reducer() 매크로가 Destination 열거형에 적용된 방식에서 유추할 수 있기 때문입니다.
        .ifLet(\.$destination, action: \.destination)

    }
}
