import SwiftUI

struct MoreView: View {
    var body: some View {
        List {
            Section("Семья") {
                NavigationLink {
                    Text("Дети")
                } label: {
                    Label("Дети", systemImage: "person.crop.square")
                }
                NavigationLink {
                    Text("Семья")
                } label: {
                    Label("Семья", systemImage: "person.2")
                }
                NavigationLink {
                    Text("Классы")
                } label: {
                    Label("Классы", systemImage: "building.2")
                }
            }

            Section("Приложение") {
                Label("Подписка", systemImage: "creditcard")
                Label("Уведомления", systemImage: "bell")
                Label("Память класса", systemImage: "magnifyingglass")
                Label("Файлы", systemImage: "folder")
            }

            Section("Помощь") {
                Label("Безопасность", systemImage: "lock.shield")
                Label("Написать в поддержку", systemImage: "message")
                Label("Сообщить о проблеме", systemImage: "exclamationmark.bubble")
            }
        }
        .listStyle(.insetGrouped)
    }
}

#Preview {
    NavigationStack {
        MoreView()
            .navigationTitle("Еще")
    }
}

