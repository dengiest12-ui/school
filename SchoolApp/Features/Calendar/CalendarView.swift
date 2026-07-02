import SwiftUI

struct CalendarView: View {
    @State private var selectedMode: CalendarMode = .list
    @State private var events = SampleData.events
    @State private var activeSheet: CalendarSheet?

    init() {
        _activeSheet = State(initialValue: CalendarView.launchSheet())
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                header
                modePicker
                weekCard
                eventSummaryCard
                eventsList
                circlesCard
            }
            .padding(.horizontal, 20)
            .padding(.top, 22)
            .padding(.bottom, SchoolTheme.bottomScrollPadding)
        }
        .background(SchoolTheme.page.ignoresSafeArea())
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .add:
                AddEventSheet { event in
                    events.insert(event, at: 0)
                    selectedMode = .list
                }
            case .detail(let event):
                EventDetailSheet(event: event) { response in
                    setResponse(response, for: event)
                }
            }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Календарь")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(SchoolTheme.graphite)
                Text("События, кружки и дедлайны")
                    .font(.subheadline)
                    .foregroundStyle(SchoolTheme.muted)
            }

            Spacer()

            HeaderIconButton(systemName: "calendar.badge.plus") {
                activeSheet = .add
            }
            .accessibilityLabel("Создать событие")
        }
    }

    private var modePicker: some View {
        Picker("Режим", selection: $selectedMode) {
            ForEach(CalendarMode.allCases) { mode in
                Text(mode.title).tag(mode)
            }
        }
        .pickerStyle(.segmented)
    }

    private var weekCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 12) {
                    IconBadge(systemName: "calendar", color: SchoolTheme.accent)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Эта неделя")
                            .font(.headline)
                            .foregroundStyle(SchoolTheme.graphite)
                        Text("Сегодня выбран четверг, 22 мая")
                            .font(.subheadline)
                            .foregroundStyle(SchoolTheme.muted)
                    }
                    Spacer()
                }

                HStack(spacing: 8) {
                    ForEach(SampleData.weekDays) { day in
                        VStack(spacing: 5) {
                            Text(day.weekday)
                                .font(.caption)
                                .foregroundStyle(day.isSelected ? .white.opacity(0.88) : SchoolTheme.muted)
                            Text(day.day)
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(day.isSelected ? .white : SchoolTheme.graphite)
                        }
                        .frame(maxWidth: .infinity, minHeight: 58)
                        .background(day.isSelected ? SchoolTheme.accent : Color.clear, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
                    }
                }
            }
        }
    }

    private var eventSummaryCard: some View {
        DashboardCard {
            HStack(spacing: 12) {
                summaryMetric(value: "\(events.count)", title: "события", color: SchoolTheme.accent)
                Divider()
                summaryMetric(value: "\(events.filter { $0.response == .going }.count)", title: "идем", color: SchoolTheme.success)
                Divider()
                summaryMetric(value: "\(events.filter { $0.response == .undecided }.count)", title: "ждут ответа", color: SchoolTheme.warning)
            }
            .frame(height: 62)
        }
    }

    private var eventsList: some View {
        VStack(spacing: 12) {
            ForEach(events) { event in
                Button {
                    activeSheet = .detail(event)
                } label: {
                    eventCard(event)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func eventCard(_ event: ClassEvent) -> some View {
        DashboardCard {
            HStack(alignment: .top, spacing: 12) {
                IconBadge(systemName: iconName(for: event.type), color: color(for: event.type), size: 42)
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        StatusBadge(text: event.type, color: color(for: event.type))
                        StatusBadge(text: event.response.rawValue, color: responseColor(event.response))
                    }

                    Text(event.title)
                        .font(.headline)
                        .foregroundStyle(SchoolTheme.graphite)
                    Text(event.dateLabel)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SchoolTheme.success)
                    Text(event.detail)
                        .font(.caption)
                        .foregroundStyle(SchoolTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(SchoolTheme.muted)
                    .padding(.top, 3)
            }
        }
    }

    private var circlesCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Личные кружки")
                    .font(.headline)
                    .foregroundStyle(SchoolTheme.graphite)
                circleRow("Шахматы", "Сегодня 17:00", "brain.head.profile", SchoolTheme.teal)
                circleRow("Английский", "Среда 18:30", "text.book.closed", SchoolTheme.accent)
            }
        }
    }

    private func summaryMetric(value: String, title: String, color: Color) -> some View {
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

    private func circleRow(_ title: String, _ subtitle: String, _ icon: String, _ color: Color) -> some View {
        HStack(spacing: 12) {
            IconBadge(systemName: icon, color: color, size: 42)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
            }
            Spacer()
            Image(systemName: "bell")
                .foregroundStyle(SchoolTheme.muted)
        }
    }

    private func setResponse(_ response: EventResponse, for event: ClassEvent) {
        guard let index = events.firstIndex(where: { $0.id == event.id }) else {
            return
        }

        events[index].response = response
    }

    private func iconName(for type: String) -> String {
        switch type {
        case "Экскурсия":
            "bus.fill"
        case "Контрольная":
            "checklist.checked"
        case "Сбор":
            "rublesign.circle"
        case "Праздник":
            "party.popper.fill"
        case "Кружок":
            "figure.run"
        default:
            "calendar.circle"
        }
    }

    private func color(for type: String) -> Color {
        switch type {
        case "Контрольная":
            SchoolTheme.danger
        case "Сбор":
            SchoolTheme.warning
        case "Кружок":
            SchoolTheme.teal
        default:
            SchoolTheme.success
        }
    }

    private func responseColor(_ response: EventResponse) -> Color {
        switch response {
        case .going:
            SchoolTheme.success
        case .declined:
            SchoolTheme.danger
        case .question:
            SchoolTheme.accent
        case .undecided:
            SchoolTheme.warning
        }
    }

    private static func launchSheet() -> CalendarSheet? {
        let arguments = ProcessInfo.processInfo.arguments

        if arguments.contains("-qa-calendar-add") {
            return .add
        }

        if arguments.contains("-qa-calendar-detail"), let firstEvent = SampleData.events.first {
            return .detail(firstEvent)
        }

        return nil
    }
}

