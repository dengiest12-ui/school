import Foundation

enum AppUserRole: String, CaseIterable, Identifiable {
    case parent
    case parentCommittee
    case teacher

    var id: String { rawValue }

    var title: String {
        switch self {
        case .parent:
            "Родитель"
        case .parentCommittee:
            "Родкомитет"
        case .teacher:
            "Учитель"
        }
    }

    var subtitle: String {
        switch self {
        case .parent:
            "ДЗ, события, напоминания и семейные задачи"
        case .parentCommittee:
            "Сборы, приглашения, отчеты и объявления класса"
        case .teacher:
            "Объявления, домашние задания и важные отметки"
        }
    }

    var iconName: String {
        switch self {
        case .parent:
            "figure.2.and.child.holdinghands"
        case .parentCommittee:
            "person.badge.shield.checkmark.fill"
        case .teacher:
            "graduationcap.fill"
        }
    }

    var canManageCollections: Bool {
        self == .parentCommittee
    }

    var canPublishAnnouncements: Bool {
        self == .parentCommittee || self == .teacher
    }

    var canInviteMembers: Bool {
        self == .parentCommittee || self == .teacher
    }
}

struct ChildSummary: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    let className: String
    let school: String
    let avatarText: String

    init(id: UUID = UUID(), name: String, className: String, school: String, avatarText: String) {
        self.id = id
        self.name = name
        self.className = className
        self.school = school
        self.avatarText = avatarText
    }
}

struct HomeworkItem: Identifiable, Hashable, Codable {
    enum Status: String, Codable {
        case pending = "Нужно сделать"
        case done = "Готово"
        case review = "Проверить"
    }

    let id: UUID
    var subject: String
    var title: String
    var dueLabel: String
    var source: String
    var status: Status
    var bring: String?

    init(
        id: UUID = UUID(),
        subject: String,
        title: String,
        dueLabel: String,
        source: String,
        status: Status,
        bring: String?
    ) {
        self.id = id
        self.subject = subject
        self.title = title
        self.dueLabel = dueLabel
        self.source = source
        self.status = status
        self.bring = bring
    }
}

struct ScheduleItem: Identifiable, Hashable {
    let id: UUID
    var day: String
    var time: String
    var title: String
    var detail: String
    var teacher: String
    var requiresForm: Bool
    var isReplacement: Bool

    init(
        id: UUID = UUID(),
        day: String = "Чт",
        time: String,
        title: String,
        detail: String,
        teacher: String = "",
        requiresForm: Bool = false,
        isReplacement: Bool = false
    ) {
        self.id = id
        self.day = day
        self.time = time
        self.title = title
        self.detail = detail
        self.teacher = teacher
        self.requiresForm = requiresForm
        self.isReplacement = isReplacement
    }
}

struct PersonalCircle: Identifiable, Hashable {
    let id: UUID
    var title: String
    var day: String
    var time: String
    var place: String
    var responsible: String
    var iconName: String
    var colorName: String

    init(
        id: UUID = UUID(),
        title: String,
        day: String,
        time: String,
        place: String,
        responsible: String,
        iconName: String,
        colorName: String
    ) {
        self.id = id
        self.title = title
        self.day = day
        self.time = time
        self.place = place
        self.responsible = responsible
        self.iconName = iconName
        self.colorName = colorName
    }
}

struct ChatPreviewItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let message: String
    let timeLabel: String
    let icon: String
    let colorName: String
    let hasUnread: Bool
}

struct ClassChatMessage: Identifiable, Hashable, Codable {
    let id: UUID
    var author: String
    var text: String
    var timeLabel: String
    var isImportant: Bool
    var actionTitle: String?
    var createdTask: Bool

    init(
        id: UUID = UUID(),
        author: String,
        text: String,
        timeLabel: String,
        isImportant: Bool = false,
        actionTitle: String? = nil,
        createdTask: Bool = false
    ) {
        self.id = id
        self.author = author
        self.text = text
        self.timeLabel = timeLabel
        self.isImportant = isImportant
        self.actionTitle = actionTitle
        self.createdTask = createdTask
    }
}

struct ChatThread: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var subtitle: String
    var icon: String
    var colorName: String
    var unreadCount: Int
    var isAnnouncementOnly: Bool
    var messages: [ClassChatMessage]

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        icon: String,
        colorName: String,
        unreadCount: Int,
        isAnnouncementOnly: Bool = false,
        messages: [ClassChatMessage]
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.colorName = colorName
        self.unreadCount = unreadCount
        self.isAnnouncementOnly = isAnnouncementOnly
        self.messages = messages
    }
}

