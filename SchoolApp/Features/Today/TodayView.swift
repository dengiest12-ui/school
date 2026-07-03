import SwiftUI
import UniformTypeIdentifiers
import UIKit

private struct TodayImportantMessage: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var detail: String
    var source: String
    var dueLabel: String
    var actionTitle: String
    var taskKind: ParentTask.Kind
    var isHandled: Bool

    init(
        id: UUID = UUID(),
        title: String,
        detail: String,
        source: String,
        dueLabel: String,
        actionTitle: String,
        taskKind: ParentTask.Kind,
        isHandled: Bool = false
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.source = source
        self.dueLabel = dueLabel
        self.actionTitle = actionTitle
        self.taskKind = taskKind
        self.isHandled = isHandled
    }
}

private struct GlobalParseDraft: Identifiable, Hashable {
    enum Kind: String, CaseIterable, Identifiable {
        case homework
        case familyTask
        case event
        case payment

        var id: String { rawValue }

        var title: String {
            switch self {
            case .homework:
                "ДЗ"
            case .familyTask:
                "Задача"
            case .event:
                "Событие"
            case .payment:
                "Оплата"
            }
        }

        var iconName: String {
            switch self {
            case .homework:
                "book.closed.fill"
            case .familyTask:
                "checklist.checked"
            case .event:
                "calendar.badge.clock"
            case .payment:
                "rublesign.circle.fill"
            }
        }

        var color: Color {
            switch self {
            case .homework:
                SchoolTheme.success
            case .familyTask:
                SchoolTheme.warning
            case .event:
                SchoolTheme.accent
            case .payment:
                SchoolTheme.teal
            }
        }
    }

    let id: UUID
    var kind: Kind
    var title: String
    var detail: String
    var dueLabel: String
    var assignee: String

    init(
        id: UUID = UUID(),
        kind: Kind,
        title: String,
        detail: String,
        dueLabel: String,
        assignee: String
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.detail = detail
        self.dueLabel = dueLabel
        self.assignee = assignee
    }
}

private struct TodayStoreSnapshot: Codable {
    var homework: [HomeworkItem]
    var parentTasks: [ParentTask]
    var importantMessages: [TodayImportantMessage]
    var schedule: [ScheduleItem]
    var personalCircles: [PersonalCircle]

    static let sample = TodayStoreSnapshot(
        homework: SampleData.homework,
        parentTasks: SampleData.parentTasks,
        importantMessages: [
            TodayImportantMessage(
                title: "Форма на физкультуру",
                detail: "Завтра нужна форма и сменная обувь для спортзала",
                source: "Классный руководитель",
                dueLabel: "Сегодня",
                actionTitle: "Создать задачу",
                taskKind: .bring
            ),
            TodayImportantMessage(
                title: "Согласие на экскурсию",
                detail: "Распечатанные согласия нужно передать учителю утром",
                source: "Родители 3Б",
                dueLabel: "Завтра",
                actionTitle: "Добавить в дела",
                taskKind: .sign
            ),
            TodayImportantMessage(
                title: "Картон и клей",
                detail: "Для проекта по окружающему миру нужны материалы",
                source: "AI-дайджест чата",
                dueLabel: "До пятницы",
                actionTitle: "Не забыть",
                taskKind: .buy
            )
        ],
        schedule: SampleData.schedule,
        personalCircles: SampleData.personalCircles
    )
}

private enum TodayLocalStore {
    private static let key = "todayStoreSnapshot.v1"

    static var snapshot: TodayStoreSnapshot {
        get {
            guard
                let data = UserDefaults.standard.data(forKey: key),
                let snapshot = try? JSONDecoder().decode(TodayStoreSnapshot.self, from: data)
            else {
                return .sample
            }

            return snapshot
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                return
            }

            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static var homework: [HomeworkItem] {
        get { snapshot.homework }
        set {
            var currentSnapshot = snapshot
            currentSnapshot.homework = newValue
            snapshot = currentSnapshot
        }
    }

    static var parentTasks: [ParentTask] {
        get { snapshot.parentTasks }
        set {
            var currentSnapshot = snapshot
            currentSnapshot.parentTasks = newValue
            snapshot = currentSnapshot
        }
    }

    static var importantMessages: [TodayImportantMessage] {
        get { snapshot.importantMessages }
        set {
            var currentSnapshot = snapshot
            currentSnapshot.importantMessages = newValue
            snapshot = currentSnapshot
        }
    }

    static var schedule: [ScheduleItem] {
        get { snapshot.schedule }
        set {
            var currentSnapshot = snapshot
            currentSnapshot.schedule = newValue
            snapshot = currentSnapshot
        }
    }

    static var personalCircles: [PersonalCircle] {
        get { snapshot.personalCircles }
        set {
            var currentSnapshot = snapshot
            currentSnapshot.personalCircles = newValue
            snapshot = currentSnapshot
        }
    }

    static func resetIfRequested() {
        guard ProcessInfo.processInfo.arguments.contains("-qa-reset-today-store") else {
            return
        }

        UserDefaults.standard.removeObject(forKey: key)
    }
}

struct TodayView: View {
    let userRole: AppUserRole

    @AppStorage("school.shared.selectedChildID") private var selectedChildID = ""
    @State private var children: [ChildSummary]
    @State private var homework: [HomeworkItem]
    @State private var parentTasks: [ParentTask]
    @State private var importantMessages: [TodayImportantMessage]
    @State private var schedule: [ScheduleItem]
    @State private var personalCircles: [PersonalCircle]
    @State private var selectedScheduleDay = "Чт"
    @State private var activeSheet: TodaySheet?

