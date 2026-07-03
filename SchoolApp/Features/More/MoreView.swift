import SwiftUI
import UniformTypeIdentifiers

private struct NotificationSettingsState: Codable, Hashable {
    var eveningTime: String
    var morningTime: String
    var quietHoursEnabled: Bool
    var quietStart: String
    var quietEnd: String

    static let sample = NotificationSettingsState(
        eveningTime: "20:30",
        morningTime: "07:15",
        quietHoursEnabled: true,
        quietStart: "22:00",
        quietEnd: "07:00"
    )
}

private struct MoreStoreSnapshot: Codable {
    var children: [ChildSummary]
    var familyMembers: [FamilyAccessMember]
    var classAccess: [ClassAccessSummary]
    var notificationPreferences: [NotificationPreference]
    var notificationSettings: NotificationSettingsState
    var subscriptionPlans: [SubscriptionPlanSummary]
    var classMemory: [ClassMemoryEntry]
    var classFiles: [ClassFileSummary]

    init(
        children: [ChildSummary],
        familyMembers: [FamilyAccessMember],
        classAccess: [ClassAccessSummary],
        notificationPreferences: [NotificationPreference],
        notificationSettings: NotificationSettingsState = .sample,
        subscriptionPlans: [SubscriptionPlanSummary],
        classMemory: [ClassMemoryEntry],
        classFiles: [ClassFileSummary]
    ) {
        self.children = children
        self.familyMembers = familyMembers
        self.classAccess = classAccess
        self.notificationPreferences = notificationPreferences
        self.notificationSettings = notificationSettings
        self.subscriptionPlans = subscriptionPlans
        self.classMemory = classMemory
        self.classFiles = classFiles
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        children = try container.decode([ChildSummary].self, forKey: .children)
        familyMembers = try container.decode([FamilyAccessMember].self, forKey: .familyMembers)
        classAccess = try container.decode([ClassAccessSummary].self, forKey: .classAccess)
        notificationPreferences = try container.decode([NotificationPreference].self, forKey: .notificationPreferences)
        notificationSettings = try container.decodeIfPresent(NotificationSettingsState.self, forKey: .notificationSettings) ?? .sample
        subscriptionPlans = try container.decode([SubscriptionPlanSummary].self, forKey: .subscriptionPlans)
        classMemory = try container.decodeIfPresent([ClassMemoryEntry].self, forKey: .classMemory) ?? SampleData.classMemory
        classFiles = try container.decodeIfPresent([ClassFileSummary].self, forKey: .classFiles) ?? SampleData.classFiles
    }

    static let sample = MoreStoreSnapshot(
        children: SampleData.children,
        familyMembers: SampleData.familyMembers,
        classAccess: SampleData.classAccess,
        notificationPreferences: SampleData.notificationPreferences,
        notificationSettings: .sample,
        subscriptionPlans: SampleData.subscriptionPlans,
        classMemory: SampleData.classMemory,
        classFiles: SampleData.classFiles
    )
}

private enum MoreLocalStore {
    private static let defaultsKey = "school.more.store.v1"
    private static var snapshot: MoreStoreSnapshot = load()

    static var children: [ChildSummary] {
        get { snapshot.children }
        set {
            snapshot.children = newValue
            save()
        }
    }

    static var familyMembers: [FamilyAccessMember] {
        get { snapshot.familyMembers }
        set {
            snapshot.familyMembers = newValue
            save()
        }
    }

    static var classAccess: [ClassAccessSummary] {
        get { snapshot.classAccess }
        set {
            snapshot.classAccess = newValue
            save()
        }
    }

    static var notificationPreferences: [NotificationPreference] {
        get { snapshot.notificationPreferences }
        set {
            snapshot.notificationPreferences = newValue
            save()
        }
    }

    static var notificationSettings: NotificationSettingsState {
        get { snapshot.notificationSettings }
        set {
            snapshot.notificationSettings = newValue
            save()
        }
    }

    static var subscriptionPlans: [SubscriptionPlanSummary] {
        get { snapshot.subscriptionPlans }
        set {
            snapshot.subscriptionPlans = newValue
            save()
        }
    }

    static var classMemory: [ClassMemoryEntry] {
        get { snapshot.classMemory }
        set {
            snapshot.classMemory = newValue
            save()
        }
    }

    static var classFiles: [ClassFileSummary] {
        get { snapshot.classFiles }
        set {
            snapshot.classFiles = newValue
            save()
        }
    }

    static func resetIfRequested() {
        guard ProcessInfo.processInfo.arguments.contains("-qa-reset-more-store") else {
            return
        }

        snapshot = .sample
        UserDefaults.standard.removeObject(forKey: defaultsKey)
    }

    private static func load() -> MoreStoreSnapshot {
        guard
            let data = UserDefaults.standard.data(forKey: defaultsKey),
            let decoded = try? JSONDecoder().decode(MoreStoreSnapshot.self, from: data)
        else {
            return .sample
        }

        return decoded
    }

    private static func save() {
        guard let data = try? JSONEncoder().encode(snapshot) else {
            return
        }

        UserDefaults.standard.set(data, forKey: defaultsKey)
    }
}

struct MoreView: View {
    @State private var children: [ChildSummary]
    @State private var familyMembers: [FamilyAccessMember]
    @State private var classAccess: [ClassAccessSummary]
    @State private var notificationPreferences: [NotificationPreference]
    @State private var notificationSettings: NotificationSettingsState
    @State private var subscriptionPlans: [SubscriptionPlanSummary]
    @State private var classMemory: [ClassMemoryEntry]
    @State private var classFiles: [ClassFileSummary]
    @State private var activeSheet: MoreSheet?

