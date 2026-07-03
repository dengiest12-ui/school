import SwiftUI
import UIKit

private enum ClassRoomLocalStore {
    static var feedItems = SampleData.feed
    static var collections = SampleData.collections
    static var chatThreads = SampleData.chatThreads
    static var digestItems = SampleData.chatDigestItems
    static var members = SampleData.classMembers
}

struct ClassRoomView: View {
    let userRole: AppUserRole

    @State private var selectedSection: ClassSection
    @State private var feedItems: [FeedItem]
    @State private var collections: [CollectionSummary]
    @State private var chatThreads: [ChatThread]
    @State private var digestItems: [ChatDigestItem]
    @State private var members: [ClassMemberSummary]
    @State private var activeSheet: ClassRoomSheet?

    init(userRole: AppUserRole = .parent) {
        self.userRole = userRole
        let launchSheet = ClassRoomView.launchSheet()
        _selectedSection = State(initialValue: launchSheet?.preferredSection ?? ClassRoomView.launchSection())
        _feedItems = State(initialValue: ClassRoomLocalStore.feedItems)
        _collections = State(initialValue: ClassRoomLocalStore.collections)
        _chatThreads = State(initialValue: ClassRoomLocalStore.chatThreads)
        _digestItems = State(initialValue: ClassRoomLocalStore.digestItems)
        _members = State(initialValue: ClassRoomLocalStore.members)
        _activeSheet = State(initialValue: launchSheet)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                header
                classSummary
                sectionPicker
                selectedContent
            }
            .padding(.horizontal, 20)
            .padding(.top, 22)
            .padding(.bottom, SchoolTheme.bottomScrollPadding)
        }
        .background(SchoolTheme.page.ignoresSafeArea())
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .addCollection:
                if userRole.canManageCollections {
                    AddCollectionSheet { collection in
                        collections.insert(collection, at: 0)
                        ClassRoomLocalStore.collections = collections
                        selectedSection = .collections
                    }
                } else {
                    BlockedClassActionSheet(
                        icon: "rublesign.circle.fill",
                        title: "Создание сбора закрыто",
                        detail: "Сборы создает и ведет родкомитет. Родитель может смотреть отчет и отметить оплату своей семьи."
                    )
                }
            case .collectionDetail(let collection):
                CollectionDetailSheet(collection: collection, userRole: userRole) { updatedCollection in
                    updateCollection(updatedCollection)
                }
            case .chatDetail(let thread):
                ChatDetailSheet(thread: thread) { updatedThread in
                    updateChatThread(updatedThread)
                }
            case .digestDetail:
                ChatDigestSheet(items: digestItems) { updatedItems in
                    digestItems = updatedItems
                    ClassRoomLocalStore.digestItems = updatedItems
                }
            case .announcementDetail(let item):
                AnnouncementDetailSheet(item: item) { updatedItem in
                    updateFeedItem(updatedItem)
                }
            case .newAnnouncement:
                if userRole.canPublishAnnouncements {
                    NewAnnouncementSheet { item in
                        feedItems.insert(item, at: 0)
                        ClassRoomLocalStore.feedItems = feedItems
                        selectedSection = .feed
                    }
                } else {
                    BlockedClassActionSheet(
                        icon: "megaphone.fill",
                        title: "Публикация закрыта",
                        detail: "Объявления публикуют учитель и родкомитет. Родитель может читать и подтверждать прочтение."
                    )
                }
            case .inviteMembers:
                if userRole.canInviteMembers {
                    InviteMembersSheet(members: members) { updatedMembers in
                        members = updatedMembers
                        ClassRoomLocalStore.members = updatedMembers
                        selectedSection = .members
                    }
                } else {
                    BlockedClassActionSheet(
                        icon: "person.badge.plus",
                        title: "Приглашения закрыты",
                        detail: "Участников приглашает администратор класса, учитель или родкомитет."
                    )
                }
            }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Класс 3Б")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(SchoolTheme.graphite)
                Text("Лента, чаты, сборы и материалы")
                    .font(.subheadline)
                    .foregroundStyle(SchoolTheme.muted)
            }

            Spacer()

            HeaderIconButton(systemName: "magnifyingglass")
                .accessibilityLabel("Поиск")
            if canUseHeaderCreateAction {
                HeaderIconButton(systemName: "plus") {
                    openCreateAction()
                }
                .accessibilityLabel("Добавить")
            }
        }
    }

    private var classSummary: some View {
        DashboardCard {
            HStack(spacing: 14) {
                IconBadge(systemName: "person.3.fill", color: SchoolTheme.success, size: 52)
                VStack(alignment: .leading, spacing: 4) {
                    Text("25 родителей подключены")
                        .font(.headline)
                        .foregroundStyle(SchoolTheme.graphite)
                    Text("Сегодня: \(feedItems.count) объявления, \(activeDigestCount) задачи, \(collectionCountText)")
                        .font(.subheadline)
                        .foregroundStyle(SchoolTheme.muted)
                }
                Spacer()
            }
        }
    }

    private var sectionPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ClassSection.allCases) { section in
                    Button {
                        selectedSection = section
                    } label: {
                        Text(section.title)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(selectedSection == section ? SchoolTheme.graphite : SchoolTheme.muted)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                            .padding(.horizontal, 9)
                            .frame(height: 38)
                            .background(
                                selectedSection == section ? SchoolTheme.card : Color.clear,
                                in: Capsule()
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(4)
            .background(Color.black.opacity(0.055), in: Capsule())
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var selectedContent: some View {
        switch selectedSection {
        case .feed:
            feedContent
        case .chats:
            chatContent
        case .collections:
            collectionsContent
        case .photos:
            photosContent
        case .members:
            membersContent
        }
    }

    private var feedContent: some View {
        VStack(spacing: 12) {
            ForEach(feedItems) { item in
                DashboardCard {
                    VStack(alignment: .leading, spacing: 10) {
                        StatusBadge(text: item.tag, color: badgeColor(for: item.tag))
                        Text(item.title)
                            .font(.headline)
                            .foregroundStyle(SchoolTheme.graphite)
                        Text(item.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(SchoolTheme.muted)
                        HStack {
                            Button("Открыть") {
                                activeSheet = .announcementDetail(item)
                            }
                                .buttonStyle(.bordered)
                            Button("Напомнить") {
                                activeSheet = .newAnnouncement
                            }
                                .buttonStyle(.borderless)
                                .disabled(!userRole.canPublishAnnouncements)
                            Spacer()
                        }
                        .font(.subheadline.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private var chatContent: some View {
        VStack(spacing: 12) {
            Button {
                activeSheet = .digestDetail
            } label: {
                digestCard
            }
            .buttonStyle(.plain)

            ForEach(chatThreads) { thread in
                Button {
                    activeSheet = .chatDetail(thread)
                } label: {
                    chatThreadCard(thread)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var digestCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    IconBadge(systemName: "sparkles", color: SchoolTheme.accent)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Тихий чат")
                            .font(.headline)
                            .foregroundStyle(SchoolTheme.graphite)
                        Text("Важное за день без лишнего шума")
                            .font(.subheadline)
                            .foregroundStyle(SchoolTheme.muted)
                    }
                    Spacer()
                    InfoPill(text: "\(activeDigestCount) дела", color: SchoolTheme.accent)
                }

                VStack(spacing: 10) {
                    ForEach(digestItems.prefix(3)) { item in
                        HStack(spacing: 10) {
                            Image(systemName: item.isDone ? "checkmark.circle.fill" : item.iconName)
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(item.isDone ? SchoolTheme.success : color(for: item.colorName))
                                .frame(width: 24)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(SchoolTheme.graphite)
                                    .lineLimit(1)
                                Text(item.detail)
                                    .font(.caption)
                                    .foregroundStyle(SchoolTheme.muted)
                                    .lineLimit(1)
                            }
                            Spacer()
                        }
                    }
                }
            }
        }
    }

    private func chatThreadCard(_ thread: ChatThread) -> some View {
        DashboardCard {
            HStack(spacing: 12) {
                IconBadge(systemName: thread.icon, color: color(for: thread.colorName), size: 44)
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 7) {
                        Text(thread.title)
                            .font(.headline)
                            .foregroundStyle(SchoolTheme.graphite)
                            .lineLimit(1)
                        if thread.isAnnouncementOnly {
                            StatusBadge(text: "Объявления", color: SchoolTheme.accent)
                        }
                    }
                    Text(thread.messages.last?.text ?? thread.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(SchoolTheme.muted)
                        .lineLimit(2)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 8) {
                    if thread.unreadCount > 0 {
                        Text("\(thread.unreadCount)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(width: 25, height: 25)
                            .background(SchoolTheme.danger, in: Circle())
                    }
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(SchoolTheme.muted)
                }
            }
        }
    }

    private var collectionsContent: some View {
        VStack(spacing: 12) {
            collectionSummaryCard
            if !userRole.canManageCollections {
                roleRestrictionCard(
                    title: "Вы вошли как родитель",
                    detail: "Можно смотреть сборы и отметить оплату своей семьи. Общий счетчик, чеки и отчет ведет родкомитет.",
                    iconName: "lock.shield.fill",
                    color: SchoolTheme.accent
                )
            }

            if userRole.canManageCollections {
                Button {
                    activeSheet = .addCollection
                } label: {
                    Label("Создать сбор", systemImage: "plus")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 52)
                }
                .buttonStyle(.borderedProminent)
                .tint(SchoolTheme.success)
            }

            ForEach(collections) { collection in
                Button {
                    activeSheet = .collectionDetail(collection)
                } label: {
                    collectionCard(collection)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var collectionSummaryCard: some View {
        DashboardCard {
            HStack(spacing: 12) {
                collectionMetric(
                    value: "\(collections.count)",
                    title: "активных",
                    color: SchoolTheme.accent
                )
                Divider()
                collectionMetric(
                    value: "\(collections.reduce(0) { $0 + $1.paidCount })",
                    title: "оплат",
                    color: SchoolTheme.success
                )
                Divider()
                collectionMetric(
                    value: "\(collections.reduce(0) { $0 + max(0, $1.totalCount - $1.paidCount) })",
                    title: "ждем",
                    color: SchoolTheme.warning
                )
            }
            .frame(height: 62)
        }
    }

    private func collectionCard(_ collection: CollectionSummary) -> some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    IconBadge(systemName: "rublesign.circle.fill", color: collectionStatusColor(collection.status), size: 44)
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 7) {
                            StatusBadge(text: collection.status.rawValue, color: collectionStatusColor(collection.status))
                            InfoPill(text: collection.amount, color: SchoolTheme.warning)
                        }

                        Text(collection.title)
                            .font(.headline)
                            .foregroundStyle(SchoolTheme.graphite)
                        Text("Срок: \(collection.deadline)")
                            .font(.subheadline)
                            .foregroundStyle(SchoolTheme.muted)
                        Text(collection.detail)
                            .font(.caption)
                            .foregroundStyle(SchoolTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(SchoolTheme.muted)
                        .padding(.top, 4)
                }

                ProgressView(value: Double(collection.paidCount), total: Double(collection.totalCount))
                    .tint(SchoolTheme.success)

                HStack {
                    Text("\(collection.paidCount) из \(collection.totalCount) сдали")
                    Spacer()
                    Text("Осталось \(max(0, collection.totalCount - collection.paidCount))")
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(SchoolTheme.muted)
            }
        }
    }

    private var photosContent: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            photoTile("Экскурсии", "photo.on.rectangle", SchoolTheme.accent)
            photoTile("Праздники", "party.popper", SchoolTheme.warning)
            photoTile("Будни класса", "camera", SchoolTheme.teal)
            photoTile("Документы", "doc.text", SchoolTheme.success)
        }
    }

    private var membersContent: some View {
        VStack(spacing: 12) {
            DashboardCard {
                HStack(spacing: 12) {
                    collectionMetric(value: "\(members.count)", title: "людей", color: SchoolTheme.success)
                    Divider()
                    collectionMetric(value: "\(members.filter { $0.canManage }.count)", title: "админа", color: SchoolTheme.accent)
                    Divider()
                    collectionMetric(value: "\(members.filter { $0.status.contains("Ожидает") }.count)", title: "ждут", color: SchoolTheme.warning)
                }
                .frame(height: 62)
            }

            DashboardCard {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Участники класса")
                        .font(.headline)
                        .foregroundStyle(SchoolTheme.graphite)

                    ForEach(members) { member in
                        memberAccessRow(member)
                    }
                }
            }

            if userRole.canInviteMembers {
                Button {
                    activeSheet = .inviteMembers
                } label: {
                    Label("Пригласить родителей", systemImage: "link")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 52)
                }
                .buttonStyle(.borderedProminent)
                .tint(SchoolTheme.success)
            } else {
                roleRestrictionCard(
                    title: "Управляет администратор класса",
                    detail: "Обычный родитель видит состав класса, но не приглашает участников и не меняет роли.",
                    iconName: "person.badge.shield.checkmark.fill",
                    color: SchoolTheme.accent
                )
            }
        }
    }

    private func roleRestrictionCard(title: String, detail: String, iconName: String, color: Color) -> some View {
        DashboardCard {
            HStack(spacing: 12) {
                IconBadge(systemName: iconName, color: color, size: 44)
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(SchoolTheme.graphite)
                    Text(detail)
                        .font(.subheadline)
                        .foregroundStyle(SchoolTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
        }
    }

    private func collectionMetric(value: String, title: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(color)
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
        .frame(maxWidth: .infinity)
    }

    private var collectionCountText: String {
        let count = collections.count
        let suffix: String

        switch count {
        case 1:
            suffix = "сбор"
        case 2...4:
            suffix = "сбора"
        default:
            suffix = "сборов"
        }

        return "\(count) \(suffix)"
    }

    private func photoTile(_ title: String, _ icon: String, _ color: Color) -> some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 18) {
                IconBadge(systemName: icon, color: color)
                Text(title)
                    .font(.headline)
                    .foregroundStyle(SchoolTheme.graphite)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func memberAccessRow(_ member: ClassMemberSummary) -> some View {
        HStack(spacing: 12) {
            InitialAvatar(text: member.avatarText, color: memberColor(member.role), size: 42)
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 7) {
                    Text(member.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SchoolTheme.graphite)
                    StatusBadge(text: member.role, color: memberColor(member.role))
                }
                Text(member.childName)
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
                Text(member.status)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(member.status.contains("Ожидает") ? SchoolTheme.warning : SchoolTheme.success)
            }
            Spacer()
            if member.canManage {
                Image(systemName: "checkmark.shield.fill")
                    .foregroundStyle(SchoolTheme.success)
            }
        }
    }

    private func memberColor(_ role: String) -> Color {
        switch role {
        case "Учитель":
            SchoolTheme.accent
        case "Родкомитет", "Админ класса":
            SchoolTheme.success
        case "Семья":
            SchoolTheme.teal
        default:
            SchoolTheme.muted
        }
    }

    private func updateCollection(_ updatedCollection: CollectionSummary) {
        guard let index = collections.firstIndex(where: { $0.id == updatedCollection.id }) else {
            return
        }

        collections[index] = updatedCollection
        ClassRoomLocalStore.collections = collections
    }

    private func updateChatThread(_ updatedThread: ChatThread) {
        guard let index = chatThreads.firstIndex(where: { $0.id == updatedThread.id }) else {
            return
        }

        chatThreads[index] = updatedThread
        ClassRoomLocalStore.chatThreads = chatThreads
    }

    private func updateFeedItem(_ updatedItem: FeedItem) {
        guard let index = feedItems.firstIndex(where: { $0.id == updatedItem.id }) else {
            return
        }

        feedItems[index] = updatedItem
        ClassRoomLocalStore.feedItems = feedItems
    }

    private func openCreateAction() {
        switch selectedSection {
        case .collections:
            if userRole.canManageCollections {
                activeSheet = .addCollection
            }
        case .feed, .chats:
            if userRole.canPublishAnnouncements {
                activeSheet = .newAnnouncement
            }
        case .photos, .members:
            if userRole.canInviteMembers {
                activeSheet = .inviteMembers
            }
        }
    }

    private var canUseHeaderCreateAction: Bool {
        switch selectedSection {
        case .collections:
            userRole.canManageCollections
        case .feed, .chats:
            userRole.canPublishAnnouncements
        case .members:
            userRole.canInviteMembers
        case .photos:
            false
        }
    }

    private func badgeColor(for tag: String) -> Color {
        switch tag {
        case "Родкомитет":
            SchoolTheme.warning
        case "Тихий чат":
            SchoolTheme.accent
        default:
            SchoolTheme.success
        }
    }

    private func color(for colorName: String) -> Color {
        switch colorName {
        case "green":
            SchoolTheme.success
        case "teal":
            SchoolTheme.teal
        case "red":
            SchoolTheme.danger
        default:
            SchoolTheme.accent
        }
    }

    private var activeDigestCount: Int {
        digestItems.filter { !$0.isDone }.count
    }

    private func collectionStatusColor(_ status: CollectionStatus) -> Color {
        switch status {
        case .active:
            SchoolTheme.success
        case .dueSoon:
            SchoolTheme.warning
        case .closed:
            SchoolTheme.accent
        }
    }

    private static func launchSection() -> ClassSection {
        let arguments = ProcessInfo.processInfo.arguments

        guard
            let sectionArgumentIndex = arguments.firstIndex(of: "-qa-class-section"),
            arguments.indices.contains(sectionArgumentIndex + 1),
            let section = ClassSection(rawValue: arguments[sectionArgumentIndex + 1])
        else {
            return .feed
        }

        return section
    }

    private static func launchSheet() -> ClassRoomSheet? {
        let arguments = ProcessInfo.processInfo.arguments

        if arguments.contains("-qa-collection-add") {
            return .addCollection
        }

        if arguments.contains("-qa-collection-detail"), let firstCollection = SampleData.collections.first {
            return .collectionDetail(firstCollection)
        }

        if arguments.contains("-qa-chat-detail"), let firstThread = SampleData.chatThreads.first {
            return .chatDetail(firstThread)
        }

        if arguments.contains("-qa-chat-digest") {
            return .digestDetail
        }

        if arguments.contains("-qa-announcement-detail"), let firstItem = SampleData.feed.first {
            return .announcementDetail(firstItem)
        }

        if arguments.contains("-qa-announcement-add") {
            return .newAnnouncement
        }

        if arguments.contains("-qa-member-invite") {
            return .inviteMembers
        }

        return nil
    }
}

private struct AddCollectionSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: (CollectionSummary) -> Void

    @State private var title = "Экскурсия в музей"
    @State private var amount = "500 руб."
    @State private var deadline = "до пятницы"
    @State private var recipient = "Мария, родкомитет"
    @State private var detail = "Билеты, автобус и небольшой резерв."
    @State private var totalCount = 25
    @State private var reminderEnabled = true

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    CollectionSheetHeader(
                        icon: "rublesign.circle.fill",
                        color: SchoolTheme.success,
                        title: "Создать сбор",
                        subtitle: "Ответственный, дедлайн и прозрачный отчет"
                    )

                    DashboardCard {
                        VStack(spacing: 12) {
                            CollectionTextField(title: "Название", iconName: "text.badge.plus", color: SchoolTheme.success, text: $title)
                            CollectionTextField(title: "Сумма с семьи", iconName: "banknote", color: SchoolTheme.warning, text: $amount)
                            CollectionTextField(title: "Дедлайн", iconName: "calendar.badge.clock", color: SchoolTheme.accent, text: $deadline)
                            CollectionTextField(title: "Кому сдавать", iconName: "person.badge.shield.checkmark", color: SchoolTheme.teal, text: $recipient)
                            CollectionTextField(title: "Описание", iconName: "text.alignleft", color: SchoolTheme.success, text: $detail)
                        }
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Stepper(value: $totalCount, in: 1...50) {
                                HStack(spacing: 12) {
                                    IconBadge(systemName: "person.3.fill", color: SchoolTheme.accent, size: 42)
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("Участников")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(SchoolTheme.graphite)
                                        Text("\(totalCount) семей")
                                            .font(.caption)
                                            .foregroundStyle(SchoolTheme.muted)
                                    }
                                }
                            }

                            Toggle(isOn: $reminderEnabled) {
                                HStack(spacing: 12) {
                                    IconBadge(systemName: "bell.badge.fill", color: SchoolTheme.warning, size: 42)
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("Напомнить не оплатившим")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(SchoolTheme.graphite)
                                        Text("Мягкое напоминание перед дедлайном")
                                            .font(.caption)
                                            .foregroundStyle(SchoolTheme.muted)
                                    }
                                }
                            }
                            .toggleStyle(.switch)
                            .tint(SchoolTheme.success)
                        }
                    }

                    Button {
                        save()
                    } label: {
                        Label("Опубликовать сбор", systemImage: "checkmark")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 52)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(SchoolTheme.success)
                    .disabled(title.trimmed.isEmpty || amount.trimmed.isEmpty || deadline.trimmed.isEmpty)
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Новый сбор")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Готово") {
                        dismissKeyboard()
                    }
                }
            }
        }
    }

    private func save() {
        let collection = CollectionSummary(
            title: title.trimmed,
            amount: amount.trimmed,
            deadline: deadline.trimmed,
            paidCount: 0,
            totalCount: totalCount,
            recipient: recipient.trimmed,
            detail: detail.trimmed,
            status: .active,
            expenses: []
        )

        onSave(collection)
        dismiss()
    }
}

