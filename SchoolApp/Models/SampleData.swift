import Foundation

struct ChildSummary: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let className: String
}

struct HomeworkItem: Identifiable, Hashable {
    enum Status: String {
        case pending = "Нужно сделать"
        case done = "Готово"
        case review = "Проверить"
    }

    let id = UUID()
    let subject: String
    let title: String
    let dueLabel: String
    let source: String
    let status: Status
    let bring: String?
}

struct ScheduleItem: Identifiable, Hashable {
    let id = UUID()
    let time: String
    let title: String
    let detail: String
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
        ChildSummary(name: "Миша", className: "2Б"),
        ChildSummary(name: "Аня", className: "4А")
    ]

    static let homework = [
        HomeworkItem(
            subject: "Математика",
            title: "Стр. 45, номера 6, 7, 8",
            dueLabel: "завтра",
            source: "AI из фото доски",
            status: .pending,
            bring: nil
        ),
        HomeworkItem(
            subject: "Русский язык",
            title: "Упр. 123, выучить правило",
            dueLabel: "завтра",
            source: "Учитель",
            status: .review,
            bring: nil
        ),
        HomeworkItem(
            subject: "Технология",
            title: "Подготовить аппликацию",
            dueLabel: "пятница",
            source: "Родитель",
            status: .pending,
            bring: "картон и клей"
        )
    ]

    static let schedule = [
        ScheduleItem(time: "08:30", title: "Математика", detail: "каб. 204"),
        ScheduleItem(time: "09:25", title: "Русский язык", detail: "каб. 204"),
        ScheduleItem(time: "10:30", title: "Физкультура", detail: "форма обязательна"),
        ScheduleItem(time: "17:00", title: "Шахматы", detail: "кружок")
    ]

    static let parentTasks = [
        ParentTask(title: "Принести картон", dueLabel: "завтра", kind: .bring),
        ParentTask(title: "Сдать 500 руб. на театр", dueLabel: "до пятницы", kind: .pay),
        ParentTask(title: "Подписать согласие на экскурсию", dueLabel: "сегодня", kind: .sign)
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
}