    init() {
        MoreLocalStore.resetIfRequested()
        _children = State(initialValue: MoreLocalStore.children)
        _familyMembers = State(initialValue: MoreLocalStore.familyMembers)
        _classAccess = State(initialValue: MoreLocalStore.classAccess)
        _notificationPreferences = State(initialValue: MoreLocalStore.notificationPreferences)
        _notificationSettings = State(initialValue: MoreLocalStore.notificationSettings)
        _subscriptionPlans = State(initialValue: MoreLocalStore.subscriptionPlans)
        _classMemory = State(initialValue: MoreLocalStore.classMemory)
        _classFiles = State(initialValue: MoreLocalStore.classFiles)
        _activeSheet = State(initialValue: MoreView.launchSheet())
    }

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
            .padding(.bottom, SchoolTheme.bottomScrollPadding)
        }
        .background(SchoolTheme.page.ignoresSafeArea())
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .children:
                ChildrenAccessSheet(children: children) { updatedChildren in
                    children = updatedChildren
                    MoreLocalStore.children = updatedChildren
                }
            case .family:
                FamilyAccessSheet(members: familyMembers) { updatedMembers in
                    familyMembers = updatedMembers
                    MoreLocalStore.familyMembers = updatedMembers
                }
            case .classes:
                ClassesAccessSheet(classes: classAccess) { updatedClasses in
                    classAccess = updatedClasses
                    MoreLocalStore.classAccess = updatedClasses
                }
            case .subscription:
                SubscriptionSheet(plans: subscriptionPlans) { updatedPlans in
                    subscriptionPlans = updatedPlans
                    MoreLocalStore.subscriptionPlans = updatedPlans
                }
            case .notifications:
                NotificationSettingsSheet(preferences: notificationPreferences, settings: notificationSettings) { updatedPreferences, updatedSettings in
                    notificationPreferences = updatedPreferences
                    notificationSettings = updatedSettings
                    MoreLocalStore.notificationPreferences = updatedPreferences
                    MoreLocalStore.notificationSettings = updatedSettings
                }
            case .memory:
                ClassMemorySheet(entries: classMemory) { updatedEntries in
                    classMemory = updatedEntries
                    MoreLocalStore.classMemory = updatedEntries
                }
            case .files:
                ClassFilesSheet(files: classFiles) { updatedFiles in
                    classFiles = updatedFiles
                    MoreLocalStore.classFiles = updatedFiles
                }
            }
        }
    }

    private var header: some View {
        HStack {
            Text("Еще")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(SchoolTheme.graphite)
            Spacer()
            HeaderIconButton(systemName: "gearshape") {
                activeSheet = .notifications
            }
            .accessibilityLabel("Настройки")
        }
    }

    private var profileCard: some View {
        Button {
            activeSheet = .family
        } label: {
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
        .buttonStyle(.plain)
    }

    private func menuSection(_ title: String, items: [MoreMenuItem]) -> some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 14) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(SchoolTheme.graphite)

                ForEach(items) { item in
                    Button {
                        if let sheet = item.sheet {
                            activeSheet = sheet
                        }
                    } label: {
                        HStack(spacing: 12) {
                            IconBadge(systemName: item.icon, color: item.color, size: 40)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(SchoolTheme.graphite)
                                Text(item.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(SchoolTheme.muted)
                                    .lineLimit(2)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(SchoolTheme.muted)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var familyItems: [MoreMenuItem] {
        [
            MoreMenuItem(title: "Дети", subtitle: "\(children.count) профиля", icon: "person.crop.square", color: SchoolTheme.success, sheet: .children),
            MoreMenuItem(title: "Семья", subtitle: "\(familyMembers.count) доступа: родители, бабушка, няня", icon: "person.2.fill", color: SchoolTheme.teal, sheet: .family),
            MoreMenuItem(title: "Классы", subtitle: classAccess.map(\.title).joined(separator: " и "), icon: "building.2.fill", color: SchoolTheme.accent, sheet: .classes)
        ]
    }

    private var appItems: [MoreMenuItem] {
        [
            MoreMenuItem(title: "Подписка", subtitle: subscriptionSubtitle, icon: "creditcard.fill", color: SchoolTheme.warning, sheet: .subscription),
            MoreMenuItem(title: "Уведомления", subtitle: "\(enabledNotificationCount) включено: дайджесты, дедлайны, срочное", icon: "bell.fill", color: SchoolTheme.success, sheet: .notifications),
            MoreMenuItem(title: "Память класса", subtitle: "\(classMemory.count) находки: объявления, файлы, события", icon: "magnifyingglass", color: SchoolTheme.accent, sheet: .memory),
            MoreMenuItem(title: "Файлы", subtitle: "\(classFiles.count) файла: согласия, чеки, материалы", icon: "folder.fill", color: SchoolTheme.teal, sheet: .files)
        ]
    }

    private var subscriptionSubtitle: String {
        guard let currentPlan = subscriptionPlans.first(where: \.isCurrent) else {
            return "Пробный период и семейный доступ"
        }

        return "\(currentPlan.title): \(currentPlan.price)"
    }

    private var enabledNotificationCount: Int {
        notificationPreferences.filter(\.isEnabled).count
    }

    private var helpItems: [MoreMenuItem] {
        [
            MoreMenuItem(title: "Безопасность", subtitle: "Данные детей и доступы", icon: "lock.shield.fill", color: SchoolTheme.success),
            MoreMenuItem(title: "Поддержка", subtitle: "Написать нам", icon: "message.fill", color: SchoolTheme.accent),
            MoreMenuItem(title: "Проблема", subtitle: "Сообщить об ошибке", icon: "exclamationmark.bubble.fill", color: SchoolTheme.danger)
        ]
    }

    private static func launchSheet() -> MoreSheet? {
        let arguments = ProcessInfo.processInfo.arguments

        if arguments.contains("-qa-more-children") {
            return .children
        }

        if arguments.contains("-qa-more-family") {
            return .family
        }

        if arguments.contains("-qa-more-classes") {
            return .classes
        }

        if arguments.contains("-qa-more-subscription") {
            return .subscription
        }

        if arguments.contains("-qa-more-notifications") {
            return .notifications
        }

        if arguments.contains("-qa-more-memory") {
            return .memory
        }

        if arguments.contains("-qa-more-files") || arguments.contains("-qa-more-files-importer") {
            return .files
        }

        return nil
    }
}

private struct ChildrenAccessSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: ([ChildSummary]) -> Void

    @State private var children: [ChildSummary]
    @State private var childName = "Саша"
    @State private var className = "1А"
    @State private var school = "Школа 1254"

    init(children: [ChildSummary], onSave: @escaping ([ChildSummary]) -> Void) {
        self.onSave = onSave
        _children = State(initialValue: children)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    MoreSheetHeader(
                        icon: "person.crop.square",
                        color: SchoolTheme.success,
                        title: "Дети",
                        subtitle: "Профили, классы и школьные связи"
                    )

                    DashboardCard {
                        HStack(spacing: 12) {
                            MoreMetric(value: "\(children.count)", title: "профиля", color: SchoolTheme.success)
                            Divider()
                            MoreMetric(value: "2", title: "класса", color: SchoolTheme.accent)
                            Divider()
                            MoreMetric(value: "1", title: "семья", color: SchoolTheme.teal)
                        }
                        .frame(height: 62)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Профили детей")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            ForEach(children) { child in
                                HStack(spacing: 12) {
                                    InitialAvatar(text: child.avatarText, color: SchoolTheme.success, size: 42)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("\(child.name), \(child.className)")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(SchoolTheme.graphite)
                                        Text(child.school)
                                            .font(.caption)
                                            .foregroundStyle(SchoolTheme.muted)
                                    }
                                    Spacer()
                                    StatusBadge(text: "Активен", color: SchoolTheme.success)
                                }
                            }
                        }
                    }

                    DashboardCard {
                        VStack(spacing: 12) {
                            MoreTextField(title: "Имя ребенка", iconName: "person.fill", color: SchoolTheme.success, text: $childName)
                            MoreTextField(title: "Класс", iconName: "building.2.fill", color: SchoolTheme.accent, text: $className)
                            MoreTextField(title: "Школа", iconName: "graduationcap.fill", color: SchoolTheme.teal, text: $school)

                            Button {
                                addChild()
                            } label: {
                                Label("Добавить ребенка", systemImage: "plus")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity, minHeight: 46)
                            }
                            .buttonStyle(.bordered)
                            .tint(SchoolTheme.success)
                            .disabled(childName.trimmed.isEmpty || className.trimmed.isEmpty)
                        }
                    }

                    saveButton
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Дети")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        save()
                    }
                }
            }
        }
    }

    private var saveButton: some View {
        Button {
            save()
        } label: {
            Label("Сохранить детей", systemImage: "checkmark")
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: 52)
        }
        .buttonStyle(.borderedProminent)
        .tint(SchoolTheme.success)
    }

    private func addChild() {
        let avatar = String(childName.trimmed.prefix(1)).uppercased()
        children.append(
            ChildSummary(
                name: childName.trimmed,
                className: className.trimmed,
                school: school.trimmed,
                avatarText: avatar.isEmpty ? "Р" : avatar
            )
        )
        childName = ""
        className = ""
    }

    private func save() {
        onSave(children)
        dismiss()
    }
}

