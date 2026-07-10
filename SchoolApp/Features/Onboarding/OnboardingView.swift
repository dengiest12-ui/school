import SwiftUI

struct OnboardingView: View {
    let onFinish: (AppUserRole) -> Void

    @AppStorage("authMethod") private var storedAuthMethod = "phone"
    @AppStorage("authContact") private var storedAuthContact = ""
    @AppStorage("authVerifiedAt") private var storedAuthVerifiedAt = ""

    @State private var mode: OnboardingMode = OnboardingView.initialMode
    @State private var authMethod: OnboardingAuthMethod = OnboardingView.initialAuthMethod
    @State private var phoneNumber = "+7 999 000-12-34"
    @State private var phoneCode = OnboardingView.initialPhoneCode
    @State private var phoneCodeSent = OnboardingView.startsPhoneVerified
    @State private var phoneStatus = OnboardingView.initialPhoneStatus
    @State private var appleEmail = "vladimir@example.com"
    @State private var appleLinked = OnboardingView.startsAppleLinked
    @State private var supabaseEmail = OnboardingView.initialSupabaseEmail
    @State private var supabasePassword = OnboardingView.initialSupabasePassword
    @State private var supabaseStatus = "Войдите через Supabase Auth, чтобы связать аккаунт с backend."
    @State private var supabaseEmailSignedIn = false
    @State private var isSupabaseSigningIn = false
    @State private var role: AppUserRole = .parent
    @State private var parentName = "Владимир"
    @State private var childName = "Миша"
    @State private var className = "3Б"
    @State private var schoolName = "Школа 1254"
    @State private var inviteCode = OnboardingView.initialInviteCode
    @State private var notificationsEnabled = true
    @State private var childDataConsent = OnboardingView.startsWithPrivacyConsent
    @State private var privacyPolicyAccepted = OnboardingView.startsWithPrivacyConsent
    @State private var didPrepareClass = OnboardingView.startsPrepared
    @FocusState private var focusedField: OnboardingField?

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    header
                    heroCard

