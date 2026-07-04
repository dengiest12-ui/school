import SwiftUI
import UniformTypeIdentifiers
import UIKit
import CoreImage.CIFilterBuiltins

private struct ClassPhotoItem: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var author: String
    var dateLabel: String
    var status: String
    var attachment: String?
    var colorName: String

    init(
        id: UUID = UUID(),
        title: String,
        author: String,
        dateLabel: String,
        status: String = "В альбоме",
        attachment: String? = nil,
        colorName: String = "blue"
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.dateLabel = dateLabel
        self.status = status
        self.attachment = attachment
        self.colorName = colorName
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case author
        case dateLabel
        case status
        case attachment
        case colorName
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        author = try container.decode(String.self, forKey: .author)
        dateLabel = try container.decode(String.self, forKey: .dateLabel)
        status = try container.decodeIfPresent(String.self, forKey: .status) ?? "В альбоме"
        attachment = try container.decodeIfPresent(String.self, forKey: .attachment)
        colorName = try container.decodeIfPresent(String.self, forKey: .colorName) ?? "blue"
    }
}

private struct PhotoAlbumSummary: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var subtitle: String
    var iconName: String
    var colorName: String
    var photos: [ClassPhotoItem]

    init(id: UUID = UUID(), title: String, subtitle: String, iconName: String, colorName: String, photos: [ClassPhotoItem]) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.iconName = iconName
        self.colorName = colorName
        self.photos = photos
    }

    static let sample = [
        PhotoAlbumSummary(
            title: "Экскурсии",
            subtitle: "Музей, театр и выезды класса",
            iconName: "photo.on.rectangle",
            colorName: "blue",
            photos: [
                ClassPhotoItem(title: "Музей космонавтики", author: "Мария, родкомитет", dateLabel: "12 сентября", colorName: "blue"),
                ClassPhotoItem(title: "Автобус перед школой", author: "Екатерина", dateLabel: "12 сентября", colorName: "teal")
            ]
        ),
        PhotoAlbumSummary(
            title: "Праздники",
            subtitle: "Дни рождения, 1 сентября, выпускные",
            iconName: "party.popper",
            colorName: "orange",
            photos: [
                ClassPhotoItem(title: "День учителя", author: "Анна", dateLabel: "5 октября", colorName: "orange")
            ]
        ),
        PhotoAlbumSummary(
            title: "Будни класса",
            subtitle: "Проекты, уроки, стенды и поделки",
            iconName: "camera",
            colorName: "teal",
            photos: [
                ClassPhotoItem(title: "Проект по окружающему миру", author: "Учитель", dateLabel: "Вчера", colorName: "green")
            ]
        ),
        PhotoAlbumSummary(
            title: "Документы",
            subtitle: "Согласия, памятки и важные сканы",
            iconName: "doc.text",
            colorName: "green",
            photos: [
                ClassPhotoItem(title: "Памятка на экскурсию", author: "Учитель", dateLabel: "Сегодня", colorName: "green")
            ]
        )
    ]
}

private struct ClassRoomStoreSnapshot: Codable {
    var feedItems: [FeedItem]
    var collections: [CollectionSummary]
    var chatThreads: [ChatThread]
    var digestItems: [ChatDigestItem]
    var members: [ClassMemberSummary]
    var photoAlbums: [PhotoAlbumSummary]

    init(
        feedItems: [FeedItem] = SampleData.feed,
        collections: [CollectionSummary] = SampleData.collections,
        chatThreads: [ChatThread] = SampleData.chatThreads,
        digestItems: [ChatDigestItem] = SampleData.chatDigestItems,
        members: [ClassMemberSummary] = SampleData.classMembers,
        photoAlbums: [PhotoAlbumSummary] = PhotoAlbumSummary.sample
    ) {
        self.feedItems = feedItems
        self.collections = collections
        self.chatThreads = chatThreads
        self.digestItems = digestItems
        self.members = members
        self.photoAlbums = photoAlbums
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        feedItems = try container.decodeIfPresent([FeedItem].self, forKey: .feedItems) ?? SampleData.feed
        collections = try container.decodeIfPresent([CollectionSummary].self, forKey: .collections) ?? SampleData.collections
        chatThreads = try container.decodeIfPresent([ChatThread].self, forKey: .chatThreads) ?? SampleData.chatThreads
        digestItems = try container.decodeIfPresent([ChatDigestItem].self, forKey: .digestItems) ?? SampleData.chatDigestItems
        members = try container.decodeIfPresent([ClassMemberSummary].self, forKey: .members) ?? SampleData.classMembers
        photoAlbums = try container.decodeIfPresent([PhotoAlbumSummary].self, forKey: .photoAlbums) ?? PhotoAlbumSummary.sample
    }

    static let sample = ClassRoomStoreSnapshot()
}

private enum ClassRoomLocalStore {
    private static let defaultsKey = "school.classRoom.store.v1"
    private static var snapshot: ClassRoomStoreSnapshot = load()

    static var feedItems: [FeedItem] {
        get { snapshot.feedItems }
        set {
            snapshot.feedItems = newValue
            save()
        }
    }

    static var collections: [CollectionSummary] {
        get { snapshot.collections }
        set {
            snapshot.collections = newValue
            save()
        }
    }

    static var chatThreads: [ChatThread] {
        get { snapshot.chatThreads }
        set {
            snapshot.chatThreads = newValue
            save()
        }
    }

    static var digestItems: [ChatDigestItem] {
        get { snapshot.digestItems }
        set {
            snapshot.digestItems = newValue
            save()
        }
    }

    static var members: [ClassMemberSummary] {
        get { snapshot.members }
        set {
            snapshot.members = newValue
            save()
        }
    }

    static var photoAlbums: [PhotoAlbumSummary] {
        get { snapshot.photoAlbums }
        set {
            snapshot.photoAlbums = newValue
            save()
        }
    }

    static func resetIfRequested() {
        guard ProcessInfo.processInfo.arguments.contains("-qa-reset-class-store") else {
            return
        }

        snapshot = .sample
        UserDefaults.standard.removeObject(forKey: defaultsKey)
    }