private struct FamilyAccessSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: ([FamilyAccessMember]) -> Void

    @State private var members: [FamilyAccessMember]
    @State private var inviteName = "Наталья"
    @State private var inviteRole = "Няня"
    @State private var inviteAccess = "Календарь и что забрать"

    init(members: [FamilyAccessMember], onSave: @escaping ([FamilyAccessMember]) -> Void) {
        self.onSave = onSave
        _members = State(initialValue: members)
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        MoreSheetHeader(
                            icon: "person.2.fill",
                            color: SchoolTheme.teal,
                            title: "Семья",
                            subtitle: "Кто помогает с ребенком и что видит"
                        )
                        .id("family-top")

                        DashboardCard {
                            HStack(spacing: 12) {
                                MoreMetric(value: "\(members.count)", title: "доступа", color: SchoolTheme.teal)
                                Divider()
                                MoreMetric(value: "\(members.filter { $0.status.contains("Ожидает") }.count)", title: "ожидают", color: SchoolTheme.warning)
                                Divider()
                                MoreMetric(value: "1", title: "админ", color: SchoolTheme.success)
                            }
                            .frame(height: 62)
                        }

                        DashboardCard {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Семейный доступ")
                                    .font(.headline)
                                    .foregroundStyle(SchoolTheme.graphite)

                                ForEach(members) { member in
                                    HStack(spacing: 12) {
                                        InitialAvatar(text: member.avatarText, color: color(for: member.role), size: 42)
                                        VStack(alignment: .leading, spacing: 3) {
                                            HStack(spacing: 7) {
                                                Text(member.name)
                                                    .font(.subheadline.weight(.semibold))
                                                    .foregroundStyle(SchoolTheme.graphite)
                                                StatusBadge(text: member.role, color: color(for: member.role))
                                            }
                                            Text(member.access)
                                                .font(.caption)
                                                .foregroundStyle(SchoolTheme.muted)
                                            Text(member.status)
                                                .font(.caption.weight(.semibold))
                                                .foregroundStyle(member.status.contains("Ожидает") ? SchoolTheme.warning : SchoolTheme.success)
                                        }
                                        Spacer()
                                    }
                                }
                            }
                        }

                        DashboardCard {
                            VStack(spacing: 12) {
                                MoreTextField(title: "Кого пригласить", iconName: "person.badge.plus", color: SchoolTheme.success, text: $inviteName)

                                Picker("Роль", selection: $inviteRole) {
                                    Text("Родитель").tag("Второй родитель")
                                    Text("Бабушка").tag("Бабушка")
                                    Text("Няня").tag("Няня")
                                }
                                .pickerStyle(.segmented)

                                MoreTextField(title: "Доступ", iconName: "lock.open.fill", color: SchoolTheme.accent, text: $inviteAccess)

                                Button {
                                    inviteMember()
                                } label: {
                                    Label("Отправить приглашение", systemImage: "link")
                                        .font(.subheadline.weight(.semibold))
                                        .frame(maxWidth: .infinity, minHeight: 46)
                                }
                                .buttonStyle(.bordered)
                                .tint(SchoolTheme.success)
                                .disabled(inviteName.trimmed.isEmpty)
                            }
                        }

                        Button {
                            save()
                        } label: {
                            Label("Сохранить семью", systemImage: "checkmark")
                                .font(.headline)
                                .frame(maxWidth: .infinity, minHeight: 52)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(SchoolTheme.success)
                    }
                    .padding(20)
                    .padding(.bottom, 20)
                }
                .onAppear {
                    proxy.scrollTo("family-top", anchor: .top)
                }
                .background(SchoolTheme.page.ignoresSafeArea())
                .navigationTitle("Семья")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Закрыть") {
                            save()
                        }
                    }
                }
            }
        }
    }

    private func inviteMember() {
        let avatar = String(inviteName.trimmed.prefix(1)).uppercased()
        members.append(
            FamilyAccessMember(
                name: inviteName.trimmed,
                role: inviteRole,
                access: inviteAccess.trimmed,
                avatarText: avatar.isEmpty ? "С" : avatar,
                status: "Ожидает вход"
            )
        )
        inviteName = ""
    }

    private func save() {
        onSave(members)
        dismiss()
    }

    private func color(for role: String) -> Color {
        switch role {
        case "Бабушка", "Няня":
            SchoolTheme.teal
        case "Второй родитель":
            SchoolTheme.accent
        default:
            SchoolTheme.success
        }
    }
}

