import SwiftUI

struct ClassRoomView: View {
    @State private var selectedSection: ClassSection = .feed

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                header
                classSummary
                sectionPicker
                selectedContent
            }
            .padding(.horizontal, 20)
            .padding(.top, 22)
            .padding(.bottom, 28)
        }
        .background(SchoolTheme.page.ignoresSafeArea())
    }

    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Класс 3Б")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(SchoolTheme.graphite)
                Text("Лента, чаты, сборы и материалы")
                    .font(.subheadline)
                    .foregroundStyle(SchoolTheme.muted)
            }

            Spacer()

            HeaderIconButton(systemName: "magnifyingglass")
                .accessibilityLabel("Поиск")
            HeaderIconButton(systemName: "plus")
                .accessibilityLabel("Добавить")
        }
    }

    private var classSummary: some View {
        DashboardCard {
            HStack(spacing: 14) {
                IconBadge(systemName: "person.3.fill", color: SchoolTheme.success, size: 52)
                VStack(alignment: .leading, spacing: 4) {
                    Text("25 родителей подключены")
                        .font(.headline)
                        .foregroundStyle(SchoolTheme.graphite)
                    Text("Сегодня: 1 объявление, 2 задачи, 1 сбор")
                        .font(.subheadline)
                        .foregroundStyle(SchoolTheme.muted)
                }
                Spacer()
            }
        }
    }

    private var sectionPicker: some View {
        Picker("Раздел", selection: $selectedSection) {
            ForEach(ClassSection.allCases) { section in
                Text(section.title).tag(section)
            }
        }
        .pickerStyle(.segmented)
    }

    @ViewBuilder
    private var selectedContent: some View {
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

    private var feedContent: some View {
        VStack(spacing: 12) {
            ForEach(SampleData.feed) { item in
                DashboardCard {
                    VStack(alignment: .leading, spacing: 10) {
                        StatusBadge(text: item.tag, color: badgeColor(for: item.tag))
                        Text(item.title)
                            .font(.headline)
                            .foregroundStyle(SchoolTheme.graphite)
                        Text(item.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(SchoolTheme.muted)
                        HStack {
                            Button("Открыть") {}
                                .buttonStyle(.bordered)
                            Button("Напомнить") {}
                                .buttonStyle(.borderless)
                            Spacer()
                        }
                        .font(.subheadline.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private var chatContent: some View {
        VStack(spacing: 12) {
            DashboardCard {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        IconBadge(systemName: "sparkles", color: SchoolTheme.accent)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Тихий чат")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)
                            Text("Важное за день без лишнего шума")
                                .font(.subheadline)
                                .foregroundStyle(SchoolTheme.muted)
                        }
                    }

                    Text("3 важных пункта: форма на физкультуру, проект «Моя семья», экскурсия в пятницу.")
                        .font(.subheadline)
                        .foregroundStyle(SchoolTheme.graphite)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            ForEach(SampleData.chats) { chat in
                DashboardCard {
                    HStack(spacing: 12) {
                        IconBadge(systemName: chat.icon, color: color(for: chat.colorName), size: 44)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(chat.title)
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)
                            Text(chat.message)
                                .font(.subheadline)
                                .foregroundStyle(SchoolTheme.muted)
                                .lineLimit(2)
                        }
                        Spacer()
                        Text(chat.timeLabel)
                            .font(.caption)
                            .foregroundStyle(SchoolTheme.muted)
                    }
                }
            }
        }
    }

    private var collectionsContent: some View {
        VStack(spacing: 12) {
            ForEach(SampleData.collections) { collection in
                DashboardCard {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(collection.title)
                                    .font(.headline)
                                    .foregroundStyle(SchoolTheme.graphite)
                                Text("Срок: \(collection.deadline)")
                                    .font(.subheadline)
                                    .foregroundStyle(SchoolTheme.muted)
                            }
                            Spacer()
                            InfoPill(text: collection.amount, color: SchoolTheme.warning)
                        }

                        ProgressView(value: Double(collection.paidCount), total: Double(collection.totalCount))
                            .tint(SchoolTheme.success)

                        HStack {
                            Text("\(collection.paidCount) из \(collection.totalCount) сдали")
                            Spacer()
                            Text("Осталось \(collection.totalCount - collection.paidCount)")
                        }
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(SchoolTheme.muted)
                    }
                }
            }
        }
    }

    private var photosContent: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            photoTile("Экскурсии", "photo.on.rectangle", SchoolTheme.accent)
            photoTile("Праздники", "party.popper", SchoolTheme.warning)
            photoTile("Будни класса", "camera", SchoolTheme.teal)
            photoTile("Документы", "doc.text", SchoolTheme.success)
        }
    }

    private var membersContent: some View {
        VStack(spacing: 12) {
            DashboardCard {
                VStack(spacing: 14) {
                    memberRow("Родители", "25 участников", "person.2.fill", SchoolTheme.success)
                    memberRow("Классный руководитель", "1 учитель", "graduationcap.fill", SchoolTheme.accent)
                    memberRow("Родкомитет", "3 ответственных", "person.badge.shield.checkmark.fill", SchoolTheme.teal)
                }
            }

            Button {
            } label: {
                Label("Пригласить родителей", systemImage: "link")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 52)
            }
            .buttonStyle(.borderedProminent)
            .tint(SchoolTheme.success)
        }
    }

    private func photoTile(_ title: String, _ icon: String, _ color: Color) -> some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 18) {
                IconBadge(systemName: icon, color: color)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(SchoolTheme.graphite)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func memberRow(_ title: String, _ subtitle: String, _ icon: String, _ color: Color) -> some View {
        HStack(spacing: 12) {
            IconBadge(systemName: icon, color: color, size: 42)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(SchoolTheme.muted)
        }
    }

    private func badgeColor(for tag: String) -> Color {
        switch tag {
        case "Родкомитет":
            SchoolTheme.warning
        case "Тихий чат":
            SchoolTheme.accent
        default:
            SchoolTheme.success
        }
    }

    private func color(for colorName: String) -> Color {
        switch colorName {
        case "green":
            SchoolTheme.success
        case "teal":
            SchoolTheme.teal
        default:
            SchoolTheme.accent
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
    ClassRoomView()
}
