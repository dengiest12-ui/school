import SwiftUI

struct TodayView: View {
    @State private var selectedChild = SampleData.children[0]

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                childPicker
                tomorrowSummary
                urgentTasks
                homeworkPreview
                schedulePreview
                chatDigest
                quickActions
            }
            .padding(.vertical, 16)
        }
        .background(SchoolTheme.page)
    }

    private var childPicker: some View {
        Picker("Ребенок", selection: $selectedChild) {
            ForEach(SampleData.children) { child in
                Text("\(child.name), \(child.className)").tag(child)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }

    private var tomorrowSummary: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Что завтра?")
                        .font(.title2.weight(.bold))
                    Text("3 урока, 2 ДЗ, форма на физкультуру, картон и сбор 500 руб.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundStyle(SchoolTheme.accent)
            }

            Button {
            } label: {
                Label("Разобрать фото ДЗ", systemImage: "camera.viewfinder")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
        .background(SchoolTheme.surface, in: RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal)
    }

    private var urgentTasks: some View {
        VStack(spacing: 10) {
            SectionHeader("Принести / оплатить / подписать")
            ForEach(SampleData.parentTasks) { task in
                HStack(spacing: 12) {
                    Image(systemName: iconName(for: task.kind))
                        .font(.headline)
                        .foregroundStyle(SchoolTheme.warning)
                        .frame(width: 28)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(task.title)
                            .font(.subheadline.weight(.semibold))
                        Text(task.dueLabel)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button {
                    } label: {
                        Image(systemName: "checkmark")
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.circle)
                    .accessibilityLabel("Отметить выполнено")
                }
                .padding()
                .background(.background, in: RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal)
            }
        }
    }

    private var homeworkPreview: some View {
        VStack(spacing: 10) {
            SectionHeader("Домашние задания", actionTitle: "Все") {}
            ForEach(SampleData.homework.prefix(2)) { item in
                HomeworkCompactRow(item: item)
                    .padding(.horizontal)
            }
        }
    }

    private var schedulePreview: some View {
        VStack(spacing: 10) {
            SectionHeader("Расписание и кружки")
            ForEach(SampleData.schedule) { item in
                HStack {
                    Text(item.time)
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                        .frame(width: 48, alignment: .leading)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.title)
                            .font(.subheadline.weight(.semibold))
                        Text(item.detail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .padding()
                .background(.background, in: RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal)
            }
        }
    }

    private var chatDigest: some View {
        VStack(spacing: 10) {
            SectionHeader("Важное из чата")
            VStack(alignment: .leading, spacing: 8) {
                StatusBadge(text: "AI-дайджест", color: SchoolTheme.accent)
                Text("За день найдено 3 важных пункта. Остальное - обсуждение подарка и расписания.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.background, in: RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal)
        }
    }

    private var quickActions: some View {
        VStack(spacing: 10) {
            SectionHeader("Быстрые действия")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                actionButton("Добавить ДЗ", "plus.circle")
                actionButton("Событие", "calendar.badge.plus")
                actionButton("Сбор", "rublesign.circle")
                actionButton("Чат", "bubble.left.and.bubble.right")
            }
            .padding(.horizontal)
        }
    }

    private func actionButton(_ title: String, _ icon: String) -> some View {
        Button {
        } label: {
            Label(title, systemImage: icon)
                .frame(maxWidth: .infinity, minHeight: 44)
        }
        .buttonStyle(.bordered)
    }

    private func iconName(for kind: ParentTask.Kind) -> String {
        switch kind {
        case .bring:
            "shippingbox"
        case .pay:
            "rublesign.circle"
        case .sign:
            "signature"
        case .buy:
            "cart"
        }
    }
}

private struct HomeworkCompactRow: View {
    let item: HomeworkItem

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "book.closed")
                .foregroundStyle(SchoolTheme.accent)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.subject)
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text(item.dueLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(item.title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    NavigationStack {
        TodayView()
            .navigationTitle("Сегодня")
    }
}