private struct BlockedClassActionSheet: View {
    @Environment(\.dismiss) private var dismiss

    let icon: String
    let title: String
    let detail: String

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                CollectionSheetHeader(
                    icon: icon,
                    color: SchoolTheme.accent,
                    title: title,
                    subtitle: detail
                )

                DashboardCard {
                    HStack(spacing: 12) {
                        IconBadge(systemName: "lock.shield.fill", color: SchoolTheme.accent, size: 44)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Доступ ограничен")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)
                            Text("Это защитит сборы, объявления и данные класса от случайных изменений.")
                                .font(.subheadline)
                                .foregroundStyle(SchoolTheme.muted)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer()
                    }
                }

                Spacer()
            }
            .padding(20)
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Нет прав")
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

private struct CollectionDetailSheet: View {
    @Environment(\.dismiss) private var dismiss

    let collection: CollectionSummary
    let userRole: AppUserRole
    let onSave: (CollectionSummary) -> Void

    @State private var paidCount: Int
    @State private var status: CollectionStatus
    @State private var expenses: [CollectionExpense]
    @State private var myFamilyPaid: Bool
    @State private var expenseTitle = "Чек за автобус"
    @State private var expenseAmount = "2 500 руб."
    @State private var expenseNote = "Добавлено в отчет"
    @State private var expenseAttachment: String?

