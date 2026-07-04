import SwiftUI
import UniformTypeIdentifiers
import UIKit

private enum HomeworkLocalStore {
    private static let defaultsKey = "school.homework.items.v1"
    private static var storedItems: [HomeworkItem] = load()

    static var items: [HomeworkItem] {
        get { storedItems }
        set {
            storedItems = newValue
            save()
        }
    }

    static func resetIfRequested() {
        guard ProcessInfo.processInfo.arguments.contains("-qa-reset-homework-store") else {
            return
        }

        storedItems = SampleData.homework
        UserDefaults.standard.removeObject(forKey: defaultsKey)
    }

    private static func load() -> [HomeworkItem] {
        guard
            let data = UserDefaults.standard.data(forKey: defaultsKey),
            let decoded = try? JSONDecoder().decode([HomeworkItem].self, from: data)
        else {
            return SampleData.homework
        }

        return decoded
    }

    private static func save() {
        guard let data = try? JSONEncoder().encode(storedItems) else {
            return
        }

        UserDefaults.standard.set(data, forKey: defaultsKey)
    }
}

struct HomeworkView: View {
    private static let allFilterValue = "Все"

    @State private var selectedScope: HomeworkScope = .tomorrow
    @State private var selectedChildName = HomeworkView.allFilterValue
    @State private var selectedSubject = HomeworkView.allFilterValue
    @State private var selectedStatus = HomeworkView.allFilterValue
    @State private var selectedSource = HomeworkView.allFilterValue
    @State private var homeworkItems: [HomeworkItem]
    @State private var activeSheet: HomeworkSheet?