struct ChatDigestItem: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var detail: String
    var source: String
    var iconName: String
    var colorName: String
    var actionTitle: String
    var isDone: Bool

    init(
        id: UUID = UUID(),
        title: String,
        detail: String,
        source: String,
        iconName: String,
        colorName: String,
        actionTitle: String,
        isDone: Bool = false
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.source = source
        self.iconName = iconName
        self.colorName = colorName
        self.actionTitle = actionTitle
        self.isDone = isDone
    }
}

struct DayChip: Identifiable, Hashable {
    let id = UUID()
    let weekday: String
    let day: String
    let isSelected: Bool
}

struct ParentTask: Identifiable, Hashable {
    enum Kind {
        case bring
        case pay
        case sign
        case buy
    }

    let id = UUID()
    let title: String
    let dueLabel: String
    let kind: Kind
}

struct FamilyAccessMember: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var role: String
    var access: String
    var avatarText: String
    var status: String

    init(id: UUID = UUID(), name: String, role: String, access: String, avatarText: String, status: String) {
        self.id = id
        self.name = name
        self.role = role
        self.access = access
        self.avatarText = avatarText
        self.status = status
    }
}

struct ClassAccessSummary: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var school: String
    var role: String
    var inviteCode: String
    var status: String

    init(id: UUID = UUID(), title: String, school: String, role: String, inviteCode: String, status: String) {
        self.id = id
        self.title = title
        self.school = school
        self.role = role
        self.inviteCode = inviteCode
        self.status = status
    }
}

struct ClassMemberSummary: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var childName: String
    var role: String
    var status: String
    var avatarText: String
    var canManage: Bool

    init(id: UUID = UUID(), name: String, childName: String, role: String, status: String, avatarText: String, canManage: Bool) {
        self.id = id
        self.name = name
        self.childName = childName
        self.role = role
        self.status = status
        self.avatarText = avatarText
        self.canManage = canManage
    }
}

struct NotificationPreference: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var detail: String
    var iconName: String
    var colorName: String
    var isEnabled: Bool

    init(id: UUID = UUID(), title: String, detail: String, iconName: String, colorName: String, isEnabled: Bool) {
        self.id = id
        self.title = title
        self.detail = detail
        self.iconName = iconName
        self.colorName = colorName
        self.isEnabled = isEnabled
    }
}

struct SubscriptionPlanSummary: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var price: String
    var detail: String
    var badge: String
    var isCurrent: Bool

    init(id: UUID = UUID(), title: String, price: String, detail: String, badge: String, isCurrent: Bool = false) {
        self.id = id
        self.title = title
        self.price = price
        self.detail = detail
        self.badge = badge
        self.isCurrent = isCurrent
    }
}

struct ClassMemoryEntry: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var detail: String
    var source: String
    var dateLabel: String
    var tag: String
    var iconName: String
    var colorName: String

    init(
        id: UUID = UUID(),
        title: String,
        detail: String,
        source: String,
        dateLabel: String,
        tag: String,
        iconName: String,
        colorName: String
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.source = source
        self.dateLabel = dateLabel
        self.tag = tag
        self.iconName = iconName
        self.colorName = colorName
    }
}

struct ClassFileSummary: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var detail: String
    var category: String
    var owner: String
    var updatedLabel: String
    var status: String
    var iconName: String
    var colorName: String

    init(
        id: UUID = UUID(),
        title: String,
        detail: String,
        category: String,
        owner: String,
        updatedLabel: String,
        status: String,
        iconName: String,
        colorName: String
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.category = category
        self.owner = owner
        self.updatedLabel = updatedLabel
        self.status = status
        self.iconName = iconName
        self.colorName = colorName
    }
}

struct SubscriptionBenefit: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let detail: String
    let iconName: String
    let colorName: String
}

enum EventResponse: String, CaseIterable, Hashable, Codable {
    case undecided = "Жду ответа"
    case going = "Идем"
    case declined = "Не сможем"
    case question = "Есть вопрос"
}

struct EventLinkedCollection: Hashable, Codable {
    var title: String
    var amount: String
    var status: CollectionStatus
}

