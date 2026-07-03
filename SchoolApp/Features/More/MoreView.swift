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

private struct SecuritySettingsState: Codable, Hashable {
    var closedClassOnly: Bool
    var maskFinanceForFamily: Bool
    var requireInviteApproval: Bool
    var deleteRequestStatus: String

    static let sample = SecuritySettingsState(
        closedClassOnly: true,
        maskFinanceForFamily: true,
        requireInviteApproval: true,
        deleteRequestStatus: "Запрос удаления не отправлялся"
    )
}

private struct PrivacySettingsState: Codable, Hashable {
    var minimalChildData: Bool
    var childDataConsent: Bool
    var privacyPolicyAccepted: Bool
    var consentStatus: String

    static let sample = PrivacySettingsState(
        minimalChildData: true,
        childDataConsent: false,
        privacyPolicyAccepted: false,
        consentStatus: "Согласие еще не подтверждено"
    )
}

private struct ParentProfileState: Codable, Hashable {
    var name: String
    var contact: String
    var appleID: String
    var roleSummary: String

    static let sample = ParentProfileState(
        name: "Владимир",
        contact: "+7 999 000-12-34",
        appleID: "vladimir@example.com",
        roleSummary: "Родитель Миши, 3Б"
    )
}

private struct FamilyTaskSummary: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var assignee: String
    var dueLabel: String
    var reminder: String
    var status: String

    init(
        id: UUID = UUID(),
        title: String,
        assignee: String,
        dueLabel: String,
        reminder: String,
        status: String = "Назначена"
    ) {
        self.id = id
        self.title = title
        self.assignee = assignee
        self.dueLabel = dueLabel
        self.reminder = reminder
        self.status = status
    }

    static let sample = [
        FamilyTaskSummary(title: "Подписать согласие на экскурсию", assignee: "Владимир", dueLabel: "Сегодня", reminder: "19:30"),
        FamilyTaskSummary(title: "Принести картон и клей", assignee: "Ирина", dueLabel: "Завтра", reminder: "08:00"),
        FamilyTaskSummary(title: "Оплатить сбор на театр", assignee: "Екатерина", dueLabel: "до пятницы", reminder: "20:00")
    ]
}

private struct AuditLogEntry: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var detail: String
    var actor: String
    var target: String
    var category: String
    var status: String
    var timestampLabel: String
    var iconName: String
    var colorName: String

    init(
        id: UUID = UUID(),
        title: String,
        detail: String,
        actor: String,
        target: String,
        category: String,
        status: String = "Локально",
        timestampLabel: String = "сейчас",
        iconName: String,
        colorName: String
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.actor = actor
        self.target = target
        self.category = category
        self.status = status
        self.timestampLabel = timestampLabel
        self.iconName = iconName
        self.colorName = colorName
    }

    static let sample = [
        AuditLogEntry(
            title: "Создан закрытый класс",
            detail: "Код 3B-742 включен только для приглашенных семей",
            actor: "Владимир",
            target: "3Б",
            category: "Доступ",
            status: "Проверено",
            timestampLabel: "сегодня 09:12",
            iconName: "lock.shield.fill",
            colorName: "green"
        ),
        AuditLogEntry(
            title: "Родителю ограничены финансы",
            detail: "Обычный родитель видит отчет, но не меняет оплаты и расходы",
            actor: "Система ролей",
            target: "Сбор на театр",
            category: "Роли",
            status: "Проверено",
            timestampLabel: "сегодня 10:35",
            iconName: "person.badge.shield.checkmark.fill",
            colorName: "blue"
        ),
        AuditLogEntry(
            title: "Жалоба на фото сохранена",
            detail: "Фото скрыто из спорных действий до подключения модерации",
            actor: "Екатерина",
            target: "Альбом 3Б",
            category: "Модерация",
            status: "Локально",
            timestampLabel: "вчера",
            iconName: "exclamationmark.shield.fill",
            colorName: "red"
        )
    ]
}

private struct MoreStoreSnapshot: Codable {
    var profile: ParentProfileState
    var children: [ChildSummary]
    var familyMembers: [FamilyAccessMember]
    var familyTasks: [FamilyTaskSummary]
    var classAccess: [ClassAccessSummary]
    var notificationPreferences: [NotificationPreference]
    var notificationSettings: NotificationSettingsState
    var subscriptionPlans: [SubscriptionPlanSummary]
    var classMemory: [ClassMemoryEntry]
    var classFiles: [ClassFileSummary]
    var securitySettings: SecuritySettingsState
    var auditEntries: [AuditLogEntry]
    var privacySettings: PrivacySettingsState

    init(
        profile: ParentProfileState = .sample,
        children: [ChildSummary],
        familyMembers: [FamilyAccessMember],
        familyTasks: [FamilyTaskSummary] = FamilyTaskSummary.sample,
        classAccess: [ClassAccessSummary],
        notificationPreferences: [NotificationPreference],
        notificationSettings: NotificationSettingsState = .sample,
        subscriptionPlans: [SubscriptionPlanSummary],
        classMemory: [ClassMemoryEntry],
        classFiles: [ClassFileSummary],
        securitySettings: SecuritySettingsState = .sample,
        auditEntries: [AuditLogEntry] = AuditLogEntry.sample,
        privacySettings: PrivacySettingsState = .sample
    ) {
        self.profile = profile
        self.children = children
        self.familyMembers = familyMembers
        self.familyTasks = familyTasks
        self.classAccess = classAccess
        self.notificationPreferences = notificationPreferences
        self.notificationSettings = notificationSettings
        self.subscriptionPlans = subscriptionPlans
        self.classMemory = classMemory
        self.classFiles = classFiles
        self.securitySettings = securitySettings
        self.auditEntries = auditEntries
        self.privacySettings = privacySettings
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        profile = try container.decodeIfPresent(ParentProfileState.self, forKey: .profile) ?? .sample
        children = try container.decode([ChildSummary].self, forKey: .children)
        familyMembers = try container.decode([FamilyAccessMember].self, forKey: .familyMembers)
        familyTasks = try container.decodeIfPresent([FamilyTaskSummary].self, forKey: .familyTasks) ?? FamilyTaskSummary.sample
        classAccess = try container.decode([ClassAccessSummary].self, forKey: .classAccess)
        notificationPreferences = try container.decode([NotificationPreference].self, forKey: .notificationPreferences)
        notificationSettings = try container.decodeIfPresent(NotificationSettingsState.self, forKey: .notificationSettings) ?? .sample
        subscriptionPlans = try container.decode([SubscriptionPlanSummary].self, forKey: .subscriptionPlans)
        classMemory = try container.decodeIfPresent([ClassMemoryEntry].self, forKey: .classMemory) ?? SampleData.classMemory
        classFiles = try container.decodeIfPresent([ClassFileSummary].self, forKey: .classFiles) ?? SampleData.classFiles
        securitySettings = try container.decodeIfPresent(SecuritySettingsState.self, forKey: .securitySettings) ?? .sample
        auditEntries = try container.decodeIfPresent([AuditLogEntry].self, forKey: .auditEntries) ?? AuditLogEntry.sample
        privacySettings = try container.decodeIfPresent(PrivacySettingsState.self, forKey: .privacySettings) ?? .sample
    }

