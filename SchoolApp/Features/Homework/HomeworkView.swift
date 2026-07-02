import SwiftUI

struct HomeworkView: View {
    @State private var selectedScope: HomeworkScope = .tomorrow

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                header
                scopePicker
                parseCard
                homeworkList
            }
            .padding(.horizontal, 20)
            .padding(.top, 22)
            .padding(.bottom, SchoolTheme.bottomScrollPadding)
        }
        .background(SchoolTheme.page.ignoresSafeArea())
    }

    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Домашка")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(SchoolTheme.graphite)
                Text("Понятно, по предметам и дедлайнам")
                    .font(.subheadline)
                    .foregroundStyle(SchoolTheme.muted)
            }

            Spacer()

            HeaderIconButton(systemName: "camera.viewfinder")
                .accessibilityLabel("Сфотографировать ДЗ")
            HeaderIconButton(systemName: "plus")
                .accessibilityLabel("Добавить ДЗ")
        }
    }

    private var scopePicker: some View {
        Picker("Период", selection: $selectedScope) {
            ForEach(HomeworkScope.allCases) { scope in
                Text(scope.title).tag(scope)
            }
        }
        .pickerStyle(.segmented)
    }

    private var parseCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    IconBadge(systemName: "sparkles", color: SchoolTheme.success)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Разобрать ДЗ")
                            .font(.headline)
                            .foregroundStyle(SchoolTheme.graphite)
                        Text("Фото доски, текст, скрин или голос")
                            .font(.subheadline)
                            .foregroundStyle(SchoolTheme.muted)
                    }
                    Spacer()
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    parseAction("Сфоткать", "camera", SchoolTheme.success)
                    parseAction("Загрузить", "photo", SchoolTheme.accent)
                    parseAction("Продиктовать", "mic", SchoolTheme.teal)
                    parseAction("Скрин", "doc.viewfinder", SchoolTheme.warning)
                }
            }
        }
    }

    private var homeworkList: some View {
        VStack(spacing: 12) {
            ForEach(SampleData.homework) { item in
                homeworkCard(item)
            }
        }
    }

    private func homeworkCard(_ item: HomeworkItem) -> some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    IconBadge(systemName: "book.closed", color: badgeColor(for: item.status), size: 42)

                    VStack(alignment: .leading, spacing: 5) {
                        Text(item.subject)
                            .font(.headline)
                            .foregroundStyle(SchoolTheme.graphite)
                        Text(item.title)
                            .font(.subheadline)
                            .foregroundStyle(SchoolTheme.graphite)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()
                    StatusBadge(text: item.status.rawValue, color: badgeColor(for: item.status))
                }

                HStack(spacing: 10) {
                    Label(item.dueLabel, systemImage: "clock")
                    Label(item.source, systemImage: "person.crop.circle")
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(SchoolTheme.muted)

                if let bring = item.bring {
                    Label("Принести: \(bring)", systemImage: "shippingbox")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(SchoolTheme.warning)
                }

                HStack {
                    Button("Отметить") {}
                        .buttonStyle(.bordered)
                    Button("Напомнить") {}
                        .buttonStyle(.borderless)
                    Spacer()
                }
                .font(.subheadline.weight(.semibold))
            }
        }
    }

    private func parseAction(_ title: String, _ icon: String, _ color: Color) -> some View {
        Button {
        } label: {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, minHeight: 42)
            .background(color.opacity(0.09), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func badgeColor(for status: HomeworkItem.Status) -> Color {
        switch status {
        case .pending:
            SchoolTheme.warning
        case .done:
            SchoolTheme.success
        case .review:
            SchoolTheme.accent
        }
    }
}

private enum HomeworkScope: String, CaseIterable, Identifiable {
    case today
    case tomorrow
    case week
    case done

    var id: String { rawValue }

    var title: String {
        switch self {
        case .today:
            "Сегодня"
        case .tomorrow:
            "Завтра"
        case .week:
            "Неделя"
        case .done:
            "Готово"
        }
    }
}

#Preview {
    HomeworkView()
}
