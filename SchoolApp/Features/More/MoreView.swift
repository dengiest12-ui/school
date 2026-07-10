import SwiftUI
import UniformTypeIdentifiers
import UserNotifications
import UIKit
import CoreImage.CIFilterBuiltins
import StoreKit
import Security

private struct NotificationSettingsState: Codable, Hashable {
    static let scheduledIdentifiers = [
        "school.digest.evening",
        "school.digest.morning",
        "school.collection.deadline",
        "school.urgent.announcement",
        "school.family.task"
    ]

    var eveningTime: String
    var morningTime: String
    var quietHoursEnabled: Bool
    var quietStart: String
    var quietEnd: String
    var permissionStatus: String
    var deliveryStatus: String
    var scheduledCount: Int

    static let sample = NotificationSettingsState(
        eveningTime: "20:30",
        morningTime: "07:15",
        quietHoursEnabled: true,
        quietStart: "22:00",
        quietEnd: "07:00",
        permissionStatus: "Разрешение iOS еще не запрашивалось",
        deliveryStatus: "Локальные уведомления не планировались",
        scheduledCount: 0
    )

    init(
        eveningTime: String,
        morningTime: String,
        quietHoursEnabled: Bool,
        quietStart: String,
        quietEnd: String,
        permissionStatus: String,
        deliveryStatus: String,
        scheduledCount: Int
    ) {
        self.eveningTime = eveningTime
        self.morningTime = morningTime
        self.quietHoursEnabled = quietHoursEnabled
        self.quietStart = quietStart
        self.quietEnd = quietEnd
        self.permissionStatus = permissionStatus
        self.deliveryStatus = deliveryStatus
        self.scheduledCount = scheduledCount
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        eveningTime = try container.decodeIfPresent(String.self, forKey: .eveningTime) ?? "20:30"
        morningTime = try container.decodeIfPresent(String.self, forKey: .morningTime) ?? "07:15"
        quietHoursEnabled = try container.decodeIfPresent(Bool.self, forKey: .quietHoursEnabled) ?? true
        quietStart = try container.decodeIfPresent(String.self, forKey: .quietStart) ?? "22:00"
        quietEnd = try container.decodeIfPresent(String.self, forKey: .quietEnd) ?? "07:00"
        permissionStatus = try container.decodeIfPresent(String.self, forKey: .permissionStatus) ?? "Разрешение iOS еще не запрашивалось"
        deliveryStatus = try container.decodeIfPresent(String.self, forKey: .deliveryStatus) ?? "Локальные уведомления не планировались"
        scheduledCount = try container.decodeIfPresent(Int.self, forKey: .scheduledCount) ?? 0
    }
}

private struct SecuritySettingsState: Codable, Hashable {
    var closedClassOnly: Bool
    var maskFinanceForFamily: Bool
    var requireInviteApproval: Bool
    var deleteRequestStatus: String
    var deleteScope: String
    var exportStatus: String
    var deleteConfirmation: String
    var deletionRequestId: String
    var deletionGracePeriod: String
    var deletionCanCancel: Bool
    var deletionCancelStatus: String
    var deletionReauthCode: String

    static let sample = SecuritySettingsState(
        closedClassOnly: true,
        maskFinanceForFamily: true,
        requireInviteApproval: true,
        deleteRequestStatus: "Запрос удаления не отправлялся",
        deleteScope: "Аккаунт и личные данные",
        exportStatus: "Экспорт не подготовлен",
        deleteConfirmation: "",
        deletionRequestId: "",
        deletionGracePeriod: "Период отмены не запущен",
        deletionCanCancel: false,
        deletionCancelStatus: "Отмена недоступна: активной заявки нет",
        deletionReauthCode: ""
    )

    init(
        closedClassOnly: Bool,
        maskFinanceForFamily: Bool,
        requireInviteApproval: Bool,
        deleteRequestStatus: String,
        deleteScope: String,
        exportStatus: String,
        deleteConfirmation: String,
        deletionRequestId: String = "",
        deletionGracePeriod: String = "Период отмены не запущен",
        deletionCanCancel: Bool = false,
        deletionCancelStatus: String = "Отмена недоступна: активной заявки нет",
        deletionReauthCode: String = ""
    ) {
        self.closedClassOnly = closedClassOnly
        self.maskFinanceForFamily = maskFinanceForFamily
        self.requireInviteApproval = requireInviteApproval
        self.deleteRequestStatus = deleteRequestStatus
        self.deleteScope = deleteScope
        self.exportStatus = exportStatus
        self.deleteConfirmation = deleteConfirmation
        self.deletionRequestId = deletionRequestId
        self.deletionGracePeriod = deletionGracePeriod
        self.deletionCanCancel = deletionCanCancel
        self.deletionCancelStatus = deletionCancelStatus
        self.deletionReauthCode = deletionReauthCode
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        closedClassOnly = try container.decodeIfPresent(Bool.self, forKey: .closedClassOnly) ?? true
        maskFinanceForFamily = try container.decodeIfPresent(Bool.self, forKey: .maskFinanceForFamily) ?? true
        requireInviteApproval = try container.decodeIfPresent(Bool.self, forKey: .requireInviteApproval) ?? true
        deleteRequestStatus = try container.decodeIfPresent(String.self, forKey: .deleteRequestStatus) ?? "Запрос удаления не отправлялся"
        deleteScope = try container.decodeIfPresent(String.self, forKey: .deleteScope) ?? "Аккаунт и личные данные"
        exportStatus = try container.decodeIfPresent(String.self, forKey: .exportStatus) ?? "Экспорт не подготовлен"
        deleteConfirmation = try container.decodeIfPresent(String.self, forKey: .deleteConfirmation) ?? ""
        deletionRequestId = try container.decodeIfPresent(String.self, forKey: .deletionRequestId) ?? ""
        deletionGracePeriod = try container.decodeIfPresent(String.self, forKey: .deletionGracePeriod) ?? "Период отмены не запущен"
        deletionCanCancel = try container.decodeIfPresent(Bool.self, forKey: .deletionCanCancel) ?? false
        deletionCancelStatus = try container.decodeIfPresent(String.self, forKey: .deletionCancelStatus) ?? "Отмена недоступна: активной заявки нет"
        deletionReauthCode = try container.decodeIfPresent(String.self, forKey: .deletionReauthCode) ?? ""
    }
}

private struct PrivacySettingsState: Codable, Hashable {
    var minimalChildData: Bool
    var childDataConsent: Bool
    var privacyPolicyAccepted: Bool
    var consentStatus: String

    static let sample = PrivacySettingsState(
        minimalChildData: true,
        childDataConsent: AppPrivacyConsentStore.childDataConsent,
        privacyPolicyAccepted: AppPrivacyConsentStore.policyAccepted,
        consentStatus: AppPrivacyConsentStore.statusText
    )

    func mergingStoredConsent() -> PrivacySettingsState {
        var merged = self
        if AppPrivacyConsentStore.childDataConsent || AppPrivacyConsentStore.policyAccepted {
            merged.childDataConsent = AppPrivacyConsentStore.childDataConsent
            merged.privacyPolicyAccepted = AppPrivacyConsentStore.policyAccepted
            merged.consentStatus = AppPrivacyConsentStore.statusText
        }
        return merged
    }
}

private struct ParentProfileState: Codable, Hashable {
    var name: String
    var contact: String
    var appleID: String
    var roleSummary: String

    static let sample = ParentProfileState(
        name: "Владимир",
        contact: "+7 999 000-12-34",
        appleID: "vladimir@example.com",
        roleSummary: "Родитель Миши, 3Б"
    )
}

private struct FamilyTaskSummary: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var assignee: String
    var dueLabel: String
    var reminder: String
    var status: String

    init(
        id: UUID = UUID(),
        title: String,
        assignee: String,
        dueLabel: String,
        reminder: String,
        status: String = "Назначена"
    ) {
        self.id = id
        self.title = title
        self.assignee = assignee
        self.dueLabel = dueLabel
        self.reminder = reminder
        self.status = status
    }

    static let sample = [
        FamilyTaskSummary(title: "Подписать согласие на экскурсию", assignee: "Владимир", dueLabel: "Сегодня", reminder: "19:30"),
        FamilyTaskSummary(title: "Принести картон и клей", assignee: "Ирина", dueLabel: "Завтра", reminder: "08:00"),
        FamilyTaskSummary(title: "Оплатить сбор на театр", assignee: "Екатерина", dueLabel: "до пятницы", reminder: "20:00")
    ]
}

private struct AuditLogEntry: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var detail: String
    var actor: String
    var target: String
    var category: String
    var status: String
    var timestampLabel: String
    var iconName: String
    var colorName: String

    init(
        id: UUID = UUID(),
        title: String,
        detail: String,
        actor: String,
        target: String,
        category: String,
        status: String = "Локально",
        timestampLabel: String = "сейчас",
        iconName: String,
        colorName: String
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.actor = actor
        self.target = target
        self.category = category
        self.status = status
        self.timestampLabel = timestampLabel
        self.iconName = iconName
        self.colorName = colorName
    }

    static let sample = [
        AuditLogEntry(
            title: "Создан закрытый класс",
            detail: "Код 3B-742 включен только для приглашенных семей",
            actor: "Владимир",
            target: "3Б",
            category: "Доступ",
            status: "Проверено",
            timestampLabel: "сегодня 09:12",
            iconName: "lock.shield.fill",
            colorName: "green"
        ),
        AuditLogEntry(
            title: "Родителю ограничены финансы",
            detail: "Обычный родитель видит отчет, но не меняет оплаты и расходы",
            actor: "Система ролей",
            target: "Сбор на театр",
            category: "Роли",
            status: "Проверено",
            timestampLabel: "сегодня 10:35",
            iconName: "person.badge.shield.checkmark.fill",
            colorName: "blue"
        ),
        AuditLogEntry(
            title: "Жалоба на фото сохранена",
            detail: "Фото скрыто из спорных действий до подключения модерации",
            actor: "Екатерина",
            target: "Альбом 3Б",
            category: "Модерация",
            status: "Локально",
            timestampLabel: "вчера",
            iconName: "exclamationmark.shield.fill",
            colorName: "red"
        )
    ]
}

private struct AnalyticsEventSummary: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var group: String
    var detail: String
    var count: Int
    var lastSeen: String
    var iconName: String
    var colorName: String

    init(
        id: UUID = UUID(),
        name: String,
        group: String,
        detail: String,
        count: Int,
        lastSeen: String,
        iconName: String,
        colorName: String
    ) {
        self.id = id
        self.name = name
        self.group = group
        self.detail = detail
        self.count = count
        self.lastSeen = lastSeen
        self.iconName = iconName
        self.colorName = colorName
    }

    static let sample = [
        AnalyticsEventSummary(name: "app_installed", group: "Аккаунт", detail: "Первый запуск приложения", count: 1, lastSeen: "сегодня", iconName: "iphone.gen3", colorName: "blue"),
        AnalyticsEventSummary(name: "account_created", group: "Аккаунт", detail: "Локальный профиль родителя создан", count: 1, lastSeen: "сегодня", iconName: "person.crop.circle.badge.checkmark", colorName: "green"),
        AnalyticsEventSummary(name: "child_added", group: "Аккаунт", detail: "Добавлен профиль ребенка", count: 2, lastSeen: "сегодня", iconName: "person.crop.square", colorName: "green"),
        AnalyticsEventSummary(name: "class_created", group: "Класс", detail: "Создана комната 3Б", count: 1, lastSeen: "сегодня", iconName: "building.2.fill", colorName: "blue"),
        AnalyticsEventSummary(name: "parent_invited", group: "Класс", detail: "Приглашение семьи по коду", count: 3, lastSeen: "вчера", iconName: "person.badge.plus", colorName: "teal"),
        AnalyticsEventSummary(name: "homework_created", group: "ДЗ и AI", detail: "Домашнее задание добавлено вручную", count: 5, lastSeen: "сегодня", iconName: "book.closed.fill", colorName: "green"),
        AnalyticsEventSummary(name: "homework_photo_scanned", group: "ДЗ и AI", detail: "Разбор фото или файла ДЗ", count: 2, lastSeen: "сегодня", iconName: "camera.viewfinder", colorName: "blue"),
        AnalyticsEventSummary(name: "ai_result_saved", group: "ДЗ и AI", detail: "Результат разбора подтвержден", count: 2, lastSeen: "сегодня", iconName: "sparkles", colorName: "orange"),
        AnalyticsEventSummary(name: "event_created", group: "Календарь и сборы", detail: "Событие класса добавлено", count: 2, lastSeen: "вчера", iconName: "calendar.badge.plus", colorName: "teal"),
        AnalyticsEventSummary(name: "collection_created", group: "Календарь и сборы", detail: "Сбор родкомитета создан", count: 1, lastSeen: "вчера", iconName: "rublesign.circle.fill", colorName: "orange"),
        AnalyticsEventSummary(name: "paywall_viewed", group: "Подписка", detail: "Экран подписки открыт", count: 4, lastSeen: "сегодня", iconName: "creditcard.fill", colorName: "orange"),
        AnalyticsEventSummary(name: "trial_started", group: "Подписка", detail: "Пробный период выбран локально", count: 1, lastSeen: "сегодня", iconName: "checkmark.seal.fill", colorName: "green")
    ]
}

private struct MvpMetricSummary: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var value: String
    var target: String
    var status: String
    var detail: String
    var iconName: String
    var colorName: String

    init(
        id: UUID = UUID(),
        title: String,
        value: String,
        target: String,
        status: String,
        detail: String,
        iconName: String,
        colorName: String
    ) {
        self.id = id
        self.title = title
        self.value = value
        self.target = target
        self.status = status
        self.detail = detail
        self.iconName = iconName
        self.colorName = colorName
    }

    static let sample = [
        MvpMetricSummary(title: "Активация класса", value: "68%", target: "цель 60%", status: "В норме", detail: "Есть класс, дети, семья и первые события", iconName: "flag.checkered", colorName: "green"),
        MvpMetricSummary(title: "ДЗ в неделю", value: "5", target: "цель 3+", status: "В норме", detail: "Проверяет, возвращаются ли родители за домашкой", iconName: "book.closed.fill", colorName: "green"),
        MvpMetricSummary(title: "Событие или сбор", value: "3", target: "цель 1+", status: "В норме", detail: "Класс использует календарь и родкомитет", iconName: "calendar.badge.clock", colorName: "teal"),
        MvpMetricSummary(title: "Retention 30 дней", value: "локально", target: "нужен backend", status: "Риск", detail: "Без серверной аналитики считается только как UX-заготовка", iconName: "chart.line.uptrend.xyaxis", colorName: "orange"),
        MvpMetricSummary(title: "Конверсия в подписку", value: "trial", target: "нужен StoreKit", status: "Риск", detail: "До StoreKit виден только локальный paywall-сценарий", iconName: "creditcard.fill", colorName: "orange")
    ]
}

private struct QaStateScenario: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var detail: String
    var state: String
    var expectedResult: String
    var status: String
    var iconName: String
    var colorName: String

    init(
        id: UUID = UUID(),
        title: String,
        detail: String,
        state: String,
        expectedResult: String,
        status: String = "Проверить",
        iconName: String,
        colorName: String
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.state = state
        self.expectedResult = expectedResult
        self.status = status
        self.iconName = iconName
        self.colorName = colorName
    }

    static let sample = [
        QaStateScenario(title: "Без учителя", detail: "Родитель или родкомитет запускает класс самостоятельно", state: "Нет учителя", expectedResult: "Доступны ДЗ, события, сборы, семья и приглашения", status: "Пройдено", iconName: "person.2.badge.gearshape.fill", colorName: "green"),
        QaStateScenario(title: "Нет класса", detail: "Пользователь еще не создал и не присоединился к комнате", state: "Пустой класс", expectedResult: "Показать вход по коду и создание комнаты без потери данных", iconName: "building.2.crop.circle", colorName: "blue"),
        QaStateScenario(title: "Нет ребенка", detail: "У родителя нет профиля ребенка", state: "Пустая семья", expectedResult: "Предложить добавить ребенка, не блокируя изучение приложения", iconName: "person.crop.square.fill", colorName: "teal"),
        QaStateScenario(title: "Нет ДЗ", detail: "Домашних заданий пока не добавили", state: "Пустой список", expectedResult: "Показать мягкое пустое состояние и кнопку добавления/разбора", status: "Пройдено", iconName: "tray.fill", colorName: "green"),
        QaStateScenario(title: "Нет прав", detail: "Обычный родитель открывает действия родкомитета", state: "Ограничение роли", expectedResult: "Показать объяснение и не дать менять оплаты, чеки и объявления", status: "Пройдено", iconName: "lock.shield.fill", colorName: "green"),
        QaStateScenario(title: "Нет подписки", detail: "AI и расширенные функции требуют тарифа", state: "Paywall", expectedResult: "Базовые данные остаются доступны, ограничения честно объяснены", status: "Пройдено", iconName: "creditcard.trianglebadge.exclamationmark", colorName: "green"),
        QaStateScenario(title: "Ошибка сети", detail: "Backend или файлы временно недоступны", state: "Offline", expectedResult: "Сохранить локальный черновик и показать, что синхронизация повторится", status: "Пройдено", iconName: "wifi.exclamationmark", colorName: "green"),
        QaStateScenario(title: "Отмена действия", detail: "Пользователь закрыл форму или системный picker", state: "Cancel", expectedResult: "Не создавать мусорные записи и оставить понятный статус", status: "Пройдено", iconName: "xmark.circle.fill", colorName: "green")
    ]
}

private struct SyncOperationSummary: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var entity: String
    var endpoint: String
    var status: String
    var operation: String
    var baseVersion: Int
    var payloadPreview: String
    var retryPolicy: String
    var conflictRule: String
    var iconName: String
    var colorName: String

    init(
        id: UUID = UUID(),
        title: String,
        entity: String,
        endpoint: String,
        status: String,
        operation: String = "create",
        baseVersion: Int = 1,
        payloadPreview: String = "{}",
        retryPolicy: String,
        conflictRule: String,
        iconName: String,
        colorName: String
    ) {
        self.id = id
        self.title = title
        self.entity = entity
        self.endpoint = endpoint
        self.status = status
        self.operation = operation
        self.baseVersion = baseVersion
        self.payloadPreview = payloadPreview
        self.retryPolicy = retryPolicy
        self.conflictRule = conflictRule
        self.iconName = iconName
        self.colorName = colorName
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case entity
        case endpoint
        case status
        case operation
        case baseVersion
        case payloadPreview
        case retryPolicy
        case conflictRule
        case iconName
        case colorName
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        entity = try container.decode(String.self, forKey: .entity)
        endpoint = try container.decode(String.self, forKey: .endpoint)
        status = try container.decode(String.self, forKey: .status)
        operation = try container.decodeIfPresent(String.self, forKey: .operation) ?? "create"
        baseVersion = try container.decodeIfPresent(Int.self, forKey: .baseVersion) ?? 1
        payloadPreview = try container.decodeIfPresent(String.self, forKey: .payloadPreview) ?? "{}"
        retryPolicy = try container.decode(String.self, forKey: .retryPolicy)
        conflictRule = try container.decode(String.self, forKey: .conflictRule)
        iconName = try container.decode(String.self, forKey: .iconName)
        colorName = try container.decode(String.self, forKey: .colorName)
    }

    static let sample = [
        SyncOperationSummary(
            title: "Создать класс 3Б",
            entity: "class_room",
            endpoint: "POST /classes",
            status: "Готово к API",
            payloadPreview: #"{"title":"3Б","school":"Лицей 18"}"#,
            retryPolicy: "Повторить при offline",
            conflictRule: "Код класса уникален, владелец получает роль admin",
            iconName: "building.2.fill",
            colorName: "green"
        ),
        SyncOperationSummary(
            title: "Опубликовать ДЗ",
            entity: "homework",
            endpoint: "POST /homework",
            status: "В очереди",
            payloadPreview: #"{"subject":"Математика","assignees":"class"}"#,
            retryPolicy: "Сохранить черновик и повторить",
            conflictRule: "Последняя правка автора побеждает, история остается в AuditLog",
            iconName: "book.closed.fill",
            colorName: "orange"
        ),
        SyncOperationSummary(
            title: "Подтвердить прочтение объявления",
            entity: "announcement_read",
            endpoint: "PUT /announcements/{id}/reads/me",
            status: "Локально",
            operation: "acknowledge",
            baseVersion: 4,
            payloadPreview: #"{"readAt":"client-now"}"#,
            retryPolicy: "Отправить фоном",
            conflictRule: "Read receipt идемпотентный, повтор безопасен",
            iconName: "checkmark.message.fill",
            colorName: "blue"
        ),
        SyncOperationSummary(
            title: "Добавить чек к сбору",
            entity: "collection_receipt",
            endpoint: "POST /collections/{id}/receipts",
            status: "Нужен storage",
            payloadPreview: #"{"amount":1200,"fileId":"pending-upload"}"#,
            retryPolicy: "Сначала загрузить файл, затем метаданные",
            conflictRule: "Удаление и правка только родкомитетом или автором",
            iconName: "receipt.fill",
            colorName: "orange"
        )
    ]
}

private struct SyncNetworkFailureScenario: Identifiable, Hashable {
    let id: String
    let title: String
    let detail: String
    let userMessage: String
    let queuePolicy: String
    let retryPlan: String
    let badge: String
    let colorName: String

    static let sample = [
        SyncNetworkFailureScenario(
            id: "timeout",
            title: "Timeout 8 секунд",
            detail: "POST /sync/mutations не успел ответить",
            userMessage: "Действие сохранено локально и повторится само.",
            queuePolicy: "Мутация остается в очереди, форма не сбрасывается",
            retryPlan: "Retry 1/5: 15s, 45s, 2m, 5m, 15m",
            badge: "retry",
            colorName: "orange"
        ),
        SyncNetworkFailureScenario(
            id: "offline",
            title: "Нет сети",
            detail: "Система вернула offline до отправки запроса",
            userMessage: "Пользовательские данные не теряются.",
            queuePolicy: "Отправка возобновится после восстановления сети",
            retryPlan: "Ждать network reachable, затем один dry-run",
            badge: "queue",
            colorName: "blue"
        ),
        SyncNetworkFailureScenario(
            id: "server",
            title: "5xx backend",
            detail: "Сервер временно не принял batch",
            userMessage: "Показываем понятный статус без дублей записей.",
            queuePolicy: "Idempotency key не меняется до успешного ответа",
            retryPlan: "Exponential backoff, затем ручная проверка",
            badge: "5xx",
            colorName: "red"
        )
    ]
}

private enum BackendEnvironment: String, CaseIterable, Identifiable, Codable {
    case development
    case staging
    case production

    var id: String { rawValue }

    var title: String {
        switch self {
        case .development:
            "Dev"
        case .staging:
            "Staging"
        case .production:
            "Prod"
        }
    }

    var baseURL: String {
        switch self {
        case .development:
            "https://dev-api.school-class.local"
        case .staging:
            "https://staging-api.school-class.app"
        case .production:
            "https://api.school-class.app"
        }
    }

    var status: String {
        switch self {
        case .development:
            "готовить sandbox-данные"
        case .staging:
            "проверять TestFlight"
        case .production:
            "только после юридической проверки"
        }
    }

    var storageBucketPrefix: String {
        switch self {
        case .development:
            "dev"
        case .staging:
            "staging"
        case .production:
            "prod"
        }
    }
}

private struct BetaReadinessItem: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var detail: String
    var status: String
    var iconName: String
    var colorName: String

    static let sample: [BetaReadinessItem] = [
        BetaReadinessItem(
            title: "Сборка Debug",
            detail: "Проект собирается в Simulator и проходит полный smoke-прогон.",
            status: "Готово",
            iconName: "hammer.fill",
            colorName: "green"
        ),
        BetaReadinessItem(
            title: "Критичные сценарии",
            detail: "Онбординг, дети, роли, ДЗ, календарь, сборы, объявления, чаты и настройки покрыты скриншотами.",
            status: "Готово",
            iconName: "checkmark.seal.fill",
            colorName: "green"
        ),
        BetaReadinessItem(
            title: "Реальный iPhone",
            detail: "Нужно вручную проверить камеру, уведомления, шаринг файлов, производительность и подпись на устройстве.",
            status: "Нужна проверка",
            iconName: "iphone",
            colorName: "orange"
        ),
        BetaReadinessItem(
            title: "App Store Connect",
            detail: "Нужны bundle id, команда разработчика, StoreKit products, группа тестеров и сборка Archive.",
            status: "Блокер",
            iconName: "icloud.and.arrow.up.fill",
            colorName: "red"
        ),
        BetaReadinessItem(
            title: "Юридические материалы",
            detail: "Черновики политики и условий есть, но перед внешними тестерами нужен финальный владелец и юридический обзор.",
            status: "Блокер",
            iconName: "doc.text.fill",
            colorName: "red"
        )
    ]
}

private struct ModerationQueueItem: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var target: String
    var reporter: String
    var status: String
    var priority: String
    var detail: String
    var iconName: String
    var colorName: String

    static let sample: [ModerationQueueItem] = [
        ModerationQueueItem(
            title: "Фото из экскурсии",
            target: "Альбом 4Б",
            reporter: "Мама Сони",
            status: "Новая",
            priority: "Высокий",
            detail: "На снимке виден ребенок без согласия на публикацию в альбоме класса.",
            iconName: "photo.fill",
            colorName: "red"
        ),
        ModerationQueueItem(
            title: "Сообщение в чате",
            target: "Тихий чат",
            reporter: "Папа Миши",
            status: "На проверке",
            priority: "Средний",
            detail: "Родитель отметил резкий тон в обсуждении сбора на театр.",
            iconName: "message.fill",
            colorName: "orange"
        ),
        ModerationQueueItem(
            title: "Новый участник",
            target: "Приглашение CLASS-4B",
            reporter: "Родкомитет",
            status: "Закрыта",
            priority: "Низкий",
            detail: "Проверили связь с ребенком и оставили доступ только к нужному классу.",
            iconName: "person.crop.circle.badge.questionmark",
            colorName: "green"
        )
    ]
}

private struct ModerationRule: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var detail: String
    var iconName: String
    var colorName: String

    static let sample: [ModerationRule] = [
        ModerationRule(
            title: "Фото удаляют только доверенные роли",
            detail: "Учитель, родкомитет или администратор класса могут скрыть спорное фото из локального альбома.",
            iconName: "photo.badge.exclamationmark",
            colorName: "red"
        ),
        ModerationRule(
            title: "Жалоба не видна всему классу",
            detail: "Сигнал попадает в очередь проверки, чтобы не раздувать конфликт в общем чате.",
            iconName: "eye.slash.fill",
            colorName: "teal"
        ),
        ModerationRule(
            title: "Backend должен закрепить решение",
            detail: "В продакшене статус жалобы, автор решения и аудит должны храниться на сервере.",
            iconName: "server.rack",
            colorName: "orange"
        )
    ]
}

private struct LegalDocumentItem: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var version: String
    var status: String
    var detail: String
    var iconName: String
    var colorName: String

    static let sample: [LegalDocumentItem] = [
        LegalDocumentItem(
            title: "Политика приватности",
            version: "draft 0.1",
            status: "Черновик",
            detail: "Описывает данные детей, семьи, файлов, чеков, AI-разбора, удаления и роли доступа.",
            iconName: "hand.raised.fill",
            colorName: "teal"
        ),
        LegalDocumentItem(
            title: "Пользовательское соглашение",
            version: "draft 0.1",
            status: "Черновик",
            detail: "Фиксирует правила класса, родкомитета, семейного доступа, платных функций и ограничений.",
            iconName: "doc.text.fill",
            colorName: "blue"
        ),
        LegalDocumentItem(
            title: "Согласие родителя",
            version: "MVP flow",
            status: "В приложении",
            detail: "Согласие есть в онбординге и настройках приватности; перед релизом нужна финальная формулировка.",
            iconName: "checkmark.seal.fill",
            colorName: "green"
        )
    ]
}

private struct LegalReadinessItem: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var detail: String
    var status: String
    var iconName: String
    var colorName: String

    static let sample: [LegalReadinessItem] = [
        LegalReadinessItem(
            title: "Публичная ссылка",
            detail: "Нужна постоянная HTTPS-страница политики для App Store Connect и onboarding.",
            status: "Блокер",
            iconName: "link",
            colorName: "red"
        ),
        LegalReadinessItem(
            title: "Владелец приложения",
            detail: "В документе нужно указать юрлицо/ИП, контакт поддержки и регион обработки данных.",
            status: "Блокер",
            iconName: "building.2.fill",
            colorName: "red"
        ),
        LegalReadinessItem(
            title: "Фактические провайдеры",
            detail: "После выбора backend, storage, AI и платежей нужно обновить текст и privacy nutrition labels.",
            status: "Нужна проверка",
            iconName: "server.rack",
            colorName: "orange"
        ),
        LegalReadinessItem(
            title: "Локальный MVP",
            detail: "Черновики документов и пользовательский экран готовы для внутреннего обсуждения.",
            status: "Готово",
            iconName: "checkmark.shield.fill",
            colorName: "green"
        )
    ]
}

private struct RealDeviceQaItem: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var detail: String
    var status: String
    var evidence: String
    var iconName: String
    var colorName: String

    static let sample: [RealDeviceQaItem] = [
        RealDeviceQaItem(
            title: "Подпись и запуск",
            detail: "Поставить сборку на iPhone, открыть приложение и убедиться, что подпись доверена.",
            status: "Ждет iPhone",
            evidence: "Скрин Xcode Devices + запуск на устройстве",
            iconName: "iphone.gen3",
            colorName: "orange"
        ),
        RealDeviceQaItem(
            title: "Камера и фото",
            detail: "Проверить ДЗ по фото, чек сбора, фотоальбом класса и разрешения камеры/галереи.",
            status: "Ждет iPhone",
            evidence: "Фото добавляется, превью видно, отказ разрешения не ломает экран",
            iconName: "camera.fill",
            colorName: "orange"
        ),
        RealDeviceQaItem(
            title: "Файлы и шаринг",
            detail: "Открыть document picker, прикрепить файл к ДЗ/сбору/чату и проверить системный Share Sheet.",
            status: "Ждет iPhone",
            evidence: "Имя файла сохраняется, лист шаринга открывается",
            iconName: "folder.fill",
            colorName: "orange"
        ),
        RealDeviceQaItem(
            title: "Уведомления",
            detail: "Запросить разрешение iOS, запланировать локальный тест и проверить тихие часы.",
            status: "Ждет iPhone",
            evidence: "Локальное уведомление приходит, отказ показывается в настройках",
            iconName: "bell.badge.fill",
            colorName: "orange"
        ),
        RealDeviceQaItem(
            title: "Роли и приватность",
            detail: "Пройти родителя, родкомитет, учителя и детский режим на реальном размере экрана.",
            status: "Ждет iPhone",
            evidence: "Запреты родителя и детская навигация совпадают с Simulator QA",
            iconName: "person.2.badge.gearshape.fill",
            colorName: "orange"
        ),
        RealDeviceQaItem(
            title: "Производительность",
            detail: "Проверить холодный старт, прокрутку ДЗ/класса/фото и отсутствие рывков на длинных списках.",
            status: "Ждет iPhone",
            evidence: "Нет зависаний дольше 1 секунды на ключевых вкладках",
            iconName: "speedometer",
            colorName: "orange"
        )
    ]
}

private struct BehavioralQaItem: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var invariant: String
    var smokeCase: String
    var evidence: String
    var status: String
    var iconName: String
    var colorName: String

    static let sample: [BehavioralQaItem] = [
        BehavioralQaItem(
            title: "Родительские права",
            invariant: "Родитель не создает объявления, сборы, приглашения и не меняет общий финансовый статус.",
            smokeCase: "class-parent-permissions",
            evidence: "UI-test кликает вкладку сборов под родителем и проверяет отсутствие действия создания.",
            status: "Smoke + XCTest",
            iconName: "lock.shield.fill",
            colorName: "green"
        ),
        BehavioralQaItem(
            title: "Состояния сохраняются",
            invariant: "Прочтение объявления, выбранный ребенок, ДЗ, сборы, чеки и статусы не сбрасываются при переходах.",
            smokeCase: "today-main, homework-archive, class-collection-report, ui-announcement-relaunch",
            evidence: "UI-test подтверждает прочтение объявления, перезапускает приложение и проверяет сохраненный статус.",
            status: "Smoke + XCTest",
            iconName: "externaldrive.fill",
            colorName: "orange"
        ),
        BehavioralQaItem(
            title: "Детский режим",
            invariant: "Ребенок видит только Сегодня, ДЗ и Календарь без сборов, класса и родительских обсуждений.",
            smokeCase: "child-mode",
            evidence: "Smoke и UI-test запускают роль child и проверяют безопасную навигацию.",
            status: "Smoke + XCTest",
            iconName: "figure.and.child.holdinghands",
            colorName: "green"
        ),
        BehavioralQaItem(
            title: "Offline и конфликты",
            invariant: "Операции не теряются без сети: мутации остаются в очереди и показывают понятный статус.",
            smokeCase: "more-sync-offline",
            evidence: "Sync center показывает queued/offline состояние; нужен backend e2e после API.",
            status: "Dry-run",
            iconName: "wifi.slash",
            colorName: "orange"
        ),
        BehavioralQaItem(
            title: "Paywall не ломает базовый MVP",
            invariant: "Без подписки AI закрыт paywall-ом, но ручные ДЗ, списки, календарь и фильтры остаются доступны.",
            smokeCase: "today-paywall, homework-paywall",
            evidence: "Smoke проверяет оба входа в paywall и базовые экраны ДЗ отдельно.",
            status: "Smoke",
            iconName: "creditcard.fill",
            colorName: "green"
        ),
        BehavioralQaItem(
            title: "Файлы и медиа",
            invariant: "Фото, файл, чек и голосовое вложение имеют предсказуемое состояние до backend-хранилища.",
            smokeCase: "class-chat-detail, class-photo-viewer, class-collection-report",
            evidence: "Локальные вложения видны в UI; реальная камера и файлы проверяются на iPhone gate.",
            status: "Smoke + iPhone",
            iconName: "paperclip",
            colorName: "orange"
        )
    ]
}

private struct BetaTesterGroup: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var detail: String
    var count: String
    var colorName: String

    static let sample: [BetaTesterGroup] = [
        BetaTesterGroup(title: "Внутренний тест", detail: "Владелец, родитель, родкомитет: проверка прав и данных.", count: "3-5", colorName: "blue"),
        BetaTesterGroup(title: "Пилотный класс", detail: "Родители с 2-3 детьми и разными ролями в классах.", count: "10-20", colorName: "green"),
        BetaTesterGroup(title: "Учитель/админ", detail: "Проверка объявлений, фото, участников и сценариев без оплаты.", count: "2-3", colorName: "orange")
    ]
}

private struct BetaScenario: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var detail: String
    var expected: String
    var status: String
    var colorName: String

    static let sample: [BetaScenario] = [
        BetaScenario(title: "Первый запуск", detail: "Вход, роль, код класса, ребенок, согласия.", expected: "Пользователь попадает в правильный класс", status: "Smoke passed", colorName: "green"),
        BetaScenario(title: "Родитель без прав", detail: "Пробует создать объявление, сбор, чек и менять оплаты.", expected: "Действия заблокированы интерфейсом", status: "Smoke passed", colorName: "green"),
        BetaScenario(title: "Родкомитет", detail: "Создает сбор, добавляет расход, чек и отчет.", expected: "Данные сохраняются локально", status: "Smoke passed", colorName: "green"),
        BetaScenario(title: "Несколько детей", detail: "Добавляет ребенка в другой класс и переключает вкладки.", expected: "Выбранный ребенок и класс сохраняются", status: "Smoke passed", colorName: "green"),
        BetaScenario(title: "Файлы и медиа", detail: "Прикрепляет фото/файл/voice-note в ДЗ, сборах и чатах.", expected: "Вложения видны после сохранения", status: "Smoke passed", colorName: "green"),
        BetaScenario(title: "Устройство", detail: "Камера, push permission, Share Sheet и установка на iPhone.", expected: "Работает вне Simulator", status: "Нужен iPhone", colorName: "orange")
    ]
}

private enum SyncEndpointKind: String, CaseIterable, Identifiable {
    case signedUpload
    case classRoom
    case homework
    case announcementRead
    case receipt
    case familyInvite
    case photo

    var id: String { rawValue }

    var title: String {
        switch self {
        case .signedUpload:
            "Upload URL"
        case .classRoom:
            "Класс"
        case .homework:
            "ДЗ"
        case .announcementRead:
            "Прочтение"
        case .receipt:
            "Чек"
        case .familyInvite:
            "Инвайт"
        case .photo:
            "Фото"
        }
    }

    var method: String {
        switch self {
        case .announcementRead:
            "PUT"
        default:
            "POST"
        }
    }

    var path: String {
        switch self {
        case .signedUpload:
            "/files/upload-url"
        case .classRoom:
            "/classes"
        case .homework:
            "/homework"
        case .announcementRead:
            "/announcements/{id}/reads/me"
        case .receipt:
            "/collections/{id}/receipts"
        case .familyInvite:
            "/classes/{id}/invites"
        case .photo:
            "/classes/{id}/albums/{albumId}/photos"
        }
    }

    var entity: String {
        switch self {
        case .signedUpload:
            "file_upload_intent"
        case .classRoom:
            "class_room"
        case .homework:
            "homework"
        case .announcementRead:
            "announcement_read"
        case .receipt:
            "collection_receipt"
        case .familyInvite:
            "class_invite"
        case .photo:
            "album_photo"
        }
    }

    var iconName: String {
        switch self {
        case .signedUpload:
            "externaldrive.badge.plus"
        case .classRoom:
            "building.2.fill"
        case .homework:
            "book.closed.fill"
        case .announcementRead:
            "checkmark.message.fill"
        case .receipt:
            "receipt.fill"
        case .familyInvite:
            "person.badge.plus"
        case .photo:
            "photo.stack.fill"
        }
    }

    var risk: String {
        switch self {
        case .signedUpload:
            "signed URL до отправки fileId"
        case .classRoom:
            "создает владельца и код класса"
        case .homework:
            "нужна история правок"
        case .announcementRead:
            "идемпотентный повтор"
        case .receipt:
            "сначала файл, потом метаданные"
        case .familyInvite:
            "нужен отзыв ссылки"
        case .photo:
            "приватное storage и модерация"
        }
    }

    var contractLine: String {
        "\(method) \(path)"
    }
}

private struct SyncDryRunResult: Hashable {
    var environment: BackendEnvironment
    var acceptedCount: Int
    var queuedCount: Int
    var blockedCount: Int
    var requestID: String
    var summary: String
    var mutations: [SyncMutationPreview]
    var requestPreview: SyncRequestPreview
    var clientPreview: SyncClientPreview
    var authContext: SyncAuthContext
    var storagePreflight: SyncStoragePreflight
    var networkReadiness: SyncNetworkReadiness

    static func make(environment: BackendEnvironment, operations: [SyncOperationSummary]) -> SyncDryRunResult {
        let suffix = UUID().uuidString.prefix(8).uppercased()
        let mutations = operations.enumerated().map { index, operation in
            SyncMutationPreview.make(environment: environment, operation: operation, index: index)
        }
        let requestID = "dry-\(suffix)"
        let authContext = SyncAuthContext.make(environment: environment)
        let storagePreflight = SyncStoragePreflight.make(environment: environment, mutations: mutations)
        let clientProbe = SchoolSyncClient.dryRun(
            environment: environment,
            requestID: requestID,
            authContext: authContext,
            storagePreflight: storagePreflight,
            mutations: mutations
        )

        return SyncDryRunResult(
            environment: environment,
            acceptedCount: clientProbe.acceptedCount,
            queuedCount: clientProbe.queuedCount,
            blockedCount: clientProbe.blockedCount,
            requestID: requestID,
            summary: "Dry-run: \(clientProbe.acceptedCount) можно отправить, \(clientProbe.queuedCount) ждут сети, \(clientProbe.blockedCount) требуют решения до API.",
            mutations: mutations,
            requestPreview: clientProbe.requestPreview,
            clientPreview: SyncClientPreview.make(environment: environment, probe: clientProbe),
            authContext: authContext,
            storagePreflight: storagePreflight,
            networkReadiness: SyncNetworkReadiness.make(environment: environment, probe: clientProbe)
        )
    }
}

private struct SyncMutationPreview: Identifiable, Hashable {
    var id: String { mutationID }
    var mutationID: String
    var endpoint: String
    var entity: String
    var operation: String
    var baseVersion: Int
    var payloadPreview: String
    var status: String

    var requiresStoragePreflight: Bool {
        let searchable = "\(endpoint) \(entity) \(payloadPreview)".lowercased()
        return searchable.contains("receipt")
            || searchable.contains("photo")
            || searchable.contains("file")
            || searchable.contains("document")
            || status == "blocked" && searchable.contains("storage")
    }

    static func make(environment: BackendEnvironment, operation: SyncOperationSummary, index: Int) -> SyncMutationPreview {
        let status: String
        switch operation.status {
        case "Готово к API", "Синхронизировано":
            status = "accepted"
        case "Нужен storage", "Конфликт":
            status = "blocked"
        default:
            status = "queued"
        }

        return SyncMutationPreview(
            mutationID: "\(environment.rawValue)-\(operation.entity)-\(index + 1)-\(operation.id.uuidString.prefix(6))",
            endpoint: operation.endpoint,
            entity: operation.entity,
            operation: operation.operation,
            baseVersion: operation.baseVersion,
            payloadPreview: operation.payloadPreview,
            status: status
        )
    }
}

private struct SyncRequestPreview: Hashable {
    var method: String
    var path: String
    var url: String
    var authState: String
    var idempotencyKey: String
    var bodyPreview: String

    static func make(environment: BackendEnvironment, requestID: String, mutations: [SyncMutationPreview]) -> SyncRequestPreview {
        let payload = mutations
            .prefix(3)
            .map { mutation in
                #"{"mutationId":"\#(mutation.mutationID)","entityType":"\#(mutation.entity)","operation":"\#(mutation.operation)","baseVersion":\#(mutation.baseVersion)}"#
            }
            .joined(separator: ",")
        let suffix = mutations.count > 3 ? #","more":\#(mutations.count - 3)"# : ""

        return SyncRequestPreview(
            method: "POST",
            path: "/sync/mutations",
            url: "\(environment.baseURL)/sync/mutations",
            authState: "Bearer token required",
            idempotencyKey: requestID,
            bodyPreview: #"{"clientId":"ios-local","mutations":[\#(payload)]\#(suffix)}"#
        )
    }
}

private struct SyncAuthContext: Hashable {
    var userID: String
    var sessionState: String
    var bearerPreview: String
    var refreshPlan: String
    var roleClaim: String
    var serverPolicy: String

    static func make(environment: BackendEnvironment) -> SyncAuthContext {
        let roleClaim: String
        switch environment {
        case .development:
            roleClaim = "class:demo-3b parentCommittee"
        case .staging:
            roleClaim = "class:staging-3b parentCommittee"
        case .production:
            roleClaim = "class:prod-3b parent"
        }

        return SyncAuthContext(
            userID: "user-ios-local",
            sessionState: "dry session, expires in 15 min",
            bearerPreview: "Bearer dry-\(environment.rawValue)-session",
            refreshPlan: "Refresh token before batch retry; logout on 401/403",
            roleClaim: roleClaim,
            serverPolicy: "Server must re-check class role for every mutation"
        )
    }
}

private struct SyncStoragePreflight: Hashable {
    var bucket: String
    var pendingUploads: Int
    var metadataReady: Int
    var requiredBeforeMutationIDs: [String]
    var uploadIntents: [SyncUploadIntentPreview]
    var signedResponses: [SyncSignedUploadResponsePreview]
    var scanGates: [SyncFileScanGatePreview]
    var metadataReleases: [SyncMetadataReleasePreview]
    var signedURLPlan: String
    var privacyRule: String
    var blockedReason: String

    static func make(environment: BackendEnvironment, mutations: [SyncMutationPreview]) -> SyncStoragePreflight {
        let uploadMutations = mutations.filter { mutation in
            mutation.requiresStoragePreflight
        }
        let uploadIntents = uploadMutations.enumerated().map { index, mutation in
            SyncUploadIntentPreview.make(environment: environment, mutation: mutation, index: index)
        }
        let bucket = "school-class-\(environment.storageBucketPrefix)-private"
        let signedResponses = uploadIntents.map { intent in
            SyncSignedUploadResponsePreview.make(environment: environment, bucket: bucket, intent: intent)
        }
        let scanGates = zip(uploadIntents, signedResponses).map { intent, response in
            SyncFileScanGatePreview.make(intent: intent, response: response)
        }
        let metadataReleases = zip(uploadIntents, scanGates).map { intent, gate in
            SyncMetadataReleasePreview.make(intent: intent, gate: gate)
        }

        return SyncStoragePreflight(
            bucket: bucket,
            pendingUploads: uploadMutations.count,
            metadataReady: max(0, mutations.count - uploadMutations.count),
            requiredBeforeMutationIDs: uploadMutations.map(\.mutationID),
            uploadIntents: uploadIntents,
            signedResponses: signedResponses,
            scanGates: scanGates,
            metadataReleases: metadataReleases,
            signedURLPlan: "Request signed upload URL, upload binary, receive fileId, then send metadata mutation",
            privacyRule: "Private by class/family membership; teacher/committee moderation for class photos",
            blockedReason: uploadMutations.isEmpty ? "No file upload required in this batch" : "storage_scan_required_before_metadata"
        )
    }
}

private struct SyncUploadIntentPreview: Identifiable, Hashable {
    var id: String { uploadID }
    var uploadID: String
    var mutationID: String
    var endpoint: String
    var kind: String
    var fileName: String
    var mimeType: String
    var sizeBytes: Int
    var checksumPreview: String
    var metadataPlan: String

    static func make(environment: BackendEnvironment, mutation: SyncMutationPreview, index: Int) -> SyncUploadIntentPreview {
        let kind: String
        let fileName: String
        let mimeType: String
        let sizeBytes: Int
        let metadataPlan: String

        if mutation.endpoint.contains("receipts") || mutation.entity.contains("receipt") {
            kind = "receipt"
            fileName = "receipt-\(index + 1)-\(environment.rawValue).png"
            mimeType = "image/png"
            sizeBytes = 842_120
            metadataPlan = "Attach returned fileId to collection receipt metadata"
        } else if mutation.endpoint.contains("photos") || mutation.entity.contains("photo") {
            kind = "photo"
            fileName = "album-photo-\(index + 1)-\(environment.rawValue).jpg"
            mimeType = "image/jpeg"
            sizeBytes = 1_842_440
            metadataPlan = "Attach returned fileId to album photo metadata"
        } else {
            kind = "class_document"
            fileName = "class-document-\(index + 1)-\(environment.rawValue).pdf"
            mimeType = "application/pdf"
            sizeBytes = 420_240
            metadataPlan = "Attach returned fileId to document metadata"
        }

        return SyncUploadIntentPreview(
            uploadID: "\(environment.rawValue)-upload-\(index + 1)-\(mutation.mutationID.prefix(6))",
            mutationID: mutation.mutationID,
            endpoint: "POST /files/upload-url",
            kind: kind,
            fileName: fileName,
            mimeType: mimeType,
            sizeBytes: sizeBytes,
            checksumPreview: "sha256:\(mutation.mutationID.prefix(12))",
            metadataPlan: metadataPlan
        )
    }
}

private struct SyncSignedUploadResponsePreview: Identifiable, Hashable, Codable {
    var id: String { fileID }
    var fileID: String
    var uploadURL: String
    var method: String
    var expiresAt: String
    var requiredHeader: String
    var privateBucket: String
    var storageKey: String
    var visibility: String
    var metadataPlan: String

    static func make(environment: BackendEnvironment, bucket: String, intent: SyncUploadIntentPreview) -> SyncSignedUploadResponsePreview {
        let fileID = "file-\(intent.uploadID.suffix(10))"
        let storageKey = "classes/demo-3b/\(intent.kind)/\(fileID)-\(intent.fileName)"

        return SyncSignedUploadResponsePreview(
            fileID: fileID,
            uploadURL: "\(environment.baseURL)/storage/signed/\(fileID)",
            method: "PUT",
            expiresAt: "15 min",
            requiredHeader: "Content-Type: \(intent.mimeType)",
            privateBucket: bucket,
            storageKey: storageKey,
            visibility: intent.kind == "receipt" ? "class_members" : "class_members",
            metadataPlan: "Use \(fileID) in mutation \(intent.mutationID)"
        )
    }
}

private struct SyncFileScanGatePreview: Identifiable, Hashable, Codable {
    var id: String { scanID }
    var scanID: String
    var fileID: String
    var status: String
    var queue: String
    var moderationRule: String
    var metadataGate: String

    static func make(intent: SyncUploadIntentPreview, response: SyncSignedUploadResponsePreview) -> SyncFileScanGatePreview {
        let moderationRule: String
        switch intent.kind {
        case "photo":
            moderationRule = "Teacher or committee can publish after safe scan"
        case "receipt":
            moderationRule = "Committee can attach after malware scan"
        default:
            moderationRule = "Class admins can publish after malware scan"
        }

        return SyncFileScanGatePreview(
            scanID: "scan-\(response.fileID)",
            fileID: response.fileID,
            status: "pending_scan",
            queue: "storage-scan",
            moderationRule: moderationRule,
            metadataGate: "Block metadata mutation until scanStatus is clean"
        )
    }
}

private struct SyncMetadataReleasePreview: Identifiable, Hashable, Codable {
    var id: String { mutationID }
    var mutationID: String
    var fileID: String
    var releaseStatus: String
    var payloadPatch: String
    var unlockRule: String

    static func make(intent: SyncUploadIntentPreview, gate: SyncFileScanGatePreview) -> SyncMetadataReleasePreview {
        SyncMetadataReleasePreview(
            mutationID: intent.mutationID,
            fileID: gate.fileID,
            releaseStatus: "waiting_for_clean_scan",
            payloadPatch: #"{"fileId":"\#(gate.fileID)","scanStatus":"clean"}"#,
            unlockRule: "Send metadata only after \(gate.scanID) returns clean"
        )
    }
}

private struct SyncNetworkReadiness: Hashable {
    var mode: String
    var baseURL: String
    var healthcheckPath: String
    var timeoutPolicy: String
    var retryPolicy: String
    var authFailurePolicy: String
    var releaseGate: String
    var status: String
    var statusColorName: String

    static func make(environment: BackendEnvironment, probe: SyncClientProbeResult) -> SyncNetworkReadiness {
        let status: String
        let statusColorName: String
        let releaseGate: String

        switch environment {
        case .development:
            status = "sandbox"
            statusColorName = "blue"
            releaseGate = "Use for local API once dev backend has /health and seeded class data"
        case .staging:
            status = probe.blockedCount > 0 ? "backend gate" : "ready for staging"
            statusColorName = probe.blockedCount > 0 ? "orange" : "green"
            releaseGate = "TestFlight allowed only after /health, auth refresh and storage scan pass on staging"
        case .production:
            status = "release locked"
            statusColorName = "red"
            releaseGate = "Production stays locked until legal docs, monitoring, backups and App Review checklist are complete"
        }

        return SyncNetworkReadiness(
            mode: "Dry-run now, URLSession live mode after backend flag",
            baseURL: environment.baseURL,
            healthcheckPath: "GET /health",
            timeoutPolicy: "8s request timeout, 30s upload timeout",
            retryPolicy: "Exponential backoff for 5xx/network, no retry for 401/403/validation",
            authFailurePolicy: "401 refreshes token once; 403 becomes role blocker with no local override",
            releaseGate: releaseGate,
            status: status,
            statusColorName: statusColorName
        )
    }
}

struct SupabaseBackendConfig: Hashable {
    var projectRef: String
    var region: String
    var restBaseURL: String
    var storageBaseURL: String
    var authBaseURL: String
    var publishableKey: String?
    var publishableKeyPreview: String?
    var hasPublishableKey: Bool
    var anonKey: String?
    var anonKeyPreview: String?
    var hasAnonKey: Bool
    var accessToken: String?
    var accessTokenPreview: String?
    var hasAccessToken: Bool
    var refreshToken: String?
    var hasRefreshToken: Bool
    var userID: String?
    var testEmail: String?
    var testEmailPreview: String?
    var hasTestEmail: Bool
    var testPassword: String?
    var hasTestPassword: Bool
    var storedSeedSession: StoredSupabaseSeedSession?
    var sessionSource: String
    var migrationFile: String
    var expectedTableCount: Int
    var expectedPolicyCount: Int
    var storageBucket: String
    var clientApiKey: String? {
        publishableKey ?? anonKey
    }

    var clientKeyPreview: String? {
        publishableKeyPreview ?? anonKeyPreview
    }

    var hasClientApiKey: Bool {
        clientApiKey?.isEmpty == false
    }

    var clientKeyKind: String {
        if hasPublishableKey {
            return "publishable"
        }

        if hasAnonKey {
            return "legacy anon"
        }

        return "missing"
    }

    static func make() -> SupabaseBackendConfig {
        let projectRef = "tlhjwfauddueioatkahm"
        let publishableKey = Self.readValue(named: "SUPABASE_PUBLISHABLE_KEY")
            ?? Self.readValue(named: "SupabasePublishableKey")
        let anonKey = Self.readValue(named: "SUPABASE_ANON_KEY")
            ?? Self.readValue(named: "SupabaseAnonKey")
        let accessToken = Self.readValue(named: "SUPABASE_ACCESS_TOKEN")
            ?? Self.readValue(named: "SupabaseAccessToken")
        let refreshToken = Self.readValue(named: "SUPABASE_REFRESH_TOKEN")
            ?? Self.readValue(named: "SupabaseRefreshToken")
        let userID = Self.readValue(named: "SUPABASE_USER_ID")
            ?? Self.readValue(named: "SupabaseUserID")
        let testEmail = Self.readValue(named: "SUPABASE_TEST_EMAIL")
            ?? Self.readValue(named: "SupabaseTestEmail")
        let testPassword = Self.readValue(named: "SUPABASE_TEST_PASSWORD")
            ?? Self.readValue(named: "SupabaseTestPassword")
        let storedSeedSession = SupabaseSeedSessionStore.session
        let resolvedAccessToken = accessToken ?? storedSeedSession?.accessToken
        let resolvedRefreshToken = refreshToken ?? storedSeedSession?.refreshToken
        let resolvedUserID = userID ?? storedSeedSession?.userID
        let sessionSource = accessToken?.isEmpty == false
            ? "build environment"
            : SupabaseSeedSessionStore.sessionSource

        return SupabaseBackendConfig(
            projectRef: projectRef,
            region: "eu-west-1",
            restBaseURL: "https://\(projectRef).supabase.co/rest/v1",
            storageBaseURL: "https://\(projectRef).supabase.co/storage/v1",
            authBaseURL: "https://\(projectRef).supabase.co/auth/v1",
            publishableKey: publishableKey,
            publishableKeyPreview: publishableKey.map(Self.preview),
            hasPublishableKey: publishableKey?.isEmpty == false,
            anonKey: anonKey,
            anonKeyPreview: anonKey.map(Self.preview),
            hasAnonKey: anonKey?.isEmpty == false,
            accessToken: resolvedAccessToken,
            accessTokenPreview: resolvedAccessToken.map(Self.preview),
            hasAccessToken: resolvedAccessToken?.isEmpty == false,
            refreshToken: resolvedRefreshToken,
            hasRefreshToken: resolvedRefreshToken?.isEmpty == false,
            userID: resolvedUserID,
            testEmail: testEmail,
            testEmailPreview: testEmail.map(Self.previewEmail),
            hasTestEmail: testEmail?.isEmpty == false,
            testPassword: testPassword,
            hasTestPassword: testPassword?.isEmpty == false,
            storedSeedSession: storedSeedSession,
            sessionSource: sessionSource,
            migrationFile: "supabase/migrations/20260704190000_initial_school_schema.sql",
            expectedTableCount: 14,
            expectedPolicyCount: 44,
            storageBucket: "class-files"
        )
    }

    func applying(session response: SupabaseRefreshSessionResponse) -> SupabaseBackendConfig {
        var copy = self
        if let accessToken = response.access_token, accessToken.isEmpty == false {
            copy.accessToken = accessToken
            copy.accessTokenPreview = Self.preview(accessToken)
            copy.hasAccessToken = true
        }
        if let refreshToken = response.refresh_token, refreshToken.isEmpty == false {
            copy.refreshToken = refreshToken
            copy.hasRefreshToken = true
        }
        if let userID = response.user?.id, userID.isEmpty == false {
            copy.userID = userID
        }
        copy.sessionSource = "in-memory sign-in response"
        return copy
    }

    private static func readValue(named key: String) -> String? {
        if let value = Bundle.main.object(forInfoDictionaryKey: key) as? String,
           value.isEmpty == false {
            return value
        }

        let environmentValue = ProcessInfo.processInfo.environment[key]
        return environmentValue?.isEmpty == false ? environmentValue : nil
    }

    static func preview(_ value: String) -> String {
        guard value.count > 12 else {
            return "set"
        }

        return "\(value.prefix(6))...\(value.suffix(4))"
    }

    static func previewEmail(_ value: String) -> String {
        let parts = value.split(separator: "@", maxSplits: 1)
        guard parts.count == 2 else {
            return preview(value)
        }

        let local = parts[0]
        let domain = parts[1]
        let localPreview = local.count <= 2 ? String(local) : "\(local.prefix(2))..."
        return "\(localPreview)@\(domain)"
    }
}

private struct SupabaseReadinessProbe: Identifiable, Hashable {
    var id: String { title }
    var title: String
    var status: String
    var statusColorName: String
    var endpoint: String
    var detail: String
    var nextStep: String
    var iconName: String

    static func make(config: SupabaseBackendConfig) -> [SupabaseReadinessProbe] {
        [
            SupabaseReadinessProbe(
                title: "Project",
                status: "active",
                statusColorName: "green",
                endpoint: config.projectRef,
                detail: "\(config.region), schema applied in test project",
                nextStep: "Keep test backend separate from production hosting decision",
                iconName: "server.rack"
            ),
            SupabaseReadinessProbe(
                title: "REST API",
                status: config.hasClientApiKey ? "ready" : "key missing",
                statusColorName: config.hasClientApiKey ? "green" : "orange",
                endpoint: config.restBaseURL,
                detail: "URLSession uses \(config.clientKeyKind) apikey; user JWT stays separate",
                nextStep: config.hasClientApiKey ? "Run signed request smoke against profiles/class_rooms" : "Add SUPABASE_PUBLISHABLE_KEY or SUPABASE_ANON_KEY through build config/test environment",
                iconName: "network"
            ),
            SupabaseReadinessProbe(
                title: "Schema",
                status: "verified",
                statusColorName: "green",
                endpoint: config.migrationFile,
                detail: "\(config.expectedTableCount) public tables, \(config.expectedPolicyCount) RLS/storage policies",
                nextStep: "Seed test users and class memberships before live iOS sync",
                iconName: "tablecells.fill"
            ),
            SupabaseReadinessProbe(
                title: "Storage",
                status: "private",
                statusColorName: "green",
                endpoint: "\(config.storageBaseURL)/object/\(config.storageBucket)",
                detail: "Bucket \(config.storageBucket), 15 MB, images/PDF for photos and receipts",
                nextStep: "Use signed upload flow before file metadata mutation",
                iconName: "externaldrive.badge.checkmark"
            ),
            SupabaseReadinessProbe(
                title: "Auth",
                status: "planned",
                statusColorName: "blue",
                endpoint: config.authBaseURL,
                detail: "Supabase Auth exists, app still uses local onboarding state",
                nextStep: "Map onboarding phone/Apple flow to auth.users and public.profiles",
                iconName: "person.badge.key.fill"
            )
        ]
    }
}

private struct SupabaseClassRoomRow: Decodable, Hashable {
    var id: String
    var title: String
    var invite_code: String?
}

private struct SupabaseProfileRow: Decodable, Hashable {
    var id: String
    var display_name: String
    var phone: String?

    func bridgeItem(emailPreview: String, mappedAt: String) -> SupabaseAccountProfileBridgeItem {
        SupabaseAccountProfileBridgeItem(
            userID: id,
            displayName: display_name.isEmpty ? "Supabase user" : display_name,
            phone: phone ?? "",
            emailPreview: emailPreview,
            source: "Supabase signed profiles",
            mappedAt: mappedAt
        )
    }
}

private struct SupabaseClassMembershipRow: Decodable, Hashable {
    var id: String
    var class_id: String
    var role: String
    var status: String
    var class_rooms: SupabaseClassRoomRow?
}

private struct SupabaseChildRow: Decodable, Hashable {
    var id: String
    var class_id: String
    var display_name: String
    var grade_title: String
    var class_rooms: SupabaseClassRoomRow?
}

private struct SupabaseAnnouncementReadRow: Decodable, Hashable {
    var user_id: String
    var read_at: String
}

private struct SupabaseAnnouncementRow: Decodable, Hashable {
    var id: String
    var class_id: String
    var title: String
    var body: String
    var is_urgent: Bool
    var published_at: String
    var announcement_reads: [SupabaseAnnouncementReadRow]?

    func bridgeItem(userID: String, mappedAt: String) -> SupabaseAnnouncementBridgeItem {
        SupabaseAnnouncementBridgeItem(
            id: id,
            classID: class_id,
            title: title,
            body: body,
            isUrgent: is_urgent,
            publishedAt: published_at,
            isReadByMe: announcement_reads?.contains { $0.user_id == userID } ?? false,
            source: "signed announcements RLS probe",
            mappedAt: mappedAt
        )
    }
}

private struct SupabaseHomeworkRow: Decodable, Hashable {
    var id: String
    var class_id: String
    var subject: String
    var title: String
    var details: String?
    var due_at: String?
    var assignee_child_id: String?

    func bridgeItem(mappedAt: String) -> SupabaseHomeworkBridgeItem {
        SupabaseHomeworkBridgeItem(
            id: id,
            classID: class_id,
            subject: subject,
            title: title,
            details: details ?? "",
            dueAt: due_at ?? "",
            assigneeChildID: assignee_child_id,
            source: "signed homework RLS probe",
            mappedAt: mappedAt
        )
    }
}

private struct SupabaseCalendarEventRow: Decodable, Hashable {
    var id: String
    var class_id: String
    var title: String
    var details: String?
    var starts_at: String
    var linked_collection_id: String?

    func bridgeItem(mappedAt: String) -> SupabaseCalendarEventBridgeItem {
        SupabaseCalendarEventBridgeItem(
            id: id,
            classID: class_id,
            title: title,
            details: details ?? "",
            startsAt: starts_at,
            linkedCollectionID: linked_collection_id,
            source: "signed calendar_events RLS probe",
            mappedAt: mappedAt
        )
    }
}

private struct SupabaseCollectionRow: Decodable, Hashable {
    var id: String
    var class_id: String
    var title: String
    var amount_per_family: Double
    var total_count: Int
    var paid_count: Int
    var status: String
    var due_at: String?

    func bridgeItem(mappedAt: String) -> SupabaseCollectionBridgeItem {
        SupabaseCollectionBridgeItem(
            id: id,
            classID: class_id,
            title: title,
            amountPerFamily: "\(Int(amount_per_family.rounded())) руб.",
            totalCount: total_count,
            paidCount: paid_count,
            status: status,
            dueAt: due_at ?? "",
            source: "signed collections RLS probe",
            mappedAt: mappedAt
        )
    }
}

private struct SupabaseLocalClassContextPreview: Hashable {
    var classID: String
    var classTitle: String
    var role: String
    var inviteCode: String

    var summary: String {
        "\(classTitle) [\(role), \(inviteCode)]"
    }

    func bridgeItem(mappedAt: String) -> SupabaseClassContextBridgeItem {
        SupabaseClassContextBridgeItem(
            classID: classID,
            classTitle: classTitle,
            role: role,
            inviteCode: inviteCode,
            source: "signed class_members RLS probe",
            mappedAt: mappedAt
        )
    }

    static func make(from rows: [SupabaseClassMembershipRow]) -> [SupabaseLocalClassContextPreview] {
        rows
            .filter { $0.status == "active" }
            .map { row in
                SupabaseLocalClassContextPreview(
                    classID: row.class_id,
                    classTitle: row.class_rooms?.title ?? row.class_id,
                    role: row.role,
                    inviteCode: row.class_rooms?.invite_code ?? "no code"
                )
            }
    }
}

private struct SupabaseLocalChildContextPreview: Hashable {
    var childID: String
    var childName: String
    var gradeTitle: String
    var classID: String
    var classTitle: String
    var inviteCode: String

    var summary: String {
        "\(childName), \(gradeTitle) -> \(classTitle) [\(inviteCode)]"
    }

    func bridgeItem(mappedAt: String) -> SupabaseChildContextBridgeItem {
        SupabaseChildContextBridgeItem(
            childID: childID,
            childName: childName,
            gradeTitle: gradeTitle,
            classID: classID,
            classTitle: classTitle,
            inviteCode: inviteCode,
            source: "signed children RLS probe",
            mappedAt: mappedAt
        )
    }

    static func make(from rows: [SupabaseChildRow]) -> [SupabaseLocalChildContextPreview] {
        rows.map { row in
            SupabaseLocalChildContextPreview(
                childID: row.id,
                childName: row.display_name,
                gradeTitle: row.grade_title,
                classID: row.class_id,
                classTitle: row.class_rooms?.title ?? row.class_id,
                inviteCode: row.class_rooms?.invite_code ?? "no code"
            )
        }
    }
}

private struct SupabaseErrorResponse: Decodable, Hashable {
    var code: String?
    var message: String?
    var details: String?
    var hint: String?
}

private struct SupabaseAuthSessionProbe: Hashable {
    var title: String
    var status: String
    var statusColorName: String
    var authURL: String
    var userState: String
    var tokenState: String
    var refreshState: String
    var rlsState: String
    var nextStep: String

    static func make(config: SupabaseBackendConfig) -> SupabaseAuthSessionProbe {
        if config.hasAccessToken {
            return SupabaseAuthSessionProbe(
                title: "Supabase Auth session",
                status: config.hasRefreshToken ? "ready" : "refresh missing",
                statusColorName: config.hasRefreshToken ? "green" : "orange",
                authURL: config.authBaseURL,
                userState: config.userID.map { "user \($0)" } ?? "user id not provided",
                tokenState: "Bearer \(config.accessTokenPreview ?? "set")",
                refreshState: config.hasRefreshToken ? "refresh token available for retry" : "missing SUPABASE_REFRESH_TOKEN",
                rlsState: "RLS can be checked with user JWT on class_rooms/profile rows",
                nextStep: config.hasRefreshToken ? "Run class_rooms probe with user access token and seeded membership" : "Add refresh token before retry/offline session restore"
            )
        }

        return SupabaseAuthSessionProbe(
            title: "Supabase Auth session",
            status: "session missing",
            statusColorName: "orange",
            authURL: config.authBaseURL,
            userState: config.userID.map { "seed user \($0)" } ?? "local onboarding only",
            tokenState: "missing SUPABASE_ACCESS_TOKEN",
            refreshState: "missing SUPABASE_REFRESH_TOKEN",
            rlsState: "RLS is not proven until a signed user request returns only that class",
            nextStep: "Sign in seed user or inject SUPABASE_ACCESS_TOKEN, SUPABASE_REFRESH_TOKEN and SUPABASE_USER_ID"
        )
    }
}

private struct SupabaseRefreshSessionRequest: Encodable {
    var refresh_token: String
}

private struct SupabasePasswordSignInRequest: Encodable {
    var email: String
    var password: String
}

struct SupabaseRefreshSessionResponse: Decodable, Hashable {
    var access_token: String?
    var refresh_token: String?
    var expires_in: Int?
    var token_type: String?
    var user: SupabaseRefreshSessionUser?
}

struct SupabaseRefreshSessionUser: Decodable, Hashable {
    var id: String?
}

struct StoredSupabaseSeedSession: Codable, Hashable {
    var accessToken: String
    var refreshToken: String?
    var userID: String
    var emailPreview: String?
    var savedAt: Date
    var expiresAt: Date?

    var accessTokenPreview: String {
        SupabaseBackendConfig.preview(accessToken)
    }

    var refreshState: String {
        refreshToken?.isEmpty == false ? "refresh token saved" : "refresh token missing"
    }

    var expiryState: String {
        guard let expiresAt else {
            return "expiry unknown"
        }

        return expiresAt <= Date.now
            ? "expired \(expiresAt.formatted(date: .numeric, time: .shortened))"
            : "expires \(expiresAt.formatted(date: .numeric, time: .shortened))"
    }
}

enum SupabaseSeedSessionStore {
    private static let legacyDefaultsKey = "school.supabase.seedSession.v1"
    private static let defaults = UserDefaults.standard
    private static let keychainService = "ru.codex.schoolclass.supabase"
    private static let keychainAccount = "seed-session"

    static var session: StoredSupabaseSeedSession? {
        keychainSession ?? legacySession
    }

    static var sessionSource: String {
        if keychainSession != nil {
            return "keychain seed session"
        }

        if legacySession != nil {
            return "legacy QA/UserDefaults seed session"
        }

        return "none"
    }

    private static var keychainSession: StoredSupabaseSeedSession? {
        guard
            let data = readKeychainData(),
            let session = try? JSONDecoder().decode(StoredSupabaseSeedSession.self, from: data)
        else {
            return nil
        }

        return session
    }

    private static var legacySession: StoredSupabaseSeedSession? {
        guard
            let data = defaults.data(forKey: legacyDefaultsKey),
            let session = try? JSONDecoder().decode(StoredSupabaseSeedSession.self, from: data)
        else {
            return nil
        }

        return session
    }

    @discardableResult
    static func save(response: SupabaseRefreshSessionResponse, emailPreview: String?, fallbackUserID: String? = nil) -> String {
        guard
            let accessToken = response.access_token,
            accessToken.isEmpty == false,
            let userID = response.user?.id ?? fallbackUserID,
            userID.isEmpty == false
        else {
            return sessionSource
        }

        let savedAt = Date.now
        let expiresAt = response.expires_in.map { savedAt.addingTimeInterval(TimeInterval($0)) }
        return save(
            StoredSupabaseSeedSession(
                accessToken: accessToken,
                refreshToken: response.refresh_token,
                userID: userID,
                emailPreview: emailPreview,
                savedAt: savedAt,
                expiresAt: expiresAt
            )
        )
    }

    static func seedForUITest() {
        _ = save(
            StoredSupabaseSeedSession(
                accessToken: "qa-access-token-0000",
                refreshToken: "qa-refresh-token-0000",
                userID: "qa-user-0000",
                emailPreview: "qa...@example.test",
                savedAt: Date.now,
                expiresAt: Date.now.addingTimeInterval(3600)
            )
        )
    }

    static func clear() {
        deleteKeychainData()
        defaults.removeObject(forKey: legacyDefaultsKey)
    }

    @discardableResult
    private static func save(_ session: StoredSupabaseSeedSession) -> String {
        guard let data = try? JSONEncoder().encode(session) else {
            return sessionSource
        }

        if writeKeychainData(data) {
            defaults.removeObject(forKey: legacyDefaultsKey)
            return "keychain seed session"
        }

        defaults.set(data, forKey: legacyDefaultsKey)
        return "legacy QA/UserDefaults seed session"
    }

    private static func readKeychainData() -> Data? {
        var query = baseKeychainQuery()
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess else {
            return nil
        }

        return result as? Data
    }

    private static func writeKeychainData(_ data: Data) -> Bool {
        let query = baseKeychainQuery()
        let update: [String: Any] = [kSecValueData as String: data]
        let updateStatus = SecItemUpdate(query as CFDictionary, update as CFDictionary)
        if updateStatus == errSecSuccess {
            return true
        }

        guard updateStatus == errSecItemNotFound else {
            return false
        }

        var insert = query
        insert[kSecValueData as String] = data
        insert[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        return SecItemAdd(insert as CFDictionary, nil) == errSecSuccess
    }

    private static func deleteKeychainData() {
        SecItemDelete(baseKeychainQuery() as CFDictionary)
    }

    private static func baseKeychainQuery() -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount
        ]
    }
}

private struct SupabaseStoredSeedSessionProbe: Hashable {
    var title: String
    var status: String
    var statusColorName: String
    var sourceState: String
    var tokenState: String
    var userState: String
    var expiryState: String
    var nextStep: String

    static func make(config: SupabaseBackendConfig) -> SupabaseStoredSeedSessionProbe {
        guard let session = config.storedSeedSession else {
            return SupabaseStoredSeedSessionProbe(
                title: "Stored seed session",
                status: "empty",
                statusColorName: "orange",
                sourceState: "Keychain session store empty",
                tokenState: "no local seed token saved",
                userState: "local onboarding only",
                expiryState: "no expiry",
                nextStep: "Run password sign-in with seed credentials; production auth still needs full account flow"
            )
        }

        let isExpired = session.expiresAt.map { $0 <= Date.now } ?? false
        return SupabaseStoredSeedSessionProbe(
            title: "Stored seed session",
            status: isExpired ? "expired" : "saved",
            statusColorName: isExpired ? "orange" : "green",
            sourceState: "source: \(config.sessionSource)",
            tokenState: "access \(session.accessTokenPreview), \(session.refreshState)",
            userState: "user \(session.userID), email \(session.emailPreview ?? "not saved")",
            expiryState: "\(session.expiryState), saved \(session.savedAt.formatted(date: .numeric, time: .shortened))",
            nextStep: config.sessionSource == "keychain seed session" ? "Keychain seed session is ready for QA probes; next step is full production auth flow" : "Legacy QA/UserDefaults fallback detected; run seed sign-in again to move session into Keychain"
        )
    }
}

private struct SupabasePasswordSignInProbe: Hashable {
    var title: String
    var status: String
    var statusColorName: String
    var endpoint: String
    var credentialState: String
    var sessionState: String
    var nextStep: String
    var session: SupabaseRefreshSessionResponse?

    static func planned(config: SupabaseBackendConfig) -> SupabasePasswordSignInProbe {
        if config.hasClientApiKey == false {
            return missingKey(config: config)
        }

        if config.hasTestEmail == false || config.hasTestPassword == false {
            return missingCredentials(config: config)
        }

        return SupabasePasswordSignInProbe(
            title: "Password sign-in probe",
            status: "ready",
            statusColorName: "blue",
            endpoint: "POST \(config.authBaseURL)/token?grant_type=password",
            credentialState: "seed email \(config.testEmailPreview ?? "set"), password provided",
            sessionState: "no session requested yet",
            nextStep: "Run password sign-in, then reuse returned access token for signed RLS probes without persisting it",
            session: nil
        )
    }

    static func missingKey(config: SupabaseBackendConfig) -> SupabasePasswordSignInProbe {
        SupabasePasswordSignInProbe(
            title: "Password sign-in probe",
            status: "blocked",
            statusColorName: "orange",
            endpoint: "POST \(config.authBaseURL)/token?grant_type=password",
            credentialState: "missing SUPABASE_PUBLISHABLE_KEY or SUPABASE_ANON_KEY",
            sessionState: "network skipped before credentials are sent",
            nextStep: "Add client apikey before testing Supabase Auth password sign-in",
            session: nil
        )
    }

    static func missingCredentials(config: SupabaseBackendConfig) -> SupabasePasswordSignInProbe {
        SupabasePasswordSignInProbe(
            title: "Password sign-in probe",
            status: "credentials missing",
            statusColorName: "orange",
            endpoint: "POST \(config.authBaseURL)/token?grant_type=password",
            credentialState: [
                config.hasTestEmail ? "SUPABASE_TEST_EMAIL ready" : "missing SUPABASE_TEST_EMAIL",
                config.hasTestPassword ? "SUPABASE_TEST_PASSWORD ready" : "missing SUPABASE_TEST_PASSWORD"
            ].joined(separator: ", "),
            sessionState: "network skipped before password request",
            nextStep: "Create a seed Auth user and pass SUPABASE_TEST_EMAIL / SUPABASE_TEST_PASSWORD through the test environment",
            session: nil
        )
    }

    static func success(config: SupabaseBackendConfig, response: SupabaseRefreshSessionResponse, statusCode: Int) -> SupabasePasswordSignInProbe {
        let accessPreview = response.access_token.map(SupabaseBackendConfig.preview) ?? "missing"
        let refreshState = response.refresh_token?.isEmpty == false ? "refresh token received" : "refresh token missing"
        let user = response.user?.id.map { "user \($0)" } ?? "user id missing"

        return SupabasePasswordSignInProbe(
            title: "Password sign-in probe",
            status: "HTTP \(statusCode)",
            statusColorName: response.access_token?.isEmpty == false ? "green" : "orange",
            endpoint: "POST \(config.authBaseURL)/token?grant_type=password",
            credentialState: "seed email \(config.testEmailPreview ?? "set") accepted",
            sessionState: "access \(accessPreview), \(refreshState), \(user)",
            nextStep: "Signed profile/classes/children probes can now run with this in-memory seed session",
            session: response
        )
    }

    static func serverError(config: SupabaseBackendConfig, statusCode: Int, message: String) -> SupabasePasswordSignInProbe {
        SupabasePasswordSignInProbe(
            title: "Password sign-in probe",
            status: "HTTP \(statusCode)",
            statusColorName: statusCode == 401 || statusCode == 403 ? "orange" : "red",
            endpoint: "POST \(config.authBaseURL)/token?grant_type=password",
            credentialState: "Supabase Auth rejected seed password sign-in",
            sessionState: message,
            nextStep: statusCode == 401 || statusCode == 403 ? "Check seed user email/password and email confirmation state" : "Check Supabase Auth response before enabling live login",
            session: nil
        )
    }

    static func networkError(config: SupabaseBackendConfig, message: String) -> SupabasePasswordSignInProbe {
        SupabasePasswordSignInProbe(
            title: "Password sign-in probe",
            status: "network",
            statusColorName: "red",
            endpoint: "POST \(config.authBaseURL)/token?grant_type=password",
            credentialState: config.hasTestEmail ? "seed email \(config.testEmailPreview ?? "set") prepared" : "seed email missing",
            sessionState: message,
            nextStep: "Keep local onboarding active and retry after backend/network healthcheck",
            session: nil
        )
    }
}

private struct SupabaseSessionRefreshProbe: Hashable {
    var title: String
    var status: String
    var statusColorName: String
    var endpoint: String
    var headerState: String
    var tokenState: String
    var refreshState: String
    var nextStep: String
    var session: SupabaseRefreshSessionResponse?

    static func planned(config: SupabaseBackendConfig) -> SupabaseSessionRefreshProbe {
        if config.hasClientApiKey == false {
            return missingKey(config: config)
        }

        if config.hasRefreshToken == false {
            return missingRefreshToken(config: config)
        }

        return SupabaseSessionRefreshProbe(
            title: "Auth refresh probe",
            status: "ready",
            statusColorName: "blue",
            endpoint: "POST \(config.authBaseURL)/token?grant_type=refresh_token",
            headerState: "apikey \(config.clientKeyKind) ready; no bearer fallback",
            tokenState: config.hasAccessToken ? "current access \(config.accessTokenPreview ?? "set")" : "access token optional for refresh",
            refreshState: "SUPABASE_REFRESH_TOKEN ready",
            nextStep: "Run refresh exchange, then use returned access token for signed class_rooms probe",
            session: nil
        )
    }

    static func missingKey(config: SupabaseBackendConfig) -> SupabaseSessionRefreshProbe {
        SupabaseSessionRefreshProbe(
            title: "Auth refresh probe",
            status: "blocked",
            statusColorName: "orange",
            endpoint: "POST \(config.authBaseURL)/token?grant_type=refresh_token",
            headerState: "missing SUPABASE_PUBLISHABLE_KEY or SUPABASE_ANON_KEY",
            tokenState: config.hasAccessToken ? "current access \(config.accessTokenPreview ?? "set")" : "missing SUPABASE_ACCESS_TOKEN",
            refreshState: config.hasRefreshToken ? "SUPABASE_REFRESH_TOKEN ready" : "missing SUPABASE_REFRESH_TOKEN",
            nextStep: "Add client apikey before calling Supabase Auth refresh endpoint",
            session: nil
        )
    }

    static func missingRefreshToken(config: SupabaseBackendConfig) -> SupabaseSessionRefreshProbe {
        SupabaseSessionRefreshProbe(
            title: "Auth refresh probe",
            status: "refresh missing",
            statusColorName: "orange",
            endpoint: "POST \(config.authBaseURL)/token?grant_type=refresh_token",
            headerState: "apikey \(config.clientKeyKind) ready",
            tokenState: config.hasAccessToken ? "current access \(config.accessTokenPreview ?? "set")" : "missing SUPABASE_ACCESS_TOKEN",
            refreshState: "missing SUPABASE_REFRESH_TOKEN",
            nextStep: "Sign in seed user and pass refresh token through build config/test environment",
            session: nil
        )
    }

    static func success(config: SupabaseBackendConfig, response: SupabaseRefreshSessionResponse, statusCode: Int) -> SupabaseSessionRefreshProbe {
        let accessPreview = response.access_token.map(SupabaseBackendConfig.preview) ?? "missing"
        let refreshState = response.refresh_token?.isEmpty == false ? "new refresh token received" : "refresh token not returned"
        let expires = response.expires_in.map { ", expires \($0)s" } ?? ""
        let user = response.user?.id.map { " for user \($0)" } ?? ""

        return SupabaseSessionRefreshProbe(
            title: "Auth refresh probe",
            status: "HTTP \(statusCode)",
            statusColorName: "green",
            endpoint: "POST \(config.authBaseURL)/token?grant_type=refresh_token",
            headerState: "HTTP \(statusCode), \(config.clientKeyKind) apikey accepted",
            tokenState: "access \(accessPreview)\(expires)\(user)",
            refreshState: refreshState,
            nextStep: "Use refreshed access token for signed probes and update the Keychain seed session before relying on restore",
            session: response
        )
    }

    static func serverError(config: SupabaseBackendConfig, statusCode: Int, message: String) -> SupabaseSessionRefreshProbe {
        SupabaseSessionRefreshProbe(
            title: "Auth refresh probe",
            status: "HTTP \(statusCode)",
            statusColorName: statusCode == 401 || statusCode == 403 ? "orange" : "red",
            endpoint: "POST \(config.authBaseURL)/token?grant_type=refresh_token",
            headerState: "Supabase Auth rejected refresh request",
            tokenState: message,
            refreshState: "SUPABASE_REFRESH_TOKEN was sent in JSON body",
            nextStep: statusCode == 401 || statusCode == 403 ? "Issue a fresh seed-user session and retry" : "Check Supabase Auth response before enabling session restore",
            session: nil
        )
    }

    static func networkError(config: SupabaseBackendConfig, message: String) -> SupabaseSessionRefreshProbe {
        SupabaseSessionRefreshProbe(
            title: "Auth refresh probe",
            status: "network",
            statusColorName: "red",
            endpoint: "POST \(config.authBaseURL)/token?grant_type=refresh_token",
            headerState: "\(config.clientKeyKind) apikey prepared",
            tokenState: message,
            refreshState: config.hasRefreshToken ? "SUPABASE_REFRESH_TOKEN ready" : "missing SUPABASE_REFRESH_TOKEN",
            nextStep: "Keep local session state active and retry after backend/network healthcheck",
            session: nil
        )
    }
}

private struct SupabaseSignedProfileProbe: Hashable {
    var title: String
    var status: String
    var statusColorName: String
    var method: String
    var path: String
    var url: String
    var headerState: String
    var detail: String
    var nextStep: String
    var rowsPreview: String
    var mappedProfile: SupabaseAccountProfileBridgeItem?

    static func planned(config: SupabaseBackendConfig) -> SupabaseSignedProfileProbe {
        if config.hasClientApiKey == false {
            return missingKey(config: config)
        }

        if config.hasAccessToken == false {
            return missingAccessToken(config: config)
        }

        if config.userID?.isEmpty != false {
            return missingUserID(config: config)
        }

        return SupabaseSignedProfileProbe(
            title: "Signed profile probe",
            status: "ready",
            statusColorName: "blue",
            method: "GET",
            path: "/profiles?id=eq.<SUPABASE_USER_ID>&select=id,display_name,phone",
            url: "\(config.restBaseURL)/profiles",
            headerState: "apikey \(config.clientKeyKind) ready, user bearer \(config.accessTokenPreview ?? "set")",
            detail: "Signed request will check whether RLS exposes exactly the current user's profile row.",
            nextStep: "Run signed profile probe before mapping Supabase session into local account state",
            rowsPreview: "not requested",
            mappedProfile: nil
        )
    }

    static func missingKey(config: SupabaseBackendConfig) -> SupabaseSignedProfileProbe {
        SupabaseSignedProfileProbe(
            title: "Signed profile probe",
            status: "blocked",
            statusColorName: "orange",
            method: "GET",
            path: "/profiles?id=eq.<SUPABASE_USER_ID>&select=id,display_name,phone",
            url: "\(config.restBaseURL)/profiles",
            headerState: "missing SUPABASE_PUBLISHABLE_KEY or SUPABASE_ANON_KEY",
            detail: "Signed REST request is blocked before network access.",
            nextStep: "Add client apikey, then provide SUPABASE_ACCESS_TOKEN and SUPABASE_USER_ID",
            rowsPreview: "0 rows",
            mappedProfile: nil
        )
    }

    static func missingAccessToken(config: SupabaseBackendConfig) -> SupabaseSignedProfileProbe {
        SupabaseSignedProfileProbe(
            title: "Signed profile probe",
            status: "token missing",
            statusColorName: "orange",
            method: "GET",
            path: "/profiles?id=eq.<SUPABASE_USER_ID>&select=id,display_name,phone",
            url: "\(config.restBaseURL)/profiles",
            headerState: "apikey \(config.clientKeyKind) ready, missing SUPABASE_ACCESS_TOKEN",
            detail: "Client key alone cannot prove user RLS for a profile row.",
            nextStep: "Inject a seed user's Supabase access token before signed RLS proof",
            rowsPreview: "not requested",
            mappedProfile: nil
        )
    }

    static func missingUserID(config: SupabaseBackendConfig) -> SupabaseSignedProfileProbe {
        SupabaseSignedProfileProbe(
            title: "Signed profile probe",
            status: "user id missing",
            statusColorName: "orange",
            method: "GET",
            path: "/profiles?id=eq.<SUPABASE_USER_ID>&select=id,display_name,phone",
            url: "\(config.restBaseURL)/profiles",
            headerState: "apikey \(config.clientKeyKind) ready, user bearer \(config.accessTokenPreview ?? "set")",
            detail: "Access token exists, but the app cannot target the expected profile row yet.",
            nextStep: "Provide SUPABASE_USER_ID for the seed user and retry signed profile probe",
            rowsPreview: "not requested",
            mappedProfile: nil
        )
    }

    static func success(config: SupabaseBackendConfig, rows: [SupabaseProfileRow], statusCode: Int) -> SupabaseSignedProfileProbe {
        let countStatus = rows.count == 1 ? "profile" : "RLS check"
        let preview = rows.isEmpty
            ? "[]"
            : rows.map { row in "\(row.display_name.isEmpty ? row.id : row.display_name) (\(row.phone ?? "no phone"))" }.joined(separator: ", ")
        let profile = rows.count == 1
            ? rows[0].bridgeItem(emailPreview: config.testEmail.map(SupabaseBackendConfig.previewEmail) ?? "signed session", mappedAt: Date.now.formatted(date: .numeric, time: .shortened))
            : nil

        return SupabaseSignedProfileProbe(
            title: "Signed profile probe",
            status: countStatus,
            statusColorName: rows.count == 1 ? "green" : "orange",
            method: "GET",
            path: "/profiles?id=eq.<SUPABASE_USER_ID>&select=id,display_name,phone",
            url: "\(config.restBaseURL)/profiles",
            headerState: "HTTP \(statusCode), user bearer accepted",
            detail: rows.count == 1 ? "RLS returned exactly the requested profile row." : "Signed request responded, but returned \(rows.count) profile rows.",
            nextStep: rows.count == 1 ? "Save profile bridge before class/child handoff" : "Check profile seed, RLS policy and SUPABASE_USER_ID before trusting session",
            rowsPreview: preview,
            mappedProfile: profile
        )
    }

    static func serverError(config: SupabaseBackendConfig, statusCode: Int, message: String) -> SupabaseSignedProfileProbe {
        SupabaseSignedProfileProbe(
            title: "Signed profile probe",
            status: "HTTP \(statusCode)",
            statusColorName: statusCode == 401 || statusCode == 403 ? "orange" : "red",
            method: "GET",
            path: "/profiles?id=eq.<SUPABASE_USER_ID>&select=id,display_name,phone",
            url: "\(config.restBaseURL)/profiles",
            headerState: statusCode == 401 || statusCode == 403 ? "auth/session required" : "\(config.clientKeyKind) apikey and user bearer sent",
            detail: message,
            nextStep: statusCode == 401 || statusCode == 403 ? "Refresh or reissue seed user session and retry" : "Check Data API exposure, grants, migration and RLS response",
            rowsPreview: "not decoded",
            mappedProfile: nil
        )
    }

    static func networkError(config: SupabaseBackendConfig, message: String) -> SupabaseSignedProfileProbe {
        SupabaseSignedProfileProbe(
            title: "Signed profile probe",
            status: "network",
            statusColorName: "red",
            method: "GET",
            path: "/profiles?id=eq.<SUPABASE_USER_ID>&select=id,display_name,phone",
            url: "\(config.restBaseURL)/profiles",
            headerState: "\(config.clientKeyKind) apikey and user bearer prepared",
            detail: message,
            nextStep: "Keep local profile state active and retry after network/backend healthcheck",
            rowsPreview: "not requested",
            mappedProfile: nil
        )
    }
}

private struct SupabaseSignedClassScopeProbe: Hashable {
    var title: String
    var status: String
    var statusColorName: String
    var method: String
    var path: String
    var url: String
    var headerState: String
    var detail: String
    var nextStep: String
    var rowsPreview: String
    var localContextPreview: String
    var bridgePreview: String
    var mappedContexts: [SupabaseLocalClassContextPreview]

    static func planned(config: SupabaseBackendConfig) -> SupabaseSignedClassScopeProbe {
        if config.hasClientApiKey == false {
            return missingKey(config: config)
        }

        if config.hasAccessToken == false {
            return missingAccessToken(config: config)
        }

        if config.userID?.isEmpty != false {
            return missingUserID(config: config)
        }

        return SupabaseSignedClassScopeProbe(
            title: "Signed class scope probe",
            status: "ready",
            statusColorName: "blue",
            method: "GET",
            path: "/class_members?user_id=eq.<SUPABASE_USER_ID>&select=id,class_id,role,status,class_rooms(id,title,invite_code)",
            url: "\(config.restBaseURL)/class_members",
            headerState: "apikey \(config.clientKeyKind) ready, user bearer \(config.accessTokenPreview ?? "set")",
            detail: "Signed request will check class membership rows and embedded class_rooms under RLS.",
            nextStep: "Run signed class scope probe before mapping Supabase classes into local repository",
            rowsPreview: "not requested",
            localContextPreview: "waiting for signed class rows",
            bridgePreview: "Bridge waiting: local children untouched",
            mappedContexts: []
        )
    }

    static func missingKey(config: SupabaseBackendConfig) -> SupabaseSignedClassScopeProbe {
        SupabaseSignedClassScopeProbe(
            title: "Signed class scope probe",
            status: "blocked",
            statusColorName: "orange",
            method: "GET",
            path: "/class_members?user_id=eq.<SUPABASE_USER_ID>&select=id,class_id,role,status,class_rooms(id,title,invite_code)",
            url: "\(config.restBaseURL)/class_members",
            headerState: "missing SUPABASE_PUBLISHABLE_KEY or SUPABASE_ANON_KEY",
            detail: "Signed class scope request is blocked before network access.",
            nextStep: "Add client apikey, then provide SUPABASE_ACCESS_TOKEN and SUPABASE_USER_ID",
            rowsPreview: "0 rows",
            localContextPreview: "blocked before mapper",
            bridgePreview: "Bridge waiting: local children untouched",
            mappedContexts: []
        )
    }

    static func missingAccessToken(config: SupabaseBackendConfig) -> SupabaseSignedClassScopeProbe {
        SupabaseSignedClassScopeProbe(
            title: "Signed class scope probe",
            status: "token missing",
            statusColorName: "orange",
            method: "GET",
            path: "/class_members?user_id=eq.<SUPABASE_USER_ID>&select=id,class_id,role,status,class_rooms(id,title,invite_code)",
            url: "\(config.restBaseURL)/class_members",
            headerState: "apikey \(config.clientKeyKind) ready, missing SUPABASE_ACCESS_TOKEN",
            detail: "Client key alone cannot prove membership RLS for class rows.",
            nextStep: "Inject a seed user's Supabase access token before signed class proof",
            rowsPreview: "not requested",
            localContextPreview: "waiting for user bearer token",
            bridgePreview: "Bridge waiting: local children untouched",
            mappedContexts: []
        )
    }

    static func missingUserID(config: SupabaseBackendConfig) -> SupabaseSignedClassScopeProbe {
        SupabaseSignedClassScopeProbe(
            title: "Signed class scope probe",
            status: "user id missing",
            statusColorName: "orange",
            method: "GET",
            path: "/class_members?user_id=eq.<SUPABASE_USER_ID>&select=id,class_id,role,status,class_rooms(id,title,invite_code)",
            url: "\(config.restBaseURL)/class_members",
            headerState: "apikey \(config.clientKeyKind) ready, user bearer \(config.accessTokenPreview ?? "set")",
            detail: "Access token exists, but the app cannot target the expected class membership rows yet.",
            nextStep: "Provide SUPABASE_USER_ID for the seed user and retry signed class scope probe",
            rowsPreview: "not requested",
            localContextPreview: "waiting for Supabase user id",
            bridgePreview: "Bridge waiting: local children untouched",
            mappedContexts: []
        )
    }

    static func success(config: SupabaseBackendConfig, rows: [SupabaseClassMembershipRow], statusCode: Int) -> SupabaseSignedClassScopeProbe {
        let contexts = SupabaseLocalClassContextPreview.make(from: rows)
        let status = contexts.isEmpty ? "no classes" : "mapped"
        let preview = rows.isEmpty
            ? "[]"
            : rows.map { row in
                let classTitle = row.class_rooms?.title ?? row.class_id
                let invite = row.class_rooms?.invite_code ?? "no code"
                return "\(classTitle) [\(row.role), \(row.status), \(invite)]"
            }.joined(separator: ", ")
        let mappedPreview = contexts.isEmpty ? "no active class context" : contexts.map(\.summary).joined(separator: ", ")

        return SupabaseSignedClassScopeProbe(
            title: "Signed class scope probe",
            status: status,
            statusColorName: contexts.isEmpty ? "orange" : "green",
            method: "GET",
            path: "/class_members?user_id=eq.<SUPABASE_USER_ID>&select=id,class_id,role,status,class_rooms(id,title,invite_code)",
            url: "\(config.restBaseURL)/class_members",
            headerState: "HTTP \(statusCode), user bearer accepted",
            detail: contexts.isEmpty ? "RLS returned no active class memberships for this user." : "Mapped \(contexts.count) active class context(s) from signed RLS rows.",
            nextStep: contexts.isEmpty ? "Check seed membership and class_members RLS before trusting session" : "Use mapped class contexts as the source for child/class switching after repository wiring",
            rowsPreview: preview,
            localContextPreview: mappedPreview,
            bridgePreview: contexts.isEmpty ? "Bridge waiting: local children untouched" : "Bridge ready: \(contexts.count) context(s), local children untouched",
            mappedContexts: contexts
        )
    }

    static func serverError(config: SupabaseBackendConfig, statusCode: Int, message: String) -> SupabaseSignedClassScopeProbe {
        SupabaseSignedClassScopeProbe(
            title: "Signed class scope probe",
            status: "HTTP \(statusCode)",
            statusColorName: statusCode == 401 || statusCode == 403 ? "orange" : "red",
            method: "GET",
            path: "/class_members?user_id=eq.<SUPABASE_USER_ID>&select=id,class_id,role,status,class_rooms(id,title,invite_code)",
            url: "\(config.restBaseURL)/class_members",
            headerState: statusCode == 401 || statusCode == 403 ? "auth/session required" : "\(config.clientKeyKind) apikey and user bearer sent",
            detail: message,
            nextStep: statusCode == 401 || statusCode == 403 ? "Refresh or reissue seed user session and retry" : "Check Data API exposure, grants, embeds and class_members RLS response",
            rowsPreview: "not decoded",
            localContextPreview: "mapper skipped after server error",
            bridgePreview: "Bridge waiting: local children untouched",
            mappedContexts: []
        )
    }

    static func networkError(config: SupabaseBackendConfig, message: String) -> SupabaseSignedClassScopeProbe {
        SupabaseSignedClassScopeProbe(
            title: "Signed class scope probe",
            status: "network",
            statusColorName: "red",
            method: "GET",
            path: "/class_members?user_id=eq.<SUPABASE_USER_ID>&select=id,class_id,role,status,class_rooms(id,title,invite_code)",
            url: "\(config.restBaseURL)/class_members",
            headerState: "\(config.clientKeyKind) apikey and user bearer prepared",
            detail: message,
            nextStep: "Keep local class state active and retry after network/backend healthcheck",
            rowsPreview: "not requested",
            localContextPreview: "mapper skipped after network error",
            bridgePreview: "Bridge waiting: local children untouched",
            mappedContexts: []
        )
    }
}

private struct SupabaseSignedChildrenProbe: Hashable {
    var title: String
    var status: String
    var statusColorName: String
    var method: String
    var path: String
    var url: String
    var headerState: String
    var detail: String
    var nextStep: String
    var rowsPreview: String
    var localContextPreview: String
    var bridgePreview: String
    var mappedChildren: [SupabaseLocalChildContextPreview]

    static func planned(config: SupabaseBackendConfig) -> SupabaseSignedChildrenProbe {
        if config.hasClientApiKey == false {
            return missingKey(config: config)
        }

        if config.hasAccessToken == false {
            return missingAccessToken(config: config)
        }

        if config.userID?.isEmpty != false {
            return missingUserID(config: config)
        }

        return SupabaseSignedChildrenProbe(
            title: "Signed children probe",
            status: "ready",
            statusColorName: "blue",
            method: "GET",
            path: "/children?parent_user_id=eq.<SUPABASE_USER_ID>&select=id,class_id,display_name,grade_title,class_rooms(id,title,invite_code)",
            url: "\(config.restBaseURL)/children",
            headerState: "apikey \(config.clientKeyKind) ready, user bearer \(config.accessTokenPreview ?? "set")",
            detail: "Signed request will check parent-owned children and embedded class_rooms under RLS.",
            nextStep: "Run signed children probe before replacing local child picker with Supabase children",
            rowsPreview: "not requested",
            localContextPreview: "waiting for signed child rows",
            bridgePreview: "Child bridge waiting: local selected child untouched",
            mappedChildren: []
        )
    }

    static func missingKey(config: SupabaseBackendConfig) -> SupabaseSignedChildrenProbe {
        SupabaseSignedChildrenProbe(
            title: "Signed children probe",
            status: "blocked",
            statusColorName: "orange",
            method: "GET",
            path: "/children?parent_user_id=eq.<SUPABASE_USER_ID>&select=id,class_id,display_name,grade_title,class_rooms(id,title,invite_code)",
            url: "\(config.restBaseURL)/children",
            headerState: "missing SUPABASE_PUBLISHABLE_KEY or SUPABASE_ANON_KEY",
            detail: "Signed children request is blocked before network access.",
            nextStep: "Add client apikey, then provide SUPABASE_ACCESS_TOKEN and SUPABASE_USER_ID",
            rowsPreview: "0 rows",
            localContextPreview: "blocked before child mapper",
            bridgePreview: "Child bridge waiting: local selected child untouched",
            mappedChildren: []
        )
    }

    static func missingAccessToken(config: SupabaseBackendConfig) -> SupabaseSignedChildrenProbe {
        SupabaseSignedChildrenProbe(
            title: "Signed children probe",
            status: "token missing",
            statusColorName: "orange",
            method: "GET",
            path: "/children?parent_user_id=eq.<SUPABASE_USER_ID>&select=id,class_id,display_name,grade_title,class_rooms(id,title,invite_code)",
            url: "\(config.restBaseURL)/children",
            headerState: "apikey \(config.clientKeyKind) ready, missing SUPABASE_ACCESS_TOKEN",
            detail: "Client key alone cannot prove parent-child RLS.",
            nextStep: "Inject a seed user's Supabase access token before signed children proof",
            rowsPreview: "not requested",
            localContextPreview: "waiting for user bearer token",
            bridgePreview: "Child bridge waiting: local selected child untouched",
            mappedChildren: []
        )
    }

    static func missingUserID(config: SupabaseBackendConfig) -> SupabaseSignedChildrenProbe {
        SupabaseSignedChildrenProbe(
            title: "Signed children probe",
            status: "user id missing",
            statusColorName: "orange",
            method: "GET",
            path: "/children?parent_user_id=eq.<SUPABASE_USER_ID>&select=id,class_id,display_name,grade_title,class_rooms(id,title,invite_code)",
            url: "\(config.restBaseURL)/children",
            headerState: "apikey \(config.clientKeyKind) ready, user bearer \(config.accessTokenPreview ?? "set")",
            detail: "Access token exists, but the app cannot target parent_user_id yet.",
            nextStep: "Provide SUPABASE_USER_ID for the seed parent and retry signed children probe",
            rowsPreview: "not requested",
            localContextPreview: "waiting for Supabase user id",
            bridgePreview: "Child bridge waiting: local selected child untouched",
            mappedChildren: []
        )
    }

    static func success(config: SupabaseBackendConfig, rows: [SupabaseChildRow], statusCode: Int) -> SupabaseSignedChildrenProbe {
        let children = SupabaseLocalChildContextPreview.make(from: rows)
        let preview = rows.isEmpty
            ? "[]"
            : rows.map { row in
                let classTitle = row.class_rooms?.title ?? row.class_id
                let invite = row.class_rooms?.invite_code ?? "no code"
                return "\(row.display_name), \(row.grade_title) -> \(classTitle) [\(invite)]"
            }.joined(separator: ", ")
        let mappedPreview = children.isEmpty ? "no child context" : children.map(\.summary).joined(separator: ", ")

        return SupabaseSignedChildrenProbe(
            title: "Signed children probe",
            status: children.isEmpty ? "no children" : "mapped",
            statusColorName: children.isEmpty ? "orange" : "green",
            method: "GET",
            path: "/children?parent_user_id=eq.<SUPABASE_USER_ID>&select=id,class_id,display_name,grade_title,class_rooms(id,title,invite_code)",
            url: "\(config.restBaseURL)/children",
            headerState: "HTTP \(statusCode), user bearer accepted",
            detail: children.isEmpty ? "RLS returned no children for this parent user." : "Mapped \(children.count) child context(s) from signed RLS rows.",
            nextStep: children.isEmpty ? "Check children seed and RLS before trusting child picker" : "Use mapped child contexts for Supabase-backed child/class switching after repository wiring",
            rowsPreview: preview,
            localContextPreview: mappedPreview,
            bridgePreview: children.isEmpty ? "Child bridge waiting: local selected child untouched" : "Child bridge ready: \(children.count) child context(s), local selected child untouched",
            mappedChildren: children
        )
    }

    static func serverError(config: SupabaseBackendConfig, statusCode: Int, message: String) -> SupabaseSignedChildrenProbe {
        SupabaseSignedChildrenProbe(
            title: "Signed children probe",
            status: "HTTP \(statusCode)",
            statusColorName: statusCode == 401 || statusCode == 403 ? "orange" : "red",
            method: "GET",
            path: "/children?parent_user_id=eq.<SUPABASE_USER_ID>&select=id,class_id,display_name,grade_title,class_rooms(id,title,invite_code)",
            url: "\(config.restBaseURL)/children",
            headerState: statusCode == 401 || statusCode == 403 ? "auth/session required" : "\(config.clientKeyKind) apikey and user bearer sent",
            detail: message,
            nextStep: statusCode == 401 || statusCode == 403 ? "Refresh or reissue seed parent session and retry" : "Check Data API exposure, embeds and children RLS response",
            rowsPreview: "not decoded",
            localContextPreview: "child mapper skipped after server error",
            bridgePreview: "Child bridge waiting: local selected child untouched",
            mappedChildren: []
        )
    }

    static func networkError(config: SupabaseBackendConfig, message: String) -> SupabaseSignedChildrenProbe {
        SupabaseSignedChildrenProbe(
            title: "Signed children probe",
            status: "network",
            statusColorName: "red",
            method: "GET",
            path: "/children?parent_user_id=eq.<SUPABASE_USER_ID>&select=id,class_id,display_name,grade_title,class_rooms(id,title,invite_code)",
            url: "\(config.restBaseURL)/children",
            headerState: "\(config.clientKeyKind) apikey and user bearer prepared",
            detail: message,
            nextStep: "Keep local child state active and retry after network/backend healthcheck",
            rowsPreview: "not requested",
            localContextPreview: "child mapper skipped after network error",
            bridgePreview: "Child bridge waiting: local selected child untouched",
            mappedChildren: []
        )
    }
}

private struct SupabaseSignedAnnouncementsProbe: Hashable {
    var title: String
    var status: String
    var statusColorName: String
    var method: String
    var path: String
    var url: String
    var headerState: String
    var detail: String
    var nextStep: String
    var rowsPreview: String
    var bridgePreview: String
    var mappedAnnouncements: [SupabaseAnnouncementBridgeItem]

    static func planned(config: SupabaseBackendConfig) -> SupabaseSignedAnnouncementsProbe {
        if config.hasClientApiKey == false {
            return missingKey(config: config)
        }

        if config.hasAccessToken == false {
            return missingAccessToken(config: config)
        }

        if config.userID?.isEmpty != false {
            return missingUserID(config: config)
        }

        if AppSupabaseClassContextBridge.contexts.isEmpty {
            return missingClassContext(config: config)
        }

        return SupabaseSignedAnnouncementsProbe(
            title: "Signed announcements probe",
            status: "ready",
            statusColorName: "blue",
            method: "GET",
            path: "/announcements?class_id=in.<bridge>&select=id,class_id,title,body,is_urgent,published_at,announcement_reads(user_id,read_at)",
            url: "\(config.restBaseURL)/announcements",
            headerState: "apikey \(config.clientKeyKind) ready, user bearer \(config.accessTokenPreview ?? "set")",
            detail: "Signed request will read class announcements and current-user read state under RLS.",
            nextStep: "Run signed announcements probe before replacing the local class feed",
            rowsPreview: "not requested",
            bridgePreview: AppSupabaseAnnouncementBridge.statusText,
            mappedAnnouncements: []
        )
    }

    static func missingKey(config: SupabaseBackendConfig) -> SupabaseSignedAnnouncementsProbe {
        SupabaseSignedAnnouncementsProbe(
            title: "Signed announcements probe",
            status: "blocked",
            statusColorName: "orange",
            method: "GET",
            path: "/announcements?class_id=in.<bridge>",
            url: "\(config.restBaseURL)/announcements",
            headerState: "missing SUPABASE_PUBLISHABLE_KEY or SUPABASE_ANON_KEY",
            detail: "Signed announcements request is blocked before network access.",
            nextStep: "Add client apikey, then provide signed session and class bridge",
            rowsPreview: "0 rows",
            bridgePreview: AppSupabaseAnnouncementBridge.statusText,
            mappedAnnouncements: []
        )
    }

    static func missingAccessToken(config: SupabaseBackendConfig) -> SupabaseSignedAnnouncementsProbe {
        SupabaseSignedAnnouncementsProbe(
            title: "Signed announcements probe",
            status: "token missing",
            statusColorName: "orange",
            method: "GET",
            path: "/announcements?class_id=in.<bridge>",
            url: "\(config.restBaseURL)/announcements",
            headerState: "apikey \(config.clientKeyKind) ready, missing SUPABASE_ACCESS_TOKEN",
            detail: "Client key alone cannot prove class announcement RLS.",
            nextStep: "Inject a seed user's Supabase access token before signed announcements proof",
            rowsPreview: "not requested",
            bridgePreview: AppSupabaseAnnouncementBridge.statusText,
            mappedAnnouncements: []
        )
    }

    static func missingUserID(config: SupabaseBackendConfig) -> SupabaseSignedAnnouncementsProbe {
        SupabaseSignedAnnouncementsProbe(
            title: "Signed announcements probe",
            status: "user id missing",
            statusColorName: "orange",
            method: "GET",
            path: "/announcements?class_id=in.<bridge>",
            url: "\(config.restBaseURL)/announcements",
            headerState: "apikey \(config.clientKeyKind) ready, user bearer \(config.accessTokenPreview ?? "set")",
            detail: "Access token exists, but current-user read state cannot be mapped yet.",
            nextStep: "Provide SUPABASE_USER_ID for the seed user and retry signed announcements probe",
            rowsPreview: "not requested",
            bridgePreview: AppSupabaseAnnouncementBridge.statusText,
            mappedAnnouncements: []
        )
    }

    static func missingClassContext(config: SupabaseBackendConfig) -> SupabaseSignedAnnouncementsProbe {
        SupabaseSignedAnnouncementsProbe(
            title: "Signed announcements probe",
            status: "class missing",
            statusColorName: "orange",
            method: "GET",
            path: "/announcements?class_id=in.<bridge>",
            url: "\(config.restBaseURL)/announcements",
            headerState: "apikey \(config.clientKeyKind) ready, user bearer \(config.accessTokenPreview ?? "set")",
            detail: "The app has no saved Supabase class bridge to scope announcement rows.",
            nextStep: "Run signed class scope probe first, then retry announcements",
            rowsPreview: "not requested",
            bridgePreview: AppSupabaseAnnouncementBridge.statusText,
            mappedAnnouncements: []
        )
    }

    static func success(config: SupabaseBackendConfig, rows: [SupabaseAnnouncementRow], statusCode: Int) -> SupabaseSignedAnnouncementsProbe {
        let mappedAt = Date.now.formatted(date: .numeric, time: .shortened)
        let userID = config.userID ?? ""
        let announcements = rows.map { $0.bridgeItem(userID: userID, mappedAt: mappedAt) }
        let preview = announcements.isEmpty
            ? "[]"
            : announcements.map(\.summary).joined(separator: ", ")

        return SupabaseSignedAnnouncementsProbe(
            title: "Signed announcements probe",
            status: announcements.isEmpty ? "empty" : "mapped",
            statusColorName: announcements.isEmpty ? "orange" : "green",
            method: "GET",
            path: "/announcements?class_id=in.<bridge>&select=id,class_id,title,body,is_urgent,published_at,announcement_reads(user_id,read_at)",
            url: "\(config.restBaseURL)/announcements",
            headerState: "HTTP \(statusCode), user bearer accepted",
            detail: announcements.isEmpty ? "RLS returned no announcements for saved class context." : "Mapped \(announcements.count) announcement(s) from signed RLS rows.",
            nextStep: announcements.isEmpty ? "Seed class announcements or verify RLS before feed switch" : "Keep bridge preview until the local class feed repository can switch safely",
            rowsPreview: preview,
            bridgePreview: announcements.isEmpty ? "Announcement bridge waiting: local feed active" : "Announcement bridge ready: \(announcements.count) item(s), local feed still active",
            mappedAnnouncements: announcements
        )
    }

    static func serverError(config: SupabaseBackendConfig, statusCode: Int, message: String) -> SupabaseSignedAnnouncementsProbe {
        SupabaseSignedAnnouncementsProbe(
            title: "Signed announcements probe",
            status: "HTTP \(statusCode)",
            statusColorName: statusCode == 401 || statusCode == 403 ? "orange" : "red",
            method: "GET",
            path: "/announcements?class_id=in.<bridge>",
            url: "\(config.restBaseURL)/announcements",
            headerState: statusCode == 401 || statusCode == 403 ? "auth/session required" : "\(config.clientKeyKind) apikey and user bearer sent",
            detail: message,
            nextStep: statusCode == 401 || statusCode == 403 ? "Refresh or reissue seed user session and retry" : "Check Data API exposure, embeds and announcements RLS response",
            rowsPreview: "not decoded",
            bridgePreview: AppSupabaseAnnouncementBridge.statusText,
            mappedAnnouncements: []
        )
    }

    static func networkError(config: SupabaseBackendConfig, message: String) -> SupabaseSignedAnnouncementsProbe {
        SupabaseSignedAnnouncementsProbe(
            title: "Signed announcements probe",
            status: "network",
            statusColorName: "red",
            method: "GET",
            path: "/announcements?class_id=in.<bridge>",
            url: "\(config.restBaseURL)/announcements",
            headerState: "\(config.clientKeyKind) apikey and user bearer prepared",
            detail: message,
            nextStep: "Keep local class feed active and retry after network/backend healthcheck",
            rowsPreview: "not requested",
            bridgePreview: AppSupabaseAnnouncementBridge.statusText,
            mappedAnnouncements: []
        )
    }
}

private struct SupabaseSignedHomeworkProbe: Hashable {
    var title: String
    var status: String
    var statusColorName: String
    var method: String
    var path: String
    var url: String
    var headerState: String
    var detail: String
    var nextStep: String
    var rowsPreview: String
    var bridgePreview: String
    var mappedHomework: [SupabaseHomeworkBridgeItem]

    static func planned(config: SupabaseBackendConfig) -> SupabaseSignedHomeworkProbe {
        if config.hasClientApiKey == false {
            return missingKey(config: config)
        }

        if config.hasAccessToken == false {
            return missingAccessToken(config: config)
        }

        if AppSupabaseClassContextBridge.contexts.isEmpty {
            return missingClassContext(config: config)
        }

        return SupabaseSignedHomeworkProbe(
            title: "Signed homework probe",
            status: "ready",
            statusColorName: "blue",
            method: "GET",
            path: "/homework_items?class_id=in.<bridge>&select=id,class_id,subject,title,details,due_at,assignee_child_id",
            url: "\(config.restBaseURL)/homework_items",
            headerState: "apikey \(config.clientKeyKind) ready, user bearer \(config.accessTokenPreview ?? "set")",
            detail: "Signed request will read class homework rows under RLS.",
            nextStep: "Run signed homework probe before replacing the local homework repository",
            rowsPreview: "not requested",
            bridgePreview: AppSupabaseHomeworkBridge.statusText,
            mappedHomework: []
        )
    }

    static func missingKey(config: SupabaseBackendConfig) -> SupabaseSignedHomeworkProbe {
        SupabaseSignedHomeworkProbe(
            title: "Signed homework probe",
            status: "blocked",
            statusColorName: "orange",
            method: "GET",
            path: "/homework_items?class_id=in.<bridge>",
            url: "\(config.restBaseURL)/homework_items",
            headerState: "missing SUPABASE_PUBLISHABLE_KEY or SUPABASE_ANON_KEY",
            detail: "Signed homework request is blocked before network access.",
            nextStep: "Add client apikey, signed session and class bridge",
            rowsPreview: "0 rows",
            bridgePreview: AppSupabaseHomeworkBridge.statusText,
            mappedHomework: []
        )
    }

    static func missingAccessToken(config: SupabaseBackendConfig) -> SupabaseSignedHomeworkProbe {
        SupabaseSignedHomeworkProbe(
            title: "Signed homework probe",
            status: "token missing",
            statusColorName: "orange",
            method: "GET",
            path: "/homework_items?class_id=in.<bridge>",
            url: "\(config.restBaseURL)/homework_items",
            headerState: "apikey \(config.clientKeyKind) ready, missing SUPABASE_ACCESS_TOKEN",
            detail: "Client key alone cannot prove class homework RLS.",
            nextStep: "Inject a seed user's Supabase access token before signed homework proof",
            rowsPreview: "not requested",
            bridgePreview: AppSupabaseHomeworkBridge.statusText,
            mappedHomework: []
        )
    }

    static func missingClassContext(config: SupabaseBackendConfig) -> SupabaseSignedHomeworkProbe {
        SupabaseSignedHomeworkProbe(
            title: "Signed homework probe",
            status: "class missing",
            statusColorName: "orange",
            method: "GET",
            path: "/homework_items?class_id=in.<bridge>",
            url: "\(config.restBaseURL)/homework_items",
            headerState: "apikey \(config.clientKeyKind) ready, user bearer \(config.accessTokenPreview ?? "set")",
            detail: "The app has no saved Supabase class bridge to scope homework rows.",
            nextStep: "Run signed class scope probe first, then retry homework",
            rowsPreview: "not requested",
            bridgePreview: AppSupabaseHomeworkBridge.statusText,
            mappedHomework: []
        )
    }

    static func success(config: SupabaseBackendConfig, rows: [SupabaseHomeworkRow], statusCode: Int) -> SupabaseSignedHomeworkProbe {
        let mappedAt = Date.now.formatted(date: .numeric, time: .shortened)
        let homework = rows.map { $0.bridgeItem(mappedAt: mappedAt) }
        let preview = homework.isEmpty ? "[]" : homework.map(\.summary).joined(separator: ", ")

        return SupabaseSignedHomeworkProbe(
            title: "Signed homework probe",
            status: homework.isEmpty ? "empty" : "mapped",
            statusColorName: homework.isEmpty ? "orange" : "green",
            method: "GET",
            path: "/homework_items?class_id=in.<bridge>&select=id,class_id,subject,title,details,due_at,assignee_child_id",
            url: "\(config.restBaseURL)/homework_items",
            headerState: "HTTP \(statusCode), user bearer accepted",
            detail: homework.isEmpty ? "RLS returned no homework for saved class context." : "Mapped \(homework.count) homework item(s) from signed RLS rows.",
            nextStep: homework.isEmpty ? "Seed class homework or verify RLS before homework switch" : "Keep bridge preview until the local homework repository can switch safely",
            rowsPreview: preview,
            bridgePreview: homework.isEmpty ? "Homework bridge waiting: local homework active" : "Homework bridge ready: \(homework.count) item(s), local homework still active",
            mappedHomework: homework
        )
    }

    static func serverError(config: SupabaseBackendConfig, statusCode: Int, message: String) -> SupabaseSignedHomeworkProbe {
        SupabaseSignedHomeworkProbe(
            title: "Signed homework probe",
            status: "HTTP \(statusCode)",
            statusColorName: statusCode == 401 || statusCode == 403 ? "orange" : "red",
            method: "GET",
            path: "/homework_items?class_id=in.<bridge>",
            url: "\(config.restBaseURL)/homework_items",
            headerState: statusCode == 401 || statusCode == 403 ? "auth/session required" : "\(config.clientKeyKind) apikey and user bearer sent",
            detail: message,
            nextStep: statusCode == 401 || statusCode == 403 ? "Refresh or reissue seed user session and retry" : "Check Data API exposure and homework_items RLS response",
            rowsPreview: "not decoded",
            bridgePreview: AppSupabaseHomeworkBridge.statusText,
            mappedHomework: []
        )
    }

    static func networkError(config: SupabaseBackendConfig, message: String) -> SupabaseSignedHomeworkProbe {
        SupabaseSignedHomeworkProbe(
            title: "Signed homework probe",
            status: "network",
            statusColorName: "red",
            method: "GET",
            path: "/homework_items?class_id=in.<bridge>",
            url: "\(config.restBaseURL)/homework_items",
            headerState: "\(config.clientKeyKind) apikey and user bearer prepared",
            detail: message,
            nextStep: "Keep local homework active and retry after network/backend healthcheck",
            rowsPreview: "not requested",
            bridgePreview: AppSupabaseHomeworkBridge.statusText,
            mappedHomework: []
        )
    }
}

private struct SupabaseSignedCalendarEventsProbe: Hashable {
    var title: String
    var status: String
    var statusColorName: String
    var method: String
    var path: String
    var url: String
    var headerState: String
    var detail: String
    var nextStep: String
    var rowsPreview: String
    var bridgePreview: String
    var mappedEvents: [SupabaseCalendarEventBridgeItem]

    static func planned(config: SupabaseBackendConfig) -> SupabaseSignedCalendarEventsProbe {
        if config.hasClientApiKey == false {
            return missingKey(config: config)
        }

        if config.hasAccessToken == false {
            return missingAccessToken(config: config)
        }

        if AppSupabaseClassContextBridge.contexts.isEmpty {
            return missingClassContext(config: config)
        }

        return SupabaseSignedCalendarEventsProbe(
            title: "Signed calendar probe",
            status: "ready",
            statusColorName: "blue",
            method: "GET",
            path: "/calendar_events?class_id=in.<bridge>&select=id,class_id,title,details,starts_at,linked_collection_id",
            url: "\(config.restBaseURL)/calendar_events",
            headerState: "apikey \(config.clientKeyKind) ready, user bearer \(config.accessTokenPreview ?? "set")",
            detail: "Signed request will read class calendar events under RLS.",
            nextStep: "Run signed calendar probe before replacing the local calendar repository",
            rowsPreview: "not requested",
            bridgePreview: AppSupabaseCalendarEventBridge.statusText,
            mappedEvents: []
        )
    }

    static func missingKey(config: SupabaseBackendConfig) -> SupabaseSignedCalendarEventsProbe {
        SupabaseSignedCalendarEventsProbe(
            title: "Signed calendar probe",
            status: "blocked",
            statusColorName: "orange",
            method: "GET",
            path: "/calendar_events?class_id=in.<bridge>",
            url: "\(config.restBaseURL)/calendar_events",
            headerState: "missing SUPABASE_PUBLISHABLE_KEY or SUPABASE_ANON_KEY",
            detail: "Signed calendar request is blocked before network access.",
            nextStep: "Add client apikey, signed session and class bridge",
            rowsPreview: "0 rows",
            bridgePreview: AppSupabaseCalendarEventBridge.statusText,
            mappedEvents: []
        )
    }

    static func missingAccessToken(config: SupabaseBackendConfig) -> SupabaseSignedCalendarEventsProbe {
        SupabaseSignedCalendarEventsProbe(
            title: "Signed calendar probe",
            status: "token missing",
            statusColorName: "orange",
            method: "GET",
            path: "/calendar_events?class_id=in.<bridge>",
            url: "\(config.restBaseURL)/calendar_events",
            headerState: "apikey \(config.clientKeyKind) ready, missing SUPABASE_ACCESS_TOKEN",
            detail: "Client key alone cannot prove class calendar RLS.",
            nextStep: "Inject a seed user's Supabase access token before signed calendar proof",
            rowsPreview: "not requested",
            bridgePreview: AppSupabaseCalendarEventBridge.statusText,
            mappedEvents: []
        )
    }

    static func missingClassContext(config: SupabaseBackendConfig) -> SupabaseSignedCalendarEventsProbe {
        SupabaseSignedCalendarEventsProbe(
            title: "Signed calendar probe",
            status: "class missing",
            statusColorName: "orange",
            method: "GET",
            path: "/calendar_events?class_id=in.<bridge>",
            url: "\(config.restBaseURL)/calendar_events",
            headerState: "apikey \(config.clientKeyKind) ready, user bearer \(config.accessTokenPreview ?? "set")",
            detail: "The app has no saved Supabase class bridge to scope calendar rows.",
            nextStep: "Run signed class scope probe first, then retry calendar events",
            rowsPreview: "not requested",
            bridgePreview: AppSupabaseCalendarEventBridge.statusText,
            mappedEvents: []
        )
    }

    static func success(config: SupabaseBackendConfig, rows: [SupabaseCalendarEventRow], statusCode: Int) -> SupabaseSignedCalendarEventsProbe {
        let mappedAt = Date.now.formatted(date: .numeric, time: .shortened)
        let events = rows.map { $0.bridgeItem(mappedAt: mappedAt) }
        let preview = events.isEmpty ? "[]" : events.map(\.summary).joined(separator: ", ")

        return SupabaseSignedCalendarEventsProbe(
            title: "Signed calendar probe",
            status: events.isEmpty ? "empty" : "mapped",
            statusColorName: events.isEmpty ? "orange" : "green",
            method: "GET",
            path: "/calendar_events?class_id=in.<bridge>&select=id,class_id,title,details,starts_at,linked_collection_id",
            url: "\(config.restBaseURL)/calendar_events",
            headerState: "HTTP \(statusCode), user bearer accepted",
            detail: events.isEmpty ? "RLS returned no calendar events for saved class context." : "Mapped \(events.count) calendar event(s) from signed RLS rows.",
            nextStep: events.isEmpty ? "Seed class calendar events or verify RLS before calendar switch" : "Keep bridge preview until the local calendar repository can switch safely",
            rowsPreview: preview,
            bridgePreview: events.isEmpty ? "Calendar bridge waiting: local calendar active" : "Calendar bridge ready: \(events.count) event(s), local calendar still active",
            mappedEvents: events
        )
    }

    static func serverError(config: SupabaseBackendConfig, statusCode: Int, message: String) -> SupabaseSignedCalendarEventsProbe {
        SupabaseSignedCalendarEventsProbe(
            title: "Signed calendar probe",
            status: "HTTP \(statusCode)",
            statusColorName: statusCode == 401 || statusCode == 403 ? "orange" : "red",
            method: "GET",
            path: "/calendar_events?class_id=in.<bridge>",
            url: "\(config.restBaseURL)/calendar_events",
            headerState: statusCode == 401 || statusCode == 403 ? "auth/session required" : "\(config.clientKeyKind) apikey and user bearer sent",
            detail: message,
            nextStep: statusCode == 401 || statusCode == 403 ? "Refresh or reissue seed user session and retry" : "Check Data API exposure and calendar_events RLS response",
            rowsPreview: "not decoded",
            bridgePreview: AppSupabaseCalendarEventBridge.statusText,
            mappedEvents: []
        )
    }

    static func networkError(config: SupabaseBackendConfig, message: String) -> SupabaseSignedCalendarEventsProbe {
        SupabaseSignedCalendarEventsProbe(
            title: "Signed calendar probe",
            status: "network",
            statusColorName: "red",
            method: "GET",
            path: "/calendar_events?class_id=in.<bridge>",
            url: "\(config.restBaseURL)/calendar_events",
            headerState: "\(config.clientKeyKind) apikey and user bearer prepared",
            detail: message,
            nextStep: "Keep local calendar active and retry after network/backend healthcheck",
            rowsPreview: "not requested",
            bridgePreview: AppSupabaseCalendarEventBridge.statusText,
            mappedEvents: []
        )
    }
}

private struct SupabaseSignedCollectionsProbe: Hashable {
    var title: String
    var status: String
    var statusColorName: String
    var method: String
    var path: String
    var url: String
    var headerState: String
    var detail: String
    var nextStep: String
    var rowsPreview: String
    var bridgePreview: String
    var mappedCollections: [SupabaseCollectionBridgeItem]

    static func planned(config: SupabaseBackendConfig) -> SupabaseSignedCollectionsProbe {
        if config.hasClientApiKey == false {
            return missingKey(config: config)
        }

        if config.hasAccessToken == false {
            return missingAccessToken(config: config)
        }

        if AppSupabaseClassContextBridge.contexts.isEmpty {
            return missingClassContext(config: config)
        }

        return SupabaseSignedCollectionsProbe(
            title: "Signed collections probe",
            status: "ready",
            statusColorName: "blue",
            method: "GET",
            path: "/collections?class_id=in.<bridge>&select=id,class_id,title,amount_per_family,total_count,paid_count,status,due_at",
            url: "\(config.restBaseURL)/collections",
            headerState: "apikey \(config.clientKeyKind) ready, user bearer \(config.accessTokenPreview ?? "set")",
            detail: "Signed request will read class collections under RLS.",
            nextStep: "Run signed collections probe before replacing the local collections repository",
            rowsPreview: "not requested",
            bridgePreview: AppSupabaseCollectionBridge.statusText,
            mappedCollections: []
        )
    }

    static func missingKey(config: SupabaseBackendConfig) -> SupabaseSignedCollectionsProbe {
        SupabaseSignedCollectionsProbe(
            title: "Signed collections probe",
            status: "blocked",
            statusColorName: "orange",
            method: "GET",
            path: "/collections?class_id=in.<bridge>",
            url: "\(config.restBaseURL)/collections",
            headerState: "missing SUPABASE_PUBLISHABLE_KEY or SUPABASE_ANON_KEY",
            detail: "Signed collections request is blocked before network access.",
            nextStep: "Add client apikey, signed session and class bridge",
            rowsPreview: "0 rows",
            bridgePreview: AppSupabaseCollectionBridge.statusText,
            mappedCollections: []
        )
    }

    static func missingAccessToken(config: SupabaseBackendConfig) -> SupabaseSignedCollectionsProbe {
        SupabaseSignedCollectionsProbe(
            title: "Signed collections probe",
            status: "token missing",
            statusColorName: "orange",
            method: "GET",
            path: "/collections?class_id=in.<bridge>",
            url: "\(config.restBaseURL)/collections",
            headerState: "apikey \(config.clientKeyKind) ready, missing SUPABASE_ACCESS_TOKEN",
            detail: "Client key alone cannot prove class collections RLS.",
            nextStep: "Inject a seed user's Supabase access token before signed collections proof",
            rowsPreview: "not requested",
            bridgePreview: AppSupabaseCollectionBridge.statusText,
            mappedCollections: []
        )
    }

    static func missingClassContext(config: SupabaseBackendConfig) -> SupabaseSignedCollectionsProbe {
        SupabaseSignedCollectionsProbe(
            title: "Signed collections probe",
            status: "class missing",
            statusColorName: "orange",
            method: "GET",
            path: "/collections?class_id=in.<bridge>",
            url: "\(config.restBaseURL)/collections",
            headerState: "apikey \(config.clientKeyKind) ready, user bearer \(config.accessTokenPreview ?? "set")",
            detail: "The app has no saved Supabase class bridge to scope collection rows.",
            nextStep: "Run signed class scope probe first, then retry collections",
            rowsPreview: "not requested",
            bridgePreview: AppSupabaseCollectionBridge.statusText,
            mappedCollections: []
        )
    }

    static func success(config: SupabaseBackendConfig, rows: [SupabaseCollectionRow], statusCode: Int) -> SupabaseSignedCollectionsProbe {
        let mappedAt = Date.now.formatted(date: .numeric, time: .shortened)
        let collections = rows.map { $0.bridgeItem(mappedAt: mappedAt) }
        let preview = collections.isEmpty ? "[]" : collections.map(\.summary).joined(separator: ", ")

        return SupabaseSignedCollectionsProbe(
            title: "Signed collections probe",
            status: collections.isEmpty ? "empty" : "mapped",
            statusColorName: collections.isEmpty ? "orange" : "green",
            method: "GET",
            path: "/collections?class_id=in.<bridge>&select=id,class_id,title,amount_per_family,total_count,paid_count,status,due_at",
            url: "\(config.restBaseURL)/collections",
            headerState: "HTTP \(statusCode), user bearer accepted",
            detail: collections.isEmpty ? "RLS returned no collections for saved class context." : "Mapped \(collections.count) collection(s) from signed RLS rows.",
            nextStep: collections.isEmpty ? "Seed class collections or verify RLS before collections switch" : "Keep bridge preview until the local collections repository can switch safely",
            rowsPreview: preview,
            bridgePreview: collections.isEmpty ? "Collection bridge waiting: local collections active" : "Collection bridge ready: \(collections.count) collection(s), local collections still active",
            mappedCollections: collections
        )
    }

    static func serverError(config: SupabaseBackendConfig, statusCode: Int, message: String) -> SupabaseSignedCollectionsProbe {
        SupabaseSignedCollectionsProbe(
            title: "Signed collections probe",
            status: "HTTP \(statusCode)",
            statusColorName: statusCode == 401 || statusCode == 403 ? "orange" : "red",
            method: "GET",
            path: "/collections?class_id=in.<bridge>",
            url: "\(config.restBaseURL)/collections",
            headerState: statusCode == 401 || statusCode == 403 ? "auth/session required" : "\(config.clientKeyKind) apikey and user bearer sent",
            detail: message,
            nextStep: statusCode == 401 || statusCode == 403 ? "Refresh or reissue seed user session and retry" : "Check Data API exposure and collections RLS response",
            rowsPreview: "not decoded",
            bridgePreview: AppSupabaseCollectionBridge.statusText,
            mappedCollections: []
        )
    }

    static func networkError(config: SupabaseBackendConfig, message: String) -> SupabaseSignedCollectionsProbe {
        SupabaseSignedCollectionsProbe(
            title: "Signed collections probe",
            status: "network",
            statusColorName: "red",
            method: "GET",
            path: "/collections?class_id=in.<bridge>",
            url: "\(config.restBaseURL)/collections",
            headerState: "\(config.clientKeyKind) apikey and user bearer prepared",
            detail: message,
            nextStep: "Keep local collections active and retry after network/backend healthcheck",
            rowsPreview: "not requested",
            bridgePreview: AppSupabaseCollectionBridge.statusText,
            mappedCollections: []
        )
    }
}

private struct SupabaseAnnouncementReadAckResult: Hashable {
    var title: String
    var status: String
    var statusColorName: String
    var method: String
    var path: String
    var url: String
    var headerState: String
    var detail: String
    var nextStep: String
    var targetPreview: String

    static func planned(config: SupabaseBackendConfig) -> SupabaseAnnouncementReadAckResult {
        if config.hasClientApiKey == false {
            return missingKey(config: config)
        }

        if config.hasAccessToken == false {
            return missingAccessToken(config: config)
        }

        if config.userID?.isEmpty != false {
            return missingUserID(config: config)
        }

        guard let announcement = AppSupabaseAnnouncementBridge.primaryAnnouncement else {
            return missingAnnouncement(config: config)
        }

        return SupabaseAnnouncementReadAckResult(
            title: "Announcement read ack",
            status: announcement.isReadByMe ? "already read" : "ready",
            statusColorName: announcement.isReadByMe ? "green" : "blue",
            method: "POST",
            path: "/announcement_reads",
            url: "\(config.restBaseURL)/announcement_reads",
            headerState: "apikey \(config.clientKeyKind) ready, user bearer \(config.accessTokenPreview ?? "set")",
            detail: announcement.isReadByMe ? "Saved bridge already marks this announcement as read by current user." : "Signed request will insert current-user read state under RLS.",
            nextStep: announcement.isReadByMe ? "Keep local bridge in sync with signed announcements probe" : "Send signed ack before wiring live announcement detail button",
            targetPreview: announcement.summary
        )
    }

    static func missingKey(config: SupabaseBackendConfig) -> SupabaseAnnouncementReadAckResult {
        SupabaseAnnouncementReadAckResult(
            title: "Announcement read ack",
            status: "blocked",
            statusColorName: "orange",
            method: "POST",
            path: "/announcement_reads",
            url: "\(config.restBaseURL)/announcement_reads",
            headerState: "missing SUPABASE_PUBLISHABLE_KEY or SUPABASE_ANON_KEY",
            detail: "Signed announcement read ack is blocked before network access.",
            nextStep: "Add client apikey, signed session and announcement bridge",
            targetPreview: AppSupabaseAnnouncementBridge.previewText
        )
    }

    static func missingAccessToken(config: SupabaseBackendConfig) -> SupabaseAnnouncementReadAckResult {
        SupabaseAnnouncementReadAckResult(
            title: "Announcement read ack",
            status: "token missing",
            statusColorName: "orange",
            method: "POST",
            path: "/announcement_reads",
            url: "\(config.restBaseURL)/announcement_reads",
            headerState: "apikey \(config.clientKeyKind) ready, missing SUPABASE_ACCESS_TOKEN",
            detail: "Client key alone cannot write read state for a user.",
            nextStep: "Inject a seed user's Supabase access token before read ack proof",
            targetPreview: AppSupabaseAnnouncementBridge.previewText
        )
    }

    static func missingUserID(config: SupabaseBackendConfig) -> SupabaseAnnouncementReadAckResult {
        SupabaseAnnouncementReadAckResult(
            title: "Announcement read ack",
            status: "user id missing",
            statusColorName: "orange",
            method: "POST",
            path: "/announcement_reads",
            url: "\(config.restBaseURL)/announcement_reads",
            headerState: "apikey \(config.clientKeyKind) ready, user bearer \(config.accessTokenPreview ?? "set")",
            detail: "Access token exists, but the ack body needs the signed user's id.",
            nextStep: "Provide SUPABASE_USER_ID for the seed user and retry read ack",
            targetPreview: AppSupabaseAnnouncementBridge.previewText
        )
    }

    static func missingAnnouncement(config: SupabaseBackendConfig) -> SupabaseAnnouncementReadAckResult {
        SupabaseAnnouncementReadAckResult(
            title: "Announcement read ack",
            status: "announcement missing",
            statusColorName: "orange",
            method: "POST",
            path: "/announcement_reads",
            url: "\(config.restBaseURL)/announcement_reads",
            headerState: "apikey \(config.clientKeyKind) ready, user bearer \(config.accessTokenPreview ?? "set")",
            detail: "No Supabase announcement bridge item is available to acknowledge.",
            nextStep: "Run signed announcements probe first, then retry read ack",
            targetPreview: AppSupabaseAnnouncementBridge.previewText
        )
    }

    static func success(config: SupabaseBackendConfig, announcement: SupabaseAnnouncementBridgeItem, statusCode: Int) -> SupabaseAnnouncementReadAckResult {
        SupabaseAnnouncementReadAckResult(
            title: "Announcement read ack",
            status: "saved",
            statusColorName: "green",
            method: "POST",
            path: "/announcement_reads",
            url: "\(config.restBaseURL)/announcement_reads",
            headerState: "HTTP \(statusCode), user bearer accepted",
            detail: "Server accepted read-state insert for the signed user.",
            nextStep: "Refresh signed announcements before replacing the local detail ack button",
            targetPreview: announcement.summary
        )
    }

    static func duplicate(config: SupabaseBackendConfig, announcement: SupabaseAnnouncementBridgeItem, statusCode: Int) -> SupabaseAnnouncementReadAckResult {
        SupabaseAnnouncementReadAckResult(
            title: "Announcement read ack",
            status: "already saved",
            statusColorName: "green",
            method: "POST",
            path: "/announcement_reads",
            url: "\(config.restBaseURL)/announcement_reads",
            headerState: "HTTP \(statusCode), duplicate read row treated as idempotent success",
            detail: "The read-state row already exists for this announcement and user.",
            nextStep: "Keep UI read state enabled; no retry needed",
            targetPreview: announcement.summary
        )
    }

    static func serverError(config: SupabaseBackendConfig, statusCode: Int, message: String) -> SupabaseAnnouncementReadAckResult {
        SupabaseAnnouncementReadAckResult(
            title: "Announcement read ack",
            status: "HTTP \(statusCode)",
            statusColorName: statusCode == 401 || statusCode == 403 ? "orange" : "red",
            method: "POST",
            path: "/announcement_reads",
            url: "\(config.restBaseURL)/announcement_reads",
            headerState: statusCode == 401 || statusCode == 403 ? "auth/session required" : "\(config.clientKeyKind) apikey and user bearer sent",
            detail: message,
            nextStep: statusCode == 401 || statusCode == 403 ? "Refresh or reissue seed user session and retry read ack" : "Check announcement_reads RLS and primary-key conflict handling",
            targetPreview: AppSupabaseAnnouncementBridge.previewText
        )
    }

    static func networkError(config: SupabaseBackendConfig, message: String) -> SupabaseAnnouncementReadAckResult {
        SupabaseAnnouncementReadAckResult(
            title: "Announcement read ack",
            status: "network",
            statusColorName: "red",
            method: "POST",
            path: "/announcement_reads",
            url: "\(config.restBaseURL)/announcement_reads",
            headerState: "\(config.clientKeyKind) apikey and user bearer prepared",
            detail: message,
            nextStep: "Keep local feed active and retry after network/backend healthcheck",
            targetPreview: AppSupabaseAnnouncementBridge.previewText
        )
    }
}

private struct SupabaseRlsSmokeProbe: Hashable {
    var title: String
    var status: String
    var statusColorName: String
    var seedUser: String
    var parentResult: String
    var teacherResult: String
    var anonResult: String
    var writeResult: String
    var nextStep: String

    static func make(config: SupabaseBackendConfig) -> SupabaseRlsSmokeProbe {
        SupabaseRlsSmokeProbe(
            title: "RLS smoke seed",
            status: "SQL proven",
            statusColorName: "green",
            seedUser: "parent 10000000-0000-4000-8000-000000000001",
            parentResult: "parent sees 1 class: QA-3B-2026",
            teacherResult: "teacher sees 2 classes: QA-3B-2026, QA-4A-2026",
            anonResult: "anon sees 0 classes",
            writeResult: "writes: parent blocked, teacher allowed",
            nextStep: config.hasAccessToken ? "Run live iOS request with this user token and map returned class rows" : "Issue a real Supabase Auth access token for the seed parent before iOS signed REST proof"
        )
    }
}

private struct SupabaseLiveProbeResult: Hashable {
    var title: String
    var status: String
    var statusColorName: String
    var method: String
    var path: String
    var url: String
    var headerState: String
    var detail: String
    var nextStep: String
    var rowsPreview: String

    static func planned(config: SupabaseBackendConfig) -> SupabaseLiveProbeResult {
        SupabaseLiveProbeResult(
            title: "Live REST probe",
            status: config.hasClientApiKey ? "ready to run" : "blocked",
            statusColorName: config.hasClientApiKey ? "blue" : "orange",
            method: "GET",
            path: "/class_rooms?select=id,title,invite_code&limit=3",
            url: "\(config.restBaseURL)/class_rooms",
            headerState: config.hasClientApiKey ? "apikey \(config.clientKeyKind) ready, bearer \(config.accessTokenPreview ?? (config.hasPublishableKey ? "user token missing" : config.anonKeyPreview ?? "set"))" : "missing SUPABASE_PUBLISHABLE_KEY",
            detail: config.hasAccessToken ? "URLSession request is prepared with user token; local class data still stays active until rows map cleanly." : "URLSession request is prepared with client apikey; no local class data is replaced until a signed user probe succeeds.",
            nextStep: config.hasClientApiKey ? (config.hasAccessToken ? "Run probe, verify RLS, then map class rows into repository" : "Run anon probe, then repeat with Supabase Auth session token") : "Add SUPABASE_PUBLISHABLE_KEY or SUPABASE_ANON_KEY through build config/test environment",
            rowsPreview: "not requested"
        )
    }

    static func missingKey(config: SupabaseBackendConfig) -> SupabaseLiveProbeResult {
        var result = planned(config: config)
        result.status = "blocked"
        result.statusColorName = "orange"
        result.headerState = "missing SUPABASE_PUBLISHABLE_KEY or SUPABASE_ANON_KEY"
        result.detail = "Live URLSession request is intentionally blocked before network access."
        result.rowsPreview = "0 rows"
        return result
    }

    static func success(config: SupabaseBackendConfig, rows: [SupabaseClassRoomRow], statusCode: Int) -> SupabaseLiveProbeResult {
        SupabaseLiveProbeResult(
            title: "Live REST probe",
            status: rows.isEmpty ? "reachable" : "rows",
            statusColorName: rows.isEmpty ? "blue" : "green",
            method: "GET",
            path: "/class_rooms?select=id,title,invite_code&limit=3",
            url: "\(config.restBaseURL)/class_rooms",
            headerState: config.hasAccessToken ? "HTTP \(statusCode), user bearer accepted" : "HTTP \(statusCode), \(config.clientKeyKind) apikey accepted",
            detail: rows.isEmpty ? "REST responded, but RLS/auth seed returned no visible classes yet." : "REST responded with visible class rows.",
            nextStep: rows.isEmpty ? "Seed signed test user, profile, class membership and retry with user session token" : (config.hasAccessToken ? "Map returned rows into local class repository" : "Repeat with user access token before trusting RLS"),
            rowsPreview: rows.isEmpty ? "[]" : rows.map { row in "\(row.title) (\(row.invite_code ?? "no code"))" }.joined(separator: ", ")
        )
    }

    static func serverError(config: SupabaseBackendConfig, statusCode: Int, message: String) -> SupabaseLiveProbeResult {
        SupabaseLiveProbeResult(
            title: "Live REST probe",
            status: "HTTP \(statusCode)",
            statusColorName: statusCode == 401 || statusCode == 403 ? "orange" : "red",
            method: "GET",
            path: "/class_rooms?select=id,title,invite_code&limit=3",
            url: "\(config.restBaseURL)/class_rooms",
            headerState: statusCode == 401 || statusCode == 403 ? "auth/session required" : "\(config.clientKeyKind) apikey sent",
            detail: message,
            nextStep: statusCode == 401 || statusCode == 403 ? "Connect Supabase Auth session before reading class data" : "Check Supabase REST/RLS response and migration state",
            rowsPreview: "not decoded"
        )
    }

    static func networkError(config: SupabaseBackendConfig, message: String) -> SupabaseLiveProbeResult {
        SupabaseLiveProbeResult(
            title: "Live REST probe",
            status: "network",
            statusColorName: "red",
            method: "GET",
            path: "/class_rooms?select=id,title,invite_code&limit=3",
            url: "\(config.restBaseURL)/class_rooms",
            headerState: "\(config.clientKeyKind) apikey prepared",
            detail: message,
            nextStep: "Keep local data active and retry after network/backend healthcheck",
            rowsPreview: "not requested"
        )
    }
}

struct SupabasePasswordAuthResult: Hashable {
    var status: String
    var message: String
    var session: SupabaseRefreshSessionResponse?

    var isSuccess: Bool {
        session?.access_token?.isEmpty == false
    }
}

struct SupabaseOnboardingHandoffResult: Hashable {
    var status: String
    var message: String
    var accountSummary: String?
    var profileCount: Int
    var classCount: Int
    var childCount: Int
    var selectedChildSummary: String?

    var hasLiveChildContext: Bool {
        childCount > 0
    }
}

struct SupabaseOnboardingHandoffClient {
    static func syncAfterAuth(config: SupabaseBackendConfig) async -> SupabaseOnboardingHandoffResult {
        guard config.hasAccessToken, config.userID?.isEmpty == false else {
            return SupabaseOnboardingHandoffResult(
                status: "session incomplete",
                message: "Сессия сохранена, но для загрузки класса нужны access token и user id.",
                accountSummary: nil,
                profileCount: 0,
                classCount: 0,
                childCount: 0,
                selectedChildSummary: nil
            )
        }

        async let profile = SupabaseSignedProfileClient.probeProfile(config: config)
        async let classScope = SupabaseSignedClassScopeClient.probeClassScope(config: config)
        async let children = SupabaseSignedChildrenClient.probeChildren(config: config)
        let (profileResult, classResult, childResult) = await (profile, classScope, children)

        if let mappedProfile = profileResult.mappedProfile {
            AppSupabaseAccountProfileBridge.save(mappedProfile)
        }

        if classResult.mappedContexts.isEmpty == false {
            AppSupabaseClassContextBridge.replace(
                with: classResult.mappedContexts.map { $0.bridgeItem(mappedAt: Date.now.formatted(date: .numeric, time: .shortened)) }
            )
        }

        if childResult.mappedChildren.isEmpty == false {
            AppSupabaseChildContextBridge.replace(
                with: childResult.mappedChildren.map { $0.bridgeItem(mappedAt: Date.now.formatted(date: .numeric, time: .shortened)) }
            )
            AppChildStore.usesSupabaseChildSourcePreview = true
            if let selectedChild = AppChildStore.effectiveChildren.first {
                AppChildStore.select(selectedChild)
            }
        }

        let selected = AppChildStore.usesSupabaseChildSourcePreview
            ? AppChildStore.effectiveChildren.first.map { "\($0.name), \($0.className) -> \($0.school)" }
            : nil
        let account = AppSupabaseAccountProfileBridge.profile?.summary
        let details = [
            profileResult.detail,
            classResult.detail,
            childResult.detail
        ].joined(separator: " ")
        let message = childResult.mappedChildren.isEmpty
            ? "Supabase Auth подключен, но live-дети пока не найдены. \(details)"
            : "Supabase Auth подключен, профиль: \(account ?? "не найден"), детей: \(childResult.mappedChildren.count), классов: \(classResult.mappedContexts.count)."

        return SupabaseOnboardingHandoffResult(
            status: childResult.mappedChildren.isEmpty ? "partial" : "ready",
            message: message,
            accountSummary: account,
            profileCount: profileResult.mappedProfile == nil ? 0 : 1,
            classCount: classResult.mappedContexts.count,
            childCount: childResult.mappedChildren.count,
            selectedChildSummary: selected
        )
    }
}

struct SupabaseAuthClient {
    static func signInWithPassword(email: String, password: String, config: SupabaseBackendConfig) async -> SupabasePasswordAuthResult {
        guard let apiKey = config.clientApiKey, apiKey.isEmpty == false else {
            return SupabasePasswordAuthResult(
                status: "key missing",
                message: "Нужен SUPABASE_PUBLISHABLE_KEY или SUPABASE_ANON_KEY в конфигурации приложения.",
                session: nil
            )
        }

        guard email.isEmpty == false, password.isEmpty == false else {
            return SupabasePasswordAuthResult(
                status: "credentials missing",
                message: "Введите email и пароль Supabase Auth.",
                session: nil
            )
        }

        guard let url = URL(string: "\(config.authBaseURL)/token?grant_type=password") else {
            return SupabasePasswordAuthResult(status: "invalid URL", message: "Некорректный Supabase Auth URL.", session: nil)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 10
        request.addValue(apiKey, forHTTPHeaderField: "apikey")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(SupabasePasswordSignInRequest(email: email, password: password))
            let (data, response) = try await URLSession.shared.data(for: request)
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            if (200..<300).contains(statusCode) {
                let decoded = try JSONDecoder().decode(SupabaseRefreshSessionResponse.self, from: data)
                return SupabasePasswordAuthResult(status: "HTTP \(statusCode)", message: "Supabase Auth принял email/password.", session: decoded)
            }

            let decodedError = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data)
            let message = decodedError?.message
                ?? String(data: data, encoding: .utf8)
                ?? "Supabase Auth вернул HTTP \(statusCode)."
            return SupabasePasswordAuthResult(status: "HTTP \(statusCode)", message: message, session: nil)
        } catch {
            return SupabasePasswordAuthResult(status: "network", message: error.localizedDescription, session: nil)
        }
    }

    fileprivate static func signInWithPassword(config: SupabaseBackendConfig) async -> SupabasePasswordSignInProbe {
        guard let apiKey = config.clientApiKey, apiKey.isEmpty == false else {
            return .missingKey(config: config)
        }

        guard let email = config.testEmail, email.isEmpty == false,
              let password = config.testPassword, password.isEmpty == false else {
            return .missingCredentials(config: config)
        }

        guard let url = URL(string: "\(config.authBaseURL)/token?grant_type=password") else {
            return .networkError(config: config, message: "Invalid Supabase Auth password URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 8
        request.addValue(apiKey, forHTTPHeaderField: "apikey")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(SupabasePasswordSignInRequest(email: email, password: password))
            let (data, response) = try await URLSession.shared.data(for: request)
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            if (200..<300).contains(statusCode) {
                let decoded = try JSONDecoder().decode(SupabaseRefreshSessionResponse.self, from: data)
                return .success(config: config, response: decoded, statusCode: statusCode)
            }

            let decodedError = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data)
            let message = decodedError?.message
                ?? String(data: data, encoding: .utf8)
                ?? "Supabase Auth returned HTTP \(statusCode)"
            return .serverError(config: config, statusCode: statusCode, message: message)
        } catch {
            return .networkError(config: config, message: error.localizedDescription)
        }
    }

    fileprivate static func refreshSession(config: SupabaseBackendConfig) async -> SupabaseSessionRefreshProbe {
        guard let apiKey = config.clientApiKey, apiKey.isEmpty == false else {
            return .missingKey(config: config)
        }

        guard let refreshToken = config.refreshToken, refreshToken.isEmpty == false else {
            return .missingRefreshToken(config: config)
        }

        guard let url = URL(string: "\(config.authBaseURL)/token?grant_type=refresh_token") else {
            return .networkError(config: config, message: "Invalid Supabase Auth token URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 8
        request.addValue(apiKey, forHTTPHeaderField: "apikey")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(SupabaseRefreshSessionRequest(refresh_token: refreshToken))
            let (data, response) = try await URLSession.shared.data(for: request)
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            if (200..<300).contains(statusCode) {
                let decoded = try JSONDecoder().decode(SupabaseRefreshSessionResponse.self, from: data)
                return .success(config: config, response: decoded, statusCode: statusCode)
            }

            let decodedError = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data)
            let message = decodedError?.message
                ?? String(data: data, encoding: .utf8)
                ?? "Supabase Auth returned HTTP \(statusCode)"
            return .serverError(config: config, statusCode: statusCode, message: message)
        } catch {
            return .networkError(config: config, message: error.localizedDescription)
        }
    }
}

private struct SupabaseSignedProfileClient {
    static func probeProfile(config: SupabaseBackendConfig) async -> SupabaseSignedProfileProbe {
        guard let apiKey = config.clientApiKey, apiKey.isEmpty == false else {
            return .missingKey(config: config)
        }

        guard let accessToken = config.accessToken, accessToken.isEmpty == false else {
            return .missingAccessToken(config: config)
        }

        guard let userID = config.userID, userID.isEmpty == false else {
            return .missingUserID(config: config)
        }

        guard var components = URLComponents(string: "\(config.restBaseURL)/profiles") else {
            return .networkError(config: config, message: "Invalid Supabase profiles URL")
        }

        components.queryItems = [
            URLQueryItem(name: "id", value: "eq.\(userID)"),
            URLQueryItem(name: "select", value: "id,display_name,phone")
        ]

        guard let url = components.url else {
            return .networkError(config: config, message: "Invalid Supabase profiles query")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 8
        request.addValue(apiKey, forHTTPHeaderField: "apikey")
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            if (200..<300).contains(statusCode) {
                let rows = try JSONDecoder().decode([SupabaseProfileRow].self, from: data)
                return .success(config: config, rows: rows, statusCode: statusCode)
            }

            let decodedError = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data)
            let message = decodedError?.message
                ?? String(data: data, encoding: .utf8)
                ?? "Supabase returned HTTP \(statusCode)"
            return .serverError(config: config, statusCode: statusCode, message: message)
        } catch {
            return .networkError(config: config, message: error.localizedDescription)
        }
    }
}

private struct SupabaseSignedClassScopeClient {
    static func probeClassScope(config: SupabaseBackendConfig) async -> SupabaseSignedClassScopeProbe {
        guard let apiKey = config.clientApiKey, apiKey.isEmpty == false else {
            return .missingKey(config: config)
        }

        guard let accessToken = config.accessToken, accessToken.isEmpty == false else {
            return .missingAccessToken(config: config)
        }

        guard let userID = config.userID, userID.isEmpty == false else {
            return .missingUserID(config: config)
        }

        guard var components = URLComponents(string: "\(config.restBaseURL)/class_members") else {
            return .networkError(config: config, message: "Invalid Supabase class_members URL")
        }

        components.queryItems = [
            URLQueryItem(name: "user_id", value: "eq.\(userID)"),
            URLQueryItem(name: "select", value: "id,class_id,role,status,class_rooms(id,title,invite_code)"),
            URLQueryItem(name: "order", value: "created_at.asc")
        ]

        guard let url = components.url else {
            return .networkError(config: config, message: "Invalid Supabase class_members query")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 8
        request.addValue(apiKey, forHTTPHeaderField: "apikey")
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            if (200..<300).contains(statusCode) {
                let rows = try JSONDecoder().decode([SupabaseClassMembershipRow].self, from: data)
                return .success(config: config, rows: rows, statusCode: statusCode)
            }

            let decodedError = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data)
            let message = decodedError?.message
                ?? String(data: data, encoding: .utf8)
                ?? "Supabase returned HTTP \(statusCode)"
            return .serverError(config: config, statusCode: statusCode, message: message)
        } catch {
            return .networkError(config: config, message: error.localizedDescription)
        }
    }
}

private struct SupabaseSignedChildrenClient {
    static func probeChildren(config: SupabaseBackendConfig) async -> SupabaseSignedChildrenProbe {
        guard let apiKey = config.clientApiKey, apiKey.isEmpty == false else {
            return .missingKey(config: config)
        }

        guard let accessToken = config.accessToken, accessToken.isEmpty == false else {
            return .missingAccessToken(config: config)
        }

        guard let userID = config.userID, userID.isEmpty == false else {
            return .missingUserID(config: config)
        }

        guard var components = URLComponents(string: "\(config.restBaseURL)/children") else {
            return .networkError(config: config, message: "Invalid Supabase children URL")
        }

        components.queryItems = [
            URLQueryItem(name: "parent_user_id", value: "eq.\(userID)"),
            URLQueryItem(name: "select", value: "id,class_id,display_name,grade_title,class_rooms(id,title,invite_code)"),
            URLQueryItem(name: "order", value: "created_at.asc")
        ]

        guard let url = components.url else {
            return .networkError(config: config, message: "Invalid Supabase children query")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 8
        request.addValue(apiKey, forHTTPHeaderField: "apikey")
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            if (200..<300).contains(statusCode) {
                let rows = try JSONDecoder().decode([SupabaseChildRow].self, from: data)
                return .success(config: config, rows: rows, statusCode: statusCode)
            }

            let decodedError = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data)
            let message = decodedError?.message
                ?? String(data: data, encoding: .utf8)
                ?? "Supabase returned HTTP \(statusCode)"
            return .serverError(config: config, statusCode: statusCode, message: message)
        } catch {
            return .networkError(config: config, message: error.localizedDescription)
        }
    }
}

private struct SupabaseSignedAnnouncementsClient {
    static func probeAnnouncements(config: SupabaseBackendConfig) async -> SupabaseSignedAnnouncementsProbe {
        guard let apiKey = config.clientApiKey, apiKey.isEmpty == false else {
            return .missingKey(config: config)
        }

        guard let accessToken = config.accessToken, accessToken.isEmpty == false else {
            return .missingAccessToken(config: config)
        }

        guard let userID = config.userID, userID.isEmpty == false else {
            return .missingUserID(config: config)
        }

        let classIDs = AppSupabaseClassContextBridge.contexts.map(\.classID)
        guard classIDs.isEmpty == false else {
            return .missingClassContext(config: config)
        }

        guard var components = URLComponents(string: "\(config.restBaseURL)/announcements") else {
            return .networkError(config: config, message: "Invalid Supabase announcements URL")
        }

        components.queryItems = [
            URLQueryItem(name: "class_id", value: "in.(\(classIDs.joined(separator: ",")))"),
            URLQueryItem(name: "select", value: "id,class_id,title,body,is_urgent,published_at,announcement_reads(user_id,read_at)"),
            URLQueryItem(name: "announcement_reads.user_id", value: "eq.\(userID)"),
            URLQueryItem(name: "order", value: "published_at.desc"),
            URLQueryItem(name: "limit", value: "20")
        ]

        guard let url = components.url else {
            return .networkError(config: config, message: "Invalid Supabase announcements query")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 8
        request.addValue(apiKey, forHTTPHeaderField: "apikey")
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            if (200..<300).contains(statusCode) {
                let rows = try JSONDecoder().decode([SupabaseAnnouncementRow].self, from: data)
                return .success(config: config, rows: rows, statusCode: statusCode)
            }

            let decodedError = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data)
            let message = decodedError?.message
                ?? String(data: data, encoding: .utf8)
                ?? "Supabase returned HTTP \(statusCode)"
            return .serverError(config: config, statusCode: statusCode, message: message)
        } catch {
            return .networkError(config: config, message: error.localizedDescription)
        }
    }
}

private struct SupabaseSignedHomeworkClient {
    static func probeHomework(config: SupabaseBackendConfig) async -> SupabaseSignedHomeworkProbe {
        guard let apiKey = config.clientApiKey, apiKey.isEmpty == false else {
            return .missingKey(config: config)
        }

        guard let accessToken = config.accessToken, accessToken.isEmpty == false else {
            return .missingAccessToken(config: config)
        }

        let classIDs = AppSupabaseClassContextBridge.contexts.map(\.classID)
        guard classIDs.isEmpty == false else {
            return .missingClassContext(config: config)
        }

        guard var components = URLComponents(string: "\(config.restBaseURL)/homework_items") else {
            return .networkError(config: config, message: "Invalid Supabase homework_items URL")
        }

        components.queryItems = [
            URLQueryItem(name: "class_id", value: "in.(\(classIDs.joined(separator: ",")))"),
            URLQueryItem(name: "select", value: "id,class_id,subject,title,details,due_at,assignee_child_id"),
            URLQueryItem(name: "order", value: "due_at.asc"),
            URLQueryItem(name: "limit", value: "20")
        ]

        guard let url = components.url else {
            return .networkError(config: config, message: "Invalid Supabase homework_items query")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 8
        request.addValue(apiKey, forHTTPHeaderField: "apikey")
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            if (200..<300).contains(statusCode) {
                let rows = try JSONDecoder().decode([SupabaseHomeworkRow].self, from: data)
                return .success(config: config, rows: rows, statusCode: statusCode)
            }

            let decodedError = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data)
            let message = decodedError?.message
                ?? String(data: data, encoding: .utf8)
                ?? "Supabase returned HTTP \(statusCode)"
            return .serverError(config: config, statusCode: statusCode, message: message)
        } catch {
            return .networkError(config: config, message: error.localizedDescription)
        }
    }
}

private struct SupabaseSignedCalendarEventsClient {
    static func probeCalendarEvents(config: SupabaseBackendConfig) async -> SupabaseSignedCalendarEventsProbe {
        guard let apiKey = config.clientApiKey, apiKey.isEmpty == false else {
            return .missingKey(config: config)
        }

        guard let accessToken = config.accessToken, accessToken.isEmpty == false else {
            return .missingAccessToken(config: config)
        }

        let classIDs = AppSupabaseClassContextBridge.contexts.map(\.classID)
        guard classIDs.isEmpty == false else {
            return .missingClassContext(config: config)
        }

        guard var components = URLComponents(string: "\(config.restBaseURL)/calendar_events") else {
            return .networkError(config: config, message: "Invalid Supabase calendar_events URL")
        }

        components.queryItems = [
            URLQueryItem(name: "class_id", value: "in.(\(classIDs.joined(separator: ",")))"),
            URLQueryItem(name: "select", value: "id,class_id,title,details,starts_at,linked_collection_id"),
            URLQueryItem(name: "order", value: "starts_at.asc"),
            URLQueryItem(name: "limit", value: "20")
        ]

        guard let url = components.url else {
            return .networkError(config: config, message: "Invalid Supabase calendar_events query")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 8
        request.addValue(apiKey, forHTTPHeaderField: "apikey")
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            if (200..<300).contains(statusCode) {
                let rows = try JSONDecoder().decode([SupabaseCalendarEventRow].self, from: data)
                return .success(config: config, rows: rows, statusCode: statusCode)
            }

            let decodedError = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data)
            let message = decodedError?.message
                ?? String(data: data, encoding: .utf8)
                ?? "Supabase returned HTTP \(statusCode)"
            return .serverError(config: config, statusCode: statusCode, message: message)
        } catch {
            return .networkError(config: config, message: error.localizedDescription)
        }
    }
}

private struct SupabaseSignedCollectionsClient {
    static func probeCollections(config: SupabaseBackendConfig) async -> SupabaseSignedCollectionsProbe {
        guard let apiKey = config.clientApiKey, apiKey.isEmpty == false else {
            return .missingKey(config: config)
        }

        guard let accessToken = config.accessToken, accessToken.isEmpty == false else {
            return .missingAccessToken(config: config)
        }

        let classIDs = AppSupabaseClassContextBridge.contexts.map(\.classID)
        guard classIDs.isEmpty == false else {
            return .missingClassContext(config: config)
        }

        guard var components = URLComponents(string: "\(config.restBaseURL)/collections") else {
            return .networkError(config: config, message: "Invalid Supabase collections URL")
        }

        components.queryItems = [
            URLQueryItem(name: "class_id", value: "in.(\(classIDs.joined(separator: ",")))"),
            URLQueryItem(name: "select", value: "id,class_id,title,amount_per_family,total_count,paid_count,status,due_at"),
            URLQueryItem(name: "order", value: "due_at.asc"),
            URLQueryItem(name: "limit", value: "20")
        ]

        guard let url = components.url else {
            return .networkError(config: config, message: "Invalid Supabase collections query")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 8
        request.addValue(apiKey, forHTTPHeaderField: "apikey")
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            if (200..<300).contains(statusCode) {
                let rows = try JSONDecoder().decode([SupabaseCollectionRow].self, from: data)
                return .success(config: config, rows: rows, statusCode: statusCode)
            }

            let decodedError = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data)
            let message = decodedError?.message
                ?? String(data: data, encoding: .utf8)
                ?? "Supabase returned HTTP \(statusCode)"
            return .serverError(config: config, statusCode: statusCode, message: message)
        } catch {
            return .networkError(config: config, message: error.localizedDescription)
        }
    }
}

private struct SupabaseAnnouncementReadAckClient {
    private struct ReadAckBody: Encodable {
        var announcement_id: String
        var user_id: String
    }

    static func acknowledgePrimaryAnnouncement(config: SupabaseBackendConfig) async -> SupabaseAnnouncementReadAckResult {
        guard let apiKey = config.clientApiKey, apiKey.isEmpty == false else {
            return .missingKey(config: config)
        }

        guard let accessToken = config.accessToken, accessToken.isEmpty == false else {
            return .missingAccessToken(config: config)
        }

        guard let userID = config.userID, userID.isEmpty == false else {
            return .missingUserID(config: config)
        }

        guard let announcement = AppSupabaseAnnouncementBridge.primaryAnnouncement else {
            return .missingAnnouncement(config: config)
        }

        guard let url = URL(string: "\(config.restBaseURL)/announcement_reads") else {
            return .networkError(config: config, message: "Invalid Supabase announcement_reads URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 8
        request.addValue(apiKey, forHTTPHeaderField: "apikey")
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("return=minimal", forHTTPHeaderField: "Prefer")
        request.httpBody = try? JSONEncoder().encode(
            ReadAckBody(
                announcement_id: announcement.id,
                user_id: userID
            )
        )

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            if (200..<300).contains(statusCode) {
                return .success(config: config, announcement: announcement, statusCode: statusCode)
            }

            let decodedError = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data)
            let message = decodedError?.message
                ?? String(data: data, encoding: .utf8)
                ?? "Supabase returned HTTP \(statusCode)"

            if statusCode == 409 || message.localizedCaseInsensitiveContains("duplicate key") {
                return .duplicate(config: config, announcement: announcement, statusCode: statusCode)
            }

            return .serverError(config: config, statusCode: statusCode, message: message)
        } catch {
            return .networkError(config: config, message: error.localizedDescription)
        }
    }
}

private struct SupabaseLiveClient {
    static func probeClassRooms(config: SupabaseBackendConfig) async -> SupabaseLiveProbeResult {
        guard let apiKey = config.clientApiKey, apiKey.isEmpty == false else {
            return .missingKey(config: config)
        }

        guard var components = URLComponents(string: "\(config.restBaseURL)/class_rooms") else {
            return .networkError(config: config, message: "Invalid Supabase REST URL")
        }

        components.queryItems = [
            URLQueryItem(name: "select", value: "id,title,invite_code"),
            URLQueryItem(name: "limit", value: "3")
        ]

        guard let url = components.url else {
            return .networkError(config: config, message: "Invalid Supabase class_rooms query")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 8
        request.addValue(apiKey, forHTTPHeaderField: "apikey")
        if let accessToken = config.accessToken, accessToken.isEmpty == false {
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        } else if config.hasAnonKey && !config.hasPublishableKey, let anonKey = config.anonKey {
            request.addValue("Bearer \(anonKey)", forHTTPHeaderField: "Authorization")
        }
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            if (200..<300).contains(statusCode) {
                let rows = try JSONDecoder().decode([SupabaseClassRoomRow].self, from: data)
                return .success(config: config, rows: rows, statusCode: statusCode)
            }

            let decodedError = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data)
            let message = decodedError?.message
                ?? String(data: data, encoding: .utf8)
                ?? "Supabase returned HTTP \(statusCode)"
            return .serverError(config: config, statusCode: statusCode, message: message)
        } catch {
            return .networkError(config: config, message: error.localizedDescription)
        }
    }
}

private struct SchoolSyncClient {
    static func dryRun(environment: BackendEnvironment, requestID: String, authContext: SyncAuthContext, storagePreflight: SyncStoragePreflight, mutations: [SyncMutationPreview]) -> SyncClientProbeResult {
        guard let url = URL(string: "\(environment.baseURL)/sync/mutations") else {
            return SyncClientProbeResult.failed(environment: environment, requestID: requestID, reason: "Invalid environment URL")
        }

        let request = MutationBatchRequest(
            clientId: "ios-local",
            environment: environment.rawValue,
            actorUserId: authContext.userID,
            roleClaim: authContext.roleClaim,
            storagePreflight: StoragePreflightRequest(
                privateBucket: storagePreflight.bucket,
                pendingUploads: storagePreflight.pendingUploads,
                requiredBeforeMutationIds: storagePreflight.requiredBeforeMutationIDs,
                uploadIntents: storagePreflight.uploadIntents.map { intent in
                    UploadIntentRequest(
                        uploadId: intent.uploadID,
                        mutationId: intent.mutationID,
                        endpoint: intent.endpoint,
                        kind: intent.kind,
                        fileName: intent.fileName,
                        mimeType: intent.mimeType,
                        sizeBytes: intent.sizeBytes,
                        checksumSha256: intent.checksumPreview
                    )
                },
                signedResponses: storagePreflight.signedResponses.map { response in
                    SignedUploadResponsePreviewRequest(
                        fileId: response.fileID,
                        method: response.method,
                        uploadUrl: response.uploadURL,
                        expiresAt: response.expiresAt,
                        requiredHeader: response.requiredHeader,
                        privateBucket: response.privateBucket,
                        storageKey: response.storageKey,
                        visibility: response.visibility
                    )
                },
                scanGates: storagePreflight.scanGates.map { gate in
                    FileScanGateRequest(
                        scanId: gate.scanID,
                        fileId: gate.fileID,
                        status: gate.status,
                        queue: gate.queue,
                        moderationRule: gate.moderationRule,
                        metadataGate: gate.metadataGate
                    )
                },
                metadataReleases: storagePreflight.metadataReleases.map { release in
                    MetadataReleaseRequest(
                        mutationId: release.mutationID,
                        fileId: release.fileID,
                        releaseStatus: release.releaseStatus,
                        payloadPatch: release.payloadPatch,
                        unlockRule: release.unlockRule
                    )
                },
                policy: storagePreflight.privacyRule
            ),
            mutations: mutations.map { mutation in
                MutationRequestItem(
                    mutationId: mutation.mutationID,
                    entityType: mutation.entity,
                    endpoint: mutation.endpoint,
                    operation: mutation.operation,
                    baseVersion: mutation.baseVersion,
                    payloadPreview: mutation.payloadPreview
                )
            }
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]

        do {
            let requestData = try encoder.encode(request)
            let responseData = try encoder.encode(mockResponse(requestID: requestID, mutations: mutations))
            let decodedResponse = try JSONDecoder().decode(MutationBatchResponse.self, from: responseData)
            let preview = SyncRequestPreview(
                method: "POST",
                path: "/sync/mutations",
                url: url.absoluteString,
                authState: "\(authContext.bearerPreview), \(authContext.sessionState)",
                idempotencyKey: requestID,
                bodyPreview: compactPreview(from: requestData)
            )

            return SyncClientProbeResult(
                transportState: "URLSession request ready",
                requestEncodingState: "\(requestData.count) bytes JSON",
                responseDecodingState: "Decoded \(decodedResponse.results.count) mutation result(s)",
                requestPreview: preview,
                acceptedCount: decodedResponse.results.filter { $0.status == "accepted" }.count,
                queuedCount: decodedResponse.results.filter { $0.status == "queued" }.count,
                blockedCount: decodedResponse.results.filter { $0.status == "blocked" }.count,
                serverVersionPlan: decodedResponse.results.contains { $0.entityVersion != nil } ? "Persist entityVersion before clearing accepted mutations" : "No server versions in dry-run response",
                retryPlan: decodedResponse.results.contains { $0.status == "queued" } ? "Keep queued mutations with retryAfterSeconds/backoff" : "No retry needed after this response",
                failureMapping: decodedResponse.results.contains { $0.status == "blocked" } ? "Stop automatic send for blocked mutations until user/backend resolves reason" : "Network failures still map to offline queue"
            )
        } catch {
            return SyncClientProbeResult.failed(environment: environment, requestID: requestID, reason: error.localizedDescription)
        }
    }

    private static func mockResponse(requestID: String, mutations: [SyncMutationPreview]) -> MutationBatchResponse {
        MutationBatchResponse(
            requestId: requestID,
            results: mutations.map { mutation in
                switch mutation.status {
                case "accepted":
                    return MutationResultItem(
                        mutationId: mutation.mutationID,
                        status: "accepted",
                        entityVersion: mutation.baseVersion + 1,
                        retryAfterSeconds: nil,
                        blockedReason: nil
                    )
                case "blocked":
                    return MutationResultItem(
                        mutationId: mutation.mutationID,
                        status: "blocked",
                        entityVersion: nil,
                        retryAfterSeconds: nil,
                        blockedReason: mutation.endpoint.contains("photos") || mutation.endpoint.contains("receipts") ? "storage_required" : "conflict_or_auth_required"
                    )
                default:
                    return MutationResultItem(
                        mutationId: mutation.mutationID,
                        status: "queued",
                        entityVersion: nil,
                        retryAfterSeconds: 60,
                        blockedReason: nil
                    )
                }
            }
        )
    }

    private static func compactPreview(from data: Data) -> String {
        guard let text = String(data: data, encoding: .utf8) else {
            return "{}"
        }

        if text.count <= 190 {
            return text
        }

        return String(text.prefix(190)) + "...}"
    }
}

private struct MutationBatchRequest: Codable, Hashable {
    var clientId: String
    var environment: String
    var actorUserId: String
    var roleClaim: String
    var storagePreflight: StoragePreflightRequest
    var mutations: [MutationRequestItem]
}

private struct StoragePreflightRequest: Codable, Hashable {
    var privateBucket: String
    var pendingUploads: Int
    var requiredBeforeMutationIds: [String]
    var uploadIntents: [UploadIntentRequest]
    var signedResponses: [SignedUploadResponsePreviewRequest]
    var scanGates: [FileScanGateRequest]
    var metadataReleases: [MetadataReleaseRequest]
    var policy: String
}

private struct UploadIntentRequest: Codable, Hashable {
    var uploadId: String
    var mutationId: String
    var endpoint: String
    var kind: String
    var fileName: String
    var mimeType: String
    var sizeBytes: Int
    var checksumSha256: String
}

private struct SignedUploadResponsePreviewRequest: Codable, Hashable {
    var fileId: String
    var method: String
    var uploadUrl: String
    var expiresAt: String
    var requiredHeader: String
    var privateBucket: String
    var storageKey: String
    var visibility: String
}

private struct FileScanGateRequest: Codable, Hashable {
    var scanId: String
    var fileId: String
    var status: String
    var queue: String
    var moderationRule: String
    var metadataGate: String
}

private struct MetadataReleaseRequest: Codable, Hashable {
    var mutationId: String
    var fileId: String
    var releaseStatus: String
    var payloadPatch: String
    var unlockRule: String
}

private struct MutationRequestItem: Codable, Hashable {
    var mutationId: String
    var entityType: String
    var endpoint: String
    var operation: String
    var baseVersion: Int
    var payloadPreview: String
}

private struct MutationBatchResponse: Codable, Hashable {
    var requestId: String
    var results: [MutationResultItem]
}

private struct MutationResultItem: Codable, Hashable {
    var mutationId: String
    var status: String
    var entityVersion: Int?
    var retryAfterSeconds: Int?
    var blockedReason: String?
}

private struct SyncClientProbeResult: Hashable {
    var transportState: String
    var requestEncodingState: String
    var responseDecodingState: String
    var requestPreview: SyncRequestPreview
    var acceptedCount: Int
    var queuedCount: Int
    var blockedCount: Int
    var serverVersionPlan: String
    var retryPlan: String
    var failureMapping: String

    static func failed(environment: BackendEnvironment, requestID: String, reason: String) -> SyncClientProbeResult {
        SyncClientProbeResult(
            transportState: "Client probe failed",
            requestEncodingState: reason,
            responseDecodingState: "No decoded response",
            requestPreview: SyncRequestPreview.make(environment: environment, requestID: requestID, mutations: []),
            acceptedCount: 0,
            queuedCount: 0,
            blockedCount: 1,
            serverVersionPlan: "Keep local mutations until client probe is fixed",
            retryPlan: "Do not send malformed request",
            failureMapping: "Map client encoding/decoding failures to QA blocker"
        )
    }
}

private struct SyncClientPreview: Hashable {
    var transport: String
    var resultType: String
    var requestState: String
    var responseState: String
    var retryPlan: String
    var serverVersionPlan: String
    var failureMapping: String

    static func make(environment: BackendEnvironment, probe: SyncClientProbeResult) -> SyncClientPreview {
        return SyncClientPreview(
            transport: "URLSession + JSONDecoder, \(environment.title)",
            resultType: "SyncClientResult: accepted / queued / blocked",
            requestState: probe.requestEncodingState,
            responseState: probe.responseDecodingState,
            retryPlan: probe.retryPlan,
            serverVersionPlan: probe.serverVersionPlan,
            failureMapping: probe.failureMapping
        )
    }
}

private struct ApiReadinessItem: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var artifact: String
    var status: String
    var detail: String
    var iconName: String
    var colorName: String

    static let sample = [
        ApiReadinessItem(
            title: "OpenAPI MVP",
            artifact: "docs/openapi_mvp.yaml",
            status: "Готово",
            detail: "Описаны batch-мутации, signed upload URL и первые endpoint-ы класса, ДЗ, объявлений, чеков, приглашений и фото.",
            iconName: "doc.text.fill",
            colorName: "green"
        ),
        ApiReadinessItem(
            title: "Mutation dry-run",
            artifact: "iOS Sync Center",
            status: "Готово",
            detail: "Приложение уже собирает mutationId, operation, baseVersion, payloadPreview и статус отправки.",
            iconName: "play.rectangle.fill",
            colorName: "green"
        ),
        ApiReadinessItem(
            title: "Swift API client",
            artifact: "URLSession + Codable dry-run",
            status: "Частично",
            detail: "Есть типизированный batch request/response, mapping accepted/queued/blocked и план сохранения server version; настоящая сеть, auth и refresh token еще впереди.",
            iconName: "curlybraces.square.fill",
            colorName: "orange"
        ),
        ApiReadinessItem(
            title: "Network readiness",
            artifact: "GET /health + retry policy",
            status: "Частично",
            detail: "Dry-run фиксирует live-mode gate: healthcheck, timeout, retry/backoff, auth refresh и запрет локального обхода 403 до TestFlight.",
            iconName: "network",
            colorName: "orange"
        ),
        ApiReadinessItem(
            title: "Auth + server roles",
            artifact: "Auth context + Backend policy",
            status: "Частично",
            detail: "iOS dry-run передает user id, role claim и refresh-план; сервер все равно должен проверять роль в конкретном классе для каждого действия.",
            iconName: "lock.shield.fill",
            colorName: "orange"
        ),
        ApiReadinessItem(
            title: "File storage",
            artifact: "Signed upload contract + preflight",
            status: "Блокер",
            detail: "iOS уже готовит preflight, а OpenAPI описывает signed upload URL; реальная выдача URL, private bucket и malware/moderation scan остаются backend-блокером.",
            iconName: "externaldrive.badge.icloud.fill",
            colorName: "red"
        )
    ]
}

private struct BackendPermissionRule: Identifiable, Hashable {
    enum Decision: String {
        case allow = "Разрешить"
        case deny = "Запретить"
        case ownOnly = "Только свое"

        var color: Color {
            switch self {
            case .allow:
                SchoolTheme.success
            case .deny:
                SchoolTheme.danger
            case .ownOnly:
                SchoolTheme.warning
            }
        }
    }

    let id = UUID()
    var action: String
    var endpoint: SyncEndpointKind
    var parent: Decision
    var committee: Decision
    var teacher: Decision
    var child: Decision
    var auditReason: String

    static let sample = [
        BackendPermissionRule(
            action: "Создать объявление",
            endpoint: .announcementRead,
            parent: .deny,
            committee: .allow,
            teacher: .allow,
            child: .deny,
            auditReason: "Публикации класса должны иметь автора с ролью учитель или родкомитет"
        ),
        BackendPermissionRule(
            action: "Изменить статус сбора",
            endpoint: .receipt,
            parent: .deny,
            committee: .allow,
            teacher: .deny,
            child: .deny,
            auditReason: "Финансовые статусы меняет только родкомитет, сервер повторно проверяет роль"
        ),
        BackendPermissionRule(
            action: "Отметить оплату семьи",
            endpoint: .receipt,
            parent: .ownOnly,
            committee: .allow,
            teacher: .deny,
            child: .deny,
            auditReason: "Родитель может менять только запись своей семьи"
        ),
        BackendPermissionRule(
            action: "Удалить фото альбома",
            endpoint: .photo,
            parent: .deny,
            committee: .allow,
            teacher: .allow,
            child: .deny,
            auditReason: "Удаление фото доступно модераторам класса и фиксируется в AuditLog"
        ),
        BackendPermissionRule(
            action: "Пригласить участника",
            endpoint: .familyInvite,
            parent: .deny,
            committee: .allow,
            teacher: .allow,
            child: .deny,
            auditReason: "Инвайт создает токен доступа к закрытому классу"
        )
    ]
}

private struct MoreStoreSnapshot: Codable {
    var profile: ParentProfileState
    var children: [ChildSummary]
    var familyMembers: [FamilyAccessMember]
    var familyTasks: [FamilyTaskSummary]
    var classAccess: [ClassAccessSummary]
    var notificationPreferences: [NotificationPreference]
    var notificationSettings: NotificationSettingsState
    var subscriptionPlans: [SubscriptionPlanSummary]
    var classMemory: [ClassMemoryEntry]
    var classFiles: [ClassFileSummary]
    var securitySettings: SecuritySettingsState
    var auditEntries: [AuditLogEntry]
    var privacySettings: PrivacySettingsState
    var analyticsEvents: [AnalyticsEventSummary]
    var mvpMetrics: [MvpMetricSummary]
    var aiQualityLogs: [AIQualityLogEntry]
    var qaScenarios: [QaStateScenario]
    var syncOperations: [SyncOperationSummary]

    init(
        profile: ParentProfileState = .sample,
        children: [ChildSummary],
        familyMembers: [FamilyAccessMember],
        familyTasks: [FamilyTaskSummary] = FamilyTaskSummary.sample,
        classAccess: [ClassAccessSummary],
        notificationPreferences: [NotificationPreference],
        notificationSettings: NotificationSettingsState = .sample,
        subscriptionPlans: [SubscriptionPlanSummary],
        classMemory: [ClassMemoryEntry],
        classFiles: [ClassFileSummary],
        securitySettings: SecuritySettingsState = .sample,
        auditEntries: [AuditLogEntry] = AuditLogEntry.sample,
        privacySettings: PrivacySettingsState = .sample,
        analyticsEvents: [AnalyticsEventSummary] = AnalyticsEventSummary.sample,
        mvpMetrics: [MvpMetricSummary] = MvpMetricSummary.sample,
        aiQualityLogs: [AIQualityLogEntry] = AIQualityLogEntry.sample,
        qaScenarios: [QaStateScenario] = QaStateScenario.sample,
        syncOperations: [SyncOperationSummary] = SyncOperationSummary.sample
    ) {
        self.profile = profile
        self.children = children
        self.familyMembers = familyMembers
        self.familyTasks = familyTasks
        self.classAccess = classAccess
        self.notificationPreferences = notificationPreferences
        self.notificationSettings = notificationSettings
        self.subscriptionPlans = subscriptionPlans
        self.classMemory = classMemory
        self.classFiles = classFiles
        self.securitySettings = securitySettings
        self.auditEntries = auditEntries
        self.privacySettings = privacySettings
        self.analyticsEvents = analyticsEvents
        self.mvpMetrics = mvpMetrics
        self.aiQualityLogs = aiQualityLogs
        self.qaScenarios = qaScenarios
        self.syncOperations = syncOperations
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        profile = try container.decodeIfPresent(ParentProfileState.self, forKey: .profile) ?? .sample
        children = try container.decode([ChildSummary].self, forKey: .children)
        familyMembers = try container.decode([FamilyAccessMember].self, forKey: .familyMembers)
        familyTasks = try container.decodeIfPresent([FamilyTaskSummary].self, forKey: .familyTasks) ?? FamilyTaskSummary.sample
        classAccess = try container.decode([ClassAccessSummary].self, forKey: .classAccess)
        notificationPreferences = try container.decode([NotificationPreference].self, forKey: .notificationPreferences)
        notificationSettings = try container.decodeIfPresent(NotificationSettingsState.self, forKey: .notificationSettings) ?? .sample
        subscriptionPlans = try container.decode([SubscriptionPlanSummary].self, forKey: .subscriptionPlans)
        classMemory = try container.decodeIfPresent([ClassMemoryEntry].self, forKey: .classMemory) ?? SampleData.classMemory
        classFiles = try container.decodeIfPresent([ClassFileSummary].self, forKey: .classFiles) ?? SampleData.classFiles
        securitySettings = try container.decodeIfPresent(SecuritySettingsState.self, forKey: .securitySettings) ?? .sample
        auditEntries = try container.decodeIfPresent([AuditLogEntry].self, forKey: .auditEntries) ?? AuditLogEntry.sample
        privacySettings = try container.decodeIfPresent(PrivacySettingsState.self, forKey: .privacySettings) ?? .sample
        analyticsEvents = try container.decodeIfPresent([AnalyticsEventSummary].self, forKey: .analyticsEvents) ?? AnalyticsEventSummary.sample
        mvpMetrics = try container.decodeIfPresent([MvpMetricSummary].self, forKey: .mvpMetrics) ?? MvpMetricSummary.sample
        aiQualityLogs = try container.decodeIfPresent([AIQualityLogEntry].self, forKey: .aiQualityLogs) ?? AIQualityLogEntry.sample
        qaScenarios = try container.decodeIfPresent([QaStateScenario].self, forKey: .qaScenarios) ?? QaStateScenario.sample
        syncOperations = try container.decodeIfPresent([SyncOperationSummary].self, forKey: .syncOperations) ?? SyncOperationSummary.sample
    }

    static let sample = MoreStoreSnapshot(
        profile: .sample,
        children: SampleData.children,
        familyMembers: SampleData.familyMembers,
        familyTasks: FamilyTaskSummary.sample,
        classAccess: SampleData.classAccess,
        notificationPreferences: SampleData.notificationPreferences,
        notificationSettings: .sample,
        subscriptionPlans: SampleData.subscriptionPlans,
        classMemory: SampleData.classMemory,
        classFiles: SampleData.classFiles,
        securitySettings: .sample,
        auditEntries: AuditLogEntry.sample,
        privacySettings: .sample,
        analyticsEvents: AnalyticsEventSummary.sample,
        mvpMetrics: MvpMetricSummary.sample,
        aiQualityLogs: AIQualityLogEntry.sample,
        qaScenarios: QaStateScenario.sample,
        syncOperations: SyncOperationSummary.sample
    )
}

private enum MoreLocalStore {
    private static let defaultsKey = "school.more.store.v1"
    private static var snapshot: MoreStoreSnapshot = load()

    static var profile: ParentProfileState {
        get { snapshot.profile }
        set {
            snapshot.profile = newValue
            save()
        }
    }

    static var children: [ChildSummary] {
        get { snapshot.children }
        set {
            snapshot.children = newValue
            AppChildStore.children = newValue
            save()
        }
    }

    static var familyMembers: [FamilyAccessMember] {
        get { snapshot.familyMembers }
        set {
            snapshot.familyMembers = newValue
            save()
        }
    }

    static var familyTasks: [FamilyTaskSummary] {
        get { snapshot.familyTasks }
        set {
            snapshot.familyTasks = newValue
            save()
        }
    }

    static var classAccess: [ClassAccessSummary] {
        get { snapshot.classAccess }
        set {
            snapshot.classAccess = newValue
            save()
        }
    }

    static var notificationPreferences: [NotificationPreference] {
        get { snapshot.notificationPreferences }
        set {
            snapshot.notificationPreferences = newValue
            save()
        }
    }

    static var notificationSettings: NotificationSettingsState {
        get { snapshot.notificationSettings }
        set {
            snapshot.notificationSettings = newValue
            save()
        }
    }

    static var subscriptionPlans: [SubscriptionPlanSummary] {
        get { snapshot.subscriptionPlans }
        set {
            snapshot.subscriptionPlans = newValue
            save()
        }
    }

    static var classMemory: [ClassMemoryEntry] {
        get { snapshot.classMemory }
        set {
            snapshot.classMemory = newValue
            save()
        }
    }

    static var classFiles: [ClassFileSummary] {
        get { snapshot.classFiles }
        set {
            snapshot.classFiles = newValue
            save()
        }
    }

    static var securitySettings: SecuritySettingsState {
        get { snapshot.securitySettings }
        set {
            snapshot.securitySettings = newValue
            save()
        }
    }

    static var auditEntries: [AuditLogEntry] {
        get { snapshot.auditEntries }
        set {
            snapshot.auditEntries = newValue
            save()
        }
    }

    static var privacySettings: PrivacySettingsState {
        get { snapshot.privacySettings }
        set {
            snapshot.privacySettings = newValue
            save()
        }
    }

    static var analyticsEvents: [AnalyticsEventSummary] {
        get { snapshot.analyticsEvents }
        set {
            snapshot.analyticsEvents = newValue
            save()
        }
    }

    static var mvpMetrics: [MvpMetricSummary] {
        get { snapshot.mvpMetrics }
        set {
            snapshot.mvpMetrics = newValue
            save()
        }
    }

    static var aiQualityLogs: [AIQualityLogEntry] {
        get { AppAIQualityLogStore.logs }
        set {
            snapshot.aiQualityLogs = newValue
            AppAIQualityLogStore.logs = newValue
            save()
        }
    }

    static var qaScenarios: [QaStateScenario] {
        get { snapshot.qaScenarios }
        set {
            snapshot.qaScenarios = newValue
            save()
        }
    }

    static var syncOperations: [SyncOperationSummary] {
        get { snapshot.syncOperations }
        set {
            snapshot.syncOperations = newValue
            save()
        }
    }

    static func localExportSummary() -> String {
        let homeworkCount = storedArrayCount(forKey: "school.homework.items.v1")
        let eventsCount = storedArrayCount(forKey: "school.calendar.events.v1")
        let timestamp = Date.now.formatted(date: .numeric, time: .shortened)

        return "Экспорт подготовлен локально \(timestamp): дети \(snapshot.children.count), семья \(snapshot.familyMembers.count), классы \(snapshot.classAccess.count), файлы \(snapshot.classFiles.count), ДЗ \(homeworkCount), события \(eventsCount)."
    }

    static func performLocalDeletion(scope: String) -> String {
        let timestamp = Date.now.formatted(date: .numeric, time: .shortened)

        switch scope {
        case "Профиль ребенка":
            snapshot.children = []
            AppChildStore.clear()
            snapshot.privacySettings.childDataConsent = false
            snapshot.privacySettings.privacyPolicyAccepted = false
            snapshot.privacySettings.consentStatus = "Данные ребенка очищены локально \(timestamp)"
            AppPrivacyConsentStore.clear()
            save()
        case "Семейные доступы":
            snapshot.familyMembers = []
            snapshot.familyTasks = []
            save()
        case "Локальные файлы и чеки":
            snapshot.classFiles = []
            UserDefaults.standard.removeObject(forKey: "school.classRoom.store.v1")
            save()
        case "Все локальные данные":
            removeAllLocalDataKeys()
            snapshot = .sample
        default:
            snapshot.profile = .sample
            snapshot.children = []
            AppChildStore.clear()
            snapshot.familyMembers = []
            snapshot.familyTasks = []
            snapshot.classAccess = []
            snapshot.privacySettings.childDataConsent = false
            snapshot.privacySettings.privacyPolicyAccepted = false
            snapshot.privacySettings.consentStatus = "Аккаунт и личные данные очищены локально \(timestamp)"
            AppPrivacyConsentStore.clear()
            save()
        }

        return "Локально удалено \(timestamp): \(scope). После backend этот шаг должен отправлять серверный запрос, требовать повторный вход и давать период отмены."
    }

    static func recordAudit(_ entry: AuditLogEntry) {
        snapshot.auditEntries.insert(entry, at: 0)
        save()
    }

    static func resetIfRequested() {
        guard ProcessInfo.processInfo.arguments.contains("-qa-reset-more-store") else {
            return
        }

        snapshot = .sample
        UserDefaults.standard.removeObject(forKey: defaultsKey)
    }

    private static func load() -> MoreStoreSnapshot {
        guard
            let data = UserDefaults.standard.data(forKey: defaultsKey),
            let decoded = try? JSONDecoder().decode(MoreStoreSnapshot.self, from: data)
        else {
            return .sample
        }

        return decoded
    }

    private static func save() {
        guard let data = try? JSONEncoder().encode(snapshot) else {
            return
        }

        UserDefaults.standard.set(data, forKey: defaultsKey)
    }

    private static func storedArrayCount(forKey key: String) -> Int {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let array = try? JSONSerialization.jsonObject(with: data) as? [Any]
        else {
            return 0
        }

        return array.count
    }

    private static func removeAllLocalDataKeys() {
        [
            defaultsKey,
            "school.homework.items.v1",
            "school.calendar.events.v1",
            "todayStoreSnapshot.v1",
            "school.classRoom.store.v1",
            "hasCompletedOnboarding",
            "onboardingVersion",
            "currentUserRole",
            "authMethod",
            "authContact",
            "authVerifiedAt",
            "school.shared.children.v1",
            "school.shared.selectedChildID"
        ].forEach(UserDefaults.standard.removeObject)

        AppPrivacyConsentStore.clear()
        AppChildStore.clear()
    }
}

struct MoreView: View {
    @State private var profile: ParentProfileState
    @State private var children: [ChildSummary]
    @State private var familyMembers: [FamilyAccessMember]
    @State private var familyTasks: [FamilyTaskSummary]
    @State private var classAccess: [ClassAccessSummary]
    @State private var notificationPreferences: [NotificationPreference]
    @State private var notificationSettings: NotificationSettingsState
    @State private var subscriptionPlans: [SubscriptionPlanSummary]
    @State private var classMemory: [ClassMemoryEntry]
    @State private var classFiles: [ClassFileSummary]
    @State private var securitySettings: SecuritySettingsState
    @State private var auditEntries: [AuditLogEntry]
    @State private var privacySettings: PrivacySettingsState
    @State private var analyticsEvents: [AnalyticsEventSummary]
    @State private var mvpMetrics: [MvpMetricSummary]
    @State private var aiQualityLogs: [AIQualityLogEntry]
    @State private var qaScenarios: [QaStateScenario]
    @State private var syncOperations: [SyncOperationSummary]
    @State private var activeSheet: MoreSheet?

    init() {
        MoreView.seedPrivacyConsentIfRequested()
        MoreLocalStore.resetIfRequested()
        _profile = State(initialValue: MoreLocalStore.profile)
        _children = State(initialValue: AppChildStore.children)
        _familyMembers = State(initialValue: MoreLocalStore.familyMembers)
        _familyTasks = State(initialValue: MoreLocalStore.familyTasks)
        _classAccess = State(initialValue: MoreLocalStore.classAccess)
        _notificationPreferences = State(initialValue: MoreLocalStore.notificationPreferences)
        _notificationSettings = State(initialValue: MoreLocalStore.notificationSettings)
        _subscriptionPlans = State(initialValue: MoreLocalStore.subscriptionPlans)
        _classMemory = State(initialValue: MoreLocalStore.classMemory)
        _classFiles = State(initialValue: MoreLocalStore.classFiles)
        _securitySettings = State(initialValue: MoreLocalStore.securitySettings)
        _auditEntries = State(initialValue: MoreLocalStore.auditEntries)
        _privacySettings = State(initialValue: MoreLocalStore.privacySettings.mergingStoredConsent())
        _analyticsEvents = State(initialValue: MoreLocalStore.analyticsEvents)
        _mvpMetrics = State(initialValue: MoreLocalStore.mvpMetrics)
        _aiQualityLogs = State(initialValue: MoreLocalStore.aiQualityLogs)
        _qaScenarios = State(initialValue: MoreLocalStore.qaScenarios)
        _syncOperations = State(initialValue: MoreLocalStore.syncOperations)
        _activeSheet = State(initialValue: MoreView.launchSheet())
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                header
                profileCard
                menuSection("Семья", items: familyItems)
                menuSection("Приложение", items: appItems)
                menuSection("Помощь", items: helpItems)
                logoutButton
            }
            .padding(.horizontal, 20)
            .padding(.top, 22)
            .padding(.bottom, SchoolTheme.bottomScrollPadding)
        }
        .background(SchoolTheme.page.ignoresSafeArea())
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .profile:
                ParentProfileSheet(
                    profile: profile,
                    children: children,
                    familyMembers: familyMembers,
                    classAccess: classAccess,
                    onOpenChildren: {
                        activeSheet = .children
                    },
                    onSave: { updatedProfile in
                        profile = updatedProfile
                        MoreLocalStore.profile = updatedProfile
                        recordAudit(
                            title: "Профиль обновлен",
                            detail: "Изменены контакт родителя",
                            target: updatedProfile.name,
                            category: "Аккаунт",
                            iconName: "person.crop.circle.fill",
                            colorName: "blue"
                        )
                    }
                )
            case .children:
                ChildrenAccessSheet(children: children) { updatedChildren in
                    children = updatedChildren
                    MoreLocalStore.children = updatedChildren
                    classAccess = MoreView.classAccess(from: updatedChildren)
                    MoreLocalStore.classAccess = classAccess
                    recordAudit(
                        title: "Профили детей сохранены",
                        detail: "Всего профилей: \(updatedChildren.count)",
                        target: "Дети",
                        category: "Данные детей",
                        iconName: "person.crop.square",
                        colorName: "green"
                    )
                }
            case .family:
                FamilyAccessSheet(members: familyMembers) { updatedMembers in
                    familyMembers = updatedMembers
                    MoreLocalStore.familyMembers = updatedMembers
                    recordAudit(
                        title: "Семейный доступ обновлен",
                        detail: "Всего доступов: \(updatedMembers.count)",
                        target: "Семья",
                        category: "Доступ",
                        iconName: "person.2.fill",
                        colorName: "teal"
                    )
                }
            case .familyTasks:
                FamilyTasksSheet(profile: profile, members: familyMembers, tasks: familyTasks) { updatedTasks in
                    familyTasks = updatedTasks
                    MoreLocalStore.familyTasks = updatedTasks
                    recordAudit(
                        title: "Семейные задачи сохранены",
                        detail: "Активных задач: \(updatedTasks.filter { $0.status != "Готово" }.count)",
                        target: "Задачи семьи",
                        category: "Семья",
                        iconName: "checklist.checked",
                        colorName: "orange"
                    )
                }
            case .classes:
                ClassesAccessSheet(classes: MoreView.classAccess(from: children)) { updatedClasses in
                    classAccess = updatedClasses
                    MoreLocalStore.classAccess = updatedClasses
                    recordAudit(
                        title: "Доступ к классам обновлен",
                        detail: "Классов подключено: \(updatedClasses.count)",
                        target: "Классы",
                        category: "Доступ",
                        iconName: "building.2.fill",
                        colorName: "blue"
                    )
                }
            case .subscription:
                SubscriptionSheet(plans: subscriptionPlans) { updatedPlans in
                    subscriptionPlans = updatedPlans
                    MoreLocalStore.subscriptionPlans = updatedPlans
                    recordAudit(
                        title: "Подписка изменена",
                        detail: updatedPlans.first(where: \.isCurrent)?.title ?? "Тариф не выбран",
                        target: "Подписка",
                        category: "Оплата",
                        iconName: "creditcard.fill",
                        colorName: "orange"
                    )
                }
            case .notifications:
                NotificationSettingsSheet(preferences: notificationPreferences, settings: notificationSettings) { updatedPreferences, updatedSettings in
                    notificationPreferences = updatedPreferences
                    notificationSettings = updatedSettings
                    MoreLocalStore.notificationPreferences = updatedPreferences
                    MoreLocalStore.notificationSettings = updatedSettings
                    recordAudit(
                        title: "Уведомления сохранены",
                        detail: "Включено сценариев: \(updatedPreferences.filter(\.isEnabled).count)",
                        target: "Настройки",
                        category: "Уведомления",
                        iconName: "bell.fill",
                        colorName: "green"
                    )
                }
            case .memory:
                ClassMemorySheet(entries: classMemory) { updatedEntries in
                    classMemory = updatedEntries
                    MoreLocalStore.classMemory = updatedEntries
                }
            case .files:
                ClassFilesSheet(files: classFiles) { updatedFiles in
                    classFiles = updatedFiles
                    MoreLocalStore.classFiles = updatedFiles
                    recordAudit(
                        title: "Файлы класса обновлены",
                        detail: "Файлов в локальном архиве: \(updatedFiles.count)",
                        target: "Файлы",
                        category: "Файлы",
                        iconName: "folder.fill",
                        colorName: "teal"
                    )
                }
            case .security:
                SecuritySettingsSheet(settings: securitySettings) { updatedSettings in
                    securitySettings = updatedSettings
                    MoreLocalStore.securitySettings = updatedSettings
                    recordAudit(
                        title: "Настройки безопасности сохранены",
                        detail: "\(securityEnabledCount(updatedSettings)) защиты включено",
                        target: "Безопасность",
                        category: "Безопасность",
                        iconName: "lock.shield.fill",
                        colorName: "green"
                    )
                }
            case .audit:
                AuditLogSheet(entries: auditEntries) { updatedEntries in
                    auditEntries = updatedEntries
                    MoreLocalStore.auditEntries = updatedEntries
                }
            case .privacy:
                PrivacySettingsSheet(settings: privacySettings) { updatedSettings in
                    privacySettings = updatedSettings
                    MoreLocalStore.privacySettings = updatedSettings
                    recordAudit(
                        title: "Приватность сохранена",
                        detail: updatedSettings.consentStatus,
                        target: "Данные ребенка",
                        category: "Безопасность",
                        iconName: "hand.raised.fill",
                        colorName: "green"
                    )
                }
            case .legal:
                LegalCenterSheet(settings: privacySettings)
            case .realDeviceQa:
                RealDeviceQaSheet()
            case .behavioralQa:
                BehavioralQaSheet()
            case .metrics:
                MvpMetricsSheet(events: analyticsEvents, metrics: mvpMetrics) { updatedEvents, updatedMetrics in
                    analyticsEvents = updatedEvents
                    mvpMetrics = updatedMetrics
                    MoreLocalStore.analyticsEvents = updatedEvents
                    MoreLocalStore.mvpMetrics = updatedMetrics
                    recordAudit(
                        title: "MVP-метрики обновлены",
                        detail: "Событий: \(updatedEvents.count), метрик: \(updatedMetrics.count)",
                        target: "Аналитика",
                        category: "Метрики",
                        iconName: "chart.bar.xaxis",
                        colorName: "blue"
                    )
                }
            case .aiQuality:
                AIQualitySheet(logs: aiQualityLogs) { updatedLogs in
                    aiQualityLogs = updatedLogs
                    MoreLocalStore.aiQualityLogs = updatedLogs
                    recordAudit(
                        title: "AI-качество обновлено",
                        detail: "Записей: \(updatedLogs.count), на проверке: \(updatedLogs.filter { $0.status != "Принято" }.count)",
                        target: "AI-разбор",
                        category: "AI",
                        iconName: "sparkles",
                        colorName: "orange"
                    )
                }
            case .qaStates:
                QaStatesSheet(scenarios: qaScenarios) { updatedScenarios in
                    qaScenarios = updatedScenarios
                    MoreLocalStore.qaScenarios = updatedScenarios
                    recordAudit(
                        title: "QA-состояния обновлены",
                        detail: "Пройдено: \(updatedScenarios.filter { $0.status == "Пройдено" }.count) из \(updatedScenarios.count)",
                        target: "Приемка MVP",
                        category: "QA",
                        iconName: "checkmark.seal.fill",
                        colorName: "green"
                    )
                }
            case .syncCenter:
                SyncCenterSheet(operations: syncOperations) { updatedOperations in
                    syncOperations = updatedOperations
                    MoreLocalStore.syncOperations = updatedOperations
                    recordAudit(
                        title: "Синхронизация проверена",
                        detail: "Очередь: \(updatedOperations.filter { $0.status != "Синхронизировано" }.count) задач",
                        target: "Backend readiness",
                        category: "Синхронизация",
                        iconName: "arrow.triangle.2.circlepath",
                        colorName: "blue"
                    )
                }
            case .moderation:
                ModerationCenterSheet()
            case .betaReadiness:
                BetaReadinessSheet()
            case .support:
                SupportMessageSheet(kind: .support)
            case .problem:
                SupportMessageSheet(kind: .problem)
            case .logout:
                LogoutSheet()
            }
        }
    }

    private var header: some View {
        HStack {
            Text("Еще")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(SchoolTheme.graphite)
            Spacer()
            HeaderIconButton(systemName: "gearshape") {
                activeSheet = .notifications
            }
            .accessibilityLabel("Настройки")
        }
    }

    private var profileCard: some View {
        Button {
            activeSheet = .profile
        } label: {
            DashboardCard {
                HStack(spacing: 14) {
                    InitialAvatar(text: String(profile.name.prefix(1)), color: SchoolTheme.accent, size: 58)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(profile.name)
                            .font(.headline)
                            .foregroundStyle(SchoolTheme.graphite)
                        Text(profile.roleSummary)
                            .font(.subheadline)
                            .foregroundStyle(SchoolTheme.muted)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(SchoolTheme.muted)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func menuSection(_ title: String, items: [MoreMenuItem]) -> some View {
        DashboardCard {
            VStack(alignment: .leading, spacing: 14) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(SchoolTheme.graphite)

                ForEach(items) { item in
                    Button {
                        if let sheet = item.sheet {
                            activeSheet = sheet
                        }
                    } label: {
                        HStack(spacing: 12) {
                            IconBadge(systemName: item.icon, color: item.color, size: 40)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(SchoolTheme.graphite)
                                Text(item.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(SchoolTheme.muted)
                                    .lineLimit(2)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundStyle(SchoolTheme.muted)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var logoutButton: some View {
        Button {
            activeSheet = .logout
        } label: {
            Label("Выйти из аккаунта", systemImage: "rectangle.portrait.and.arrow.right")
                .font(.headline)
                .foregroundStyle(SchoolTheme.warning)
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(SchoolTheme.warning.opacity(0.10), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private var familyItems: [MoreMenuItem] {
        [
            MoreMenuItem(title: "Дети и классы", subtitle: childRoleSummary, icon: "person.crop.square", color: SchoolTheme.success, sheet: .children),
            MoreMenuItem(title: "Семья", subtitle: "\(familyMembers.count) доступа: родители, бабушка, няня", icon: "person.2.fill", color: SchoolTheme.teal, sheet: .family),
            MoreMenuItem(title: "Задачи семьи", subtitle: "\(openFamilyTaskCount) активных: назначение и напоминания", icon: "checklist.checked", color: SchoolTheme.warning, sheet: .familyTasks),
            MoreMenuItem(title: "Классы", subtitle: classRoleSummary, icon: "building.2.fill", color: SchoolTheme.accent, sheet: .classes)
        ]
    }

    private var childRoleSummary: String {
        let classCount = Set(children.map(\.classCode)).count
        let committeeCount = children.filter { $0.parentRoleTitle == "Родкомитет" }.count
        return "\(children.count) профиля, \(classCount) класса, родкомитет: \(committeeCount)"
    }

    private var classRoleSummary: String {
        children
            .map { "\($0.className): \($0.parentRoleTitle.lowercased())" }
            .joined(separator: ", ")
    }

    private static func classAccess(from children: [ChildSummary]) -> [ClassAccessSummary] {
        children.map { child in
            ClassAccessSummary(
                title: child.className,
                school: child.school,
                role: child.parentRoleTitle,
                inviteCode: child.classCode,
                status: "Профиль: \(child.name)"
            )
        }
    }

    private var appItems: [MoreMenuItem] {
        [
            MoreMenuItem(title: "Подписка", subtitle: subscriptionSubtitle, icon: "creditcard.fill", color: SchoolTheme.warning, sheet: .subscription),
            MoreMenuItem(title: "Уведомления", subtitle: "\(enabledNotificationCount) включено: дайджесты, дедлайны, срочное", icon: "bell.fill", color: SchoolTheme.success, sheet: .notifications),
            MoreMenuItem(title: "Память класса", subtitle: "\(classMemory.count) находки: объявления, файлы, события", icon: "magnifyingglass", color: SchoolTheme.accent, sheet: .memory),
            MoreMenuItem(title: "Файлы", subtitle: "\(classFiles.count) файла: согласия, чеки, материалы", icon: "folder.fill", color: SchoolTheme.teal, sheet: .files),
            MoreMenuItem(title: "Журнал действий", subtitle: "\(auditEntries.count) записей: роли, доступы, файлы", icon: "list.bullet.rectangle.portrait.fill", color: SchoolTheme.graphite, sheet: .audit),
            MoreMenuItem(title: "MVP-метрики", subtitle: "\(eventsTotal) событий: активация, ДЗ, сборы, trial", icon: "chart.bar.xaxis", color: SchoolTheme.accent, sheet: .metrics),
            MoreMenuItem(title: "Качество AI", subtitle: "\(aiReviewCount) требуют проверки: повторы, промпты, ошибки", icon: "sparkles", color: SchoolTheme.warning, sheet: .aiQuality),
            MoreMenuItem(title: "Синхронизация", subtitle: syncSubtitle, icon: "arrow.triangle.2.circlepath", color: SchoolTheme.accent, sheet: .syncCenter)
        ]
    }

    private var subscriptionSubtitle: String {
        guard let currentPlan = subscriptionPlans.first(where: \.isCurrent) else {
            return "Пробный период и семейный доступ"
        }

        return "\(currentPlan.title): \(currentPlan.price)"
    }

    private var enabledNotificationCount: Int {
        notificationPreferences.filter(\.isEnabled).count
    }

    private var openFamilyTaskCount: Int {
        familyTasks.filter { $0.status != "Готово" }.count
    }

    private var eventsTotal: Int {
        analyticsEvents.map(\.count).reduce(0, +)
    }

    private var aiReviewCount: Int {
        aiQualityLogs.filter { $0.status != "Принято" }.count
    }

    private var syncSubtitle: String {
        let pending = syncOperations.filter { $0.status != "Синхронизировано" }.count
        return "\(pending) в очереди: API, offline, конфликты"
    }

    private var helpItems: [MoreMenuItem] {
        [
            MoreMenuItem(title: "Безопасность", subtitle: securitySubtitle, icon: "lock.shield.fill", color: SchoolTheme.success, sheet: .security),
            MoreMenuItem(title: "Приватность", subtitle: privacySubtitle, icon: "hand.raised.fill", color: SchoolTheme.teal, sheet: .privacy),
            MoreMenuItem(title: "Юридика", subtitle: "Политика, условия и App Store-блокеры", icon: "doc.text.magnifyingglass", color: SchoolTheme.graphite, sheet: .legal),
            MoreMenuItem(title: "Модерация", subtitle: moderationSubtitle, icon: "flag.fill", color: SchoolTheme.danger, sheet: .moderation),
            MoreMenuItem(title: "Проверка на iPhone", subtitle: "Камера, файлы, уведомления, подпись", icon: "iphone.gen3", color: SchoolTheme.accent, sheet: .realDeviceQa),
            MoreMenuItem(title: "Behavior QA", subtitle: "Инварианты прав, ролей и сохранения", icon: "checklist.checked", color: SchoolTheme.success, sheet: .behavioralQa),
            MoreMenuItem(title: "QA-состояния", subtitle: "\(qaPassedCount) из \(qaScenarios.count) проверены: пусто, offline, нет прав", icon: "checkmark.seal.fill", color: SchoolTheme.success, sheet: .qaStates),
            MoreMenuItem(title: "Бета / TestFlight", subtitle: "Release gate, тестеры и сценарии приемки", icon: "testtube.2", color: SchoolTheme.accent, sheet: .betaReadiness),
            MoreMenuItem(title: "Поддержка", subtitle: "Написать нам", icon: "message.fill", color: SchoolTheme.accent, sheet: .support),
            MoreMenuItem(title: "Проблема", subtitle: "Сообщить об ошибке", icon: "exclamationmark.bubble.fill", color: SchoolTheme.danger, sheet: .problem),
            MoreMenuItem(title: "Выйти", subtitle: "Локальный выход и перенос данных", icon: "rectangle.portrait.and.arrow.right", color: SchoolTheme.warning, sheet: .logout)
        ]
    }

    private var securitySubtitle: String {
        let enabledCount = [
            securitySettings.closedClassOnly,
            securitySettings.maskFinanceForFamily,
            securitySettings.requireInviteApproval
        ].filter { $0 }.count

        return "\(enabledCount) защиты: данные детей и доступы"
    }

    private var privacySubtitle: String {
        if privacySettings.childDataConsent && privacySettings.privacyPolicyAccepted {
            return "Согласие и политика подтверждены"
        }

        return "Нужно подтвердить согласие родителя"
    }

    private var moderationSubtitle: String {
        let openCount = ModerationQueueItem.sample.filter { $0.status != "Закрыта" }.count
        return "\(openCount) открыто: фото, чат, участники"
    }

    private var qaPassedCount: Int {
        qaScenarios.filter { $0.status == "Пройдено" }.count
    }

    private static func launchSheet() -> MoreSheet? {
        let arguments = ProcessInfo.processInfo.arguments

        if arguments.contains("-qa-more-profile") {
            return .profile
        }

        if arguments.contains("-qa-more-children") {
            return .children
        }

        if arguments.contains("-qa-more-family") {
            return .family
        }

        if arguments.contains("-qa-more-family-tasks") {
            return .familyTasks
        }

        if arguments.contains("-qa-more-classes") {
            return .classes
        }

        if arguments.contains("-qa-more-subscription") {
            return .subscription
        }

        if arguments.contains("-qa-more-notifications") {
            return .notifications
        }

        if arguments.contains("-qa-more-memory") {
            return .memory
        }

        if arguments.contains("-qa-more-files") || arguments.contains("-qa-more-files-importer") {
            return .files
        }

        if arguments.contains("-qa-more-audit") {
            return .audit
        }

        if arguments.contains("-qa-more-security") {
            return .security
        }

        if arguments.contains("-qa-more-privacy") {
            return .privacy
        }

        if arguments.contains("-qa-more-legal") {
            return .legal
        }

        if arguments.contains("-qa-more-real-device") {
            return .realDeviceQa
        }

        if arguments.contains("-qa-more-behavior") {
            return .behavioralQa
        }

        if arguments.contains("-qa-more-metrics") {
            return .metrics
        }

        if arguments.contains("-qa-more-ai-quality") {
            return .aiQuality
        }

        if arguments.contains("-qa-more-states") {
            return .qaStates
        }

        if arguments.contains("-qa-more-sync") {
            return .syncCenter
        }

        if arguments.contains("-qa-more-moderation") {
            return .moderation
        }

        if arguments.contains("-qa-more-beta") {
            return .betaReadiness
        }

        if arguments.contains("-qa-more-support") {
            return .support
        }

        if arguments.contains("-qa-more-problem") {
            return .problem
        }

        if arguments.contains("-qa-more-logout") {
            return .logout
        }

        return nil
    }

    private static func seedPrivacyConsentIfRequested() {
        guard ProcessInfo.processInfo.arguments.contains("-qa-more-privacy-consented") else {
            return
        }

        AppPrivacyConsentStore.save(
            childDataConsent: true,
            policyAccepted: true,
            actor: "Владимир"
        )
    }

    private func recordAudit(
        title: String,
        detail: String,
        target: String,
        category: String,
        iconName: String,
        colorName: String
    ) {
        let entry = AuditLogEntry(
            title: title,
            detail: detail,
            actor: profile.name,
            target: target,
            category: category,
            timestampLabel: "сейчас",
            iconName: iconName,
            colorName: colorName
        )
        auditEntries.insert(entry, at: 0)
        MoreLocalStore.recordAudit(entry)
    }

    private func securityEnabledCount(_ settings: SecuritySettingsState) -> Int {
        [
            settings.closedClassOnly,
            settings.maskFinanceForFamily,
            settings.requireInviteApproval
        ].filter { $0 }.count
    }
}

private struct ParentProfileSheet: View {
    @Environment(\.dismiss) private var dismiss

    let children: [ChildSummary]
    let familyMembers: [FamilyAccessMember]
    let classAccess: [ClassAccessSummary]
    let onOpenChildren: () -> Void
    let onSave: (ParentProfileState) -> Void

    @State private var profile: ParentProfileState

    init(
        profile: ParentProfileState,
        children: [ChildSummary],
        familyMembers: [FamilyAccessMember],
        classAccess: [ClassAccessSummary],
        onOpenChildren: @escaping () -> Void,
        onSave: @escaping (ParentProfileState) -> Void
    ) {
        self.children = children
        self.familyMembers = familyMembers
        self.classAccess = classAccess
        self.onOpenChildren = onOpenChildren
        self.onSave = onSave
        _profile = State(initialValue: profile)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    MoreSheetHeader(
                        icon: "person.crop.circle.fill",
                        color: SchoolTheme.accent,
                        title: "Профиль родителя",
                        subtitle: "Контакт, роли в классах и семейные участники"
                    )

                    DashboardCard {
                        HStack(spacing: 12) {
                            MoreMetric(value: "\(children.count)", title: "детей", color: SchoolTheme.success)
                            Divider()
                            MoreMetric(value: "\(classProfileCount)", title: "класса", color: SchoolTheme.accent)
                            Divider()
                            MoreMetric(value: "\(familyMembers.count)", title: "семья", color: SchoolTheme.teal)
                        }
                        .frame(height: 62)
                    }

                    DashboardCard {
                        VStack(spacing: 12) {
                            MoreTextField(title: "Имя", iconName: "person.fill", color: SchoolTheme.accent, text: $profile.name)
                            MoreTextField(title: "Телефон", iconName: "phone.fill", color: SchoolTheme.success, text: $profile.contact)
                            MoreTextField(title: "Apple ID / email", iconName: "at", color: SchoolTheme.teal, text: $profile.appleID)
                        }
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Роли в классах")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            Text("Один аккаунт может иметь разные права в разных классах. При выборе ребенка приложение переключает класс и роль.")
                                .font(.caption)
                                .foregroundStyle(SchoolTheme.muted)
                                .fixedSize(horizontal: false, vertical: true)

                            ForEach(children) { child in
                                profileClassRoleRow(child)
                            }

                            if let bridgeContext = AppSupabaseClassContextBridge.primaryContext {
                                profileInfoRow(
                                    icon: "link.badge.plus",
                                    color: SchoolTheme.accent,
                                    title: bridgeContext.handoffText,
                                    detail: "Пока хранится отдельно от локальных детей"
                                )
                            }

                            if let childContext = AppSupabaseChildContextBridge.primaryContext {
                                profileInfoRow(
                                    icon: "person.crop.circle.badge.checkmark",
                                    color: SchoolTheme.success,
                                    title: childContext.handoffText,
                                    detail: "Child bridge хранится отдельно от выбранного локального ребенка"
                                )
                            }

                            Button {
                                openChildrenProfiles()
                            } label: {
                                Label("Добавить профиль в другом классе", systemImage: "plus")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity, minHeight: 46)
                            }
                            .buttonStyle(.bordered)
                            .tint(SchoolTheme.success)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Семья")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            ForEach(familyMembers.prefix(3)) { member in
                                profileInfoRow(
                                    icon: "person.2.fill",
                                    color: SchoolTheme.teal,
                                    title: member.name,
                                    detail: "\(member.role) - \(member.access)"
                                )
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button {
                        save()
                    } label: {
                        Label("Сохранить профиль", systemImage: "checkmark")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 52)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(SchoolTheme.success)
                    .disabled(profile.name.trimmed.isEmpty || profile.contact.trimmed.isEmpty)
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Профиль")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        save()
                    }
                }
                KeyboardDoneToolbar()
            }
        }
    }

    private var classProfileCount: Int {
        Set(children.map(\.classCode)).count
    }

    private func profileClassRoleRow(_ child: ChildSummary) -> some View {
        HStack(spacing: 12) {
            InitialAvatar(text: child.avatarText, color: roleColor(child.parentRoleTitle), size: 40)
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 7) {
                    Text("\(child.name), \(child.className)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SchoolTheme.graphite)
                    StatusBadge(text: child.parentRoleTitle, color: roleColor(child.parentRoleTitle))
                }
                Text("\(child.school) - код \(child.classCode)")
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
    }

    private func roleColor(_ role: String) -> Color {
        switch role {
        case "Родкомитет":
            SchoolTheme.warning
        case "Учитель":
            SchoolTheme.accent
        default:
            SchoolTheme.success
        }
    }

    private func openChildrenProfiles() {
        onSave(profile)
        dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            onOpenChildren()
        }
    }

    private func profileInfoRow(icon: String, color: Color, title: String, detail: String) -> some View {
        HStack(spacing: 12) {
            IconBadge(systemName: icon, color: color, size: 40)
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
            Spacer()
        }
    }

    private func save() {
        onSave(profile)
        dismiss()
    }
}

private struct ChildrenAccessSheet: View {
    @Environment(\.dismiss) private var dismiss
    private let roleOptions = ["Родитель", "Родкомитет", "Учитель"]

    let onSave: ([ChildSummary]) -> Void

    @State private var children: [ChildSummary]
    @State private var childName = "Саша"
    @State private var className = "1А"
    @State private var school = "Школа 1254"
    @State private var classCode = "1A-1254"
    @State private var parentRoleTitle = "Родитель"

    init(children: [ChildSummary], onSave: @escaping ([ChildSummary]) -> Void) {
        self.onSave = onSave
        _children = State(initialValue: children)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    MoreSheetHeader(
                        icon: "person.crop.square",
                        color: SchoolTheme.success,
                        title: "Дети",
                        subtitle: "Профили, классы и школьные связи"
                    )

                    DashboardCard {
                        HStack(spacing: 12) {
                            MoreMetric(value: "\(children.count)", title: "профиля", color: SchoolTheme.success)
                            Divider()
                            MoreMetric(value: "2", title: "класса", color: SchoolTheme.accent)
                            Divider()
                            MoreMetric(value: "1", title: "семья", color: SchoolTheme.teal)
                        }
                        .frame(height: 62)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Профили детей")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            ForEach(children) { child in
                                HStack(spacing: 12) {
                                    InitialAvatar(text: child.avatarText, color: SchoolTheme.success, size: 42)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("\(child.name), \(child.className)")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(SchoolTheme.graphite)
                                        Text("\(child.school) - код \(child.classCode)")
                                            .font(.caption)
                                            .foregroundStyle(SchoolTheme.muted)
                                    }
                                    Spacer()
                                    roleMenu(for: child)
                                }
                            }
                        }
                    }

                    DashboardCard {
                        VStack(spacing: 12) {
                            MoreTextField(title: "Имя ребенка", iconName: "person.fill", color: SchoolTheme.success, text: $childName)
                            MoreTextField(title: "Класс", iconName: "building.2.fill", color: SchoolTheme.accent, text: $className)
                            MoreTextField(title: "Код класса", iconName: "link", color: SchoolTheme.warning, text: $classCode)
                            MoreTextField(title: "Школа", iconName: "graduationcap.fill", color: SchoolTheme.teal, text: $school)
                            Menu {
                                ForEach(roleOptions, id: \.self) { role in
                                    Button(role) {
                                        parentRoleTitle = role
                                    }
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    IconBadge(systemName: "person.badge.shield.checkmark.fill", color: SchoolTheme.accent, size: 40)
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("Роль в этом классе")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(SchoolTheme.muted)
                                        Text(parentRoleTitle)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(SchoolTheme.graphite)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundStyle(SchoolTheme.muted)
                                }
                                .padding(12)
                                .background(SchoolTheme.page, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(SchoolTheme.line, lineWidth: 1)
                                }
                            }
                            .buttonStyle(.plain)

                            Button {
                                addChild()
                            } label: {
                                Label("Добавить ребенка", systemImage: "plus")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity, minHeight: 46)
                            }
                            .buttonStyle(.bordered)
                            .tint(SchoolTheme.success)
                            .disabled(childName.trimmed.isEmpty || className.trimmed.isEmpty || classCode.trimmed.isEmpty)
                        }
                    }

                    saveButton
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Дети")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        save()
                    }
                }
                KeyboardDoneToolbar()
            }
        }
    }

    private var saveButton: some View {
        Button {
            save()
        } label: {
            Label("Сохранить детей", systemImage: "checkmark")
                .font(.headline)
                .frame(maxWidth: .infinity, minHeight: 52)
        }
        .buttonStyle(.borderedProminent)
        .tint(SchoolTheme.success)
    }

    private func roleMenu(for child: ChildSummary) -> some View {
        Menu {
            ForEach(roleOptions, id: \.self) { role in
                Button {
                    updateRole(for: child, role: role)
                } label: {
                    if child.parentRoleTitle == role {
                        Label(role, systemImage: "checkmark")
                    } else {
                        Text(role)
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                StatusBadge(text: child.parentRoleTitle, color: roleColor(child.parentRoleTitle))
                Image(systemName: "chevron.down")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(SchoolTheme.muted)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Изменить роль в классе \(child.className)")
    }

    private func addChild() {
        let avatar = String(childName.trimmed.prefix(1)).uppercased()
        children.append(
            ChildSummary(
                name: childName.trimmed,
                className: className.trimmed,
                school: school.trimmed,
                avatarText: avatar.isEmpty ? "Р" : avatar,
                classCode: classCode.trimmed.uppercased(),
                parentRoleTitle: parentRoleTitle
            )
        )
        childName = ""
        className = ""
        classCode = ""
    }

    private func updateRole(for child: ChildSummary, role: String) {
        guard let index = children.firstIndex(where: { $0.id == child.id }) else {
            return
        }

        children[index] = ChildSummary(
            id: child.id,
            name: child.name,
            className: child.className,
            school: child.school,
            avatarText: child.avatarText,
            classCode: child.classCode,
            parentRoleTitle: role
        )
    }

    private func roleColor(_ role: String) -> Color {
        switch role {
        case "Родкомитет":
            SchoolTheme.warning
        case "Учитель":
            SchoolTheme.accent
        default:
            SchoolTheme.success
        }
    }

    private func save() {
        onSave(children)
        dismiss()
    }
}

private struct FamilyTasksSheet: View {
    @Environment(\.dismiss) private var dismiss

    let profile: ParentProfileState
    let members: [FamilyAccessMember]
    let onSave: ([FamilyTaskSummary]) -> Void

    @State private var tasks: [FamilyTaskSummary]
    @State private var title = "Забрать согласие из портфеля"
    @State private var dueLabel = "Сегодня"
    @State private var reminder = "19:30"
    @State private var assignee: String

    init(
        profile: ParentProfileState,
        members: [FamilyAccessMember],
        tasks: [FamilyTaskSummary],
        onSave: @escaping ([FamilyTaskSummary]) -> Void
    ) {
        self.profile = profile
        self.members = members
        self.onSave = onSave
        _tasks = State(initialValue: tasks)
        _assignee = State(initialValue: members.first?.name ?? profile.name)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    MoreSheetHeader(
                        icon: "checklist.checked",
                        color: SchoolTheme.warning,
                        title: "Задачи семьи",
                        subtitle: "Назначение, персональные напоминания и передача"
                    )

                    DashboardCard {
                        HStack(spacing: 12) {
                            MoreMetric(value: "\(openTasks.count)", title: "активных", color: SchoolTheme.warning)
                            Divider()
                            MoreMetric(value: "\(myTasks.count)", title: "моих", color: SchoolTheme.success)
                            Divider()
                            MoreMetric(value: "\(tasks.filter { $0.status == "Готово" }.count)", title: "готово", color: SchoolTheme.accent)
                        }
                        .frame(height: 62)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Список задач")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            if tasks.isEmpty {
                                emptyTaskRow
                            } else {
                                ForEach(tasks) { task in
                                    taskRow(task)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    DashboardCard {
                        VStack(spacing: 12) {
                            assigneeMenu
                            MoreTextField(title: "Задача", iconName: "text.badge.plus", color: SchoolTheme.warning, text: $title)
                            MoreTextField(title: "Срок", iconName: "calendar", color: SchoolTheme.accent, text: $dueLabel)
                            MoreTextField(title: "Напоминание", iconName: "bell.fill", color: SchoolTheme.success, text: $reminder)

                            Button {
                                addTask()
                            } label: {
                                Label("Назначить задачу", systemImage: "plus")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity, minHeight: 46)
                            }
                            .buttonStyle(.bordered)
                            .tint(SchoolTheme.warning)
                            .disabled(title.trimmed.isEmpty || assignee.trimmed.isEmpty)
                        }
                    }

                    Button {
                        save()
                    } label: {
                        Label("Сохранить задачи", systemImage: "checkmark")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 52)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(SchoolTheme.success)
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Задачи")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        save()
                    }
                }
                KeyboardDoneToolbar()
            }
        }
    }

    private var openTasks: [FamilyTaskSummary] {
        tasks.filter { $0.status != "Готово" }
    }

    private var myTasks: [FamilyTaskSummary] {
        tasks.filter { $0.assignee == profile.name && $0.status != "Готово" }
    }

    private var emptyTaskRow: some View {
        HStack(spacing: 12) {
            IconBadge(systemName: "checkmark.seal.fill", color: SchoolTheme.success, size: 40)
            Text("Семейных задач пока нет")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(SchoolTheme.muted)
            Spacer()
        }
    }

    private var assigneeMenu: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Исполнитель")
                .font(.caption.weight(.semibold))
                .foregroundStyle(SchoolTheme.muted)

            Menu {
                ForEach(memberNames, id: \.self) { memberName in
                    Button(memberName) {
                        assignee = memberName
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    IconBadge(systemName: "person.fill", color: SchoolTheme.teal, size: 38)
                    Text(assignee)
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

    private var memberNames: [String] {
        let names = members.map(\.name)
        return names.contains(profile.name) ? names : [profile.name] + names
    }

    private func taskRow(_ task: FamilyTaskSummary) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                IconBadge(
                    systemName: task.status == "Готово" ? "checkmark.circle.fill" : "bell.fill",
                    color: task.status == "Готово" ? SchoolTheme.success : SchoolTheme.warning,
                    size: 40
                )

                VStack(alignment: .leading, spacing: 5) {
                    Text(task.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(task.status == "Готово" ? SchoolTheme.muted : SchoolTheme.graphite)
                        .strikethrough(task.status == "Готово", color: SchoolTheme.muted)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    StatusBadge(text: task.status, color: task.status == "Готово" ? SchoolTheme.success : SchoolTheme.warning)

                    Text("\(task.assignee) - \(task.dueLabel)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(SchoolTheme.graphite)
                    Text("Персональное напоминание для \(task.assignee): \(task.reminder)")
                        .font(.caption)
                        .foregroundStyle(SchoolTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)
            }

            HStack(spacing: 8) {
                Button {
                    assignToMe(task)
                } label: {
                    TaskActionButtonLabel(title: "Я сделаю", systemImage: "person.fill")
                }
                .buttonStyle(.bordered)
                .tint(SchoolTheme.success)
                .disabled(task.status == "Готово")

                Button {
                    transfer(task)
                } label: {
                    TaskActionButtonLabel(title: "Передать", systemImage: "arrow.right.circle.fill")
                }
                .buttonStyle(.bordered)
                .tint(SchoolTheme.accent)
                .disabled(task.status == "Готово")

                Button {
                    complete(task)
                } label: {
                    TaskActionButtonLabel(title: "Готово", systemImage: "checkmark")
                }
                .buttonStyle(.borderedProminent)
                .tint(SchoolTheme.success)
                .disabled(task.status == "Готово")
            }
        }
        .padding(12)
        .background(SchoolTheme.surface, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(SchoolTheme.line, lineWidth: 1)
        }
    }

    private func addTask() {
        tasks.insert(
            FamilyTaskSummary(
                title: title.trimmed,
                assignee: assignee,
                dueLabel: dueLabel.trimmed.isEmpty ? "Сегодня" : dueLabel.trimmed,
                reminder: reminder.trimmed.isEmpty ? "19:30" : reminder.trimmed
            ),
            at: 0
        )
        title = ""
    }

    private func assignToMe(_ task: FamilyTaskSummary) {
        update(task) { item in
            item.assignee = profile.name
            item.status = "Я сделаю"
        }
    }

    private func transfer(_ task: FamilyTaskSummary) {
        guard let currentIndex = memberNames.firstIndex(of: task.assignee) else {
            update(task) { item in
                item.assignee = memberNames.first ?? profile.name
                item.status = "Передана"
            }
            return
        }

        let nextIndex = memberNames.index(after: currentIndex) == memberNames.endIndex ? memberNames.startIndex : memberNames.index(after: currentIndex)
        update(task) { item in
            item.assignee = memberNames[nextIndex]
            item.status = "Передана"
        }
    }

    private func complete(_ task: FamilyTaskSummary) {
        update(task) { item in
            item.status = "Готово"
        }
    }

    private func update(_ task: FamilyTaskSummary, mutation: (inout FamilyTaskSummary) -> Void) {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else {
            return
        }

        mutation(&tasks[index])
        onSave(tasks)
    }

    private func save() {
        onSave(tasks)
        dismiss()
    }
}

private struct TaskActionButtonLabel: View {
    let title: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: systemImage)
                .font(.caption.weight(.bold))
            Text(title)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .allowsTightening(true)
        }
        .frame(maxWidth: .infinity, minHeight: 36)
    }
}

private struct FamilyAccessSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: ([FamilyAccessMember]) -> Void

    @State private var members: [FamilyAccessMember]
    @State private var inviteName = "Наталья"
    @State private var inviteRole = "Няня"
    @State private var inviteAccess = "Календарь и что забрать"
    @State private var familyInviteCode = "FAM-3184"
    @State private var inviteStatus = "Семейная ссылка готова к отправке"

    init(members: [FamilyAccessMember], onSave: @escaping ([FamilyAccessMember]) -> Void) {
        self.onSave = onSave
        _members = State(initialValue: members)
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        MoreSheetHeader(
                            icon: "person.2.fill",
                            color: SchoolTheme.teal,
                            title: "Семья",
                            subtitle: "Кто помогает с ребенком и что видит"
                        )
                        .id("family-top")

                        DashboardCard {
                            HStack(spacing: 12) {
                                MoreMetric(value: "\(members.count)", title: "доступа", color: SchoolTheme.teal)
                                Divider()
                                MoreMetric(value: "\(members.filter { $0.status.contains("Ожидает") }.count)", title: "ожидают", color: SchoolTheme.warning)
                                Divider()
                                MoreMetric(value: "1", title: "админ", color: SchoolTheme.success)
                            }
                            .frame(height: 62)
                        }

                        DashboardCard {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Семейный доступ")
                                    .font(.headline)
                                    .foregroundStyle(SchoolTheme.graphite)

                                ForEach(members) { member in
                                    HStack(spacing: 12) {
                                        InitialAvatar(text: member.avatarText, color: color(for: member.role), size: 42)
                                        VStack(alignment: .leading, spacing: 3) {
                                            HStack(spacing: 7) {
                                                Text(member.name)
                                                    .font(.subheadline.weight(.semibold))
                                                    .foregroundStyle(SchoolTheme.graphite)
                                                StatusBadge(text: member.role, color: color(for: member.role))
                                            }
                                            Text(member.access)
                                                .font(.caption)
                                                .foregroundStyle(SchoolTheme.muted)
                                            Text(member.status)
                                                .font(.caption.weight(.semibold))
                                                .foregroundStyle(member.status.contains("Ожидает") ? SchoolTheme.warning : SchoolTheme.success)
                                        }
                                        Spacer()
                                    }
                                }
                            }
                        }

                        DashboardCard {
                            VStack(spacing: 12) {
                                HStack(alignment: .top, spacing: 14) {
                                    MoreInviteQRCodeView(text: familyInviteLink, color: SchoolTheme.graphite)
                                        .frame(width: 96, height: 96)

                                    VStack(alignment: .leading, spacing: 7) {
                                        Text("Ссылка семьи")
                                            .font(.headline)
                                            .foregroundStyle(SchoolTheme.graphite)
                                        Text(familyInviteLink)
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(SchoolTheme.graphite)
                                            .lineLimit(3)
                                            .textSelection(.enabled)
                                        Text(inviteStatus)
                                            .font(.caption)
                                            .foregroundStyle(SchoolTheme.muted)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    Spacer()
                                }

                                HStack(spacing: 8) {
                                    ShareLink(item: familyInviteLink) {
                                        Label("Отправить", systemImage: "square.and.arrow.up")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(SchoolTheme.accent)
                                            .frame(maxWidth: .infinity, minHeight: 38)
                                            .background(SchoolTheme.accent.opacity(0.11), in: Capsule())
                                    }

                                    Button {
                                        familyInviteCode = nextFamilyInviteCode()
                                        inviteStatus = "Семейный код обновлен локально"
                                    } label: {
                                        Label("Новый код", systemImage: "arrow.clockwise")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(SchoolTheme.warning)
                                            .frame(maxWidth: .infinity, minHeight: 38)
                                            .background(SchoolTheme.warning.opacity(0.11), in: Capsule())
                                    }
                                    .buttonStyle(.plain)
                                }

                                Divider()

                                MoreTextField(title: "Кого пригласить", iconName: "person.badge.plus", color: SchoolTheme.success, text: $inviteName)

                                Picker("Роль", selection: $inviteRole) {
                                    Text("Родитель").tag("Второй родитель")
                                    Text("Бабушка").tag("Бабушка")
                                    Text("Няня").tag("Няня")
                                }
                                .pickerStyle(.segmented)

                                MoreTextField(title: "Доступ", iconName: "lock.open.fill", color: SchoolTheme.accent, text: $inviteAccess)

                                Button {
                                    inviteMember()
                                } label: {
                                    Label("Отправить приглашение", systemImage: "link")
                                        .font(.subheadline.weight(.semibold))
                                        .frame(maxWidth: .infinity, minHeight: 46)
                                }
                                .buttonStyle(.bordered)
                                .tint(SchoolTheme.success)
                                .disabled(inviteName.trimmed.isEmpty)
                            }
                        }

                        Button {
                            save()
                        } label: {
                            Label("Сохранить семью", systemImage: "checkmark")
                                .font(.headline)
                                .frame(maxWidth: .infinity, minHeight: 52)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(SchoolTheme.success)
                    }
                    .padding(20)
                    .padding(.bottom, 20)
                }
                .onAppear {
                    proxy.scrollTo("family-top", anchor: .top)
                }
                .scrollDismissesKeyboard(.interactively)
                .background(SchoolTheme.page.ignoresSafeArea())
                .navigationTitle("Семья")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Закрыть") {
                            save()
                        }
                    }
                    KeyboardDoneToolbar()
                }
            }
        }
    }

    private var familyInviteLink: String {
        let role = inviteRole.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? inviteRole
        let access = inviteAccess.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? inviteAccess
        return "schoolclass://family/join?code=\(familyInviteCode)&role=\(role)&access=\(access)"
    }

    private func inviteMember() {
        let avatar = String(inviteName.trimmed.prefix(1)).uppercased()
        members.append(
            FamilyAccessMember(
                name: inviteName.trimmed,
                role: inviteRole,
                access: inviteAccess.trimmed,
                avatarText: avatar.isEmpty ? "С" : avatar,
                status: "Ожидает вход"
            )
        )
        inviteStatus = "Приглашение для \(inviteName.trimmed) добавлено. Ссылку можно отправить через системное меню."
        inviteName = ""
    }

    private func nextFamilyInviteCode() -> String {
        "FAM-\(Int.random(in: 1000...9999))"
    }

    private func save() {
        onSave(members)
        dismiss()
    }

    private func color(for role: String) -> Color {
        switch role {
        case "Бабушка", "Няня":
            SchoolTheme.teal
        case "Второй родитель":
            SchoolTheme.accent
        default:
            SchoolTheme.success
        }
    }
}

private struct MoreInviteQRCodeView: View {
    let text: String
    let color: Color

    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()

    var body: some View {
        Group {
            if let image = qrImage {
                Image(uiImage: image)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "qrcode")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(color)
            }
        }
        .padding(10)
        .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(SchoolTheme.line, lineWidth: 1)
        }
        .accessibilityLabel("QR-код семейного приглашения")
    }

    private var qrImage: UIImage? {
        filter.message = Data(text.utf8)
        filter.correctionLevel = "M"

        guard let outputImage = filter.outputImage else {
            return nil
        }

        let scaled = outputImage.transformed(by: CGAffineTransform(scaleX: 8, y: 8))
        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }
}

private struct ClassesAccessSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: ([ClassAccessSummary]) -> Void

    @State private var classes: [ClassAccessSummary]
    @State private var inviteCode = "NEW-2048"
    @State private var newClassTitle = "2В"
    @State private var newRole = "Родитель"
    private let roleOptions = ["Родитель", "Родкомитет", "Учитель"]

    init(classes: [ClassAccessSummary], onSave: @escaping ([ClassAccessSummary]) -> Void) {
        self.onSave = onSave
        _classes = State(initialValue: classes)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    MoreSheetHeader(
                        icon: "building.2.fill",
                        color: SchoolTheme.accent,
                        title: "Классы",
                        subtitle: "Роли, коды приглашения и закрытый доступ"
                    )

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Мои классы")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            ForEach(classes) { classItem in
                                HStack(spacing: 12) {
                                    IconBadge(systemName: "building.2.fill", color: roleColor(classItem.role), size: 42)
                                    VStack(alignment: .leading, spacing: 3) {
                                        HStack(spacing: 7) {
                                            Text(classItem.title)
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(SchoolTheme.graphite)
                                            StatusBadge(text: classItem.role, color: roleColor(classItem.role))
                                        }
                                        Text(classItem.school)
                                            .font(.caption)
                                            .foregroundStyle(SchoolTheme.muted)
                                        Text("\(classItem.status) - код \(classItem.inviteCode)")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(SchoolTheme.muted)
                                    }
                                    Spacer()
                                }
                            }
                        }
                    }

                    DashboardCard {
                        VStack(spacing: 12) {
                            MoreTextField(title: "Название класса", iconName: "text.badge.plus", color: SchoolTheme.success, text: $newClassTitle)
                            MoreTextField(title: "Код приглашения", iconName: "number", color: SchoolTheme.warning, text: $inviteCode)

                            Picker("Роль", selection: $newRole) {
                                ForEach(roleOptions, id: \.self) { role in
                                    Text(role).tag(role)
                                }
                            }
                            .pickerStyle(.segmented)

                            Button {
                                joinClass()
                            } label: {
                                Label("Добавить класс", systemImage: "plus")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity, minHeight: 46)
                            }
                            .buttonStyle(.bordered)
                            .tint(SchoolTheme.success)
                            .disabled(newClassTitle.trimmed.isEmpty || inviteCode.trimmed.isEmpty)
                        }
                    }

                    Button {
                        save()
                    } label: {
                        Label("Сохранить классы", systemImage: "checkmark")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 52)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(SchoolTheme.success)
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Классы")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        save()
                    }
                }
                KeyboardDoneToolbar()
            }
        }
    }

    private func joinClass() {
        classes.append(
            ClassAccessSummary(
                title: newClassTitle.trimmed,
                school: "Школа 1254",
                role: newRole,
                inviteCode: inviteCode.trimmed,
                status: "Ожидает подтверждения"
            )
        )
        newClassTitle = ""
        inviteCode = ""
    }

    private func roleColor(_ role: String) -> Color {
        switch role {
        case "Родкомитет":
            SchoolTheme.warning
        case "Учитель":
            SchoolTheme.accent
        default:
            SchoolTheme.success
        }
    }

    private func save() {
        onSave(classes)
        dismiss()
    }
}

private struct SubscriptionSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: ([SubscriptionPlanSummary]) -> Void

    @State private var plans: [SubscriptionPlanSummary]
    @State private var restoreStatus = "Покупки еще не проверялись"
    @State private var storeKitStatus = "StoreKit 2 каталог подключен; покупка пока проверяется локальными сценариями"
    @State private var transactionId = "нет транзакции"
    @State private var subscriptionExpires = "trial +14 дней"
    @State private var storeKitCatalogStatus = "Каталог StoreKit еще не запрашивался"
    @State private var storeKitProducts: [StoreKitProductSnapshot] = StoreKitProductSnapshot.pending
    @State private var isLoadingStoreKitProducts = false

    init(plans: [SubscriptionPlanSummary], onSave: @escaping ([SubscriptionPlanSummary]) -> Void) {
        self.onSave = onSave
        _plans = State(initialValue: plans)
        if ProcessInfo.processInfo.arguments.contains("-qa-more-subscription") {
            _storeKitCatalogStatus = State(initialValue: "QA: StoreKit 2 готов к проверке product ids")
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    MoreSheetHeader(
                        icon: "creditcard.fill",
                        color: SchoolTheme.warning,
                        title: "Подписка",
                        subtitle: "Пробный период, семейный доступ и будущие лимиты"
                    )

                    DashboardCard {
                        HStack(spacing: 12) {
                            MoreMetric(value: currentPlan?.badge ?? "Активен", title: "статус", color: SchoolTheme.warning)
                            Divider()
                            MoreMetric(value: "14", title: "дней trial", color: SchoolTheme.success)
                            Divider()
                            MoreMetric(value: "2", title: "ребенка", color: SchoolTheme.accent)
                        }
                        .frame(height: 62)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Покупки")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            storeKitRow(
                                icon: "shippingbox.fill",
                                color: SchoolTheme.accent,
                                title: "Продукт",
                                detail: productId
                            )

                            storeKitRow(
                                icon: "receipt.fill",
                                color: SchoolTheme.success,
                                title: "Транзакция",
                                detail: transactionId
                            )

                            storeKitRow(
                                icon: "calendar.badge.clock",
                                color: SchoolTheme.warning,
                                title: "Действует",
                                detail: subscriptionExpires
                            )

                            Text(storeKitStatus)
                                .font(.caption)
                                .foregroundStyle(SchoolTheme.muted)
                                .fixedSize(horizontal: false, vertical: true)

                            HStack(spacing: 8) {
                                purchaseButton(isLoadingStoreKitProducts ? "Проверка" : "StoreKit", icon: "shippingbox.and.arrow.backward.fill", color: SchoolTheme.accent) {
                                    Task {
                                        await loadStoreKitProducts()
                                    }
                                }
                                purchaseButton("Купить", icon: "cart.fill", color: SchoolTheme.success) {
                                    purchaseLocally()
                                }
                            }

                            HStack(spacing: 8) {
                                purchaseButton("Вернуть", icon: "arrow.clockwise", color: SchoolTheme.accent) {
                                    restorePurchases()
                                }
                                purchaseButton("Истекла", icon: "clock.badge.exclamationmark.fill", color: SchoolTheme.warning) {
                                    expireSubscription()
                                }
                                purchaseButton("Ошибка", icon: "exclamationmark.triangle.fill", color: SchoolTheme.danger) {
                                    failPurchase()
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    DashboardCard {
                        storeKitEntitlementCard(entitlementPreview)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("StoreKit 2 каталог")
                                    .font(.headline)
                                    .foregroundStyle(SchoolTheme.graphite)
                                Spacer()
                                StatusBadge(text: "\(loadedStoreKitCount)/\(storeKitProducts.count)", color: loadedStoreKitCount == storeKitProducts.count ? SchoolTheme.success : SchoolTheme.warning)
                            }

                            Text(storeKitCatalogStatus)
                                .font(.caption)
                                .foregroundStyle(SchoolTheme.muted)
                                .fixedSize(horizontal: false, vertical: true)

                            ForEach(storeKitProducts) { product in
                                storeKitProductRow(product)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Тарифы MVP")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            ForEach(plans) { plan in
                                Button {
                                    select(plan)
                                } label: {
                                    subscriptionPlanRow(plan)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Что входит")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            ForEach(SampleData.subscriptionBenefits) { benefit in
                                HStack(spacing: 12) {
                                    IconBadge(systemName: benefit.iconName, color: moreColor(for: benefit.colorName), size: 40)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(benefit.title)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(SchoolTheme.graphite)
                                        Text(benefit.detail)
                                            .font(.caption)
                                            .foregroundStyle(SchoolTheme.muted)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    Spacer()
                                }
                            }
                        }
                    }

                    Button {
                        save()
                    } label: {
                        Label("Сохранить подписку", systemImage: "checkmark")
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
            .navigationTitle("Подписка")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                guard ProcessInfo.processInfo.arguments.contains("-qa-more-subscription") else {
                    return
                }
                await loadStoreKitProducts()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        save()
                    }
                }
            }
        }
    }

    private var currentPlan: SubscriptionPlanSummary? {
        plans.first(where: \.isCurrent)
    }

    private var productId: String {
        switch currentPlan?.title {
        case "1 ребенок":
            "school.class.family.monthly.child1"
        case "Семья+":
            "school.class.family.monthly.extra_child"
        default:
            "school.class.family.trial"
        }
    }

    private var loadedStoreKitCount: Int {
        storeKitProducts.filter { $0.status == "Найден" }.count
    }

    private var entitlementPreview: StoreKitEntitlementPreview {
        StoreKitEntitlementPreview.make(
            planTitle: currentPlan?.title ?? "Пробный период",
            productID: productId,
            transactionID: transactionId,
            expires: subscriptionExpires
        )
    }

    private func subscriptionPlanRow(_ plan: SubscriptionPlanSummary) -> some View {
        HStack(spacing: 12) {
            IconBadge(
                systemName: plan.isCurrent ? "checkmark.seal.fill" : "creditcard.fill",
                color: plan.isCurrent ? SchoolTheme.success : SchoolTheme.warning,
                size: 42
            )
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 7) {
                    Text(plan.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SchoolTheme.graphite)
                    StatusBadge(text: plan.badge, color: plan.isCurrent ? SchoolTheme.success : SchoolTheme.warning)
                }
                Text(plan.price)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite)
                Text(plan.detail)
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            Image(systemName: plan.isCurrent ? "checkmark.circle.fill" : "circle")
                .font(.title3.weight(.semibold))
                .foregroundStyle(plan.isCurrent ? SchoolTheme.success : SchoolTheme.muted.opacity(0.45))
        }
        .padding(12)
        .background(SchoolTheme.surface, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(plan.isCurrent ? SchoolTheme.success.opacity(0.35) : SchoolTheme.line, lineWidth: 1)
        }
    }

    private func select(_ plan: SubscriptionPlanSummary) {
        for index in plans.indices {
            plans[index].isCurrent = plans[index].id == plan.id
        }
        storeKitStatus = "Выбран продукт \(productId). Нажмите Купить для локальной проверки сценария."
    }

    private func storeKitRow(icon: String, color: Color, title: String, detail: String) -> some View {
        HStack(spacing: 12) {
            IconBadge(systemName: icon, color: color, size: 40)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SchoolTheme.muted)
                Text(detail)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
    }

    private func storeKitProductRow(_ product: StoreKitProductSnapshot) -> some View {
        HStack(alignment: .top, spacing: 12) {
            IconBadge(systemName: product.iconName, color: product.statusColor, size: 38)
            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(product.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SchoolTheme.graphite)
                        .fixedSize(horizontal: false, vertical: true)
                    StatusBadge(text: product.status, color: product.statusColor)
                }

                Text(product.productID)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                    .fixedSize(horizontal: false, vertical: true)

                Text(product.price)
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
    }

    private func storeKitEntitlementCard(_ entitlement: StoreKitEntitlementPreview) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("Entitlement")
                    .font(.headline)
                    .foregroundStyle(SchoolTheme.graphite)
                Spacer()
                StatusBadge(text: entitlement.state, color: moreColor(for: entitlement.colorName))
            }

            storeKitRow(
                icon: "checkmark.seal.fill",
                color: moreColor(for: entitlement.colorName),
                title: "Право доступа",
                detail: entitlement.aiAccess
            )

            storeKitRow(
                icon: "point.3.connected.trianglepath.dotted",
                color: SchoolTheme.accent,
                title: "Источник проверки",
                detail: entitlement.verificationSource
            )

            Text("\(entitlement.serverEndpoint) - \(entitlement.familyScope)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(2)
                .minimumScaleFactor(0.76)

            Text(entitlement.verificationPlan)
                .font(.caption)
                .foregroundStyle(SchoolTheme.muted)
                .fixedSize(horizontal: false, vertical: true)

            Text(entitlement.renewalPolicy)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(moreColor(for: entitlement.colorName))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func purchaseButton(_ title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
                .frame(maxWidth: .infinity, minHeight: 38)
                .background(color.opacity(0.11), in: Capsule())
        }
        .buttonStyle(.plain)
    }

    @MainActor
    private func loadStoreKitProducts() async {
        guard !isLoadingStoreKitProducts else {
            return
        }

        isLoadingStoreKitProducts = true
        storeKitCatalogStatus = "Запрашиваю продукты StoreKit 2 для текущего bundle id..."

        do {
            let products = try await fetchStoreKitProductsWithTimeout()
            storeKitProducts = StoreKitProductSnapshot.merge(products: products)

            if products.isEmpty {
                storeKitCatalogStatus = "StoreKit 2 ответил пустым каталогом: нужно добавить StoreKit Configuration или продукты App Store Connect."
            } else {
                storeKitCatalogStatus = "StoreKit 2 загрузил \(products.count) продукт(а); цены берутся из StoreKit, локальные строки станут fallback."
            }
        } catch {
            storeKitProducts = StoreKitProductSnapshot.failed(message: error.localizedDescription)
            storeKitCatalogStatus = "StoreKit 2 вернул ошибку: \(error.localizedDescription)"
        }

        isLoadingStoreKitProducts = false
    }

    private func fetchStoreKitProductsWithTimeout() async throws -> [Product] {
        try await withThrowingTaskGroup(of: [Product].self) { group in
            group.addTask {
                try await Product.products(for: StoreKitProductSnapshot.productIDs)
            }
            group.addTask {
                try await Task.sleep(nanoseconds: 1_000_000_000)
                return []
            }

            let products = try await group.next() ?? []
            group.cancelAll()
            return products
        }
    }

    private func purchaseLocally() {
        transactionId = "local-\(Int(Date.now.timeIntervalSince1970))"
        subscriptionExpires = currentPlan?.title == "Пробный период" ? "trial +14 дней" : "активна до следующего месяца"
        AppSubscriptionAccessStore.activate(planTitle: currentPlan?.title ?? "Пробный период")
        storeKitStatus = "Покупка принята локально: \(currentPlan?.title ?? "пробный период"). Настоящая проверка должна идти через StoreKit 2 Transaction.currentEntitlements."
    }

    private func restorePurchases() {
        restoreStatus = "Проверено локально: активен \(currentPlan?.title ?? "пробный период")"
        transactionId = "restored-local"
        AppSubscriptionAccessStore.activate(planTitle: currentPlan?.title ?? "Пробный период")
        storeKitStatus = "\(restoreStatus). В релизе нужно вызвать AppStore.sync() и проверить entitlement."
    }

    private func expireSubscription() {
        subscriptionExpires = "истекла"
        AppSubscriptionAccessStore.expireCurrentPlan()
        storeKitStatus = "Локально сымитирована истекшая подписка: платные AI-функции должны показать ограничение без потери данных."
    }

    private func failPurchase() {
        transactionId = "ошибка оплаты"
        storeKitStatus = "Локально сымитирована ошибка оплаты: показать понятную причину и оставить текущий тариф без изменений."
    }

    private func save() {
        AppSubscriptionAccessStore.saveCurrentPlan(currentPlan)
        onSave(plans)
        dismiss()
    }
}

private struct StoreKitProductSnapshot: Identifiable, Hashable {
    var id: String { productID }
    var title: String
    var productID: String
    var price: String
    var status: String
    var iconName: String

    var statusColor: Color {
        switch status {
        case "Найден":
            SchoolTheme.success
        case "Ошибка":
            SchoolTheme.danger
        case "Не найден":
            SchoolTheme.warning
        default:
            SchoolTheme.accent
        }
    }

    static let productIDs = [
        "school.class.family.monthly.child1",
        "school.class.family.monthly.extra_child"
    ]

    static let pending = [
        StoreKitProductSnapshot(
            title: "1 ребенок",
            productID: "school.class.family.monthly.child1",
            price: "149 руб./мес fallback",
            status: "Ожидает",
            iconName: "person.crop.circle.fill"
        ),
        StoreKitProductSnapshot(
            title: "Семья+",
            productID: "school.class.family.monthly.extra_child",
            price: "+59 руб./мес fallback",
            status: "Ожидает",
            iconName: "person.2.fill"
        )
    ]

    static func merge(products: [Product]) -> [StoreKitProductSnapshot] {
        pending.map { snapshot in
            guard let product = products.first(where: { $0.id == snapshot.productID }) else {
                var missing = snapshot
                missing.status = "Не найден"
                return missing
            }

            return StoreKitProductSnapshot(
                title: product.displayName.isEmpty ? snapshot.title : product.displayName,
                productID: product.id,
                price: product.displayPrice,
                status: "Найден",
                iconName: snapshot.iconName
            )
        }
    }

    static func failed(message: String) -> [StoreKitProductSnapshot] {
        pending.map { snapshot in
            var failed = snapshot
            failed.price = message.isEmpty ? "StoreKit ошибка" : message
            failed.status = "Ошибка"
            return failed
        }
    }
}

private struct StoreKitEntitlementPreview: Hashable {
    var state: String
    var productID: String
    var verificationSource: String
    var serverEndpoint: String
    var aiAccess: String
    var familyScope: String
    var verificationPlan: String
    var renewalPolicy: String
    var colorName: String

    static func make(planTitle: String, productID: String, transactionID: String, expires: String) -> StoreKitEntitlementPreview {
        if transactionID == "ошибка оплаты" {
            return StoreKitEntitlementPreview(
                state: "failed",
                productID: productID,
                verificationSource: "StoreKit purchase result",
                serverEndpoint: "GET /subscriptions/entitlement",
                aiAccess: "AI закрыт, текущий тариф не меняется",
                familyScope: "family entitlement unchanged",
                verificationPlan: "Покупка не должна менять локальный доступ, пока StoreKit не вернул verified transaction.",
                renewalPolicy: "Показать причину ошибки и оставить предыдущий entitlement",
                colorName: "red"
            )
        }

        if expires == "истекла" {
            return StoreKitEntitlementPreview(
                state: "expired",
                productID: productID,
                verificationSource: "Transaction.currentEntitlements",
                serverEndpoint: "GET /subscriptions/entitlement",
                aiAccess: "AI закрыт, данные семьи остаются доступны",
                familyScope: "family entitlement expired",
                verificationPlan: "Клиент должен убрать premium-флаг после expired/revoked entitlement и сохранить базовый доступ.",
                renewalPolicy: "Разрешить восстановление или повторную покупку без потери данных",
                colorName: "orange"
            )
        }

        if transactionID.hasPrefix("local-") || transactionID == "restored-local" {
            return StoreKitEntitlementPreview(
                state: "active-local",
                productID: productID,
                verificationSource: "StoreKit verified transaction + backend receipt check",
                serverEndpoint: "GET /subscriptions/entitlement",
                aiAccess: "AI открыт для текущей семьи",
                familyScope: planTitle == "Семья+" ? "family + extra child" : "family first child",
                verificationPlan: "В релизе сохранить только entitlement/status, сверить transaction id на backend и не хранить платежные данные.",
                renewalPolicy: "Переход в billing retry/expired должен закрыть premium без удаления локальных данных",
                colorName: "green"
            )
        }

        return StoreKitEntitlementPreview(
            state: "trial-local",
            productID: productID,
            verificationSource: "local trial, then StoreKit entitlement",
            serverEndpoint: "GET /subscriptions/entitlement",
            aiAccess: "AI открыт в рамках trial-сценария",
            familyScope: "family trial",
            verificationPlan: "После подключения StoreKit trial должен сверяться с backend entitlement и App Store Server Notifications.",
            renewalPolicy: "За 2 дня до окончания показать мягкое продление, без блокировки базовых данных",
            colorName: "blue"
        )
    }
}

private struct NotificationSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: ([NotificationPreference], NotificationSettingsState) -> Void

    @State private var preferences: [NotificationPreference]
    @State private var settings: NotificationSettingsState
    @State private var testStatus = "Тестовый дайджест не отправлялся"
    @State private var scheduledPreview: [String] = []

    init(
        preferences: [NotificationPreference],
        settings: NotificationSettingsState,
        onSave: @escaping ([NotificationPreference], NotificationSettingsState) -> Void
    ) {
        self.onSave = onSave
        _preferences = State(initialValue: preferences)
        _settings = State(initialValue: settings)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    MoreSheetHeader(
                        icon: "bell.fill",
                        color: SchoolTheme.success,
                        title: "Уведомления",
                        subtitle: "Дайджесты, дедлайны, срочное и тихие часы"
                    )

                    DashboardCard {
                        HStack(spacing: 12) {
                            MoreMetric(value: "\(enabledCount)", title: "включено", color: SchoolTheme.success)
                            Divider()
                            MoreMetric(value: "\(settings.scheduledCount)", title: "iOS", color: SchoolTheme.accent)
                            Divider()
                            MoreMetric(value: settings.quietHoursEnabled ? "да" : "нет", title: "тихий режим", color: SchoolTheme.teal)
                        }
                        .frame(height: 62)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Доставка iOS")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            notificationStateRow(
                                icon: "checkmark.shield.fill",
                                color: SchoolTheme.success,
                                title: "Разрешение",
                                detail: settings.permissionStatus
                            )
                            notificationStateRow(
                                icon: "calendar.badge.clock",
                                color: SchoolTheme.accent,
                                title: "Расписание",
                                detail: settings.deliveryStatus
                            )

                            HStack(spacing: 8) {
                                notificationActionButton("Разрешить", icon: "bell.badge.fill", color: SchoolTheme.success) {
                                    requestPermission()
                                }
                                notificationActionButton("Тест", icon: "paperplane.fill", color: SchoolTheme.accent) {
                                    sendTestNotification()
                                }
                            }

                            notificationActionButton("Запланировать дайджесты", icon: "calendar.badge.plus", color: SchoolTheme.warning) {
                                scheduleEnabledNotifications()
                            }

                            apnsReadinessCard(APNsReadiness.make(settings: settings, enabledCount: enabledCount))

                            if !scheduledPreview.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("В очереди iOS")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(SchoolTheme.muted)
                                    ForEach(scheduledPreview, id: \.self) { item in
                                        Label(item, systemImage: "checkmark.circle.fill")
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(SchoolTheme.success)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 2)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Что присылать")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            ForEach($preferences) { $preference in
                                NotificationPreferenceRow(preference: $preference)
                            }
                        }
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Время дайджестов")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            Text("Вечер")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(SchoolTheme.muted)
                            Picker("Вечер", selection: $settings.eveningTime) {
                                Text("19:30").tag("19:30")
                                Text("20:30").tag("20:30")
                                Text("21:30").tag("21:30")
                            }
                            .pickerStyle(.segmented)

                            Text("Утро")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(SchoolTheme.muted)
                            Picker("Утро", selection: $settings.morningTime) {
                                Text("07:00").tag("07:00")
                                Text("07:15").tag("07:15")
                                Text("07:30").tag("07:30")
                            }
                            .pickerStyle(.segmented)
                        }
                    }

                    DashboardCard {
                        VStack(spacing: 12) {
                            Toggle(isOn: $settings.quietHoursEnabled) {
                                HStack(spacing: 12) {
                                    IconBadge(systemName: "moon.zzz.fill", color: SchoolTheme.teal, size: 40)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Тихие часы")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(SchoolTheme.graphite)
                                        Text("Срочное остается, обычные напоминания ждут утра")
                                            .font(.caption)
                                            .foregroundStyle(SchoolTheme.muted)
                                    }
                                }
                            }
                            .tint(SchoolTheme.success)

                            HStack(spacing: 10) {
                                MoreTextField(title: "Начало", iconName: "moon.fill", color: SchoolTheme.teal, text: $settings.quietStart)
                                MoreTextField(title: "Конец", iconName: "sunrise.fill", color: SchoolTheme.warning, text: $settings.quietEnd)
                            }
                            .disabled(!settings.quietHoursEnabled)
                            .opacity(settings.quietHoursEnabled ? 1 : 0.45)
                        }
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Проверка")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)
                            Text(testStatus)
                                .font(.caption)
                                .foregroundStyle(SchoolTheme.muted)

                            Button {
                                scheduleEnabledNotifications()
                            } label: {
                                Label("Пересобрать расписание", systemImage: "arrow.clockwise")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity, minHeight: 46)
                            }
                            .buttonStyle(.bordered)
                            .tint(SchoolTheme.accent)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button {
                        save()
                    } label: {
                        Label("Сохранить уведомления", systemImage: "checkmark")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 52)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(SchoolTheme.success)
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Уведомления")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        save()
                    }
                }
                KeyboardDoneToolbar()
            }
            .task {
                if ProcessInfo.processInfo.arguments.contains("-qa-more-notifications") {
                    scheduleEnabledNotifications()
                    return
                }

                await refreshNotificationStatus()
            }
        }
    }

    private var enabledCount: Int {
        preferences.filter(\.isEnabled).count
    }

    private func notificationStateRow(icon: String, color: Color, title: String, detail: String) -> some View {
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

    private func notificationActionButton(_ title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
                .frame(maxWidth: .infinity, minHeight: 38)
                .background(color.opacity(0.11), in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private func apnsReadinessCard(_ readiness: APNsReadiness) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Label("APNs readiness", systemImage: "antenna.radiowaves.left.and.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(SchoolTheme.graphite)
                Spacer()
                StatusBadge(text: readiness.status, color: SchoolTheme.warning)
            }

            Text(readiness.tokenEndpoint)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text(readiness.dispatchEndpoint)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text(readiness.routingRule)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .fixedSize(horizontal: false, vertical: true)

            Text(readiness.quietHoursRule)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.warning)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(10)
        .background(SchoolTheme.warning.opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func requestPermission() {
        Task {
            do {
                let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
                await MainActor.run {
                    settings.permissionStatus = granted ? "Разрешено iOS: alert, badge, sound" : "Пользователь отказал в уведомлениях"
                    testStatus = granted ? "Можно планировать локальные напоминания" : "Открой настройки iOS, если захочешь включить позже"
                }
            } catch {
                await MainActor.run {
                    settings.permissionStatus = "Ошибка запроса: \(error.localizedDescription)"
                    testStatus = "Не удалось запросить разрешение"
                }
            }
        }
    }

    private func sendTestNotification() {
        Task {
            let content = UNMutableNotificationContent()
            content.title = "Школьный класс"
            content.body = "Тест: завтра математика, форма и одно дело для родителя"
            content.sound = .default

            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest(identifier: "school.test.digest", content: content, trigger: trigger)

            do {
                try await UNUserNotificationCenter.current().add(request)
                await MainActor.run {
                    settings.deliveryStatus = "Тестовое уведомление запланировано через 5 секунд"
                    testStatus = "Тест отправлен в iOS Notification Center"
                }
                await refreshNotificationStatus()
            } catch {
                await MainActor.run {
                    settings.deliveryStatus = "Ошибка теста: \(error.localizedDescription)"
                    testStatus = "Проверь разрешение уведомлений"
                }
            }
        }
    }

    private func scheduleEnabledNotifications() {
        Task {
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: NotificationSettingsState.scheduledIdentifiers)

            var requests: [UNNotificationRequest] = []
            var preview: [String] = []

            if preferences.contains(where: { $0.title == "Вечерний дайджест" && $0.isEnabled }) {
                requests.append(calendarRequest(
                    identifier: "school.digest.evening",
                    title: "Что завтра",
                    body: "Проверь уроки, ДЗ, форму и что нужно принести",
                    time: settings.eveningTime
                ))
                preview.append("Вечерний дайджест в \(settings.eveningTime)")
            }

            if preferences.contains(where: { $0.title == "Утренний дайджест" && $0.isEnabled }) {
                requests.append(calendarRequest(
                    identifier: "school.digest.morning",
                    title: "Перед школой",
                    body: "Расписание, срочное и семейные задачи на утро",
                    time: settings.morningTime
                ))
                preview.append("Утренний дайджест в \(settings.morningTime)")
            }

            if preferences.contains(where: { $0.title == "Срочные объявления" && $0.isEnabled }) {
                requests.append(timeIntervalRequest(
                    identifier: "school.urgent.announcement",
                    title: "Срочное объявление",
                    body: "Учитель отметил важное сообщение. Открой раздел Сегодня",
                    seconds: 60,
                    sound: .default
                ))
                preview.append("Срочное объявление отдельным сигналом")
            }

            if preferences.contains(where: { $0.title == "Дедлайны оплат" && $0.isEnabled }) {
                requests.append(calendarRequest(
                    identifier: "school.collection.deadline",
                    title: "Сбор класса",
                    body: "Проверь срок оплаты и чек в разделе Класс",
                    time: settings.quietHoursEnabled ? settings.quietEnd : settings.eveningTime
                ))
                preview.append("Дедлайн оплаты в \(settings.quietHoursEnabled ? settings.quietEnd : settings.eveningTime)")
            }

            if preferences.contains(where: { $0.title == "Семейные задачи" && $0.isEnabled }) {
                requests.append(calendarRequest(
                    identifier: "school.family.task",
                    title: "Семейная задача",
                    body: "Проверь, кто отвечает за принести, подписать или оплатить",
                    time: settings.quietHoursEnabled ? settings.quietEnd : settings.eveningTime
                ))
                preview.append("Семейные задачи в \(settings.quietHoursEnabled ? settings.quietEnd : settings.eveningTime)")
            }

            do {
                for request in requests {
                    try await center.add(request)
                }
                await MainActor.run {
                    settings.scheduledCount = requests.count
                    settings.deliveryStatus = requests.isEmpty ? "Нет включенных сценариев для расписания" : "Запланировано локально: \(requests.count) уведомления"
                    scheduledPreview = preview
                    testStatus = "Расписание iOS обновлено"
                }
                await refreshNotificationStatus()
            } catch {
                await MainActor.run {
                    settings.deliveryStatus = "Ошибка расписания: \(error.localizedDescription)"
                    testStatus = "Не удалось обновить расписание iOS"
                }
            }
        }
    }

    private func calendarRequest(identifier: String, title: String, body: String, time: String) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let parts = time.split(separator: ":").compactMap { Int($0) }
        var dateComponents = DateComponents()
        dateComponents.hour = parts.first ?? 20
        dateComponents.minute = parts.dropFirst().first ?? 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        return UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    }

    private func timeIntervalRequest(identifier: String, title: String, body: String, seconds: TimeInterval, sound: UNNotificationSound) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = sound
        content.interruptionLevel = .timeSensitive

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        return UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
    }

    @MainActor
    private func updateAuthorizationStatus(_ status: UNAuthorizationStatus) {
        switch status {
        case .authorized:
            settings.permissionStatus = "Разрешено iOS"
        case .denied:
            settings.permissionStatus = "Запрещено в настройках iOS"
        case .notDetermined:
            settings.permissionStatus = "Разрешение iOS еще не запрашивалось"
        case .provisional:
            settings.permissionStatus = "Временное разрешение iOS"
        case .ephemeral:
            settings.permissionStatus = "Временная сессия iOS"
        @unknown default:
            settings.permissionStatus = "Неизвестный статус iOS"
        }
    }

    private func refreshNotificationStatus() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        let pending = await center.pendingNotificationRequests()

        await MainActor.run {
            updateAuthorizationStatus(settings.authorizationStatus)
            self.settings.scheduledCount = pending.filter { $0.identifier.hasPrefix("school.") }.count
            self.scheduledPreview = pending
                .filter { NotificationSettingsState.scheduledIdentifiers.contains($0.identifier) }
                .sorted { $0.identifier < $1.identifier }
                .map { notificationTitle(for: $0.identifier) }
            if self.settings.scheduledCount > 0 {
                self.settings.deliveryStatus = "В iOS ожидают \(self.settings.scheduledCount) локальных уведомления"
            }
        }
    }

    private func notificationTitle(for identifier: String) -> String {
        switch identifier {
        case "school.digest.evening":
            "Вечерний дайджест в \(settings.eveningTime)"
        case "school.digest.morning":
            "Утренний дайджест в \(settings.morningTime)"
        case "school.collection.deadline":
            "Дедлайн оплаты"
        case "school.urgent.announcement":
            "Срочное объявление отдельным сигналом"
        case "school.family.task":
            "Семейные задачи"
        default:
            "Локальное уведомление"
        }
    }

    private func save() {
        onSave(preferences, settings)
        dismiss()
    }
}

private struct APNsReadiness: Hashable {
    var status: String
    var tokenEndpoint: String
    var dispatchEndpoint: String
    var routingRule: String
    var quietHoursRule: String

    static func make(settings: NotificationSettingsState, enabledCount: Int) -> APNsReadiness {
        APNsReadiness(
            status: "backend gate",
            tokenEndpoint: "POST /devices/push-token",
            dispatchEndpoint: "POST /notifications/dispatch-preview",
            routingRule: "Server routes \(enabledCount) enabled channels by child/class/family role and stores per-device opt-outs.",
            quietHoursRule: settings.quietHoursEnabled
                ? "Quiet hours \(settings.quietStart)-\(settings.quietEnd); urgent announcements bypass as time-sensitive."
                : "Quiet hours disabled; backend still must rate-limit urgent and payment reminders."
        )
    }
}

private struct ClassMemorySheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: ([ClassMemoryEntry]) -> Void

    @State private var entries: [ClassMemoryEntry]
    @State private var searchText = ""
    @State private var newTitle = "Фото с экскурсии"
    @State private var newDetail = "Добавить в память класса и связать с событием"
    @State private var newTag = "Фото"

    private let tags = ["Фото", "Событие", "Объявление", "Файл"]

    init(entries: [ClassMemoryEntry], onSave: @escaping ([ClassMemoryEntry]) -> Void) {
        self.onSave = onSave
        _entries = State(initialValue: entries)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    MoreSheetHeader(
                        icon: "magnifyingglass",
                        color: SchoolTheme.accent,
                        title: "Память класса",
                        subtitle: "Поиск по объявлениям, событиям, файлам и важным решениям"
                    )

                    DashboardCard {
                        HStack(spacing: 12) {
                            MoreMetric(value: "\(entries.count)", title: "записей", color: SchoolTheme.accent)
                            Divider()
                            MoreMetric(value: "\(Set(entries.map(\.tag)).count)", title: "типов", color: SchoolTheme.teal)
                            Divider()
                            MoreMetric(value: "\(filteredEntries.count)", title: "найдено", color: SchoolTheme.success)
                        }
                        .frame(height: 62)
                    }

                    DashboardCard {
                        VStack(spacing: 12) {
                            MoreTextField(title: "Поиск", iconName: "magnifyingglass", color: SchoolTheme.accent, text: $searchText)

                            if filteredEntries.isEmpty {
                                MoreEmptyState(
                                    icon: "tray.fill",
                                    title: "Ничего не найдено",
                                    detail: "Попробуй другое слово: событие, чек, согласие или объявление"
                                )
                            } else {
                                ForEach(filteredEntries) { entry in
                                    memoryRow(entry)
                                }
                            }
                        }
                    }

                    DashboardCard {
                        VStack(spacing: 12) {
                            Text("Добавить в память")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            MoreTextField(title: "Название", iconName: "text.badge.plus", color: SchoolTheme.success, text: $newTitle)
                            MoreTextField(title: "Описание", iconName: "note.text", color: SchoolTheme.accent, text: $newDetail)

                            Picker("Тип", selection: $newTag) {
                                ForEach(tags, id: \.self) { tag in
                                    Text(tag).tag(tag)
                                }
                            }
                            .pickerStyle(.segmented)

                            Button {
                                addEntry()
                            } label: {
                                Label("Добавить запись", systemImage: "plus")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity, minHeight: 46)
                            }
                            .buttonStyle(.bordered)
                            .tint(SchoolTheme.success)
                            .disabled(newTitle.trimmed.isEmpty || newDetail.trimmed.isEmpty)
                        }
                    }

                    Button {
                        save()
                    } label: {
                        Label("Сохранить память", systemImage: "checkmark")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 52)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(SchoolTheme.success)
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Память класса")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        save()
                    }
                }
                KeyboardDoneToolbar()
            }
        }
    }

    private var filteredEntries: [ClassMemoryEntry] {
        let query = searchText.trimmed.lowercased()
        guard !query.isEmpty else {
            return entries
        }

        return entries.filter { entry in
            [entry.title, entry.detail, entry.source, entry.dateLabel, entry.tag]
                .joined(separator: " ")
                .lowercased()
                .contains(query)
        }
    }

    private func memoryRow(_ entry: ClassMemoryEntry) -> some View {
        HStack(alignment: .top, spacing: 12) {
            IconBadge(systemName: entry.iconName, color: moreColor(for: entry.colorName), size: 42)
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 7) {
                    Text(entry.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SchoolTheme.graphite)
                    StatusBadge(text: entry.tag, color: moreColor(for: entry.colorName))
                }
                Text(entry.detail)
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
                Text("\(entry.source) - \(entry.dateLabel)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SchoolTheme.success)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func addEntry() {
        entries.insert(
            ClassMemoryEntry(
                title: newTitle.trimmed,
                detail: newDetail.trimmed,
                source: "Добавлено вручную",
                dateLabel: "сегодня",
                tag: newTag,
                iconName: iconName(for: newTag),
                colorName: colorName(for: newTag)
            ),
            at: 0
        )
        newTitle = ""
        newDetail = ""
    }

    private func iconName(for tag: String) -> String {
        switch tag {
        case "Фото":
            "photo.fill"
        case "Событие":
            "calendar.badge.clock"
        case "Объявление":
            "megaphone.fill"
        default:
            "doc.text.fill"
        }
    }

    private func colorName(for tag: String) -> String {
        switch tag {
        case "Фото", "Файл":
            "teal"
        case "Объявление":
            "orange"
        default:
            "blue"
        }
    }

    private func save() {
        onSave(entries)
        dismiss()
    }
}

private struct ClassFilesSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: ([ClassFileSummary]) -> Void

    @State private var files: [ClassFileSummary]
    @State private var searchText = ""
    @State private var selectedFilter = "Все"
    @State private var newTitle = "Согласие на экскурсию.pdf"
    @State private var newDetail = "Документ для родителей 3Б"
    @State private var newCategory = "Согласия"
    @State private var importStatus = "Файл пока не выбран"
    @State private var isFileImporterVisible = ProcessInfo.processInfo.arguments.contains("-qa-more-files-importer")

    private let filters = ["Все", "Согласия", "Чеки", "Материалы"]
    private let categories = ["Согласия", "Чеки", "Материалы"]

    init(files: [ClassFileSummary], onSave: @escaping ([ClassFileSummary]) -> Void) {
        self.onSave = onSave
        _files = State(initialValue: files)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    MoreSheetHeader(
                        icon: "folder.fill",
                        color: SchoolTheme.teal,
                        title: "Файлы",
                        subtitle: "Согласия, чеки, материалы и документы класса"
                    )

                    DashboardCard {
                        HStack(spacing: 12) {
                            MoreMetric(value: "\(files.count)", title: "файлов", color: SchoolTheme.teal)
                            Divider()
                            MoreMetric(value: "\(Set(files.map(\.category)).count)", title: "папки", color: SchoolTheme.accent)
                            Divider()
                            MoreMetric(value: "\(actionNeededCount)", title: "дела", color: SchoolTheme.warning)
                        }
                        .frame(height: 62)
                    }

                    DashboardCard {
                        VStack(spacing: 12) {
                            MoreTextField(title: "Поиск файла", iconName: "magnifyingglass", color: SchoolTheme.accent, text: $searchText)

                            Picker("Папка", selection: $selectedFilter) {
                                ForEach(filters, id: \.self) { filter in
                                    Text(filter).tag(filter)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Документы")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            if filteredFiles.isEmpty {
                                MoreEmptyState(
                                    icon: "folder.badge.questionmark",
                                    title: "Файлов нет",
                                    detail: "В этой папке пока ничего не найдено"
                                )
                            } else {
                                ForEach(filteredFiles) { file in
                                    fileRow(file)
                                }
                            }
                        }
                    }

                    DashboardCard {
                        VStack(spacing: 12) {
                            Text("Добавить файл")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            MoreTextField(title: "Название", iconName: "doc.badge.plus", color: SchoolTheme.success, text: $newTitle)
                            MoreTextField(title: "Описание", iconName: "note.text", color: SchoolTheme.accent, text: $newDetail)

                            Picker("Категория", selection: $newCategory) {
                                ForEach(categories, id: \.self) { category in
                                    Text(category).tag(category)
                                }
                            }
                            .pickerStyle(.segmented)

                            Text(importStatus)
                                .font(.caption)
                                .foregroundStyle(SchoolTheme.muted)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            HStack(spacing: 10) {
                                Button {
                                    isFileImporterVisible = true
                                } label: {
                                    Label("Выбрать", systemImage: "paperclip")
                                        .frame(maxWidth: .infinity, minHeight: 44)
                                }
                                .buttonStyle(.bordered)
                                .tint(SchoolTheme.accent)

                                Button {
                                    addManualFile()
                                } label: {
                                    Label("Добавить", systemImage: "plus")
                                        .frame(maxWidth: .infinity, minHeight: 44)
                                }
                                .buttonStyle(.bordered)
                                .tint(SchoolTheme.success)
                                .disabled(newTitle.trimmed.isEmpty || newDetail.trimmed.isEmpty)
                            }
                        }
                    }

                    Button {
                        save()
                    } label: {
                        Label("Сохранить файлы", systemImage: "checkmark")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 52)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(SchoolTheme.success)
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Файлы")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        save()
                    }
                }
                KeyboardDoneToolbar()
            }
            .fileImporter(
                isPresented: $isFileImporterVisible,
                allowedContentTypes: [.item],
                allowsMultipleSelection: true
            ) { result in
                handleFileImport(result)
            }
        }
    }

    private var filteredFiles: [ClassFileSummary] {
        let query = searchText.trimmed.lowercased()
        return files.filter { file in
            let matchesFilter = selectedFilter == "Все" || file.category == selectedFilter
            let searchableText = [file.title, file.detail, file.category, file.owner, file.status]
                .joined(separator: " ")
                .lowercased()
            let matchesSearch = query.isEmpty || searchableText.contains(query)
            return matchesFilter && matchesSearch
        }
    }

    private var actionNeededCount: Int {
        files.filter { file in
            file.status.contains("Нужно") || file.status.contains("Ожидает")
        }.count
    }

    private func fileRow(_ file: ClassFileSummary) -> some View {
        HStack(alignment: .top, spacing: 12) {
            IconBadge(systemName: file.iconName, color: moreColor(for: file.colorName), size: 42)
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 7) {
                    Text(file.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SchoolTheme.graphite)
                    StatusBadge(text: file.category, color: moreColor(for: file.colorName))
                }
                Text(file.detail)
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
                Text("\(file.owner) - \(file.updatedLabel)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SchoolTheme.muted)
                Text(file.status)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(statusColor(for: file.status))
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func addManualFile() {
        files.insert(
            ClassFileSummary(
                title: newTitle.trimmed,
                detail: newDetail.trimmed,
                category: newCategory,
                owner: "Владимир",
                updatedLabel: "сегодня",
                status: "Локально",
                iconName: iconName(for: newCategory),
                colorName: colorName(for: newCategory)
            ),
            at: 0
        )
        importStatus = "Добавлена запись: \(newTitle.trimmed)"
        newTitle = ""
        newDetail = ""
    }

    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard !urls.isEmpty else {
                importStatus = "Файл не выбран"
                return
            }

            for url in urls {
                files.insert(
                    ClassFileSummary(
                        title: url.lastPathComponent,
                        detail: "Добавлен через системный выбор файла",
                        category: newCategory,
                        owner: "Владимир",
                        updatedLabel: "сегодня",
                        status: "Локально",
                        iconName: iconName(for: newCategory),
                        colorName: colorName(for: newCategory)
                    ),
                    at: 0
                )
            }

            importStatus = "Добавлено файлов: \(urls.count)"
        case .failure:
            importStatus = "Не удалось добавить файл"
        }
    }

    private func iconName(for category: String) -> String {
        switch category {
        case "Чеки":
            "receipt.fill"
        case "Материалы":
            "photo.on.rectangle.angled"
        default:
            "doc.text.fill"
        }
    }

    private func colorName(for category: String) -> String {
        switch category {
        case "Чеки":
            "green"
        case "Материалы":
            "teal"
        default:
            "blue"
        }
    }

    private func statusColor(for status: String) -> Color {
        if status.contains("Нужно") || status.contains("Ожидает") {
            return SchoolTheme.warning
        }

        if status.contains("Проверено") || status.contains("Локально") {
            return SchoolTheme.success
        }

        return SchoolTheme.muted
    }

    private func save() {
        onSave(files)
        dismiss()
    }
}

private struct SecuritySettingsSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: (SecuritySettingsState) -> Void

    @State private var settings: SecuritySettingsState

    init(settings: SecuritySettingsState, onSave: @escaping (SecuritySettingsState) -> Void) {
        self.onSave = onSave
        _settings = State(initialValue: settings)
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        MoreSheetHeader(
                            icon: "lock.shield.fill",
                            color: SchoolTheme.success,
                            title: "Безопасность",
                            subtitle: "Данные детей, закрытый класс и семейные доступы"
                        )

                        DashboardCard {
                            HStack(spacing: 12) {
                                MoreMetric(value: "\(enabledCount)", title: "защиты", color: SchoolTheme.success)
                                Divider()
                                MoreMetric(value: settings.closedClassOnly ? "да" : "нет", title: "закрытый", color: SchoolTheme.accent)
                                Divider()
                                MoreMetric(value: settings.requireInviteApproval ? "да" : "нет", title: "входы", color: SchoolTheme.teal)
                            }
                            .frame(height: 62)
                        }

                        DashboardCard {
                            VStack(spacing: 14) {
                                securityToggle(
                                    title: "Только участники класса",
                                    detail: "Материалы и файлы видят только подключенные семьи",
                                    icon: "person.3.fill",
                                    color: SchoolTheme.success,
                                    isOn: $settings.closedClassOnly
                                )

                                Divider()

                                securityToggle(
                                    title: "Скрывать финансы",
                                    detail: "Бабушка и няня видят задачи без сумм сборов",
                                    icon: "rublesign.circle.fill",
                                    color: SchoolTheme.warning,
                                    isOn: $settings.maskFinanceForFamily
                                )

                                Divider()

                                securityToggle(
                                    title: "Подтверждать входы",
                                    detail: "Новые приглашения ждут одобрения администратора",
                                    icon: "checkmark.shield.fill",
                                    color: SchoolTheme.accent,
                                    isOn: $settings.requireInviteApproval
                                )
                            }
                        }

                        DashboardCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Удаление данных")
                                    .font(.headline)
                                    .foregroundStyle(SchoolTheme.graphite)

                                deletionRow(
                                    icon: "square.and.arrow.up.fill",
                                    color: SchoolTheme.accent,
                                    title: "Экспорт перед удалением",
                                    detail: settings.exportStatus
                                )

                                Button {
                                    settings.exportStatus = MoreLocalStore.localExportSummary()
                                } label: {
                                    Label("Подготовить экспорт", systemImage: "square.and.arrow.up")
                                        .font(.subheadline.weight(.semibold))
                                        .frame(maxWidth: .infinity, minHeight: 44)
                                }
                                .buttonStyle(.bordered)
                                .tint(SchoolTheme.accent)

                                serverDeletionReadinessCard(ServerDeletionReadiness.make(scope: settings.deleteScope))

                                Divider()

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Что удалить")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(SchoolTheme.muted)

                                    Menu {
                                        ForEach(deleteScopes, id: \.self) { scope in
                                            Button(scope) {
                                                settings.deleteScope = scope
                                            }
                                        }
                                    } label: {
                                        HStack(spacing: 12) {
                                            IconBadge(systemName: "trash.fill", color: SchoolTheme.danger, size: 38)
                                            VStack(alignment: .leading, spacing: 3) {
                                                Text(settings.deleteScope)
                                                    .font(.subheadline.weight(.semibold))
                                                    .foregroundStyle(SchoolTheme.graphite)
                                                    .fixedSize(horizontal: false, vertical: true)
                                                Text("В MVP очищается локальное хранилище, серверное удаление появится с backend")
                                                    .font(.caption)
                                                    .foregroundStyle(SchoolTheme.muted)
                                                    .fixedSize(horizontal: false, vertical: true)
                                            }
                                            Spacer()
                                            Image(systemName: "chevron.down")
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

                                MoreTextField(
                                    title: "Подтверждение",
                                    iconName: "keyboard.fill",
                                    color: confirmationReady ? SchoolTheme.success : SchoolTheme.warning,
                                    text: $settings.deleteConfirmation
                                )

                                Text(settings.deleteRequestStatus)
                                    .font(.caption)
                                    .foregroundStyle(SchoolTheme.muted)
                                    .fixedSize(horizontal: false, vertical: true)

                                deletionLifecycleCard
                                    .id("deletion-lifecycle")

                                Button {
                                    prepareDeletionRequest()
                                } label: {
                                    Label("Подготовить заявку на удаление", systemImage: "trash.fill")
                                        .font(.subheadline.weight(.semibold))
                                        .frame(maxWidth: .infinity, minHeight: 44)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(SchoolTheme.danger)
                                .disabled(!confirmationReady)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        Button {
                            save()
                        } label: {
                            Label("Сохранить безопасность", systemImage: "checkmark")
                                .font(.headline)
                                .frame(maxWidth: .infinity, minHeight: 52)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(SchoolTheme.success)
                    }
                    .padding(20)
                    .padding(.bottom, 20)
                }
                .scrollDismissesKeyboard(.interactively)
                .onAppear {
                    guard ProcessInfo.processInfo.arguments.contains("-qa-more-security-lifecycle") else { return }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.snappy) {
                            proxy.scrollTo("deletion-lifecycle", anchor: .center)
                        }
                    }
                }
            }
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Безопасность")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        save()
                    }
                }
                KeyboardDoneToolbar()
            }
        }
    }

    private var enabledCount: Int {
        [
            settings.closedClassOnly,
            settings.maskFinanceForFamily,
            settings.requireInviteApproval
        ].filter { $0 }.count
    }

    private var deleteScopes: [String] {
        [
            "Аккаунт и личные данные",
            "Профиль ребенка",
            "Семейные доступы",
            "Локальные файлы и чеки",
            "Все локальные данные"
        ]
    }

    private var confirmationReady: Bool {
        settings.deleteConfirmation.trimmed.uppercased() == "УДАЛИТЬ"
    }

    private var cancelReady: Bool {
        settings.deletionCanCancel && settings.deletionReauthCode.trimmed == "1234"
    }

    private var deletionLifecycleCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Label("Статус заявки", systemImage: "clock.badge.checkmark")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(SchoolTheme.graphite)
                Spacer()
                StatusBadge(
                    text: settings.deletionCanCancel ? "можно отменить" : "нет активной",
                    color: settings.deletionCanCancel ? SchoolTheme.success : SchoolTheme.muted
                )
            }

            deletionLifecycleRow(title: "requestId", value: settings.deletionRequestId.isEmpty ? "заявка не создана" : settings.deletionRequestId)
            deletionLifecycleRow(title: "grace period", value: settings.deletionGracePeriod)
            deletionLifecycleRow(title: "cancel", value: settings.deletionCancelStatus)

            MoreTextField(
                title: "Код повторного входа",
                iconName: "key.fill",
                color: cancelReady ? SchoolTheme.success : SchoolTheme.warning,
                text: $settings.deletionReauthCode
            )

            Button {
                cancelDeletionRequest()
            } label: {
                Label("Отменить заявку", systemImage: "arrow.uturn.backward.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: 42)
            }
            .buttonStyle(.bordered)
            .tint(SchoolTheme.success)
            .disabled(!cancelReady)
        }
        .padding(10)
        .background(SchoolTheme.success.opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func deletionLifecycleRow(title: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(title)
                .font(.caption2.weight(.bold))
                .foregroundStyle(SchoolTheme.muted)
                .frame(width: 76, alignment: .leading)
            Text(value)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.graphite.opacity(0.78))
                .lineLimit(2)
                .minimumScaleFactor(0.78)
            Spacer(minLength: 0)
        }
    }

    private func deletionRow(icon: String, color: Color, title: String, detail: String) -> some View {
        HStack(spacing: 12) {
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

    private func serverDeletionReadinessCard(_ readiness: ServerDeletionReadiness) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Label("Server deletion", systemImage: "server.rack")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(SchoolTheme.graphite)
                Spacer()
                StatusBadge(text: readiness.status, color: SchoolTheme.warning)
            }

            Text(readiness.exportEndpoint)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text(readiness.deleteEndpoint)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text(readiness.statusEndpoint)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text(readiness.cancelEndpoint)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text(readiness.auditRule)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .fixedSize(horizontal: false, vertical: true)

            Text(readiness.gracePeriod)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.warning)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(10)
        .background(SchoolTheme.warning.opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func securityToggle(
        title: String,
        detail: String,
        icon: String,
        color: Color,
        isOn: Binding<Bool>
    ) -> some View {
        Toggle(isOn: isOn) {
            HStack(spacing: 12) {
                IconBadge(systemName: icon, color: color, size: 42)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SchoolTheme.graphite)
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(SchoolTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .tint(SchoolTheme.success)
    }

    private func save() {
        onSave(settings)
        dismiss()
    }

    private func prepareDeletionRequest() {
        let requestId = "del-\(UUID().uuidString.prefix(8).lowercased())"
        let now = Date.now.formatted(date: .numeric, time: .shortened)
        let graceEnds = Calendar.current.date(byAdding: .day, value: 7, to: Date.now) ?? Date.now

        settings.deleteRequestStatus = MoreLocalStore.performLocalDeletion(scope: settings.deleteScope)
        settings.deletionRequestId = requestId
        settings.deletionGracePeriod = "До \(graceEnds.formatted(date: .numeric, time: .shortened)); создано \(now)"
        settings.deletionCanCancel = true
        settings.deletionCancelStatus = "Ожидает повторный вход: локальный код 1234"
        settings.deleteConfirmation = ""
        settings.deletionReauthCode = ""

        MoreLocalStore.recordAudit(
            AuditLogEntry(
                title: "Создана заявка удаления",
                detail: "Scope: \(settings.deleteScope), requestId: \(requestId), отмена доступна до конца grace period",
                actor: "Локальный пользователь",
                target: settings.deleteScope,
                category: "Приватность",
                status: "Локально",
                timestampLabel: "сейчас",
                iconName: "trash.fill",
                colorName: "red"
            )
        )
    }

    private func cancelDeletionRequest() {
        guard cancelReady else { return }

        settings.deletionCanCancel = false
        settings.deletionCancelStatus = "Заявка отменена локально после повторного входа"
        settings.deleteRequestStatus = "Удаление отменено: серверный MVP должен восстановить доступы в рамках scope и записать AuditLog"
        settings.deletionReauthCode = ""

        MoreLocalStore.recordAudit(
            AuditLogEntry(
                title: "Отменена заявка удаления",
                detail: "RequestId: \(settings.deletionRequestId.isEmpty ? "local" : settings.deletionRequestId), повторный вход подтвержден",
                actor: "Локальный пользователь",
                target: settings.deleteScope,
                category: "Приватность",
                status: "Локально",
                timestampLabel: "сейчас",
                iconName: "arrow.uturn.backward.circle.fill",
                colorName: "green"
            )
        )
    }
}

private struct ServerDeletionReadiness: Hashable {
    var status: String
    var exportEndpoint: String
    var deleteEndpoint: String
    var statusEndpoint: String
    var cancelEndpoint: String
    var auditRule: String
    var gracePeriod: String

    static func make(scope: String) -> ServerDeletionReadiness {
        let serverScope: String
        switch scope {
        case "Профиль ребенка":
            serverScope = "child_profile"
        case "Семейные доступы":
            serverScope = "family_access"
        case "Локальные файлы и чеки":
            serverScope = "files_receipts"
        case "Все локальные данные":
            serverScope = "all_local_and_server_data"
        default:
            serverScope = "account_personal_data"
        }

        return ServerDeletionReadiness(
            status: "backend gate",
            exportEndpoint: "GET /me/export?scope=\(serverScope)",
            deleteEndpoint: "POST /me/deletion-requests",
            statusEndpoint: "GET /me/deletion-requests/{requestId}",
            cancelEndpoint: "POST /me/deletion-requests/{requestId}/cancel",
            auditRule: "Backend must verify session, write AuditLog for create/cancel and revoke or restore class/family access by scope.",
            gracePeriod: "7 day grace period for account deletion; files and child data stay hidden immediately."
        )
    }
}

private struct AuditLogSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: ([AuditLogEntry]) -> Void

    @State private var entries: [AuditLogEntry]
    @State private var selectedCategory = "Все"

    init(entries: [AuditLogEntry], onSave: @escaping ([AuditLogEntry]) -> Void) {
        self.onSave = onSave
        _entries = State(initialValue: entries)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    MoreSheetHeader(
                        icon: "list.bullet.rectangle.portrait.fill",
                        color: SchoolTheme.graphite,
                        title: "Журнал действий",
                        subtitle: "Роли, доступы, файлы и важные изменения класса"
                    )

                    DashboardCard {
                        HStack(spacing: 12) {
                            MoreMetric(value: "\(entries.count)", title: "записей", color: SchoolTheme.accent)
                            Divider()
                            MoreMetric(value: "\(localCount)", title: "локально", color: SchoolTheme.warning)
                            Divider()
                            MoreMetric(value: "\(verifiedCount)", title: "проверено", color: SchoolTheme.success)
                        }
                        .frame(height: 62)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Фильтр")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(categories, id: \.self) { category in
                                        Button {
                                            selectedCategory = category
                                        } label: {
                                            Text(category)
                                                .font(.caption.weight(.semibold))
                                                .foregroundStyle(selectedCategory == category ? .white : SchoolTheme.graphite)
                                                .lineLimit(1)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .background(
                                                    selectedCategory == category ? SchoolTheme.accent : SchoolTheme.page,
                                                    in: Capsule()
                                                )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("Последние действия")
                                    .font(.headline)
                                    .foregroundStyle(SchoolTheme.graphite)
                                Spacer()
                                Button {
                                    addControlCheckpoint()
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundStyle(SchoolTheme.accent)
                                        .frame(width: 34, height: 34)
                                        .background(SchoolTheme.accent.opacity(0.10), in: Circle())
                                }
                                .accessibilityLabel("Добавить контрольную запись")
                            }

                            if filteredEntries.isEmpty {
                                MoreEmptyState(
                                    icon: "checkmark.shield.fill",
                                    title: "Записей нет",
                                    detail: "Для этого фильтра пока не было действий"
                                )
                            } else {
                                ForEach(filteredEntries) { entry in
                                    auditRow(entry)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Серверный AuditLog подключается следующим этапом", systemImage: "server.rack")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(SchoolTheme.graphite)
                            Text("Сейчас журнал сохраняется на устройстве и показывает UX-сценарий: кто изменил доступ, файл, безопасность или семейную задачу. Для продакшена эти записи должны уходить на backend и быть защищены от ручного изменения.")
                                .font(.caption)
                                .foregroundStyle(SchoolTheme.muted)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Журнал")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        save()
                    }
                }
            }
        }
    }

    private var categories: [String] {
        ["Все"] + Array(Set(entries.map(\.category))).sorted()
    }

    private var filteredEntries: [AuditLogEntry] {
        entries.filter { entry in
            selectedCategory == "Все" || entry.category == selectedCategory
        }
    }

    private var localCount: Int {
        entries.filter { $0.status == "Локально" }.count
    }

    private var verifiedCount: Int {
        entries.filter { $0.status == "Проверено" }.count
    }

    private func auditRow(_ entry: AuditLogEntry) -> some View {
        HStack(alignment: .top, spacing: 12) {
            IconBadge(systemName: entry.iconName, color: moreColor(for: entry.colorName), size: 42)
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 7) {
                    Text(entry.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SchoolTheme.graphite)
                        .fixedSize(horizontal: false, vertical: true)
                    StatusBadge(text: entry.category, color: moreColor(for: entry.colorName))
                }

                Text(entry.detail)
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)

                Text("\(entry.actor) - \(entry.target)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite.opacity(0.72))

                HStack(spacing: 8) {
                    Text(entry.timestampLabel)
                        .font(.caption)
                        .foregroundStyle(SchoolTheme.muted)
                    Text(entry.status)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(entry.status == "Проверено" ? SchoolTheme.success : SchoolTheme.warning)
                }
            }
            Spacer()
        }
        .padding(.vertical, 2)
    }

    private func addControlCheckpoint() {
        entries.insert(
            AuditLogEntry(
                title: "Контрольная проверка",
                detail: "Администратор открыл журнал и сверил локальные записи",
                actor: "Владимир",
                target: "AuditLog",
                category: "Безопасность",
                status: "Локально",
                timestampLabel: "сейчас",
                iconName: "checkmark.shield.fill",
                colorName: "green"
            ),
            at: 0
        )
    }

    private func save() {
        onSave(entries)
        dismiss()
    }
}

private struct LegalCenterSheet: View {
    @Environment(\.dismiss) private var dismiss

    let settings: PrivacySettingsState

    private let documents = LegalDocumentItem.sample
    private let readinessItems = LegalReadinessItem.sample

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    MoreSheetHeader(
                        icon: "doc.text.magnifyingglass",
                        color: SchoolTheme.graphite,
                        title: "Юридика",
                        subtitle: "Политика, условия, согласие родителя и готовность к App Store"
                    )

                    DashboardCard {
                        HStack(spacing: 12) {
                            MoreMetric(value: "\(documents.count)", title: "документа", color: SchoolTheme.accent)
                            Divider()
                            MoreMetric(value: "\(blockerCount)", title: "блокеры", color: SchoolTheme.danger)
                            Divider()
                            MoreMetric(value: consentValue, title: "согласие", color: consentColor)
                        }
                        .frame(height: 62)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Документы MVP")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            ForEach(documents) { document in
                                legalDocumentRow(document)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Готовность к публикации")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            ForEach(readinessItems) { item in
                                legalReadinessRow(item)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Что важно перед TestFlight", systemImage: "exclamationmark.shield.fill")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(SchoolTheme.graphite)
                            Text("Для внутренней разработки достаточно черновиков. Перед внешними тестерами нужно финализировать владельца приложения, публичную ссылку политики, фактических провайдеров хранения/AI/платежей и App Store privacy labels.")
                                .font(.caption)
                                .foregroundStyle(SchoolTheme.muted)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Юридика")
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

    private var blockerCount: Int {
        readinessItems.filter { $0.status == "Блокер" }.count
    }

    private var consentValue: String {
        settings.childDataConsent && settings.privacyPolicyAccepted ? "есть" : "нет"
    }

    private var consentColor: Color {
        settings.childDataConsent && settings.privacyPolicyAccepted ? SchoolTheme.success : SchoolTheme.warning
    }

    private func legalDocumentRow(_ document: LegalDocumentItem) -> some View {
        HStack(alignment: .top, spacing: 12) {
            IconBadge(systemName: document.iconName, color: moreColor(for: document.colorName), size: 42)

            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(document.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SchoolTheme.graphite)
                    StatusBadge(text: document.status, color: moreColor(for: document.colorName))
                }

                Text(document.version)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite.opacity(0.70))

                Text(document.detail)
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(.vertical, 2)
    }

    private func legalReadinessRow(_ item: LegalReadinessItem) -> some View {
        HStack(alignment: .top, spacing: 12) {
            IconBadge(systemName: item.iconName, color: moreColor(for: item.colorName), size: 40)

            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(item.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SchoolTheme.graphite)
                    StatusBadge(text: item.status, color: moreColor(for: item.colorName))
                }

                Text(item.detail)
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(12)
        .background(SchoolTheme.page, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct RealDeviceQaSheet: View {
    @Environment(\.dismiss) private var dismiss

    private let checks = RealDeviceQaItem.sample

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    MoreSheetHeader(
                        icon: "iphone.gen3",
                        color: SchoolTheme.accent,
                        title: "Проверка на iPhone",
                        subtitle: "Ручной прогон того, что Simulator не доказывает перед TestFlight"
                    )

                    DashboardCard {
                        HStack(spacing: 12) {
                            MoreMetric(value: "\(checks.count)", title: "проверок", color: SchoolTheme.accent)
                            Divider()
                            MoreMetric(value: "\(waitingCount)", title: "ждут", color: SchoolTheme.warning)
                            Divider()
                            MoreMetric(value: "0", title: "пройдено", color: SchoolTheme.success)
                        }
                        .frame(height: 62)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Что пройти на устройстве")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            ForEach(checks) { check in
                                deviceCheckRow(check)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Почему это отдельный gate", systemImage: "exclamationmark.triangle.fill")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(SchoolTheme.graphite)
                            Text("Simulator хорошо ловит навигацию, состояния и верстку. Реальный iPhone нужен для камеры, галереи, файлов, уведомлений, подписи, памяти, плавности прокрутки и поведения системных листов.")
                                .font(.caption)
                                .foregroundStyle(SchoolTheme.muted)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Следующий шаг", systemImage: "checkmark.seal.fill")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(SchoolTheme.graphite)
                            Text("После установки на iPhone нужно пройти этот список, приложить фактические скриншоты или заметки в чеклист и только потом считать TestFlight gate готовым.")
                                .font(.caption)
                                .foregroundStyle(SchoolTheme.muted)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("iPhone QA")
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

    private var waitingCount: Int {
        checks.filter { $0.status == "Ждет iPhone" }.count
    }

    private func deviceCheckRow(_ check: RealDeviceQaItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                IconBadge(systemName: check.iconName, color: moreColor(for: check.colorName), size: 42)

                VStack(alignment: .leading, spacing: 5) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(check.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(SchoolTheme.graphite)
                        StatusBadge(text: check.status, color: moreColor(for: check.colorName))
                    }

                    Text(check.detail)
                        .font(.caption)
                        .foregroundStyle(SchoolTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }

            Label(check.evidence, systemImage: "doc.text.magnifyingglass")
                .font(.caption.weight(.semibold))
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .background(SchoolTheme.page, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct BehavioralQaSheet: View {
    @Environment(\.dismiss) private var dismiss

    private let items = BehavioralQaItem.sample

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    MoreSheetHeader(
                        icon: "checklist.checked",
                        color: SchoolTheme.success,
                        title: "Behavior QA",
                        subtitle: "Инварианты, которые должны проверяться не только скриншотами"
                    )

                    DashboardCard {
                        HStack(spacing: 12) {
                            MoreMetric(value: "\(items.count)", title: "правил", color: SchoolTheme.accent)
                            Divider()
                            MoreMetric(value: "\(smokeCount)", title: "smoke", color: SchoolTheme.success)
                            Divider()
                            MoreMetric(value: "\(needsXCTestCount)", title: "XCTest", color: SchoolTheme.warning)
                        }
                        .frame(height: 62)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Критичные инварианты")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            ForEach(items) { item in
                                behavioralRow(item)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Следующий уровень автоматизации", systemImage: "testtube.2")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(SchoolTheme.graphite)
                            Text("Текущий smoke доказывает, что экраны открываются и не пустые. Перед релизом эти правила нужно перенести в XCTest/UI-тесты: нажимать кнопки, менять роли, перезапускать приложение и проверять конкретное состояние, а не только PNG.")
                                .font(.caption)
                                .foregroundStyle(SchoolTheme.muted)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Behavior QA")
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

    private var smokeCount: Int {
        items.filter { $0.status.contains("Smoke") }.count
    }

    private var needsXCTestCount: Int {
        items.filter { !$0.status.contains("XCTest") }.count
    }

    private func behavioralRow(_ item: BehavioralQaItem) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                IconBadge(systemName: item.iconName, color: moreColor(for: item.colorName), size: 42)

                VStack(alignment: .leading, spacing: 5) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(item.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(SchoolTheme.graphite)
                        StatusBadge(text: item.status, color: moreColor(for: item.colorName))
                    }

                    Text(item.invariant)
                        .font(.caption)
                        .foregroundStyle(SchoolTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }

            Label(item.smokeCase, systemImage: "camera.viewfinder")
                .font(.caption.weight(.semibold))
                .foregroundStyle(SchoolTheme.accent)
                .fixedSize(horizontal: false, vertical: true)

            Text(item.evidence)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .background(SchoolTheme.page, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("behaviorQA.\(item.title)")
    }
}

private struct PrivacySettingsSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: (PrivacySettingsState) -> Void

    @State private var settings: PrivacySettingsState

    init(settings: PrivacySettingsState, onSave: @escaping (PrivacySettingsState) -> Void) {
        self.onSave = onSave
        _settings = State(initialValue: settings)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    MoreSheetHeader(
                        icon: "hand.raised.fill",
                        color: SchoolTheme.teal,
                        title: "Приватность",
                        subtitle: "Минимум данных ребенка, согласие родителя и правила хранения"
                    )

                    DashboardCard {
                        HStack(spacing: 12) {
                            MoreMetric(value: settings.minimalChildData ? "да" : "нет", title: "минимум", color: SchoolTheme.success)
                            Divider()
                            MoreMetric(value: settings.childDataConsent ? "да" : "нет", title: "согласие", color: settings.childDataConsent ? SchoolTheme.success : SchoolTheme.warning)
                            Divider()
                            MoreMetric(value: settings.privacyPolicyAccepted ? "да" : "нет", title: "политика", color: settings.privacyPolicyAccepted ? SchoolTheme.success : SchoolTheme.warning)
                        }
                        .frame(height: 62)
                    }

                    DashboardCard {
                        VStack(spacing: 14) {
                            privacyToggle(
                                title: "Собирать минимум данных",
                                detail: "Имя ребенка, класс и школьные связи без лишних персональных полей",
                                icon: "person.text.rectangle.fill",
                                color: SchoolTheme.success,
                                isOn: $settings.minimalChildData
                            )

                            Divider()

                            privacyToggle(
                                title: "Согласие родителя",
                                detail: "Для работы класса и семьи",
                                icon: "checkmark.seal.fill",
                                color: SchoolTheme.accent,
                                isOn: $settings.childDataConsent
                            )

                            Divider()

                            privacyToggle(
                                title: "Политика конфиденциальности",
                                detail: "Какие данные нужны и зачем",
                                icon: "doc.text.fill",
                                color: SchoolTheme.teal,
                                isOn: $settings.privacyPolicyAccepted
                            )
                        }
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Кратко о данных")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)
                            privacyRule("Профиль ребенка", "имя, класс, школа и связи с семьей")
                            privacyRule("Учебные данные", "домашние задания, события, файлы и отметки семьи")
                            privacyRule("Финансы класса", "сборы и чеки видны по ролям, без банковских данных")
                            privacyRule("Удаление", "запрос удаления готовится в безопасности аккаунта")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Статус", systemImage: "checkmark.shield.fill")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)
                            Text(settings.consentStatus)
                                .font(.caption)
                                .foregroundStyle(SchoolTheme.muted)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button {
                        save()
                    } label: {
                        Label("Сохранить приватность", systemImage: "checkmark")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: 52)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(SchoolTheme.success)
                    .disabled(!settings.minimalChildData)
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Приватность")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        save()
                    }
                }
            }
        }
    }

    private func privacyToggle(
        title: String,
        detail: String,
        icon: String,
        color: Color,
        isOn: Binding<Bool>
    ) -> some View {
        Toggle(isOn: isOn) {
            HStack(spacing: 12) {
                IconBadge(systemName: icon, color: color, size: 42)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SchoolTheme.graphite)
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(SchoolTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .tint(SchoolTheme.success)
    }

    private func privacyRule(_ title: String, _ detail: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(SchoolTheme.success)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
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

    private func save() {
        AppPrivacyConsentStore.save(
            childDataConsent: settings.childDataConsent,
            policyAccepted: settings.privacyPolicyAccepted,
            actor: "родителем"
        )

        if settings.childDataConsent && settings.privacyPolicyAccepted {
            settings.consentStatus = AppPrivacyConsentStore.statusText
        } else if settings.childDataConsent {
            settings.consentStatus = "Согласие есть, но политика еще не подтверждена"
        } else {
            settings.consentStatus = "Согласие еще не подтверждено"
        }

        onSave(settings)
        dismiss()
    }
}

private struct MvpMetricsSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: ([AnalyticsEventSummary], [MvpMetricSummary]) -> Void

    @State private var events: [AnalyticsEventSummary]
    @State private var metrics: [MvpMetricSummary]
    @State private var selectedGroup = "Все"

    init(
        events: [AnalyticsEventSummary],
        metrics: [MvpMetricSummary],
        onSave: @escaping ([AnalyticsEventSummary], [MvpMetricSummary]) -> Void
    ) {
        self.onSave = onSave
        _events = State(initialValue: events)
        _metrics = State(initialValue: metrics)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    MoreSheetHeader(
                        icon: "chart.bar.xaxis",
                        color: SchoolTheme.accent,
                        title: "MVP-метрики",
                        subtitle: "Активация класса, ДЗ, события, сборы и trial"
                    )

                    DashboardCard {
                        HStack(spacing: 12) {
                            MoreMetric(value: "\(eventsTotal)", title: "событий", color: SchoolTheme.accent)
                            Divider()
                            MoreMetric(value: "\(healthyMetrics)", title: "в норме", color: SchoolTheme.success)
                            Divider()
                            MoreMetric(value: "\(riskMetrics)", title: "риски", color: SchoolTheme.warning)
                        }
                        .frame(height: 62)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Главные метрики")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            ForEach(metrics) { metric in
                                metricRow(metric)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("События")
                                    .font(.headline)
                                    .foregroundStyle(SchoolTheme.graphite)
                                Spacer()
                            }

                            Button {
                                addSmokeEvent()
                            } label: {
                                Label("Добавить тестовое событие", systemImage: "plus.circle.fill")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(SchoolTheme.accent)
                                    .frame(maxWidth: .infinity, minHeight: 40)
                                    .background(SchoolTheme.accent.opacity(0.11), in: Capsule())
                            }
                            .buttonStyle(.plain)
                            .accessibilityIdentifier("metrics.add-test-event")

                            if let latestEvent = events.first {
                                HStack(alignment: .top, spacing: 10) {
                                    IconBadge(systemName: latestEvent.iconName, color: moreColor(for: latestEvent.colorName), size: 34)
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text("Последнее событие")
                                            .font(.caption2.weight(.semibold))
                                            .foregroundStyle(SchoolTheme.muted)
                                        Text(latestEvent.name)
                                            .font(.caption.weight(.bold))
                                            .foregroundStyle(SchoolTheme.graphite)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.76)
                                            .accessibilityIdentifier("metrics.latest-event.\(latestEvent.name)")
                                        Text(latestEvent.detail)
                                            .font(.caption2)
                                            .foregroundStyle(SchoolTheme.muted)
                                            .lineLimit(2)
                                            .minimumScaleFactor(0.76)
                                    }
                                    Spacer()
                                    StatusBadge(text: "\(latestEvent.count)", color: moreColor(for: latestEvent.colorName))
                                }
                                .padding(8)
                                .background(moreColor(for: latestEvent.colorName).opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                            }

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(groups, id: \.self) { group in
                                        Button {
                                            selectedGroup = group
                                        } label: {
                                            Text(group)
                                                .font(.caption.weight(.semibold))
                                                .foregroundStyle(selectedGroup == group ? .white : SchoolTheme.graphite)
                                                .lineLimit(1)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .background(
                                                    selectedGroup == group ? SchoolTheme.accent : SchoolTheme.page,
                                                    in: Capsule()
                                                )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }

                            ForEach(filteredEvents) { event in
                                eventRow(event)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Сейчас это локальная аналитика", systemImage: "externaldrive.fill")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(SchoolTheme.graphite)
                            Text("Экран фиксирует продуктовую схему: какие события нужны для MVP и какие метрики показывают пользу. Для релиза события должны отправляться на backend или в выбранную аналитику с учетом согласия и приватности.")
                                .font(.caption)
                                .foregroundStyle(SchoolTheme.muted)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Метрики")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        save()
                    }
                }
            }
        }
    }

    private var groups: [String] {
        ["Все"] + Array(Set(events.map(\.group))).sorted()
    }

    private var filteredEvents: [AnalyticsEventSummary] {
        events.filter { event in
            selectedGroup == "Все" || event.group == selectedGroup
        }
    }

    private var eventsTotal: Int {
        events.map(\.count).reduce(0, +)
    }

    private var healthyMetrics: Int {
        metrics.filter { $0.status == "В норме" }.count
    }

    private var riskMetrics: Int {
        metrics.filter { $0.status != "В норме" }.count
    }

    private func metricRow(_ metric: MvpMetricSummary) -> some View {
        HStack(alignment: .top, spacing: 12) {
            IconBadge(systemName: metric.iconName, color: moreColor(for: metric.colorName), size: 42)
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(metric.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SchoolTheme.graphite)
                        .fixedSize(horizontal: false, vertical: true)
                    StatusBadge(text: metric.status, color: moreColor(for: metric.colorName))
                }
                Text("\(metric.value) - \(metric.target)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                Text(metric.detail)
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
    }

    private func eventRow(_ event: AnalyticsEventSummary) -> some View {
        HStack(alignment: .top, spacing: 12) {
            IconBadge(systemName: event.iconName, color: moreColor(for: event.colorName), size: 40)
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 7) {
                    Text(event.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SchoolTheme.graphite)
                        .fixedSize(horizontal: false, vertical: true)
                    StatusBadge(text: "\(event.count)", color: moreColor(for: event.colorName))
                }
                Text(event.detail)
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
                Text("\(event.group) - \(event.lastSeen)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
            }
            Spacer()
        }
        .padding(.vertical, 2)
    }

    private func addSmokeEvent() {
        events.insert(
            AnalyticsEventSummary(
                name: "qa_smoke_passed",
                group: "QA",
                detail: "Локальная проверка ключевого сценария",
                count: 1,
                lastSeen: "сейчас",
                iconName: "checkmark.seal.fill",
                colorName: "green"
            ),
            at: 0
        )
    }

    private func save() {
        onSave(events, metrics)
        dismiss()
    }
}

private struct ModerationCenterSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var queue = ModerationQueueItem.sample

    private let rules = ModerationRule.sample

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    MoreSheetHeader(
                        icon: "flag.fill",
                        color: SchoolTheme.danger,
                        title: "Жалобы и модерация",
                        subtitle: "Локальная очередь спорных фото, сообщений и участников класса"
                    )

                    DashboardCard {
                        HStack(spacing: 12) {
                            MoreMetric(value: "\(newCount)", title: "новые", color: SchoolTheme.danger)
                            Divider()
                            MoreMetric(value: "\(reviewCount)", title: "проверка", color: SchoolTheme.warning)
                            Divider()
                            MoreMetric(value: "\(closedCount)", title: "закрыто", color: SchoolTheme.success)
                        }
                        .frame(height: 62)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Очередь проверки")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            ForEach($queue) { $item in
                                moderationRow(item: $item)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Правила безопасности")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            ForEach(rules) { rule in
                                moderationRuleRow(rule)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Что еще должен сделать backend", systemImage: "server.rack")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(SchoolTheme.graphite)
                            Text("Сейчас это локальный MVP-экран. Для реального класса сервер должен хранить жалобу, роль проверяющего, решение, аудит, уведомление автора и запрет повторного показа скрытого материала.")
                                .font(.caption)
                                .foregroundStyle(SchoolTheme.muted)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Модерация")
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

    private var newCount: Int {
        queue.filter { $0.status == "Новая" }.count
    }

    private var reviewCount: Int {
        queue.filter { $0.status == "На проверке" }.count
    }

    private var closedCount: Int {
        queue.filter { $0.status == "Закрыта" }.count
    }

    private func moderationRow(item: Binding<ModerationQueueItem>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                IconBadge(systemName: item.wrappedValue.iconName, color: moreColor(for: item.wrappedValue.colorName), size: 42)

                VStack(alignment: .leading, spacing: 5) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(item.wrappedValue.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(SchoolTheme.graphite)
                        StatusBadge(text: item.wrappedValue.status, color: statusColor(for: item.wrappedValue.status))
                    }

                    Text("\(item.wrappedValue.target) · \(item.wrappedValue.reporter)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(SchoolTheme.muted)

                    Text(item.wrappedValue.detail)
                        .font(.caption)
                        .foregroundStyle(SchoolTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }

            HStack(spacing: 8) {
                StatusBadge(text: "Приоритет: \(item.wrappedValue.priority)", color: moreColor(for: item.wrappedValue.colorName))

                Spacer()

                if item.wrappedValue.status == "Новая" {
                    Button("В проверку") {
                        item.wrappedValue.status = "На проверке"
                        item.wrappedValue.colorName = "orange"
                    }
                    .font(.caption.weight(.semibold))
                    .buttonStyle(.bordered)
                }

                if item.wrappedValue.status != "Закрыта" {
                    Button("Закрыть") {
                        item.wrappedValue.status = "Закрыта"
                        item.wrappedValue.colorName = "green"
                    }
                    .font(.caption.weight(.semibold))
                    .buttonStyle(.borderedProminent)
                    .tint(SchoolTheme.success)
                }
            }
        }
        .padding(12)
        .background(SchoolTheme.page, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func moderationRuleRow(_ rule: ModerationRule) -> some View {
        HStack(alignment: .top, spacing: 12) {
            IconBadge(systemName: rule.iconName, color: moreColor(for: rule.colorName), size: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(rule.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite)
                Text(rule.detail)
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
    }

    private func statusColor(for status: String) -> Color {
        switch status {
        case "Закрыта":
            SchoolTheme.success
        case "На проверке":
            SchoolTheme.warning
        default:
            SchoolTheme.danger
        }
    }
}

private struct BetaReadinessSheet: View {
    @Environment(\.dismiss) private var dismiss

    private let readinessItems = BetaReadinessItem.sample
    private let testerGroups = BetaTesterGroup.sample
    private let scenarios = BetaScenario.sample

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    MoreSheetHeader(
                        icon: "testtube.2",
                        color: SchoolTheme.accent,
                        title: "Бета / TestFlight",
                        subtitle: "Что готово для тестовой сборки и что еще блокирует внешних тестеров"
                    )

                    DashboardCard {
                        HStack(spacing: 12) {
                            MoreMetric(value: "\(readyCount)", title: "готово", color: SchoolTheme.success)
                            Divider()
                            MoreMetric(value: "\(needsCheckCount)", title: "проверить", color: SchoolTheme.warning)
                            Divider()
                            MoreMetric(value: "\(blockerCount)", title: "блокеры", color: SchoolTheme.danger)
                        }
                        .frame(height: 62)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Release gate")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            ForEach(readinessItems) { item in
                                readinessRow(item)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Группы тестеров")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            ForEach(testerGroups) { group in
                                testerGroupRow(group)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Сценарии приемки")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            ForEach(scenarios) { scenario in
                                betaScenarioRow(scenario)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Следующий реальный шаг", systemImage: "iphone.gen3")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(SchoolTheme.graphite)
                            Text("Перед TestFlight нужно поставить приложение на реальный iPhone, пройти камеру, уведомления, файлы, выход из аккаунта и роли. После этого можно делать Archive, загружать сборку в App Store Connect и приглашать внутреннюю группу.")
                                .font(.caption)
                                .foregroundStyle(SchoolTheme.muted)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Бета")
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

    private var readyCount: Int {
        readinessItems.filter { $0.status == "Готово" }.count
    }

    private var needsCheckCount: Int {
        readinessItems.filter { $0.status == "Нужна проверка" }.count
    }

    private var blockerCount: Int {
        readinessItems.filter { $0.status == "Блокер" }.count
    }

    private func readinessRow(_ item: BetaReadinessItem) -> some View {
        HStack(alignment: .top, spacing: 12) {
            IconBadge(systemName: item.iconName, color: moreColor(for: item.colorName), size: 42)
            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(item.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SchoolTheme.graphite)
                    StatusBadge(text: item.status, color: moreColor(for: item.colorName))
                }
                Text(item.detail)
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
    }

    private func testerGroupRow(_ group: BetaTesterGroup) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(group.count)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(moreColor(for: group.colorName))
                .frame(width: 48, height: 42)
                .background(moreColor(for: group.colorName).opacity(0.10), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(group.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite)
                Text(group.detail)
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
    }

    private func betaScenarioRow(_ scenario: BetaScenario) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(scenario.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite)
                StatusBadge(text: scenario.status, color: moreColor(for: scenario.colorName))
            }
            Text(scenario.detail)
                .font(.caption)
                .foregroundStyle(SchoolTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
            Label(scenario.expected, systemImage: "target")
                .font(.caption.weight(.semibold))
                .foregroundStyle(moreColor(for: scenario.colorName))
        }
        .padding(12)
        .background(SchoolTheme.page, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct AIQualitySheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: ([AIQualityLogEntry]) -> Void

    @State private var logs: [AIQualityLogEntry]

    init(logs: [AIQualityLogEntry], onSave: @escaping ([AIQualityLogEntry]) -> Void) {
        self.onSave = onSave
        _logs = State(initialValue: logs)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    MoreSheetHeader(
                        icon: "sparkles",
                        color: SchoolTheme.warning,
                        title: "Качество AI",
                        subtitle: "Ошибки, повторы, уверенность и версии промптов"
                    )

                    DashboardCard {
                        HStack(spacing: 12) {
                            MoreMetric(value: "\(acceptedCount)", title: "принято", color: SchoolTheme.success)
                            Divider()
                            MoreMetric(value: "\(reviewCount)", title: "проверить", color: SchoolTheme.warning)
                            Divider()
                            MoreMetric(value: "\(averageConfidence)%", title: "уверенность", color: confidenceColor)
                        }
                        .frame(height: 62)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Журнал разборов")
                                    .font(.headline)
                                    .foregroundStyle(SchoolTheme.graphite)
                                Spacer()
                                Button {
                                    addRetryLog()
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundStyle(SchoolTheme.warning)
                                        .frame(width: 34, height: 34)
                                        .background(SchoolTheme.warning.opacity(0.12), in: Circle())
                                }
                                .accessibilityLabel("Добавить AI-лог")
                            }

                            ForEach(logs) { log in
                                aiLogRow(log)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Что должно уйти в backend", systemImage: "server.rack")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(SchoolTheme.graphite)
                            Text("Для релиза каждый AI-разбор должен хранить источник, версию промпта, уверенность, правки пользователя, повторные попытки и итог: принято, отклонено или отправлено на улучшение.")
                                .font(.caption)
                                .foregroundStyle(SchoolTheme.muted)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("AI")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        save()
                    }
                }
            }
        }
    }

    private var acceptedCount: Int {
        logs.filter { $0.status == "Принято" }.count
    }

    private var reviewCount: Int {
        logs.filter { $0.status != "Принято" }.count
    }

    private var averageConfidence: Int {
        guard !logs.isEmpty else {
            return 0
        }

        return logs.map(\.confidence).reduce(0, +) / logs.count
    }

    private var confidenceColor: Color {
        averageConfidence >= 85 ? SchoolTheme.success : SchoolTheme.warning
    }

    private func aiLogRow(_ log: AIQualityLogEntry) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                IconBadge(systemName: log.iconName, color: moreColor(for: log.colorName), size: 42)
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 7) {
                        Text(log.source)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(SchoolTheme.graphite)
                            .fixedSize(horizontal: false, vertical: true)
                        StatusBadge(text: log.status, color: moreColor(for: log.colorName))
                    }
                    Text(log.inputSummary)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                        .fixedSize(horizontal: false, vertical: true)
                    Text(log.issue)
                        .font(.caption)
                        .foregroundStyle(SchoolTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("\(log.promptVersion) - \(log.confidence)% - попыток: \(log.attempts)")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(SchoolTheme.muted)
                }
                Spacer()
            }

            HStack(spacing: 8) {
                aiActionButton("Принять", icon: "checkmark", color: SchoolTheme.success) {
                    update(log) { entry in
                        entry.status = "Принято"
                        entry.colorName = "green"
                        entry.confidence = max(entry.confidence, 90)
                    }
                }

                aiActionButton("Повторить", icon: "arrow.clockwise", color: SchoolTheme.accent) {
                    update(log) { entry in
                        entry.status = "Повторить"
                        entry.colorName = "blue"
                        entry.attempts += 1
                        entry.confidence = min(entry.confidence + 8, 96)
                    }
                }

                aiActionButton("Промпт", icon: "slider.horizontal.3", color: SchoolTheme.warning) {
                    update(log) { entry in
                        entry.status = "Улучшить"
                        entry.colorName = "orange"
                        entry.promptVersion = "\(entry.promptVersion)+fix"
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func aiActionButton(_ title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
                .frame(maxWidth: .infinity, minHeight: 34)
                .background(color.opacity(0.11), in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private func update(_ log: AIQualityLogEntry, mutate: (inout AIQualityLogEntry) -> Void) {
        guard let index = logs.firstIndex(where: { $0.id == log.id }) else {
            return
        }

        mutate(&logs[index])
    }

    private func addRetryLog() {
        logs.insert(
            AIQualityLogEntry(
                source: "Голос",
                inputSummary: "Надиктовано: купить папку и принести форму",
                issue: "Нужно сравнить с исходной расшифровкой",
                confidence: 73,
                status: "Проверить",
                promptVersion: "voice-v1",
                attempts: 1,
                iconName: "mic.fill",
                colorName: "orange"
            ),
            at: 0
        )
    }

    private func save() {
        onSave(logs)
        dismiss()
    }
}

private struct QaStatesSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: ([QaStateScenario]) -> Void

    @State private var scenarios: [QaStateScenario]
    @State private var selectedFilter = "Все"

    init(scenarios: [QaStateScenario], onSave: @escaping ([QaStateScenario]) -> Void) {
        self.onSave = onSave
        _scenarios = State(initialValue: scenarios)
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    MoreSheetHeader(
                        icon: "checkmark.seal.fill",
                        color: SchoolTheme.success,
                        title: "QA-состояния",
                        subtitle: "Без учителя, пустые экраны, нет прав и ошибка сети"
                    )

                    DashboardCard {
                        HStack(spacing: 12) {
                            MoreMetric(value: "\(passedCount)", title: "пройдено", color: SchoolTheme.success)
                            Divider()
                            MoreMetric(value: "\(todoCount)", title: "проверить", color: SchoolTheme.warning)
                            Divider()
                            MoreMetric(value: "\(scenarios.count)", title: "всего", color: SchoolTheme.accent)
                        }
                        .frame(height: 62)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Фильтр")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            HStack(spacing: 8) {
                                ForEach(["Все", "Пройдено", "Проверить"], id: \.self) { filter in
                                    Button {
                                        selectedFilter = filter
                                    } label: {
                                        Text(filter)
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(selectedFilter == filter ? .white : SchoolTheme.graphite)
                                            .lineLimit(1)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(
                                                selectedFilter == filter ? SchoolTheme.success : SchoolTheme.page,
                                                in: Capsule()
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Сценарии приемки")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            ForEach(filteredScenarios) { scenario in
                                scenarioRow(scenario)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Что это закрывает", systemImage: "list.clipboard.fill")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(SchoolTheme.graphite)
                            Text("Экран нужен для ручной приемки MVP в Simulator: быстро видно, какие состояния уже покрыты интерфейсом, а какие требуют backend, синхронизации, подписки или настоящих push-уведомлений.")
                                .font(.caption)
                                .foregroundStyle(SchoolTheme.muted)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("QA")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        save()
                    }
                }
            }
        }
    }

    private var filteredScenarios: [QaStateScenario] {
        scenarios.filter { scenario in
            selectedFilter == "Все" || scenario.status == selectedFilter
        }
    }

    private var passedCount: Int {
        scenarios.filter { $0.status == "Пройдено" }.count
    }

    private var todoCount: Int {
        scenarios.filter { $0.status != "Пройдено" }.count
    }

    private func scenarioRow(_ scenario: QaStateScenario) -> some View {
        HStack(alignment: .top, spacing: 12) {
            IconBadge(systemName: scenario.iconName, color: moreColor(for: scenario.colorName), size: 42)
            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(scenario.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SchoolTheme.graphite)
                        .fixedSize(horizontal: false, vertical: true)
                    StatusBadge(text: scenario.status, color: scenario.status == "Пройдено" ? SchoolTheme.success : SchoolTheme.warning)
                }

                Text(scenario.detail)
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)

                Text("\(scenario.state): \(scenario.expectedResult)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                    .fixedSize(horizontal: false, vertical: true)

                Button {
                    toggleScenario(scenario)
                } label: {
                    Label(scenario.status == "Пройдено" ? "Вернуть в проверку" : "Отметить пройдено", systemImage: scenario.status == "Пройдено" ? "arrow.uturn.left" : "checkmark")
                        .font(.caption.weight(.semibold))
                }
                .buttonStyle(.bordered)
                .tint(scenario.status == "Пройдено" ? SchoolTheme.muted : SchoolTheme.success)
                .controlSize(.small)
            }
            Spacer()
        }
        .padding(.vertical, 2)
    }

    private func toggleScenario(_ scenario: QaStateScenario) {
        guard let index = scenarios.firstIndex(where: { $0.id == scenario.id }) else {
            return
        }

        scenarios[index].status = scenarios[index].status == "Пройдено" ? "Проверить" : "Пройдено"
    }

    private func save() {
        onSave(scenarios)
        dismiss()
    }
}

private struct SyncCenterSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: ([SyncOperationSummary]) -> Void

    @State private var operations: [SyncOperationSummary]
    @State private var syncStatus = "Backend еще не подключен: проверяется локальная очередь"
    @State private var environment: BackendEnvironment = .staging
    @State private var dryRunResult: SyncDryRunResult?
    @State private var supabaseConfig = SupabaseBackendConfig.make()
    @State private var supabaseLiveProbe = SupabaseLiveProbeResult.planned(config: SupabaseBackendConfig.make())
    @State private var supabaseAuthSession = SupabaseAuthSessionProbe.make(config: SupabaseBackendConfig.make())
    @State private var supabaseStoredSeedSession = SupabaseStoredSeedSessionProbe.make(config: SupabaseBackendConfig.make())
    @State private var supabasePasswordSignIn = SupabasePasswordSignInProbe.planned(config: SupabaseBackendConfig.make())
    @State private var supabaseSessionRefresh = SupabaseSessionRefreshProbe.planned(config: SupabaseBackendConfig.make())
    @State private var supabaseSignedProfile = SupabaseSignedProfileProbe.planned(config: SupabaseBackendConfig.make())
    @State private var supabaseSignedClassScope = SupabaseSignedClassScopeProbe.planned(config: SupabaseBackendConfig.make())
    @State private var supabaseSignedChildren = SupabaseSignedChildrenProbe.planned(config: SupabaseBackendConfig.make())
    @State private var supabaseSignedAnnouncements = SupabaseSignedAnnouncementsProbe.planned(config: SupabaseBackendConfig.make())
    @State private var supabaseSignedHomework = SupabaseSignedHomeworkProbe.planned(config: SupabaseBackendConfig.make())
    @State private var supabaseSignedCalendarEvents = SupabaseSignedCalendarEventsProbe.planned(config: SupabaseBackendConfig.make())
    @State private var supabaseSignedCollections = SupabaseSignedCollectionsProbe.planned(config: SupabaseBackendConfig.make())
    @State private var supabaseAnnouncementReadAck = SupabaseAnnouncementReadAckResult.planned(config: SupabaseBackendConfig.make())
    @State private var supabaseRlsSmoke = SupabaseRlsSmokeProbe.make(config: SupabaseBackendConfig.make())
    @State private var usesSupabaseChildSourcePreview = AppChildStore.usesSupabaseChildSourcePreview

    init(operations: [SyncOperationSummary], onSave: @escaping ([SyncOperationSummary]) -> Void) {
        self.onSave = onSave
        let arguments = ProcessInfo.processInfo.arguments
        if arguments.contains("-qa-reset-supabase-session-store") {
            SupabaseSeedSessionStore.clear()
        }
        if arguments.contains("-qa-seed-supabase-session-store") {
            SupabaseSeedSessionStore.seedForUITest()
        }

        var launchOperations = operations
        if arguments.contains("-qa-more-sync-offline"), !launchOperations.isEmpty {
            launchOperations[0].status = "Offline"
            launchOperations[0].colorName = "orange"
        }
        if arguments.contains("-qa-more-sync-network-error"), !launchOperations.isEmpty {
            launchOperations[0].status = "Retry 1/5"
            launchOperations[0].colorName = "orange"
            launchOperations[0].retryPolicy = "Timeout: сохранить mutationId, повторить через 15 секунд"
            launchOperations[0].conflictRule = "Пользовательские данные не теряются; idempotency key не меняется"
        }

        _operations = State(initialValue: launchOperations)
        let launchSupabaseConfig = SupabaseBackendConfig.make()
        _supabaseConfig = State(initialValue: launchSupabaseConfig)
        _supabaseLiveProbe = State(initialValue: SupabaseLiveProbeResult.planned(config: launchSupabaseConfig))
        _supabaseAuthSession = State(initialValue: SupabaseAuthSessionProbe.make(config: launchSupabaseConfig))
        _supabaseStoredSeedSession = State(initialValue: SupabaseStoredSeedSessionProbe.make(config: launchSupabaseConfig))
        _supabasePasswordSignIn = State(initialValue: SupabasePasswordSignInProbe.planned(config: launchSupabaseConfig))
        _supabaseSessionRefresh = State(initialValue: SupabaseSessionRefreshProbe.planned(config: launchSupabaseConfig))
        _supabaseSignedProfile = State(initialValue: SupabaseSignedProfileProbe.planned(config: launchSupabaseConfig))
        _supabaseSignedClassScope = State(initialValue: SupabaseSignedClassScopeProbe.planned(config: launchSupabaseConfig))
        _supabaseSignedChildren = State(initialValue: SupabaseSignedChildrenProbe.planned(config: launchSupabaseConfig))
        _supabaseSignedAnnouncements = State(initialValue: SupabaseSignedAnnouncementsProbe.planned(config: launchSupabaseConfig))
        _supabaseSignedHomework = State(initialValue: SupabaseSignedHomeworkProbe.planned(config: launchSupabaseConfig))
        _supabaseSignedCalendarEvents = State(initialValue: SupabaseSignedCalendarEventsProbe.planned(config: launchSupabaseConfig))
        _supabaseSignedCollections = State(initialValue: SupabaseSignedCollectionsProbe.planned(config: launchSupabaseConfig))
        _supabaseAnnouncementReadAck = State(initialValue: SupabaseAnnouncementReadAckResult.planned(config: launchSupabaseConfig))
        _supabaseRlsSmoke = State(initialValue: SupabaseRlsSmokeProbe.make(config: launchSupabaseConfig))

        if arguments.contains("-qa-more-sync") {
            _dryRunResult = State(initialValue: SyncDryRunResult.make(environment: .staging, operations: launchOperations))
            if arguments.contains("-qa-more-sync-network-error") {
                _syncStatus = State(initialValue: "Timeout-сценарий: операция остается в очереди, данные сохранены локально, повтор запланирован.")
            } else if arguments.contains("-qa-more-sync-supabase") {
                _syncStatus = State(initialValue: "Supabase test backend подключен на уровне схемы: live iOS-запрос ждет publishable/client key и тестовых пользователей.")
            } else {
                _syncStatus = State(initialValue: arguments.contains("-qa-more-sync-offline") ? "Offline-сценарий: операция остается в очереди, пользовательские данные не теряются." : "Dry-run подготовил запросы для Staging: сеть не вызывается, но операции разложены по готовности.")
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    MoreSheetHeader(
                        icon: "arrow.triangle.2.circlepath",
                        color: SchoolTheme.accent,
                        title: "Синхронизация",
                        subtitle: "Очередь offline-действий, API-контракты и конфликты"
                    )

                    DashboardCard {
                        HStack(spacing: 12) {
                            MoreMetric(value: "\(readyCount)", title: "готово", color: SchoolTheme.success)
                            Divider()
                            MoreMetric(value: "\(pendingCount)", title: "очередь", color: SchoolTheme.warning)
                            Divider()
                            MoreMetric(value: "\(storageCount)", title: "storage", color: SchoolTheme.accent)
                        }
                        .frame(height: 62)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Состояние backend MVP")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)

                            VStack(alignment: .leading, spacing: 8) {
                                Picker("Окружение", selection: $environment) {
                                    ForEach(BackendEnvironment.allCases) { item in
                                        Text(item.title).tag(item)
                                    }
                                }
                                .pickerStyle(.segmented)

                                Text("\(environment.baseURL) - \(environment.status)")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(SchoolTheme.muted)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            syncStateRow(
                                icon: "server.rack",
                                color: SchoolTheme.accent,
                                title: "API-контракты",
                                detail: "Сущности, роли, offline-мутации и конфликты описаны в docs/backend_contracts.md; первый OpenAPI draft лежит в docs/openapi_mvp.yaml"
                            )
                            syncStateRow(
                                icon: "paperplane.fill",
                                color: SchoolTheme.success,
                                title: "Batch request",
                                detail: "Dry-run готовит POST /sync/mutations: base URL окружения, typed auth context, idempotency key и compact JSON body"
                            )
                            syncStateRow(
                                icon: "curlybraces.square.fill",
                                color: SchoolTheme.success,
                                title: "Swift client",
                                detail: "Dry-run проходит через типизированный Codable-клиент: URLSession request, JSON body, mock response decode и mapping accepted/queued/blocked"
                            )
                            syncStateRow(
                                icon: "network",
                                color: SchoolTheme.warning,
                                title: "Network readiness",
                                detail: "Перед live-режимом клиент должен пройти /health, timeout/retry policy, auth refresh и запрет локального обхода 403"
                            )
                            syncStateRow(
                                icon: "person.badge.key.fill",
                                color: SchoolTheme.success,
                                title: "Auth context",
                                detail: "Dry-run добавляет user id, class role claim, bearer preview и refresh-план; backend обязан повторно проверить роль"
                            )
                            syncStateRow(
                                icon: "externaldrive.badge.checkmark",
                                color: SchoolTheme.warning,
                                title: "Storage preflight",
                                detail: "Dry-run отделяет фото, чеки и документы от обычных мутаций: сначала private upload и fileId, потом metadata в API"
                            )
                            syncStateRow(
                                icon: "externaldrive.connected.to.line.below",
                                color: SchoolTheme.warning,
                                title: "Локальное хранилище",
                                detail: "Пока UserDefaults JSON; после backend нужен единый репозиторий данных и миграция"
                            )
                            syncStateRow(
                                icon: "wifi.exclamationmark",
                                color: SchoolTheme.teal,
                                title: "Offline",
                                detail: "Черновики не теряются, операции повторяются после восстановления сети"
                            )
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    DashboardCard {
                        apiReadinessSummary
                    }

                    DashboardCard {
                        supabaseReadinessCard
                    }

                    if let dryRunResult {
                        DashboardCard {
                            dryRunCard(dryRunResult)
                        }
                    }

                    DashboardCard {
                        networkFailureDrillCard
                    }

                    DashboardCard {
                        backendPermissionSummary
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Каталог endpoint-ов")
                                    .font(.headline)
                                    .foregroundStyle(SchoolTheme.graphite)
                                Spacer()
                                StatusBadge(text: "\(SyncEndpointKind.allCases.count)", color: SchoolTheme.accent)
                            }

                            ForEach(SyncEndpointKind.allCases) { endpoint in
                                endpointRow(endpoint)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Серверные права")
                                    .font(.headline)
                                    .foregroundStyle(SchoolTheme.graphite)
                                Spacer()
                                StatusBadge(text: "\(BackendPermissionRule.sample.count)", color: SchoolTheme.success)
                            }

                            ForEach(BackendPermissionRule.sample) { rule in
                                permissionRuleRow(rule)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Очередь операций")
                                    .font(.headline)
                                    .foregroundStyle(SchoolTheme.graphite)
                                Spacer()
                                Button {
                                    addInviteOperation()
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundStyle(SchoolTheme.accent)
                                        .frame(width: 34, height: 34)
                                        .background(SchoolTheme.accent.opacity(0.10), in: Circle())
                                }
                                .accessibilityLabel("Добавить операцию синхронизации")
                            }

                            ForEach(operations) { operation in
                                operationRow(operation)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Статус проверки", systemImage: "checkmark.seal.fill")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(SchoolTheme.graphite)
                            Text(syncStatus)
                                .font(.caption)
                                .foregroundStyle(SchoolTheme.muted)
                                .fixedSize(horizontal: false, vertical: true)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                syncActionButton("Dry-run", icon: "play.circle.fill", color: SchoolTheme.accent) {
                                    runDrySync()
                                }
                                syncActionButton("Sync OK", icon: "checkmark.icloud.fill", color: SchoolTheme.success) {
                                    markAllSynced()
                                }
                                syncActionButton("Offline", icon: "wifi.exclamationmark", color: SchoolTheme.warning) {
                                    simulateOffline()
                                }
                                syncActionButton("Конфликт", icon: "exclamationmark.arrow.triangle.2.circlepath", color: SchoolTheme.danger) {
                                    simulateConflict()
                                }
                                syncActionButton("Сбой сети", icon: "antenna.radiowaves.left.and.right.slash", color: SchoolTheme.warning) {
                                    simulateNetworkError()
                                }
                                .accessibilityIdentifier("sync.simulate-network-error")
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button {
                        save()
                    } label: {
                        Label("Сохранить состояние синхронизации", systemImage: "checkmark")
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
            .navigationTitle("Синхронизация")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        save()
                    }
                }
            }
        }
    }

    private var readyCount: Int {
        operations.filter { $0.status == "Готово к API" || $0.status == "Синхронизировано" }.count
    }

    private var pendingCount: Int {
        operations.filter { $0.status == "В очереди" || $0.status == "Локально" || $0.status == "Offline" || $0.status.hasPrefix("Retry") }.count
    }

    private var storageCount: Int {
        operations.filter { $0.status == "Нужен storage" }.count
    }

    private var blockedPermissionCount: Int {
        BackendPermissionRule.sample.reduce(0) { count, rule in
            count
            + [rule.parent, rule.committee, rule.teacher, rule.child].filter { $0 == .deny }.count
        }
    }

    private var ownOnlyPermissionCount: Int {
        BackendPermissionRule.sample.reduce(0) { count, rule in
            count
            + [rule.parent, rule.committee, rule.teacher, rule.child].filter { $0 == .ownOnly }.count
        }
    }

    private var apiReadyCount: Int {
        ApiReadinessItem.sample.filter { $0.status == "Готово" }.count
    }

    private var apiBlockerCount: Int {
        ApiReadinessItem.sample.filter { $0.status == "Блокер" }.count
    }

    private var backendPermissionSummary: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Backend-права", systemImage: "lock.shield.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite)
                Spacer()
                StatusBadge(text: "policy", color: SchoolTheme.success)
            }

            Text("Сервер должен повторять эти проверки, даже если кнопки скрыты в интерфейсе.")
                .font(.caption)
                .foregroundStyle(SchoolTheme.muted)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                MoreMetric(value: "\(BackendPermissionRule.sample.count)", title: "правил", color: SchoolTheme.success)
                Divider()
                MoreMetric(value: "\(blockedPermissionCount)", title: "запрет", color: SchoolTheme.danger)
                Divider()
                MoreMetric(value: "\(ownOnlyPermissionCount)", title: "только свое", color: SchoolTheme.warning)
            }
            .frame(height: 54)
        }
    }

    private var apiReadinessSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Готовность API", systemImage: "checklist.checked")
                    .font(.headline)
                    .foregroundStyle(SchoolTheme.graphite)
                Spacer()
                StatusBadge(text: "\(apiReadyCount)/\(ApiReadinessItem.sample.count)", color: apiBlockerCount == 0 ? SchoolTheme.success : SchoolTheme.warning)
            }

            HStack(spacing: 10) {
                MoreMetric(value: "\(apiReadyCount)", title: "готово", color: SchoolTheme.success)
                Divider()
                MoreMetric(value: "\(ApiReadinessItem.sample.count - apiReadyCount - apiBlockerCount)", title: "дальше", color: SchoolTheme.warning)
                Divider()
                MoreMetric(value: "\(apiBlockerCount)", title: "блокер", color: SchoolTheme.danger)
            }
            .frame(height: 54)

            ForEach(ApiReadinessItem.sample) { item in
                apiReadinessRow(item)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var supabaseReadinessCard: some View {
        let probes = SupabaseReadinessProbe.make(config: supabaseConfig)

        return VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Label("Supabase test backend", systemImage: "server.rack")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite)
                Spacer()
                StatusBadge(text: supabaseConfig.hasClientApiKey ? "key set" : "key missing", color: supabaseConfig.hasClientApiKey ? SchoolTheme.success : SchoolTheme.warning)
            }

            Text("Тестовая база создана в Supabase Cloud; продакшен для РФ-аудитории остается отдельным решением.")
                .font(.caption)
                .foregroundStyle(SchoolTheme.muted)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                MoreMetric(value: "\(supabaseConfig.expectedTableCount)", title: "таблиц", color: SchoolTheme.success)
                Divider()
                MoreMetric(value: "\(supabaseConfig.expectedPolicyCount)", title: "политик", color: SchoolTheme.accent)
                Divider()
                MoreMetric(value: supabaseConfig.hasClientApiKey ? supabaseConfig.clientKeyKind : "нет", title: "client key", color: supabaseConfig.hasClientApiKey ? SchoolTheme.success : SchoolTheme.warning)
            }
            .frame(height: 54)

            ForEach(probes) { probe in
                supabaseProbeRow(probe)
            }

            supabaseAuthSessionCard(supabaseAuthSession)
            supabaseStoredSeedSessionCard(supabaseStoredSeedSession)
            supabasePasswordSignInCard(supabasePasswordSignIn)
            supabaseSessionRefreshCard(supabaseSessionRefresh)
            supabaseSignedProfileCard(supabaseSignedProfile)
            supabaseSignedClassScopeCard(supabaseSignedClassScope)
            supabaseSignedChildrenCard(supabaseSignedChildren)
            supabaseSignedAnnouncementsCard(supabaseSignedAnnouncements)
            supabaseSignedHomeworkCard(supabaseSignedHomework)
            supabaseSignedCalendarEventsCard(supabaseSignedCalendarEvents)
            supabaseSignedCollectionsCard(supabaseSignedCollections)
            supabaseAnnouncementReadAckCard(supabaseAnnouncementReadAck)
            supabaseChildSourcePreviewCard
            supabaseRlsSmokeCard(supabaseRlsSmoke)
            supabaseLiveProbeCard(supabaseLiveProbe)

            Button {
                runSupabaseReadiness()
            } label: {
                Label("Проверить Supabase readiness", systemImage: "checkmark.seal.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SchoolTheme.accent)
                    .frame(maxWidth: .infinity, minHeight: 38)
                    .background(SchoolTheme.accent.opacity(0.11), in: Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("sync.supabase-readiness")

            Button {
                runSupabaseAuthSessionReadiness()
            } label: {
                Label("Проверить auth session", systemImage: "person.badge.key.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SchoolTheme.warning)
                    .frame(maxWidth: .infinity, minHeight: 38)
                    .background(SchoolTheme.warning.opacity(0.11), in: Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("sync.supabase-auth-session")

            Button {
                Task {
                    await runSupabasePasswordSignInProbe()
                }
            } label: {
                Label("Войти seed user", systemImage: "key.radiowaves.forward.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SchoolTheme.accent)
                    .frame(maxWidth: .infinity, minHeight: 38)
                    .background(SchoolTheme.accent.opacity(0.11), in: Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("sync.supabase-password-sign-in")

            if supabaseConfig.storedSeedSession != nil {
                Button {
                    clearSupabaseStoredSeedSession()
                } label: {
                    Label("Очистить seed session", systemImage: "trash.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(SchoolTheme.danger)
                        .frame(maxWidth: .infinity, minHeight: 38)
                        .background(SchoolTheme.danger.opacity(0.10), in: Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("sync.supabase-session-clear")
            }

            Button {
                Task {
                    await runSupabaseSessionRefreshProbe()
                }
            } label: {
                Label("Обновить auth token", systemImage: "arrow.clockwise.circle.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SchoolTheme.accent)
                    .frame(maxWidth: .infinity, minHeight: 38)
                    .background(SchoolTheme.accent.opacity(0.11), in: Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("sync.supabase-refresh-session")

            Button {
                Task {
                    await runSupabaseSignedProfileProbe()
                }
            } label: {
                Label("Проверить signed profile", systemImage: "person.text.rectangle.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SchoolTheme.success)
                    .frame(maxWidth: .infinity, minHeight: 38)
                    .background(SchoolTheme.success.opacity(0.11), in: Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("sync.supabase-signed-profile")

            Button {
                Task {
                    await runSupabaseSignedClassScopeProbe()
                }
            } label: {
                Label("Проверить signed classes", systemImage: "person.3.sequence.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SchoolTheme.success)
                    .frame(maxWidth: .infinity, minHeight: 38)
                    .background(SchoolTheme.success.opacity(0.11), in: Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("sync.supabase-signed-class-scope")

            Button {
                Task {
                    await runSupabaseSignedChildrenProbe()
                }
            } label: {
                Label("Проверить signed children", systemImage: "figure.2.and.child.holdinghands")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SchoolTheme.success)
                    .frame(maxWidth: .infinity, minHeight: 38)
                    .background(SchoolTheme.success.opacity(0.11), in: Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("sync.supabase-signed-children")

            Button {
                Task {
                    await runSupabaseSignedAnnouncementsProbe()
                }
            } label: {
                Label("Проверить signed announcements", systemImage: "megaphone.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SchoolTheme.success)
                    .frame(maxWidth: .infinity, minHeight: 38)
                    .background(SchoolTheme.success.opacity(0.11), in: Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("sync.supabase-signed-announcements")

            Button {
                Task {
                    await runSupabaseSignedHomeworkProbe()
                }
            } label: {
                Label("Проверить signed homework", systemImage: "book.closed.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SchoolTheme.success)
                    .frame(maxWidth: .infinity, minHeight: 38)
                    .background(SchoolTheme.success.opacity(0.11), in: Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("sync.supabase-signed-homework")

            Button {
                Task {
                    await runSupabaseSignedCalendarEventsProbe()
                }
            } label: {
                Label("Проверить signed calendar", systemImage: "calendar.badge.checkmark")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SchoolTheme.success)
                    .frame(maxWidth: .infinity, minHeight: 38)
                    .background(SchoolTheme.success.opacity(0.11), in: Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("sync.supabase-signed-calendar-events")

            Button {
                Task {
                    await runSupabaseSignedCollectionsProbe()
                }
            } label: {
                Label("Проверить signed collections", systemImage: "rublesign.circle.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SchoolTheme.success)
                    .frame(maxWidth: .infinity, minHeight: 38)
                    .background(SchoolTheme.success.opacity(0.11), in: Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("sync.supabase-signed-collections")

            Button {
                Task {
                    await runSupabaseAnnouncementReadAck()
                }
            } label: {
                Label("Отметить announcement read", systemImage: "checkmark.message.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SchoolTheme.success)
                    .frame(maxWidth: .infinity, minHeight: 38)
                    .background(SchoolTheme.success.opacity(0.11), in: Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("sync.supabase-announcement-read-ack")

            Button {
                Task {
                    await runSupabaseLiveProbe()
                }
            } label: {
                Label("Запустить live REST probe", systemImage: "dot.radiowaves.left.and.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SchoolTheme.success)
                    .frame(maxWidth: .infinity, minHeight: 38)
                    .background(SchoolTheme.success.opacity(0.11), in: Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("sync.supabase-live-probe")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var networkFailureDrillCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                Label("Ошибки сети и повтор", systemImage: "wifi.exclamationmark")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite)
                Spacer()
                StatusBadge(text: "queue safe", color: SchoolTheme.warning)
            }

            Text("Пользовательские данные не теряются: локальная операция остается в очереди, повтор идет с backoff, а 401/403 не обходятся на устройстве.")
                .font(.caption)
                .foregroundStyle(SchoolTheme.muted)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                MoreMetric(value: "\(SyncNetworkFailureScenario.sample.count)", title: "сценария", color: SchoolTheme.warning)
                Divider()
                MoreMetric(value: "\(operations.filter { $0.status.hasPrefix("Retry") || $0.status == "Offline" }.count)", title: "в очереди", color: SchoolTheme.accent)
                Divider()
                MoreMetric(value: "0", title: "потерь", color: SchoolTheme.success)
            }
            .frame(height: 54)

            syncActionButton("Сымитировать сбой сети", icon: "antenna.radiowaves.left.and.right.slash", color: SchoolTheme.warning) {
                simulateNetworkError()
            }
            .accessibilityIdentifier("sync.simulate-network-error")

            VStack(alignment: .leading, spacing: 8) {
                ForEach(SyncNetworkFailureScenario.sample) { scenario in
                    networkFailureScenarioRow(scenario)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func syncStateRow(icon: String, color: Color, title: String, detail: String) -> some View {
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

    private func apiReadinessRow(_ item: ApiReadinessItem) -> some View {
        HStack(alignment: .top, spacing: 12) {
            IconBadge(systemName: item.iconName, color: moreColor(for: item.colorName), size: 38)
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(item.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SchoolTheme.graphite)
                        .fixedSize(horizontal: false, vertical: true)
                    StatusBadge(text: item.status, color: statusColor(item.status))
                }

                Text(item.artifact)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)

                Text(item.detail)
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(.vertical, 2)
    }

    private func operationRow(_ operation: SyncOperationSummary) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(alignment: .top, spacing: 12) {
                IconBadge(systemName: operation.iconName, color: moreColor(for: operation.colorName), size: 42)
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(operation.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(SchoolTheme.graphite)
                            .fixedSize(horizontal: false, vertical: true)
                        StatusBadge(text: operation.status, color: statusColor(operation.status))
                    }
                    Text("\(operation.entity) - \(operation.endpoint)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                        .fixedSize(horizontal: false, vertical: true)
                    Text("\(operation.operation) v\(operation.baseVersion) - \(operation.payloadPreview)")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(SchoolTheme.accent)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)
                    Text(operation.retryPolicy)
                        .font(.caption)
                        .foregroundStyle(SchoolTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(operation.conflictRule)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(SchoolTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }

            HStack(spacing: 8) {
                syncActionButton("Готово", icon: "checkmark", color: SchoolTheme.success) {
                    update(operation) { item in
                        item.status = "Синхронизировано"
                        item.colorName = "green"
                    }
                }
                syncActionButton("Повтор", icon: "arrow.clockwise", color: SchoolTheme.accent) {
                    update(operation) { item in
                        item.status = "В очереди"
                        item.colorName = "blue"
                    }
                }
                syncActionButton("Storage", icon: "folder.badge.gearshape", color: SchoolTheme.warning) {
                    update(operation) { item in
                        item.status = "Нужен storage"
                        item.colorName = "orange"
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func endpointRow(_ endpoint: SyncEndpointKind) -> some View {
        HStack(alignment: .top, spacing: 12) {
            IconBadge(systemName: endpoint.iconName, color: endpointColor(endpoint), size: 38)
            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(endpoint.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SchoolTheme.graphite)
                    StatusBadge(text: endpoint.method, color: endpointColor(endpoint))
                }

                Text(endpoint.path)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite.opacity(0.76))
                    .fixedSize(horizontal: false, vertical: true)

                Text("\(endpoint.entity) - \(endpoint.risk)")
                    .font(.caption2)
                    .foregroundStyle(SchoolTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
    }

    private func permissionRuleRow(_ rule: BackendPermissionRule) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(alignment: .top, spacing: 12) {
                IconBadge(systemName: "lock.shield.fill", color: SchoolTheme.success, size: 38)
                VStack(alignment: .leading, spacing: 4) {
                    Text(rule.action)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(SchoolTheme.graphite)
                        .fixedSize(horizontal: false, vertical: true)

                    Text("\(rule.endpoint.contractLine) - \(rule.auditReason)")
                        .font(.caption)
                        .foregroundStyle(SchoolTheme.muted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }

            HStack(spacing: 6) {
                permissionChip("Родитель", rule.parent)
                permissionChip("Родком", rule.committee)
                permissionChip("Учитель", rule.teacher)
                permissionChip("Ребенок", rule.child)
            }
        }
        .padding(.vertical, 3)
    }

    private func permissionChip(_ title: String, _ decision: BackendPermissionRule.Decision) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text(decision.rawValue)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(decision.color)
                .lineLimit(1)
                .minimumScaleFactor(0.68)
        }
        .frame(maxWidth: .infinity, minHeight: 38)
        .background(decision.color.opacity(0.10), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func dryRunCard(_ result: SyncDryRunResult) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(result.requestID)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(SchoolTheme.graphite)
                Spacer()
                StatusBadge(text: result.environment.title, color: SchoolTheme.accent)
            }

            Text(result.summary)
                .font(.caption)
                .foregroundStyle(SchoolTheme.muted)
                .fixedSize(horizontal: false, vertical: true)

            syncRequestPreviewCard(result.requestPreview)
            syncAuthPreviewCard(result.authContext)
            syncStoragePreviewCard(result.storagePreflight)
            syncNetworkReadinessCard(result.networkReadiness)
            syncClientPreviewCard(result.clientPreview)

            HStack(spacing: 10) {
                MoreMetric(value: "\(result.acceptedCount)", title: "можно", color: SchoolTheme.success)
                Divider()
                MoreMetric(value: "\(result.queuedCount)", title: "очередь", color: SchoolTheme.warning)
                Divider()
                MoreMetric(value: "\(result.blockedCount)", title: "блок", color: SchoolTheme.danger)
            }
            .frame(height: 54)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(result.mutations.prefix(3)) { mutation in
                    mutationPreviewRow(mutation)
                }
            }
        }
        .padding(12)
        .background(SchoolTheme.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func networkFailureScenarioRow(_ scenario: SyncNetworkFailureScenario) -> some View {
        HStack(alignment: .top, spacing: 10) {
            IconBadge(systemName: "arrow.triangle.2.circlepath", color: moreColor(for: scenario.colorName), size: 34)
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(scenario.title)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(SchoolTheme.graphite)
                        .lineLimit(1)
                        .minimumScaleFactor(0.76)
                    Spacer()
                    StatusBadge(text: scenario.badge, color: moreColor(for: scenario.colorName))
                }

                Text(scenario.detail)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)

                Text(scenario.userMessage)
                    .font(.caption2)
                    .foregroundStyle(SchoolTheme.muted)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)

                Text("\(scenario.queuePolicy) - \(scenario.retryPlan)")
                    .font(.caption2)
                    .foregroundStyle(SchoolTheme.muted)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
            }
        }
        .padding(8)
        .background(moreColor(for: scenario.colorName).opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func supabaseProbeRow(_ probe: SupabaseReadinessProbe) -> some View {
        HStack(alignment: .top, spacing: 10) {
            IconBadge(systemName: probe.iconName, color: moreColor(for: probe.statusColorName), size: 34)
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(probe.title)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(SchoolTheme.graphite)
                        .lineLimit(1)
                        .minimumScaleFactor(0.76)
                    Spacer()
                    StatusBadge(text: probe.status, color: moreColor(for: probe.statusColorName))
                }

                Text(probe.endpoint)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                    .lineLimit(1)
                    .minimumScaleFactor(0.56)

                Text(probe.detail)
                    .font(.caption2)
                    .foregroundStyle(SchoolTheme.muted)
                    .lineLimit(2)
                    .minimumScaleFactor(0.76)

                Text(probe.nextStep)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(SchoolTheme.muted)
                    .lineLimit(2)
                    .minimumScaleFactor(0.72)
            }
        }
        .padding(8)
        .background(moreColor(for: probe.statusColorName).opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func supabaseLiveProbeCard(_ result: SupabaseLiveProbeResult) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Label(result.title, systemImage: "dot.radiowaves.left.and.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(SchoolTheme.graphite)
                Spacer()
                StatusBadge(text: result.status, color: moreColor(for: result.statusColorName))
            }

            Text("\(result.method) \(result.path)")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(result.url)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.62)

            Text(result.headerState)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(moreColor(for: result.statusColorName))
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(result.detail)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.74)

            Text(result.nextStep)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text("Rows: \(result.rowsPreview)")
                .font(.caption2.monospaced())
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(2)
                .minimumScaleFactor(0.64)
        }
        .padding(10)
        .background(moreColor(for: result.statusColorName).opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func supabaseAuthSessionCard(_ session: SupabaseAuthSessionProbe) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Label(session.title, systemImage: "person.badge.key.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(SchoolTheme.graphite)
                Spacer()
                StatusBadge(text: session.status, color: moreColor(for: session.statusColorName))
            }

            Text(session.authURL)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(1)
                .minimumScaleFactor(0.62)

            Text(session.userState)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text(session.tokenState)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(moreColor(for: session.statusColorName))
                .lineLimit(1)
                .minimumScaleFactor(0.70)

            Text(session.refreshState)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.74)

            Text(session.rlsState)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(session.nextStep)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
        }
        .padding(10)
        .background(moreColor(for: session.statusColorName).opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func supabaseStoredSeedSessionCard(_ session: SupabaseStoredSeedSessionProbe) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Label(session.title, systemImage: "internaldrive.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(SchoolTheme.graphite)
                Spacer()
                StatusBadge(text: session.status, color: moreColor(for: session.statusColorName))
            }

            Text(session.sourceState)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(moreColor(for: session.statusColorName))
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text(session.tokenState)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(session.userState)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(session.expiryState)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(session.nextStep)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
        }
        .padding(10)
        .background(moreColor(for: session.statusColorName).opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func supabasePasswordSignInCard(_ signIn: SupabasePasswordSignInProbe) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Label(signIn.title, systemImage: "key.radiowaves.forward.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(SchoolTheme.graphite)
                Spacer()
                StatusBadge(text: signIn.status, color: moreColor(for: signIn.statusColorName))
            }

            Text(signIn.endpoint)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(1)
                .minimumScaleFactor(0.52)

            Text(signIn.credentialState)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(moreColor(for: signIn.statusColorName))
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(signIn.sessionState)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(signIn.nextStep)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
        }
        .padding(10)
        .background(moreColor(for: signIn.statusColorName).opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func supabaseSessionRefreshCard(_ refresh: SupabaseSessionRefreshProbe) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Label(refresh.title, systemImage: "arrow.clockwise.circle.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(SchoolTheme.graphite)
                Spacer()
                StatusBadge(text: refresh.status, color: moreColor(for: refresh.statusColorName))
            }

            Text(refresh.endpoint)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(1)
                .minimumScaleFactor(0.52)

            Text(refresh.headerState)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(moreColor(for: refresh.statusColorName))
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(refresh.tokenState)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(refresh.refreshState)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(refresh.nextStep)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
        }
        .padding(10)
        .background(moreColor(for: refresh.statusColorName).opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func supabaseSignedProfileCard(_ result: SupabaseSignedProfileProbe) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Label(result.title, systemImage: "person.text.rectangle.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(SchoolTheme.graphite)
                Spacer()
                StatusBadge(text: result.status, color: moreColor(for: result.statusColorName))
            }

            Text("\(result.method) \(result.path)")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(2)
                .minimumScaleFactor(0.60)

            Text(result.url)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.62)

            Text(result.headerState)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(moreColor(for: result.statusColorName))
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(result.detail)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(result.nextStep)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text("Rows: \(result.rowsPreview)")
                .font(.caption2.monospaced())
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(2)
                .minimumScaleFactor(0.64)
        }
        .padding(10)
        .background(moreColor(for: result.statusColorName).opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func supabaseSignedClassScopeCard(_ result: SupabaseSignedClassScopeProbe) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Label(result.title, systemImage: "person.3.sequence.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(SchoolTheme.graphite)
                Spacer()
                StatusBadge(text: result.status, color: moreColor(for: result.statusColorName))
            }

            Text("\(result.method) \(result.path)")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(2)
                .minimumScaleFactor(0.50)

            Text(result.url)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.62)

            Text(result.headerState)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(moreColor(for: result.statusColorName))
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(result.detail)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(result.nextStep)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text("Rows: \(result.rowsPreview)")
                .font(.caption2.monospaced())
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(2)
                .minimumScaleFactor(0.64)

            Text("Mapped context: \(result.localContextPreview)")
                .font(.caption2.monospaced())
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(2)
                .minimumScaleFactor(0.64)

            Text(result.bridgePreview)
                .font(.caption2.monospaced())
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(2)
                .minimumScaleFactor(0.64)
        }
        .padding(10)
        .background(moreColor(for: result.statusColorName).opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func supabaseSignedChildrenCard(_ result: SupabaseSignedChildrenProbe) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Label(result.title, systemImage: "figure.2.and.child.holdinghands")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(SchoolTheme.graphite)
                Spacer()
                StatusBadge(text: result.status, color: moreColor(for: result.statusColorName))
            }

            Text("\(result.method) \(result.path)")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(2)
                .minimumScaleFactor(0.50)

            Text(result.url)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.62)

            Text(result.headerState)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(moreColor(for: result.statusColorName))
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(result.detail)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(result.nextStep)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text("Rows: \(result.rowsPreview)")
                .font(.caption2.monospaced())
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(2)
                .minimumScaleFactor(0.64)

            Text("Mapped child: \(result.localContextPreview)")
                .font(.caption2.monospaced())
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(2)
                .minimumScaleFactor(0.64)

            Text(result.bridgePreview)
                .font(.caption2.monospaced())
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(2)
                .minimumScaleFactor(0.64)
        }
        .padding(10)
        .background(moreColor(for: result.statusColorName).opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func supabaseSignedAnnouncementsCard(_ result: SupabaseSignedAnnouncementsProbe) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Label(result.title, systemImage: "megaphone.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(SchoolTheme.graphite)
                Spacer()
                StatusBadge(text: result.status, color: moreColor(for: result.statusColorName))
            }

            Text("\(result.method) \(result.path)")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(2)
                .minimumScaleFactor(0.46)

            Text(result.url)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.62)

            Text(result.headerState)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(moreColor(for: result.statusColorName))
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(result.detail)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(result.nextStep)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text("Rows: \(result.rowsPreview)")
                .font(.caption2.monospaced())
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(2)
                .minimumScaleFactor(0.64)

            Text(result.bridgePreview)
                .font(.caption2.monospaced())
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(2)
                .minimumScaleFactor(0.64)
        }
        .padding(10)
        .background(moreColor(for: result.statusColorName).opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func supabaseSignedHomeworkCard(_ result: SupabaseSignedHomeworkProbe) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Label(result.title, systemImage: "book.closed.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(SchoolTheme.graphite)
                Spacer()
                StatusBadge(text: result.status, color: moreColor(for: result.statusColorName))
            }

            Text("\(result.method) \(result.path)")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(2)
                .minimumScaleFactor(0.46)

            Text(result.url)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.62)

            Text(result.headerState)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(moreColor(for: result.statusColorName))
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(result.detail)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(result.nextStep)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text("Rows: \(result.rowsPreview)")
                .font(.caption2.monospaced())
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(2)
                .minimumScaleFactor(0.64)

            Text(result.bridgePreview)
                .font(.caption2.monospaced())
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(2)
                .minimumScaleFactor(0.64)
        }
        .padding(10)
        .background(moreColor(for: result.statusColorName).opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func supabaseSignedCalendarEventsCard(_ result: SupabaseSignedCalendarEventsProbe) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Label(result.title, systemImage: "calendar.badge.checkmark")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(SchoolTheme.graphite)
                Spacer()
                StatusBadge(text: result.status, color: moreColor(for: result.statusColorName))
            }

            Text("\(result.method) \(result.path)")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(2)
                .minimumScaleFactor(0.46)

            Text(result.url)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.62)

            Text(result.headerState)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(moreColor(for: result.statusColorName))
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(result.detail)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(result.nextStep)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text("Rows: \(result.rowsPreview)")
                .font(.caption2.monospaced())
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(2)
                .minimumScaleFactor(0.64)

            Text(result.bridgePreview)
                .font(.caption2.monospaced())
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(2)
                .minimumScaleFactor(0.64)
        }
        .padding(10)
        .background(moreColor(for: result.statusColorName).opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func supabaseSignedCollectionsCard(_ result: SupabaseSignedCollectionsProbe) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Label(result.title, systemImage: "rublesign.circle.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(SchoolTheme.graphite)
                Spacer()
                StatusBadge(text: result.status, color: moreColor(for: result.statusColorName))
            }

            Text("\(result.method) \(result.path)")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(2)
                .minimumScaleFactor(0.46)

            Text(result.url)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.62)

            Text(result.headerState)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(moreColor(for: result.statusColorName))
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(result.detail)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(result.nextStep)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text("Rows: \(result.rowsPreview)")
                .font(.caption2.monospaced())
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(2)
                .minimumScaleFactor(0.64)

            Text(result.bridgePreview)
                .font(.caption2.monospaced())
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(2)
                .minimumScaleFactor(0.64)
        }
        .padding(10)
        .background(moreColor(for: result.statusColorName).opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func supabaseAnnouncementReadAckCard(_ result: SupabaseAnnouncementReadAckResult) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Label(result.title, systemImage: "checkmark.message.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(SchoolTheme.graphite)
                Spacer()
                StatusBadge(text: result.status, color: moreColor(for: result.statusColorName))
            }

            Text("\(result.method) \(result.path)")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(1)
                .minimumScaleFactor(0.58)

            Text(result.url)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.62)

            Text(result.headerState)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(moreColor(for: result.statusColorName))
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(result.detail)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(result.nextStep)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text("Target: \(result.targetPreview)")
                .font(.caption2.monospaced())
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(2)
                .minimumScaleFactor(0.58)
        }
        .padding(10)
        .background(moreColor(for: result.statusColorName).opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var supabaseChildSourcePreviewCard: some View {
        let bridgeChildren = AppSupabaseChildContextBridge.childSummaries(
            classContexts: AppSupabaseClassContextBridge.contexts
        )
        let primaryChild = bridgeChildren.first
        let isReady = primaryChild != nil

        return VStack(alignment: .leading, spacing: 7) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Label("Supabase child source", systemImage: "arrow.triangle.branch")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(SchoolTheme.graphite)
                Spacer()
                StatusBadge(
                    text: usesSupabaseChildSourcePreview && isReady ? "preview on" : "local",
                    color: usesSupabaseChildSourcePreview && isReady ? SchoolTheme.success : SchoolTheme.warning
                )
            }

            Text(AppChildStore.sourceModeText)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(usesSupabaseChildSourcePreview && isReady ? SchoolTheme.success : SchoolTheme.muted)
                .accessibilityIdentifier("sync.supabase-child-source-state")

            Text(primaryChild.map { "\($0.name), \($0.className), код \($0.classCode)" } ?? "Bridge пуст: сначала нужен signed children probe или QA seed")
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            HStack(spacing: 8) {
                Button {
                    enableSupabaseChildSourcePreview()
                } label: {
                    Label("Включить источник", systemImage: "checkmark.circle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(SchoolTheme.success)
                        .frame(maxWidth: .infinity, minHeight: 36)
                        .background(SchoolTheme.success.opacity(0.11), in: Capsule())
                }
                .buttonStyle(.plain)
                .disabled(!isReady)
                .opacity(isReady ? 1 : 0.55)
                .accessibilityIdentifier("sync.supabase-child-source-enable")

                Button {
                    disableSupabaseChildSourcePreview()
                } label: {
                    Label("Локальные дети", systemImage: "arrow.uturn.left.circle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(SchoolTheme.warning)
                        .frame(maxWidth: .infinity, minHeight: 36)
                        .background(SchoolTheme.warning.opacity(0.11), in: Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("sync.supabase-child-source-disable")
            }
        }
        .padding(10)
        .background((usesSupabaseChildSourcePreview && isReady ? SchoolTheme.success : SchoolTheme.warning).opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func supabaseRlsSmokeCard(_ smoke: SupabaseRlsSmokeProbe) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Label(smoke.title, systemImage: "lock.shield.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(SchoolTheme.graphite)
                Spacer()
                StatusBadge(text: smoke.status, color: moreColor(for: smoke.statusColorName))
            }

            Text(smoke.seedUser)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(1)
                .minimumScaleFactor(0.58)

            Text(smoke.parentResult)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.success)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(smoke.teacherResult)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(smoke.anonResult)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text(smoke.writeResult)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.success)
                .lineLimit(2)
                .minimumScaleFactor(0.70)

            Text(smoke.nextStep)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.70)
        }
        .padding(10)
        .background(moreColor(for: smoke.statusColorName).opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func syncClientPreviewCard(_ client: SyncClientPreview) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Label("Swift client", systemImage: "curlybraces.square.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(SchoolTheme.graphite)
                Spacer()
                StatusBadge(text: "typed", color: SchoolTheme.success)
            }

            Text(client.transport)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            Text(client.resultType)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            Text(client.requestState)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            Text(client.responseState)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            Text(client.retryPlan)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.76)

            Text(client.serverVersionPlan)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.76)

            Text(client.failureMapping)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.76)
        }
        .padding(10)
        .background(.white.opacity(0.74), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func syncNetworkReadinessCard(_ readiness: SyncNetworkReadiness) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Label("Network readiness", systemImage: "network")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(SchoolTheme.graphite)
                Spacer()
                StatusBadge(text: readiness.status, color: moreColor(for: readiness.statusColorName))
            }

            Text(readiness.mode)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text("\(readiness.healthcheckPath) - \(readiness.baseURL)")
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.62)

            Text(readiness.timeoutPolicy)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.76)

            Text(readiness.retryPolicy)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.74)

            Text(readiness.authFailurePolicy)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.74)

            Text(readiness.releaseGate)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(moreColor(for: readiness.statusColorName))
                .lineLimit(2)
                .minimumScaleFactor(0.72)
        }
        .padding(10)
        .background(moreColor(for: readiness.statusColorName).opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func syncAuthPreviewCard(_ auth: SyncAuthContext) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Label("Auth context", systemImage: "person.badge.key.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(SchoolTheme.graphite)
                Spacer()
                StatusBadge(text: "typed", color: SchoolTheme.success)
            }

            Text("\(auth.userID) - \(auth.sessionState)")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(1)
                .minimumScaleFactor(0.74)

            Text(auth.roleClaim)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.74)

            Text(auth.refreshPlan)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.76)

            Text(auth.serverPolicy)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.76)
        }
        .padding(10)
        .background(.white.opacity(0.74), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func syncStoragePreviewCard(_ storage: SyncStoragePreflight) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Label("Storage preflight", systemImage: "externaldrive.badge.checkmark")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(SchoolTheme.graphite)
                Spacer()
                StatusBadge(text: storage.pendingUploads == 0 ? "clear" : "blocked", color: storage.pendingUploads == 0 ? SchoolTheme.success : SchoolTheme.warning)
            }

            Text(storage.bucket)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text("\(storage.pendingUploads) upload before metadata, \(storage.metadataReady) metadata-ready")
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.74)

            Text(storage.signedURLPlan)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.76)

            Text(storage.privacyRule)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.76)

            Text(storage.blockedReason)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(storage.pendingUploads == 0 ? SchoolTheme.success : SchoolTheme.warning)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            ForEach(storage.uploadIntents.prefix(2)) { intent in
                uploadIntentRow(intent)
            }

            ForEach(storage.signedResponses.prefix(2)) { response in
                signedUploadResponseRow(response)
            }

            ForEach(storage.scanGates.prefix(2)) { gate in
                fileScanGateRow(gate)
            }

            ForEach(storage.metadataReleases.prefix(2)) { release in
                metadataReleaseRow(release)
            }
        }
        .padding(10)
        .background(.white.opacity(0.74), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func uploadIntentRow(_ intent: SyncUploadIntentPreview) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                StatusBadge(text: intent.kind, color: SchoolTheme.accent)
                Text(intent.fileName)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(SchoolTheme.graphite)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                Spacer()
            }

            Text("\(intent.endpoint) - \(intent.mimeType), \(formattedBytes(intent.sizeBytes))")
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text("\(intent.checksumPreview) - \(intent.metadataPlan)")
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.74)
        }
        .padding(8)
        .background(SchoolTheme.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func signedUploadResponseRow(_ response: SyncSignedUploadResponsePreview) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                StatusBadge(text: response.method, color: SchoolTheme.success)
                Text(response.fileID)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(SchoolTheme.graphite)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                Spacer()
                Text(response.expiresAt)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(SchoolTheme.warning)
            }

            Text(response.uploadURL)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(1)
                .minimumScaleFactor(0.68)

            Text("\(response.privateBucket) - \(response.storageKey)")
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text("\(response.requiredHeader) - \(response.metadataPlan)")
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
        }
        .padding(8)
        .background(SchoolTheme.success.opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func fileScanGateRow(_ gate: SyncFileScanGatePreview) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                StatusBadge(text: gate.status, color: SchoolTheme.warning)
                Text(gate.fileID)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(SchoolTheme.graphite)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                Spacer()
            }

            Text("\(gate.queue) - \(gate.moderationRule)")
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(gate.metadataGate)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.warning)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
        }
        .padding(8)
        .background(SchoolTheme.warning.opacity(0.10), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func metadataReleaseRow(_ release: SyncMetadataReleasePreview) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                StatusBadge(text: release.releaseStatus, color: SchoolTheme.warning)
                Text(release.mutationID)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(SchoolTheme.graphite)
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)
                Spacer()
            }

            Text(release.payloadPatch)
                .font(.caption2.monospaced())
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(1)
                .minimumScaleFactor(0.62)

            Text(release.unlockRule)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
        }
        .padding(8)
        .background(SchoolTheme.warning.opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func formattedBytes(_ bytes: Int) -> String {
        ByteCountFormatter.string(fromByteCount: Int64(bytes), countStyle: .file)
    }

    private func syncRequestPreviewCard(_ request: SyncRequestPreview) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                StatusBadge(text: request.method, color: SchoolTheme.accent)
                Text(request.path)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(SchoolTheme.graphite)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                Spacer()
            }

            Text(request.url)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text("\(request.authState) - Idempotency-Key: \(request.idempotencyKey)")
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.78)

            Text(request.bodyPreview)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(3)
                .minimumScaleFactor(0.70)
        }
        .padding(10)
        .background(.white.opacity(0.74), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func mutationPreviewRow(_ mutation: SyncMutationPreview) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(mutation.mutationID)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(SchoolTheme.graphite)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                Spacer()
                StatusBadge(text: mutation.status, color: mutationStatusColor(mutation.status))
            }

            Text("\(mutation.endpoint) - \(mutation.operation) v\(mutation.baseVersion)")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(SchoolTheme.graphite.opacity(0.72))
                .lineLimit(2)
                .minimumScaleFactor(0.82)

            Text(mutation.payloadPreview)
                .font(.caption2)
                .foregroundStyle(SchoolTheme.muted)
                .lineLimit(2)
                .minimumScaleFactor(0.78)
        }
        .padding(8)
        .background(.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func syncActionButton(_ title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(color)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
                .frame(maxWidth: .infinity, minHeight: 34)
                .background(color.opacity(0.11), in: Capsule())
        }
        .buttonStyle(.plain)
    }

    private func statusColor(_ status: String) -> Color {
        switch status {
        case "Синхронизировано", "Готово к API", "Готово":
            SchoolTheme.success
        case "Нужен storage", "Offline", "Дальше", "Частично":
            SchoolTheme.warning
        case "Конфликт", "Блокер":
            SchoolTheme.danger
        default:
            status.hasPrefix("Retry") ? SchoolTheme.warning : SchoolTheme.accent
        }
    }

    private func mutationStatusColor(_ status: String) -> Color {
        switch status {
        case "accepted":
            SchoolTheme.success
        case "blocked":
            SchoolTheme.danger
        default:
            SchoolTheme.warning
        }
    }

    private func endpointColor(_ endpoint: SyncEndpointKind) -> Color {
        switch endpoint {
        case .classRoom, .announcementRead:
            SchoolTheme.success
        case .homework, .familyInvite, .signedUpload:
            SchoolTheme.accent
        case .receipt, .photo:
            SchoolTheme.warning
        }
    }

    private func update(_ operation: SyncOperationSummary, mutate: (inout SyncOperationSummary) -> Void) {
        guard let index = operations.firstIndex(where: { $0.id == operation.id }) else {
            return
        }

        mutate(&operations[index])
    }

    private func addInviteOperation() {
        operations.insert(
            SyncOperationSummary(
                title: "Отправить приглашение семье",
                entity: "class_invite",
                endpoint: "POST /classes/{id}/invites",
                status: "В очереди",
                payloadPreview: #"{"scope":"family","expiresInDays":7}"#,
                retryPolicy: "Повторить до получения invite token",
                conflictRule: "Повторная отправка возвращает тот же активный invite",
                iconName: "person.badge.plus",
                colorName: "blue"
            ),
            at: 0
        )
        syncStatus = "Добавлена локальная операция приглашения: должна уйти в backend после подключения API."
    }

    private func runDrySync() {
        dryRunResult = SyncDryRunResult.make(environment: environment, operations: operations)
        syncStatus = "Dry-run подготовил запросы для \(environment.title): сеть не вызывается, но операции разложены по готовности."
    }

    private func markAllSynced() {
        for index in operations.indices {
            operations[index].status = "Синхронизировано"
            operations[index].colorName = "green"
        }
        syncStatus = "Локально сымитирована успешная синхронизация всех операций."
    }

    private func simulateOffline() {
        guard !operations.isEmpty else {
            return
        }

        operations[0].status = "Offline"
        operations[0].colorName = "orange"
        syncStatus = "Offline-сценарий: операция остается в очереди, пользовательские данные не теряются."
    }

    private func simulateConflict() {
        guard !operations.isEmpty else {
            return
        }

        operations[0].status = "Конфликт"
        operations[0].colorName = "red"
        syncStatus = "Конфликт: нужна серверная версия, правило merge и запись в AuditLog."
    }

    private func simulateNetworkError() {
        guard !operations.isEmpty else {
            return
        }

        operations[0].status = "Retry 1/5"
        operations[0].colorName = "orange"
        operations[0].retryPolicy = "Timeout: сохранить mutationId, повторить через 15 секунд"
        operations[0].conflictRule = "Пользовательские данные не теряются; idempotency key не меняется"
        dryRunResult = SyncDryRunResult.make(environment: environment, operations: operations)
        syncStatus = "Timeout-сценарий: операция остается в очереди, данные сохранены локально, повтор запланирован."
    }

    private func reloadSupabaseProbeState() {
        supabaseConfig = SupabaseBackendConfig.make()
        supabaseAuthSession = SupabaseAuthSessionProbe.make(config: supabaseConfig)
        supabaseStoredSeedSession = SupabaseStoredSeedSessionProbe.make(config: supabaseConfig)
        supabasePasswordSignIn = SupabasePasswordSignInProbe.planned(config: supabaseConfig)
        supabaseSessionRefresh = SupabaseSessionRefreshProbe.planned(config: supabaseConfig)
        supabaseSignedProfile = SupabaseSignedProfileProbe.planned(config: supabaseConfig)
        supabaseSignedClassScope = SupabaseSignedClassScopeProbe.planned(config: supabaseConfig)
        supabaseSignedChildren = SupabaseSignedChildrenProbe.planned(config: supabaseConfig)
        supabaseSignedAnnouncements = SupabaseSignedAnnouncementsProbe.planned(config: supabaseConfig)
        supabaseSignedHomework = SupabaseSignedHomeworkProbe.planned(config: supabaseConfig)
        supabaseSignedCalendarEvents = SupabaseSignedCalendarEventsProbe.planned(config: supabaseConfig)
        supabaseSignedCollections = SupabaseSignedCollectionsProbe.planned(config: supabaseConfig)
        supabaseAnnouncementReadAck = SupabaseAnnouncementReadAckResult.planned(config: supabaseConfig)
        supabaseRlsSmoke = SupabaseRlsSmokeProbe.make(config: supabaseConfig)
        supabaseLiveProbe = SupabaseLiveProbeResult.planned(config: supabaseConfig)
    }

    private func runSupabaseReadiness() {
        reloadSupabaseProbeState()
        dryRunResult = SyncDryRunResult.make(environment: environment, operations: operations)
        syncStatus = supabaseConfig.hasClientApiKey
            ? "Supabase readiness готов: URL, client apikey, schema и private storage подготовлены для первого live-запроса."
            : "Supabase readiness частичный: schema и private storage готовы, live URLSession-запрос ждет SUPABASE_PUBLISHABLE_KEY или SUPABASE_ANON_KEY."
    }

    private func runSupabaseAuthSessionReadiness() {
        reloadSupabaseProbeState()
        syncStatus = supabaseConfig.hasAccessToken
            ? "Supabase auth session готовится к RLS-проверке: live probe пойдет с user bearer token."
            : "Supabase auth session не подключен: нужен SUPABASE_ACCESS_TOKEN, refresh token и seed membership."
    }

    @MainActor
    private func runSupabasePasswordSignInProbe() async {
        reloadSupabaseProbeState()
        syncStatus = "Supabase seed sign-in: готовлю password grant без замены локального входа; seed-сессия будет сохранена в Keychain для QA-probes."
        let signInResult = await SupabaseAuthClient.signInWithPassword(config: supabaseConfig)
        supabasePasswordSignIn = signInResult

        guard let session = signInResult.session,
              session.access_token?.isEmpty == false else {
            syncStatus = signInResult.status == "blocked" || signInResult.status == "credentials missing"
                ? "Supabase seed sign-in заблокирован: нужен client key, SUPABASE_TEST_EMAIL и SUPABASE_TEST_PASSWORD."
                : "Supabase seed sign-in завершен без пригодной сессии: \(signInResult.sessionState)"
            return
        }

        let storageSource = SupabaseSeedSessionStore.save(response: session, emailPreview: supabaseConfig.testEmailPreview)
        let signedConfig = supabaseConfig.applying(session: session)
        supabaseStoredSeedSession = SupabaseStoredSeedSessionProbe.make(config: SupabaseBackendConfig.make())
        supabaseConfig = signedConfig
        supabaseAuthSession = SupabaseAuthSessionProbe.make(config: signedConfig)
        supabaseSessionRefresh = SupabaseSessionRefreshProbe.success(config: signedConfig, response: session, statusCode: 200)

        let profile = await SupabaseSignedProfileClient.probeProfile(config: signedConfig)
        supabaseSignedProfile = profile

        let classScope = await SupabaseSignedClassScopeClient.probeClassScope(config: signedConfig)
        supabaseSignedClassScope = classScope
        if classScope.mappedContexts.isEmpty == false {
            let mappedAt = Date.now.formatted(date: .numeric, time: .shortened)
            AppSupabaseClassContextBridge.replace(
                with: classScope.mappedContexts.map { $0.bridgeItem(mappedAt: mappedAt) }
            )
        }

        let children = await SupabaseSignedChildrenClient.probeChildren(config: signedConfig)
        supabaseSignedChildren = children
        if children.mappedChildren.isEmpty == false {
            let mappedAt = Date.now.formatted(date: .numeric, time: .shortened)
            AppSupabaseChildContextBridge.replace(
                with: children.mappedChildren.map { $0.bridgeItem(mappedAt: mappedAt) }
            )
        }

        let announcements = await SupabaseSignedAnnouncementsClient.probeAnnouncements(config: signedConfig)
        supabaseSignedAnnouncements = announcements
        if announcements.mappedAnnouncements.isEmpty == false {
            AppSupabaseAnnouncementBridge.replace(with: announcements.mappedAnnouncements)
        }

        let homework = await SupabaseSignedHomeworkClient.probeHomework(config: signedConfig)
        supabaseSignedHomework = homework
        if homework.mappedHomework.isEmpty == false {
            AppSupabaseHomeworkBridge.replace(with: homework.mappedHomework)
        }

        let calendarEvents = await SupabaseSignedCalendarEventsClient.probeCalendarEvents(config: signedConfig)
        supabaseSignedCalendarEvents = calendarEvents
        if calendarEvents.mappedEvents.isEmpty == false {
            AppSupabaseCalendarEventBridge.replace(with: calendarEvents.mappedEvents)
        }

        let collections = await SupabaseSignedCollectionsClient.probeCollections(config: signedConfig)
        supabaseSignedCollections = collections
        if collections.mappedCollections.isEmpty == false {
            AppSupabaseCollectionBridge.replace(with: collections.mappedCollections)
        }
        supabaseAnnouncementReadAck = SupabaseAnnouncementReadAckResult.planned(config: signedConfig)

        supabaseLiveProbe = SupabaseLiveProbeResult.planned(config: signedConfig)
        syncStatus = "Supabase seed sign-in завершен: \(signInResult.sessionState). Seed-сессия сохранена: \(storageSource)."
    }

    @MainActor
    private func runSupabaseSessionRefreshProbe() async {
        reloadSupabaseProbeState()
        syncStatus = "Supabase auth refresh: готовлю POST /token?grant_type=refresh_token без замены локальной сессии."
        let result = await SupabaseAuthClient.refreshSession(config: supabaseConfig)
        supabaseSessionRefresh = result
        if let session = result.session,
           session.access_token?.isEmpty == false {
            let storageSource = SupabaseSeedSessionStore.save(
                response: session,
                emailPreview: supabaseConfig.storedSeedSession?.emailPreview,
                fallbackUserID: supabaseConfig.userID
            )
            supabaseConfig = SupabaseBackendConfig.make()
            supabaseAuthSession = SupabaseAuthSessionProbe.make(config: supabaseConfig)
            supabaseStoredSeedSession = SupabaseStoredSeedSessionProbe.make(config: supabaseConfig)
            supabaseLiveProbe = SupabaseLiveProbeResult.planned(config: supabaseConfig)
            syncStatus = "Supabase auth refresh завершен: \(result.headerState). Seed-сессия обновлена: \(storageSource)."
            return
        }
        syncStatus = result.status == "blocked" || result.status == "refresh missing"
            ? "Supabase auth refresh заблокирован: нужен client key и SUPABASE_REFRESH_TOKEN."
            : "Supabase auth refresh завершен: \(result.headerState). \(result.nextStep)"
    }

    @MainActor
    private func runSupabaseSignedProfileProbe() async {
        reloadSupabaseProbeState()
        syncStatus = "Supabase signed profile: готовлю GET /profiles с user bearer token без замены локального профиля."
        let result = await SupabaseSignedProfileClient.probeProfile(config: supabaseConfig)
        supabaseSignedProfile = result
        syncStatus = result.status == "blocked" || result.status == "token missing" || result.status == "user id missing"
            ? "Supabase signed profile заблокирован: нужен client key, SUPABASE_ACCESS_TOKEN и SUPABASE_USER_ID."
            : "Supabase signed profile завершен: \(result.headerState). \(result.nextStep)"
    }

    @MainActor
    private func runSupabaseSignedClassScopeProbe() async {
        reloadSupabaseProbeState()
        syncStatus = "Supabase signed classes: готовлю GET /class_members с embedded class_rooms без замены локальных классов."
        let result = await SupabaseSignedClassScopeClient.probeClassScope(config: supabaseConfig)
        supabaseSignedClassScope = result
        if result.mappedContexts.isEmpty == false {
            let mappedAt = Date.now.formatted(date: .numeric, time: .shortened)
            AppSupabaseClassContextBridge.replace(
                with: result.mappedContexts.map { $0.bridgeItem(mappedAt: mappedAt) }
            )
        }
        syncStatus = result.status == "blocked" || result.status == "token missing" || result.status == "user id missing"
            ? "Supabase signed classes заблокирован: нужен client key, SUPABASE_ACCESS_TOKEN и SUPABASE_USER_ID."
            : "Supabase signed classes завершен: \(result.headerState). \(result.nextStep)"
    }

    @MainActor
    private func runSupabaseSignedChildrenProbe() async {
        reloadSupabaseProbeState()
        syncStatus = "Supabase signed children: готовлю GET /children с embedded class_rooms без замены локального выбора ребенка."
        let result = await SupabaseSignedChildrenClient.probeChildren(config: supabaseConfig)
        supabaseSignedChildren = result
        if result.mappedChildren.isEmpty == false {
            let mappedAt = Date.now.formatted(date: .numeric, time: .shortened)
            AppSupabaseChildContextBridge.replace(
                with: result.mappedChildren.map { $0.bridgeItem(mappedAt: mappedAt) }
            )
        }
        syncStatus = result.status == "blocked" || result.status == "token missing" || result.status == "user id missing"
            ? "Supabase signed children заблокирован: нужен client key, SUPABASE_ACCESS_TOKEN и SUPABASE_USER_ID."
            : "Supabase signed children завершен: \(result.headerState). \(result.nextStep)"
    }

    @MainActor
    private func runSupabaseSignedAnnouncementsProbe() async {
        reloadSupabaseProbeState()
        syncStatus = "Supabase signed announcements: готовлю GET /announcements с read-state preview без замены локальной ленты."
        let result = await SupabaseSignedAnnouncementsClient.probeAnnouncements(config: supabaseConfig)
        supabaseSignedAnnouncements = result
        if result.mappedAnnouncements.isEmpty == false {
            AppSupabaseAnnouncementBridge.replace(with: result.mappedAnnouncements)
        }
        syncStatus = result.status == "blocked" || result.status == "token missing" || result.status == "user id missing" || result.status == "class missing"
            ? "Supabase signed announcements заблокирован: нужен client key, SUPABASE_ACCESS_TOKEN, SUPABASE_USER_ID и class bridge."
            : "Supabase signed announcements завершен: \(result.headerState). \(result.nextStep)"
    }

    @MainActor
    private func runSupabaseSignedHomeworkProbe() async {
        reloadSupabaseProbeState()
        syncStatus = "Supabase signed homework: готовлю GET /homework_items без замены локальных ДЗ."
        let result = await SupabaseSignedHomeworkClient.probeHomework(config: supabaseConfig)
        supabaseSignedHomework = result
        if result.mappedHomework.isEmpty == false {
            AppSupabaseHomeworkBridge.replace(with: result.mappedHomework)
        }
        syncStatus = result.status == "blocked" || result.status == "token missing" || result.status == "class missing"
            ? "Supabase signed homework заблокирован: нужен client key, SUPABASE_ACCESS_TOKEN и class bridge."
            : "Supabase signed homework завершен: \(result.headerState). \(result.nextStep)"
    }

    @MainActor
    private func runSupabaseSignedCalendarEventsProbe() async {
        reloadSupabaseProbeState()
        syncStatus = "Supabase signed calendar: готовлю GET /calendar_events без замены локального календаря."
        let result = await SupabaseSignedCalendarEventsClient.probeCalendarEvents(config: supabaseConfig)
        supabaseSignedCalendarEvents = result
        if result.mappedEvents.isEmpty == false {
            AppSupabaseCalendarEventBridge.replace(with: result.mappedEvents)
        }
        syncStatus = result.status == "blocked" || result.status == "token missing" || result.status == "class missing"
            ? "Supabase signed calendar заблокирован: нужен client key, SUPABASE_ACCESS_TOKEN и class bridge."
            : "Supabase signed calendar завершен: \(result.headerState). \(result.nextStep)"
    }

    @MainActor
    private func runSupabaseSignedCollectionsProbe() async {
        reloadSupabaseProbeState()
        syncStatus = "Supabase signed collections: готовлю GET /collections без замены локальных сборов и без прав на управление."
        let result = await SupabaseSignedCollectionsClient.probeCollections(config: supabaseConfig)
        supabaseSignedCollections = result
        if result.mappedCollections.isEmpty == false {
            AppSupabaseCollectionBridge.replace(with: result.mappedCollections)
        }
        syncStatus = result.status == "blocked" || result.status == "token missing" || result.status == "class missing"
            ? "Supabase signed collections заблокирован: нужен client key, SUPABASE_ACCESS_TOKEN и class bridge."
            : "Supabase signed collections завершен: \(result.headerState). \(result.nextStep)"
    }

    @MainActor
    private func runSupabaseAnnouncementReadAck() async {
        reloadSupabaseProbeState()
        syncStatus = "Supabase announcement read ack: готовлю POST /announcement_reads без замены локальной ленты."
        let result = await SupabaseAnnouncementReadAckClient.acknowledgePrimaryAnnouncement(config: supabaseConfig)
        supabaseAnnouncementReadAck = result
        if result.status == "saved" || result.status == "already saved" {
            if let announcementID = AppSupabaseAnnouncementBridge.primaryAnnouncement?.id {
                AppSupabaseAnnouncementBridge.markRead(
                    announcementID: announcementID,
                    mappedAt: Date.now.formatted(date: .numeric, time: .shortened)
                )
                supabaseSignedAnnouncements = SupabaseSignedAnnouncementsProbe.planned(config: supabaseConfig)
                supabaseAnnouncementReadAck = SupabaseAnnouncementReadAckResult.planned(config: supabaseConfig)
            }
        }
        syncStatus = result.status == "blocked" || result.status == "token missing" || result.status == "user id missing" || result.status == "announcement missing"
            ? "Supabase announcement read ack заблокирован: нужен client key, SUPABASE_ACCESS_TOKEN, SUPABASE_USER_ID и announcement bridge."
            : "Supabase announcement read ack завершен: \(result.headerState). \(result.nextStep)"
    }

    private func enableSupabaseChildSourcePreview() {
        guard AppSupabaseChildContextBridge.contexts.isEmpty == false else {
            usesSupabaseChildSourcePreview = false
            AppChildStore.usesSupabaseChildSourcePreview = false
            syncStatus = "Supabase child source preview заблокирован: bridge пуст, сначала нужен signed children probe или QA seed."
            return
        }

        AppChildStore.usesSupabaseChildSourcePreview = true
        usesSupabaseChildSourcePreview = true
        let selectedChild = AppChildStore.selectedChild
        syncStatus = "Supabase child source preview включен: \(selectedChild.name), \(selectedChild.className), код \(selectedChild.classCode)."
    }

    private func disableSupabaseChildSourcePreview() {
        AppChildStore.usesSupabaseChildSourcePreview = false
        usesSupabaseChildSourcePreview = false
        let selectedChild = AppChildStore.selectedChild
        syncStatus = "Supabase child source preview выключен: снова используются локальные дети, текущий ребенок \(selectedChild.name), \(selectedChild.className)."
    }

    @MainActor
    private func runSupabaseLiveProbe() async {
        reloadSupabaseProbeState()
        syncStatus = "Supabase live probe: готовлю GET /class_rooms через URLSession без замены локальных данных."
        let result = await SupabaseLiveClient.probeClassRooms(config: supabaseConfig)
        supabaseLiveProbe = result
        syncStatus = result.status == "blocked"
            ? "Supabase live probe заблокирован: нужен SUPABASE_PUBLISHABLE_KEY или SUPABASE_ANON_KEY."
            : "Supabase live probe завершен: \(result.headerState). \(result.nextStep)"
    }

    private func clearSupabaseStoredSeedSession() {
        SupabaseSeedSessionStore.clear()
        reloadSupabaseProbeState()
        syncStatus = "Stored seed session очищена из Keychain и legacy QA store: приложение снова зависит только от env/Info.plist токенов или нового seed sign-in."
    }

    private func save() {
        onSave(operations)
        dismiss()
    }
}

private struct SupportMessageSheet: View {
    @Environment(\.dismiss) private var dismiss

    let kind: SupportMessageKind

    @State private var subject: String
    @State private var message: String
    @State private var contact = "Telegram или email"
    @State private var sendStatus = "Черновик не отправлялся"
    @State private var history: [SupportMessageDraft]
    @State private var didRunQAAutosave = false

    init(kind: SupportMessageKind) {
        self.kind = kind
        _subject = State(initialValue: kind.defaultSubject)
        _message = State(initialValue: kind.defaultMessage)
        _history = State(initialValue: SupportMessageStore.messages(for: kind))
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    MoreSheetHeader(
                        icon: kind.icon,
                        color: kind.color,
                        title: kind.title,
                        subtitle: kind.subtitle
                    )

                    DashboardCard {
                        VStack(spacing: 12) {
                            MoreTextField(title: "Тема", iconName: "text.badge.plus", color: kind.color, text: $subject)
                            MoreTextField(title: "Сообщение", iconName: "text.alignleft", color: SchoolTheme.accent, text: $message)
                            MoreTextField(title: "Контакт", iconName: "at", color: SchoolTheme.teal, text: $contact)
                        }
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Статус")
                                .font(.headline)
                                .foregroundStyle(SchoolTheme.graphite)
                            Text(sendStatus)
                                .font(.caption)
                                .foregroundStyle(SchoolTheme.muted)

                            Button {
                                saveDraft()
                            } label: {
                                Label(kind.actionTitle, systemImage: kind.actionIcon)
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity, minHeight: 44)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(kind.color)
                            .disabled(subject.trimmed.isEmpty || message.trimmed.isEmpty)

                            ShareLink(item: shareText) {
                                Label("Отправить через iOS", systemImage: "square.and.arrow.up")
                                    .font(.subheadline.weight(.semibold))
                                    .frame(maxWidth: .infinity, minHeight: 44)
                            }
                            .buttonStyle(.bordered)
                            .tint(kind.color)
                            .disabled(subject.trimmed.isEmpty || message.trimmed.isEmpty)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("История")
                                    .font(.headline)
                                    .foregroundStyle(SchoolTheme.graphite)
                                Spacer()
                                StatusBadge(text: "\(history.count)", color: kind.color)
                            }

                            if history.isEmpty {
                                MoreEmptyState(
                                    icon: "tray.fill",
                                    title: "Обращений пока нет",
                                    detail: "Сохраненные сообщения появятся здесь и не потеряются при закрытии формы."
                                )
                            } else {
                                VStack(spacing: 10) {
                                    ForEach(history.prefix(3)) { draft in
                                        supportHistoryRow(draft)
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle(kind.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
                KeyboardDoneToolbar()
            }
            .onAppear {
                runQAAutosaveIfNeeded()
            }
        }
    }

    private var shareText: String {
        [
            kind.shareTitle,
            "Тема: \(subject.trimmed)",
            "Контакт: \(contact.trimmed.isEmpty ? "не указан" : contact.trimmed)",
            "Сообщение:",
            message.trimmed
        ].joined(separator: "\n")
    }

    private func supportHistoryRow(_ draft: SupportMessageDraft) -> some View {
        HStack(alignment: .top, spacing: 12) {
            IconBadge(systemName: kind.icon, color: kind.color, size: 38)
            VStack(alignment: .leading, spacing: 3) {
                Text(draft.subject)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite)
                    .lineLimit(2)
                Text(draft.message)
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
                    .lineLimit(2)
                Text("\(draft.contact) - \(draft.createdAt)")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(kind.color)
            }
            Spacer()
        }
    }

    private func saveDraft() {
        let draft = SupportMessageDraft(kind: kind, subject: subject.trimmed, message: message.trimmed, contact: contact.trimmed.isEmpty ? "Контакт не указан" : contact.trimmed)
        history.insert(draft, at: 0)
        history = Array(history.prefix(8))
        SupportMessageStore.save(history, for: kind)
        sendStatus = "Готово: обращение сохранено локально и готово к отправке через iOS"
    }

    private func runQAAutosaveIfNeeded() {
        guard !didRunQAAutosave else {
            return
        }

        let arguments = ProcessInfo.processInfo.arguments
        guard
            (kind == .support && arguments.contains("-qa-more-support"))
                || (kind == .problem && arguments.contains("-qa-more-problem"))
        else {
            return
        }

        didRunQAAutosave = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            saveDraft()
        }
    }
}

private struct SupportMessageDraft: Identifiable, Hashable, Codable {
    let id: UUID
    var kind: String
    var subject: String
    var message: String
    var contact: String
    var createdAt: String

    init(id: UUID = UUID(), kind: SupportMessageKind, subject: String, message: String, contact: String, createdAt: String = Date().supportMessageTimestamp) {
        self.id = id
        self.kind = kind.storageKey
        self.subject = subject
        self.message = message
        self.contact = contact
        self.createdAt = createdAt
    }
}

private enum SupportMessageStore {
    private static let defaults = UserDefaults.standard

    static func messages(for kind: SupportMessageKind) -> [SupportMessageDraft] {
        guard
            let data = defaults.data(forKey: kind.defaultsKey),
            let messages = try? JSONDecoder().decode([SupportMessageDraft].self, from: data)
        else {
            return []
        }

        return messages
    }

    static func save(_ messages: [SupportMessageDraft], for kind: SupportMessageKind) {
        guard let data = try? JSONEncoder().encode(messages) else {
            return
        }

        defaults.set(data, forKey: kind.defaultsKey)
    }
}

private struct LogoutSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var transferStatus = "Перенос данных не подготовлен"

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    MoreSheetHeader(
                        icon: "rectangle.portrait.and.arrow.right",
                        color: SchoolTheme.warning,
                        title: "Выйти",
                        subtitle: "Локальный профиль, перенос данных и смена класса"
                    )

                    DashboardCard {
                        VStack(alignment: .leading, spacing: 14) {
                            logoutRow(
                                icon: "person.crop.circle.badge.checkmark",
                                color: SchoolTheme.success,
                                title: "Владимир",
                                detail: "Родитель Миши, 3Б"
                            )
                            logoutRow(
                                icon: "externaldrive.fill",
                                color: SchoolTheme.accent,
                                title: "Локальные данные",
                                detail: "ДЗ, календарь, сборы, файлы и настройки хранятся на устройстве"
                            )
                            logoutRow(
                                icon: "icloud.and.arrow.up.fill",
                                color: SchoolTheme.teal,
                                title: "Перенос",
                                detail: transferStatus
                            )
                        }
                    }

                    HStack(spacing: 10) {
                        Button {
                            transferStatus = "Пакет переноса подготовлен локально"
                        } label: {
                            Label("Подготовить", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .buttonStyle(.bordered)
                        .tint(SchoolTheme.accent)

                        Button {
                            dismiss()
                        } label: {
                            Label("Остаться", systemImage: "checkmark")
                                .frame(maxWidth: .infinity, minHeight: 44)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(SchoolTheme.success)
                    }
                }
                .padding(20)
                .padding(.bottom, 20)
            }
            .background(SchoolTheme.page.ignoresSafeArea())
            .navigationTitle("Выйти")
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

    private func logoutRow(icon: String, color: Color, title: String, detail: String) -> some View {
        HStack(spacing: 12) {
            IconBadge(systemName: icon, color: color, size: 42)
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

private enum SupportMessageKind {
    case support
    case problem

    var storageKey: String {
        switch self {
        case .support:
            "support"
        case .problem:
            "problem"
        }
    }

    var defaultsKey: String {
        "school.more.support.\(storageKey)"
    }

    var title: String {
        switch self {
        case .support:
            "Поддержка"
        case .problem:
            "Проблема"
        }
    }

    var subtitle: String {
        switch self {
        case .support:
            "Вопрос по классу, семье или подписке"
        case .problem:
            "Ошибка, потерянное состояние или странное поведение"
        }
    }

    var icon: String {
        switch self {
        case .support:
            "message.fill"
        case .problem:
            "exclamationmark.bubble.fill"
        }
    }

    var color: Color {
        switch self {
        case .support:
            SchoolTheme.accent
        case .problem:
            SchoolTheme.danger
        }
    }

    var actionTitle: String {
        switch self {
        case .support:
            "Сохранить обращение"
        case .problem:
            "Сохранить отчет"
        }
    }

    var actionIcon: String {
        switch self {
        case .support:
            "paperplane.fill"
        case .problem:
            "exclamationmark.triangle.fill"
        }
    }

    var shareTitle: String {
        switch self {
        case .support:
            "Обращение в поддержку Школьный класс"
        case .problem:
            "Отчет о проблеме Школьный класс"
        }
    }

    var defaultSubject: String {
        switch self {
        case .support:
            "Вопрос по приложению"
        case .problem:
            "Ошибка в приложении"
        }
    }

    var defaultMessage: String {
        switch self {
        case .support:
            "Хочу уточнить по настройкам класса и семейного доступа."
        case .problem:
            "Опишите, где возникла проблема и что нажимали перед этим."
        }
    }
}

private extension Date {
    var supportMessageTimestamp: String {
        formatted(.dateTime.day().month().hour().minute())
    }
}

private struct MoreEmptyState: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        VStack(spacing: 8) {
            IconBadge(systemName: icon, color: SchoolTheme.muted, size: 44)
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(SchoolTheme.graphite)
            Text(detail)
                .font(.caption)
                .foregroundStyle(SchoolTheme.muted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }
}

private struct NotificationPreferenceRow: View {
    @Binding var preference: NotificationPreference

    var body: some View {
        HStack(spacing: 12) {
            IconBadge(systemName: preference.iconName, color: moreColor(for: preference.colorName), size: 40)
            VStack(alignment: .leading, spacing: 2) {
                Text(preference.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(SchoolTheme.graphite)
                Text(preference.detail)
                    .font(.caption)
                    .foregroundStyle(SchoolTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            Toggle("", isOn: $preference.isEnabled)
                .labelsHidden()
                .tint(SchoolTheme.success)
        }
    }
}

private struct MoreSheetHeader: View {
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

private struct MoreMetric: View {
    let value: String
    let title: String
    let color: Color

    var body: some View {
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

private struct MoreTextField: View {
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

private enum MoreSheet: String, Identifiable {
    case profile
    case children
    case family
    case familyTasks
    case classes
    case subscription
    case notifications
    case memory
    case files
    case audit
    case security
    case privacy
    case legal
    case realDeviceQa
    case behavioralQa
    case metrics
    case aiQuality
    case qaStates
    case syncCenter
    case moderation
    case betaReadiness
    case support
    case problem
    case logout

    var id: String { rawValue }
}

private struct MoreMenuItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    var sheet: MoreSheet?
}

private func moreColor(for colorName: String) -> Color {
    switch colorName {
    case "green":
        SchoolTheme.success
    case "teal":
        SchoolTheme.teal
    case "red":
        SchoolTheme.danger
    case "orange":
        SchoolTheme.warning
    default:
        SchoolTheme.accent
    }
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

#Preview {
    MoreView()
}