    init(collection: CollectionSummary, userRole: AppUserRole, onSave: @escaping (CollectionSummary) -> Void) {
        self.collection = collection
        self.userRole = userRole
        self.onSave = onSave
        _paidCount = State(initialValue: collection.paidCount)
        _status = State(initialValue: collection.status)
        _expenses = State(initialValue: collection.expenses)
        _myFamilyPaid = State(initialValue: collection.myFamilyPaid)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    CollectionSheetHeader(
                        icon: "rublesign.circle.fill",
                        color: collectionStatusColor(status),
                        title: collection.title,
                        subtitle: "\(collection.amount) - \(collection.deadline)"
                    )

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 14) {
                            collectionInfo("Кому сдавать", collection.recipient, "person.badge.shield.checkmark", SchoolTheme.teal)
                            collectionInfo("Описание", collection.detail, "text.alignleft", SchoolTheme.success)
                            collectionInfo("Статус", status.rawValue, "checkmark.seal.fill", collectionStatusColor(status))
                        }
                    }

                    paymentCard
                    reportCard

                    Button {
                        save()
                    } label: {
                        Label(userRole.canManageCollections ? "Сохранить сбор" : "Сохранить мою оплату", systemImage: "checkmark")
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
            .navigationTitle("Сбор")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        save()
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Готово") {
                        dismissKeyboard()
                    }
                }
            }
        }
    }

    private var paymentCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Оплаты")
                        .font(.headline)
                        .foregroundStyle(SchoolTheme.graphite)
                    Spacer()
                    StatusBadge(text: "\(paidCount) из \(collection.totalCount)", color: SchoolTheme.success)
                }

                ProgressView(value: Double(paidCount), total: Double(collection.totalCount))
                    .tint(SchoolTheme.success)

                if userRole.canManageCollections {
                    Stepper(value: $paidCount, in: 0...collection.totalCount) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Подтверждено родкомитетом")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(SchoolTheme.graphite)
                            Text("Осталось \(max(0, collection.totalCount - paidCount)) семей")
                                .font(.caption)
                                .foregroundStyle(SchoolTheme.muted)
                        }
                    }
                } else {
                    HStack(spacing: 12) {
                        IconBadge(systemName: "lock.shield.fill", color: SchoolTheme.accent, size: 42)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Общий счетчик закрыт")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(SchoolTheme.graphite)
                            Text("Его меняет родкомитет после подтверждения оплаты")
                                .font(.caption)
                                .foregroundStyle(SchoolTheme.muted)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }

                Toggle(isOn: Binding(get: { myFamilyPaid }, set: updateMyFamilyPayment)) {
                    HStack(spacing: 12) {
                        IconBadge(systemName: "checkmark.circle.fill", color: SchoolTheme.success, size: 42)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Моя семья сдала")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(SchoolTheme.graphite)
                            Text(collection.amount)
                                .font(.caption)
                                .foregroundStyle(SchoolTheme.muted)
                        }
                    }
                }
                .toggleStyle(.switch)
                .tint(SchoolTheme.success)

                if userRole.canManageCollections {
                    Picker("Статус", selection: $status) {
                        ForEach(CollectionStatus.allCases, id: \.self) { status in
                            Text(status.rawValue).tag(status)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
        }
    }

    private var reportCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Чеки и отчет")
                    .font(.headline)
                    .foregroundStyle(SchoolTheme.graphite)

                if expenses.isEmpty {
                    Text("Расходов пока нет")
                        .font(.subheadline)
                        .foregroundStyle(SchoolTheme.muted)
                } else {
                    VStack(spacing: 10) {
                        ForEach(expenses) { expense in
                            HStack(alignment: .top, spacing: 12) {
                                IconBadge(systemName: "doc.text.fill", color: SchoolTheme.accent, size: 38)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(expense.title)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(SchoolTheme.graphite)
                                    Text(expense.note)
                                        .font(.caption)
                                        .foregroundStyle(SchoolTheme.muted)
                                    if let attachment = expense.attachment {
                                        Label(attachment, systemImage: attachment.contains("Фото") ? "camera.fill" : "paperclip")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(SchoolTheme.accent)
                                    }
                                }
                                Spacer()
                                Text(expense.amount)
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(SchoolTheme.warning)
                            }
                        }
                    }
                }

                if userRole.canManageCollections {
                    VStack(spacing: 10) {
                        CollectionTextField(title: "Расход", iconName: "doc.badge.plus", color: SchoolTheme.accent, text: $expenseTitle)
                        CollectionTextField(title: "Сумма", iconName: "banknote", color: SchoolTheme.warning, text: $expenseAmount)
                        CollectionTextField(title: "Комментарий", iconName: "text.alignleft", color: SchoolTheme.teal, text: $expenseNote)

                        HStack(spacing: 10) {
                            Button {
                                addReceiptPhoto()
                            } label: {
                                Label("Фото чека", systemImage: "camera.fill")
                                    .font(.caption.weight(.semibold))
                                    .frame(maxWidth: .infinity, minHeight: 42)
                            }
                            .buttonStyle(.bordered)
                            .tint(expenseAttachment?.contains("Фото") == true ? SchoolTheme.success : SchoolTheme.accent)

                            Button {
                                attachReceiptFile()
                            } label: {
                                Label("Файл", systemImage: "paperclip")
                                    .font(.caption.weight(.semibold))
                                    .frame(maxWidth: .infinity, minHeight: 42)
                            }
                            .buttonStyle(.bordered)
                            .tint(expenseAttachment?.contains("Файл") == true ? SchoolTheme.success : SchoolTheme.accent)
                        }
                    }

                    Button {
                        addExpense()
                    } label: {
                        Label("Добавить расход", systemImage: "plus")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity, minHeight: 46)
                    }
                    .buttonStyle(.bordered)
                    .tint(SchoolTheme.success)
                    .disabled(expenseTitle.trimmed.isEmpty || expenseAmount.trimmed.isEmpty)
                } else {
                    HStack(spacing: 12) {
                        IconBadge(systemName: "eye.fill", color: SchoolTheme.accent, size: 40)
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Отчет только для просмотра")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(SchoolTheme.graphite)
                            Text("Чеки и расходы добавляет родкомитет")
                                .font(.caption)
                                .foregroundStyle(SchoolTheme.muted)
                        }
                        Spacer()
                    }
                }
            }
        }
    }

    private func collectionInfo(_ title: String, _ value: String, _ iconName: String, _ color: Color) -> some View {
        HStack(alignment: .top, spacing: 12) {
            IconBadge(systemName: iconName, color: color, size: 38)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SchoolTheme.muted)
                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
    }

    private func updateMyFamilyPayment(_ value: Bool) {
        myFamilyPaid = value

        if value, paidCount < collection.totalCount {
            paidCount += 1
        } else if !value, paidCount > 0 {
            paidCount -= 1
        }
    }

    private func addExpense() {
        let expense = CollectionExpense(
            title: expenseTitle.trimmed,
            amount: expenseAmount.trimmed,
            note: expenseNote.trimmed.isEmpty ? "Без комментария" : expenseNote.trimmed,
            attachment: expenseAttachment
        )

        expenses.insert(expense, at: 0)
        expenseTitle = ""
        expenseAmount = ""
        expenseNote = ""
        expenseAttachment = nil
        onSave(updatedCollectionSnapshot())
    }

    private func addReceiptPhoto() {
        expenseAttachment = "Фото чека"
    }

    private func attachReceiptFile() {
        expenseAttachment = "Файл отчета"
    }

    private func save() {
        onSave(updatedCollectionSnapshot())
        dismiss()
    }

    private func updatedCollectionSnapshot() -> CollectionSummary {
        var updatedCollection = collection
        updatedCollection.myFamilyPaid = myFamilyPaid

        if userRole.canManageCollections {
            updatedCollection.paidCount = paidCount
            updatedCollection.status = paidCount >= collection.totalCount ? .closed : status
            updatedCollection.expenses = expenses
        } else {
            let previousFamilyPayment = collection.myFamilyPaid ? 1 : 0
            let currentFamilyPayment = myFamilyPaid ? 1 : 0
            let nextPaidCount = collection.paidCount + currentFamilyPayment - previousFamilyPayment
            updatedCollection.paidCount = min(max(nextPaidCount, 0), collection.totalCount)
            updatedCollection.status = updatedCollection.paidCount >= collection.totalCount ? .closed : collection.status
            updatedCollection.expenses = collection.expenses
        }

        return updatedCollection
    }

    private func collectionStatusColor(_ status: CollectionStatus) -> Color {
        switch status {
        case .active:
            SchoolTheme.success
        case .dueSoon:
            SchoolTheme.warning
        case .closed:
            SchoolTheme.accent
        }
    }
}