    init(userRole: AppUserRole = .parent) {
        self.userRole = userRole
        TodayLocalStore.resetIfRequested()
        _children = State(initialValue: AppChildStore.children)
        _homework = State(initialValue: TodayLocalStore.homework)
        _parentTasks = State(initialValue: TodayLocalStore.parentTasks)
        _importantMessages = State(initialValue: TodayLocalStore.importantMessages)
        _schedule = State(initialValue: TodayLocalStore.schedule)
        _personalCircles = State(initialValue: TodayLocalStore.personalCircles)
        _activeSheet = State(initialValue: TodayView.launchSheet())
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                header
                childCard
                tomorrowCard
                if userRole == .child {
                    childBackpackCard
                } else {
                    urgentCard
                }
                homeworkCard
                if userRole == .child {
                    childProgressCard
                } else {
                    parentActionsCard
                }
                scheduleCard
                if userRole != .child {
                    importantChatsCard
                    chatsCard
                }
                if userRole != .child {
                    quickActionsCard
                }
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
                    TodayLocalStore.schedule = schedule
                }
            case .importSchedule:
                ScheduleImportSheet { importedLessons in
                    schedule.append(contentsOf: importedLessons)
                    selectedScheduleDay = importedLessons.first?.day ?? selectedScheduleDay
                    TodayLocalStore.schedule = schedule
                }
            case .addHomework:
                AddTodayHomeworkSheet { item in
                    homework.insert(item, at: 0)
                    TodayLocalStore.homework = homework
                }
            case .addTask(let kind):
                AddParentTaskSheet(defaultKind: kind, defaultAssignee: selectedChild.name) { task in
                    parentTasks.insert(task, at: 0)
                    TodayLocalStore.parentTasks = parentTasks
                }
            case .importantMessages:
                ImportantMessagesSheet(
                    messages: $importantMessages,
                    onCreateTask: createTask(from:),
                    onSave: saveImportantMessages
                )
            case .globalParse:
                GlobalParseSheet(defaultAssignee: selectedChild.name) { drafts in
                    saveGlobalParse(drafts)
                }
            case .addChild:
                AddChildToClassSheet { child in
                    children.append(child)
                    AppChildStore.children = children
                    AppChildStore.select(child)
                    selectedChildID = child.id.uuidString
                }
            case .notifications:
                TodayNotificationsSheet(child: selectedChild)
            case .profile:
                TodayProfileSheet(child: selectedChild, children: children)
            case .homeworkList:
                TodayHomeworkListSheet(homework: $homework, selectedChild: selectedChild)
            case .urgentTasks:
                TodayUrgentTasksSheet(tasks: $parentTasks, selectedChild: selectedChild)
            case .chats:
                TodayChatsSheet()
            }
        }
        .onChange(of: schedule) { _, newValue in
            TodayLocalStore.schedule = newValue
        }
        .onChange(of: personalCircles) { _, newValue in
            TodayLocalStore.personalCircles = newValue
        }
        .onChange(of: homework) { _, newValue in
            TodayLocalStore.homework = newValue
        }
        .onChange(of: parentTasks) { _, newValue in
            TodayLocalStore.parentTasks = newValue
        }
        .onChange(of: importantMessages) { _, newValue in
            TodayLocalStore.importantMessages = newValue
        }
    }

    private func createTask(from message: TodayImportantMessage) {
        let task = ParentTask(
            title: message.detail,
            dueLabel: message.dueLabel,
            kind: message.taskKind,
            assignee: selectedChild.name
        )
        parentTasks.insert(task, at: 0)
        markImportantMessageHandled(message)
    }

    private func markImportantMessageHandled(_ message: TodayImportantMessage) {
        guard let index = importantMessages.firstIndex(where: { $0.id == message.id }) else {
            return
        }

        importantMessages[index].isHandled = true
    }

    private func saveImportantMessages() {
        TodayLocalStore.importantMessages = importantMessages
    }

    private func saveGlobalParse(_ drafts: [GlobalParseDraft]) {
        let validDrafts = drafts.filter { !$0.title.trimmed.isEmpty && !$0.detail.trimmed.isEmpty }
        let parsedHomework = validDrafts
            .filter { $0.kind == .homework }
            .map { draft in
                HomeworkItem(
                    subject: draft.title.trimmed,
                    title: draft.detail.trimmed,
                    dueLabel: draft.dueLabel.trimmed.isEmpty ? "завтра" : draft.dueLabel.trimmed,
                    source: "Разобрать",
                    status: .review,
                    bring: nil
                )
            }

        let parsedTasks = validDrafts
            .filter { $0.kind != .homework }
            .map { draft in
                ParentTask(
                    title: draft.parentTaskTitle,
                    dueLabel: draft.dueLabel.trimmed.isEmpty ? "Сегодня" : draft.dueLabel.trimmed,
                    kind: draft.parentTaskKind,
                    assignee: draft.assignee.trimmed.isEmpty ? selectedChild.name : draft.assignee.trimmed
                )
            }

        if !parsedHomework.isEmpty {
            homework.insert(contentsOf: parsedHomework, at: 0)
            TodayLocalStore.homework = homework
        }

        if !parsedTasks.isEmpty {
            parentTasks.insert(contentsOf: parsedTasks, at: 0)
            TodayLocalStore.parentTasks = parentTasks
        }
    }

    private func toggleHomework(_ item: HomeworkItem) {
        guard let index = homework.firstIndex(where: { $0.id == item.id }) else {
            return
        }

        homework[index].status = homework[index].status == .done ? .pending : .done
    }

    private func toggleParentTask(_ task: ParentTask) {
        guard let index = parentTasks.firstIndex(where: { $0.id == task.id }) else {
            return
        }

        parentTasks[index].isDone.toggle()
    }

    private func clearHandledImportantMessages() {
        importantMessages.removeAll { $0.isHandled }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            Text("Сегодня")
                .font(.system(size: 39, weight: .bold))
                .foregroundStyle(SchoolTheme.graphite)

            Spacer()

            HeaderIconButton(systemName: "bell", badgeColor: SchoolTheme.success) {
                activeSheet = .notifications
            }
                .accessibilityLabel("Уведомления")
            if userRole == .child {
                HeaderIconButton(systemName: "backpack.fill")
                    .accessibilityLabel("Режим ребенка")
            } else {
                HeaderIconButton(systemName: "person.crop.circle") {
                    activeSheet = .profile
                }
                .accessibilityLabel("Профиль")
            }
        }
        .padding(.top, 2)
    }

    private var childCard: some View {
        Menu {
            ForEach(children) { child in
                Button("\(child.name), \(child.className)") {
                    selectedChildID = child.id.uuidString
                    AppChildStore.select(child)
                }
            }
            Divider()
            Button("Добавить ребенка") {
                activeSheet = .addChild
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
                        Text("\(selectedChild.school) - \(selectedChild.parentRoleTitle.lowercased()), код \(selectedChild.classCode)")
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

                    if userRole == .child {
                        InfoPill(text: "План дня", color: SchoolTheme.success)
                    } else {
                        Button {
                            activeSheet = .schedule
                        } label: {
                            InfoPill(text: "План дня", color: SchoolTheme.success)
                        }
                        .buttonStyle(.plain)
                    }
                }

                VStack(spacing: 11) {
                    ForEach(Array(tomorrowLessons.enumerated()), id: \.element.id) { index, item in
                        scheduleRow(number: index + 1, item: item)
                    }

                    ForEach(tomorrowCircles) { circle in
                        circleSummaryRow(circle)
                    }
                }

                if userRole != .child {
                    Button {
                        activeSheet = .globalParse
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
    }

    private var urgentCard: some View {
        Button {
            activeSheet = .urgentTasks
        } label: {
            DashboardCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 14) {
                    IconBadge(systemName: "exclamationmark", color: SchoolTheme.danger)
                    Text("Срочно")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(SchoolTheme.danger)
                    Spacer()
                    Text("\(urgentTasks.count)")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .background(SchoolTheme.danger, in: Circle())
                    Image(systemName: "chevron.right")
                        .foregroundStyle(SchoolTheme.muted)
                }

                VStack(alignment: .leading, spacing: 14) {
                    if urgentTasks.isEmpty {
                        emptyTodayRow("Срочных дел нет", "checkmark.seal.fill", SchoolTheme.success)
                    } else {
                        ForEach(urgentTasks.prefix(2)) { task in
                                urgentTaskRow(task)
                        }
                    }
                }
            }
        }
        }
        .buttonStyle(.plain)
    }

    private var homeworkCard: some View {
        Button {
            activeSheet = .homeworkList
        } label: {
            DashboardCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 14) {
                    IconBadge(systemName: "book.closed", color: SchoolTheme.success)
                    Text("Домашка")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(SchoolTheme.success)
                    Spacer()
                    InfoPill(text: "\(openHomeworkCount) активно", color: SchoolTheme.success)
                    Image(systemName: "chevron.right")
                        .foregroundStyle(SchoolTheme.muted)
                }

                VStack(spacing: 13) {
                    ForEach(homework) { item in
                        homeworkRow(item: item)
                    }
                }
            }
        }
        }
        .buttonStyle(.plain)
    }

    private var childBackpackCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 14) {
                    IconBadge(systemName: "backpack.fill", color: SchoolTheme.warning)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Рюкзак завтра")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(SchoolTheme.graphite)
                        Text("Только учебные вещи, без оплат и родительских чатов")
                            .font(.caption)
                            .foregroundStyle(SchoolTheme.muted)
                    }
                    Spacer()
                    InfoPill(text: "\(childBackpackItems.count)", color: SchoolTheme.warning)
                }

                VStack(spacing: 12) {
                    if childBackpackItems.isEmpty {
                        emptyTodayRow("Особых вещей не нужно", "checkmark.seal.fill", SchoolTheme.success)
                    } else {
                        ForEach(Array(childBackpackItems.enumerated()), id: \.offset) { _, item in
                            childBackpackRow(item)
                        }
                    }
                }
            }
        }
    }

    private var childProgressCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 14) {
                    IconBadge(systemName: "checkmark.seal.fill", color: SchoolTheme.success)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Мой прогресс")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(SchoolTheme.success)
                        Text("Отмечай готовую домашку")
                            .font(.caption)
                            .foregroundStyle(SchoolTheme.muted)
                    }
                    Spacer()
                    InfoPill(text: "\(doneHomeworkCount)/\(homework.count)", color: SchoolTheme.success)
                }

                HStack(spacing: 10) {
                    childProgressMetric(title: "активно", value: "\(openHomeworkCount)", color: SchoolTheme.warning)
                    childProgressMetric(title: "готово", value: "\(doneHomeworkCount)", color: SchoolTheme.success)
                    childProgressMetric(title: "урока", value: "\(tomorrowLessons.count)", color: SchoolTheme.accent)
                }
            }
        }
    }

    private var parentActionsCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 14) {
                    IconBadge(systemName: "checklist.checked", color: SchoolTheme.warning)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Принести / оплатить / подписать")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(SchoolTheme.graphite)
                        Text("Отдельно от задач ребенка")
                            .font(.caption)
                            .foregroundStyle(SchoolTheme.muted)
                    }
                    Spacer()
                    Button {
                        activeSheet = .addTask(.bring)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(SchoolTheme.warning)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Добавить семейную задачу")
                }

                VStack(spacing: 12) {
                    if parentTasks.isEmpty {
                        emptyTodayRow("Семейных дел пока нет", "tray.fill", SchoolTheme.muted)
                    } else {
                        ForEach(parentTasks.prefix(4)) { task in
                            Button {
                                toggleParentTask(task)
                            } label: {
                                parentTaskRow(task)
                            }
                            .buttonStyle(.plain)
                        }
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
                    if userRole == .child {
                        InfoPill(text: "\(selectedLessons.count) урока", color: SchoolTheme.accent)
                    } else {
                        Button {
                            activeSheet = .schedule
                        } label: {
                            InfoPill(text: "\(selectedLessons.count) урока", color: SchoolTheme.accent)
                        }
                        .buttonStyle(.plain)
                    }
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

    private var importantChatsCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 14) {
                    IconBadge(systemName: "sparkles", color: SchoolTheme.teal)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Важное из чата")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(SchoolTheme.teal)
                        Text("Без чтения всего потока")
                            .font(.caption)
                            .foregroundStyle(SchoolTheme.muted)
                    }
                    Spacer()
                    InfoPill(text: "\(activeImportantMessages.count)", color: SchoolTheme.teal)
                }

                VStack(spacing: 12) {
                    if activeImportantMessages.isEmpty {
                        emptyTodayRow("Все важное разобрано", "checkmark.bubble.fill", SchoolTheme.success)
                    } else {
                        ForEach(activeImportantMessages.prefix(3)) { message in
                            importantMessageRow(message)
                        }
                    }
                }

                if importantMessages.contains(where: \.isHandled) {
                    Button {
                        clearHandledImportantMessages()
                    } label: {
                        Label("Очистить обработанное", systemImage: "archivebox.fill")
                            .font(.caption.weight(.semibold))
                            .frame(maxWidth: .infinity, minHeight: 38)
                    }
                    .buttonStyle(.bordered)
                    .tint(SchoolTheme.teal)
                }
            }
        }
    }

    private var chatsCard: some View {
        Button {
            activeSheet = .chats
        } label: {
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
        .buttonStyle(.plain)
    }

    private var quickActionsCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Быстрые действия")
                    .font(.headline)
                    .foregroundStyle(SchoolTheme.graphite)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    quickAction("Разобрать", "sparkles", SchoolTheme.accent) {
                        activeSheet = .globalParse
                    }
                    quickAction("Добавить ДЗ", "plus.circle", SchoolTheme.success) {
                        activeSheet = .addHomework
                    }
                    quickAction("Кружок", "figure.run", SchoolTheme.teal) {
                        activeSheet = .schedule
                    }
                    quickAction("Расписание", "clock.badge.checkmark", SchoolTheme.accent) {
                        activeSheet = .schedule
                    }

                    if userRole != .child {
                        quickAction("Событие", "calendar.badge.plus", SchoolTheme.accent) {
                            activeSheet = .addTask(.sign)
                        }
                        quickAction("Сбор", "rublesign.circle", SchoolTheme.warning) {
                            activeSheet = .addTask(.pay)
                        }
                        quickAction("Открыть чат", "bubble.left", SchoolTheme.teal) {
                            activeSheet = .importantMessages
                        }
                    }
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

    private var urgentTasks: [ParentTask] {
        parentTasks.filter { !$0.isDone }
    }

    private var openHomeworkCount: Int {
        homework.filter { $0.status != .done }.count
    }

    private var doneHomeworkCount: Int {
        homework.filter { $0.status == .done }.count
    }

    private var activeImportantMessages: [TodayImportantMessage] {
        importantMessages.filter { !$0.isHandled }
    }

    private var selectedLessons: [ScheduleItem] {
        lessons(for: selectedScheduleDay)
    }

    private var selectedCircles: [PersonalCircle] {
        circles(for: selectedScheduleDay)
    }

    private var childBackpackItems: [String] {
        var items = homework.compactMap { $0.bring?.trimmed }.filter { !$0.isEmpty }

        if tomorrowLessons.contains(where: \.requiresForm) {
            items.append("Форма и сменная обувь для физкультуры")
        }

        items.append(contentsOf: tomorrowCircles.map { "\($0.title): \($0.place)" })
        return Array(items.prefix(5))
    }

    private var selectedChild: ChildSummary {
        AppChildStore.selectedChild(in: children) ?? children.first ?? SampleData.children[0]
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

    private func urgentTaskRow(_ task: ParentTask) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Circle()
                .fill(task.kind.color)
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

    private func homeworkRow(item: HomeworkItem) -> some View {
        let isDone = item.status == .done

        return HStack(alignment: .firstTextBaseline, spacing: 12) {
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

    private func childBackpackRow(_ title: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundStyle(SchoolTheme.success)
                .frame(width: 26)

            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(SchoolTheme.graphite)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 8)
        }
        .padding(12)
        .background(SchoolTheme.surface, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(SchoolTheme.line, lineWidth: 1)
        }
    }

    private func childProgressMetric(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(color)
                .monospacedDigit()
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, minHeight: 66)
        .background(SchoolTheme.surface, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(SchoolTheme.line, lineWidth: 1)
        }
    }

    private func parentTaskRow(_ task: ParentTask) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                .font(.title3)
                .foregroundStyle(task.isDone ? SchoolTheme.success : SchoolTheme.muted.opacity(0.55))
                .frame(width: 26)

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 7) {
                    StatusBadge(text: task.kind.title, color: task.kind.color)
                    Text(task.dueLabel)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(SchoolTheme.muted)
                }

                Text(task.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(task.isDone ? SchoolTheme.muted : SchoolTheme.graphite)
                    .strikethrough(task.isDone, color: SchoolTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Исполнитель: \(task.assignee)")
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
            }

            Spacer(minLength: 8)
        }
        .contentShape(Rectangle())
    }

    private func importantMessageRow(_ message: TodayImportantMessage) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                IconBadge(systemName: "sparkles", color: message.taskKind.color, size: 38)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 7) {
                        Text(message.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(SchoolTheme.graphite)
                        StatusBadge(text: message.source, color: SchoolTheme.teal)
                    }

                    Text(message.detail)
                        .font(.caption)
                        .foregroundStyle(SchoolTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)
            }

            HStack(spacing: 10) {
                Button {
                    createTask(from: message)
                } label: {
                    Label(message.actionTitle, systemImage: "plus.circle.fill")
                        .font(.caption.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: 36)
                }
                .buttonStyle(.borderedProminent)
                .tint(message.taskKind.color)

                Button {
                    markImportantMessageHandled(message)
                } label: {
                    Label("Готово", systemImage: "checkmark")
                        .font(.caption.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: 36)
                }
                .buttonStyle(.bordered)
                .tint(SchoolTheme.teal)
            }
        }
        .padding(12)
        .background(SchoolTheme.surface, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(SchoolTheme.line, lineWidth: 1)
        }
    }

    private func emptyTodayRow(_ title: String, _ icon: String, _ color: Color) -> some View {
        HStack(spacing: 12) {
            IconBadge(systemName: icon, color: color, size: 38)
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(SchoolTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
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

        if arguments.contains("-qa-today-add-homework") {
            return .addHomework
        }

        if arguments.contains("-qa-today-add-task") {
            return .addTask(.bring)
        }

        if arguments.contains("-qa-today-add-payment") {
            return .addTask(.pay)
        }

        if arguments.contains("-qa-today-important") {
            return .importantMessages
        }

        if arguments.contains("-qa-today-global-parse") || arguments.contains("-qa-global-parse-photo-dialog") || arguments.contains("-qa-global-parse-file-importer") {
            return .globalParse
        }

        if arguments.contains("-qa-today-add-child") {
            return .addChild
        }

        if arguments.contains("-qa-today-notifications") {
            return .notifications
        }

        if arguments.contains("-qa-today-profile") {
            return .profile
        }

        if arguments.contains("-qa-today-homework-list") {
            return .homeworkList
        }

        if arguments.contains("-qa-today-urgent") {
            return .urgentTasks
        }

        if arguments.contains("-qa-today-chats") {
            return .chats
        }

        return nil
    }
}

private struct AddChildToClassSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: (ChildSummary) -> Void

    @State private var childName = "Соня"
    @State private var className = "2В"
    @State private var school = "Школа 1254"
    @State private var classCode = "2V-1254"
    @State private var parentRoleTitle = "Родитель"

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    TodaySheetHeader(
                        icon: "person.crop.square.badge.plus",
                        color: SchoolTheme.success,
                        title: "Добавить ребенка",
                        subtitle: "Для каждого ребенка можно указать свой класс и код приглашения"
                    )

                    DashboardCard {
                        VStack(spacing: 12) {
                            TodayTextField(title: "Имя ребенка", iconName: "person.fill", color: SchoolTheme.success, text: $childName)
                            TodayTextField(title: "Класс", iconName: "person.3.fill", color: SchoolTheme.accent, text: $className)
                            TodayTextField(title: "Код класса", iconName: "link", color: SchoolTheme.warning, text: $classCode)
                            TodayTextField(title: "Школа", iconName: "building.columns.fill", color: SchoolTheme.teal, text: $school)
                            roleMenu
                        }
                    }

                    Button {
                        save()
                    } label: {
                        Label("Добавить и выбрать", systemImage: "checkmark")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 52)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(SchoolTheme.success)
                    .disabled(!canSave)
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Новый ребенок")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
                KeyboardDoneToolbar()
            }
        }
    }

    private var roleMenu: some View {
        Menu {
            ForEach(["Родитель", "Родкомитет"], id: \.self) { role in
                Button(role) {
                    parentRoleTitle = role
                }
            }
        } label: {
            HStack(spacing: 12) {
                IconBadge(systemName: "person.badge.shield.checkmark.fill", color: SchoolTheme.accent, size: 40)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Ваша роль в классе")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(SchoolTheme.muted)
                    Text(parentRoleTitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SchoolTheme.graphite)
                }
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundStyle(SchoolTheme.muted)
            }
            .padding(12)
            .background(SchoolTheme.page, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(SchoolTheme.line, lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }

    private var canSave: Bool {
        !childName.trimmed.isEmpty && !className.trimmed.isEmpty && !classCode.trimmed.isEmpty
    }

    private func save() {
        let avatar = String(childName.trimmed.prefix(1)).uppercased()
        onSave(
            ChildSummary(
                name: childName.trimmed,
                className: className.trimmed,
                school: school.trimmed,
                avatarText: avatar.isEmpty ? "Р" : avatar,
                classCode: classCode.trimmed.uppercased(),
                parentRoleTitle: parentRoleTitle
            )
        )
        dismiss()
    }
}

private struct TodayNotificationsSheet: View {
    @Environment(\.dismiss) private var dismiss
    let child: ChildSummary

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    TodaySheetHeader(icon: "bell.badge.fill", color: SchoolTheme.warning, title: "Уведомления", subtitle: "Что важно по \(child.name) и классу \(child.className)")
                    DashboardCard {
                        VStack(spacing: 12) {
                            notificationRow("ДЗ на завтра", "Сегодня в 20:30", "book.closed.fill", SchoolTheme.success)
                            notificationRow("Срочные задачи", "Сразу после важных объявлений", "exclamationmark.circle.fill", SchoolTheme.danger)
                            notificationRow("Сборы и дедлайны", "За день до срока", "rublesign.circle.fill", SchoolTheme.warning)
                        }
                    }
                }
                .padding(20)
            }
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Уведомления")
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

    private func notificationRow(_ title: String, _ detail: String, _ icon: String, _ color: Color) -> some View {
        HStack(spacing: 12) {
            IconBadge(systemName: icon, color: color, size: 40)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
            }
            Spacer()
            StatusBadge(text: "Вкл", color: SchoolTheme.success)
        }
    }
}