private struct ClassesAccessSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: ([ClassAccessSummary]) -> Void

    @State private var classes: [ClassAccessSummary]
    @State private var inviteCode = "NEW-2048"
    @State private var newClassTitle = "2В"
    @State private var newRole = "Родитель"

    init(classes: [ClassAccessSummary], onSave: @escaping ([ClassAccessSummary]) -> Void) {
        self.onSave = onSave
        _classes = State(initialValue: classes)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    MoreSheetHeader(
                        icon: "building.2.fill",
                        color: SchoolTheme.accent,
                        title: "Классы",
                        subtitle: "Роли, коды приглашения и закрытый доступ"
                    )

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Мои классы")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            ForEach(classes) { classItem in
                                HStack(spacing: 12) {
                                    IconBadge(systemName: "building.2.fill", color: classItem.role.contains("Админ") ? SchoolTheme.success : SchoolTheme.accent, size: 42)
                                    VStack(alignment: .leading, spacing: 3) {
                                        HStack(spacing: 7) {
                                            Text(classItem.title)
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(SchoolTheme.graphite)
                                            StatusBadge(text: classItem.role, color: classItem.role.contains("Админ") ? SchoolTheme.success : SchoolTheme.accent)
                                        }
                                        Text(classItem.school)
                                            .font(.caption)
                                            .foregroundStyle(SchoolTheme.muted)
                                        Text("\(classItem.status) - код \(classItem.inviteCode)")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(SchoolTheme.muted)
                                    }
                                    Spacer()
                                }
                            }
                        }
                    }

                    DashboardCard {
                        VStack(spacing: 12) {
                            MoreTextField(title: "Название класса", iconName: "text.badge.plus", color: SchoolTheme.success, text: $newClassTitle)
                            MoreTextField(title: "Код приглашения", iconName: "number", color: SchoolTheme.warning, text: $inviteCode)

                            Picker("Роль", selection: $newRole) {
                                Text("Родитель").tag("Родитель")
                                Text("Админ").tag("Админ класса")
                                Text("Учитель").tag("Учитель")
                            }
                            .pickerStyle(.segmented)

                            Button {
                                joinClass()
                            } label: {
                                Label("Добавить класс", systemImage: "plus")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity, minHeight: 46)
                            }
                            .buttonStyle(.bordered)
                            .tint(SchoolTheme.success)
                            .disabled(newClassTitle.trimmed.isEmpty || inviteCode.trimmed.isEmpty)
                        }
                    }

                    Button {
                        save()
                    } label: {
                        Label("Сохранить классы", systemImage: "checkmark")
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
            .navigationTitle("Классы")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        save()
                    }
                }
            }
        }
    }

    private func joinClass() {
        classes.append(
            ClassAccessSummary(
                title: newClassTitle.trimmed,
                school: "Школа 1254",
                role: newRole,
                inviteCode: inviteCode.trimmed,
                status: "Ожидает подтверждения"
            )
        )
        newClassTitle = ""
        inviteCode = ""
    }

    private func save() {
        onSave(classes)
        dismiss()
    }
}

