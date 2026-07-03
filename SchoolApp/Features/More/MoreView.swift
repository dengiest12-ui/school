import SwiftUI

struct MoreView: View {
    @State private var children = SampleData.children
    @State private var familyMembers = SampleData.familyMembers
    @State private var classAccess = SampleData.classAccess
    @State private var notificationPreferences = SampleData.notificationPreferences
    @State private var subscriptionPlans = SampleData.subscriptionPlans
    @State private var activeSheet: MoreSheet?

    init() {
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
                }
            case .family:
                FamilyAccessSheet(members: familyMembers) { updatedMembers in
                    familyMembers = updatedMembers
                }
            case .classes:
                ClassesAccessSheet(classes: classAccess) { updatedClasses in
                    classAccess = updatedClasses
                }
            case .subscription:
                SubscriptionSheet(plans: subscriptionPlans) { updatedPlans in
                    subscriptionPlans = updatedPlans
                }
            case .notifications:
                NotificationSettingsSheet(preferences: notificationPreferences) { updatedPreferences in
                    notificationPreferences = updatedPreferences
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
            MoreMenuItem(title: "Память класса", subtitle: "Поиск по объявлениям и файлам", icon: "magnifyingglass", color: SchoolTheme.accent),
            MoreMenuItem(title: "Файлы", subtitle: "Согласия, чеки, материалы", icon: "folder.fill", color: SchoolTheme.teal)
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

    let onSave: ([NotificationPreference]) -> Void

    @State private var preferences: [NotificationPreference]
    @State private var eveningTime = "20:30"
    @State private var morningTime = "07:15"
    @State private var quietHoursEnabled = true
    @State private var quietStart = "22:00"
    @State private var quietEnd = "07:00"
    @State private var testStatus = "Тестовый дайджест не отправлялся"

    init(preferences: [NotificationPreference], onSave: @escaping ([NotificationPreference]) -> Void) {
        self.onSave = onSave
        _preferences = State(initialValue: preferences)
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
                            MoreMetric(value: eveningTime, title: "вечером", color: SchoolTheme.accent)
                            Divider()
                            MoreMetric(value: quietHoursEnabled ? "да" : "нет", title: "тихий режим", color: SchoolTheme.teal)
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
                            Picker("Вечер", selection: $eveningTime) {
                                Text("19:30").tag("19:30")
                                Text("20:30").tag("20:30")
                                Text("21:30").tag("21:30")
                            }
                            .pickerStyle(.segmented)

                            Text("Утро")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(SchoolTheme.muted)
                            Picker("Утро", selection: $morningTime) {
                                Text("07:00").tag("07:00")
                                Text("07:15").tag("07:15")
                                Text("07:30").tag("07:30")
                            }
                            .pickerStyle(.segmented)
                        }
                    }

                    DashboardCard {
                        VStack(spacing: 12) {
                            Toggle(isOn: $quietHoursEnabled) {
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
                                MoreTextField(title: "Начало", iconName: "moon.fill", color: SchoolTheme.teal, text: $quietStart)
                                MoreTextField(title: "Конец", iconName: "sunrise.fill", color: SchoolTheme.warning, text: $quietEnd)
                            }
                            .disabled(!quietHoursEnabled)
                            .opacity(quietHoursEnabled ? 1 : 0.45)
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
                                testStatus = "Готово: локальный дайджест собран на \(eveningTime)"
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
        onSave(preferences)
        dismiss()
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
