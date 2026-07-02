import SwiftUI

struct CalendarView: View {
    @State private var selectedMode: CalendarMode = .list

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                header
                modePicker
                weekCard
                eventsList
                circlesCard
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
                Text("Календарь")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(SchoolTheme.graphite)
                Text("События, кружки и дедлайны")
                    .font(.subheadline)
                    .foregroundStyle(SchoolTheme.muted)
            }

            Spacer()

            HeaderIconButton(systemName: "calendar.badge.plus")
                .accessibilityLabel("Создать событие")
        }
    }

    private var modePicker: some View {
        Picker("Режим", selection: $selectedMode) {
            ForEach(CalendarMode.allCases) { mode in
                Text(mode.title).tag(mode)
            }
        }
        .pickerStyle(.segmented)
    }

    private var weekCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    IconBadge(systemName: "calendar", color: SchoolTheme.accent)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Эта неделя")
                            .font(.headline)
                            .foregroundStyle(SchoolTheme.graphite)
                        Text("Сегодня выбран четверг, 22 мая")
                            .font(.subheadline)
                            .foregroundStyle(SchoolTheme.muted)
                    }
                    Spacer()
                }

                HStack(spacing: 8) {
                    ForEach(SampleData.weekDays) { day in
                        VStack(spacing: 5) {
                            Text(day.weekday)
                                .font(.caption)
                                .foregroundStyle(day.isSelected ? .white.opacity(0.88) : SchoolTheme.muted)
                            Text(day.day)
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(day.isSelected ? .white : SchoolTheme.graphite)
                        }
                        .frame(maxWidth: .infinity, minHeight: 58)
                        .background(day.isSelected ? SchoolTheme.accent : Color.clear, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                    }
                }
            }
        }
    }

    private var eventsList: some View {
        VStack(spacing: 12) {
            ForEach(SampleData.events) { event in
                DashboardCard {
                    HStack(alignment: .top, spacing: 12) {
                        IconBadge(systemName: "calendar.circle", color: SchoolTheme.success, size: 42)
                        VStack(alignment: .leading, spacing: 5) {
                            Text(event.title)
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)
                            Text(event.dateLabel)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(SchoolTheme.success)
                            Text(event.detail)
                                .font(.caption)
                                .foregroundStyle(SchoolTheme.muted)
                        }
                        Spacer()
                    }
                }
            }
        }
    }

    private var circlesCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Личные кружки")
                    .font(.headline)
                    .foregroundStyle(SchoolTheme.graphite)
                circleRow("Шахматы", "Сегодня 17:00", "brain.head.profile", SchoolTheme.teal)
                circleRow("Английский", "Среда 18:30", "text.book.closed", SchoolTheme.accent)
            }
        }
    }

    private func circleRow(_ title: String, _ subtitle: String, _ icon: String, _ color: Color) -> some View {
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
            Image(systemName: "bell")
                .foregroundStyle(SchoolTheme.muted)
        }
    }
}

private enum CalendarMode: String, CaseIterable, Identifiable {
    case day
    case week
    case month
    case list

    var id: String { rawValue }

    var title: String {
        switch self {
        case .day:
            "День"
        case .week:
            "Неделя"
        case .month:
            "Месяц"
        case .list:
            "Список"
        }
    }
}

#Preview {
    CalendarView()
}
