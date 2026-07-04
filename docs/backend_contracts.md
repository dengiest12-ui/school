# Школьный класс: сущности, роли и контракты синхронизации

Документ фиксирует текущую модель MVP и целевую серверную форму. Сейчас приложение хранит данные локально для проверки UX. Backend должен стать источником истины для аккаунтов, ролей, приватности детей, финансов и файлов.

Формальный черновик API зафиксирован отдельно в `docs/openapi_mvp.yaml`. Он покрывает первые endpoint-ы, которые уже отображаются в iOS-центре синхронизации: создание класса, публикацию ДЗ, подтверждение прочтения объявления, чек сбора, приглашение, фото альбома и batch-отправку offline-мутаций.

В приложении экран `Еще -> Синхронизация` дополнительно показывает readiness-контроль API: готовые артефакты, следующие инженерные слои и блокеры релиза. На текущем этапе готовыми считаются OpenAPI draft и iOS mutation dry-run, а блокерами остаются серверная авторизация/права и приватное файловое хранилище.

## 1. Основные сущности

### User
- `id`: стабильный UUID.
- `phone`: основной идентификатор входа, подтверждается SMS/звонком.
- `appleUserId`: опциональная связка для Sign in with Apple.
- `displayName`, `avatar`, `email`.
- `status`: active, invited, blocked, deleted.
- `createdAt`, `updatedAt`, `deletedAt`.

### Child
- `id`, `displayName`, `birthDate`, `avatar`.
- `familyId`: семья, которая управляет профилем ребенка.
- `classIds`: классы, к которым ребенок подключен.
- `visibility`: настройки показа имени, фото и семейных контактов.

### Family / FamilyMember
- `Family`: `id`, `title`, `ownerUserId`, `childrenIds`.
- `FamilyMember`: `id`, `familyId`, `userId`, `role`, `accessScope`, `inviteStatus`.
- Роли семьи: owner, parent, relative, nanny.
- Семейные доступы не дают права управлять классом, если у пользователя нет отдельной роли в классе.

### ClassRoom / ClassMember / Role
- `ClassRoom`: `id`, `title`, `schoolName`, `grade`, `inviteCode`, `status`.
- `ClassMember`: `id`, `classId`, `userId`, `childId`, `role`, `status`.
- Роли класса: parent, parentCommittee, teacher, classAdmin.
- `classAdmin` нужен для приглашений, состава класса и передачи прав.

### Chat / Message
- `Chat`: `id`, `classId`, `type`, `title`, `participants`, `announcementOnly`.
- `Message`: `id`, `chatId`, `authorId`, `text`, `attachments`, `createdAt`, `editedAt`, `deletedAt`.
- Для AI-дайджеста сообщения должны иметь `importance`, `actionHint`, `sourceMessageIds`.

### Announcement
- `id`, `classId`, `authorId`, `title`, `body`, `tag`, `requiresAcknowledgement`.
- `readReceipts`: список `userId`, `readAt`.
- `commentsEnabled`, `comments`.
- Создание доступно учителю, родкомитету и администратору класса.

### Homework
- `id`, `classId`, `authorId`, `subject`, `text`, `dueAt`, `status`, `attachments`.
- `source`: manual, photoAI, chatAI, teacher.
- `assignees`: класс, ребенок или группа детей.

### ScheduleItem / Event / Reminder
- `ScheduleItem`: уроки, замены, форма/предметы.
- `Event`: экскурсии, собрания, кружки, праздники, связанные сборы.
- `Reminder`: персональные и семейные напоминания, привязанные к событию, ДЗ или сбору.

### Collection / Expense
- `Collection`: `id`, `classId`, `title`, `amount`, `deadline`, `status`, `recipient`, `createdBy`.
- `PaymentMark`: `collectionId`, `familyId`, `status`, `amount`, `confirmedBy`.
- `Expense`: `id`, `collectionId`, `title`, `amount`, `note`, `attachments`, `createdBy`.
- Управление сбором доступно родкомитету и администратору класса. Родитель видит свой статус и отчеты, но не меняет чужие оплаты.

