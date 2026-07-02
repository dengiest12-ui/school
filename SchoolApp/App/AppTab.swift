import SwiftUI

enum AppTab: String, CaseIterable, Identifiable {
    case today
    case classRoom
    case homework
    case calendar
    case more

    var id: String { rawValue }

    var title: String {
        switch self {
        case .today:
            "Сегодня"
        case .classRoom:
            "Класс"
        case .homework:
            "ДЗ"
        case .calendar:
            "Календарь"
        case .more:
            "Еще"
        }
    }

    @ViewBuilder
    var content: some View {
        switch self {
        case .today:
            TodayView()
        case .classRoom:
            ClassRoomView()
        case .homework:
            HomeworkView()
        case .calendar:
            CalendarView()
        case .more:
            MoreView()
        }
    }

    @ViewBuilder
    var label: some View {
        switch self {
        case .today:
            Label("Сегодня", systemImage: "sun.max")
        case .classRoom:
            Label("Класс", systemImage: "person.3")
        case .homework:
            Label("ДЗ", systemImage: "checklist")
        case .calendar:
            Label("Календарь", systemImage: "calendar")
        case .more:
            Label("Еще", systemImage: "ellipsis.circle")
        }
    }
}