private struct SubscriptionSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: ([SubscriptionPlanSummary]) -> Void

    @State private var plans: [SubscriptionPlanSummary]
    @State private var restoreStatus = "Покупки еще не проверялись"

    init(plans: [SubscriptionPlanSummary], onSave: @escaping ([SubscriptionPlanSummary]) -> Void) {
        self.onSave = onSave
        _plans = State(initialValue: plans)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    MoreSheetHeader(
                        icon: "creditcard.fill",
                        color: SchoolTheme.warning,
                        title: "Подписка",
                        subtitle: "Пробный период, семейный доступ и будущие лимиты"
                    )

                    DashboardCard {
                        HStack(spacing: 12) {
                            MoreMetric(value: currentPlan?.badge ?? "Активен", title: "статус", color: SchoolTheme.warning)
                            Divider()
                            MoreMetric(value: "14", title: "дней trial", color: SchoolTheme.success)
                            Divider()
                            MoreMetric(value: "2", title: "ребенка", color: SchoolTheme.accent)
                        }
                        .frame(height: 62)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Тарифы MVP")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            ForEach(plans) { plan in
                                Button {
                                    select(plan)
                                } label: {
                                    subscriptionPlanRow(plan)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Что входит")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            ForEach(SampleData.subscriptionBenefits) { benefit in
                                HStack(spacing: 12) {
                                    IconBadge(systemName: benefit.iconName, color: moreColor(for: benefit.colorName), size: 40)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(benefit.title)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(SchoolTheme.graphite)
                                        Text(benefit.detail)
                                            .font(.caption)
                                            .foregroundStyle(SchoolTheme.muted)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    Spacer()
                                }
                            }
                        }
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Покупки")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)
                            Text(restoreStatus)
                                .font(.caption)
                                .foregroundStyle(SchoolTheme.muted)

                            Button {
                                restoreStatus = "Проверено локально: активен \(currentPlan?.title ?? "пробный период")"
                            } label: {
                                Label("Восстановить покупки", systemImage: "arrow.clockwise")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity, minHeight: 46)
                            }
                            .buttonStyle(.bordered)
                            .tint(SchoolTheme.accent)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button {
                        save()
                    } label: {
                        Label("Сохранить подписку", systemImage: "checkmark")
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
            .navigationTitle("Подписка")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        save()
                    }
                }
            }
        }
    }

    private var currentPlan: SubscriptionPlanSummary? {
        plans.first(where: \.isCurrent)
    }

    private func subscriptionPlanRow(_ plan: SubscriptionPlanSummary) -> some View {
        HStack(spacing: 12) {
            IconBadge(
                systemName: plan.isCurrent ? "checkmark.seal.fill" : "creditcard.fill",
                color: plan.isCurrent ? SchoolTheme.success : SchoolTheme.warning,
                size: 42
            )
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 7) {
                    Text(plan.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SchoolTheme.graphite)
                    StatusBadge(text: plan.badge, color: plan.isCurrent ? SchoolTheme.success : SchoolTheme.warning)
                }
                Text(plan.price)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite)
                Text(plan.detail)
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            Image(systemName: plan.isCurrent ? "checkmark.circle.fill" : "circle")
                .font(.title3.weight(.semibold))
                .foregroundStyle(plan.isCurrent ? SchoolTheme.success : SchoolTheme.muted.opacity(0.45))
        }
        .padding(12)
        .background(SchoolTheme.surface, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(plan.isCurrent ? SchoolTheme.success.opacity(0.35) : SchoolTheme.line, lineWidth: 1)
        }
    }

    private func select(_ plan: SubscriptionPlanSummary) {
        for index in plans.indices {
            plans[index].isCurrent = plans[index].id == plan.id
        }
    }

    private func save() {
        onSave(plans)
        dismiss()
    }
}

