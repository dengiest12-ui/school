import SwiftUI

struct CalendarView: View {
    @State private var selectedMode: CalendarMode = .list

    var body: some View {
        List {
            Section {
                Picker("Режим", selection: $selectedMode) {
                    ForEach(CalendarMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Ближайшее") {
                ForEach(SampleData.events) { event in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "calendar")
                            .foregroundStyle(SchoolTheme.accent)
                            .frame(width: 28)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(event.title)
                                .font(.headline)
                            Text(event.dateLabel)
                                .font(.subheadline.weight(.semibold))
                            Text(event.detail)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 6)
                }
            }

            Section("Личные кружки") {
                Label("Шахматы, сегодня 17:00", systemImage: "figure.mind.and.body")
                Label("Репетитор по английскому, ср 18:30", systemImage: "text.book.closed")
            }
        }
        .listStyle(.insetGrouped)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                } label: {
                    Image(systemName: "calendar.badge.plus")
                }
                .accessibilityLabel("Создать событие")
            }
        }
    }
}

private enum CalendarMode: String, CaseIterable, Identifiable {
    case day
    case week
    case month
    case list

    var id: String { rawValue }

    var title: String {
        switch self {
        case .day:
            "День"
        case .week:
            "Неделя"
        case .month:
            "Месяц"
        case .list:
            "Список"
        }
    }
}

#Preview {
    NavigationStack {
        CalendarView()
            .navigationTitle("Календарь")
    }
}