private struct ChatDetailSheet: View {
    @Environment(\.dismiss) private var dismiss

    let thread: ChatThread
    let onSave: (ChatThread) -> Void

    @State private var messages: [ClassChatMessage]
    @State private var replyText = "Спасибо, увидел"

    init(thread: ChatThread, onSave: @escaping (ChatThread) -> Void) {
        self.thread = thread
        self.onSave = onSave
        _messages = State(initialValue: thread.messages)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    CollectionSheetHeader(
                        icon: thread.icon,
                        color: color(for: thread.colorName),
                        title: thread.title,
                        subtitle: thread.subtitle
                    )

                    summaryCard
                    messagesCard
                    replyCard

                    Button {
                        save()
                    } label: {
                        Label("Сохранить чат", systemImage: "checkmark")
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
            .navigationTitle("Чат")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        save()
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Готово") {
                        dismissKeyboard()
                    }
                }
            }
        }
    }

    private var summaryCard: some View {
        DashboardCard {
            HStack(spacing: 12) {
                chatMetric(value: "\(messages.count)", title: "сообщения", color: SchoolTheme.accent)
                Divider()
                chatMetric(value: "\(messages.filter(\.isImportant).count)", title: "важные", color: SchoolTheme.warning)
                Divider()
                chatMetric(value: "\(messages.filter(\.createdTask).count)", title: "в задачах", color: SchoolTheme.success)
            }
            .frame(height: 62)
        }
    }

    private var messagesCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 14) {
                Text(thread.isAnnouncementOnly ? "Объявления" : "Сообщения")
                    .font(.headline)
                    .foregroundStyle(SchoolTheme.graphite)

                ForEach(messages) { message in
                    messageRow(message)
                }
            }
        }
    }

    private var replyCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 12) {
                Text(thread.isAnnouncementOnly ? "Вопрос учителю" : "Быстрый ответ")
                    .font(.headline)
                    .foregroundStyle(SchoolTheme.graphite)

                CollectionTextField(title: "Сообщение", iconName: "bubble.left.and.text.bubble.right", color: SchoolTheme.teal, text: $replyText)

                Button {
                    sendReply()
                } label: {
                    Label("Отправить", systemImage: "paperplane.fill")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: 46)
                }
                .buttonStyle(.bordered)
                .tint(SchoolTheme.success)
                .disabled(replyText.trimmed.isEmpty)
            }
        }
    }

    private func messageRow(_ message: ClassChatMessage) -> some View {
        HStack(alignment: .top, spacing: 12) {
            IconBadge(systemName: message.isImportant ? "exclamationmark.bubble.fill" : "bubble.left.fill", color: message.isImportant ? SchoolTheme.warning : SchoolTheme.accent, size: 38)
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 7) {
                    Text(message.author)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SchoolTheme.graphite)
                    Text(message.timeLabel)
                        .font(.caption)
                        .foregroundStyle(SchoolTheme.muted)
                    if message.isImportant {
                        StatusBadge(text: "Важно", color: SchoolTheme.warning)
                    }
                }

                Text(message.text)
                    .font(.subheadline)
                    .foregroundStyle(SchoolTheme.graphite)
                    .fixedSize(horizontal: false, vertical: true)

                if let actionTitle = message.actionTitle {
                    Button {
                        toggleTask(for: message)
                    } label: {
                        Label(message.createdTask ? "Добавлено" : actionTitle, systemImage: message.createdTask ? "checkmark.circle.fill" : "plus.circle")
                            .font(.caption.weight(.semibold))
                    }
                    .buttonStyle(.bordered)
                    .tint(message.createdTask ? SchoolTheme.success : SchoolTheme.accent)
                }
            }
            Spacer()
        }
    }

    private func chatMetric(value: String, title: String, color: Color) -> some View {
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

    private func toggleTask(for message: ClassChatMessage) {
        guard let index = messages.firstIndex(where: { $0.id == message.id }) else {
            return
        }

        messages[index].createdTask.toggle()
    }

    private func sendReply() {
        let message = ClassChatMessage(
            author: "Вы",
            text: replyText.trimmed,
            timeLabel: "сейчас"
        )
        messages.append(message)
        replyText = ""
    }

    private func save() {
        var updatedThread = thread
        updatedThread.messages = messages
        updatedThread.unreadCount = 0
        onSave(updatedThread)
        dismiss()
    }

    private func color(for colorName: String) -> Color {
        switch colorName {
        case "green":
            SchoolTheme.success
        case "teal":
            SchoolTheme.teal
        case "red":
            SchoolTheme.danger
        default:
            SchoolTheme.accent
        }
    }
}