    static let sample = MoreStoreSnapshot(
        profile: .sample,
        children: SampleData.children,
        familyMembers: SampleData.familyMembers,
        familyTasks: FamilyTaskSummary.sample,
        classAccess: SampleData.classAccess,
        notificationPreferences: SampleData.notificationPreferences,
        notificationSettings: .sample,
        subscriptionPlans: SampleData.subscriptionPlans,
        classMemory: SampleData.classMemory,
        classFiles: SampleData.classFiles,
        securitySettings: .sample,
        auditEntries: AuditLogEntry.sample,
        privacySettings: .sample
    )
}

private enum MoreLocalStore {
    private static let defaultsKey = "school.more.store.v1"
    private static var snapshot: MoreStoreSnapshot = load()

    static var profile: ParentProfileState {
        get { snapshot.profile }
        set {
            snapshot.profile = newValue
            save()
        }
    }

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

    static var familyTasks: [FamilyTaskSummary] {
        get { snapshot.familyTasks }
        set {
            snapshot.familyTasks = newValue
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

    static var securitySettings: SecuritySettingsState {
        get { snapshot.securitySettings }
        set {
            snapshot.securitySettings = newValue
            save()
        }
    }

    static var auditEntries: [AuditLogEntry] {
        get { snapshot.auditEntries }
        set {
            snapshot.auditEntries = newValue
            save()
        }
    }

    static var privacySettings: PrivacySettingsState {
        get { snapshot.privacySettings }
        set {
            snapshot.privacySettings = newValue
            save()
        }
    }

    static func recordAudit(_ entry: AuditLogEntry) {
        snapshot.auditEntries.insert(entry, at: 0)
        save()
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
    @State private var profile: ParentProfileState
    @State private var children: [ChildSummary]
    @State private var familyMembers: [FamilyAccessMember]
    @State private var familyTasks: [FamilyTaskSummary]
    @State private var classAccess: [ClassAccessSummary]
    @State private var notificationPreferences: [NotificationPreference]
    @State private var notificationSettings: NotificationSettingsState
    @State private var subscriptionPlans: [SubscriptionPlanSummary]
    @State private var classMemory: [ClassMemoryEntry]
    @State private var classFiles: [ClassFileSummary]
    @State private var securitySettings: SecuritySettingsState
    @State private var auditEntries: [AuditLogEntry]
    @State private var privacySettings: PrivacySettingsState
    @State private var activeSheet: MoreSheet?

    init() {
        MoreLocalStore.resetIfRequested()
        _profile = State(initialValue: MoreLocalStore.profile)
        _children = State(initialValue: MoreLocalStore.children)
        _familyMembers = State(initialValue: MoreLocalStore.familyMembers)
        _familyTasks = State(initialValue: MoreLocalStore.familyTasks)
        _classAccess = State(initialValue: MoreLocalStore.classAccess)
        _notificationPreferences = State(initialValue: MoreLocalStore.notificationPreferences)
        _notificationSettings = State(initialValue: MoreLocalStore.notificationSettings)
        _subscriptionPlans = State(initialValue: MoreLocalStore.subscriptionPlans)
        _classMemory = State(initialValue: MoreLocalStore.classMemory)
        _classFiles = State(initialValue: MoreLocalStore.classFiles)
        _securitySettings = State(initialValue: MoreLocalStore.securitySettings)
        _auditEntries = State(initialValue: MoreLocalStore.auditEntries)
        _privacySettings = State(initialValue: MoreLocalStore.privacySettings)
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
            case .profile:
                ParentProfileSheet(
                    profile: profile,
                    children: children,
                    familyMembers: familyMembers,
                    classAccess: classAccess
                ) { updatedProfile in
                    profile = updatedProfile
                    MoreLocalStore.profile = updatedProfile
                    recordAudit(
                        title: "Профиль обновлен",
                        detail: "Изменены контакт или роль родителя",
                        target: updatedProfile.roleSummary,
                        category: "Аккаунт",
                        iconName: "person.crop.circle.fill",
                        colorName: "blue"
                    )
                }
            case .children:
                ChildrenAccessSheet(children: children) { updatedChildren in
                    children = updatedChildren
                    MoreLocalStore.children = updatedChildren
                    recordAudit(
                        title: "Профили детей сохранены",
                        detail: "Всего профилей: \(updatedChildren.count)",
                        target: "Дети",
                        category: "Данные детей",
                        iconName: "person.crop.square",
                        colorName: "green"
                    )
                }
            case .family:
                FamilyAccessSheet(members: familyMembers) { updatedMembers in
                    familyMembers = updatedMembers
                    MoreLocalStore.familyMembers = updatedMembers
                    recordAudit(
                        title: "Семейный доступ обновлен",
                        detail: "Всего доступов: \(updatedMembers.count)",
                        target: "Семья",
                        category: "Доступ",
                        iconName: "person.2.fill",
                        colorName: "teal"
                    )
                }
            case .familyTasks:
                FamilyTasksSheet(profile: profile, members: familyMembers, tasks: familyTasks) { updatedTasks in
                    familyTasks = updatedTasks
                    MoreLocalStore.familyTasks = updatedTasks
                    recordAudit(
                        title: "Семейные задачи сохранены",
                        detail: "Активных задач: \(updatedTasks.filter { $0.status != "Готово" }.count)",
                        target: "Задачи семьи",
                        category: "Семья",
                        iconName: "checklist.checked",
                        colorName: "orange"
                    )
                }
            case .classes:
                ClassesAccessSheet(classes: classAccess) { updatedClasses in
                    classAccess = updatedClasses
                    MoreLocalStore.classAccess = updatedClasses
                    recordAudit(
                        title: "Доступ к классам обновлен",
                        detail: "Классов подключено: \(updatedClasses.count)",
                        target: "Классы",
                        category: "Доступ",
                        iconName: "building.2.fill",
                        colorName: "blue"
                    )
                }
            case .subscription:
                SubscriptionSheet(plans: subscriptionPlans) { updatedPlans in
                    subscriptionPlans = updatedPlans
                    MoreLocalStore.subscriptionPlans = updatedPlans
                    recordAudit(
                        title: "Подписка изменена",
                        detail: updatedPlans.first(where: \.isCurrent)?.title ?? "Тариф не выбран",
                        target: "Подписка",
                        category: "Оплата",
                        iconName: "creditcard.fill",
                        colorName: "orange"
                    )
                }
            case .notifications:
                NotificationSettingsSheet(preferences: notificationPreferences, settings: notificationSettings) { updatedPreferences, updatedSettings in
                    notificationPreferences = updatedPreferences
                    notificationSettings = updatedSettings
                    MoreLocalStore.notificationPreferences = updatedPreferences
                    MoreLocalStore.notificationSettings = updatedSettings
                    recordAudit(
                        title: "Уведомления сохранены",
                        detail: "Включено сценариев: \(updatedPreferences.filter(\.isEnabled).count)",
                        target: "Настройки",
                        category: "Уведомления",
                        iconName: "bell.fill",
                        colorName: "green"
                    )
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
                    recordAudit(
                        title: "Файлы класса обновлены",
                        detail: "Файлов в локальном архиве: \(updatedFiles.count)",
                        target: "Файлы",
                        category: "Файлы",
                        iconName: "folder.fill",
                        colorName: "teal"
                    )
                }
            case .security:
                SecuritySettingsSheet(settings: securitySettings) { updatedSettings in
                    securitySettings = updatedSettings
                    MoreLocalStore.securitySettings = updatedSettings
                    recordAudit(
                        title: "Настройки безопасности сохранены",
                        detail: "\(securityEnabledCount(updatedSettings)) защиты включено",
                        target: "Безопасность",
                        category: "Безопасность",
                        iconName: "lock.shield.fill",
                        colorName: "green"
                    )
                }
            case .audit:
                AuditLogSheet(entries: auditEntries) { updatedEntries in
                    auditEntries = updatedEntries
                    MoreLocalStore.auditEntries = updatedEntries
                }
            case .privacy:
                PrivacySettingsSheet(settings: privacySettings) { updatedSettings in
                    privacySettings = updatedSettings
                    MoreLocalStore.privacySettings = updatedSettings
                    recordAudit(
                        title: "Приватность сохранена",
                        detail: updatedSettings.consentStatus,
                        target: "Данные ребенка",
                        category: "Безопасность",
                        iconName: "hand.raised.fill",
                        colorName: "green"
                    )
                }
            case .support:
                SupportMessageSheet(kind: .support)
            case .problem:
                SupportMessageSheet(kind: .problem)
            case .logout:
                LogoutSheet()
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
            activeSheet = .profile
        } label: {
            DashboardCard {
                HStack(spacing: 14) {
                    InitialAvatar(text: String(profile.name.prefix(1)), color: SchoolTheme.accent, size: 58)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(profile.name)
                            .font(.headline)
                            .foregroundStyle(SchoolTheme.graphite)
                        Text(profile.roleSummary)
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
            MoreMenuItem(title: "Задачи семьи", subtitle: "\(openFamilyTaskCount) активных: назначение и напоминания", icon: "checklist.checked", color: SchoolTheme.warning, sheet: .familyTasks),
            MoreMenuItem(title: "Классы", subtitle: classAccess.map(\.title).joined(separator: " и "), icon: "building.2.fill", color: SchoolTheme.accent, sheet: .classes)
        ]
    }

    private var appItems: [MoreMenuItem] {
        [
            MoreMenuItem(title: "Подписка", subtitle: subscriptionSubtitle, icon: "creditcard.fill", color: SchoolTheme.warning, sheet: .subscription),
            MoreMenuItem(title: "Уведомления", subtitle: "\(enabledNotificationCount) включено: дайджесты, дедлайны, срочное", icon: "bell.fill", color: SchoolTheme.success, sheet: .notifications),
            MoreMenuItem(title: "Память класса", subtitle: "\(classMemory.count) находки: объявления, файлы, события", icon: "magnifyingglass", color: SchoolTheme.accent, sheet: .memory),
            MoreMenuItem(title: "Файлы", subtitle: "\(classFiles.count) файла: согласия, чеки, материалы", icon: "folder.fill", color: SchoolTheme.teal, sheet: .files),
            MoreMenuItem(title: "Журнал действий", subtitle: "\(auditEntries.count) записей: роли, доступы, файлы", icon: "list.bullet.rectangle.portrait.fill", color: SchoolTheme.graphite, sheet: .audit)
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

    private var openFamilyTaskCount: Int {
        familyTasks.filter { $0.status != "Готово" }.count
    }

    private var helpItems: [MoreMenuItem] {
        [
            MoreMenuItem(title: "Безопасность", subtitle: securitySubtitle, icon: "lock.shield.fill", color: SchoolTheme.success, sheet: .security),
            MoreMenuItem(title: "Приватность", subtitle: privacySubtitle, icon: "hand.raised.fill", color: SchoolTheme.teal, sheet: .privacy),
            MoreMenuItem(title: "Поддержка", subtitle: "Написать нам", icon: "message.fill", color: SchoolTheme.accent, sheet: .support),
            MoreMenuItem(title: "Проблема", subtitle: "Сообщить об ошибке", icon: "exclamationmark.bubble.fill", color: SchoolTheme.danger, sheet: .problem),
            MoreMenuItem(title: "Выйти", subtitle: "Локальный выход и перенос данных", icon: "rectangle.portrait.and.arrow.right", color: SchoolTheme.warning, sheet: .logout)
        ]
    }

    private var securitySubtitle: String {
        let enabledCount = [
            securitySettings.closedClassOnly,
            securitySettings.maskFinanceForFamily,
            securitySettings.requireInviteApproval
        ].filter { $0 }.count

        return "\(enabledCount) защиты: данные детей и доступы"
    }

    private var privacySubtitle: String {
        if privacySettings.childDataConsent && privacySettings.privacyPolicyAccepted {
            return "Согласие и политика подтверждены"
        }

        return "Нужно подтвердить согласие родителя"
    }

    private static func launchSheet() -> MoreSheet? {
        let arguments = ProcessInfo.processInfo.arguments

        if arguments.contains("-qa-more-profile") {
            return .profile
        }

        if arguments.contains("-qa-more-children") {
            return .children
        }

        if arguments.contains("-qa-more-family") {
            return .family
        }

        if arguments.contains("-qa-more-family-tasks") {
            return .familyTasks
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

        if arguments.contains("-qa-more-audit") {
            return .audit
        }

        if arguments.contains("-qa-more-security") {
            return .security
        }

        if arguments.contains("-qa-more-privacy") {
            return .privacy
        }

        if arguments.contains("-qa-more-support") {
            return .support
        }

        if arguments.contains("-qa-more-problem") {
            return .problem
        }

        if arguments.contains("-qa-more-logout") {
            return .logout
        }

        return nil
    }

    private func recordAudit(
        title: String,
        detail: String,
        target: String,
        category: String,
        iconName: String,
        colorName: String
    ) {
        let entry = AuditLogEntry(
            title: title,
            detail: detail,
            actor: profile.name,
            target: target,
            category: category,
            timestampLabel: "сейчас",
            iconName: iconName,
            colorName: colorName
        )
        auditEntries.insert(entry, at: 0)
        MoreLocalStore.recordAudit(entry)
    }

    private func securityEnabledCount(_ settings: SecuritySettingsState) -> Int {
        [
            settings.closedClassOnly,
            settings.maskFinanceForFamily,
            settings.requireInviteApproval
        ].filter { $0 }.count
    }
}

private struct ParentProfileSheet: View {
    @Environment(\.dismiss) private var dismiss

    let children: [ChildSummary]
    let familyMembers: [FamilyAccessMember]
    let classAccess: [ClassAccessSummary]
    let onSave: (ParentProfileState) -> Void

    @State private var profile: ParentProfileState

    init(
        profile: ParentProfileState,
        children: [ChildSummary],
        familyMembers: [FamilyAccessMember],
        classAccess: [ClassAccessSummary],
        onSave: @escaping (ParentProfileState) -> Void
    ) {
        self.children = children
        self.familyMembers = familyMembers
        self.classAccess = classAccess
        self.onSave = onSave
        _profile = State(initialValue: profile)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    MoreSheetHeader(
                        icon: "person.crop.circle.fill",
                        color: SchoolTheme.accent,
                        title: "Профиль родителя",
                        subtitle: "Контакт, роли в классах и семейные участники"
                    )

                    DashboardCard {
                        HStack(spacing: 12) {
                            MoreMetric(value: "\(children.count)", title: "детей", color: SchoolTheme.success)
                            Divider()
                            MoreMetric(value: "\(classAccess.count)", title: "класса", color: SchoolTheme.accent)
                            Divider()
                            MoreMetric(value: "\(familyMembers.count)", title: "семья", color: SchoolTheme.teal)
                        }
                        .frame(height: 62)
                    }

                    DashboardCard {
                        VStack(spacing: 12) {
                            MoreTextField(title: "Имя", iconName: "person.fill", color: SchoolTheme.accent, text: $profile.name)
                            MoreTextField(title: "Телефон", iconName: "phone.fill", color: SchoolTheme.success, text: $profile.contact)
                            MoreTextField(title: "Apple ID / email", iconName: "at", color: SchoolTheme.teal, text: $profile.appleID)
                            MoreTextField(title: "Роль", iconName: "person.badge.shield.checkmark.fill", color: SchoolTheme.warning, text: $profile.roleSummary)
                        }
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Роли в классах")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            ForEach(classAccess) { classItem in
                                profileInfoRow(
                                    icon: "person.3.fill",
                                    color: SchoolTheme.accent,
                                    title: "\(classItem.title), \(classItem.school)",
                                    detail: "\(classItem.role) - \(classItem.status)"
                                )
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Семья")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            ForEach(familyMembers.prefix(3)) { member in
                                profileInfoRow(
                                    icon: "person.2.fill",
                                    color: SchoolTheme.teal,
                                    title: member.name,
                                    detail: "\(member.role) - \(member.access)"
                                )
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button {
                        save()
                    } label: {
                        Label("Сохранить профиль", systemImage: "checkmark")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 52)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(SchoolTheme.success)
                    .disabled(profile.name.trimmed.isEmpty || profile.contact.trimmed.isEmpty)
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        save()
                    }
                }
                KeyboardDoneToolbar()
            }
        }
    }

    private func profileInfoRow(icon: String, color: Color, title: String, detail: String) -> some View {
        HStack(spacing: 12) {
            IconBadge(systemName: icon, color: color, size: 40)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite)
                    .fixedSize(horizontal: false, vertical: true)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
    }

    private func save() {
        onSave(profile)
        dismiss()
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
            .scrollDismissesKeyboard(.interactively)
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Дети")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        save()
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

private struct FamilyTasksSheet: View {
    @Environment(\.dismiss) private var dismiss

    let profile: ParentProfileState
    let members: [FamilyAccessMember]
    let onSave: ([FamilyTaskSummary]) -> Void

    @State private var tasks: [FamilyTaskSummary]
    @State private var title = "Забрать согласие из портфеля"
    @State private var dueLabel = "Сегодня"
    @State private var reminder = "19:30"
    @State private var assignee: String

    init(
        profile: ParentProfileState,
        members: [FamilyAccessMember],
        tasks: [FamilyTaskSummary],
        onSave: @escaping ([FamilyTaskSummary]) -> Void
    ) {
        self.profile = profile
        self.members = members
        self.onSave = onSave
        _tasks = State(initialValue: tasks)
        _assignee = State(initialValue: members.first?.name ?? profile.name)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    MoreSheetHeader(
                        icon: "checklist.checked",
                        color: SchoolTheme.warning,
                        title: "Задачи семьи",
                        subtitle: "Назначение, персональные напоминания и передача"
                    )

                    DashboardCard {
                        HStack(spacing: 12) {
                            MoreMetric(value: "\(openTasks.count)", title: "активных", color: SchoolTheme.warning)
                            Divider()
                            MoreMetric(value: "\(myTasks.count)", title: "моих", color: SchoolTheme.success)
                            Divider()
                            MoreMetric(value: "\(tasks.filter { $0.status == "Готово" }.count)", title: "готово", color: SchoolTheme.accent)
                        }
                        .frame(height: 62)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Список задач")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            if tasks.isEmpty {
                                emptyTaskRow
                            } else {
                                ForEach(tasks) { task in
                                    taskRow(task)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    DashboardCard {
                        VStack(spacing: 12) {
                            assigneeMenu
                            MoreTextField(title: "Задача", iconName: "text.badge.plus", color: SchoolTheme.warning, text: $title)
                            MoreTextField(title: "Срок", iconName: "calendar", color: SchoolTheme.accent, text: $dueLabel)
                            MoreTextField(title: "Напоминание", iconName: "bell.fill", color: SchoolTheme.success, text: $reminder)

                            Button {
                                addTask()
                            } label: {
                                Label("Назначить задачу", systemImage: "plus")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity, minHeight: 46)
                            }
                            .buttonStyle(.bordered)
                            .tint(SchoolTheme.warning)
                            .disabled(title.trimmed.isEmpty || assignee.trimmed.isEmpty)
                        }
                    }

                    Button {
                        save()
                    } label: {
                        Label("Сохранить задачи", systemImage: "checkmark")
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
            .navigationTitle("Задачи")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        save()
                    }
                }
                KeyboardDoneToolbar()
            }
        }
    }

    private var openTasks: [FamilyTaskSummary] {
        tasks.filter { $0.status != "Готово" }
    }

    private var myTasks: [FamilyTaskSummary] {
        tasks.filter { $0.assignee == profile.name && $0.status != "Готово" }
    }

    private var emptyTaskRow: some View {
        HStack(spacing: 12) {
            IconBadge(systemName: "checkmark.seal.fill", color: SchoolTheme.success, size: 40)
            Text("Семейных задач пока нет")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(SchoolTheme.muted)
            Spacer()
        }
    }

    private var assigneeMenu: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Исполнитель")
                .font(.caption.weight(.semibold))
                .foregroundStyle(SchoolTheme.muted)

            Menu {
                ForEach(memberNames, id: \.self) { memberName in
                    Button(memberName) {
                        assignee = memberName
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    IconBadge(systemName: "person.fill", color: SchoolTheme.teal, size: 38)
                    Text(assignee)
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

    private var memberNames: [String] {
        let names = members.map(\.name)
        return names.contains(profile.name) ? names : [profile.name] + names
    }

    private func taskRow(_ task: FamilyTaskSummary) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                IconBadge(
                    systemName: task.status == "Готово" ? "checkmark.circle.fill" : "bell.fill",
                    color: task.status == "Готово" ? SchoolTheme.success : SchoolTheme.warning,
                    size: 40
                )

                VStack(alignment: .leading, spacing: 5) {
                    Text(task.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(task.status == "Готово" ? SchoolTheme.muted : SchoolTheme.graphite)
                        .strikethrough(task.status == "Готово", color: SchoolTheme.muted)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    StatusBadge(text: task.status, color: task.status == "Готово" ? SchoolTheme.success : SchoolTheme.warning)

                    Text("\(task.assignee) - \(task.dueLabel)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(SchoolTheme.graphite)
                    Text("Персональное напоминание для \(task.assignee): \(task.reminder)")
                        .font(.caption)
                        .foregroundStyle(SchoolTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)
            }

            HStack(spacing: 8) {
                Button {
                    assignToMe(task)
                } label: {
                    TaskActionButtonLabel(title: "Я сделаю", systemImage: "person.fill")
                }
                .buttonStyle(.bordered)
                .tint(SchoolTheme.success)
                .disabled(task.status == "Готово")

                Button {
                    transfer(task)
                } label: {
                    TaskActionButtonLabel(title: "Передать", systemImage: "arrow.right.circle.fill")
                }
                .buttonStyle(.bordered)
                .tint(SchoolTheme.accent)
                .disabled(task.status == "Готово")

                Button {
                    complete(task)
                } label: {
                    TaskActionButtonLabel(title: "Готово", systemImage: "checkmark")
                }
                .buttonStyle(.borderedProminent)
                .tint(SchoolTheme.success)
                .disabled(task.status == "Готово")
            }
        }
        .padding(12)
        .background(SchoolTheme.surface, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(SchoolTheme.line, lineWidth: 1)
        }
    }

    private func addTask() {
        tasks.insert(
            FamilyTaskSummary(
                title: title.trimmed,
                assignee: assignee,
                dueLabel: dueLabel.trimmed.isEmpty ? "Сегодня" : dueLabel.trimmed,
                reminder: reminder.trimmed.isEmpty ? "19:30" : reminder.trimmed
            ),
            at: 0
        )
        title = ""
    }

    private func assignToMe(_ task: FamilyTaskSummary) {
        update(task) { item in
            item.assignee = profile.name
            item.status = "Я сделаю"
        }
    }

    private func transfer(_ task: FamilyTaskSummary) {
        guard let currentIndex = memberNames.firstIndex(of: task.assignee) else {
            update(task) { item in
                item.assignee = memberNames.first ?? profile.name
                item.status = "Передана"
            }
            return
        }

        let nextIndex = memberNames.index(after: currentIndex) == memberNames.endIndex ? memberNames.startIndex : memberNames.index(after: currentIndex)
        update(task) { item in
            item.assignee = memberNames[nextIndex]
            item.status = "Передана"
        }
    }

    private func complete(_ task: FamilyTaskSummary) {
        update(task) { item in
            item.status = "Готово"
        }
    }

    private func update(_ task: FamilyTaskSummary, mutation: (inout FamilyTaskSummary) -> Void) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else {
            return
        }

        mutation(&tasks[index])
        onSave(tasks)
    }

    private func save() {
        onSave(tasks)
        dismiss()
    }
}

private struct TaskActionButtonLabel: View {
    let title: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: systemImage)
                .font(.caption.weight(.bold))
            Text(title)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .allowsTightening(true)
        }
        .frame(maxWidth: .infinity, minHeight: 36)
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
                .scrollDismissesKeyboard(.interactively)
                .background(SchoolTheme.page.ignoresSafeArea())
                .navigationTitle("Семья")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Закрыть") {
                            save()
                        }
                    }
                    KeyboardDoneToolbar()
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
            .scrollDismissesKeyboard(.interactively)
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Классы")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        save()
                    }
                }
                KeyboardDoneToolbar()
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
            .scrollDismissesKeyboard(.interactively)
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Уведомления")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        save()
                    }
                }
                KeyboardDoneToolbar()
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
            .scrollDismissesKeyboard(.interactively)
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Память класса")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        save()
                    }
                }
                KeyboardDoneToolbar()
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
            .scrollDismissesKeyboard(.interactively)
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Файлы")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        save()
                    }
                }
                KeyboardDoneToolbar()
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

