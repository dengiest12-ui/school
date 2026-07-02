import SwiftUI

struct ClassRoomView: View {
    @State private var selectedSection: ClassSection
    @State private var collections = SampleData.collections
    @State private var activeSheet: ClassRoomSheet?

    init() {
        let launchSheet = ClassRoomView.launchSheet()
        _selectedSection = State(initialValue: launchSheet == nil ? ClassRoomView.launchSection() : .collections)
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
                AddCollectionSheet { collection in
                    collections.insert(collection, at: 0)
                    selectedSection = .collections
                }
            case .collectionDetail(let collection):
                CollectionDetailSheet(collection: collection) { updatedCollection in
                    updateCollection(updatedCollection)
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
            HeaderIconButton(systemName: "plus") {
                selectedSection = .collections
                activeSheet = .addCollection
            }
            .accessibilityLabel("Добавить")
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
                    Text("Сегодня: 1 объявление, 2 задачи, \(collectionCountText)")
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
            ForEach(SampleData.feed) { item in
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
                            Button("Открыть") {}
                                .buttonStyle(.bordered)
                            Button("Напомнить") {}
                                .buttonStyle(.borderless)
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
            DashboardCard {
                VStack(alignment: .leading, spacing: 12) {
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
                    }

                    Text("3 важных пункта: форма на физкультуру, проект «Моя семья», экскурсия в пятницу.")
                        .font(.subheadline)
                        .foregroundStyle(SchoolTheme.graphite)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            ForEach(SampleData.chats) { chat in
                DashboardCard {
                    HStack(spacing: 12) {
                        IconBadge(systemName: chat.icon, color: color(for: chat.colorName), size: 44)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(chat.title)
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)
                            Text(chat.message)
                                .font(.subheadline)
                                .foregroundStyle(SchoolTheme.muted)
                                .lineLimit(2)
                        }
                        Spacer()
                        Text(chat.timeLabel)
                            .font(.caption)
                            .foregroundStyle(SchoolTheme.muted)
                    }
                }
            }
        }
    }

    private var collectionsContent: some View {
        VStack(spacing: 12) {
            collectionSummaryCard

            Button {
                activeSheet = .addCollection
            } label: {
                Label("Создать сбор", systemImage: "plus")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 52)
            }
            .buttonStyle(.borderedProminent)
            .tint(SchoolTheme.success)

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
                VStack(spacing: 14) {
                    memberRow("Родители", "25 участников", "person.2.fill", SchoolTheme.success)
                    memberRow("Классный руководитель", "1 учитель", "graduationcap.fill", SchoolTheme.accent)
                    memberRow("Родкомитет", "3 ответственных", "person.badge.shield.checkmark.fill", SchoolTheme.teal)
                }
            }

            Button {
            } label: {
                Label("Пригласить родителей", systemImage: "link")
                    .font(.headline)
                    .frame(maxWidth: .infinity, minHeight: 52)
            }
            .buttonStyle(.borderedProminent)
            .tint(SchoolTheme.success)
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

    private func memberRow(_ title: String, _ subtitle: String, _ icon: String, _ color: Color) -> some View {
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
            Image(systemName: "chevron.right")
                .foregroundStyle(SchoolTheme.muted)
        }
    }

    private func updateCollection(_ updatedCollection: CollectionSummary) {
        guard let index = collections.firstIndex(where: { $0.id == updatedCollection.id }) else {
            return
        }

        collections[index] = updatedCollection
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
        default:
            SchoolTheme.accent
        }
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
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Новый сбор")
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

private struct CollectionDetailSheet: View {
    @Environment(\.dismiss) private var dismiss

    let collection: CollectionSummary
    let onSave: (CollectionSummary) -> Void

    @State private var paidCount: Int
    @State private var status: CollectionStatus
    @State private var expenses: [CollectionExpense]
    @State private var myFamilyPaid = false
    @State private var expenseTitle = "Чек за автобус"
    @State private var expenseAmount = "2 500 руб."
    @State private var expenseNote = "Добавлено в отчет"

    init(collection: CollectionSummary, onSave: @escaping (CollectionSummary) -> Void) {
        self.collection = collection
        self.onSave = onSave
        _paidCount = State(initialValue: collection.paidCount)
        _status = State(initialValue: collection.status)
        _expenses = State(initialValue: collection.expenses)
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
                        Label("Сохранить сбор", systemImage: "checkmark")
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
            .navigationTitle("Сбор")
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

                Picker("Статус", selection: $status) {
                    ForEach(CollectionStatus.allCases, id: \.self) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
                .pickerStyle(.segmented)
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
                                }
                                Spacer()
                                Text(expense.amount)
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(SchoolTheme.warning)
                            }
                        }
                    }
                }

                VStack(spacing: 10) {
                    CollectionTextField(title: "Расход", iconName: "doc.badge.plus", color: SchoolTheme.accent, text: $expenseTitle)
                    CollectionTextField(title: "Сумма", iconName: "banknote", color: SchoolTheme.warning, text: $expenseAmount)
                    CollectionTextField(title: "Комментарий", iconName: "text.alignleft", color: SchoolTheme.teal, text: $expenseNote)
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
            note: expenseNote.trimmed.isEmpty ? "Без комментария" : expenseNote.trimmed
        )

        expenses.insert(expense, at: 0)
        expenseTitle = ""
        expenseAmount = ""
        expenseNote = ""
    }

    private func save() {
        var updatedCollection = collection
        updatedCollection.paidCount = paidCount
        updatedCollection.status = paidCount >= collection.totalCount ? .closed : status
        updatedCollection.expenses = expenses
        onSave(updatedCollection)
        dismiss()
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

private enum ClassRoomSheet: Identifiable, Hashable {
    case addCollection
    case collectionDetail(CollectionSummary)

    var id: String {
        switch self {
        case .addCollection:
            "add-collection"
        case .collectionDetail(let collection):
            "collection-\(collection.id.uuidString)"
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