private struct ChatDigestSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: ([ChatDigestItem]) -> Void

    @State private var items: [ChatDigestItem]

    init(items: [ChatDigestItem], onSave: @escaping ([ChatDigestItem]) -> Void) {
        self.onSave = onSave
        _items = State(initialValue: items)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    CollectionSheetHeader(
                        icon: "sparkles",
                        color: SchoolTheme.accent,
                        title: "Важное за день",
                        subtitle: "Сводка из чатов без лишнего шума"
                    )

                    summaryCard
                    digestList

                    Button {
                        save()
                    } label: {
                        Label("Сохранить сводку", systemImage: "checkmark")
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
            .navigationTitle("Тихий чат")
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

    private var summaryCard: some View {
        DashboardCard {
            HStack(spacing: 12) {
                digestMetric(value: "\(items.count)", title: "пункта", color: SchoolTheme.accent)
                Divider()
                digestMetric(value: "\(items.filter { !$0.isDone }.count)", title: "активные", color: SchoolTheme.warning)
                Divider()
                digestMetric(value: "\(items.filter(\.isDone).count)", title: "готово", color: SchoolTheme.success)
            }
            .frame(height: 62)
        }
    }

    private var digestList: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Что важно")
                    .font(.headline)
                    .foregroundStyle(SchoolTheme.graphite)

                ForEach(items) { item in
                    digestRow(item)
                }
            }
        }
    }

    private func digestRow(_ item: ChatDigestItem) -> some View {
        HStack(alignment: .top, spacing: 12) {
            IconBadge(systemName: item.isDone ? "checkmark.circle.fill" : item.iconName, color: item.isDone ? SchoolTheme.success : color(for: item.colorName), size: 40)
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 7) {
                    Text(item.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SchoolTheme.graphite)
                    if item.isDone {
                        StatusBadge(text: "Готово", color: SchoolTheme.success)
                    }
                }
                Text(item.detail)
                    .font(.subheadline)
                    .foregroundStyle(SchoolTheme.graphite)
                    .fixedSize(horizontal: false, vertical: true)
                Text(item.source)
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)

                Button {
                    toggleDone(for: item)
                } label: {
                    Label(item.isDone ? "Вернуть" : item.actionTitle, systemImage: item.isDone ? "arrow.uturn.backward" : "plus.circle")
                        .font(.caption.weight(.semibold))
                }
                .buttonStyle(.bordered)
                .tint(item.isDone ? SchoolTheme.muted : SchoolTheme.accent)
            }
            Spacer()
        }
    }

    private func digestMetric(value: String, title: String, color: Color) -> some View {
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

    private func toggleDone(for item: ChatDigestItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else {
            return
        }

        items[index].isDone.toggle()
    }

    private func save() {
        onSave(items)
        dismiss()
    }

    private func color(for colorName: String) -> Color {
        switch colorName {
        case "green":
            SchoolTheme.success
        case "teal":
            SchoolTheme.teal
        case "red":
            SchoolTheme.danger
        default:
            SchoolTheme.accent
        }
    }
}

