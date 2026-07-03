import SwiftUI

struct TodayView: View {
    @State private var selectedChild = SampleData.children[0]
    @State private var schedule = SampleData.schedule
    @State private var personalCircles = SampleData.personalCircles
    @State private var selectedScheduleDay = "Чт"
    @State private var activeSheet: TodaySheet?

    init() {
        _activeSheet = State(initialValue: TodayView.launchSheet())
    }

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
            .padding(.bottom, SchoolTheme.bottomScrollPadding)
        }
        .background(SchoolTheme.page.ignoresSafeArea())
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .schedule:
                SchedulePlannerSheet(
                    schedule: $schedule,
                    personalCircles: $personalCircles,
                    selectedDay: $selectedScheduleDay,
                    onAddLesson: {
                        activeSheet = .addLesson
                    },
                    onImportSchedule: {
                        activeSheet = .importSchedule
                    }
                )
            case .addLesson:
                AddLessonSheet(defaultDay: selectedScheduleDay) { lesson in
                    schedule.append(lesson)
                    selectedScheduleDay = lesson.day
                }
            case .importSchedule:
                ScheduleImportSheet { importedLessons in
                    schedule.append(contentsOf: importedLessons)
                    selectedScheduleDay = importedLessons.first?.day ?? selectedScheduleDay
                }
            }
        }
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

                    Button {
                        activeSheet = .schedule
                    } label: {
                        InfoPill(text: "План дня", color: SchoolTheme.success)
                    }
                    .buttonStyle(.plain)
                }

                VStack(spacing: 11) {
                    ForEach(Array(tomorrowLessons.enumerated()), id: \.element.id) { index, item in
                        scheduleRow(number: index + 1, item: item)
                    }

                    ForEach(tomorrowCircles) { circle in
                        circleSummaryRow(circle)
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
                    Button {
                        activeSheet = .schedule
                    } label: {
                        InfoPill(text: "\(selectedLessons.count) урока", color: SchoolTheme.accent)
                    }
                    .buttonStyle(.plain)
                    Image(systemName: "chevron.right")
                        .foregroundStyle(SchoolTheme.muted)
                }

                HStack(spacing: 8) {
                    ForEach(SampleData.weekDays) { day in
                        Button {
                            selectedScheduleDay = day.weekday
                        } label: {
                            dayChip(day, isSelected: selectedScheduleDay == day.weekday)
                        }
                        .buttonStyle(.plain)
                    }
                }

                VStack(spacing: 10) {
                    ForEach(selectedLessons.prefix(2)) { lesson in
                        compactLessonRow(lesson)
                    }

                    if let firstCircle = selectedCircles.first {
                        compactCircleRow(firstCircle)
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
                    quickAction("Добавить ДЗ", "plus.circle", SchoolTheme.success) {}
                    quickAction("Кружок", "figure.run", SchoolTheme.teal) {
                        activeSheet = .schedule
                    }
                    quickAction("Событие", "calendar.badge.plus", SchoolTheme.accent) {}
                    quickAction("Сбор", "rublesign.circle", SchoolTheme.warning) {}
                    quickAction("Расписание", "clock.badge.checkmark", SchoolTheme.accent) {
                        activeSheet = .schedule
                    }
                    quickAction("Открыть чат", "bubble.left", SchoolTheme.teal) {}
                }
            }
        }
    }

    private var tomorrowLessons: [ScheduleItem] {
        lessons(for: "Чт")
    }

    private var tomorrowCircles: [PersonalCircle] {
        circles(for: "Чт")
    }

    private var selectedLessons: [ScheduleItem] {
        lessons(for: selectedScheduleDay)
    }

    private var selectedCircles: [PersonalCircle] {
        circles(for: selectedScheduleDay)
    }

    private func lessons(for day: String) -> [ScheduleItem] {
        schedule
            .filter { $0.day == day }
            .sorted { $0.time < $1.time }
    }

    private func circles(for day: String) -> [PersonalCircle] {
        personalCircles
            .filter { $0.day == day }
            .sorted { $0.time < $1.time }
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
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(item.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SchoolTheme.graphite)
                    if item.isReplacement {
                        StatusBadge(text: "Замена", color: SchoolTheme.warning)
                    }
                    if item.requiresForm {
                        StatusBadge(text: "Форма", color: SchoolTheme.danger)
                    }
                }
                Text(item.detailLine)
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
            }
            Spacer()
        }
    }

    private func circleSummaryRow(_ circle: PersonalCircle) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: circle.iconName)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(SchoolTheme.teal)
                .frame(width: 22, alignment: .leading)
            Text(circle.time)
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(SchoolTheme.muted)
                .frame(width: 56, alignment: .leading)
            VStack(alignment: .leading, spacing: 2) {
                Text(circle.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite)
                Text("\(circle.place) - \(circle.responsible)")
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

    private func dayChip(_ day: DayChip, isSelected: Bool) -> some View {
        VStack(spacing: 5) {
            Text(day.weekday)
                .font(.caption)
                .foregroundStyle(isSelected ? .white.opacity(0.88) : SchoolTheme.muted)
            Text(day.day)
                .font(.headline.weight(.semibold))
                .foregroundStyle(isSelected ? .white : SchoolTheme.graphite)
        }
        .frame(maxWidth: .infinity, minHeight: 58)
        .background(isSelected ? SchoolTheme.accent : Color.clear, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
    }

    private func compactLessonRow(_ lesson: ScheduleItem) -> some View {
        HStack(spacing: 12) {
            IconBadge(systemName: lesson.requiresForm ? "figure.run" : "book.closed", color: lesson.requiresForm ? SchoolTheme.danger : SchoolTheme.accent, size: 38)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(lesson.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SchoolTheme.graphite)
                    if lesson.isReplacement {
                        StatusBadge(text: "Замена", color: SchoolTheme.warning)
                    }
                }
                Text("\(lesson.time) - \(lesson.detailLine)")
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
                    .lineLimit(1)
            }
            Spacer()
        }
    }

    private func compactCircleRow(_ circle: PersonalCircle) -> some View {
        HStack(spacing: 12) {
            IconBadge(systemName: circle.iconName, color: color(for: circle.colorName), size: 38)
            VStack(alignment: .leading, spacing: 2) {
                Text(circle.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite)
                Text("\(circle.time) - \(circle.place)")
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
            }
            Spacer()
        }
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

    private func quickAction(_ title: String, _ icon: String, _ color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
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
        case "blue":
            SchoolTheme.accent
        default:
            SchoolTheme.warning
        }
    }

    private static func launchSheet() -> TodaySheet? {
        let arguments = ProcessInfo.processInfo.arguments

        if arguments.contains("-qa-today-schedule") {
            return .schedule
        }

        if arguments.contains("-qa-schedule-add") {
            return .addLesson
        }

        if arguments.contains("-qa-schedule-import") {
            return .importSchedule
        }

        return nil
    }
}