private struct TodayProfileSheet: View {
    @Environment(\.dismiss) private var dismiss
    let child: ChildSummary
    let children: [ChildSummary]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    TodaySheetHeader(icon: "person.crop.circle.fill", color: SchoolTheme.accent, title: "Профиль", subtitle: "Текущий ребенок, класс и роль")
                    DashboardCard {
                        HStack(spacing: 14) {
                            InitialAvatar(text: child.avatarText, color: SchoolTheme.success, size: 56)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(child.name), \(child.className)")
                                    .font(.headline)
                                    .foregroundStyle(SchoolTheme.graphite)
                                Text("\(child.school) - код \(child.classCode)")
                                    .font(.caption)
                                    .foregroundStyle(SchoolTheme.muted)
                            }
                            Spacer()
                            StatusBadge(text: child.parentRoleTitle, color: child.parentRoleTitle == "Родкомитет" ? SchoolTheme.warning : SchoolTheme.success)
                        }
                    }
                    DashboardCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Все профили")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)
                            ForEach(children) { item in
                                HStack(spacing: 10) {
                                    InitialAvatar(text: item.avatarText, color: item.id == child.id ? SchoolTheme.success : SchoolTheme.accent, size: 36)
                                    Text("\(item.name) - \(item.className), \(item.parentRoleTitle.lowercased())")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(SchoolTheme.graphite)
                                    Spacer()
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Профиль")
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

private struct TodayHomeworkListSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var homework: [HomeworkItem]
    let selectedChild: ChildSummary

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    TodaySheetHeader(icon: "book.closed.fill", color: SchoolTheme.success, title: "Домашка", subtitle: "\(selectedChild.name), \(selectedChild.className)")
                    DashboardCard {
                        VStack(spacing: 12) {
                            ForEach(homework) { item in
                                Button {
                                    toggle(item)
                                } label: {
                                    HStack(alignment: .top, spacing: 12) {
                                        Image(systemName: item.status == .done ? "checkmark.circle.fill" : "circle")
                                            .font(.title3)
                                            .foregroundStyle(item.status == .done ? SchoolTheme.success : SchoolTheme.muted.opacity(0.55))
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.subject)
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(SchoolTheme.graphite)
                                            Text(item.title)
                                                .font(.caption)
                                                .foregroundStyle(SchoolTheme.muted)
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                        Spacer()
                                        StatusBadge(text: item.dueLabel, color: SchoolTheme.warning)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Домашка")
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

    private func toggle(_ item: HomeworkItem) {
        guard let index = homework.firstIndex(where: { $0.id == item.id }) else {
            return
        }

        homework[index].status = homework[index].status == .done ? .pending : .done
    }
}

private struct TodayUrgentTasksSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var tasks: [ParentTask]
    let selectedChild: ChildSummary

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    TodaySheetHeader(icon: "exclamationmark.circle.fill", color: SchoolTheme.danger, title: "Срочно", subtitle: "Дела родителя по \(selectedChild.name)")
                    DashboardCard {
                        VStack(spacing: 12) {
                            ForEach(tasks) { task in
                                Button {
                                    toggle(task)
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                                            .font(.title3)
                                            .foregroundStyle(task.isDone ? SchoolTheme.success : SchoolTheme.muted.opacity(0.55))
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(task.title)
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(SchoolTheme.graphite)
                                            Text("\(task.kind.title) - \(task.dueLabel)")
                                                .font(.caption)
                                                .foregroundStyle(SchoolTheme.muted)
                                        }
                                        Spacer()
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Срочно")
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

    private func toggle(_ task: ParentTask) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else {
            return
        }

        tasks[index].isDone.toggle()
    }
}

private struct TodayChatsSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    TodaySheetHeader(icon: "bubble.left.and.bubble.right.fill", color: SchoolTheme.accent, title: "Чаты", subtitle: "Класс, родкомитет и объявления")
                    DashboardCard {
                        VStack(spacing: 14) {
                            ForEach(SampleData.chats) { chat in
                                HStack(spacing: 12) {
                                    IconBadge(systemName: chat.icon, color: color(for: chat.colorName), size: 42)
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(chat.title)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(SchoolTheme.graphite)
                                        Text(chat.message)
                                            .font(.caption)
                                            .foregroundStyle(SchoolTheme.muted)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    Spacer()
                                    if chat.hasUnread {
                                        Circle()
                                            .fill(SchoolTheme.accent)
                                            .frame(width: 9, height: 9)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Чаты")
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
}

private enum GlobalParseSource: String, CaseIterable, Identifiable {
    case photo
    case screenshot
    case file
    case voice
    case text

    var id: String { rawValue }

    var title: String {
        switch self {
        case .photo:
            "Фото"
        case .screenshot:
            "Скрин"
        case .file:
            "Файл"
        case .voice:
            "Голос"
        case .text:
            "Текст"
        }
    }

    var iconName: String {
        switch self {
        case .photo:
            "camera.fill"
        case .screenshot:
            "doc.viewfinder"
        case .file:
            "doc.fill"
        case .voice:
            "mic.fill"
        case .text:
            "text.alignleft"
        }
    }

    var color: Color {
        switch self {
        case .photo, .text:
            SchoolTheme.success
        case .screenshot:
            SchoolTheme.warning
        case .file:
            SchoolTheme.accent
        case .voice:
            SchoolTheme.teal
        }
    }

    var sampleText: String {
        switch self {
        case .voice:
            "математика страница 45 номера 6 7 8; завтра принести картон и клей; до пятницы подписать согласие на экскурсию"
        case .file:
            "русский упр 123 правило; сбор на театр 700 рублей до пятницы; музей 12 сентября в 10:00"
        case .text:
            "английский слова к четвергу; купить цветную бумагу; оплатить театр 700 рублей"
        default:
            "мат стр 45 N 6,7,8; завтра принести картон и клей; театр 12 сентября; подписать согласие до пятницы"
        }
    }
}

private struct GlobalParseSheet: View {
    @Environment(\.dismiss) private var dismiss

    let defaultAssignee: String
    let onSave: ([GlobalParseDraft]) -> Void

    @State private var source: GlobalParseSource = .photo
    @State private var recognizedText: String
    @State private var drafts: [GlobalParseDraft]
    @State private var attachmentStatus: String?
    @State private var isImageSourceDialogVisible = false
    @State private var isImagePickerVisible = false
    @State private var isFileImporterVisible = false
    @State private var imagePickerSource: UIImagePickerController.SourceType = .photoLibrary

    init(defaultAssignee: String, onSave: @escaping ([GlobalParseDraft]) -> Void) {
        self.defaultAssignee = defaultAssignee
        self.onSave = onSave
        let sample = GlobalParseSource.photo.sampleText
        _recognizedText = State(initialValue: sample)
        _drafts = State(initialValue: GlobalParseParser.parse(sample, assignee: defaultAssignee))
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    TodaySheetHeader(
                        icon: "sparkles",
                        color: SchoolTheme.accent,
                        title: "Разобрать",
                        subtitle: "Фото, скрин, файл, голос или текст в понятные дела"
                    )

                    sourcePickerCard
                    sourceInputCard
                    recognizedTextCard
                    resultCard
                    saveButton
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Разобрать")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
                KeyboardDoneToolbar()
            }
            .confirmationDialog("Добавить исходник", isPresented: $isImageSourceDialogVisible, titleVisibility: .visible) {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    Button("Сделать фото") {
                        showImagePicker(.camera)
                    }
                }

                Button("Выбрать из галереи") {
                    showImagePicker(.photoLibrary)
                }

                Button("Отмена", role: .cancel) {}
            } message: {
                Text("Фото, скрин или изображение будет привязано к разбору.")
            }
            .sheet(isPresented: $isImagePickerVisible) {
                TodayImagePicker(sourceType: imagePickerSource) { displayName in
                    attachmentStatus = "Фото прикреплено: \(displayName)"
                }
            }
            .fileImporter(
                isPresented: $isFileImporterVisible,
                allowedContentTypes: [.pdf, .image, .plainText, .item],
                allowsMultipleSelection: false
            ) { result in
                handleFileImport(result)
            }
            .onAppear {
                runQAImporterChecks()
            }
        }
    }

    private var sourcePickerCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Источник")
                    .font(.headline)
                    .foregroundStyle(SchoolTheme.graphite)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(GlobalParseSource.allCases) { option in
                        Button {
                            selectSource(option)
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: option.iconName)
                                    .font(.subheadline.weight(.bold))
                                Text(option.title)
                                    .font(.caption.weight(.semibold))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.82)
                            }
                            .foregroundStyle(source == option ? .white : option.color)
                            .frame(maxWidth: .infinity, minHeight: 42)
                            .background(source == option ? option.color : option.color.opacity(0.10), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var sourceInputCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    IconBadge(systemName: source.iconName, color: source.color, size: 42)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Исходник")
                            .font(.headline)
                            .foregroundStyle(SchoolTheme.graphite)
                        Text(attachmentStatus ?? "Можно приложить фото, скрин или документ")
                            .font(.caption)
                            .foregroundStyle(attachmentStatus == nil ? SchoolTheme.muted : SchoolTheme.success)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                }

                HStack(spacing: 10) {
                    Button {
                        handlePrimarySourceAction()
                    } label: {
                        Label(primaryActionTitle, systemImage: primaryActionIcon)
                            .font(.caption.weight(.semibold))
                            .frame(maxWidth: .infinity, minHeight: 42)
                    }
                    .buttonStyle(.bordered)
                    .tint(source.color)

                    Button {
                        isFileImporterVisible = true
                    } label: {
                        Label("Файл", systemImage: "paperclip")
                            .font(.caption.weight(.semibold))
                            .frame(maxWidth: .infinity, minHeight: 42)
                    }
                    .buttonStyle(.bordered)
                    .tint(SchoolTheme.accent)
                    .disabled(source == .text)
                }
            }
        }
    }

    private var primaryActionTitle: String {
        switch source {
        case .voice:
            "Голос"
        case .file:
            "Выбрать"
        case .text:
            "Вставить"
        case .screenshot:
            "Скрин"
        case .photo:
            "Фото"
        }
    }

    private var primaryActionIcon: String {
        switch source {
        case .voice:
            "mic.fill"
        case .file:
            "doc.fill"
        case .text:
            "text.cursor"
        case .screenshot:
            "doc.viewfinder"
        case .photo:
            "camera.fill"
        }
    }

    private var recognizedTextCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Распознанный текст")
                    .font(.headline)
                    .foregroundStyle(SchoolTheme.graphite)

                TextEditor(text: $recognizedText)
                    .font(.subheadline)
                    .foregroundStyle(SchoolTheme.graphite)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 128)
                    .padding(10)
                    .background(SchoolTheme.page, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .stroke(SchoolTheme.line, lineWidth: 1)
                    }

                Button {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) {
                        drafts = GlobalParseParser.parse(recognizedText, assignee: defaultAssignee)
                    }
                } label: {
                    Label("Разобрать заново", systemImage: "sparkles")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: 42)
                }
                .buttonStyle(.bordered)
                .tint(SchoolTheme.accent)
            }
        }
    }

    private var resultCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Что добавим")
                        .font(.headline)
                        .foregroundStyle(SchoolTheme.graphite)
                    Spacer()
                    InfoPill(text: "\(drafts.count)", color: SchoolTheme.accent)
                }

                if drafts.isEmpty {
                    HStack(spacing: 12) {
                        IconBadge(systemName: "text.magnifyingglass", color: SchoolTheme.muted, size: 40)
                        Text("Пока нечего добавить")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(SchoolTheme.muted)
                        Spacer()
                    }
                } else {
                    ForEach($drafts) { $draft in
                        GlobalParseDraftRow(draft: $draft)
                    }
                }
            }
        }
    }

    private var saveButton: some View {
        Button {
            let validDrafts = drafts.filter { !$0.title.trimmed.isEmpty && !$0.detail.trimmed.isEmpty }
            onSave(validDrafts)
            dismiss()
        } label: {
            Label("Сохранить результат", systemImage: "checkmark")
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: 52)
        }
        .buttonStyle(.borderedProminent)
        .tint(SchoolTheme.success)
        .disabled(drafts.allSatisfy { $0.title.trimmed.isEmpty || $0.detail.trimmed.isEmpty })
    }

    private func selectSource(_ option: GlobalParseSource) {
        source = option
        recognizedText = option.sampleText
        attachmentStatus = nil
        drafts = GlobalParseParser.parse(option.sampleText, assignee: defaultAssignee)
    }

    private func handlePrimarySourceAction() {
        switch source {
        case .voice:
            attachmentStatus = "Голосовая заметка готова: 00:24"
            recognizedText = GlobalParseSource.voice.sampleText
            drafts = GlobalParseParser.parse(recognizedText, assignee: defaultAssignee)
        case .file:
            isFileImporterVisible = true
        case .text:
            attachmentStatus = "Текст можно вставить и поправить ниже"
        case .photo, .screenshot:
            isImageSourceDialogVisible = true
        }
    }

    private func showImagePicker(_ sourceType: UIImagePickerController.SourceType) {
        imagePickerSource = sourceType
        isImagePickerVisible = true
    }

    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else {
                attachmentStatus = "Файл не выбран"
                return
            }

            let didAccess = url.startAccessingSecurityScopedResource()
            defer {
                if didAccess {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            let fileName = url.lastPathComponent.isEmpty ? "документ" : url.lastPathComponent
            attachmentStatus = "Файл прикреплен: \(fileName)"
        case .failure:
            attachmentStatus = "Не удалось прикрепить файл"
        }
    }

    private func runQAImporterChecks() {
        let arguments = ProcessInfo.processInfo.arguments

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            if arguments.contains("-qa-global-parse-photo-dialog") {
                isImageSourceDialogVisible = true
            }

            if arguments.contains("-qa-global-parse-file-importer") {
                isFileImporterVisible = true
            }
        }
    }
}