private struct AnnouncementDetailSheet: View {
    @Environment(\.dismiss) private var dismiss

    let item: FeedItem
    let onSave: (FeedItem) -> Void

    @State private var acknowledged: Bool

    init(item: FeedItem, onSave: @escaping (FeedItem) -> Void) {
        self.item = item
        self.onSave = onSave
        _acknowledged = State(initialValue: item.isAcknowledged)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    CollectionSheetHeader(
                        icon: icon(for: item.tag),
                        color: color(for: item.tag),
                        title: item.title,
                        subtitle: item.tag
                    )

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 14) {
                            StatusBadge(text: item.tag, color: color(for: item.tag))
                            Text(item.subtitle)
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(SchoolTheme.graphite)
                                .fixedSize(horizontal: false, vertical: true)
                            Text("Прочитали \(acknowledged ? 19 : 18) из 25 родителей")
                                .font(.subheadline)
                                .foregroundStyle(SchoolTheme.muted)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    DashboardCard {
                        HStack(spacing: 12) {
                            IconBadge(systemName: acknowledged ? "checkmark.seal.fill" : "eye.fill", color: acknowledged ? SchoolTheme.success : SchoolTheme.accent, size: 44)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(acknowledged ? "Прочтение подтверждено" : "Подтвердить прочтение")
                                    .font(.headline)
                                    .foregroundStyle(SchoolTheme.graphite)
                                Text("Автор увидит, что ваша семья в курсе")
                                    .font(.subheadline)
                                    .foregroundStyle(SchoolTheme.muted)
                            }
                            Spacer()
                        }
                    }