    private static func load() -> ClassRoomStoreSnapshot {
        guard
            let data = UserDefaults.standard.data(forKey: defaultsKey),
            let decoded = try? JSONDecoder().decode(ClassRoomStoreSnapshot.self, from: data)
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

struct ClassRoomView: View {
    let userRole: AppUserRole

    @AppStorage("school.shared.selectedChildID") private var selectedChildID = ""
    @State private var selectedSection: ClassSection
    @State private var feedItems: [FeedItem]
    @State private var collections: [CollectionSummary]
    @State private var chatThreads: [ChatThread]
    @State private var digestItems: [ChatDigestItem]
    @State private var members: [ClassMemberSummary]
    @State private var photoAlbums: [PhotoAlbumSummary]
    @State private var activeSheet: ClassRoomSheet?

    init(userRole: AppUserRole = .parent) {
        self.userRole = userRole
        ClassRoomLocalStore.resetIfRequested()
        let launchSheet = ClassRoomView.launchSheet()
        _selectedSection = State(initialValue: launchSheet?.preferredSection ?? ClassRoomView.launchSection())
        _feedItems = State(initialValue: ClassRoomLocalStore.feedItems)
        _collections = State(initialValue: ClassRoomLocalStore.collections)
        _chatThreads = State(initialValue: ClassRoomLocalStore.chatThreads)
        _digestItems = State(initialValue: ClassRoomLocalStore.digestItems)
        _members = State(initialValue: ClassRoomLocalStore.members)
        _photoAlbums = State(initialValue: ClassRoomLocalStore.photoAlbums)
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
        .onAppear {
            if ProcessInfo.processInfo.arguments.contains("-qa-member-invite") {
                selectedSection = .members
                activeSheet = .inviteMembers
            } else if ProcessInfo.processInfo.arguments.contains("-qa-member-management") {
                selectedSection = .members
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .addCollection:
                if activeUserRole.canManageCollections {
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
                AnnouncementDetailSheet(item: item, userRole: userRole) { updatedItem in
                    updateFeedItem(updatedItem)
                }
            case .newAnnouncement:
                if activeUserRole.canPublishAnnouncements {
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
                if activeUserRole.canInviteMembers {
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
            case .photoAlbum(let album):
                PhotoAlbumSheet(album: album, userRole: activeUserRole) { updatedAlbum in
                    updatePhotoAlbum(updatedAlbum)
                }
            case .newPhotoAlbum:
                if canManagePhotoAlbums {
                    NewPhotoAlbumSheet { album in
                        photoAlbums.insert(album, at: 0)
                        ClassRoomLocalStore.photoAlbums = photoAlbums
                        selectedSection = .photos
                    }
                } else {
                    BlockedClassActionSheet(
                        icon: "photo.on.rectangle.angled",
                        title: "Создание альбомов закрыто",
                        detail: "Альбомы класса создает учитель или родкомитет. Родитель может смотреть фото, скачивать и жаловаться на спорные материалы."
                    )
                }
            }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Класс \(selectedChild.className)")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(SchoolTheme.graphite)
                Text("\(selectedChild.name): \(selectedChild.parentRoleTitle.lowercased()), код \(selectedChild.classCode)")
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
                    Text("\(selectedChild.school). Сегодня: \(feedItems.count) объявления, \(activeDigestCount) задачи, \(collectionCountText)")
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
                                .disabled(!activeUserRole.canPublishAnnouncements)
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
            if !activeUserRole.canManageCollections {
                roleRestrictionCard(
                    title: "Вы вошли как родитель",
                    detail: "Можно смотреть сборы и отметить оплату своей семьи. Общий счетчик, чеки и отчет ведет родкомитет.",
                    iconName: "lock.shield.fill",
                    color: SchoolTheme.accent
                )
            }

            if activeUserRole.canManageCollections {
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
        VStack(spacing: 12) {
            DashboardCard {
                HStack(spacing: 12) {
                    collectionMetric(value: "\(photoAlbums.count)", title: "альбома", color: SchoolTheme.accent)
                    Divider()
                    collectionMetric(value: "\(photoAlbums.reduce(0) { $0 + $1.photos.count })", title: "фото", color: SchoolTheme.success)
                    Divider()
                    collectionMetric(value: "закрыт", title: "доступ", color: SchoolTheme.teal)
                }
                .frame(height: 62)
            }

            roleRestrictionCard(
                title: "Только участники класса",
                detail: "Фото и документы класса видны только тем, кто находится в закрытой комнате класса. Публичной ссылки на альбомы нет.",
                iconName: "lock.shield.fill",
                color: SchoolTheme.teal
            )

            if canManagePhotoAlbums {
                Button {
                    activeSheet = .newPhotoAlbum
                } label: {
                    Label("Создать альбом", systemImage: "plus")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 52)
                }
                .buttonStyle(.borderedProminent)
                .tint(SchoolTheme.accent)
            } else {
                roleRestrictionCard(
                    title: "Альбомы ведет класс",
                    detail: "Обычный родитель может смотреть, скачивать и отправлять жалобы. Создание альбомов доступно учителю и родкомитету.",
                    iconName: "photo.badge.plus",
                    color: SchoolTheme.accent
                )
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(photoAlbums) { album in
                    Button {
                        activeSheet = .photoAlbum(album)
                    } label: {
                        photoTile(album)
                    }
                    .buttonStyle(.plain)
                }
            }
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
                        memberAccessRow(member, canManage: activeUserRole.canInviteMembers)
                    }
                }
            }

            if activeUserRole.canInviteMembers {
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

    private func photoTile(_ album: PhotoAlbumSummary) -> some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 18) {
                IconBadge(systemName: album.iconName, color: color(for: album.colorName))
                VStack(alignment: .leading, spacing: 5) {
                    Text(album.title)
                        .font(.headline)
                        .foregroundStyle(SchoolTheme.graphite)
                        .lineLimit(1)
                    Text("\(album.photos.count) фото")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(color(for: album.colorName))
                    Text(album.subtitle)
                        .font(.caption)
                        .foregroundStyle(SchoolTheme.muted)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func memberAccessRow(_ member: ClassMemberSummary, canManage: Bool) -> some View {
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
            if canManage {
                Menu {
                    Button {
                        updateMember(member, role: "Родитель")
                    } label: {
                        Label("Сделать родителем", systemImage: "person.fill")
                    }

                    Button {
                        updateMember(member, role: "Родкомитет")
                    } label: {
                        Label("Сделать родкомитетом", systemImage: "person.2.badge.gearshape.fill")
                    }

                    Button {
                        updateMember(member, role: "Учитель")
                    } label: {
                        Label("Сделать учителем", systemImage: "graduationcap.fill")
                    }

                    Button {
                        transferAdmin(to: member)
                    } label: {
                        Label("Передать админа", systemImage: "checkmark.shield.fill")
                    }
                    .disabled(member.role == "Админ класса")

                    Divider()

                    Button {
                        toggleMemberAccess(member)
                    } label: {
                        Label(member.status.contains("Отключен") ? "Вернуть доступ" : "Отключить доступ", systemImage: "lock.rotation")
                    }

                    Button(role: .destructive) {
                        removeMember(member)
                    } label: {
                        Label("Удалить участника", systemImage: "trash")
                    }
                    .disabled(member.role == "Админ класса" && adminCount <= 1)
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.title3)
                        .foregroundStyle(SchoolTheme.muted)
                }
                .accessibilityLabel("Управление участником")
            }
        }
    }

    private var adminCount: Int {
        members.filter { $0.role == "Админ класса" }.count
    }

    private func updateMember(_ member: ClassMemberSummary, role: String) {
        guard let index = members.firstIndex(where: { $0.id == member.id }) else {
            return
        }

        members[index].role = role
        members[index].canManage = role == "Родкомитет" || role == "Учитель" || role == "Админ класса"
        members[index].status = members[index].status.contains("Отключен") ? "Подключен" : members[index].status
        ClassRoomLocalStore.members = members
    }

    private func transferAdmin(to member: ClassMemberSummary) {
        guard let newAdminIndex = members.firstIndex(where: { $0.id == member.id }) else {
            return
        }

        for index in members.indices where members[index].role == "Админ класса" {
            members[index].role = "Родкомитет"
            members[index].canManage = true
        }

        members[newAdminIndex].role = "Админ класса"
        members[newAdminIndex].canManage = true
        members[newAdminIndex].status = "Подключен"
        ClassRoomLocalStore.members = members
    }

    private func toggleMemberAccess(_ member: ClassMemberSummary) {
        guard let index = members.firstIndex(where: { $0.id == member.id }) else {
            return
        }

        members[index].status = members[index].status.contains("Отключен") ? "Подключен" : "Отключен"
        ClassRoomLocalStore.members = members
    }

    private func removeMember(_ member: ClassMemberSummary) {
        guard !(member.role == "Админ класса" && adminCount <= 1) else {
            return
        }

        members.removeAll { $0.id == member.id }
        ClassRoomLocalStore.members = members
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

    private func updatePhotoAlbum(_ updatedAlbum: PhotoAlbumSummary) {
        guard let index = photoAlbums.firstIndex(where: { $0.id == updatedAlbum.id }) else {
            return
        }

        photoAlbums[index] = updatedAlbum
        ClassRoomLocalStore.photoAlbums = photoAlbums
    }

    private func openCreateAction() {
        switch selectedSection {
        case .collections:
            if activeUserRole.canManageCollections {
                activeSheet = .addCollection
            }
        case .feed, .chats:
            if activeUserRole.canPublishAnnouncements {
                activeSheet = .newAnnouncement
            }
        case .photos:
            if canManagePhotoAlbums {
                activeSheet = .newPhotoAlbum
            }
        case .members:
            if activeUserRole.canInviteMembers {
                activeSheet = .inviteMembers
            }
        }
    }

    private var canUseHeaderCreateAction: Bool {
        switch selectedSection {
        case .collections:
            activeUserRole.canManageCollections
        case .feed, .chats:
            activeUserRole.canPublishAnnouncements
        case .members:
            activeUserRole.canInviteMembers
        case .photos:
            canManagePhotoAlbums
        }
    }

    private var selectedChild: ChildSummary {
        AppChildStore.selectedChild
    }

    private var activeUserRole: AppUserRole {
        if selectedChild.parentRoleTitle == "Родкомитет" {
            return .parentCommittee
        }

        return userRole
    }

    private var canManagePhotoAlbums: Bool {
        activeUserRole == .parentCommittee || activeUserRole == .teacher
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
        case "orange":
            SchoolTheme.warning
        case "blue":
            SchoolTheme.accent
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

        if arguments.contains("-qa-photo-album-create") {
            return .newPhotoAlbum
        }

        if arguments.contains("-qa-photo-album")
            || arguments.contains("-qa-photo-viewer")
            || arguments.contains("-qa-class-photo-dialog")
            || arguments.contains("-qa-class-photo-file-importer"),
           let firstAlbum = PhotoAlbumSummary.sample.first {
            return .photoAlbum(firstAlbum)
        }

        return nil
    }
}

private struct PhotoAlbumSheet: View {
    @Environment(\.dismiss) private var dismiss

    let userRole: AppUserRole
    let onSave: (PhotoAlbumSummary) -> Void

    @State private var album: PhotoAlbumSummary
    @State private var newTitle = "Фото с мероприятия"
    @State private var attachmentStatus: String?
    @State private var isPhotoDialogVisible = false
    @State private var isImagePickerVisible = false
    @State private var isFileImporterVisible = false
    @State private var photoPickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedPhoto: ClassPhotoItem?

    init(album: PhotoAlbumSummary, userRole: AppUserRole, onSave: @escaping (PhotoAlbumSummary) -> Void) {
        self.userRole = userRole
        self.onSave = onSave
        _album = State(initialValue: album)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    CollectionSheetHeader(
                        icon: album.iconName,
                        color: color(for: album.colorName),
                        title: album.title,
                        subtitle: album.subtitle
                    )

                    DashboardCard {
                        HStack(spacing: 12) {
                            albumMetric(value: "\(album.photos.count)", title: "фото", color: color(for: album.colorName))
                            Divider()
                            albumMetric(value: "закрыт", title: "доступ", color: SchoolTheme.teal)
                            Divider()
                            albumMetric(value: "\(reportedCount)", title: "жалоб", color: SchoolTheme.danger)
                        }
                        .frame(height: 62)
                    }

                    DashboardCard {
                        HStack(spacing: 12) {
                            IconBadge(systemName: "lock.shield.fill", color: SchoolTheme.teal, size: 42)
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Доступ только классу")
                                    .font(.headline)
                                    .foregroundStyle(SchoolTheme.graphite)
                                Text("Фото не публикуются наружу. Жалоба помечает фото для модерации администратором класса.")
                                    .font(.caption)
                                    .foregroundStyle(SchoolTheme.muted)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            Spacer()
                        }
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Фото")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            if album.photos.isEmpty {
                                emptyPhotoRow
                            } else {
                                photoStrip

                                ForEach(album.photos) { photo in
                                    Button {
                                        selectedPhoto = photo
                                    } label: {
                                        photoRow(photo)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }

                    DashboardCard {
                        VStack(spacing: 12) {
                            CollectionTextField(title: "Название", iconName: "text.badge.plus", color: color(for: album.colorName), text: $newTitle)

                            if let attachmentStatus {
                                Label(attachmentStatus, systemImage: "checkmark.circle.fill")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(SchoolTheme.success)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            HStack(spacing: 10) {
                                Button {
                                    isPhotoDialogVisible = true
                                } label: {
                                    Label("Фото", systemImage: "camera.fill")
                                        .font(.caption.weight(.semibold))
                                        .frame(maxWidth: .infinity, minHeight: 42)
                                }
                                .buttonStyle(.bordered)
                                .tint(SchoolTheme.success)

                                Button {
                                    isFileImporterVisible = true
                                } label: {
                                    Label("Файл", systemImage: "paperclip")
                                        .font(.caption.weight(.semibold))
                                        .frame(maxWidth: .infinity, minHeight: 42)
                                }
                                .buttonStyle(.bordered)
                                .tint(SchoolTheme.accent)
                            }

                            Button {
                                addPhoto()
                            } label: {
                                Label("Добавить в альбом", systemImage: "plus")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, minHeight: 48)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(color(for: album.colorName))
                            .disabled(newTitle.trimmed.isEmpty)
                        }
                    }

                    Button {
                        save()
                    } label: {
                        Label("Готово", systemImage: "checkmark")
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
            .navigationTitle("Альбом")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        save()
                    }
                }
                KeyboardDoneToolbar()
            }
            .confirmationDialog("Добавить фото", isPresented: $isPhotoDialogVisible, titleVisibility: .visible) {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    Button("Сделать фото") {
                        showPhotoPicker(.camera)
                    }
                }

                Button("Выбрать из галереи") {
                    showPhotoPicker(.photoLibrary)
                }

                Button("Отмена", role: .cancel) {}
            } message: {
                Text("Фото будет добавлено только в закрытый альбом класса.")
            }
            .sheet(isPresented: $isImagePickerVisible) {
                ClassAlbumPhotoPicker(sourceType: photoPickerSource) { displayName in
                    attachmentStatus = "Фото выбрано: \(displayName)"
                }
            }
            .sheet(item: $selectedPhoto) { photo in
                PhotoViewerSheet(
                    album: album,
                    selectedPhoto: photo,
                    canDelete: canDeletePhotos,
                    onUpdateStatus: update(_:status:),
                    onDelete: delete(_:)
                )
            }
            .fileImporter(
                isPresented: $isFileImporterVisible,
                allowedContentTypes: [.image, .pdf, .item],
                allowsMultipleSelection: false
            ) { result in
                handleFileImport(result)
            }
            .onAppear {
                runQAImporterChecks()
            }
        }
    }

    private var canDeletePhotos: Bool {
        userRole == .parentCommittee || userRole == .teacher
    }

    private var reportedCount: Int {
        album.photos.filter { $0.status == "Жалоба" }.count
    }

    private var emptyPhotoRow: some View {
        HStack(spacing: 12) {
            IconBadge(systemName: "photo.on.rectangle.angled", color: SchoolTheme.muted, size: 40)
            Text("В альбоме пока нет фото")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(SchoolTheme.muted)
            Spacer()
        }
    }

    private var photoStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(album.photos) { photo in
                    Button {
                        selectedPhoto = photo
                    } label: {
                        photoPreviewCard(photo, compact: true)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 2)
        }
    }

    private func photoRow(_ photo: ClassPhotoItem) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                photoPreviewCard(photo, compact: false)
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 7) {
                        Text(photo.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(SchoolTheme.graphite)
                            .fixedSize(horizontal: false, vertical: true)
                        StatusBadge(text: photo.status, color: statusColor(photo.status))
                    }
                    Text("\(photo.author) - \(photo.dateLabel)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(SchoolTheme.muted)
                    if let attachment = photo.attachment {
                        Text(attachment)
                            .font(.caption)
                            .foregroundStyle(SchoolTheme.muted)
                            .lineLimit(2)
                    }
                }
                Spacer()
            }

            HStack(spacing: 8) {
                photoAction("Скачать", "arrow.down.circle.fill", SchoolTheme.success) {
                    update(photo, status: "Скачано")
                }
                photoAction("Поделиться", "square.and.arrow.up.fill", SchoolTheme.accent) {
                    update(photo, status: "Поделиться")
                }
                photoAction("Жалоба", "exclamationmark.bubble.fill", SchoolTheme.danger) {
                    update(photo, status: "Жалоба")
                }
                if canDeletePhotos {
                    photoAction("Удалить", "trash.fill", SchoolTheme.warning) {
                        delete(photo)
                    }
                } else {
                    lockedDeleteHint
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

    private var lockedDeleteHint: some View {
        Image(systemName: "lock.fill")
            .font(.caption.weight(.bold))
            .foregroundStyle(SchoolTheme.muted)
            .frame(maxWidth: .infinity, minHeight: 34)
            .background(SchoolTheme.muted.opacity(0.10), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
            .accessibilityLabel("Удаление доступно учителю и родкомитету")
    }

    private func photoPreviewCard(_ photo: ClassPhotoItem, compact: Bool) -> some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: compact ? 14 : 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            color(for: photo.colorName).opacity(0.95),
                            color(for: photo.colorName).opacity(0.45),
                            SchoolTheme.graphite.opacity(0.18)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Image(systemName: "photo.fill")
                .font(.system(size: compact ? 28 : 32, weight: .bold))
                .foregroundStyle(.white.opacity(0.86))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

            if !compact {
                Text(photo.dateLabel)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(.black.opacity(0.20), in: Capsule())
                    .padding(8)
            }
        }
        .frame(width: compact ? 112 : 76, height: compact ? 86 : 76)
        .overlay {
            RoundedRectangle(cornerRadius: compact ? 14 : 16, style: .continuous)
                .stroke(.white.opacity(0.55), lineWidth: 1)
        }
    }

    private func photoAction(_ title: String, _ icon: String, _ color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(color)
                .frame(maxWidth: .infinity, minHeight: 34)
                .background(color.opacity(0.10), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }

    private func albumMetric(value: String, title: String, color: Color) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(color)
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity)
    }

    private func addPhoto() {
        album.photos.insert(
            ClassPhotoItem(
                title: newTitle.trimmed,
                author: userRole.title,
                dateLabel: "Сегодня",
                attachment: attachmentStatus,
                colorName: album.colorName
            ),
            at: 0
        )
        newTitle = ""
        attachmentStatus = nil
        onSave(album)
    }

    private func update(_ photo: ClassPhotoItem, status: String) {
        guard let index = album.photos.firstIndex(where: { $0.id == photo.id }) else {
            return
        }

        album.photos[index].status = status
        onSave(album)
    }

    private func delete(_ photo: ClassPhotoItem) {
        guard canDeletePhotos else {
            return
        }

        album.photos.removeAll { $0.id == photo.id }
        if selectedPhoto?.id == photo.id {
            selectedPhoto = nil
        }
        onSave(album)
    }

    private func save() {
        onSave(album)
        dismiss()
    }

    private func showPhotoPicker(_ sourceType: UIImagePickerController.SourceType) {
        photoPickerSource = sourceType
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

            attachmentStatus = "Файл выбран: \(url.lastPathComponent.isEmpty ? "документ" : url.lastPathComponent)"
        case .failure:
            attachmentStatus = "Не удалось выбрать файл"
        }
    }

    private func statusColor(_ status: String) -> Color {
        switch status {
        case "Скачано":
            SchoolTheme.success
        case "Поделиться":
            SchoolTheme.accent
        case "Жалоба":
            SchoolTheme.danger
        default:
            color(for: album.colorName)
        }
    }

    private func color(for colorName: String) -> Color {
        switch colorName {
        case "green":
            SchoolTheme.success
        case "teal":
            SchoolTheme.teal
        case "orange":
            SchoolTheme.warning
        default:
            SchoolTheme.accent
        }
    }

    private func runQAImporterChecks() {
        let arguments = ProcessInfo.processInfo.arguments

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            if arguments.contains("-qa-class-photo-dialog") {
                isPhotoDialogVisible = true
            }

            if arguments.contains("-qa-class-photo-file-importer") {
                isFileImporterVisible = true
            }

            if arguments.contains("-qa-photo-viewer") {
                selectedPhoto = album.photos.first
            }
        }
    }
}

private struct NewPhotoAlbumSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: (PhotoAlbumSummary) -> Void

