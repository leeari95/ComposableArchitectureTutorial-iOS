//
//  ContactsView.swift
//  ComposableArchitectureTutorial-iOS
//
//  Created by Ari on 5/21/24.
//

import SwiftUI
import ComposableArchitecture

// 바인딩 가능 속성 래퍼를 사용하여 store에 대한 바인딩을 파생하고, 이 바인딩은 addContact 기능의 프레젠테이션 도메인으로만 범위를 좁혀 시트(항목:) 보기 수정자에 전달할 수 있습니다. addContact 상태가 nil이 아닌 상태가 되면 AddContactFeature 도메인에만 초점을 맞춘 새 스토어가 파생되며, 이 스토어는 AddContactView에 전달할 수 있습니다.


struct ContactsView: View {
    /// 이 바인딩은 addContact Feature의 프레젠테이션 도메인으로만 범위를 좁혀 sheet(item:) View Modifier에 전달할 수 있습니다.
    @Bindable var store: StoreOf<ContactsFeature>
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(store.contacts) { contact in
                    HStack {
                      Text(contact.name)
                      Spacer()
                      Button {
                        store.send(.deleteButtonTapped(id: contact.id))
                      } label: {
                        Image(systemName: "trash")
                          .foregroundColor(.red)
                      }
                    }
                }
            }
            .navigationTitle("Contacts")
            .toolbar {
                ToolbarItem {
                    Button {
                        store.send(.addButtonTapped)
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(
            item: $store.scope(state: \.destination?.addContact, action: \.destination.addContact)
        ) { addContactStore in
            NavigationStack {
                AddContactView(store: addContactStore)
            }
        }
        .alert($store.scope(state: \.destination?.alert, action: \.destination.alert))
    }
}