private struct SchedulePlannerSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var schedule: [ScheduleItem]
    @Binding var personalCircles: [PersonalCircle]
    @Binding var selectedDay: String

    let onAddLesson: () -> Void
    let onImportSchedule: () -> Void

    private var lessons: [ScheduleItem] {
        schedule
            .filter { $0.day == selectedDay }
            .sorted { $0.time < $1.time }
    }

    private var circles: [PersonalCircle] {
        personalCircles
            .filter { $0.day == selectedDay }
            .sorted { $0.time < $1.time }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    TodaySheetHeader(
                        icon: "clock.badge.checkmark",
                        color: SchoolTheme.accent,
                        title: "План дня",
                        subtitle: "Уроки, замены, форма и личные кружки"
                    )

                    summaryCard
                    dayPicker
                    lessonsCard
                    circlesCard
                    actionButtons
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Расписание")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var summaryCard: some View {
        DashboardCard {
            HStack(spacing: 12) {
                scheduleMetric(value: "\(lessons.count)", title: "уроки", color: SchoolTheme.accent)
                Divider()
                scheduleMetric(value: "\(lessons.filter(\.isReplacement).count)", title: "замены", color: SchoolTheme.warning)
                Divider()
                scheduleMetric(value: "\(circles.count)", title: "кружки", color: SchoolTheme.teal)
            }
            .frame(height: 62)
        }
    }

    private var dayPicker: some View {
        DashboardCard {
            HStack(spacing: 8) {
                ForEach(SampleData.weekDays) { day in
                    Button {
                        selectedDay = day.weekday
                    } label: {
                        VStack(spacing: 5) {
                            Text(day.weekday)
                                .font(.caption)
                                .foregroundStyle(selectedDay == day.weekday ? .white.opacity(0.88) : SchoolTheme.muted)
                            Text(day.day)
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(selectedDay == day.weekday ? .white : SchoolTheme.graphite)
                        }
                        .frame(maxWidth: .infinity, minHeight: 58)
                        .background(
                            selectedDay == day.weekday ? SchoolTheme.accent : Color.clear,
                            in: RoundedRectangle(cornerRadius: 13, style: .continuous)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var lessonsCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Уроки")
                    .font(.headline)
                    .foregroundStyle(SchoolTheme.graphite)

                if lessons.isEmpty {
                    emptyRow("Уроков на этот день нет", "moon.zzz", SchoolTheme.muted)
                } else {
                    ForEach(lessons) { lesson in
                        lessonRow(lesson)
                    }
                }
            }
        }
    }

    private var circlesCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Кружки и секции")
                    .font(.headline)
                    .foregroundStyle(SchoolTheme.graphite)

                if circles.isEmpty {
                    emptyRow("Личных занятий нет", "calendar.badge.checkmark", SchoolTheme.teal)
                } else {
                    ForEach(circles) { circle in
                        circleRow(circle)
                    }
                }
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 10) {
            Button {
                onAddLesson()
            } label: {
                Label("Добавить урок или замену", systemImage: "plus")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 52)
            }
            .buttonStyle(.borderedProminent)
            .tint(SchoolTheme.success)

            Button {
                onImportSchedule()
            } label: {
                Label("Разобрать фото расписания", systemImage: "camera.viewfinder")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 52)
            }
            .buttonStyle(.bordered)
            .tint(SchoolTheme.accent)
        }
    }

    private func scheduleMetric(value: String, title: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(color)
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }

    private func lessonRow(_ lesson: ScheduleItem) -> some View {
        HStack(alignment: .top, spacing: 12) {
            IconBadge(systemName: lesson.requiresForm ? "figure.run" : "book.closed", color: lesson.requiresForm ? SchoolTheme.danger : SchoolTheme.accent, size: 40)
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 7) {
                    Text(lesson.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SchoolTheme.graphite)
                    if lesson.isReplacement {
                        StatusBadge(text: "Замена", color: SchoolTheme.warning)
                    }
                    if lesson.requiresForm {
                        StatusBadge(text: "Форма", color: SchoolTheme.danger)
                    }
                }
                Text("\(lesson.time) - \(lesson.detailLine)")
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
                if !lesson.teacher.isEmpty {
                    Text(lesson.teacher)
                        .font(.caption)
                        .foregroundStyle(SchoolTheme.muted)
                }
            }
            Spacer()
        }
    }

    private func circleRow(_ circle: PersonalCircle) -> some View {
        HStack(alignment: .top, spacing: 12) {
            IconBadge(systemName: circle.iconName, color: color(for: circle.colorName), size: 40)
            VStack(alignment: .leading, spacing: 4) {
                Text(circle.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite)
                Text("\(circle.time) - \(circle.place)")
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
                Text("Ответственный: \(circle.responsible)")
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
            }
            Spacer()
        }
    }

    private func emptyRow(_ title: String, _ icon: String, _ color: Color) -> some View {
        HStack(spacing: 12) {
            IconBadge(systemName: icon, color: color, size: 40)
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(SchoolTheme.muted)
            Spacer()
        }
    }

    private func color(for colorName: String) -> Color {
        switch colorName {
        case "teal":
            SchoolTheme.teal
        case "blue":
            SchoolTheme.accent
        default:
            SchoolTheme.success
        }
    }
}