    init() {
        HomeworkLocalStore.resetIfRequested()
        let launchItems = ProcessInfo.processInfo.arguments.contains("-qa-homework-empty") ? [] : HomeworkLocalStore.items
        _homeworkItems = State(initialValue: launchItems)
        _activeSheet = State(initialValue: HomeworkView.launchSheet())
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 14) {
                    header
                    scopePicker
                    parseCard
                    summaryCard
                    filtersCard
                    homeworkList
                }
                .padding(.horizontal, 20)
                .padding(.top, 22)
                .padding(.bottom, SchoolTheme.bottomScrollPadding)
                .frame(width: proxy.size.width, alignment: .top)
            }
            .scrollClipDisabled(false)
        }
        .background(SchoolTheme.page.ignoresSafeArea())
        .onAppear {
            applyLaunchFiltersIfNeeded()
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .add:
                AddHomeworkSheet { newItem in
                    homeworkItems.insert(newItem, at: 0)
                    HomeworkLocalStore.items = homeworkItems
                }
            case .parse(let inputKind):
                ParseHomeworkSheet(inputKind: inputKind) { parsedItems in
                    homeworkItems.insert(contentsOf: parsedItems, at: 0)
                    HomeworkLocalStore.items = homeworkItems
                    selectedScope = .tomorrow
                }
            case .paywall:
                HomeworkPaywallSheet()
            case .archive:
                HomeworkArchiveSheet(items: doneHomeworkItems)
            }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Домашка")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(SchoolTheme.graphite)
                Text("Понятно, по предметам и дедлайнам")
                    .font(.subheadline)
                    .foregroundStyle(SchoolTheme.muted)
            }

            Spacer()

            HeaderIconButton(systemName: "archivebox.fill") {
                activeSheet = .archive
            }
            .accessibilityLabel("Архив выполненных ДЗ")

            HeaderIconButton(systemName: "camera.viewfinder") {
                openParse(.photo)
            }
            .accessibilityLabel("Сфотографировать ДЗ")

            HeaderIconButton(systemName: "plus") {
                activeSheet = .add
            }
            .accessibilityLabel("Добавить ДЗ")
        }
    }

    private var scopePicker: some View {
        Picker("Период", selection: $selectedScope) {
            ForEach(HomeworkScope.allCases) { scope in
                Text(scope.title).tag(scope)
            }
        }
        .pickerStyle(.segmented)
    }

    private var parseCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    IconBadge(systemName: "sparkles", color: SchoolTheme.success)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Разобрать ДЗ")
                            .font(.headline)
                            .foregroundStyle(SchoolTheme.graphite)
                        Text("Фото доски, текст, скрин или голос")
                            .font(.subheadline)
                            .foregroundStyle(SchoolTheme.muted)
                    }
                    Spacer()
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    parseAction(.photo, SchoolTheme.success)
                    parseAction(.upload, SchoolTheme.accent)
                    parseAction(.voice, SchoolTheme.teal)
                    parseAction(.screenshot, SchoolTheme.warning)
                }
            }
        }
    }

    private var summaryCard: some View {
        DashboardCard {
            HStack(spacing: 12) {
                summaryMetric(value: "\(pendingCount)", title: "в работе", color: SchoolTheme.warning)
                Divider()
                summaryMetric(value: "\(reviewCount)", title: "проверить", color: SchoolTheme.accent)
                Divider()
                summaryMetric(value: "\(doneCount)", title: "готово", color: SchoolTheme.success)
            }
            .frame(height: 62)
        }
    }

    private var filtersCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    IconBadge(systemName: "line.3.horizontal.decrease.circle.fill", color: SchoolTheme.accent, size: 42)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Фильтры")
                            .font(.headline)
                            .foregroundStyle(SchoolTheme.graphite)
                        Text(filtersSubtitle)
                            .font(.caption)
                            .foregroundStyle(SchoolTheme.muted)
                            .lineLimit(2)
                            .minimumScaleFactor(0.86)
                    }
                    Spacer()
                    if hasActiveFilters {
                        Button {
                            resetFilters()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundStyle(SchoolTheme.muted)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Сбросить фильтры ДЗ")
                    }
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    filterMenu(
                        title: "Ребенок",
                        selection: $selectedChildName,
                        values: childFilterValues,
                        iconName: "figure.child",
                        color: SchoolTheme.success
                    )
                    filterMenu(
                        title: "Предмет",
                        selection: $selectedSubject,
                        values: subjectFilterValues,
                        iconName: "book.closed.fill",
                        color: SchoolTheme.accent
                    )
                    filterMenu(
                        title: "Статус",
                        selection: $selectedStatus,
                        values: statusFilterValues,
                        iconName: "checkmark.seal.fill",
                        color: SchoolTheme.warning
                    )
                    filterMenu(
                        title: "Источник",
                        selection: $selectedSource,
                        values: sourceFilterValues,
                        iconName: "person.crop.circle.fill",
                        color: SchoolTheme.teal
                    )
                }
            }
        }
    }

    private var homeworkList: some View {
        VStack(spacing: 12) {
            if filteredHomework.isEmpty {
                emptyState
            } else {
                ForEach(filteredHomework) { item in
                    homeworkCard(item)
                }
            }
        }
    }

    private var emptyState: some View {
        DashboardCard {
            VStack(spacing: 12) {
                IconBadge(systemName: "checkmark.seal.fill", color: SchoolTheme.success, size: 52)
                Text("Здесь пока чисто")
                    .font(.headline)
                    .foregroundStyle(SchoolTheme.graphite)
                Text("Добавьте задание вручную или разберите фото доски.")
                    .font(.subheadline)
                    .foregroundStyle(SchoolTheme.muted)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var filteredHomework: [HomeworkItem] {
        let scopedItems: [HomeworkItem] = switch selectedScope {
        case .today:
            homeworkItems.filter { $0.status != .done && $0.dueLabel.localizedCaseInsensitiveContains("сегодня") }
        case .tomorrow:
            homeworkItems.filter { $0.status != .done && $0.dueLabel.localizedCaseInsensitiveContains("завтра") }
        case .week:
            homeworkItems.filter { $0.status != .done }
        case .done:
            homeworkItems.filter { $0.status == .done }
        }

        return scopedItems.filter { item in
            matchesFilter(selectedChildName, value: item.childName)
                && matchesFilter(selectedSubject, value: item.subject)
                && matchesFilter(selectedStatus, value: item.status.rawValue)
                && matchesFilter(selectedSource, value: item.source)
        }
    }

    private var pendingCount: Int {
        homeworkItems.filter { $0.status == .pending }.count
    }

    private var reviewCount: Int {
        homeworkItems.filter { $0.status == .review }.count
    }

    private var doneCount: Int {
        homeworkItems.filter { $0.status == .done }.count
    }

    private var doneHomeworkItems: [HomeworkItem] {
        homeworkItems.filter { $0.status == .done }
    }

    private var childFilterValues: [String] {
        filterValues(homeworkItems.map(\.childName))
    }

    private var subjectFilterValues: [String] {
        filterValues(homeworkItems.map(\.subject))
    }

    private var statusFilterValues: [String] {
        [Self.allFilterValue] + HomeworkItem.Status.allCases.map(\.rawValue)
    }

    private var sourceFilterValues: [String] {
        filterValues(homeworkItems.map(\.source))
    }

    private var filtersSubtitle: String {
        if hasActiveFilters {
            return "Показано \(filteredHomework.count) из \(scopedHomeworkCount) в выбранном периоде"
        }

        return "Ребенок, предмет, статус и источник"
    }

    private var hasActiveFilters: Bool {
        selectedChildName != Self.allFilterValue
            || selectedSubject != Self.allFilterValue
            || selectedStatus != Self.allFilterValue
            || selectedSource != Self.allFilterValue
    }

    private var scopedHomeworkCount: Int {
        switch selectedScope {
        case .today:
            homeworkItems.filter { $0.status != .done && $0.dueLabel.localizedCaseInsensitiveContains("сегодня") }.count
        case .tomorrow:
            homeworkItems.filter { $0.status != .done && $0.dueLabel.localizedCaseInsensitiveContains("завтра") }.count
        case .week:
            homeworkItems.filter { $0.status != .done }.count
        case .done:
            homeworkItems.filter { $0.status == .done }.count
        }
    }

    private func homeworkCard(_ item: HomeworkItem) -> some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    IconBadge(systemName: "book.closed", color: badgeColor(for: item.status), size: 42)

                    VStack(alignment: .leading, spacing: 5) {
                        Text(item.subject)
                            .font(.headline)
                            .foregroundStyle(SchoolTheme.graphite)
                        Text(item.title)
                            .font(.subheadline)
                            .foregroundStyle(SchoolTheme.graphite)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()
                    StatusBadge(text: item.status.rawValue, color: badgeColor(for: item.status))
                }

                ViewThatFits(in: .horizontal) {
                    HStack(spacing: 10) {
                        metadataLabel(item.childName, icon: "figure.child")
                        metadataLabel(item.dueLabel, icon: "clock")
                        metadataLabel(item.source, icon: "person.crop.circle")
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        metadataLabel(item.childName, icon: "figure.child")
                        metadataLabel(item.dueLabel, icon: "clock")
                        metadataLabel(item.source, icon: "person.crop.circle")
                    }
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(SchoolTheme.muted)

                if let bring = item.bring, !bring.isEmpty {
                    Label("Принести: \(bring)", systemImage: "shippingbox")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(SchoolTheme.warning)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let attachment = item.attachment, !attachment.isEmpty {
                    Label(attachment, systemImage: "paperclip")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(SchoolTheme.accent)
                        .fixedSize(horizontal: false, vertical: true)
                }

                ViewThatFits(in: .horizontal) {
                    HStack {
                        homeworkDoneButton(item)
                        homeworkAIButton
                        Spacer()
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        homeworkDoneButton(item)
                        homeworkAIButton
                    }
                }
                .font(.subheadline.weight(.semibold))
            }
        }
    }

    private func metadataLabel(_ text: String, icon: String) -> some View {
        Label(text, systemImage: icon)
            .lineLimit(1)
            .minimumScaleFactor(0.82)
    }

    private func homeworkDoneButton(_ item: HomeworkItem) -> some View {
        Button {
            toggleDone(item)
        } label: {
            Label(item.status == .done ? "Вернуть" : "Готово", systemImage: item.status == .done ? "arrow.uturn.left" : "checkmark.circle")
        }
        .buttonStyle(.bordered)
    }

    private var homeworkAIButton: some View {
        Button {
            openParse(.text)
        } label: {
            Label("Исправить через AI", systemImage: "sparkles")
        }
        .buttonStyle(.borderless)
    }

    private func parseAction(_ kind: HomeworkInputKind, _ color: Color) -> some View {
        Button {
            openParse(kind)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: kind.iconName)
                    .font(.headline)
                    .foregroundStyle(color)
                Text(kind.actionTitle)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, minHeight: 42)
            .background(color.opacity(0.09), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func openParse(_ kind: HomeworkInputKind) {
        activeSheet = AppSubscriptionAccessStore.canUseAI ? .parse(kind) : .paywall
    }

    private func filterMenu(title: String, selection: Binding<String>, values: [String], iconName: String, color: Color) -> some View {
        Menu {
            ForEach(values, id: \.self) { value in
                Button {
                    selection.wrappedValue = value
                } label: {
                    if selection.wrappedValue == value {
                        Label(value, systemImage: "checkmark")
                    } else {
                        Text(value)
                    }
                }
            }
        } label: {
            HStack(spacing: 9) {
                Image(systemName: iconName)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(color)
                    .frame(width: 20)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(SchoolTheme.muted)
                    Text(selection.wrappedValue)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(SchoolTheme.graphite)
                        .lineLimit(1)
                        .minimumScaleFactor(0.76)
                }
                Spacer(minLength: 4)
                Image(systemName: "chevron.down")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(SchoolTheme.muted)
            }
            .frame(maxWidth: .infinity, minHeight: 48)
            .padding(.horizontal, 10)
            .background(color.opacity(selection.wrappedValue == Self.allFilterValue ? 0.08 : 0.14), in: RoundedRectangle(cornerRadius: 13, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .stroke(selection.wrappedValue == Self.allFilterValue ? SchoolTheme.line : color.opacity(0.35), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
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
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }

    private func toggleDone(_ item: HomeworkItem) {
        guard let index = homeworkItems.firstIndex(where: { $0.id == item.id }) else {
            return
        }

        homeworkItems[index].status = homeworkItems[index].status == .done ? .pending : .done
        HomeworkLocalStore.items = homeworkItems
    }

    private func filterValues(_ values: [String]) -> [String] {
        [Self.allFilterValue] + Array(Set(values.filter { !$0.trimmed.isEmpty })).sorted()
    }

    private func matchesFilter(_ filter: String, value: String) -> Bool {
        filter == Self.allFilterValue || value == filter
    }

    private func resetFilters() {
        selectedChildName = Self.allFilterValue
        selectedSubject = Self.allFilterValue
        selectedStatus = Self.allFilterValue
        selectedSource = Self.allFilterValue
    }

    private func applyLaunchFiltersIfNeeded() {
        guard ProcessInfo.processInfo.arguments.contains("-qa-homework-filters") else {
            return
        }

        selectedScope = .week
        selectedChildName = "Миша"
        selectedSubject = "Русский язык"
        selectedStatus = HomeworkItem.Status.review.rawValue
        selectedSource = "Учитель"
    }

    private func badgeColor(for status: HomeworkItem.Status) -> Color {
        switch status {
        case .pending:
            SchoolTheme.warning
        case .done:
            SchoolTheme.success
        case .review:
            SchoolTheme.accent
        }
    }

    private static func launchSheet() -> HomeworkSheet? {
        let arguments = ProcessInfo.processInfo.arguments

        if arguments.contains("-qa-homework-add") {
            return .add
        }

        if arguments.contains("-qa-homework-paywall") || arguments.contains("-qa-no-subscription") {
            return .paywall
        }

        if arguments.contains("-qa-homework-archive") {
            return .archive
        }

        if arguments.contains("-qa-homework-file-importer") {
            return .parse(.upload)
        }

        if arguments.contains("-qa-homework-parse") || arguments.contains("-qa-homework-photo-dialog") {
            return .parse(.photo)
        }

        return nil
    }
}

private struct AddHomeworkSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: (HomeworkItem) -> Void

    @State private var subject = "Математика"
    @State private var title = "Страница 45, номера 6, 7, 8"
    @State private var dueLabel = "завтра"
    @State private var bring = ""
    @State private var attachmentStatus: String?
    @State private var isImageSourceDialogVisible = false
    @State private var isImagePickerVisible = false
    @State private var isFileImporterVisible = false
    @State private var imagePickerSource: UIImagePickerController.SourceType = .photoLibrary

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    sheetHeader(
                        icon: "plus.circle.fill",
                        color: SchoolTheme.success,
                        title: "Добавить ДЗ",
                        subtitle: "Ручной ввод от родителя, учителя или родкомитета"
                    )

                    DashboardCard {
                        VStack(spacing: 12) {
                            HomeworkTextField(title: "Предмет", iconName: "book.closed", color: SchoolTheme.success, text: $subject)
                            HomeworkTextField(title: "Задание", iconName: "text.alignleft", color: SchoolTheme.accent, text: $title)
                            HomeworkTextField(title: "Срок", iconName: "clock", color: SchoolTheme.warning, text: $dueLabel)
                            HomeworkTextField(title: "Что принести", iconName: "shippingbox", color: SchoolTheme.teal, text: $bring)
                        }
                    }

                    DashboardCard {
                        attachmentActions
                    }

                    Button {
                        save()
                    } label: {
                        Label("Сохранить задание", systemImage: "checkmark")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 52)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(SchoolTheme.success)
                    .disabled(subject.trimmed.isEmpty || title.trimmed.isEmpty || dueLabel.trimmed.isEmpty)
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Новое ДЗ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
                KeyboardDoneToolbar()
            }
            .confirmationDialog("Добавить вложение", isPresented: $isImageSourceDialogVisible, titleVisibility: .visible) {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    Button("Сделать фото") {
                        showImagePicker(.camera)
                    }
                }

                Button("Выбрать из галереи") {
                    showImagePicker(.photoLibrary)
                }

                Button("Отмена", role: .cancel) {}
            } message: {
                Text("Фото дневника, доски или тетради будет прикреплено к заданию.")
            }
            .sheet(isPresented: $isImagePickerVisible) {
                HomeworkImagePicker(sourceType: imagePickerSource) { displayName in
                    attachmentStatus = "Фото прикреплено: \(displayName)"
                }
            }
            .fileImporter(
                isPresented: $isFileImporterVisible,
                allowedContentTypes: [.pdf, .image, .plainText, .item],
                allowsMultipleSelection: false
            ) { result in
                handleFileImport(result)
            }
            .onAppear {
                runQAImporterChecks()
            }
        }
    }

    private var attachmentActions: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                IconBadge(systemName: "paperclip", color: SchoolTheme.accent, size: 42)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Вложение")
                        .font(.headline)
                        .foregroundStyle(SchoolTheme.graphite)
                    Text(attachmentStatus ?? "Фото доски, дневника, тетради или файл")
                        .font(.caption)
                        .foregroundStyle(attachmentStatus == nil ? SchoolTheme.muted : SchoolTheme.success)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }

            HStack(spacing: 10) {
                Button {
                    isImageSourceDialogVisible = true
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
                    Label("Файл", systemImage: "doc.fill")
                        .font(.caption.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: 42)
                }
                .buttonStyle(.bordered)
                .tint(SchoolTheme.accent)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func save() {
        onSave(
            HomeworkItem(
                subject: subject.trimmed,
                title: title.trimmed,
                dueLabel: dueLabel.trimmed,
                source: "Родитель",
                status: .pending,
                bring: bring.trimmed.isEmpty ? nil : bring.trimmed,
                attachment: attachmentStatus
            )
        )
        dismiss()
    }

    private func showImagePicker(_ sourceType: UIImagePickerController.SourceType) {
        imagePickerSource = sourceType
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

            let fileName = url.lastPathComponent.isEmpty ? "документ" : url.lastPathComponent
            attachmentStatus = "Файл прикреплен: \(fileName)"
        case .failure:
            attachmentStatus = "Не удалось прикрепить файл"
        }
    }

    private func runQAImporterChecks() {
        let arguments = ProcessInfo.processInfo.arguments

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            if arguments.contains("-qa-homework-add-photo-dialog") {
                isImageSourceDialogVisible = true
            }

            if arguments.contains("-qa-homework-add-file-importer") {
                isFileImporterVisible = true
            }
        }
    }
}

