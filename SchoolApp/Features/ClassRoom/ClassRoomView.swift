import SwiftUI

struct ClassRoomView: View {
    @State private var selectedSection: ClassSection = .feed

    var body: some View {
        VStack(spacing: 0) {
            Picker("Раздел", selection: $selectedSection) {
                ForEach(ClassSection.allCases) { section in
                    Text(section.title).tag(section)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            List {
                switch selectedSection {
                case .feed:
                    feedContent
                case .chats:
                    chatContent
                case .collections:
                    collectionsContent
                case .photos:
                    photosContent
                case .members:
                    membersContent
                }
            }
            .listStyle(.insetGrouped)
        }
        .background(SchoolTheme.page)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Добавить")
            }
        }
    }

    private var feedContent: some View {
        Section("Лента класса") {
            ForEach(SampleData.feed) { item in
                VStack(alignment: .leading, spacing: 6) {
                    StatusBadge(text: item.tag, color: SchoolTheme.accent)
                    Text(item.title)
                        .font(.headline)
                    Text(item.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 6)
            }
        }
    }

    private var chatContent: some View {
        Section("Тихий чат") {
            Label("Кратко за день", systemImage: "sparkles")
            Label("Только важное", systemImage: "line.3.horizontal.decrease.circle")
            Label("Что я пропустил?", systemImage: "questionmark.bubble")
            Label("Найти даты и задачи", systemImage: "calendar.badge.clock")
        }
    }

    private var collectionsContent: some View {
        Section("Сборы") {
            ForEach(SampleData.collections) { collection in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(collection.title)
                            .font(.headline)
                        Spacer()
                        Text(collection.amount)
                            .font(.subheadline.weight(.semibold))
                    }
                    ProgressView(value: Double(collection.paidCount), total: Double(collection.totalCount))
                    Text("\(collection.paidCount) из \(collection.totalCount) сдали, срок \(collection.deadline)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 6)
            }
        }
    }

    private var photosContent: some View {
        Section("Фотоальбомы") {
            Label("Экскурсии", systemImage: "photo.on.rectangle")
            Label("Праздники", systemImage: "party.popper")
            Label("Будни класса", systemImage: "camera")
        }
    }

    private var membersContent: some View {
        Section("Участники") {
            Label("25 родителей", systemImage: "person.2")
            Label("1 учитель", systemImage: "graduationcap")
            Label("3 участника родкомитета", systemImage: "person.badge.shield.checkmark")
            Button {
            } label: {
                Label("Пригласить по ссылке", systemImage: "link")
            }
        }
    }
}

private enum ClassSection: String, CaseIterable, Identifiable {
    case feed
    case chats
    case collections
    case photos
    case members

    var id: String { rawValue }

    var title: String {
        switch self {
        case .feed:
            "Лента"
        case .chats:
            "Чаты"
        case .collections:
            "Сборы"
        case .photos:
            "Фото"
        case .members:
            "Участники"
        }
    }
}

#Preview {
    NavigationStack {
        ClassRoomView()
            .navigationTitle("Класс")
    }
}