private struct NotificationSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: ([NotificationPreference], NotificationSettingsState) -> Void

    @State private var preferences: [NotificationPreference]
    @State private var settings: NotificationSettingsState
    @State private var testStatus = "Тестовый дайджест не отправлялся"

    init(
        preferences: [NotificationPreference],
        settings: NotificationSettingsState,
        onSave: @escaping ([NotificationPreference], NotificationSettingsState) -> Void
    ) {
        self.onSave = onSave
        _preferences = State(initialValue: preferences)
        _settings = State(initialValue: settings)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    MoreSheetHeader(
                        icon: "bell.fill",
                        color: SchoolTheme.success,
                        title: "Уведомления",
                        subtitle: "Дайджесты, дедлайны, срочное и тихие часы"
                    )

                    DashboardCard {
                        HStack(spacing: 12) {
                            MoreMetric(value: "\(enabledCount)", title: "включено", color: SchoolTheme.success)
                            Divider()
                            MoreMetric(value: settings.eveningTime, title: "вечером", color: SchoolTheme.accent)
                            Divider()
                            MoreMetric(value: settings.quietHoursEnabled ? "да" : "нет", title: "тихий режим", color: SchoolTheme.teal)
                        }
                        .frame(height: 62)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Что присылать")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            ForEach($preferences) { $preference in
                                NotificationPreferenceRow(preference: $preference)
                            }
                        }
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Время дайджестов")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            Text("Вечер")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(SchoolTheme.muted)
                            Picker("Вечер", selection: $settings.eveningTime) {
                                Text("19:30").tag("19:30")
                                Text("20:30").tag("20:30")
                                Text("21:30").tag("21:30")
                            }
                            .pickerStyle(.segmented)

                            Text("Утро")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(SchoolTheme.muted)
                            Picker("Утро", selection: $settings.morningTime) {
                                Text("07:00").tag("07:00")
                                Text("07:15").tag("07:15")
                                Text("07:30").tag("07:30")
                            }
                            .pickerStyle(.segmented)
                        }
                    }

                    DashboardCard {
                        VStack(spacing: 12) {
                            Toggle(isOn: $settings.quietHoursEnabled) {
                                HStack(spacing: 12) {
                                    IconBadge(systemName: "moon.zzz.fill", color: SchoolTheme.teal, size: 40)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Тихие часы")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(SchoolTheme.graphite)
                                        Text("Срочное остается, обычные напоминания ждут утра")
                                            .font(.caption)
                                            .foregroundStyle(SchoolTheme.muted)
                                    }
                                }
                            }
                            .tint(SchoolTheme.success)

                            HStack(spacing: 10) {
                                MoreTextField(title: "Начало", iconName: "moon.fill", color: SchoolTheme.teal, text: $settings.quietStart)
                                MoreTextField(title: "Конец", iconName: "sunrise.fill", color: SchoolTheme.warning, text: $settings.quietEnd)
                            }
                            .disabled(!settings.quietHoursEnabled)
                            .opacity(settings.quietHoursEnabled ? 1 : 0.45)
                        }
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Проверка")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)
                            Text(testStatus)
                                .font(.caption)
                                .foregroundStyle(SchoolTheme.muted)

                            Button {
                                testStatus = "Готово: локальный дайджест собран на \(settings.eveningTime)"
                            } label: {
                                Label("Собрать тестовый дайджест", systemImage: "paperplane.fill")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity, minHeight: 46)
                            }
                            .buttonStyle(.bordered)
                            .tint(SchoolTheme.accent)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button {
                        save()
                    } label: {
                        Label("Сохранить уведомления", systemImage: "checkmark")
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
            .navigationTitle("Уведомления")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        save()
                    }
                }
            }
        }
    }

    private var enabledCount: Int {
        preferences.filter(\.isEnabled).count
    }

    private func save() {
        onSave(preferences, settings)
        dismiss()
    }
}

private struct ClassMemorySheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: ([ClassMemoryEntry]) -> Void

    @State private var entries: [ClassMemoryEntry]
    @State private var searchText = ""
    @State private var newTitle = "Фото с экскурсии"
    @State private var newDetail = "Добавить в память класса и связать с событием"
    @State private var newTag = "Фото"

    private let tags = ["Фото", "Событие", "Объявление", "Файл"]

    init(entries: [ClassMemoryEntry], onSave: @escaping ([ClassMemoryEntry]) -> Void) {
        self.onSave = onSave
        _entries = State(initialValue: entries)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    MoreSheetHeader(
                        icon: "magnifyingglass",
                        color: SchoolTheme.accent,
                        title: "Память класса",
                        subtitle: "Поиск по объявлениям, событиям, файлам и важным решениям"
                    )

                    DashboardCard {
                        HStack(spacing: 12) {
                            MoreMetric(value: "\(entries.count)", title: "записей", color: SchoolTheme.accent)
                            Divider()
                            MoreMetric(value: "\(Set(entries.map(\.tag)).count)", title: "типов", color: SchoolTheme.teal)
                            Divider()
                            MoreMetric(value: "\(filteredEntries.count)", title: "найдено", color: SchoolTheme.success)
                        }
                        .frame(height: 62)
                    }

                    DashboardCard {
                        VStack(spacing: 12) {
                            MoreTextField(title: "Поиск", iconName: "magnifyingglass", color: SchoolTheme.accent, text: $searchText)

                            if filteredEntries.isEmpty {
                                MoreEmptyState(
                                    icon: "tray.fill",
                                    title: "Ничего не найдено",
                                    detail: "Попробуй другое слово: событие, чек, согласие или объявление"
                                )
                            } else {
                                ForEach(filteredEntries) { entry in
                                    memoryRow(entry)
                                }
                            }
                        }
                    }

                    DashboardCard {
                        VStack(spacing: 12) {
                            Text("Добавить в память")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            MoreTextField(title: "Название", iconName: "text.badge.plus", color: SchoolTheme.success, text: $newTitle)
                            MoreTextField(title: "Описание", iconName: "note.text", color: SchoolTheme.accent, text: $newDetail)

                            Picker("Тип", selection: $newTag) {
                                ForEach(tags, id: \.self) { tag in
                                    Text(tag).tag(tag)
                                }
                            }
                            .pickerStyle(.segmented)

                            Button {
                                addEntry()
                            } label: {
                                Label("Добавить запись", systemImage: "plus")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity, minHeight: 46)
                            }
                            .buttonStyle(.bordered)
                            .tint(SchoolTheme.success)
                            .disabled(newTitle.trimmed.isEmpty || newDetail.trimmed.isEmpty)
                        }
                    }

                    Button {
                        save()
                    } label: {
                        Label("Сохранить память", systemImage: "checkmark")
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
            .navigationTitle("Память класса")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        save()
                    }
                }
            }
        }
    }

    private var filteredEntries: [ClassMemoryEntry] {
        let query = searchText.trimmed.lowercased()
        guard !query.isEmpty else {
            return entries
        }

        return entries.filter { entry in
            [entry.title, entry.detail, entry.source, entry.dateLabel, entry.tag]
                .joined(separator: " ")
                .lowercased()
                .contains(query)
        }
    }

    private func memoryRow(_ entry: ClassMemoryEntry) -> some View {
        HStack(alignment: .top, spacing: 12) {
            IconBadge(systemName: entry.iconName, color: moreColor(for: entry.colorName), size: 42)
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 7) {
                    Text(entry.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SchoolTheme.graphite)
                    StatusBadge(text: entry.tag, color: moreColor(for: entry.colorName))
                }
                Text(entry.detail)
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
                Text("\(entry.source) - \(entry.dateLabel)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SchoolTheme.success)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func addEntry() {
        entries.insert(
            ClassMemoryEntry(
                title: newTitle.trimmed,
                detail: newDetail.trimmed,
                source: "Добавлено вручную",
                dateLabel: "сегодня",
                tag: newTag,
                iconName: iconName(for: newTag),
                colorName: colorName(for: newTag)
            ),
            at: 0
        )
        newTitle = ""
        newDetail = ""
    }

    private func iconName(for tag: String) -> String {
        switch tag {
        case "Фото":
            "photo.fill"
        case "Событие":
            "calendar.badge.clock"
        case "Объявление":
            "megaphone.fill"
        default:
            "doc.text.fill"
        }
    }

    private func colorName(for tag: String) -> String {
        switch tag {
        case "Фото", "Файл":
            "teal"
        case "Объявление":
            "orange"
        default:
            "blue"
        }
    }

    private func save() {
        onSave(entries)
        dismiss()
    }
}

