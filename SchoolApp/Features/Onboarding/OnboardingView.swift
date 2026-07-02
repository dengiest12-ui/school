import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void

    @State private var mode: OnboardingMode = OnboardingView.initialMode
    @State private var role: OnboardingRole = .parentCommittee
    @State private var parentName = "Владимир"
    @State private var childName = "Миша"
    @State private var className = "3Б"
    @State private var schoolName = "Школа 1254"
    @State private var inviteCode = OnboardingView.initialInviteCode
    @State private var notificationsEnabled = true
    @State private var didPrepareClass = OnboardingView.startsPrepared
    @FocusState private var focusedField: OnboardingField?

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    header
                    heroCard
                    modePicker

                    if didPrepareClass {
                        readyCard
                    } else {
                        roleCard
                        detailsCard
                        notificationCard
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 22)
                .padding(.bottom, 108)
            }

            VStack(spacing: 0) {
                SchoolTheme.page
                    .frame(height: 18)
                    .blur(radius: 10)

                primaryButton
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
                    .background(SchoolTheme.page)
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .background(SchoolTheme.page.ignoresSafeArea())
        .scrollDismissesKeyboard(.interactively)
        .onChange(of: mode) { _, _ in
            didPrepareClass = false
        }
    }

    private static var initialMode: OnboardingMode {
        ProcessInfo.processInfo.arguments.contains("-qa-onboarding-join") ? .join : .create
    }

    private static var initialInviteCode: String {
        initialMode == .join ? "3B-1254" : ""
    }

    private static var startsPrepared: Bool {
        ProcessInfo.processInfo.arguments.contains("-qa-onboarding-ready")
    }

    private var header: some View {
        HStack(spacing: 12) {
            IconBadge(systemName: "house.and.flag.fill", color: SchoolTheme.success, size: 50)

            VStack(alignment: .leading, spacing: 3) {
                Text("Школьный класс")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(SchoolTheme.graphite)
                Text("Комната для семьи, класса и родкомитета")
                    .font(.subheadline)
                    .foregroundStyle(SchoolTheme.muted)
            }

            Spacer()
        }
    }

    private var heroCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 18) {
                Text("Что завтра, что принести и что не забыть")
                    .font(.system(size: 31, weight: .bold))
                    .foregroundStyle(SchoolTheme.graphite)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 10) {
                    summaryPill("ДЗ", "book.closed", SchoolTheme.success)
                    summaryPill("Сборы", "rublesign.circle", SchoolTheme.warning)
                    summaryPill("События", "calendar", SchoolTheme.accent)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var modePicker: some View {
        HStack(spacing: 8) {
            ForEach(OnboardingMode.allCases) { item in
                Button {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.88)) {
                        mode = item
                    }
                } label: {
                    Label(item.title, systemImage: item.iconName)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.88)
                        .foregroundStyle(mode == item ? .white : SchoolTheme.graphite)
                        .frame(maxWidth: .infinity, minHeight: 46)
                        .background(mode == item ? SchoolTheme.success : SchoolTheme.card, in: Capsule())
                        .overlay {
                            Capsule()
                                .stroke(mode == item ? Color.clear : SchoolTheme.line, lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .accessibilityElement(children: .contain)
    }

    private var roleCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Моя роль")
                    .font(.headline)
                    .foregroundStyle(SchoolTheme.graphite)

                VStack(spacing: 9) {
                    ForEach(OnboardingRole.allCases) { item in
                        roleRow(item)
                    }
                }
            }
        }
    }

    private var detailsCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 14) {
                Text(mode.detailsTitle)
                    .font(.headline)
                    .foregroundStyle(SchoolTheme.graphite)

                OnboardingTextField(
                    title: "Ваше имя",
                    placeholder: "Имя родителя",
                    iconName: "person.fill",
                    color: SchoolTheme.accent,
                    text: $parentName
                )
                .focused($focusedField, equals: .parentName)

                OnboardingTextField(
                    title: "Ребенок",
                    placeholder: "Имя ребенка",
                    iconName: "figure.child",
                    color: SchoolTheme.success,
                    text: $childName
                )
                .focused($focusedField, equals: .childName)

                if mode == .create {
                    OnboardingTextField(
                        title: "Класс",
                        placeholder: "Например, 3Б",
                        iconName: "person.3.fill",
                        color: SchoolTheme.teal,
                        text: $className
                    )
                    .focused($focusedField, equals: .className)

                    OnboardingTextField(
                        title: "Школа",
                        placeholder: "Название школы",
                        iconName: "building.columns.fill",
                        color: SchoolTheme.warning,
                        text: $schoolName
                    )
                    .focused($focusedField, equals: .schoolName)
                } else {
                    OnboardingTextField(
                        title: "Код приглашения",
                        placeholder: "Например, 3B-1254",
                        iconName: "link",
                        color: SchoolTheme.teal,
                        text: $inviteCode,
                        textInputAutocapitalization: .characters,
                        autocorrectionDisabled: true
                    )
                    .focused($focusedField, equals: .inviteCode)
                }
            }
        }
    }

    private var notificationCard: some View {
        DashboardCard {
            Toggle(isOn: $notificationsEnabled) {
                HStack(spacing: 12) {
                    IconBadge(systemName: "bell.badge.fill", color: SchoolTheme.warning, size: 42)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Утренние и вечерние напоминания")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(SchoolTheme.graphite)
                        Text("ДЗ, форма, сборы и важные объявления")
                            .font(.caption)
                            .foregroundStyle(SchoolTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .toggleStyle(.switch)
            .tint(SchoolTheme.success)
        }
    }

    private var readyCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    IconBadge(systemName: "checkmark.seal.fill", color: SchoolTheme.success, size: 44)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(mode.readyTitle)
                            .font(.headline)
                            .foregroundStyle(SchoolTheme.graphite)
                        Text(readySubtitle)
                            .font(.subheadline)
                            .foregroundStyle(SchoolTheme.muted)
                    }
                    Spacer()
                }

                if mode == .create {
                    HStack(spacing: 10) {
                        Text("Код")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(SchoolTheme.muted)
                        Text(generatedInviteCode)
                            .font(.title3.monospacedDigit().weight(.bold))
                            .foregroundStyle(SchoolTheme.graphite)
                        Spacer()
                        Image(systemName: "square.and.arrow.up")
                            .font(.headline)
                            .foregroundStyle(SchoolTheme.success)
                    }
                    .padding(13)
                    .background(SchoolTheme.success.opacity(0.09), in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                }
            }
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private var primaryButton: some View {
        Button {
            if didPrepareClass {
                onFinish()
            } else {
                focusedField = nil
                withAnimation(.spring(response: 0.32, dampingFraction: 0.9)) {
                    didPrepareClass = true
                }
            }
        } label: {
            Label(primaryButtonTitle, systemImage: didPrepareClass ? "arrow.right" : mode.primaryIcon)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.86)
                .frame(maxWidth: .infinity, minHeight: 54)
        }
        .buttonStyle(.borderedProminent)
        .tint(SchoolTheme.success)
        .disabled(!didPrepareClass && !canPrepare)
    }

    private func summaryPill(_ title: String, _ iconName: String, _ color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: iconName)
                .font(.caption.weight(.bold))
            Text(title)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
        }
        .foregroundStyle(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(color.opacity(0.10), in: Capsule())
    }

    private func roleRow(_ item: OnboardingRole) -> some View {
        Button {
            role = item
            didPrepareClass = false
        } label: {
            HStack(spacing: 12) {
                IconBadge(systemName: item.iconName, color: role == item ? SchoolTheme.success : SchoolTheme.accent, size: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SchoolTheme.graphite)
                    Text(item.subtitle)
                        .font(.caption)
                        .foregroundStyle(SchoolTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: role == item ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(role == item ? SchoolTheme.success : SchoolTheme.muted.opacity(0.55))
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var primaryButtonTitle: String {
        if didPrepareClass {
            return "Перейти в Сегодня"
        }

        return mode == .create ? "Создать комнату класса" : "Войти в класс"
    }

    private var canPrepare: Bool {
        guard !parentName.trimmed.isEmpty, !childName.trimmed.isEmpty else {
            return false
        }

        switch mode {
        case .create:
            return !className.trimmed.isEmpty && !schoolName.trimmed.isEmpty
        case .join:
            return inviteCode.trimmed.count >= 4
        }
    }

    private var generatedInviteCode: String {
        let cleanClassName = className.trimmed.replacingOccurrences(of: " ", with: "").uppercased()
        let cleanSchoolName = schoolName.trimmed.filter(\.isNumber).suffix(4)
        let schoolPart = cleanSchoolName.isEmpty ? "2026" : String(cleanSchoolName)
        return "\(cleanClassName)-\(schoolPart)"
    }

    private var readySubtitle: String {
        switch mode {
        case .create:
            return "\(childName.trimmed), \(className.trimmed). Можно приглашать родителей."
        case .join:
            return "\(childName.trimmed) добавлен в класс по коду \(inviteCode.trimmed.uppercased())."
        }
    }
}

private struct OnboardingTextField: View {
    let title: String
    let placeholder: String
    let iconName: String
    let color: Color
    @Binding var text: String
    var textInputAutocapitalization: TextInputAutocapitalization = .sentences
    var autocorrectionDisabled = false

    var body: some View {
        HStack(spacing: 12) {
            IconBadge(systemName: iconName, color: color, size: 40)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SchoolTheme.muted)
                TextField(placeholder, text: $text)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite)
                    .textInputAutocapitalization(textInputAutocapitalization)
                    .autocorrectionDisabled(autocorrectionDisabled)
            }
        }
        .padding(12)
        .background(SchoolTheme.page, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(SchoolTheme.line, lineWidth: 1)
        }
    }
}

private enum OnboardingMode: String, CaseIterable, Identifiable {
    case create
    case join

    var id: String { rawValue }

    var title: String {
        switch self {
        case .create:
            "Создать"
        case .join:
            "Войти"
        }
    }

    var iconName: String {
        switch self {
        case .create:
            "plus.circle.fill"
        case .join:
            "link.circle.fill"
        }
    }

    var detailsTitle: String {
        switch self {
        case .create:
            "Новая комната класса"
        case .join:
            "Вход по приглашению"
        }
    }

    var readyTitle: String {
        switch self {
        case .create:
            "Комната готова"
        case .join:
            "Вы в классе"
        }
    }

    var primaryIcon: String {
        switch self {
        case .create:
            "person.3.sequence.fill"
        case .join:
            "arrowshape.turn.up.right.fill"
        }
    }
}

private enum OnboardingRole: String, CaseIterable, Identifiable {
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
}

private enum OnboardingField: Hashable {
    case parentName
    case childName
    case className
    case schoolName
    case inviteCode
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

#Preview {
    OnboardingView {}
}