private struct ParseHomeworkSheet: View {
    @Environment(\.dismiss) private var dismiss

    let inputKind: HomeworkInputKind
    let onSave: ([HomeworkItem]) -> Void

    @State private var recognizedText: String
    @State private var drafts: [ParsedHomeworkDraft]
    @State private var attachmentStatus: String?
    @State private var isImageSourceDialogVisible = false
    @State private var isImagePickerVisible = false
    @State private var isFileImporterVisible = false
    @State private var imagePickerSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var aiReportStatus = "Если AI ошибся, отправьте результат в журнал качества"
    @State private var didRunAIReportQA = false

    init(inputKind: HomeworkInputKind, onSave: @escaping ([HomeworkItem]) -> Void) {
        self.inputKind = inputKind
        self.onSave = onSave
        _recognizedText = State(initialValue: inputKind.sampleText)
        _drafts = State(initialValue: HomeworkParser.parse(inputKind.sampleText))
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    sheetHeader(
                        icon: inputKind.iconName,
                        color: inputKind.color,
                        title: inputKind.sheetTitle,
                        subtitle: "Проверьте текст, поправьте результат и сохраните по предметам"
                    )

                    if inputKind != .text {
                        capturePreview
                    }

                    recognizedTextCard
                    parsedResultCard
                    aiFeedbackCard
                    saveButton
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Разобрать ДЗ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
                KeyboardDoneToolbar()
            }
            .confirmationDialog("Добавить исходник ДЗ", isPresented: $isImageSourceDialogVisible, titleVisibility: .visible) {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    Button("Сделать фото") {
                        showImagePicker(.camera)
                    }
                }