private struct ClassFilesSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: ([ClassFileSummary]) -> Void

    @State private var files: [ClassFileSummary]
    @State private var searchText = ""
    @State private var selectedFilter = "Все"
    @State private var newTitle = "Согласие на экскурсию.pdf"
    @State private var newDetail = "Документ для родителей 3Б"
    @State private var newCategory = "Согласия"
    @State private var importStatus = "Файл пока не выбран"
    @State private var isFileImporterVisible = ProcessInfo.processInfo.arguments.contains("-qa-more-files-importer")

    private let filters = ["Все", "Согласия", "Чеки", "Материалы"]
    private let categories = ["Согласия", "Чеки", "Материалы"]

    init(files: [ClassFileSummary], onSave: @escaping ([ClassFileSummary]) -> Void) {
        self.onSave = onSave
        _files = State(initialValue: files)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    MoreSheetHeader(
                        icon: "folder.fill",
                        color: SchoolTheme.teal,
                        title: "Файлы",
                        subtitle: "Согласия, чеки, материалы и документы класса"
                    )

                    DashboardCard {
                        HStack(spacing: 12) {
                            MoreMetric(value: "\(files.count)", title: "файлов", color: SchoolTheme.teal)
                            Divider()
                            MoreMetric(value: "\(Set(files.map(\.category)).count)", title: "папки", color: SchoolTheme.accent)
                            Divider()
                            MoreMetric(value: "\(actionNeededCount)", title: "дела", color: SchoolTheme.warning)
                        }
                        .frame(height: 62)
                    }

                    DashboardCard {
                        VStack(spacing: 12) {
                            MoreTextField(title: "Поиск файла", iconName: "magnifyingglass", color: SchoolTheme.accent, text: $searchText)

                            Picker("Папка", selection: $selectedFilter) {
                                ForEach(filters, id: \.self) { filter in
                                    Text(filter).tag(filter)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Документы")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            if filteredFiles.isEmpty {
                                MoreEmptyState(
                                    icon: "folder.badge.questionmark",
                                    title: "Файлов нет",
                                    detail: "В этой папке пока ничего не найдено"
                                )
                            } else {
                                ForEach(filteredFiles) { file in
                                    fileRow(file)
                                }
                            }
                        }
                    }

                    DashboardCard {
                        VStack(spacing: 12) {
                            Text("Добавить файл")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            MoreTextField(title: "Название", iconName: "doc.badge.plus", color: SchoolTheme.success, text: $newTitle)
                            MoreTextField(title: "Описание", iconName: "note.text", color: SchoolTheme.accent, text: $newDetail)

                            Picker("Категория", selection: $newCategory) {
                                ForEach(categories, id: \.self) { category in
                                    Text(category).tag(category)
                                }
                            }
                            .pickerStyle(.segmented)

                            Text(importStatus)
                                .font(.caption)
                                .foregroundStyle(SchoolTheme.muted)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            HStack(spacing: 10) {
                                Button {
                                    isFileImporterVisible = true
                                } label: {
                                    Label("Выбрать", systemImage: "paperclip")
                                        .frame(maxWidth: .infinity, minHeight: 44)
                                }
                                .buttonStyle(.bordered)
                                .tint(SchoolTheme.accent)

                                Button {
                                    addManualFile()
                                } label: {
                                    Label("Добавить", systemImage: "plus")
                                        .frame(maxWidth: .infinity, minHeight: 44)
                                }
                                .buttonStyle(.bordered)
                                .tint(SchoolTheme.success)
                                .disabled(newTitle.trimmed.isEmpty || newDetail.trimmed.isEmpty)
                            }
                        }
                    }

                    Button {
                        save()
                    } label: {
                        Label("Сохранить файлы", systemImage: "checkmark")
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
            .navigationTitle("Файлы")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        save()
                    }
                }
            }
            .fileImporter(
                isPresented: $isFileImporterVisible,
                allowedContentTypes: [.item],
                allowsMultipleSelection: true
            ) { result in
                handleFileImport(result)
            }
        }
    }

    private var filteredFiles: [ClassFileSummary] {
        let query = searchText.trimmed.lowercased()
        return files.filter { file in
            let matchesFilter = selectedFilter == "Все" || file.category == selectedFilter
            let searchableText = [file.title, file.detail, file.category, file.owner, file.status]
                .joined(separator: " ")
                .lowercased()
            let matchesSearch = query.isEmpty || searchableText.contains(query)
            return matchesFilter && matchesSearch
        }
    }

    private var actionNeededCount: Int {
        files.filter { file in
            file.status.contains("Нужно") || file.status.contains("Ожидает")
        }.count
    }

    private func fileRow(_ file: ClassFileSummary) -> some View {
        HStack(alignment: .top, spacing: 12) {
            IconBadge(systemName: file.iconName, color: moreColor(for: file.colorName), size: 42)
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 7) {
                    Text(file.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SchoolTheme.graphite)
                    StatusBadge(text: file.category, color: moreColor(for: file.colorName))
                }
                Text(file.detail)
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
                Text("\(file.owner) - \(file.updatedLabel)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SchoolTheme.muted)
                Text(file.status)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(statusColor(for: file.status))
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func addManualFile() {
        files.insert(
            ClassFileSummary(
                title: newTitle.trimmed,
                detail: newDetail.trimmed,
                category: newCategory,
                owner: "Владимир",
                updatedLabel: "сегодня",
                status: "Локально",
                iconName: iconName(for: newCategory),
                colorName: colorName(for: newCategory)
            ),
            at: 0
        )
        importStatus = "Добавлена запись: \(newTitle.trimmed)"
        newTitle = ""
        newDetail = ""
    }

    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard !urls.isEmpty else {
                importStatus = "Файл не выбран"
                return
            }

            for url in urls {
                files.insert(
                    ClassFileSummary(
                        title: url.lastPathComponent,
                        detail: "Добавлен через системный выбор файла",
                        category: newCategory,
                        owner: "Владимир",
                        updatedLabel: "сегодня",
                        status: "Локально",
                        iconName: iconName(for: newCategory),
                        colorName: colorName(for: newCategory)
                    ),
                    at: 0
                )
            }

            importStatus = "Добавлено файлов: \(urls.count)"
        case .failure:
            importStatus = "Не удалось добавить файл"
        }
    }

    private func iconName(for category: String) -> String {
        switch category {
        case "Чеки":
            "receipt.fill"
        case "Материалы":
            "photo.on.rectangle.angled"
        default:
            "doc.text.fill"
        }
    }

    private func colorName(for category: String) -> String {
        switch category {
        case "Чеки":
            "green"
        case "Материалы":
            "teal"
        default:
            "blue"
        }
    }

    private func statusColor(for status: String) -> Color {
        if status.contains("Нужно") || status.contains("Ожидает") {
            return SchoolTheme.warning
        }

        if status.contains("Проверено") || status.contains("Локально") {
            return SchoolTheme.success
        }

        return SchoolTheme.muted
    }

    private func save() {
        onSave(files)
        dismiss()
    }
}