private struct GlobalParseDraftRow: View {
    @Binding var draft: GlobalParseDraft

    var body: some View {
        VStack(spacing: 10) {
            kindMenu
            TodayTextField(title: titleFieldTitle, iconName: "text.badge.plus", color: draft.kind.color, text: $draft.title)
            TodayTextField(title: detailFieldTitle, iconName: "text.alignleft", color: SchoolTheme.accent, text: $draft.detail)
            TodayTextField(title: "Срок", iconName: "calendar", color: SchoolTheme.warning, text: $draft.dueLabel)

            if draft.kind != .homework {
                TodayTextField(title: "Исполнитель", iconName: "person.fill", color: SchoolTheme.teal, text: $draft.assignee)
            }
        }
        .padding(12)
        .background(SchoolTheme.page, in: RoundedRectangle(cornerRadius: 17, style: .continuous))
    }

    private var titleFieldTitle: String {
        draft.kind == .homework ? "Предмет" : "Название"
    }

    private var detailFieldTitle: String {
        draft.kind == .homework ? "Задание" : "Что сделать"
    }

    private var kindMenu: some View {
        Menu {
            ForEach(GlobalParseDraft.Kind.allCases) { kind in
                Button(kind.title) {
                    draft.kind = kind
                }
            }
        } label: {
            HStack(spacing: 12) {
                IconBadge(systemName: draft.kind.iconName, color: draft.kind.color, size: 38)
                Text(draft.kind.title)
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

private enum GlobalParseParser {
    static func parse(_ text: String, assignee: String) -> [GlobalParseDraft] {
        let fragments = text
            .replacingOccurrences(of: "\n", with: ";")
            .split(separator: ";")
            .map { String($0).trimmed }
            .filter { !$0.isEmpty }

        var drafts = fragments.map { parseFragment($0, assignee: assignee) }

        if drafts.isEmpty && !text.trimmed.isEmpty {
            drafts = [
                GlobalParseDraft(
                    kind: .familyTask,
                    title: "Задача",
                    detail: text.trimmed,
                    dueLabel: "Сегодня",
                    assignee: assignee
                )
            ]
        }

        return drafts
    }

    private static func parseFragment(_ fragment: String, assignee: String) -> GlobalParseDraft {
        let normalized = fragment.lowercased()
        let dueLabel = dueLabel(for: normalized)

        if isPayment(normalized) {
            return GlobalParseDraft(
                kind: .payment,
                title: paymentTitle(for: normalized),
                detail: cleanTaskText(fragment),
                dueLabel: dueLabel,
                assignee: assignee
            )
        }

        if isEvent(normalized) {
            return GlobalParseDraft(
                kind: .event,
                title: eventTitle(for: fragment),
                detail: cleanTaskText(fragment),
                dueLabel: dueLabel,
                assignee: assignee
            )
        }

        if isFamilyTask(normalized) {
            return GlobalParseDraft(
                kind: .familyTask,
                title: familyTaskTitle(for: normalized),
                detail: cleanTaskText(fragment),
                dueLabel: dueLabel,
                assignee: assignee
            )
        }

        return GlobalParseDraft(
            kind: .homework,
            title: subjectName(for: normalized),
            detail: homeworkTitle(fragment, normalized: normalized),
            dueLabel: dueLabel == "Сегодня" ? "завтра" : dueLabel,
            assignee: assignee
        )
    }

    private static func isPayment(_ normalized: String) -> Bool {
        normalized.contains("оплат") || normalized.contains("сбор") || normalized.contains("руб")
    }

    private static func isEvent(_ normalized: String) -> Bool {
        normalized.contains("экскур") || normalized.contains("театр") || normalized.contains("музей") || normalized.contains("собрание")
    }

    private static func isFamilyTask(_ normalized: String) -> Bool {
        normalized.contains("принести") || normalized.contains("купить") || normalized.contains("подпис") || normalized.contains("согласие") || normalized.contains("форма")
    }

    private static func subjectName(for normalized: String) -> String {
        if normalized.hasPrefix("мат") || normalized.contains("матем") {
            return "Математика"
        }

        if normalized.hasPrefix("рус") || normalized.contains("русский") {
            return "Русский язык"
        }

        if normalized.hasPrefix("окр") || normalized.contains("окружа") {
            return "Окружающий мир"
        }

        if normalized.contains("англ") {
            return "Английский язык"
        }

        if normalized.contains("литер") {
            return "Литература"
        }

        return "Без предмета"
    }

    private static func homeworkTitle(_ fragment: String, normalized: String) -> String {
        let prefixes = [
            "математика",
            "мат",
            "русский язык",
            "русский",
            "рус",
            "окружающий мир",
            "окр мир",
            "окр",
            "английский",
            "англ",
            "литература"
        ]

        var result = fragment.trimmed
        for prefix in prefixes where normalized.hasPrefix(prefix) {
            result = String(result.dropFirst(prefix.count)).trimmed
            break
        }

        return result
            .replacingOccurrences(of: "стр", with: "страница")
            .replacingOccurrences(of: "упр", with: "упражнение")
            .replacingOccurrences(of: "N", with: "номер")
            .replacingOccurrences(of: "№", with: "номер")
            .trimmed
    }

    private static func dueLabel(for normalized: String) -> String {
        if normalized.contains("пятниц") {
            return "до пятницы"
        }

        if normalized.contains("четвер") {
            return "к четвергу"
        }

        if normalized.contains("завтра") {
            return "завтра"
        }

        if normalized.contains("сегодня") {
            return "Сегодня"
        }

        if normalized.contains("12 сентября") {
            return "12 сентября"
        }

        return "Сегодня"
    }

    private static func paymentTitle(for normalized: String) -> String {
        if normalized.contains("театр") {
            return "Театр"
        }

        if normalized.contains("экскур") {
            return "Экскурсия"
        }

        return "Сбор класса"
    }

    private static func eventTitle(for fragment: String) -> String {
        let normalized = fragment.lowercased()

        if normalized.contains("театр") {
            return "Театр"
        }

        if normalized.contains("музей") {
            return "Музей"
        }

        if normalized.contains("экскур") {
            return "Экскурсия"
        }

        return "Событие"
    }

    private static func familyTaskTitle(for normalized: String) -> String {
        if normalized.contains("купить") {
            return "Купить"
        }

        if normalized.contains("подпис") || normalized.contains("согласие") {
            return "Подписать"
        }

        return "Принести"
    }

    private static func cleanTaskText(_ fragment: String) -> String {
        fragment
            .replacingOccurrences(of: "завтра", with: "", options: .caseInsensitive)
            .replacingOccurrences(of: "сегодня", with: "", options: .caseInsensitive)
            .trimmed
    }
}

private extension GlobalParseDraft {
    var parentTaskTitle: String {
        switch kind {
        case .homework:
            detail.trimmed
        case .familyTask:
            detail.trimmed
        case .event:
            "\(title.trimmed): \(detail.trimmed)"
        case .payment:
            "Оплатить \(title.trimmed.lowercased()): \(detail.trimmed)"
        }
    }

    var parentTaskKind: ParentTask.Kind {
        switch kind {
        case .homework:
            return .bring
        case .familyTask:
            if title.lowercased().contains("подпис") {
                return .sign
            }

            if title.lowercased().contains("куп") {
                return .buy
            }

            return .bring
        case .event:
            return .sign
        case .payment:
            return .pay
        }
    }
}

private struct TodayImagePicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss

    let sourceType: UIImagePickerController.SourceType
    let onPick: (String) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = UIImagePickerController.isSourceTypeAvailable(sourceType) ? sourceType : .photoLibrary
        picker.mediaTypes = [UTType.image.identifier]
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: TodayImagePicker

        init(parent: TodayImagePicker) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            let pickedURL = info[.imageURL] as? URL
            let defaultName = parent.sourceType == .camera ? "снимок \(Date().todayAttachmentTimestamp)" : "изображение"
            parent.onPick(pickedURL?.lastPathComponent ?? defaultName)
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
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
            .scrollDismissesKeyboard(.interactively)
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
                KeyboardDoneToolbar()
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
            .scrollDismissesKeyboard(.interactively)
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Импорт")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
                KeyboardDoneToolbar()
            }
        }
    }
}