                Button("Выбрать из галереи") {
                    showImagePicker(.photoLibrary)
                }

                Button("Отмена", role: .cancel) {}
            } message: {
                Text("Фото или скрин будет привязан к распознанному тексту.")
            }
            .sheet(isPresented: $isImagePickerVisible) {
                HomeworkImagePicker(sourceType: imagePickerSource) { displayName in
                    attachmentStatus = "Фото прикреплено: \(displayName)"
                }
            }
            .fileImporter(
                isPresented: $isFileImporterVisible,
                allowedContentTypes: [.pdf, .image, .plainText, .item],
                allowsMultipleSelection: false
            ) { result in
                handleFileImport(result)
            }
            .onAppear {
                runQAImporterChecks()
            }
        }
    }

    private var capturePreview: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    IconBadge(systemName: inputKind.iconName, color: inputKind.color, size: 42)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(inputKind.previewTitle)
                            .font(.headline)
                            .foregroundStyle(SchoolTheme.graphite)
                        Text("Можно заменить фото или исправить текст ниже")
                            .font(.caption)
                            .foregroundStyle(SchoolTheme.muted)
                    }
                    Spacer()
                }

                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(inputKind.color.opacity(0.10))
                    VStack(alignment: .leading, spacing: 10) {
                        Text("мат стр 45 N 6,7,8")
                        Text("рус упр 123 правило")
                        Text("окр мир доклад про растение")
                    }
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite)
                    .padding(18)
                }
                .frame(height: 154)

                attachmentActions
            }
        }
    }

    private var attachmentActions: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Button {
                    isImageSourceDialogVisible = true
                } label: {
                    Label(imageActionTitle, systemImage: "camera.fill")
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

            if let attachmentStatus {
                Label(attachmentStatus, systemImage: "checkmark.circle.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SchoolTheme.success)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
            }
        }
    }

    private var imageActionTitle: String {
        switch inputKind {
        case .photo:
            "Фото"
        case .screenshot:
            "Скрин"
        default:
            "Изображение"
        }
    }

    private var recognizedTextCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Распознанный текст")
                    .font(.headline)
                    .foregroundStyle(SchoolTheme.graphite)

                TextEditor(text: $recognizedText)
                    .font(.body)
                    .foregroundStyle(SchoolTheme.graphite)
                    .frame(minHeight: 116)
                    .padding(10)
                    .background(SchoolTheme.page, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 15, style: .continuous)
                            .stroke(SchoolTheme.line, lineWidth: 1)
                    }

                Button {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) {
                        drafts = HomeworkParser.parse(recognizedText)
                    }
                } label: {
                    Label("Разобрать заново", systemImage: "sparkles")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: 42)
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private var parsedResultCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Результат")
                        .font(.headline)
                        .foregroundStyle(SchoolTheme.graphite)
                    Spacer()
                    InfoPill(text: "\(drafts.count) предмета", color: SchoolTheme.success)
                }

                ForEach($drafts) { $draft in
                    ParsedDraftRow(draft: $draft)
                }
            }
        }
    }

    private var aiFeedbackCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    IconBadge(systemName: "exclamationmark.bubble.fill", color: SchoolTheme.warning, size: 42)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Ошибка распознавания")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(SchoolTheme.graphite)
                        Text(aiReportStatus)
                            .font(.caption)
                            .foregroundStyle(SchoolTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                }

                Button {
                    reportAIError()
                } label: {
                    Label("Сообщить об ошибке AI", systemImage: "flag.fill")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.bordered)
                .tint(SchoolTheme.warning)
                .id("homework-ai-report")
            }
        }
    }

    private var saveButton: some View {
        Button {
            let items = drafts
                .filter { !$0.subject.trimmed.isEmpty && !$0.title.trimmed.isEmpty }
                .map { draft in
                    HomeworkItem(
                        subject: draft.subject.trimmed,
                        title: draft.title.trimmed,
                        dueLabel: draft.dueLabel.trimmed.isEmpty ? "завтра" : draft.dueLabel.trimmed,
                        source: "AI из \(inputKind.sourceName)",
                        status: .review,
                        bring: draft.bring.trimmed.isEmpty ? nil : draft.bring.trimmed,
                        attachment: attachmentStatus
                    )
                }

            onSave(items)
            dismiss()
        } label: {
            Label("Сохранить в ДЗ", systemImage: "checkmark")
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: 52)
        }
        .buttonStyle(.borderedProminent)
        .tint(SchoolTheme.success)
        .disabled(drafts.allSatisfy { $0.subject.trimmed.isEmpty || $0.title.trimmed.isEmpty })
    }

    private func showImagePicker(_ sourceType: UIImagePickerController.SourceType) {
        imagePickerSource = sourceType
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

            let fileName = url.lastPathComponent.isEmpty ? "документ" : url.lastPathComponent
            attachmentStatus = "Файл прикреплен: \(fileName)"
        case .failure:
            attachmentStatus = "Не удалось прикрепить файл"
        }
    }

    private func runQAImporterChecks() {
        let arguments = ProcessInfo.processInfo.arguments

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            if arguments.contains("-qa-homework-photo-dialog") {
                isImageSourceDialogVisible = true
            }

            if arguments.contains("-qa-homework-file-importer") {
                isFileImporterVisible = true
            }

            if arguments.contains("-qa-homework-ai-report"), !didRunAIReportQA {
                didRunAIReportQA = true
                reportAIError()
            }
        }
    }

    private func reportAIError() {
        let summary = drafts
            .map { "\($0.subject): \($0.title)" }
            .joined(separator: "; ")

        AppAIQualityLogStore.prepend(
            AIQualityLogEntry(
                source: inputKind.sourceName,
                inputSummary: summary.isEmpty ? recognizedText.trimmed : summary,
                issue: "Пользователь сообщил об ошибке распознавания ДЗ",
                confidence: 58,
                status: "Проверить",
                promptVersion: "homework-v1+user-report",
                attempts: 1,
                iconName: inputKind.iconName,
                colorName: "orange"
            )
        )
        aiReportStatus = "Отправлено в журнал качества AI. Запись появится в разделе Еще -> Качество AI"
    }
}