struct ClassEvent: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var dateLabel: String
    var detail: String
    var type: String
    var place: String
    var response: EventResponse
    var linkedCollection: EventLinkedCollection?

    init(
        id: UUID = UUID(),
        title: String,
        dateLabel: String,
        detail: String,
        type: String = "Событие",
        place: String = "",
        response: EventResponse = .undecided,
        linkedCollection: EventLinkedCollection? = nil
    ) {
        self.id = id
        self.title = title
        self.dateLabel = dateLabel
        self.detail = detail
        self.type = type
        self.place = place
        self.response = response
        self.linkedCollection = linkedCollection
    }
}

enum CollectionStatus: String, CaseIterable, Hashable, Codable {
    case active = "Идет сбор"
    case dueSoon = "Срок близко"
    case closed = "Закрыт"
}

struct CollectionExpense: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var amount: String
    var note: String
    var attachment: String?

    init(id: UUID = UUID(), title: String, amount: String, note: String, attachment: String? = nil) {
        self.id = id
        self.title = title
        self.amount = amount
        self.note = note
        self.attachment = attachment
    }
}

struct CollectionSummary: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var amount: String
    var deadline: String
    var paidCount: Int
    var totalCount: Int
    var recipient: String
    var detail: String
    var status: CollectionStatus
    var expenses: [CollectionExpense]
    var myFamilyPaid: Bool

    init(
        id: UUID = UUID(),
        title: String,
        amount: String,
        deadline: String,
        paidCount: Int,
        totalCount: Int,
        recipient: String,
        detail: String,
        status: CollectionStatus = .active,
        expenses: [CollectionExpense] = [],
        myFamilyPaid: Bool = false
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.deadline = deadline
        self.paidCount = paidCount
        self.totalCount = totalCount
        self.recipient = recipient
        self.detail = detail
        self.status = status
        self.expenses = expenses
        self.myFamilyPaid = myFamilyPaid
    }
}

struct FeedItem: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var subtitle: String
    var tag: String
    var isAcknowledged: Bool

    init(id: UUID = UUID(), title: String, subtitle: String, tag: String, isAcknowledged: Bool = false) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.tag = tag
        self.isAcknowledged = isAcknowledged
    }
}

enum SampleData {
    static let children = [
        ChildSummary(name: "Миша", className: "3Б", school: "Школа 1254", avatarText: "М"),
        ChildSummary(name: "Аня", className: "4А", school: "Школа 1254", avatarText: "А")
    ]

    static let familyMembers = [
        FamilyAccessMember(name: "Владимир", role: "Родитель", access: "Все задачи и уведомления", avatarText: "В", status: "Админ семьи"),
        FamilyAccessMember(name: "Екатерина", role: "Второй родитель", access: "ДЗ, календарь, чаты", avatarText: "Е", status: "Подключена"),
        FamilyAccessMember(name: "Ирина", role: "Бабушка", access: "Календарь и что принести", avatarText: "И", status: "Ожидает вход")
    ]

    static let classAccess = [
        ClassAccessSummary(title: "3Б", school: "Школа 1254", role: "Админ класса", inviteCode: "3B-4821", status: "25 родителей"),
        ClassAccessSummary(title: "4А", school: "Школа 1254", role: "Родитель", inviteCode: "4A-1930", status: "18 родителей")
    ]

    static let classMembers = [
        ClassMemberSummary(name: "Владимир", childName: "Миша", role: "Админ класса", status: "Подключен", avatarText: "В", canManage: true),
        ClassMemberSummary(name: "Елена Сергеевна", childName: "Классный руководитель", role: "Учитель", status: "Подключена", avatarText: "Е", canManage: false),
        ClassMemberSummary(name: "Мария", childName: "Соня", role: "Родкомитет", status: "Подключена", avatarText: "М", canManage: true),
        ClassMemberSummary(name: "Антон", childName: "Дима", role: "Родитель", status: "Подключен", avatarText: "А", canManage: false),
        ClassMemberSummary(name: "Ирина", childName: "Миша", role: "Семья", status: "Ожидает вход", avatarText: "И", canManage: false)
    ]

