import SwiftUI

struct TodayView: View {
    @State private var selectedChild = SampleData.children[0]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                header
                childCard
                tomorrowCard
                urgentCard
                homeworkCard
                scheduleCard
                chatsCard
                quickActionsCard
            }
            .padding(.horizontal, 20)
            .padding(.top, 22)
            .padding(.bottom, 28)
        }
        .background(SchoolTheme.page.ignoresSafeArea())
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            Text("Сегодня")
                .font(.system(size: 39, weight: .bold))
                .foregroundStyle(SchoolTheme.graphite)

            Spacer()

            HeaderIconButton(systemName: "bell", badgeColor: SchoolTheme.success)
                .accessibilityLabel("Уведомления")
            HeaderIconButton(systemName: "person.crop.circle")
                .accessibilityLabel("Профиль")
        }
        .padding(.top, 2)
    }

    private var childCard: some View {
        Menu {
            ForEach(SampleData.children) { child in
                Button("\(child.name), \(child.className)") {
                    selectedChild = child
                }
            }
        } label: {
            DashboardCard(padding: 0) {
                HStack(spacing: 14) {
                    InitialAvatar(text: selectedChild.avatarText, size: 58)
                        .padding(.leading, 10)
                        .padding(.vertical, 8)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(selectedChild.name), \(selectedChild.className)")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(SchoolTheme.graphite)
                        Text(selectedChild.school)
                            .font(.caption)
                            .foregroundStyle(SchoolTheme.muted)
                    }

                    Image(systemName: "chevron.down")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(SchoolTheme.muted)

                    Spacer()
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var tomorrowCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 14) {
                    IconBadge(systemName: "calendar", color: SchoolTheme.success)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Что завтра")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(SchoolTheme.success)
                        Text("Четверг, 22 мая")
                            .font(.subheadline)
                            .foregroundStyle(SchoolTheme.muted)
                    }

                    Spacer()
                    InfoPill(text: "План дня", color: SchoolTheme.success)
                }

                VStack(spacing: 11) {
                    ForEach(Array(SampleData.schedule.enumerated()), id: \.element.id) { index, item in
                        scheduleRow(number: index + 1, item: item)
                    }
                }

                Button {
                } label: {
                    Label("Разобрать фото ДЗ", systemImage: "camera.viewfinder")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: 42)
                }
                .buttonStyle(.borderedProminent)
                .tint(SchoolTheme.success)
            }
        }
    }

    private var urgentCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 14) {
                    IconBadge(systemName: "exclamationmark", color: SchoolTheme.danger)
                    Text("Срочно")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(SchoolTheme.danger)
                    Spacer()
                    Text("2")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .background(SchoolTheme.danger, in: Circle())
                    Image(systemName: "chevron.right")
                        .foregroundStyle(SchoolTheme.muted)
                }

                VStack(alignment: .leading, spacing: 14) {
                    ForEach(Array(SampleData.parentTasks.prefix(2))) { task in
                        HStack(alignment: .firstTextBaseline, spacing: 12) {
                            Circle()
                                .fill(SchoolTheme.danger)
                                .frame(width: 9, height: 9)
                            Text(task.title)
                                .font(.subheadline)
                                .foregroundStyle(SchoolTheme.graphite)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer(minLength: 8)
                            Text(task.dueLabel)
                                .font(.caption)
                                .foregroundStyle(SchoolTheme.muted)
                        }
                    }
                }
            }
        }
    }

    private var homeworkCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 14) {
                    IconBadge(systemName: "book.closed", color: SchoolTheme.success)
                    Text("Домашка")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(SchoolTheme.success)
                    Spacer()
                    InfoPill(text: "3 задания", color: SchoolTheme.success)
                    Image(systemName: "chevron.right")
                        .foregroundStyle(SchoolTheme.muted)
                }

                VStack(spacing: 13) {
                    ForEach(Array(SampleData.homework.enumerated()), id: \.element.id) { index, item in
                        homeworkRow(item: item, isDone: index == 0)
                    }
                }
            }
        }
    }

    private var scheduleCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 14) {
                    IconBadge(systemName: "clock", color: SchoolTheme.accent)
                    Text("Расписание")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(SchoolTheme.accent)
                    Spacer()
                    InfoPill(text: "На неделю", color: SchoolTheme.accent)
                    Image(systemName: "chevron.right")
                        .foregroundStyle(SchoolTheme.muted)
                }

                HStack(spacing: 8) {
                    ForEach(SampleData.weekDays) { day in
                        dayChip(day)
                    }
                }
            }
        }
    }

    private var chatsCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 14) {
                    IconBadge(systemName: "bubble.left.and.bubble.right", color: SchoolTheme.accent)
                    Text("Чаты")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(SchoolTheme.accent)
                    Spacer()
                    InfoPill(text: "3 новых", color: SchoolTheme.accent)
                    Image(systemName: "chevron.right")
                        .foregroundStyle(SchoolTheme.muted)
                }

                VStack(spacing: 14) {
                    ForEach(SampleData.chats) { chat in
                        chatRow(chat)
                    }
                }
            }
        }
    }

    private var quickActionsCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Быстрые действия")
                    .font(.headline)
                    .foregroundStyle(SchoolTheme.graphite)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    quickAction("Добавить ДЗ", "plus.circle", SchoolTheme.success)
                    quickAction("Событие", "calendar.badge.plus", SchoolTheme.accent)
                    quickAction("Сбор", "rublesign.circle", SchoolTheme.warning)
                    quickAction("Открыть чат", "bubble.left", SchoolTheme.teal)
                }
            }
        }
    }

    private func scheduleRow(number: Int, item: ScheduleItem) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Text("\(number)")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(SchoolTheme.graphite)
                .frame(width: 22, alignment: .leading)
            Text(item.time)
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(SchoolTheme.muted)
                .frame(width: 56, alignment: .leading)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite)
                Text(item.detail)
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
            }
            Spacer()
        }
    }

    private func homeworkRow(item: HomeworkItem, isDone: Bool) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(item.subject)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(SchoolTheme.graphite)
                .frame(width: 122, alignment: .leading)

            Text(item.title)
                .font(.subheadline)
                .foregroundStyle(SchoolTheme.graphite)
                .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(isDone ? SchoolTheme.success : SchoolTheme.muted.opacity(0.55))
        }
    }

    private func dayChip(_ day: DayChip) -> some View {
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

    private func chatRow(_ chat: ChatPreviewItem) -> some View {
        HStack(spacing: 12) {
            IconBadge(systemName: chat.icon, color: color(for: chat.colorName), size: 42)

            VStack(alignment: .leading, spacing: 2) {
                Text(chat.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite)
                Text(chat.message)
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                Text(chat.timeLabel)
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
                Circle()
                    .fill(chat.hasUnread ? SchoolTheme.accent : Color.clear)
                    .frame(width: 9, height: 9)
            }
        }
    }

    private func quickAction(_ title: String, _ icon: String, _ color: Color) -> some View {
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

#Preview {
    TodayView()
}