private struct HomeworkImagePicker: UIViewControllerRepresentable {
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
        let parent: HomeworkImagePicker

        init(parent: HomeworkImagePicker) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            let pickedURL = info[.imageURL] as? URL
            let defaultName = parent.sourceType == .camera ? "снимок \(Date().homeworkAttachmentTimestamp)" : "изображение ДЗ"
            parent.onPick(pickedURL?.lastPathComponent ?? defaultName)
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

private extension Date {
    var homeworkAttachmentTimestamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM HH:mm"
        return formatter.string(from: self)
    }
}

private struct ParsedDraftRow: View {
    @Binding var draft: ParsedHomeworkDraft

    var body: some View {
        VStack(spacing: 10) {
            HomeworkTextField(title: "Предмет", iconName: "book.closed", color: SchoolTheme.success, text: $draft.subject)
            HomeworkTextField(title: "Задание", iconName: "text.alignleft", color: SchoolTheme.accent, text: $draft.title)
            HomeworkTextField(title: "Срок", iconName: "clock", color: SchoolTheme.warning, text: $draft.dueLabel)
            HomeworkTextField(title: "Принести", iconName: "shippingbox", color: SchoolTheme.teal, text: $draft.bring)
        }
        .padding(12)
        .background(SchoolTheme.page, in: RoundedRectangle(cornerRadius: 17, style: .continuous))
    }
}