    static let notificationPreferences = [
        NotificationPreference(title: "Вечерний дайджест", detail: "Что завтра: уроки, форма, ДЗ и что принести", iconName: "moon.stars.fill", colorName: "blue", isEnabled: true),
        NotificationPreference(title: "Утренний дайджест", detail: "Расписание, срочные дела и кружки перед школой", iconName: "sun.max.fill", colorName: "orange", isEnabled: true),
        NotificationPreference(title: "Срочные объявления", detail: "От учителя и администратора класса отдельно от чатов", iconName: "exclamationmark.triangle.fill", colorName: "red", isEnabled: true),
        NotificationPreference(title: "Дедлайны оплат", detail: "Мягкие напоминания по сборам родкомитета", iconName: "rublesign.circle.fill", colorName: "green", isEnabled: true),
        NotificationPreference(title: "Семейные задачи", detail: "Только исполнителю: забрать, принести, подписать", iconName: "person.2.fill", colorName: "teal", isEnabled: false)
    ]

    static let subscriptionPlans = [
        SubscriptionPlanSummary(title: "Пробный период", price: "0 руб.", detail: "14 дней: ДЗ по фото, дайджесты и семейный доступ", badge: "Активен", isCurrent: true),
        SubscriptionPlanSummary(title: "1 ребенок", price: "149 руб./мес", detail: "Все ключевые функции для одного школьника", badge: "MVP"),
        SubscriptionPlanSummary(title: "Семья+", price: "+59 руб./мес", detail: "Дополнительный ребенок и общие семейные напоминания", badge: "Доп. ребенок")
    ]

    static let classMemory = [
        ClassMemoryEntry(
            title: "Экскурсия в планетарий",
            detail: "Дата, список детей, чек автобуса и фото из объявления собраны в одном месте",
            source: "Календарь + файлы",
            dateLabel: "12 мая",
            tag: "Событие",
            iconName: "sparkles",
            colorName: "blue"
        ),
        ClassMemoryEntry(
            title: "Список на ярмарку",
            detail: "Кто что приносит, ответственные родители и финальный отчет по сбору",
            source: "Объявления",
            dateLabel: "апрель",
            tag: "Объявление",
            iconName: "megaphone.fill",
            colorName: "orange"
        ),
        ClassMemoryEntry(
            title: "Согласия на поездку",
            detail: "Шаблон согласия, подписанные сканы и напоминание тем, кто еще не отправил",
            source: "Файлы",
            dateLabel: "март",
            tag: "Файл",
            iconName: "doc.text.fill",
            colorName: "green"
        )
    ]

    static let classFiles = [
        ClassFileSummary(
            title: "Согласие на экскурсию.pdf",
            detail: "Шаблон для родителей 3Б",
            category: "Согласия",
            owner: "Елена Сергеевна",
            updatedLabel: "обновлено вчера",
            status: "Нужно подписать",
            iconName: "doc.text.fill",
            colorName: "blue"
        ),
        ClassFileSummary(
            title: "Чек автобус.pdf",
            detail: "Расход по сбору на планетарий",
            category: "Чеки",
            owner: "Родкомитет",
            updatedLabel: "12 мая",
            status: "Проверено",
            iconName: "receipt.fill",
            colorName: "green"
        ),
        ClassFileSummary(
            title: "Памятка по форме.png",
            detail: "Что надеть на физкультуру и праздник",
            category: "Материалы",
            owner: "Владимир",
            updatedLabel: "1 мая",
            status: "В классе",
            iconName: "photo.fill",
            colorName: "teal"
        )
    ]

    static let subscriptionBenefits = [
        SubscriptionBenefit(title: "Что завтра", detail: "Единый вечерний план для ребенка и родителя", iconName: "checklist", colorName: "green"),
        SubscriptionBenefit(title: "ДЗ по фото", detail: "Разбор доски, дневника или сообщения в структуру", iconName: "camera.viewfinder", colorName: "blue"),
        SubscriptionBenefit(title: "Семейный доступ", detail: "Второй родитель, бабушка или няня видят нужное", iconName: "person.2.fill", colorName: "teal"),
        SubscriptionBenefit(title: "Тихий чат", detail: "Важное из сообщений без необходимости читать весь поток", iconName: "sparkles", colorName: "orange")
    ]

    static let homework = [
        HomeworkItem(
            subject: "Математика",
            title: "№ 47, 48 (с. 78)",
            dueLabel: "завтра",
            source: "AI из фото доски",
            status: .pending,
            bring: nil
        ),
        HomeworkItem(
            subject: "Русский язык",
            title: "Упр. 132 (с. 96)",
            dueLabel: "завтра",
            source: "Учитель",
            status: .review,
            bring: nil
        ),
        HomeworkItem(
            subject: "Окружающий мир",
            title: "Подготовить рассказ о растении",
            dueLabel: "пятница",
            source: "Родитель",
            status: .pending,
            bring: "картон и клей"
        )
    ]