private struct AddLessonSheet: View {
    @Environment(\.dismiss) private var dismiss

    let defaultDay: String
    let onSave: (ScheduleItem) -> Void

    @State private var day: String
    @State private var time = "12:25"
    @State private var title = "Технология"
    @State private var cabinet = "Каб. 18"
    @State private var teacher = "Ирина Петровна"
    @State private var requiresForm = false
    @State private var isReplacement = false

    init(defaultDay: String, onSave: @escaping (ScheduleItem) -> Void) {
        self.defaultDay = defaultDay
        self.onSave = onSave
        _day = State(initialValue: defaultDay)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    TodaySheetHeader(
                        icon: "plus.circle.fill",
                        color: SchoolTheme.success,
                        title: "Добавить урок",
                        subtitle: "Урок, кабинет, учитель, форма или замена"
                    )

                    DashboardCard {
                        VStack(spacing: 12) {
                            dayMenu
                            TodayTextField(title: "Время", iconName: "clock", color: SchoolTheme.warning, text: $time)
                            TodayTextField(title: "Предмет", iconName: "book.closed", color: SchoolTheme.accent, text: $title)
                            TodayTextField(title: "Кабинет", iconName: "door.left.hand.open", color: SchoolTheme.teal, text: $cabinet)
                            TodayTextField(title: "Учитель", iconName: "graduationcap.fill", color: SchoolTheme.success, text: $teacher)
                        }
                    }

                    DashboardCard {
                        VStack(spacing: 12) {
                            Toggle(isOn: $requiresForm) {
                                toggleLabel("Нужна форма", "Физкультура или сменная одежда", "figure.run", SchoolTheme.danger)
                            }
                            .toggleStyle(.switch)
                            .tint(SchoolTheme.success)

                            Toggle(isOn: $isReplacement) {
                                toggleLabel("Это замена", "Покажем заметный бейдж в расписании", "arrow.triangle.2.circlepath", SchoolTheme.warning)
                            }
                            .toggleStyle(.switch)
                            .tint(SchoolTheme.success)
                        }
                    }

                }
                .padding(20)
                .padding(.bottom, 94)
            }
            .safeAreaInset(edge: .bottom) {
                saveButton
            }
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Новый урок")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var saveButton: some View {
        Button {
            save()
        } label: {
            Label("Сохранить урок", systemImage: "checkmark")
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: 52)
        }
        .buttonStyle(.borderedProminent)
        .tint(SchoolTheme.success)
        .disabled(time.trimmed.isEmpty || title.trimmed.isEmpty || cabinet.trimmed.isEmpty)
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 10)
        .background(SchoolTheme.page)
    }

    private var dayMenu: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("День")
                .font(.caption.weight(.semibold))
                .foregroundStyle(SchoolTheme.muted)

            Menu {
                ForEach(["Пн", "Вт", "Ср", "Чт", "Пт", "Сб"], id: \.self) { day in
                    Button(day) {
                        self.day = day
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    IconBadge(systemName: "calendar", color: SchoolTheme.accent, size: 38)
                    Text(day)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SchoolTheme.graphite)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(SchoolTheme.muted)
                }
                .padding(12)
                .background(SchoolTheme.surface, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .stroke(SchoolTheme.line, lineWidth: 1)
                }
            }
            .buttonStyle(.plain)
        }
    }

    private func toggleLabel(_ title: String, _ subtitle: String, _ icon: String, _ color: Color) -> some View {
        HStack(spacing: 12) {
            IconBadge(systemName: icon, color: color, size: 42)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
            }
        }
    }

    private func save() {
        let lesson = ScheduleItem(
            day: day,
            time: time.trimmed,
            title: title.trimmed,
            detail: cabinet.trimmed,
            teacher: teacher.trimmed,
            requiresForm: requiresForm,
            isReplacement: isReplacement
        )

        onSave(lesson)
        dismiss()
    }
}