private struct HomeworkTextField: View {
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

private func sheetHeader(icon: String, color: Color, title: String, subtitle: String) -> some View {
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

private enum HomeworkSheet: Identifiable, Hashable {
    case add
    case parse(HomeworkInputKind)
    case paywall
    case archive

    var id: String {
        switch self {
        case .add:
            "add"
        case .parse(let inputKind):
            "parse-\(inputKind.rawValue)"
        case .paywall:
            "paywall"
        case .archive:
            "archive"
        }
    }
}

private struct HomeworkArchiveSheet: View {
    @Environment(\.dismiss) private var dismiss

    let items: [HomeworkItem]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    sheetHeader(
                        icon: "archivebox.fill",
                        color: SchoolTheme.success,
                        title: "Архив ДЗ",
                        subtitle: "Выполненные задания по срокам и детям"
                    )

                    DashboardCard {
                        HStack(spacing: 12) {
                            archiveMetric(value: "\(items.count)", title: "готово", color: SchoolTheme.success)
                            Divider()
                            archiveMetric(value: "\(groups.count)", title: "сроков", color: SchoolTheme.accent)
                            Divider()
                            archiveMetric(value: "\(childrenCount)", title: "детей", color: SchoolTheme.warning)
                        }
                        .frame(height: 62)
                    }

                    if items.isEmpty {
                        emptyArchive
                    } else {
                        ForEach(groups) { group in
                            archiveGroupCard(group)
                        }
                    }
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Архив")
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

    private var groups: [HomeworkArchiveGroup] {
        let grouped = Dictionary(grouping: items, by: \.dueLabel)
        return grouped
            .map { HomeworkArchiveGroup(dueLabel: $0.key, items: $0.value.sorted { $0.subject < $1.subject }) }
            .sorted { $0.dueLabel < $1.dueLabel }
    }

    private var childrenCount: Int {
        Set(items.map(\.childName)).count
    }

    private var emptyArchive: some View {
        DashboardCard {
            VStack(spacing: 12) {
                IconBadge(systemName: "tray.fill", color: SchoolTheme.muted, size: 52)
                Text("Архив пока пуст")
                    .font(.headline)
                    .foregroundStyle(SchoolTheme.graphite)
                Text("Когда задание отмечают как готовое, оно появляется здесь по сроку и ребенку.")
                    .font(.subheadline)
                    .foregroundStyle(SchoolTheme.muted)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func archiveGroupCard(_ group: HomeworkArchiveGroup) -> some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    IconBadge(systemName: "calendar.badge.checkmark", color: SchoolTheme.success, size: 42)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(group.dueLabel.capitalized)
                            .font(.headline)
                            .foregroundStyle(SchoolTheme.graphite)
                        Text("\(group.items.count) выполнено")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(SchoolTheme.muted)
                    }
                    Spacer()
                }

                ForEach(group.items) { item in
                    archiveItemRow(item)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func archiveItemRow(_ item: HomeworkItem) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(SchoolTheme.success)
                .font(.headline)
            VStack(alignment: .leading, spacing: 3) {
                Text(item.subject)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite)
                Text(item.title)
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
                Label(item.childName, systemImage: "figure.child")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SchoolTheme.accent)
            }
            Spacer()
        }
        .padding(10)
        .background(SchoolTheme.page, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func archiveMetric(value: String, title: String, color: Color) -> some View {
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

private struct HomeworkArchiveGroup: Identifiable {
    let dueLabel: String
    let items: [HomeworkItem]

    var id: String { dueLabel }
}

private struct HomeworkPaywallSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    sheetHeader(
                        icon: "creditcard.fill",
                        color: SchoolTheme.warning,
                        title: "AI-разбор по подписке",
                        subtitle: AppSubscriptionAccessStore.statusText
                    )

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Что останется доступно")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            paywallRow("Ручное ДЗ", "Можно добавлять предмет, срок, вложения и отметки выполнения", "checkmark.circle.fill", SchoolTheme.success)
                            paywallRow("Список и фильтры", "Все сохраненные задания остаются на месте", "line.3.horizontal.decrease.circle.fill", SchoolTheme.accent)
                            paywallRow("AI по фото/файлу", "Разбор доски, скрина, текста и голоса включается в trial или подписке", "sparkles", SchoolTheme.warning)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button {
                        dismiss()
                    } label: {
                        Label("Понятно", systemImage: "checkmark")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 52)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(SchoolTheme.warning)
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
                        dismiss()
                    }
                }
            }
        }
    }

    private func paywallRow(_ title: String, _ detail: String, _ icon: String, _ color: Color) -> some View {
        HStack(alignment: .top, spacing: 12) {
            IconBadge(systemName: icon, color: color, size: 40)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
    }
}