    static let schedule = [
        ScheduleItem(day: "Пн", time: "08:30", title: "Литература", detail: "Каб. 18", teacher: "Ирина Петровна"),
        ScheduleItem(day: "Пн", time: "09:25", title: "Математика", detail: "Каб. 21", teacher: "Ольга Ивановна"),
        ScheduleItem(day: "Вт", time: "08:30", title: "Русский язык", detail: "Каб. 15", teacher: "Елена Сергеевна"),
        ScheduleItem(day: "Ср", time: "10:35", title: "Музыка", detail: "Актовый зал", teacher: "Анна Викторовна"),
        ScheduleItem(day: "Чт", time: "08:30", title: "Математика", detail: "Каб. 21", teacher: "Ольга Ивановна"),
        ScheduleItem(day: "Чт", time: "09:25", title: "Русский язык", detail: "Каб. 15", teacher: "Елена Сергеевна"),
        ScheduleItem(day: "Чт", time: "10:35", title: "Физкультура", detail: "Спортзал", teacher: "Дмитрий Андреевич", requiresForm: true),
        ScheduleItem(day: "Чт", time: "11:30", title: "Окружающий мир", detail: "Каб. 12", teacher: "Наталья Павловна"),
        ScheduleItem(day: "Пт", time: "09:25", title: "Английский язык", detail: "Вместо музыки, каб. 32", teacher: "Мария Олеговна", isReplacement: true)
    ]

    static let personalCircles = [
        PersonalCircle(
            title: "Шахматы",
            day: "Чт",
            time: "17:00",
            place: "Клуб у школы",
            responsible: "Папа",
            iconName: "brain.head.profile",
            colorName: "teal"
        ),
        PersonalCircle(
            title: "Английский",
            day: "Ср",
            time: "18:30",
            place: "Онлайн",
            responsible: "Мама",
            iconName: "text.book.closed",
            colorName: "blue"
        )
    ]

    static let parentTasks = [
        ParentTask(title: "Завтра принести сменную обувь для спортзала", dueLabel: "Сегодня", kind: .bring),
        ParentTask(title: "Сдать до пятницы: проект «Моя семья»", dueLabel: "23 мая", kind: .sign),
        ParentTask(title: "500 руб. на экскурсию", dueLabel: "до пятницы", kind: .pay)
    ]

    static let events = [
        ClassEvent(
            title: "Экскурсия в музей",
            dateLabel: "Чт, 9 июля",
            detail: "Сбор у школы в 09:10",
            type: "Экскурсия",
            place: "Музей космонавтики",
            linkedCollection: EventLinkedCollection(title: "Сбор на экскурсию", amount: "500 руб.", status: .dueSoon)
        ),
        ClassEvent(
            title: "Контрольная по математике",
            dateLabel: "Пт, 10 июля",
            detail: "Повторить таблицу умножения",
            type: "Контрольная",
            place: "Каб. 21"
        ),
        ClassEvent(
            title: "День рождения Сони",
            dateLabel: "Пн, 13 июля",
            detail: "Поздравление после уроков",
            type: "Праздник",
            place: "Класс"
        )
    ]

    static let collections = [
        CollectionSummary(
            title: "Театр",
            amount: "500 руб.",
            deadline: "до пятницы",
            paidCount: 14,
            totalCount: 25,
            recipient: "Мария, родкомитет",
            detail: "Билеты на спектакль и автобус до театра.",
            status: .dueSoon,
            expenses: [
                CollectionExpense(title: "Билеты", amount: "10 000 руб.", note: "Предоплата театру", attachment: "PDF-счет театра")
            ]
        ),
        CollectionSummary(
            title: "Подарок учителю",
            amount: "300 руб.",
            deadline: "до 15 июля",
            paidCount: 18,
            totalCount: 25,
            recipient: "Ольга, родкомитет",
            detail: "Общий подарок и открытка от класса.",
            expenses: []
        )
    ]

    static let feed = [
        FeedItem(title: "Важное объявление", subtitle: "Форма на физкультуру нужна завтра.", tag: "Учитель"),
        FeedItem(title: "Сбор на театр", subtitle: "500 руб. до пятницы, отчет будет в приложении.", tag: "Родкомитет"),
        FeedItem(title: "AI-дайджест чата", subtitle: "3 важных пункта: форма, картон, согласие.", tag: "Тихий чат")
    ]

