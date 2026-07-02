import Foundation

struct ChildSummary: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let className: String
    let school: String
    let avatarText: String
}

struct HomeworkItem: Identifiable, Hashable {
    enum Status: String {
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
    let id = UUID()
    let time: String
    let title: String
    let detail: String
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

struct ClassEvent: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let dateLabel: String
    let detail: String
}

struct CollectionSummary: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let amount: String
    let deadline: String
    let paidCount: Int
    let totalCount: Int
}

struct FeedItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let tag: String
}

enum SampleData {
    static let children = [
        ChildSummary(name: "Миша", className: "3Б", school: "Школа 1254", avatarText: "М"),
        ChildSummary(name: "Аня", className: "4А", school: "Школа 1254", avatarText: "А")
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
        ScheduleItem(time: "08:30", title: "Математика", detail: "Каб. 21"),
        ScheduleItem(time: "09:25", title: "Русский язык", detail: "Каб. 15"),
        ScheduleItem(time: "10:35", title: "Физкультура", detail: "Спортзал - нужна форма"),
        ScheduleItem(time: "11:30", title: "Окружающий мир", detail: "Каб. 12")
    ]

    static let parentTasks = [
        ParentTask(title: "Завтра принести сменную обувь для спортзала", dueLabel: "Сегодня", kind: .bring),
        ParentTask(title: "Сдать до пятницы: проект «Моя семья»", dueLabel: "23 мая", kind: .sign),
        ParentTask(title: "500 руб. на экскурсию", dueLabel: "до пятницы", kind: .pay)
    ]

    static let events = [
        ClassEvent(title: "Экскурсия в музей", dateLabel: "Чт, 9 июля", detail: "Сбор у школы в 09:10"),
        ClassEvent(title: "Контрольная по математике", dateLabel: "Пт, 10 июля", detail: "Повторить таблицу умножения"),
        ClassEvent(title: "День рождения Сони", dateLabel: "Пн, 13 июля", detail: "Поздравление после уроков")
    ]

    static let collections = [
        CollectionSummary(title: "Театр", amount: "500 руб.", deadline: "до пятницы", paidCount: 14, totalCount: 25),
        CollectionSummary(title: "Подарок учителю", amount: "300 руб.", deadline: "до 15 июля", paidCount: 18, totalCount: 25)
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