                    if didPrepareClass {
                        readyCard
                    } else {
                        authCard
                        if authIsReady {
                            roleCard
                            modePicker
                            detailsCard
                            consentCard
                            notificationCard
                        } else {
                            accountFirstCard
                        }
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
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Готово") {
                    focusedField = nil
                }
            }
        }
    }

    private static var initialMode: OnboardingMode {
        ProcessInfo.processInfo.arguments.contains("-qa-onboarding-join") ? .join : .create
    }

    private static var initialInviteCode: String {
        initialMode == .join ? "3B-1254" : ""
    }

    private static var initialAuthMethod: OnboardingAuthMethod {
        if ProcessInfo.processInfo.arguments.contains("-qa-onboarding-supabase-email") {
            return .supabaseEmail
        }

        return ProcessInfo.processInfo.arguments.contains("-qa-onboarding-apple") ? OnboardingAuthMethod.apple : OnboardingAuthMethod.phone
    }

    private static var startsPhoneVerified: Bool {
        ProcessInfo.processInfo.arguments.contains("-qa-onboarding-phone-verified")
    }

    private static var initialPhoneCode: String {
        startsPhoneVerified ? "1234" : ""
    }

    private static var initialPhoneStatus: String {
        startsPhoneVerified ? "Телефон подтвержден локально кодом 1234" : "Код еще не отправлен"
    }

    private static var startsAppleLinked: Bool {
        ProcessInfo.processInfo.arguments.contains("-qa-onboarding-apple")
    }

    private static var initialSupabaseEmail: String {
        Bundle.main.object(forInfoDictionaryKey: "SupabaseTestEmail") as? String
            ?? ProcessInfo.processInfo.environment["SUPABASE_TEST_EMAIL"]
            ?? ""
    }

    private static var initialSupabasePassword: String {
        Bundle.main.object(forInfoDictionaryKey: "SupabaseTestPassword") as? String
            ?? ProcessInfo.processInfo.environment["SUPABASE_TEST_PASSWORD"]
            ?? ""
    }

    private static var startsPrepared: Bool {
        ProcessInfo.processInfo.arguments.contains("-qa-onboarding-ready")
    }

    private static var startsWithPrivacyConsent: Bool {
        ProcessInfo.processInfo.arguments.contains("-qa-onboarding-consent")
            || ProcessInfo.processInfo.arguments.contains("-qa-onboarding-ready")
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

    private var authCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("Вход")
                    .font(.headline)
                    .foregroundStyle(SchoolTheme.graphite)

                HStack(spacing: 8) {
                    ForEach(OnboardingAuthMethod.allCases) { method in
                        Button {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) {
                                authMethod = method
                                didPrepareClass = false
                            }
                        } label: {
                            Label(method.title, systemImage: method.iconName)
                                .font(.caption.weight(.semibold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.84)
                                .foregroundStyle(authMethod == method ? .white : SchoolTheme.graphite)
                                .frame(maxWidth: .infinity, minHeight: 40)
                                .background(authMethod == method ? method.color : SchoolTheme.page, in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }

                if authMethod == .phone {
                    phoneAuthFields
                } else if authMethod == .apple {
                    appleAuthFields
                } else {
                    supabaseEmailAuthFields
                }
            }
        }
    }

    private var phoneAuthFields: some View {
        VStack(alignment: .leading, spacing: 10) {
            OnboardingTextField(
                title: "Телефон",
                placeholder: "+7 999 000-00-00",
                iconName: "phone.fill",
                color: SchoolTheme.success,
                text: $phoneNumber,
                keyboardType: .phonePad,
                textInputAutocapitalization: .never
            )
            .focused($focusedField, equals: .phone)

            HStack(spacing: 10) {
                OnboardingTextField(
                    title: "Код",
                    placeholder: "1234",
                    iconName: "number",
                    color: phoneCodeIsValid ? SchoolTheme.success : SchoolTheme.warning,
                    text: $phoneCode,
                    keyboardType: .numberPad,
                    textInputAutocapitalization: .never
                )
                .focused($focusedField, equals: .phoneCode)

                Button {
                    sendPhoneCode()
                } label: {
                    Text(phoneCodeSent ? "Еще раз" : "Код")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SchoolTheme.success)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                        .frame(width: 88, height: 64)
                        .background(SchoolTheme.success.opacity(0.11), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
                .disabled(!phoneLooksValid)
            }

            Text(phoneStatus)
                .font(.caption)
                .foregroundStyle(phoneCodeIsValid ? SchoolTheme.success : SchoolTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var appleAuthFields: some View {
        VStack(alignment: .leading, spacing: 10) {
            OnboardingTextField(
                title: "Apple ID email",
                placeholder: "name@example.com",
                iconName: "apple.logo",
                color: appleLinked ? SchoolTheme.success : SchoolTheme.graphite,
                text: $appleEmail,
                keyboardType: .emailAddress,
                textInputAutocapitalization: .never,
                autocorrectionDisabled: true
            )
            .focused($focusedField, equals: .appleEmail)

            Button {
                appleLinked = appleEmail.trimmed.contains("@")
                phoneStatus = appleLinked ? "Apple ID привязан локально" : "Введите email Apple ID"
            } label: {
                Label(appleLinked ? "Apple ID привязан" : "Привязать Apple ID", systemImage: "apple.logo")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(appleLinked ? SchoolTheme.success : SchoolTheme.graphite)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .background((appleLinked ? SchoolTheme.success : SchoolTheme.graphite).opacity(0.10), in: Capsule())
            }
            .buttonStyle(.plain)

            Text("Сейчас это локальная привязка. Настоящий Sign in with Apple подключается через Apple ID entitlement, nonce и backend-связку аккаунта.")
                .font(.caption)
                .foregroundStyle(SchoolTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var supabaseEmailAuthFields: some View {
        VStack(alignment: .leading, spacing: 10) {
            OnboardingTextField(
                title: "Email",
                placeholder: "name@example.com",
                iconName: "envelope.badge.fill",
                color: supabaseEmailSignedIn ? SchoolTheme.success : SchoolTheme.accent,
                text: $supabaseEmail,
                keyboardType: .emailAddress,
                textInputAutocapitalization: .never,
                autocorrectionDisabled: true
            )
            .focused($focusedField, equals: .supabaseEmail)

            OnboardingSecureField(
                title: "Пароль",
                placeholder: "Пароль Supabase",
                iconName: "key.fill",
                color: supabaseEmailSignedIn ? SchoolTheme.success : SchoolTheme.warning,
                text: $supabasePassword
            )
            .focused($focusedField, equals: .supabasePassword)

            Button {
                Task {
                    await signInWithSupabaseEmail()
                }
            } label: {
                HStack(spacing: 8) {
                    if isSupabaseSigningIn {
                        ProgressView()
                            .tint(SchoolTheme.success)
                    }
                    Label(supabaseEmailSignedIn ? "Supabase подключен" : "Войти через Supabase", systemImage: supabaseEmailSignedIn ? "checkmark.seal.fill" : "person.badge.key.fill")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(supabaseEmailSignedIn ? SchoolTheme.success : SchoolTheme.accent)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background((supabaseEmailSignedIn ? SchoolTheme.success : SchoolTheme.accent).opacity(0.10), in: Capsule())
            }
            .buttonStyle(.plain)
            .disabled(isSupabaseSigningIn || supabaseEmail.trimmed.isEmpty || supabasePassword.isEmpty)

            Text(supabaseStatus)
                .font(.caption)
                .foregroundStyle(supabaseEmailSignedIn ? SchoolTheme.success : SchoolTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var roleCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Ваш статус")
                        .font(.headline)
                        .foregroundStyle(SchoolTheme.graphite)
                    Text("Выберите, кем вы будете в школьной комнате. Для разных детей роль можно поменять позже.")
                        .font(.caption)
                        .foregroundStyle(SchoolTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(spacing: 9) {
                    ForEach(AppUserRole.allCases) { item in
                        roleRow(item)
                    }
                }
            }
        }
    }

    private var accountFirstCard: some View {
        DashboardCard {
            HStack(spacing: 12) {
                IconBadge(systemName: "person.crop.circle.badge.checkmark", color: SchoolTheme.accent, size: 42)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Сначала войдите в аккаунт")
                        .font(.headline)
                        .foregroundStyle(SchoolTheme.graphite)
                    Text("После подтверждения телефона или Apple ID приложение спросит ваш статус и предложит создать класс или войти по коду.")
                        .font(.caption)
                        .foregroundStyle(SchoolTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
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
                    title: role == .child ? "Имя ребенка" : "Ваше имя",
                    placeholder: role == .child ? "Например, Миша" : "Имя родителя",
                    iconName: role == .child ? "figure.child" : "person.fill",
                    color: role == .child ? SchoolTheme.success : SchoolTheme.accent,
                    text: $parentName
                )
                .focused($focusedField, equals: .parentName)

                if role != .child {
                    OnboardingTextField(
                        title: "Ребенок",
                        placeholder: "Имя ребенка",
                        iconName: "figure.child",
                        color: SchoolTheme.success,
                        text: $childName
                    )
                    .focused($focusedField, equals: .childName)
                }

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

    private var consentCard: some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 12) {
                    IconBadge(systemName: "hand.raised.fill", color: SchoolTheme.teal, size: 42)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Приватность ребенка")
                            .font(.headline)
                            .foregroundStyle(SchoolTheme.graphite)
                        Text("Минимум данных: имя, класс, школа и связи с семьей")
                            .font(.caption)
                            .foregroundStyle(SchoolTheme.muted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                consentToggle(
                    title: "Я подтверждаю обработку данных ребенка",
                    detail: "Для домашки, событий, семьи и доступа к классу",
                    icon: "checkmark.seal.fill",
                    color: SchoolTheme.success,
                    isOn: $childDataConsent
                )

                Divider()

                consentToggle(
                    title: "Я принимаю политику конфиденциальности",
                    detail: "Удаление и экспорт данных доступны в настройках",
                    icon: "doc.text.fill",
                    color: SchoolTheme.accent,
                    isOn: $privacyPolicyAccepted
                )

                if !privacyConsentIsReady {
                    Text("Чтобы продолжить, подтвердите оба пункта. Это локальная MVP-фиксация согласия.")
                        .font(.caption)
                        .foregroundStyle(SchoolTheme.warning)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
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
                persistAuthIfNeeded()
                onFinish(role)
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

    private func roleRow(_ item: AppUserRole) -> some View {
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

    private func consentToggle(
        title: String,
        detail: String,
        icon: String,
        color: Color,
        isOn: Binding<Bool>
    ) -> some View {
        Toggle(isOn: isOn) {
            HStack(spacing: 12) {
                IconBadge(systemName: icon, color: color, size: 38)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SchoolTheme.graphite)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(SchoolTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .tint(SchoolTheme.success)
    }

    private var primaryButtonTitle: String {
        if didPrepareClass {
            return "Перейти в Сегодня"
        }

        if !authIsReady {
            return "Сначала подтвердите аккаунт"
        }

        return mode == .create ? "Создать комнату класса" : "Войти в класс"
    }

    private var canPrepare: Bool {
        guard authIsReady, privacyConsentIsReady, !parentName.trimmed.isEmpty, role == .child || !childName.trimmed.isEmpty else {
            return false
        }

        switch mode {
        case .create:
            return !className.trimmed.isEmpty && !schoolName.trimmed.isEmpty
        case .join:
            return inviteCode.trimmed.count >= 4
        }
    }

    private var authIsReady: Bool {
        switch authMethod {
        case .phone:
            return phoneLooksValid && phoneCodeIsValid
        case .apple:
            return appleLinked && appleEmail.trimmed.contains("@")
        case .supabaseEmail:
            return supabaseEmailSignedIn
        }
    }

    private var privacyConsentIsReady: Bool {
        childDataConsent && privacyPolicyAccepted
    }

    private var phoneLooksValid: Bool {
        phoneNumber.filter(\.isNumber).count >= 10
    }

    private var phoneCodeIsValid: Bool {
        phoneCode.trimmed == "1234"
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
            if role == .child {
                return "\(parentName.trimmed), \(className.trimmed). Включен детский режим без сборов и родительских чатов."
            }

            return "\(childName.trimmed), \(className.trimmed). Можно приглашать родителей."
        case .join:
            if role == .child {
                return "\(parentName.trimmed) вошел в класс по коду \(inviteCode.trimmed.uppercased()) в детском режиме."
            }

            return "\(childName.trimmed) добавлен в класс по коду \(inviteCode.trimmed.uppercased())."
        }
    }

    private func sendPhoneCode() {
        phoneCodeSent = true
        if phoneLooksValid {
            phoneStatus = "Код 1234 отправлен локально. Повторная отправка доступна."
        } else {
            phoneStatus = "Проверьте номер телефона"
        }
    }

    private func persistAuthIfNeeded() {
        storedAuthMethod = authMethod.rawValue
        switch authMethod {
        case .phone:
            storedAuthContact = phoneNumber.trimmed
        case .apple:
            storedAuthContact = appleEmail.trimmed
        case .supabaseEmail:
            storedAuthContact = supabaseEmail.trimmed
        }
        storedAuthVerifiedAt = Date.now.formatted(date: .numeric, time: .shortened)
        AppPrivacyConsentStore.save(
            childDataConsent: childDataConsent,
            policyAccepted: privacyPolicyAccepted,
            actor: parentName
        )
    }

    @MainActor
    private func signInWithSupabaseEmail() async {
        focusedField = nil
        isSupabaseSigningIn = true
        supabaseEmailSignedIn = false
        supabaseStatus = "Проверяю email/password в Supabase Auth..."

        let email = supabaseEmail.trimmed
        let result = await SupabaseAuthClient.signInWithPassword(
            email: email,
            password: supabasePassword,
            config: SupabaseBackendConfig.make()
        )

        isSupabaseSigningIn = false
        guard let session = result.session, result.isSuccess else {
            supabaseStatus = "Supabase Auth: \(result.message)"
            return
        }

        let storageSource = SupabaseSeedSessionStore.save(
            response: session,
            emailPreview: SupabaseBackendConfig.previewEmail(email)
        )
        supabaseEmailSignedIn = true
        supabaseStatus = "Supabase Auth подключен: \(storageSource). Теперь выберите статус и класс."
    }
}

private struct OnboardingTextField: View {
    let title: String
    let placeholder: String
    let iconName: String
    let color: Color
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
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
                    .keyboardType(keyboardType)
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

private struct OnboardingSecureField: View {
    let title: String
    let placeholder: String
    let iconName: String
    let color: Color
    @Binding var text: String

    var body: some View {
        HStack(spacing: 12) {
            IconBadge(systemName: iconName, color: color, size: 40)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SchoolTheme.muted)
                SecureField(placeholder, text: $text)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
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

private enum OnboardingAuthMethod: String, CaseIterable, Identifiable {
    case phone
    case apple
    case supabaseEmail

    var id: String { rawValue }

    var title: String {
        switch self {
        case .phone:
            "Телефон"
        case .apple:
            "Apple"
        case .supabaseEmail:
            "Email"
        }
    }

    var iconName: String {
        switch self {
        case .phone:
            "phone.fill"
        case .apple:
            "apple.logo"
        case .supabaseEmail:
            "envelope.badge.fill"
        }
    }

    var color: Color {
        switch self {
        case .phone:
            SchoolTheme.success
        case .apple:
            SchoolTheme.graphite
        case .supabaseEmail:
            SchoolTheme.accent
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

private enum OnboardingField: Hashable {
    case phone
    case phoneCode
    case appleEmail
    case supabaseEmail
    case supabasePassword
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
    OnboardingView { _ in }
}