                    Button {
                        acknowledge()
                    } label: {
                        Label(acknowledged ? "Прочитано" : "Я прочитал", systemImage: acknowledged ? "checkmark.seal.fill" : "checkmark")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 52)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(acknowledged ? SchoolTheme.muted : SchoolTheme.success)
                    .disabled(acknowledged)
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Объявление")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        save()
                        dismiss()
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Готово") {
                        dismissKeyboard()
                    }
                }
            }
        }
    }

    private func acknowledge() {
        acknowledged = true
        save()
    }

    private func save() {
        var updatedItem = item
        updatedItem.isAcknowledged = acknowledged
        onSave(updatedItem)
    }

    private func icon(for tag: String) -> String {
        switch tag {
        case "Родкомитет":
            "building.columns.fill"
        case "Тихий чат":
            "sparkles"
        default:
            "megaphone.fill"
        }
    }

    private func color(for tag: String) -> Color {
        switch tag {
        case "Родкомитет":
            SchoolTheme.warning
        case "Тихий чат":
            SchoolTheme.accent
        default:
            SchoolTheme.success
        }
    }
}

private struct NewAnnouncementSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: (FeedItem) -> Void

    @State private var title = "Форма на физкультуру"
    @State private var bodyText = "Завтра нужна форма и сменная обувь для спортзала."
    @State private var tag = "Учитель"
    @State private var requiresAck = true

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    CollectionSheetHeader(
                        icon: "megaphone.fill",
                        color: SchoolTheme.success,
                        title: "Новое объявление",
                        subtitle: "Коротко, важно и с подтверждением"
                    )

                    DashboardCard {
                        VStack(spacing: 12) {
                            CollectionTextField(title: "Заголовок", iconName: "text.badge.plus", color: SchoolTheme.success, text: $title)
                            CollectionTextField(title: "Текст", iconName: "text.alignleft", color: SchoolTheme.accent, text: $bodyText)

                            Picker("Канал", selection: $tag) {
                                Text("Учитель").tag("Учитель")
                                Text("Родкомитет").tag("Родкомитет")
                                Text("Тихий чат").tag("Тихий чат")
                            }
                            .pickerStyle(.segmented)
                        }
                    }

                    DashboardCard {
                        Toggle(isOn: $requiresAck) {
                            HStack(spacing: 12) {
                                IconBadge(systemName: "checkmark.seal.fill", color: SchoolTheme.warning, size: 42)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text("Нужно подтверждение")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(SchoolTheme.graphite)
                                    Text("Покажем, кто прочитал")
                                        .font(.caption)
                                        .foregroundStyle(SchoolTheme.muted)
                                }
                            }
                        }
                        .toggleStyle(.switch)
                        .tint(SchoolTheme.success)
                    }

                    Button {
                        save()
                    } label: {
                        Label("Опубликовать", systemImage: "paperplane.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 52)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(SchoolTheme.success)
                    .disabled(title.trimmed.isEmpty || bodyText.trimmed.isEmpty)
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Объявление")
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

    private func save() {
        let ackText = requiresAck ? " Нужно подтверждение прочтения." : ""
        let item = FeedItem(
            title: title.trimmed,
            subtitle: bodyText.trimmed + ackText,
            tag: tag
        )

        onSave(item)
        dismiss()
    }
}

private struct InviteMembersSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: ([ClassMemberSummary]) -> Void

    @State private var members: [ClassMemberSummary]
    @State private var inviteName = "Новый родитель"
    @State private var childName = "Имя ребенка"
    @State private var role = "Родитель"
    @State private var inviteCode = "3B-4821"

    init(members: [ClassMemberSummary], onSave: @escaping ([ClassMemberSummary]) -> Void) {
        self.onSave = onSave
        _members = State(initialValue: members)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    CollectionSheetHeader(
                        icon: "person.badge.plus",
                        color: SchoolTheme.success,
                        title: "Пригласить в класс",
                        subtitle: "Роль, ребенок и закрытый код доступа"
                    )

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Код приглашения")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            HStack(spacing: 12) {
                                IconBadge(systemName: "number", color: SchoolTheme.warning, size: 42)
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(inviteCode)
                                        .font(.title3.weight(.bold))
                                        .foregroundStyle(SchoolTheme.graphite)
                                    Text("Действует для класса 3Б")
                                        .font(.caption)
                                        .foregroundStyle(SchoolTheme.muted)
                                }
                                Spacer()
                                StatusBadge(text: "Закрытый класс", color: SchoolTheme.success)
                            }
                        }
                    }

                    DashboardCard {
                        VStack(spacing: 12) {
                            CollectionTextField(title: "Имя", iconName: "person.fill", color: SchoolTheme.success, text: $inviteName)
                            CollectionTextField(title: "Ребенок", iconName: "person.crop.square", color: SchoolTheme.teal, text: $childName)

                            Picker("Роль", selection: $role) {
                                Text("Родитель").tag("Родитель")
                                Text("Родкомитет").tag("Родкомитет")
                                Text("Учитель").tag("Учитель")
                            }
                            .pickerStyle(.segmented)

                            Button {
                                addInvite()
                            } label: {
                                Label("Добавить приглашение", systemImage: "link")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity, minHeight: 46)
                            }
                            .buttonStyle(.bordered)
                            .tint(SchoolTheme.success)
                            .disabled(inviteName.trimmed.isEmpty || childName.trimmed.isEmpty)
                        }
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Кого пригласили")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            ForEach(members.suffix(4)) { member in
                                HStack(spacing: 12) {
                                    InitialAvatar(text: member.avatarText, color: color(for: member.role), size: 38)
                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack(spacing: 7) {
                                            Text(member.name)
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(SchoolTheme.graphite)
                                            StatusBadge(text: member.role, color: color(for: member.role))
                                        }
                                        Text("\(member.childName) - \(member.status)")
                                            .font(.caption)
                                            .foregroundStyle(SchoolTheme.muted)
                                    }
                                    Spacer()
                                }
                            }
                        }
                    }

                    Button {
                        save()
                    } label: {
                        Label("Сохранить участников", systemImage: "checkmark")
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
            .navigationTitle("Приглашение")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        save()
                    }
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Готово") {
                        dismissKeyboard()
                    }
                }
            }
        }
    }

    private func addInvite() {
        let avatar = String(inviteName.trimmed.prefix(1)).uppercased()
        members.append(
            ClassMemberSummary(
                name: inviteName.trimmed,
                childName: childName.trimmed,
                role: role,
                status: "Ожидает вход",
                avatarText: avatar.isEmpty ? "Р" : avatar,
                canManage: role == "Родкомитет" || role == "Учитель"
            )
        )
        inviteName = ""
        childName = ""
    }

    private func save() {
        onSave(members)
        dismiss()
    }

    private func color(for role: String) -> Color {
        switch role {
        case "Учитель":
            SchoolTheme.accent
        case "Родкомитет":
            SchoolTheme.success
        default:
            SchoolTheme.teal
        }
    }
}

