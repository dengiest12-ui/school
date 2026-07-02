import SwiftUI

struct MoreView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                header
                profileCard
                menuSection("Семья", items: familyItems)
                menuSection("Приложение", items: appItems)
                menuSection("Помощь", items: helpItems)
            }
            .padding(.horizontal, 20)
            .padding(.top, 22)
            .padding(.bottom, 28)
        }
        .background(SchoolTheme.page.ignoresSafeArea())
    }

    private var header: some View {
        HStack {
            Text("Еще")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(SchoolTheme.graphite)
            Spacer()
            HeaderIconButton(systemName: "gearshape")
                .accessibilityLabel("Настройки")
        }
    }

    private var profileCard: some View {
        DashboardCard {
            HStack(spacing: 14) {
                InitialAvatar(text: "В", color: SchoolTheme.accent, size: 58)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Владимир")
                        .font(.headline)
                        .foregroundStyle(SchoolTheme.graphite)
                    Text("Родитель Миши, 3Б")
                        .font(.subheadline)
                        .foregroundStyle(SchoolTheme.muted)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(SchoolTheme.muted)
            }
        }
    }

    private func menuSection(_ title: String, items: [MoreMenuItem]) -> some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 14) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(SchoolTheme.graphite)

                ForEach(items) { item in
                    HStack(spacing: 12) {
                        IconBadge(systemName: item.icon, color: item.color, size: 40)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(SchoolTheme.graphite)
                            Text(item.subtitle)
                                .font(.caption)
                                .foregroundStyle(SchoolTheme.muted)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(SchoolTheme.muted)
                    }
                }
            }
        }
    }

    private var familyItems: [MoreMenuItem] {
        [
            MoreMenuItem(title: "Дети", subtitle: "2 профиля", icon: "person.crop.square", color: SchoolTheme.success),
            MoreMenuItem(title: "Семья", subtitle: "Второй родитель, бабушка, няня", icon: "person.2.fill", color: SchoolTheme.teal),
            MoreMenuItem(title: "Классы", subtitle: "3Б и 4А", icon: "building.2.fill", color: SchoolTheme.accent)
        ]
    }

    private var appItems: [MoreMenuItem] {
        [
            MoreMenuItem(title: "Подписка", subtitle: "Пробный период и семейный доступ", icon: "creditcard.fill", color: SchoolTheme.warning),
            MoreMenuItem(title: "Уведомления", subtitle: "Дайджесты, дедлайны, срочное", icon: "bell.fill", color: SchoolTheme.success),
            MoreMenuItem(title: "Память класса", subtitle: "Поиск по объявлениям и файлам", icon: "magnifyingglass", color: SchoolTheme.accent),
            MoreMenuItem(title: "Файлы", subtitle: "Согласия, чеки, материалы", icon: "folder.fill", color: SchoolTheme.teal)
        ]
    }

    private var helpItems: [MoreMenuItem] {
        [
            MoreMenuItem(title: "Безопасность", subtitle: "Данные детей и доступы", icon: "lock.shield.fill", color: SchoolTheme.success),
            MoreMenuItem(title: "Поддержка", subtitle: "Написать нам", icon: "message.fill", color: SchoolTheme.accent),
            MoreMenuItem(title: "Проблема", subtitle: "Сообщить об ошибке", icon: "exclamationmark.bubble.fill", color: SchoolTheme.danger)
        ]
    }
}

private struct MoreMenuItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
}

#Preview {
    MoreView()
}