private enum HomeworkInputKind: String, CaseIterable, Identifiable, Hashable {
    case photo
    case upload
    case voice
    case screenshot
    case text

    var id: String { rawValue }

    var actionTitle: String {
        switch self {
        case .photo:
            "Сфоткать"
        case .upload:
            "Загрузить"
        case .voice:
            "Продиктовать"
        case .screenshot:
            "Скрин"
        case .text:
            "Текст"
        }
    }

    var sheetTitle: String {
        switch self {
        case .photo:
            "ДЗ по фото"
        case .upload:
            "ДЗ из файла"
        case .voice:
            "ДЗ из голоса"
        case .screenshot:
            "ДЗ из скрина"
        case .text:
            "ДЗ из текста"
        }
    }

    var previewTitle: String {
        switch self {
        case .photo:
            "Фото доски"
        case .upload:
            "Загруженное фото"
        case .voice:
            "Расшифровка голоса"
        case .screenshot:
            "Скрин из чата"
        case .text:
            "Текст"
        }
    }

    var sourceName: String {
        switch self {
        case .photo:
            "фото доски"
        case .upload:
            "файла"
        case .voice:
            "голоса"
        case .screenshot:
            "скрина"
        case .text:
            "текста"
        }
    }

    var iconName: String {
        switch self {
        case .photo:
            "camera"
        case .upload:
            "photo"
        case .voice:
            "mic"
        case .screenshot:
            "doc.viewfinder"
        case .text:
            "text.alignleft"
        }
    }