private struct AddTodayHomeworkSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: (HomeworkItem) -> Void

    @State private var subject = "Математика"
    @State private var title = "№ 50, 51 (с. 80)"
    @State private var dueLabel = "завтра"
    @State private var source = "Родитель"
    @State private var bring = ""

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    TodaySheetHeader(
                        icon: "book.closed.fill",
                        color: SchoolTheme.success,
                        title: "Добавить ДЗ",
                        subtitle: "Быстрое задание в план на сегодня"
                    )

                    DashboardCard {
                        VStack(spacing: 12) {
                            TodayTextField(title: "Предмет", iconName: "book.closed", color: SchoolTheme.success, text: $subject)
                            TodayTextField(title: "Задание", iconName: "text.alignleft", color: SchoolTheme.accent, text: $title)
                            TodayTextField(title: "Срок", iconName: "calendar", color: SchoolTheme.warning, text: $dueLabel)
                            TodayTextField(title: "Источник", iconName: "person.crop.circle", color: SchoolTheme.teal, text: $source)
                            TodayTextField(title: "Что принести", iconName: "backpack.fill", color: SchoolTheme.danger, text: $bring)
                        }
                    }

                    Button {
                        save()
                    } label: {
                        Label("Сохранить ДЗ", systemImage: "checkmark")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 52)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(SchoolTheme.success)
                    .disabled(subject.trimmed.isEmpty || title.trimmed.isEmpty || dueLabel.trimmed.isEmpty)
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Новое ДЗ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
                KeyboardDoneToolbar()
            }
        }
    }

    private func save() {
        let item = HomeworkItem(
            subject: subject.trimmed,
            title: title.trimmed,
            dueLabel: dueLabel.trimmed,
            source: source.trimmed.isEmpty ? "Родитель" : source.trimmed,
            status: .pending,
            bring: bring.trimmed.isEmpty ? nil : bring.trimmed
        )

        onSave(item)
        dismiss()
    }
}