    @State private var title = "Новый альбом"
    @State private var subtitle = "Фото события, урока или документов класса"
    @State private var selectedTemplate = PhotoAlbumTemplate.event

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    CollectionSheetHeader(
                        icon: selectedTemplate.iconName,
                        color: selectedTemplate.color,
                        title: "Новый альбом",
                        subtitle: "Закрыт для участников класса"
                    )

                    DashboardCard {
                        VStack(spacing: 12) {
                            CollectionTextField(title: "Название", iconName: "text.badge.plus", color: selectedTemplate.color, text: $title)
                            CollectionTextField(title: "Описание", iconName: "text.alignleft", color: SchoolTheme.teal, text: $subtitle)
                        }
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Тип альбома")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                ForEach(PhotoAlbumTemplate.allCases) { template in
                                    Button {
                                        selectedTemplate = template
                                    } label: {
                                        HStack(spacing: 10) {
                                            IconBadge(systemName: template.iconName, color: template.color, size: 34)
                                            Text(template.title)
                                                .font(.caption.weight(.semibold))
                                                .foregroundStyle(SchoolTheme.graphite)
                                                .lineLimit(1)
                                            Spacer(minLength: 0)
                                            if selectedTemplate == template {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundStyle(template.color)
                                            }
                                        }
                                        .padding(10)
                                        .background(template.color.opacity(selectedTemplate == template ? 0.16 : 0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                .stroke(selectedTemplate == template ? template.color.opacity(0.45) : SchoolTheme.line, lineWidth: 1)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    roleHint

                    Button {
                        save()
                    } label: {
                        Label("Создать альбом", systemImage: "checkmark")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 52)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(selectedTemplate.color)
                    .disabled(title.trimmed.isEmpty || subtitle.trimmed.isEmpty)
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Альбом")
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

    private var roleHint: some View {
        DashboardCard {
            HStack(spacing: 12) {
                IconBadge(systemName: "lock.shield.fill", color: SchoolTheme.teal, size: 42)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Доступ закрыт")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SchoolTheme.graphite)
                    Text("После создания альбом видят только участники класса. Фото можно добавить внутри альбома.")
                        .font(.caption)
                        .foregroundStyle(SchoolTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
        }
    }

    private func save() {
        onSave(
            PhotoAlbumSummary(
                title: title.trimmed,
                subtitle: subtitle.trimmed,
                iconName: selectedTemplate.iconName,
                colorName: selectedTemplate.colorName,
                photos: []
            )
        )
        dismiss()
    }
}

private enum PhotoAlbumTemplate: String, CaseIterable, Identifiable {
    case event
    case holiday
    case classroom
    case documents

    var id: String { rawValue }

    var title: String {
        switch self {
        case .event:
            "Событие"
        case .holiday:
            "Праздник"
        case .classroom:
            "Будни"
        case .documents:
            "Документы"
        }
    }

    var iconName: String {
        switch self {
        case .event:
            "photo.on.rectangle"
        case .holiday:
            "party.popper"
        case .classroom:
            "camera"
        case .documents:
            "doc.text"
        }
    }

    var colorName: String {
        switch self {
        case .event:
            "blue"
        case .holiday:
            "orange"
        case .classroom:
            "teal"
        case .documents:
            "green"
        }
    }

    var color: Color {
        switch self {
        case .event:
            SchoolTheme.accent
        case .holiday:
            SchoolTheme.warning
        case .classroom:
            SchoolTheme.teal
        case .documents:
            SchoolTheme.success
        }
    }
}

private struct PhotoViewerSheet: View {
    @Environment(\.dismiss) private var dismiss

    let album: PhotoAlbumSummary
    let selectedPhoto: ClassPhotoItem
    let canDelete: Bool
    let onUpdateStatus: (ClassPhotoItem, String) -> Void
    let onDelete: (ClassPhotoItem) -> Void

    @State private var selectedPhotoID: UUID

    init(
        album: PhotoAlbumSummary,
        selectedPhoto: ClassPhotoItem,
        canDelete: Bool,
        onUpdateStatus: @escaping (ClassPhotoItem, String) -> Void,
        onDelete: @escaping (ClassPhotoItem) -> Void
    ) {
        self.album = album
        self.selectedPhoto = selectedPhoto
        self.canDelete = canDelete
        self.onUpdateStatus = onUpdateStatus
        self.onDelete = onDelete
        _selectedPhotoID = State(initialValue: selectedPhoto.id)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                TabView(selection: $selectedPhotoID) {
                    ForEach(album.photos) { photo in
                        photoPage(photo)
                            .tag(photo.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .automatic))

                actionBar
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle(album.title)
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

    private var activePhoto: ClassPhotoItem {
        album.photos.first { $0.id == selectedPhotoID } ?? selectedPhoto
    }

    private var actionBar: some View {
        HStack(spacing: 10) {
            viewerAction("Скачать", "arrow.down.circle.fill", SchoolTheme.success) {
                onUpdateStatus(activePhoto, "Скачано")
            }
            viewerAction("Поделиться", "square.and.arrow.up.fill", SchoolTheme.accent) {
                onUpdateStatus(activePhoto, "Поделиться")
            }
            viewerAction("Жалоба", "exclamationmark.bubble.fill", SchoolTheme.danger) {
                onUpdateStatus(activePhoto, "Жалоба")
            }

            if canDelete {
                viewerAction("Удалить", "trash.fill", SchoolTheme.warning) {
                    onDelete(activePhoto)
                    dismiss()
                }
            } else {
                Label("Удаляет учитель или родкомитет", systemImage: "lock.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SchoolTheme.muted)
                    .frame(maxWidth: .infinity, minHeight: 42)
                    .background(SchoolTheme.muted.opacity(0.10), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
            }
        }
    }

    private func photoPage(_ photo: ClassPhotoItem) -> some View {
        VStack(spacing: 16) {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                color(for: photo.colorName).opacity(0.95),
                                color(for: photo.colorName).opacity(0.48),
                                SchoolTheme.graphite.opacity(0.20)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .aspectRatio(0.78, contentMode: .fit)

                Image(systemName: "photo.fill")
                    .font(.system(size: 72, weight: .bold))
                    .foregroundStyle(.white.opacity(0.86))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                VStack(alignment: .leading, spacing: 8) {
                    StatusBadge(text: photo.status, color: statusColor(photo.status, fallback: color(for: photo.colorName)))
                    Text(photo.title)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("\(photo.author) - \(photo.dateLabel)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.86))
                    if let attachment = photo.attachment {
                        Label(attachment, systemImage: "paperclip")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.86))
                            .lineLimit(2)
                    }
                }
                .padding(18)
            }
            .padding(.horizontal, 20)

            Text("\(photoIndex(photo)) из \(album.photos.count)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(SchoolTheme.muted)
        }
    }

    private func viewerAction(_ title: String, _ icon: String, _ color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.headline.weight(.bold))
                .foregroundStyle(color)
                .frame(maxWidth: .infinity, minHeight: 42)
                .background(color.opacity(0.10), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }

    private func photoIndex(_ photo: ClassPhotoItem) -> Int {
        (album.photos.firstIndex(where: { $0.id == photo.id }) ?? 0) + 1
    }

    private func statusColor(_ status: String, fallback: Color) -> Color {
        switch status {
        case "Скачано":
            SchoolTheme.success
        case "Поделиться":
            SchoolTheme.accent
        case "Жалоба":
            SchoolTheme.danger
        default:
            fallback
        }
    }

    private func color(for colorName: String) -> Color {
        switch colorName {
        case "green":
            SchoolTheme.success
        case "teal":
            SchoolTheme.teal
        case "orange":
            SchoolTheme.warning
        default:
            SchoolTheme.accent
        }
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
    @State private var attachmentStatus: String?
    @State private var isPhotoSourceDialogVisible = false
    @State private var isPhotoPickerVisible = false
    @State private var isFileImporterVisible = false
    @State private var photoPickerSource: UIImagePickerController.SourceType = .photoLibrary

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
            ScrollViewReader { proxy in
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
                        .id("collection-save-button")
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
                .confirmationDialog("Добавить фото чека", isPresented: $isPhotoSourceDialogVisible, titleVisibility: .visible) {
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        Button("Сделать фото") {
                            showPhotoPicker(.camera)
                        }
                    }

                    Button("Выбрать из галереи") {
                        showPhotoPicker(.photoLibrary)
                    }

                    Button("Отмена", role: .cancel) {}
                } message: {
                    Text("Фото будет прикреплено к новому расходу.")
                }
                .sheet(isPresented: $isPhotoPickerVisible) {
                    ReceiptPhotoPicker(sourceType: photoPickerSource) { displayName in
                        expenseAttachment = "Фото: \(displayName)"
                        attachmentStatus = "Фото прикреплено"
                    }
                }
                .fileImporter(
                    isPresented: $isFileImporterVisible,
                    allowedContentTypes: [.pdf, .image, .item],
                    allowsMultipleSelection: false
                ) { result in
                    handleReceiptFileImport(result)
                }
                .onAppear {
                    runQACollectionDetailChecks(proxy)
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
                HStack {
                    Text("Чеки и отчет")
                        .font(.headline)
                        .foregroundStyle(SchoolTheme.graphite)
                    Spacer()
                    StatusBadge(text: status.rawValue, color: collectionStatusColor(status))
                }

                VStack(spacing: 10) {
                    HStack(spacing: 10) {
                        reportMetric("Сдали", "\(paidCount)/\(collection.totalCount)", "checkmark.circle.fill", SchoolTheme.success)
                        reportMetric("Осталось", "\(max(0, collection.totalCount - paidCount))", "person.2.badge.clock.fill", SchoolTheme.warning)
                    }

                    HStack(spacing: 10) {
                        reportMetric("Сбор", "\(paidCount) x \(collection.amount)", "rublesign.circle.fill", SchoolTheme.accent)
                        reportMetric("Расходы", "\(expenses.count)", "receipt.fill", SchoolTheme.teal)
                    }
                }

                ShareLink(item: collectionReportText) {
                    Label("Поделиться отчетом", systemImage: "square.and.arrow.up")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: 46)
                }
                .buttonStyle(.bordered)
                .tint(SchoolTheme.accent)
                .id("collection-report-actions")

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
                                Label(expenseAttachment?.contains("Фото") == true ? "Фото выбрано" : "Фото чека", systemImage: "camera.fill")
                                    .font(.caption.weight(.semibold))
                                    .frame(maxWidth: .infinity, minHeight: 42)
                            }
                            .buttonStyle(.bordered)
                            .tint(expenseAttachment?.contains("Фото") == true ? SchoolTheme.success : SchoolTheme.accent)

                            Button {
                                isFileImporterVisible = true
                            } label: {
                                Label(expenseAttachment?.contains("Файл") == true ? "Файл выбран" : "Файл", systemImage: "paperclip")
                                    .font(.caption.weight(.semibold))
                                    .frame(maxWidth: .infinity, minHeight: 42)
                            }
                            .buttonStyle(.bordered)
                            .tint(expenseAttachment?.contains("Файл") == true ? SchoolTheme.success : SchoolTheme.accent)
                        }

                        if let attachmentStatus {
                            Label(attachmentStatus, systemImage: "checkmark.circle.fill")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(SchoolTheme.success)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .id("expense-form")

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
                    .id("expense-actions")
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

    private func reportMetric(_ title: String, _ value: String, _ iconName: String, _ color: Color) -> some View {
        HStack(spacing: 10) {
            IconBadge(systemName: iconName, color: color, size: 34)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SchoolTheme.muted)
                    .lineLimit(1)
                Text(value)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(SchoolTheme.graphite)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            Spacer(minLength: 0)
        }
        .padding(10)
        .frame(maxWidth: .infinity, minHeight: 58, alignment: .leading)
        .background(color.opacity(0.08), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func runQACollectionDetailChecks(_ proxy: ScrollViewProxy) {
        let arguments = ProcessInfo.processInfo.arguments
        guard
            arguments.contains("-qa-scroll-expenses")
                || arguments.contains("-qa-receipt-photo-dialog")
                || arguments.contains("-qa-receipt-file-importer")
                || arguments.contains("-qa-collection-report")
        else {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.easeInOut(duration: 0.2)) {
                proxy.scrollTo(arguments.contains("-qa-collection-report") ? "collection-report-actions" : "expense-actions", anchor: .bottom)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            if arguments.contains("-qa-receipt-photo-dialog") {
                isPhotoSourceDialogVisible = true
            }

            if arguments.contains("-qa-receipt-file-importer") {
                isFileImporterVisible = true
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
        attachmentStatus = nil
        onSave(updatedCollectionSnapshot())
    }

    private func addReceiptPhoto() {
        isPhotoSourceDialogVisible = true
    }

    private func showPhotoPicker(_ sourceType: UIImagePickerController.SourceType) {
        photoPickerSource = sourceType
        isPhotoPickerVisible = true
    }

    private func handleReceiptFileImport(_ result: Result<[URL], Error>) {
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
            expenseAttachment = "Файл: \(fileName)"
            attachmentStatus = "Файл прикреплен"
        case .failure:
            attachmentStatus = "Не удалось прикрепить файл"
        }
    }

    private func save() {
        onSave(updatedCollectionSnapshot())
        dismiss()
    }

    private var collectionReportText: String {
        let paymentLine = "Оплачено: \(paidCount) из \(collection.totalCount), осталось \(max(0, collection.totalCount - paidCount))"
        let expensesLines: [String]

        if expenses.isEmpty {
            expensesLines = ["Расходы: пока не добавлены"]
        } else {
            expensesLines = expenses.map { expense in
                let attachment = expense.attachment.map { " / \($0)" } ?? ""
                return "- \(expense.title): \(expense.amount), \(expense.note)\(attachment)"
            }
        }

        return [
            "Отчет по сбору: \(collection.title)",
            "Сумма с семьи: \(collection.amount)",
            "Дедлайн: \(collection.deadline)",
            "Кому сдавать: \(collection.recipient)",
            "Статус: \(status.rawValue)",
            paymentLine,
            "Описание: \(collection.detail)",
            "Чеки и расходы:",
            expensesLines.joined(separator: "\n")
        ].joined(separator: "\n")
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

private struct ReceiptPhotoPicker: UIViewControllerRepresentable {
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
        let parent: ReceiptPhotoPicker

        init(parent: ReceiptPhotoPicker) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            let pickedURL = info[.imageURL] as? URL
            let defaultName = parent.sourceType == .camera ? "снимок \(Date().receiptAttachmentTimestamp)" : "фото чека"
            parent.onPick(pickedURL?.lastPathComponent ?? defaultName)
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

private struct ClassAlbumPhotoPicker: UIViewControllerRepresentable {
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
        let parent: ClassAlbumPhotoPicker

        init(parent: ClassAlbumPhotoPicker) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            let pickedURL = info[.imageURL] as? URL
            let defaultName = parent.sourceType == .camera ? "снимок \(Date().classPhotoTimestamp)" : "фото класса"
            parent.onPick(pickedURL?.lastPathComponent ?? defaultName)
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

private extension Date {
    var receiptAttachmentTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM HH:mm"
        return formatter.string(from: self)
    }

    var classPhotoTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM HH:mm"
        return formatter.string(from: self)
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
                    pinnedMessagesCard
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
                chatMetric(value: "\(messages.count)", title: "сообщ.", color: SchoolTheme.accent)
                Divider()
                chatMetric(value: "\(messages.filter(\.isImportant).count)", title: "важные", color: SchoolTheme.warning)
                Divider()
                chatMetric(value: "\(messages.filter(\.isPinned).count)", title: "пины", color: SchoolTheme.teal)
                Divider()
                chatMetric(value: "\(reactionTotal)", title: "реакции", color: SchoolTheme.success)
            }
            .frame(height: 62)
        }
    }

    @ViewBuilder
    private var pinnedMessagesCard: some View {
        let pinnedMessages = messages.filter(\.isPinned)
        if !pinnedMessages.isEmpty {
            DashboardCard {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Закреплено", systemImage: "pin.fill")
                        .font(.headline)
                        .foregroundStyle(SchoolTheme.graphite)

                    ForEach(pinnedMessages) { message in
                        HStack(alignment: .top, spacing: 10) {
                            IconBadge(systemName: "pin.fill", color: SchoolTheme.teal, size: 34)
                            VStack(alignment: .leading, spacing: 5) {
                                Text(message.author)
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(SchoolTheme.graphite)
                                Text(message.text)
                                    .font(.caption)
                                    .foregroundStyle(SchoolTheme.muted)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
            }
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
                    if message.isPinned {
                        StatusBadge(text: "Закреплено", color: SchoolTheme.teal)
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

                LazyVGrid(columns: reactionColumns, alignment: .leading, spacing: 8) {
                    Button {
                        togglePin(for: message)
                    } label: {
                        Label(message.isPinned ? "Открепить" : "Закрепить", systemImage: message.isPinned ? "pin.slash.fill" : "pin.fill")
                            .font(.caption.weight(.semibold))
                    }
                    .buttonStyle(.bordered)
                    .tint(message.isPinned ? SchoolTheme.teal : SchoolTheme.muted)

                    ForEach(reactionOptions, id: \.self) { iconName in
                        Button {
                            toggleReaction(iconName, for: message)
                        } label: {
                            Label("\(message.reactions[iconName, default: 0])", systemImage: iconName)
                                .font(.caption.weight(.semibold))
                        }
                        .buttonStyle(.bordered)
                        .tint(reactionColor(for: iconName))
                    }
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

    private func togglePin(for message: ClassChatMessage) {
        guard let index = messages.firstIndex(where: { $0.id == message.id }) else {
            return
        }

        messages[index].isPinned.toggle()
    }

    private func toggleReaction(_ iconName: String, for message: ClassChatMessage) {
        guard let index = messages.firstIndex(where: { $0.id == message.id }) else {
            return
        }

        messages[index].reactions[iconName, default: 0] += 1
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

    private var reactionOptions: [String] {
        ["checkmark.circle.fill", "heart.fill", "hand.raised.fill"]
    }

    private var reactionColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 86), spacing: 8)]
    }

    private var reactionTotal: Int {
        messages.reduce(0) { total, message in
            total + message.reactions.values.reduce(0, +)
        }
    }

    private func reactionColor(for iconName: String) -> Color {
        switch iconName {
        case "heart.fill":
            SchoolTheme.danger
        case "hand.raised.fill":
            SchoolTheme.warning
        default:
            SchoolTheme.success
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
    let userRole: AppUserRole
    let onSave: (FeedItem) -> Void

    @State private var acknowledged: Bool
    @State private var commentsEnabled: Bool
    @State private var comments: [AnnouncementComment]
    @State private var commentText = "Спасибо, увидели"

    init(item: FeedItem, userRole: AppUserRole, onSave: @escaping (FeedItem) -> Void) {
        self.item = item
        self.userRole = userRole
        self.onSave = onSave
        _acknowledged = State(initialValue: item.isAcknowledged)
        _commentsEnabled = State(initialValue: item.commentsEnabled)
        _comments = State(initialValue: item.comments)
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

                    if userRole.canPublishAnnouncements {
                        DashboardCard {
                            Toggle(isOn: $commentsEnabled) {
                                HStack(spacing: 12) {
                                    IconBadge(systemName: commentsEnabled ? "bubble.left.and.bubble.right.fill" : "bubble.left.slash.fill", color: commentsEnabled ? SchoolTheme.teal : SchoolTheme.muted, size: 42)
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(commentsEnabled ? "Обсуждение открыто" : "Обсуждение закрыто")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(SchoolTheme.graphite)
                                        Text("\(comments.count) комментария")
                                            .font(.caption)
                                            .foregroundStyle(SchoolTheme.muted)
                                    }
                                }
                            }
                            .toggleStyle(.switch)
                            .tint(SchoolTheme.success)
                            .onChange(of: commentsEnabled) {
                                save()
                            }
                        }
                    }

                    commentsCard

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

    private var commentsCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    IconBadge(systemName: "bubble.left.and.bubble.right.fill", color: SchoolTheme.teal, size: 42)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Обсуждение")
                            .font(.headline)
                            .foregroundStyle(SchoolTheme.graphite)
                        Text(commentsEnabled ? "\(comments.count) комментария" : "Комментарии закрыты")
                            .font(.caption)
                            .foregroundStyle(SchoolTheme.muted)
                    }
                    Spacer()
                }

                if comments.isEmpty {
                    HStack(spacing: 12) {
                        IconBadge(systemName: "text.bubble.fill", color: SchoolTheme.muted, size: 38)
                        Text("Комментариев пока нет")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(SchoolTheme.muted)
                        Spacer()
                    }
                } else {
                    VStack(spacing: 12) {
                        ForEach(comments) { comment in
                            commentRow(comment)
                        }
                    }
                }

                if commentsEnabled {
                    VStack(spacing: 10) {
                        CollectionTextField(title: "Комментарий", iconName: "text.bubble.fill", color: SchoolTheme.teal, text: $commentText)

                        Button {
                            addComment()
                        } label: {
                            Label("Добавить комментарий", systemImage: "paperplane.fill")
                                .font(.subheadline.weight(.semibold))
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(SchoolTheme.teal)
                        .disabled(commentText.trimmed.isEmpty)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func commentRow(_ comment: AnnouncementComment) -> some View {
        HStack(alignment: .top, spacing: 12) {
            InitialAvatar(text: String(comment.author.prefix(1)), size: 38)
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(comment.author)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SchoolTheme.graphite)
                    Text(comment.timeLabel)
                        .font(.caption)
                        .foregroundStyle(SchoolTheme.muted)
                }
                Text(comment.text)
                    .font(.subheadline)
                    .foregroundStyle(SchoolTheme.graphite)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
    }

    private func addComment() {
        let comment = AnnouncementComment(author: "Владимир", text: commentText.trimmed, timeLabel: "сейчас")
        comments.append(comment)
        commentText = ""
        save()
    }

    private func save() {
        var updatedItem = item
        updatedItem.isAcknowledged = acknowledged
        updatedItem.commentsEnabled = commentsEnabled
        updatedItem.comments = comments
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
    @State private var commentsEnabled = true

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
                        VStack(spacing: 12) {
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

                            Divider()

                            Toggle(isOn: $commentsEnabled) {
                                HStack(spacing: 12) {
                                    IconBadge(systemName: "bubble.left.and.bubble.right.fill", color: SchoolTheme.teal, size: 42)
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("Разрешить обсуждение")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(SchoolTheme.graphite)
                                        Text("Родители смогут оставить вопросы")
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
            .scrollDismissesKeyboard(.interactively)
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Объявление")
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
        let ackText = requiresAck ? " Нужно подтверждение прочтения." : ""
        let item = FeedItem(
            title: title.trimmed,
            subtitle: bodyText.trimmed + ackText,
            tag: tag,
            commentsEnabled: commentsEnabled
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
    @State private var inviteStatus = "Ссылка готова: можно отправить родителю или учителю"

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
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Ссылка и QR")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            HStack(alignment: .top, spacing: 14) {
                                InviteQRCodeView(text: inviteLink, color: SchoolTheme.graphite)
                                    .frame(width: 98, height: 98)

                                VStack(alignment: .leading, spacing: 7) {
                                    Text(inviteLink)
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(SchoolTheme.graphite)
                                        .lineLimit(3)
                                        .textSelection(.enabled)
                                    Text(inviteStatus)
                                        .font(.caption)
                                        .foregroundStyle(SchoolTheme.muted)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                Spacer()
                            }

                            HStack(spacing: 8) {
                                ShareLink(item: inviteLink) {
                                    Label("Отправить", systemImage: "square.and.arrow.up")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(SchoolTheme.accent)
                                        .frame(maxWidth: .infinity, minHeight: 38)
                                        .background(SchoolTheme.accent.opacity(0.11), in: Capsule())
                                }

                                Button {
                                    inviteCode = nextInviteCode()
                                    inviteStatus = "Код обновлен локально. Старую ссылку нужно будет отозвать на backend."
                                } label: {
                                    Label("Новый код", systemImage: "arrow.clockwise")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(SchoolTheme.warning)
                                        .frame(maxWidth: .infinity, minHeight: 38)
                                        .background(SchoolTheme.warning.opacity(0.11), in: Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
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

    private var inviteLink: String {
        "schoolclass://join?code=\(inviteCode.trimmed.uppercased())&role=\(role.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? role)"
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
        inviteStatus = "Приглашение для \(inviteName.trimmed) добавлено. Ссылку можно отправить через системное меню."
        inviteName = ""
        childName = ""
    }

    private func nextInviteCode() -> String {
        let classPrefix = inviteCode.split(separator: "-").first.map(String.init) ?? "3B"
        let number = Int.random(in: 1000...9999)
        return "\(classPrefix)-\(number)"
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

private struct InviteQRCodeView: View {
    let text: String
    let color: Color

    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()

    var body: some View {
        Group {
            if let image = qrImage {
                Image(uiImage: image)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "qrcode")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(color)
            }
        }
        .padding(10)
        .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(SchoolTheme.line, lineWidth: 1)
        }
        .accessibilityLabel("QR-код приглашения")
    }

    private var qrImage: UIImage? {
        filter.message = Data(text.utf8)
        filter.correctionLevel = "M"

        guard let outputImage = filter.outputImage else {
            return nil
        }

        let scaled = outputImage.transformed(by: CGAffineTransform(scaleX: 8, y: 8))
        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
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
    case photoAlbum(PhotoAlbumSummary)
    case newPhotoAlbum

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
        case .photoAlbum(let album):
            "photo-album-\(album.id.uuidString)"
        case .newPhotoAlbum:
            "new-photo-album"
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
        case .photoAlbum, .newPhotoAlbum:
            .photos
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