### Album / Photo / File
- `Album`: `id`, `classId`, `title`, `eventId`, `visibility`.
- `Photo`: `id`, `albumId`, `fileId`, `authorId`, `createdAt`, `moderationStatus`.
- `File`: `id`, `ownerId`, `storageKey`, `mimeType`, `size`, `checksum`, `scanStatus`.

### Task
- `id`, `familyId`, `classId`, `childId`, `title`, `dueAt`, `assigneeUserId`, `source`, `status`.
- Источники: manual, chatDigest, homework, event, collection.

### AIParseResult
- `id`, `sourceType`, `sourceId`, `inputHash`, `modelVersion`, `confidence`.
- `items`: распознанные ДЗ, события, задачи или напоминания.
- `reviewStatus`: draft, accepted, rejected, edited.
- Должен хранить след аудита: кто принял результат и что было изменено.

### Subscription
- `id`, `familyId`, `productId`, `storeTransactionId`, `status`, `expiresAt`.
- Источник истины для подписки: App Store Server Notifications плюс локальная StoreKit-проверка.

### NotificationSetting
- `id`, `userId`, `classId`, `channel`, `enabled`, `quietHours`, `topic`.
- Темы: announcements, homework, collections, events, chats, familyTasks, aiDigest.

### AuditLog
- `id`, `actorUserId`, `entityType`, `entityId`, `action`, `diff`, `createdAt`, `ipHash`.
- Обязателен для ролей, приглашений, сборов, файлов, удаления данных и согласий.

## 2. Backend-права

UI может скрывать кнопки, но backend обязан повторно проверять все действия.

| Действие | Parent | Parent committee | Teacher | Class admin |
| --- | --- | --- | --- | --- |
| Читать объявления класса | Да | Да | Да | Да |
| Создавать объявления | Нет | Да | Да | Да |
| Отмечать свое прочтение | Да | Да | Да | Да |
| Создавать ДЗ | Нет | Нет | Да | Да |
| Создавать семейные задачи | Да, в своей семье | Да, в своей семье | Нет | Да, в своей семье |
| Создавать сборы | Нет | Да | Нет | Да |
| Менять чужую оплату | Нет | Да | Нет | Да |
| Добавлять расходы и чеки | Нет | Да | Нет | Да |
| Приглашать участников класса | Нет | Да | Да | Да |
| Удалять участника класса | Нет | Нет | Нет | Да |
| Управлять файлами класса | Только просмотр | Да | Да | Да |
| Удалять аккаунт/данные | Только свои данные | Только свои данные | Только свои данные | Только свои данные |

Сервер должен проверять:
- членство пользователя в классе или семье;
- роль в конкретном классе, а не глобальную роль профиля;
- связь ребенка с семьей;
- подписку и доступ к платным функциям;
- запрет на доступ к файлам и финансам вне класса;
- аудит всех действий с персональными данными детей.

## 3. Контракты синхронизации

### Общий формат изменений

```json
{
  "mutationId": "uuid",
  "clientId": "ios-device-id",
  "actorUserId": "uuid",
  "entityType": "Announcement",
  "entityId": "uuid",
  "operation": "create|update|delete|acknowledge",
  "baseVersion": 12,
  "payload": {},
  "createdAt": "2026-07-03T12:00:00Z"
}
```

Ответ сервера:

```json
{
  "mutationId": "uuid",
  "status": "accepted|rejected|conflict",
  "entityVersion": 13,
  "serverState": {},
  "errorCode": null
}
```

### iOS dry-run мутаций

Экран `Еще -> Синхронизация` уже строит локальное превью таких мутаций без сетевого запроса:

- генерирует стабильный для проверки `mutationId` по окружению, сущности и локальной операции;
- показывает `endpoint`, `operation`, `baseVersion` и краткий `payloadPreview`;
- собирает типизированный batch-запрос `POST /sync/mutations` с base URL окружения, typed auth context, idempotency key и компактным JSON body;
- прогоняет request/response через локальный Codable dry-run будущего Swift-клиента: `URLSession` request, `MutationBatchResponse` decode, result mapping, retry-план, server version persistence и остановку автоматической отправки для storage/conflict/auth блокеров;
- добавляет в dry-run `actorUserId`, class role claim, bearer preview и refresh-план, но не считает это заменой серверной проверки ролей;
- добавляет storage preflight: private bucket, количество pending uploads и список `mutationId`, которые нельзя отправлять до получения `fileId`;
- показывает upload-intent preview для `POST /files/upload-url`: kind, fileName, mimeType, sizeBytes, checksumSha256 и связь с исходной мутацией;
- показывает mock signed upload response: `fileId`, `uploadUrl`, TTL, required header, private bucket и storage key;
- показывает scan/moderation gate: файл остается `pending_scan`, а metadata-мутация не отправляется до `clean`;
- раскладывает операции по статусам `accepted`, `queued` и `blocked`;
- отдельно подсвечивает операции, которые требуют storage до отправки метаданных;
- сохраняет обратную совместимость со старыми локальными записями очереди.

Это не заменяет backend-клиент, но фиксирует форму данных, которую следующий слой сможет отправлять в API.

Пример локального dry-run:

```json
{
  "mutationId": "staging-homework-2-ABC123",
  "endpoint": "POST /homework",
  "entity": "homework",
  "operation": "create",
  "baseVersion": 1,
  "payloadPreview": "{\"subject\":\"Математика\",\"assignees\":\"class\"}",
  "status": "queued"
}
```

Пример локального batch-request preview:

```json
{
  "method": "POST",
  "url": "https://staging-api.school-class.app/sync/mutations",
  "headers": {
    "Authorization": "Bearer dry-staging-session",
    "Idempotency-Key": "dry-ABC12345"
  },
  "body": {
    "clientId": "ios-local",
    "actorUserId": "user-ios-local",
    "roleClaim": "class:staging-3b parentCommittee",
    "storagePreflight": {
      "privateBucket": "school-class-staging-private",
      "pendingUploads": 1,
      "requiredBeforeMutationIds": ["staging-receipt-4-ABC123"],
      "policy": "Private by class/family membership"
    },
    "mutations": [
      {
        "mutationId": "staging-homework-2-ABC123",
        "entityType": "homework",
        "operation": "create",
        "baseVersion": 1
      }
    ]
  }
}
```

### iOS SyncClient dry-run

Следующий слой в приложении должен заменить mock-response на реальный transport. Текущий экран уже фиксирует, что клиенту нужно:

- отправлять batch через `URLSession` и декодировать `MutationBatchResponse` теми же Codable-моделями;
- прикладывать bearer session, `actorUserId` и class role claim к batch-запросу;
- обновлять access token перед повторной отправкой и переводить 401/403 в понятный auth/permission blocker;
- маппить ответы в `accepted`, `queued`, `blocked` и `conflict`;
- сохранять `entityVersion` перед удалением локальной мутации;
- оставлять offline/network failures в локальной очереди с backoff retry;
- останавливать автоматическую отправку для storage, auth и conflict блокеров.

### Storage preflight

Фото, документы, чеки расходов и вложения ДЗ не должны отправляться в `POST /sync/mutations` как обычный payload. Клиентский порядок:

1. Найти локальные мутации, которым нужен файл: receipt, photo, file, document.
2. Собрать upload-intent: kind, fileName, mimeType, sizeBytes, checksumSha256 и связанный `mutationId`.
3. Запросить у backend signed upload URL через `POST /files/upload-url`.
4. Загрузить binary/file в private storage.
5. Получить `fileId`, checksum, размер и mime type.
6. Дождаться `scanStatus = clean`; для фото может потребоваться moderation-проверка учителем или родкомитетом.
7. Отправить metadata-мутацию в `POST /sync/mutations` уже со ссылкой на `fileId`.

Текущий iOS dry-run уже показывает этот preflight, upload-intent preview, mock signed-response preview и scan gate в `Еще -> Синхронизация`, а OpenAPI draft фиксирует контракт `POST /files/upload-url`. Настоящий backend все равно должен выдать signed URL, проверить права класса/семьи, сохранить audit event и выполнить file scan/moderation до публикации.

Минимальный request для signed upload:

```json
{
  "classId": "8f8b9f7a-7e8f-4d7c-b4bd-6a5c5fd4a111",
  "collectionId": "b5c1a5df-37d1-4a3b-b3f3-7d35fcb28a42",
  "kind": "receipt",
  "fileName": "receipt-september.png",
  "mimeType": "image/png",
  "sizeBytes": 842120,
  "checksumSha256": "local-sha256-before-upload"
}
```

Минимальный response:

```json
{
  "fileId": "30b1ebaf-cd6f-4a43-a2a2-f8f84b6f0dd2",
  "uploadUrl": "https://storage.example/signed-put",
  "method": "PUT",
  "expiresAt": "2026-07-04T12:00:00Z",
  "requiredHeaders": {
    "Content-Type": "image/png"
  },
  "metadata": {
    "fileId": "30b1ebaf-cd6f-4a43-a2a2-f8f84b6f0dd2",
    "privateBucket": "school-class-staging-private",
    "storageKey": "classes/8f8b9f7a/receipts/30b1ebaf.png",
    "kind": "receipt",
    "visibility": "class_members"
  }
}
```

### Auth и серверные роли

iOS dry-run теперь показывает будущий auth-контекст запроса, но это только клиентская подготовка. Backend обязан:

- валидировать bearer token и привязку пользователя к семье/классу;
- проверять роль пользователя в конкретном классе для каждой мутации, а не доверять UI;
- отклонять действия с кодами `401`, `403` или typed `blockedReason`;
- писать audit event для смены ролей, приглашений, сборов, чеков, фото и удаления данных.

### Что можно создавать локально
- Черновики объявлений, ДЗ, событий, сборов и задач.
- Отметки "прочитано" и "моя семья оплатила" до подтверждения сервером.
- AI-распознавание как draft, пока пользователь не принял результат.
- Локальные настройки уведомлений и приватности до синхронизации.

### Что должно подтверждаться backend
- Создание объявления, ДЗ, сбора, расхода, файла, участника класса.
- Любое изменение ролей.
- Любое изменение финансового статуса другой семьи.
- Загрузка фото, чеков и документов.
- Удаление аккаунта, ребенка, семьи или класса.
- Подписка и платежи.

### Разрешение конфликтов
- `lastWriteWins` допустим только для личных настроек.
- Для сборов, расходов, ролей и состава класса нужен `baseVersion`; при конфликте сервер возвращает актуальное состояние.
- Для read receipts и реакций используется merge-set: отметки разных пользователей не перетирают друг друга.
- Для файлов используется immutable upload: новая версия создает новый `fileId`.
- Для AI-результатов пользовательское редактирование всегда важнее повторного парсинга.

### Offline-очередь
- Каждая локальная операция получает `mutationId`.
- Повторная отправка с тем же `mutationId` должна быть идемпотентной.
- UI показывает optimistic state, но помечает действие как "ждет синхронизации".
- При отклонении сервером UI возвращает состояние и показывает понятную причину.

## 4. Окружения

### Dev
- Локальные данные, моковые пользователи и тестовые файлы.
- Разрешены QA-флаги запуска.
- Push/SMS/StoreKit могут быть sandbox.

### Staging
- Реальный backend с тестовой базой.
- Отдельные ключи хранилища файлов, AI и уведомлений.
- Тестовые Apple/StoreKit-сценарии.
- Нужен перед TestFlight.

### Production
- Реальные пользователи, реальные платежи, реальные файлы.
- Строгие политики удаления, аудита и доступа.
- Отдельные ключи, мониторинг, резервные копии и лимиты.

## 5. Следующие инженерные шаги

- Вынести модели из `SampleData.swift` в доменные файлы `Models`.
- Добавить `version`, `createdAt`, `updatedAt` в синхронизируемые сущности.
- Сделать локальную очередь мутаций поверх текущего JSON-хранения.
- Расширить `docs/openapi_mvp.yaml` до полной backend schema и сгенерировать Swift-клиент.
- Подключить URLSession/сгенерированный клиент к очереди мутаций и сохранить server version.
- Реализовать приватное storage для фото, чеков и документов до отправки метаданных.
- Добавить unit-тесты ролей и конфликтов синхронизации.