    var color: Color {
        switch self {
        case .photo, .text:
            SchoolTheme.success
        case .upload:
            SchoolTheme.accent
        case .voice:
            SchoolTheme.teal
        case .screenshot:
            SchoolTheme.warning
        }
    }

    var sampleText: String {
        switch self {
        case .voice:
            "математика страница 45 номера 6 7 8; русский упражнение 123 выучить правило; принести картон и клей"
        default:
            "мат стр 45 N 6,7,8; рус упр 123 правило; окр мир доклад про растение"
        }
    }
}

private struct ParsedHomeworkDraft: Identifiable, Hashable {
    let id = UUID()
    var subject: String
    var title: String
    var dueLabel: String
    var bring: String
}

private enum HomeworkParser {
    static func parse(_ text: String) -> [ParsedHomeworkDraft] {
        let fragments = text
            .replacingOccurrences(of: "\n", with: ";")
            .split(separator: ";")
            .map { String($0).trimmed }
            .filter { !$0.isEmpty }

        var drafts = fragments.compactMap(parseFragment)

        if drafts.isEmpty && !text.trimmed.isEmpty {
            drafts = [
                ParsedHomeworkDraft(
                    subject: "Без предмета",
                    title: text.trimmed,
                    dueLabel: "завтра",
                    bring: ""
                )
            ]
        }

        return drafts
    }

    private static func parseFragment(_ fragment: String) -> ParsedHomeworkDraft? {
        let normalized = fragment.lowercased()

        if normalized.contains("принести") {
            let bring = fragment
                .replacingOccurrences(of: "принести", with: "", options: .caseInsensitive)
                .trimmed

            return ParsedHomeworkDraft(
                subject: "Что принести",
                title: "Подготовить к школе",
                dueLabel: "завтра",
                bring: bring
            )
        }

        let subject = subjectName(for: normalized)
        let title = titleText(fragment, normalized: normalized)

        return ParsedHomeworkDraft(
            subject: subject,
            title: title.isEmpty ? fragment : title,
            dueLabel: "завтра",
            bring: ""
        )
    }

    private static func subjectName(for normalized: String) -> String {
        if normalized.hasPrefix("мат") || normalized.contains("матем") {
            return "Математика"
        }

        if normalized.hasPrefix("рус") || normalized.contains("русский") {
            return "Русский язык"
        }

        if normalized.hasPrefix("окр") || normalized.contains("окружа") {
            return "Окружающий мир"
        }

        if normalized.contains("англ") {
            return "Английский язык"
        }

        return "Без предмета"
    }

    private static func titleText(_ fragment: String, normalized: String) -> String {
        let prefixes = [
            "математика",
            "мат",
            "русский язык",
            "русский",
            "рус",
            "окружающий мир",
            "окр мир",
            "окр"
        ]

        var result = fragment.trimmed
        for prefix in prefixes where normalized.hasPrefix(prefix) {
            result = String(result.dropFirst(prefix.count)).trimmed
            break
        }

        return result
            .replacingOccurrences(of: "стр", with: "страница")
            .replacingOccurrences(of: "упр", with: "упражнение")
            .replacingOccurrences(of: "N", with: "номер")
            .replacingOccurrences(of: "№", with: "номер")
            .trimmed
    }
}

private enum HomeworkScope: String, CaseIterable, Identifiable {
    case today
    case tomorrow
    case week
    case done

    var id: String { rawValue }

    var title: String {
        switch self {
        case .today:
            "Сегодня"
        case .tomorrow:
            "Завтра"
        case .week:
            "Неделя"
        case .done:
            "Готово"
        }
    }
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

#Preview {
    HomeworkView()
}