private struct MoreEmptyState: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        VStack(spacing: 8) {
            IconBadge(systemName: icon, color: SchoolTheme.muted, size: 44)
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(SchoolTheme.graphite)
            Text(detail)
                .font(.caption)
                .foregroundStyle(SchoolTheme.muted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}

private struct NotificationPreferenceRow: View {
    @Binding var preference: NotificationPreference

    var body: some View {
        HStack(spacing: 12) {
            IconBadge(systemName: preference.iconName, color: moreColor(for: preference.colorName), size: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(preference.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite)
                Text(preference.detail)
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            Toggle("", isOn: $preference.isEnabled)
                .labelsHidden()
                .tint(SchoolTheme.success)
        }
    }
}

private struct MoreSheetHeader: View {
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

private struct MoreMetric: View {
    let value: String
    let title: String
    let color: Color

    var body: some View {
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
}

private struct MoreTextField: View {
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

private enum MoreSheet: String, Identifiable {
    case children
    case family
    case classes
    case subscription
    case notifications
    case memory
    case files

    var id: String { rawValue }
}

private struct MoreMenuItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    var sheet: MoreSheet?
}

private func moreColor(for colorName: String) -> Color {
    switch colorName {
    case "green":
        SchoolTheme.success
    case "teal":
        SchoolTheme.teal
    case "red":
        SchoolTheme.danger
    case "orange":
        SchoolTheme.warning
    default:
        SchoolTheme.accent
    }
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

#Preview {
    MoreView()
}