private struct CollectionSheetHeader: View {
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

private struct CollectionTextField: View {
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

private func dismissKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}

private enum ClassRoomSheet: Identifiable, Hashable {
    case addCollection
    case collectionDetail(CollectionSummary)
    case chatDetail(ChatThread)
    case digestDetail
    case announcementDetail(FeedItem)
    case newAnnouncement
    case inviteMembers

    var id: String {
        switch self {
        case .addCollection:
            "add-collection"
        case .collectionDetail(let collection):
            "collection-\(collection.id.uuidString)"
        case .chatDetail(let thread):
            "chat-\(thread.id.uuidString)"
        case .digestDetail:
            "digest-detail"
        case .announcementDetail(let item):
            "announcement-\(item.id.uuidString)"
        case .newAnnouncement:
            "new-announcement"
        case .inviteMembers:
            "invite-members"
        }
    }

    var preferredSection: ClassSection {
        switch self {
        case .addCollection, .collectionDetail:
            .collections
        case .chatDetail, .digestDetail:
            .chats
        case .announcementDetail, .newAnnouncement:
            .feed
        case .inviteMembers:
            .members
        }
    }
}

private enum ClassSection: String, CaseIterable, Identifiable {
    case feed
    case chats
    case collections
    case photos
    case members

    var id: String { rawValue }

    var title: String {
        switch self {
        case .feed:
            "Лента"
        case .chats:
            "Чаты"
        case .collections:
            "Сборы"
        case .photos:
            "Фото"
        case .members:
            "Участники"
        }
    }
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

#Preview {
    ClassRoomView()
}
