import SwiftUI
import UniformTypeIdentifiers
import UserNotifications
import UIKit
import CoreImage.CIFilterBuiltins
import StoreKit

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

    static let sample = SecuritySettingsState(
        closedClassOnly: true,
        maskFinanceForFamily: true,
        requireInviteApproval: true,
        deleteRequestStatus: "Запрос удаления не отправлялся",
        deleteScope: "Аккаунт и личные данные",
        exportStatus: "Экспорт не подготовлен",
        deleteConfirmation: ""
    )

    init(
        closedClassOnly: Bool,
        maskFinanceForFamily: Bool,
        requireInviteApproval: Bool,
        deleteRequestStatus: String,
        deleteScope: String,
        exportStatus: String,
        deleteConfirmation: String
    ) {
        self.closedClassOnly = closedClassOnly
        self.maskFinanceForFamily = maskFinanceForFamily
        self.requireInviteApproval = requireInviteApproval
        self.deleteRequestStatus = deleteRequestStatus
        self.deleteScope = deleteScope
        self.exportStatus = exportStatus
        self.deleteConfirmation = deleteConfirmation
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
}

private enum SyncEndpointKind: String, CaseIterable, Identifiable {
    case classRoom
    case homework
    case announcementRead
    case receipt
    case familyInvite
    case photo

    var id: String { rawValue }

    var title: String {
        switch self {
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

    static func make(environment: BackendEnvironment, operations: [SyncOperationSummary]) -> SyncDryRunResult {
        let queued = operations.filter { ["В очереди", "Локально", "Offline"].contains($0.status) }.count
        let blocked = operations.filter { ["Нужен storage", "Конфликт"].contains($0.status) }.count
        let accepted = max(operations.count - queued - blocked, 0)
        let suffix = UUID().uuidString.prefix(8).uppercased()
        let mutations = operations.enumerated().map { index, operation in
            SyncMutationPreview.make(environment: environment, operation: operation, index: index)
        }
        let requestID = "dry-\(suffix)"

        return SyncDryRunResult(
            environment: environment,
            acceptedCount: accepted,
            queuedCount: queued,
            blockedCount: blocked,
            requestID: requestID,
            summary: "Dry-run: \(accepted) можно отправить, \(queued) ждут сети, \(blocked) требуют решения до API.",
            mutations: mutations,
            requestPreview: SyncRequestPreview.make(environment: environment, requestID: requestID, mutations: mutations)
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
            detail: "Описаны batch-мутации и первые endpoint-ы класса, ДЗ, объявлений, чеков, приглашений и фото.",
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
            artifact: "URLSession / generated client",
            status: "Дальше",
            detail: "Нужен слой запросов, refresh token, retry, mapping ошибок и сохранение серверных версий.",
            iconName: "curlybraces.square.fill",
            colorName: "orange"
        ),
        ApiReadinessItem(
            title: "Auth + server roles",
            artifact: "Backend policy",
            status: "Блокер",
            detail: "Сервер должен проверять роль в конкретном классе для объявлений, сборов, чеков, фото и приглашений.",
            iconName: "lock.shield.fill",
            colorName: "red"
        ),
        ApiReadinessItem(
            title: "File storage",
            artifact: "Private uploads",
            status: "Блокер",
            detail: "Фото, документы и чеки должны загружаться в приватное хранилище до отправки метаданных.",
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
            MoreMenuItem(title: "QA-состояния", subtitle: "\(qaPassedCount) из \(qaScenarios.count) проверены: пусто, offline, нет прав", icon: "checkmark.seal.fill", color: SchoolTheme.success, sheet: .qaStates),
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
        settings.deleteRequestStatus = MoreLocalStore.performLocalDeletion(scope: settings.deleteScope)
        settings.deleteConfirmation = ""
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
                                Button {
                                    addSmokeEvent()
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundStyle(SchoolTheme.accent)
                                        .frame(width: 34, height: 34)
                                        .background(SchoolTheme.accent.opacity(0.10), in: Circle())
                                }
                                .accessibilityLabel("Добавить тестовое событие")
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

    init(operations: [SyncOperationSummary], onSave: @escaping ([SyncOperationSummary]) -> Void) {
        self.onSave = onSave
        var launchOperations = operations
        if ProcessInfo.processInfo.arguments.contains("-qa-more-sync-offline"), !launchOperations.isEmpty {
            launchOperations[0].status = "Offline"
            launchOperations[0].colorName = "orange"
        }

        _operations = State(initialValue: launchOperations)
        if ProcessInfo.processInfo.arguments.contains("-qa-more-sync") {
            _dryRunResult = State(initialValue: SyncDryRunResult.make(environment: .staging, operations: launchOperations))
            _syncStatus = State(initialValue: ProcessInfo.processInfo.arguments.contains("-qa-more-sync-offline") ? "Offline-сценарий: операция остается в очереди, пользовательские данные не теряются." : "Dry-run подготовил запросы для Staging: сеть не вызывается, но операции разложены по готовности.")
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
                                detail: "Dry-run готовит POST /sync/mutations: base URL окружения, auth-заглушка, idempotency key и compact JSON body"
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

                    if let dryRunResult {
                        DashboardCard {
                            dryRunCard(dryRunResult)
                        }
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

                            HStack(spacing: 8) {
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
        operations.filter { $0.status == "В очереди" || $0.status == "Локально" || $0.status == "Offline" }.count
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
        case "Нужен storage", "Offline", "Дальше":
            SchoolTheme.warning
        case "Конфликт", "Блокер":
            SchoolTheme.danger
        default:
            SchoolTheme.accent
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
        case .homework, .familyInvite:
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
    case metrics
    case aiQuality
    case qaStates
    case syncCenter
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