private struct SecuritySettingsSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: (SecuritySettingsState) -> Void

    @State private var settings: SecuritySettingsState

    init(settings: SecuritySettingsState, onSave: @escaping (SecuritySettingsState) -> Void) {
        self.onSave = onSave
        _settings = State(initialValue: settings)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    MoreSheetHeader(
                        icon: "lock.shield.fill",
                        color: SchoolTheme.success,
                        title: "Безопасность",
                        subtitle: "Данные детей, закрытый класс и семейные доступы"
                    )

                    DashboardCard {
                        HStack(spacing: 12) {
                            MoreMetric(value: "\(enabledCount)", title: "защиты", color: SchoolTheme.success)
                            Divider()
                            MoreMetric(value: settings.closedClassOnly ? "да" : "нет", title: "закрытый", color: SchoolTheme.accent)
                            Divider()
                            MoreMetric(value: settings.requireInviteApproval ? "да" : "нет", title: "входы", color: SchoolTheme.teal)
                        }
                        .frame(height: 62)
                    }

                    DashboardCard {
                        VStack(spacing: 14) {
                            securityToggle(
                                title: "Только участники класса",
                                detail: "Материалы и файлы видят только подключенные семьи",
                                icon: "person.3.fill",
                                color: SchoolTheme.success,
                                isOn: $settings.closedClassOnly
                            )

                            Divider()

                            securityToggle(
                                title: "Скрывать финансы",
                                detail: "Бабушка и няня видят задачи без сумм сборов",
                                icon: "rublesign.circle.fill",
                                color: SchoolTheme.warning,
                                isOn: $settings.maskFinanceForFamily
                            )

                            Divider()

                            securityToggle(
                                title: "Подтверждать входы",
                                detail: "Новые приглашения ждут одобрения администратора",
                                icon: "checkmark.shield.fill",
                                color: SchoolTheme.accent,
                                isOn: $settings.requireInviteApproval
                            )
                        }
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Удаление данных")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)
                            Text(settings.deleteRequestStatus)
                                .font(.caption)
                                .foregroundStyle(SchoolTheme.muted)

                            Button {
                                settings.deleteRequestStatus = "Запрос удаления подготовлен локально: подтвердить можно после подключения аккаунта"
                            } label: {
                                Label("Подготовить удаление данных", systemImage: "trash.fill")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity, minHeight: 44)
                            }
                            .buttonStyle(.bordered)
                            .tint(SchoolTheme.danger)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button {
                        save()
                    } label: {
                        Label("Сохранить безопасность", systemImage: "checkmark")
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
            .navigationTitle("Безопасность")
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
        [
            settings.closedClassOnly,
            settings.maskFinanceForFamily,
            settings.requireInviteApproval
        ].filter { $0 }.count
    }

    private func securityToggle(
        title: String,
        detail: String,
        icon: String,
        color: Color,
        isOn: Binding<Bool>
    ) -> some View {
        Toggle(isOn: isOn) {
            HStack(spacing: 12) {
                IconBadge(systemName: icon, color: color, size: 42)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SchoolTheme.graphite)
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(SchoolTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .tint(SchoolTheme.success)
    }

    private func save() {
        onSave(settings)
        dismiss()
    }
}

private struct AuditLogSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: ([AuditLogEntry]) -> Void

    @State private var entries: [AuditLogEntry]
    @State private var selectedCategory = "Все"

    init(entries: [AuditLogEntry], onSave: @escaping ([AuditLogEntry]) -> Void) {
        self.onSave = onSave
        _entries = State(initialValue: entries)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    MoreSheetHeader(
                        icon: "list.bullet.rectangle.portrait.fill",
                        color: SchoolTheme.graphite,
                        title: "Журнал действий",
                        subtitle: "Роли, доступы, файлы и важные изменения класса"
                    )

                    DashboardCard {
                        HStack(spacing: 12) {
                            MoreMetric(value: "\(entries.count)", title: "записей", color: SchoolTheme.accent)
                            Divider()
                            MoreMetric(value: "\(localCount)", title: "локально", color: SchoolTheme.warning)
                            Divider()
                            MoreMetric(value: "\(verifiedCount)", title: "проверено", color: SchoolTheme.success)
                        }
                        .frame(height: 62)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Фильтр")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(categories, id: \.self) { category in
                                        Button {
                                            selectedCategory = category
                                        } label: {
                                            Text(category)
                                                .font(.caption.weight(.semibold))
                                                .foregroundStyle(selectedCategory == category ? .white : SchoolTheme.graphite)
                                                .lineLimit(1)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .background(
                                                    selectedCategory == category ? SchoolTheme.accent : SchoolTheme.page,
                                                    in: Capsule()
                                                )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("Последние действия")
                                    .font(.headline)
                                    .foregroundStyle(SchoolTheme.graphite)
                                Spacer()
                                Button {
                                    addControlCheckpoint()
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundStyle(SchoolTheme.accent)
                                        .frame(width: 34, height: 34)
                                        .background(SchoolTheme.accent.opacity(0.10), in: Circle())
                                }
                                .accessibilityLabel("Добавить контрольную запись")
                            }

                            if filteredEntries.isEmpty {
                                MoreEmptyState(
                                    icon: "checkmark.shield.fill",
                                    title: "Записей нет",
                                    detail: "Для этого фильтра пока не было действий"
                                )
                            } else {
                                ForEach(filteredEntries) { entry in
                                    auditRow(entry)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Серверный AuditLog подключается следующим этапом", systemImage: "server.rack")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(SchoolTheme.graphite)
                            Text("Сейчас журнал сохраняется на устройстве и показывает UX-сценарий: кто изменил доступ, файл, безопасность или семейную задачу. Для продакшена эти записи должны уходить на backend и быть защищены от ручного изменения.")
                                .font(.caption)
                                .foregroundStyle(SchoolTheme.muted)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Журнал")
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

    private var categories: [String] {
        ["Все"] + Array(Set(entries.map(\.category))).sorted()
    }

    private var filteredEntries: [AuditLogEntry] {
        entries.filter { entry in
            selectedCategory == "Все" || entry.category == selectedCategory
        }
    }

    private var localCount: Int {
        entries.filter { $0.status == "Локально" }.count
    }

    private var verifiedCount: Int {
        entries.filter { $0.status == "Проверено" }.count
    }

    private func auditRow(_ entry: AuditLogEntry) -> some View {
        HStack(alignment: .top, spacing: 12) {
            IconBadge(systemName: entry.iconName, color: moreColor(for: entry.colorName), size: 42)
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 7) {
                    Text(entry.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SchoolTheme.graphite)
                        .fixedSize(horizontal: false, vertical: true)
                    StatusBadge(text: entry.category, color: moreColor(for: entry.colorName))
                }

                Text(entry.detail)
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)

                Text("\(entry.actor) - \(entry.target)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite.opacity(0.72))

                HStack(spacing: 8) {
                    Text(entry.timestampLabel)
                        .font(.caption)
                        .foregroundStyle(SchoolTheme.muted)
                    Text(entry.status)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(entry.status == "Проверено" ? SchoolTheme.success : SchoolTheme.warning)
                }
            }
            Spacer()
        }
        .padding(.vertical, 2)
    }

    private func addControlCheckpoint() {
        entries.insert(
            AuditLogEntry(
                title: "Контрольная проверка",
                detail: "Администратор открыл журнал и сверил локальные записи",
                actor: "Владимир",
                target: "AuditLog",
                category: "Безопасность",
                status: "Локально",
                timestampLabel: "сейчас",
                iconName: "checkmark.shield.fill",
                colorName: "green"
            ),
            at: 0
        )
    }

    private func save() {
        onSave(entries)
        dismiss()
    }
}

private struct PrivacySettingsSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: (PrivacySettingsState) -> Void

    @State private var settings: PrivacySettingsState

    init(settings: PrivacySettingsState, onSave: @escaping (PrivacySettingsState) -> Void) {
        self.onSave = onSave
        _settings = State(initialValue: settings)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    MoreSheetHeader(
                        icon: "hand.raised.fill",
                        color: SchoolTheme.teal,
                        title: "Приватность",
                        subtitle: "Минимум данных ребенка, согласие родителя и правила хранения"
                    )

                    DashboardCard {
                        HStack(spacing: 12) {
                            MoreMetric(value: settings.minimalChildData ? "да" : "нет", title: "минимум", color: SchoolTheme.success)
                            Divider()
                            MoreMetric(value: settings.childDataConsent ? "да" : "нет", title: "согласие", color: settings.childDataConsent ? SchoolTheme.success : SchoolTheme.warning)
                            Divider()
                            MoreMetric(value: settings.privacyPolicyAccepted ? "да" : "нет", title: "политика", color: settings.privacyPolicyAccepted ? SchoolTheme.success : SchoolTheme.warning)
                        }
                        .frame(height: 62)
                    }

                    DashboardCard {
                        VStack(spacing: 14) {
                            privacyToggle(
                                title: "Собирать минимум данных",
                                detail: "Имя ребенка, класс и школьные связи без лишних персональных полей",
                                icon: "person.text.rectangle.fill",
                                color: SchoolTheme.success,
                                isOn: $settings.minimalChildData
                            )

                            Divider()

                            privacyToggle(
                                title: "Согласие родителя",
                                detail: "Для работы класса и семьи",
                                icon: "checkmark.seal.fill",
                                color: SchoolTheme.accent,
                                isOn: $settings.childDataConsent
                            )

                            Divider()

                            privacyToggle(
                                title: "Политика конфиденциальности",
                                detail: "Какие данные нужны и зачем",
                                icon: "doc.text.fill",
                                color: SchoolTheme.teal,
                                isOn: $settings.privacyPolicyAccepted
                            )
                        }
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Кратко о данных")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)
                            privacyRule("Профиль ребенка", "имя, класс, школа и связи с семьей")
                            privacyRule("Учебные данные", "домашние задания, события, файлы и отметки семьи")
                            privacyRule("Финансы класса", "сборы и чеки видны по ролям, без банковских данных")
                            privacyRule("Удаление", "запрос удаления готовится в безопасности аккаунта")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Статус", systemImage: "checkmark.shield.fill")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)
                            Text(settings.consentStatus)
                                .font(.caption)
                                .foregroundStyle(SchoolTheme.muted)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button {
                        save()
                    } label: {
                        Label("Сохранить приватность", systemImage: "checkmark")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 52)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(SchoolTheme.success)
                    .disabled(!settings.minimalChildData)
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Приватность")
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

    private func privacyToggle(
        title: String,
        detail: String,
        icon: String,
        color: Color,
        isOn: Binding<Bool>
    ) -> some View {
        Toggle(isOn: isOn) {
            HStack(spacing: 12) {
                IconBadge(systemName: icon, color: color, size: 42)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SchoolTheme.graphite)
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(SchoolTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .tint(SchoolTheme.success)
    }

    private func privacyRule(_ title: String, _ detail: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(SchoolTheme.success)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
    }

    private func save() {
        if settings.childDataConsent && settings.privacyPolicyAccepted {
            settings.consentStatus = "Согласие и политика подтверждены локально"
        } else if settings.childDataConsent {
            settings.consentStatus = "Согласие есть, но политика еще не подтверждена"
        } else {
            settings.consentStatus = "Согласие еще не подтверждено"
        }

        onSave(settings)
        dismiss()
    }
}

private struct SupportMessageSheet: View {
    @Environment(\.dismiss) private var dismiss

    let kind: SupportMessageKind

    @State private var subject: String
    @State private var message: String
    @State private var contact = "Telegram или email"
    @State private var sendStatus = "Черновик не отправлялся"

    init(kind: SupportMessageKind) {
        self.kind = kind
        _subject = State(initialValue: kind.defaultSubject)
        _message = State(initialValue: kind.defaultMessage)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    MoreSheetHeader(
                        icon: kind.icon,
                        color: kind.color,
                        title: kind.title,
                        subtitle: kind.subtitle
                    )

                    DashboardCard {
                        VStack(spacing: 12) {
                            MoreTextField(title: "Тема", iconName: "text.badge.plus", color: kind.color, text: $subject)
                            MoreTextField(title: "Сообщение", iconName: "text.alignleft", color: SchoolTheme.accent, text: $message)
                            MoreTextField(title: "Контакт", iconName: "at", color: SchoolTheme.teal, text: $contact)
                        }
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Статус")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)
                            Text(sendStatus)
                                .font(.caption)
                                .foregroundStyle(SchoolTheme.muted)

                            Button {
                                sendStatus = "Готово: обращение сохранено локально для отправки после подключения поддержки"
                            } label: {
                                Label(kind.actionTitle, systemImage: kind.actionIcon)
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity, minHeight: 44)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(kind.color)
                            .disabled(subject.trimmed.isEmpty || message.trimmed.isEmpty)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle(kind.title)
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

private struct LogoutSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var transferStatus = "Перенос данных не подготовлен"

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    MoreSheetHeader(
                        icon: "rectangle.portrait.and.arrow.right",
                        color: SchoolTheme.warning,
                        title: "Выйти",
                        subtitle: "Локальный профиль, перенос данных и смена класса"
                    )

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 14) {
                            logoutRow(
                                icon: "person.crop.circle.badge.checkmark",
                                color: SchoolTheme.success,
                                title: "Владимир",
                                detail: "Родитель Миши, 3Б"
                            )
                            logoutRow(
                                icon: "externaldrive.fill",
                                color: SchoolTheme.accent,
                                title: "Локальные данные",
                                detail: "ДЗ, календарь, сборы, файлы и настройки хранятся на устройстве"
                            )
                            logoutRow(
                                icon: "icloud.and.arrow.up.fill",
                                color: SchoolTheme.teal,
                                title: "Перенос",
                                detail: transferStatus
                            )
                        }
                    }

                    HStack(spacing: 10) {
                        Button {
                            transferStatus = "Пакет переноса подготовлен локально"
                        } label: {
                            Label("Подготовить", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .buttonStyle(.bordered)
                        .tint(SchoolTheme.accent)

                        Button {
                            dismiss()
                        } label: {
                            Label("Остаться", systemImage: "checkmark")
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(SchoolTheme.success)
                    }
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Выйти")
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

    private func logoutRow(icon: String, color: Color, title: String, detail: String) -> some View {
        HStack(spacing: 12) {
            IconBadge(systemName: icon, color: color, size: 42)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
    }
}

private enum SupportMessageKind {
    case support
    case problem

    var title: String {
        switch self {
        case .support:
            "Поддержка"
        case .problem:
            "Проблема"
        }
    }

    var subtitle: String {
        switch self {
        case .support:
            "Вопрос по классу, семье или подписке"
        case .problem:
            "Ошибка, потерянное состояние или странное поведение"
        }
    }

    var icon: String {
        switch self {
        case .support:
            "message.fill"
        case .problem:
            "exclamationmark.bubble.fill"
        }
    }

    var color: Color {
        switch self {
        case .support:
            SchoolTheme.accent
        case .problem:
            SchoolTheme.danger
        }
    }

    var actionTitle: String {
        switch self {
        case .support:
            "Сохранить обращение"
        case .problem:
            "Сохранить отчет"
        }
    }

    var actionIcon: String {
        switch self {
        case .support:
            "paperplane.fill"
        case .problem:
            "exclamationmark.triangle.fill"
        }
    }

    var defaultSubject: String {
        switch self {
        case .support:
            "Вопрос по приложению"
        case .problem:
            "Ошибка в приложении"
        }
    }

    var defaultMessage: String {
        switch self {
        case .support:
            "Хочу уточнить по настройкам класса и семейного доступа."
        case .problem:
            "Опишите, где возникла проблема и что нажимали перед этим."
        }
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
    case profile
    case children
    case family
    case familyTasks
    case classes
    case subscription
    case notifications
    case memory
    case files
    case audit
    case security
    case privacy
    case support
    case problem
    case logout

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