private struct AddParentTaskSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: (ParentTask) -> Void

    @State private var kind: ParentTask.Kind
    @State private var title: String
    @State private var dueLabel = "Сегодня"
    @State private var assignee: String

    init(defaultKind: ParentTask.Kind, defaultAssignee: String, onSave: @escaping (ParentTask) -> Void) {
        self.onSave = onSave
        _kind = State(initialValue: defaultKind)
        _title = State(initialValue: defaultKind.defaultTaskTitle)
        _assignee = State(initialValue: defaultAssignee)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    TodaySheetHeader(
                        icon: kind.iconName,
                        color: kind.color,
                        title: "Семейная задача",
                        subtitle: "Принести, оплатить, подписать или купить"
                    )

                    DashboardCard {
                        VStack(spacing: 12) {
                            kindMenu
                            TodayTextField(title: "Что сделать", iconName: "text.badge.plus", color: kind.color, text: $title)
                            TodayTextField(title: "Срок", iconName: "calendar", color: SchoolTheme.warning, text: $dueLabel)
                            TodayTextField(title: "Исполнитель", iconName: "person.fill", color: SchoolTheme.teal, text: $assignee)
                        }
                    }

                    Button {
                        save()
                    } label: {
                        Label("Сохранить задачу", systemImage: "checkmark")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 52)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(kind.color)
                    .disabled(title.trimmed.isEmpty || dueLabel.trimmed.isEmpty || assignee.trimmed.isEmpty)
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Задача")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
                KeyboardDoneToolbar()
            }
        }
    }

    private var kindMenu: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Тип")
                .font(.caption.weight(.semibold))
                .foregroundStyle(SchoolTheme.muted)

            Menu {
                ForEach(ParentTask.Kind.allCases, id: \.self) { kind in
                    Button(kind.title) {
                        self.kind = kind
                        if title.trimmed.isEmpty || ParentTask.Kind.allCases.map(\.defaultTaskTitle).contains(title) {
                            title = kind.defaultTaskTitle
                        }
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    IconBadge(systemName: kind.iconName, color: kind.color, size: 38)
                    Text(kind.title)
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

    private func save() {
        let task = ParentTask(
            title: title.trimmed,
            dueLabel: dueLabel.trimmed,
            kind: kind,
            assignee: assignee.trimmed
        )

        onSave(task)
        dismiss()
    }
}

private struct ImportantMessagesSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var messages: [TodayImportantMessage]

    let onCreateTask: (TodayImportantMessage) -> Void
    let onSave: () -> Void

    private var activeCount: Int {
        messages.filter { !$0.isHandled }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    TodaySheetHeader(
                        icon: "sparkles",
                        color: SchoolTheme.teal,
                        title: "Важное из чата",
                        subtitle: "Сообщения, из которых можно сделать семейные дела"
                    )

                    DashboardCard {
                        HStack(spacing: 12) {
                            metric(value: "\(activeCount)", title: "новых", color: SchoolTheme.teal)
                            Divider()
                            metric(value: "\(messages.count - activeCount)", title: "готово", color: SchoolTheme.success)
                            Divider()
                            metric(value: "\(messages.count)", title: "всего", color: SchoolTheme.accent)
                        }
                        .frame(height: 62)
                    }

                    DashboardCard {
                        VStack(spacing: 12) {
                            if messages.isEmpty {
                                emptyRow
                            } else {
                                ForEach(messages) { message in
                                    messageRow(message)
                                }
                            }
                        }
                    }
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Чат")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        onSave()
                        dismiss()
                    }
                }
            }
        }
    }

    private var emptyRow: some View {
        HStack(spacing: 12) {
            IconBadge(systemName: "checkmark.bubble.fill", color: SchoolTheme.success, size: 40)
            Text("Важных сообщений пока нет")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(SchoolTheme.muted)
            Spacer()
        }
    }

    private func messageRow(_ message: TodayImportantMessage) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                IconBadge(systemName: message.isHandled ? "checkmark.circle.fill" : message.taskKind.iconName, color: message.isHandled ? SchoolTheme.success : message.taskKind.color, size: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text(message.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(message.isHandled ? SchoolTheme.muted : SchoolTheme.graphite)
                    Text(message.detail)
                        .font(.caption)
                        .foregroundStyle(SchoolTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("\(message.source) - \(message.dueLabel)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(SchoolTheme.teal)
                }

                Spacer()
            }

            if !message.isHandled {
                HStack(spacing: 10) {
                    Button {
                        onCreateTask(message)
                        onSave()
                    } label: {
                        Label(message.actionTitle, systemImage: "plus.circle.fill")
                            .font(.caption.weight(.semibold))
                            .frame(maxWidth: .infinity, minHeight: 36)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(message.taskKind.color)

                    Button {
                        markDone(message)
                    } label: {
                        Label("Готово", systemImage: "checkmark")
                            .font(.caption.weight(.semibold))
                            .frame(maxWidth: .infinity, minHeight: 36)
                    }
                    .buttonStyle(.bordered)
                    .tint(SchoolTheme.teal)
                }
            }
        }
        .padding(12)
        .background(SchoolTheme.surface, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(SchoolTheme.line, lineWidth: 1)
        }
    }

    private func metric(value: String, title: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(color)
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(SchoolTheme.muted)
        }
        .frame(maxWidth: .infinity)
    }

    private func markDone(_ message: TodayImportantMessage) {
        guard let index = messages.firstIndex(where: { $0.id == message.id }) else {
            return
        }

        messages[index].isHandled = true
        onSave()
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

private extension ParentTask.Kind {
    var title: String {
        switch self {
        case .bring:
            "Принести"
        case .pay:
            "Оплатить"
        case .sign:
            "Подписать"
        case .buy:
            "Купить"
        }
    }

    var iconName: String {
        switch self {
        case .bring:
            "backpack.fill"
        case .pay:
            "rublesign.circle.fill"
        case .sign:
            "signature"
        case .buy:
            "cart.fill"
        }
    }

    var color: Color {
        switch self {
        case .bring:
            SchoolTheme.teal
        case .pay:
            SchoolTheme.warning
        case .sign:
            SchoolTheme.accent
        case .buy:
            SchoolTheme.success
        }
    }

    var defaultTaskTitle: String {
        switch self {
        case .bring:
            "Принести сменную обувь"
        case .pay:
            "Оплатить сбор класса"
        case .sign:
            "Подписать согласие"
        case .buy:
            "Купить материалы"
        }
    }
}

private enum TodaySheet: Identifiable {
    case schedule
    case addLesson
    case importSchedule
    case addHomework
    case addTask(ParentTask.Kind)
    case importantMessages
    case globalParse
    case addChild
    case notifications
    case profile
    case homeworkList
    case urgentTasks
    case chats

    var id: String {
        switch self {
        case .schedule:
            "schedule"
        case .addLesson:
            "add-lesson"
        case .importSchedule:
            "import-schedule"
        case .addHomework:
            "add-homework"
        case .addTask(let kind):
            "add-task-\(kind.rawValue)"
        case .importantMessages:
            "important-messages"
        case .globalParse:
            "global-parse"
        case .addChild:
            "add-child"
        case .notifications:
            "notifications"
        case .profile:
            "profile"
        case .homeworkList:
            "homework-list"
        case .urgentTasks:
            "urgent-tasks"
        case .chats:
            "chats"
        }
    }
}

private extension Date {
    var todayAttachmentTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM HH:mm"
        return formatter.string(from: self)
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