private struct ScheduleImportSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: ([ScheduleItem]) -> Void

    @State private var recognizedText = """
    Пн 08:30 Литература каб 18
    Пн 09:25 Математика каб 21
    Пт 09:25 Английский вместо музыки каб 32
    """

    private let parsedLessons = [
        ScheduleItem(day: "Пн", time: "08:30", title: "Литература", detail: "Каб. 18", teacher: "Ирина Петровна"),
        ScheduleItem(day: "Пн", time: "09:25", title: "Математика", detail: "Каб. 21", teacher: "Ольга Ивановна"),
        ScheduleItem(day: "Пт", time: "09:25", title: "Английский язык", detail: "Вместо музыки, каб. 32", teacher: "Мария Олеговна", isReplacement: true)
    ]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    TodaySheetHeader(
                        icon: "camera.viewfinder",
                        color: SchoolTheme.accent,
                        title: "Расписание по фото",
                        subtitle: "Локальный разбор перед сохранением"
                    )

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Распознанный текст")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)
                            TextEditor(text: $recognizedText)
                                .font(.subheadline)
                                .foregroundStyle(SchoolTheme.graphite)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 118)
                                .padding(10)
                                .background(SchoolTheme.surface, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                                        .stroke(SchoolTheme.line, lineWidth: 1)
                                }
                        }
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Что добавим")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            ForEach(parsedLessons) { lesson in
                                HStack(alignment: .top, spacing: 12) {
                                    IconBadge(systemName: lesson.isReplacement ? "arrow.triangle.2.circlepath" : "book.closed", color: lesson.isReplacement ? SchoolTheme.warning : SchoolTheme.accent, size: 40)
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 7) {
                                            Text("\(lesson.day), \(lesson.time)")
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(SchoolTheme.graphite)
                                            if lesson.isReplacement {
                                                StatusBadge(text: "Замена", color: SchoolTheme.warning)
                                            }
                                        }
                                        Text(lesson.title)
                                            .font(.subheadline)
                                            .foregroundStyle(SchoolTheme.graphite)
                                        Text(lesson.detailLine)
                                            .font(.caption)
                                            .foregroundStyle(SchoolTheme.muted)
                                    }
                                    Spacer()
                                }
                            }
                        }
                    }

                    Button {
                        onSave(parsedLessons)
                        dismiss()
                    } label: {
                        Label("Добавить в расписание", systemImage: "checkmark")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 52)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(SchoolTheme.success)
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Импорт")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
        }
    }
}

private struct TodaySheetHeader: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String

    var body: some View {
        DashboardCard {
            HStack(spacing: 14) {
                IconBadge(systemName: icon, color: color, size: 52)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(SchoolTheme.graphite)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(SchoolTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
        }
    }
}

private struct TodayTextField: View {
    let title: String
    let iconName: String
    let color: Color
    @Binding var text: String

    var body: some View {
        HStack(spacing: 12) {
            IconBadge(systemName: iconName, color: color, size: 38)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SchoolTheme.muted)
                TextField(title, text: $text, axis: .vertical)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite)
                    .lineLimit(1...3)
            }
        }
        .padding(12)
        .background(SchoolTheme.surface, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(SchoolTheme.line, lineWidth: 1)
        }
    }
}

private enum TodaySheet: Identifiable {
    case schedule
    case addLesson
    case importSchedule

    var id: String {
        switch self {
        case .schedule:
            "schedule"
        case .addLesson:
            "add-lesson"
        case .importSchedule:
            "import-schedule"
        }
    }
}

private extension ScheduleItem {
    var detailLine: String {
        var parts = [detail]

        if requiresForm {
            parts.append("нужна форма")
        }

        return parts.joined(separator: " - ")
    }
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

#Preview {
    TodayView()
}