private struct AddEventSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: (ClassEvent) -> Void

    @State private var title = "Экскурсия в музей"
    @State private var dateLabel = "Пт, 17 июля, 09:10"
    @State private var type = "Экскурсия"
    @State private var place = "Музей космонавтики"
    @State private var detail = "Сбор у школы, нужна вода и согласие"
    @State private var responsible = "Родкомитет"
    @State private var reminderEnabled = true

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    CalendarSheetHeader(
                        icon: "calendar.badge.plus",
                        color: SchoolTheme.accent,
                        title: "Создать событие",
                        subtitle: "Экскурсия, контрольная, дедлайн оплаты или семейное дело"
                    )

                    DashboardCard {
                        VStack(spacing: 12) {
                            CalendarTextField(title: "Название", iconName: "text.badge.plus", color: SchoolTheme.success, text: $title)
                            eventTypePicker
                            CalendarTextField(title: "Дата и время", iconName: "clock", color: SchoolTheme.warning, text: $dateLabel)
                            CalendarTextField(title: "Место", iconName: "mappin.and.ellipse", color: SchoolTheme.teal, text: $place)
                            CalendarTextField(title: "Описание", iconName: "text.alignleft", color: SchoolTheme.accent, text: $detail)
                            CalendarTextField(title: "Ответственный", iconName: "person.badge.shield.checkmark", color: SchoolTheme.success, text: $responsible)
                        }
                    }

                    reminderCard

                    Button {
                        save()
                    } label: {
                        Label("Опубликовать событие", systemImage: "checkmark")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 52)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(SchoolTheme.success)
                    .disabled(title.trimmed.isEmpty || dateLabel.trimmed.isEmpty || detail.trimmed.isEmpty)
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Новое событие")
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

    private var eventTypePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Тип")
                .font(.caption.weight(.semibold))
                .foregroundStyle(SchoolTheme.muted)

            Menu {
                ForEach(eventTypes, id: \.self) { type in
                    Button(type) {
                        self.type = type
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    IconBadge(systemName: "tag.fill", color: SchoolTheme.accent, size: 38)
                    Text(type)
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

    private var reminderCard: some View {
        DashboardCard {
            Toggle(isOn: $reminderEnabled) {
                HStack(spacing: 12) {
                    IconBadge(systemName: "bell.badge.fill", color: SchoolTheme.warning, size: 42)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Напомнить семье")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(SchoolTheme.graphite)
                        Text("Вечером накануне и утром в день события")
                            .font(.caption)
                            .foregroundStyle(SchoolTheme.muted)
                    }
                }
            }
            .toggleStyle(.switch)
            .tint(SchoolTheme.success)
        }
    }

    private var eventTypes: [String] {
        ["Экскурсия", "Контрольная", "Собрание", "Праздник", "Сбор", "Кружок", "Личное"]
    }

    private func save() {
        let event = ClassEvent(
            title: title.trimmed,
            dateLabel: dateLabel.trimmed,
            detail: "\(detail.trimmed). Ответственный: \(responsible.trimmed)",
            type: type,
            place: place.trimmed,
            response: .undecided
        )

        onSave(event)
        dismiss()
    }
}

private struct EventDetailSheet: View {
    @Environment(\.dismiss) private var dismiss

    let event: ClassEvent
    let onResponse: (EventResponse) -> Void

    @State private var selectedResponse: EventResponse

    init(event: ClassEvent, onResponse: @escaping (EventResponse) -> Void) {
        self.event = event
        self.onResponse = onResponse
        _selectedResponse = State(initialValue: event.response)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    CalendarSheetHeader(
                        icon: "calendar.circle",
                        color: SchoolTheme.success,
                        title: event.title,
                        subtitle: event.dateLabel
                    )

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 14) {
                            eventInfo("Тип", event.type, "tag.fill", SchoolTheme.accent)
                            eventInfo("Место", event.place.isEmpty ? "Будет уточнено" : event.place, "mappin.and.ellipse", SchoolTheme.teal)
                            eventInfo("Детали", event.detail, "text.alignleft", SchoolTheme.success)
                        }
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Участие")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            ForEach(EventResponse.allCases, id: \.self) { response in
                                Button {
                                    selectedResponse = response
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: selectedResponse == response ? "checkmark.circle.fill" : "circle")
                                            .font(.title3)
                                            .foregroundStyle(selectedResponse == response ? responseColor(response) : SchoolTheme.muted.opacity(0.55))
                                        Text(response.rawValue)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(SchoolTheme.graphite)
                                        Spacer()
                                    }
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    Button {
                        onResponse(selectedResponse)
                        dismiss()
                    } label: {
                        Label("Сохранить ответ", systemImage: "checkmark")
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
            .navigationTitle("Событие")
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

    private func eventInfo(_ title: String, _ value: String, _ iconName: String, _ color: Color) -> some View {
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

    private func responseColor(_ response: EventResponse) -> Color {
        switch response {
        case .going:
            SchoolTheme.success
        case .declined:
            SchoolTheme.danger
        case .question:
            SchoolTheme.accent
        case .undecided:
            SchoolTheme.warning
        }
    }
}

private struct CalendarSheetHeader: View {
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

private struct CalendarTextField: View {
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

private enum CalendarSheet: Identifiable, Hashable {
    case add
    case detail(ClassEvent)

    var id: String {
        switch self {
        case .add:
            "add"
        case .detail(let event):
            "detail-\(event.id.uuidString)"
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

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

#Preview {
    CalendarView()
}