    static let chats = [
        ChatPreviewItem(
            title: "Родители 3Б",
            message: "Мария: Напоминаю про экскурсию в пятницу",
            timeLabel: "09:12",
            icon: "person.3.fill",
            colorName: "green",
            hasUnread: true
        ),
        ChatPreviewItem(
            title: "Классный руководитель",
            message: "Спасибо всем, кто сдал деньги на книги!",
            timeLabel: "Вчера",
            icon: "graduationcap.fill",
            colorName: "blue",
            hasUnread: true
        ),
        ChatPreviewItem(
            title: "Родительский комитет",
            message: "Итоги голосования по празднику",
            timeLabel: "Вчера",
            icon: "building.columns.fill",
            colorName: "teal",
            hasUnread: false
        )
    ]

    static let chatThreads = [
        ChatThread(
            title: "Родители 3Б",
            subtitle: "Общий чат родителей",
            icon: "person.3.fill",
            colorName: "green",
            unreadCount: 5,
            messages: [
                ClassChatMessage(author: "Мария", text: "Напоминаю про экскурсию в пятницу. Сбор у школы в 09:10.", timeLabel: "09:12", isImportant: true, actionTitle: "Добавить в календарь"),
                ClassChatMessage(author: "Антон", text: "Кто сможет взять запасные дождевики?", timeLabel: "09:18"),
                ClassChatMessage(author: "Ольга", text: "Я заберу распечатанные согласия и передам учителю утром.", timeLabel: "09:24", isImportant: true, actionTitle: "Создать задачу")
            ]
        ),
        ChatThread(
            title: "Классный руководитель",
            subtitle: "Объявления без лишних обсуждений",
            icon: "graduationcap.fill",
            colorName: "blue",
            unreadCount: 2,
            isAnnouncementOnly: true,
            messages: [
                ClassChatMessage(author: "Елена Сергеевна", text: "Завтра на физкультуру нужна форма и сменная обувь.", timeLabel: "Вчера", isImportant: true, actionTitle: "Добавить в Что завтра"),
                ClassChatMessage(author: "Елена Сергеевна", text: "Проект «Моя семья» сдаем до пятницы.", timeLabel: "Вчера", isImportant: true, actionTitle: "Создать задачу")
            ]
        ),
        ChatThread(
            title: "Родительский комитет",
            subtitle: "Сборы, отчеты и организационные вопросы",
            icon: "building.columns.fill",
            colorName: "teal",
            unreadCount: 0,
            messages: [
                ClassChatMessage(author: "Ольга", text: "По празднику большинство выбрало мастер-класс в школе.", timeLabel: "Вчера"),
                ClassChatMessage(author: "Мария", text: "Отчет по театру добавлю после оплаты автобуса.", timeLabel: "Вчера", isImportant: true, actionTitle: "Открыть сбор")
            ]
        )
    ]

    static let chatDigestItems = [
        ChatDigestItem(
            title: "Форма на физкультуру",
            detail: "Завтра нужна форма и сменная обувь.",
            source: "Классный руководитель",
            iconName: "figure.run",
            colorName: "red",
            actionTitle: "Добавить в Что завтра"
        ),
        ChatDigestItem(
            title: "Согласие на экскурсию",
            detail: "Распечатать, подписать и передать утром.",
            source: "Родители 3Б",
            iconName: "doc.text.fill",
            colorName: "blue",
            actionTitle: "Создать задачу"
        ),
        ChatDigestItem(
            title: "Проект «Моя семья»",
            detail: "Сдать до пятницы, можно принести фото и короткий рассказ.",
            source: "Классный руководитель",
            iconName: "text.book.closed",
            colorName: "green",
            actionTitle: "Добавить к ДЗ"
        )
    ]

    static let weekDays = [
        DayChip(weekday: "Пн", day: "19", isSelected: false),
        DayChip(weekday: "Вт", day: "20", isSelected: false),
        DayChip(weekday: "Ср", day: "21", isSelected: false),
        DayChip(weekday: "Чт", day: "22", isSelected: true),
        DayChip(weekday: "Пт", day: "23", isSelected: false),
        DayChip(weekday: "Сб", day: "24", isSelected: false),
        DayChip(weekday: "Вс", day: "25", isSelected: false)
    ]
}
