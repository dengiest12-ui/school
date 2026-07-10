# Чеклист продукта: приложение для класса и родителей

Файл нужен, чтобы видеть состояние проекта без хаоса: что уже сделано, что проверено, насколько глубоко проверено, где есть риски и какой следующий шаг.

Источник: `school_class_family_app_tz.md`  
Дата создания чеклиста: 2026-07-02

## Как пользоваться

Статусы:

- `[ ]` - не начато.
- `[~]` - в работе.
- `[?]` - нужно решение или уточнение.
- `[x]` - сделано.
- `[!]` - есть проблема или риск.

Уровень проверки:

- `0` - не проверено.
- `1` - самопроверка исполнителем.
- `2` - ручная проверка сценария.
- `3` - проверка на реальном устройстве или симуляторе.
- `4` - автоматические тесты.
- `5` - принято владельцем продукта.

Формат строки:

```text
- [статус] Задача
  - Проверка: что именно должно быть проверено
  - Уровень: 0-5
  - Артефакт: ссылка на экран, файл, PR, видео, тест или заметку
  - Комментарий: что важно помнить
```

## 0. Общий прогресс

| Блок | Статус | Уровень проверки | Комментарий |
| --- | --- | --- | --- |
| ТЗ изучено | `[x]` | 1 | Основные роли, MVP, AI-функции, монетизация и iOS-требования разобраны. |
| Граница MVP зафиксирована | `[x]` | 2 | Создан `docs/mvp_scope.md`: главный оффер, MVP / позже / не делать, главный сценарий и North Star Metric. |
| Дизайн-прототип | `[~]` | 3 | Выбран первый дизайн-референс и перенесен в SwiftUI на 5 главных вкладок и онбординг; нужна ручная визуальная приемка. |
| iOS-приложение | `[~]` | 3 | Создан `SchoolApp.xcodeproj`; онбординг, ДЗ, календарь, сборы, расписание, чаты с вложениями/голосовыми/закреплениями/реакциями, объявления, семейный доступ, роли, детский режим, приглашения, настройки уведомлений и подписки собираются и проверяются на iPhone 17 Simulator; данные разделов "Класс", "ДЗ", "Календарь" и "Еще" сохраняются локально между перезапусками. |
| Backend / синхронизация | `[~]` | 4 | Для MVP добавлены локальное хранение, backend-контракты, OpenAPI draft, signed upload contract, экран очереди синхронизации, typed dry-run API-клиента, auth context, storage preflight, metadata release, network readiness gate, тестовая Supabase-схема с RLS/storage, Supabase readiness gate, Auth session gate, RLS-smoke seed, publishable-key gate, Auth refresh probe, password sign-in probe для seed user, Keychain-first seed session store с legacy QA/UserDefaults fallback, очисткой и relaunch-проверкой, signed profile probe, signed class scope probe, signed children probe, signed announcements probe с read-state preview, signed announcement read ack gate, account/class/child context mapper preview, безопасные local bridge для Supabase account, class, child и announcements context, QA-gated Supabase child source preview, управляемый из sync-центра переключатель Supabase child source с проверкой сохранения после перезапуска, live REST probe `GET /class_rooms`, первый Supabase email/password вход в онбординге и handoff после входа: онбординг подтягивает signed profile/children/classes, сохраняет bridge-контекст и открывает выбор роли/класса; полноценная регистрация/профиль/класс на live-данных и замена остальных локальных разделов еще не подключены. |
| AI-разбор фото/текста | `[~]` | 3 | Реализован локальный MVP-поток разбора ДЗ из фото/текста с правкой результата; реальный AI/backend еще не подключен. |
| Уведомления | `[~]` | 3 | Локальный экран настроек дайджестов, срочного, дедлайнов и тихих часов проверен в Simulator; добавлен APNs/backend readiness gate, настоящий push-сервер еще не подключен. |
| Подписка | `[~]` | 3 | Локальный экран trial, тарифов MVP, восстановления покупок, StoreKit 2 каталога и entitlement-readiness проверен в Simulator; настоящие покупки и App Store Connect еще не подключены. |
| Безопасность и приватность | `[~]` | 3 | Добавлен локальный экран безопасности: закрытый класс, управление участниками, маскирование финансов, подтверждение входов, подготовка удаления данных, request lifecycle, локальная отмена через re-auth и server deletion readiness; юридическая часть и серверная защита еще впереди. |
| Релизная готовность | `[~]` | 3 | Добавлены локальные экраны поддержки, отчета о проблеме, выхода и beta/TestFlight readiness; App Store, политика, аналитика, реальный iPhone и загрузка TestFlight еще не готовы. |

## 1. Продуктовая рамка MVP

- [x] Изучить ТЗ целиком
  - Проверка: выделены цель продукта, роли, MVP, будущие функции и iOS-рамки
  - Уровень: 1
  - Артефакт: этот чеклист
  - Комментарий: продукт не должен превращаться в электронный дневник

- [x] Зафиксировать главный оффер
  - Проверка: одна короткая формулировка ценности понятна родителю за 5 секунд
  - Уровень: 2
  - Артефакт: `docs/mvp_scope.md`
  - Комментарий: базовая линия оставлена из ТЗ, короткая версия для первого экрана: "Что завтра в школу - понятно за 10 секунд"

- [x] Разделить функции на MVP / позже / не делать
  - Проверка: каждая функция из ТЗ имеет категорию и причину
  - Уровень: 2
  - Артефакт: `docs/mvp_scope.md`
  - Комментарий: в первый MVP не входят прием денег, фотокниги, поиск ребенка по фото, сложная социальная механика и замена электронного дневника

- [x] Описать главный пользовательский сценарий MVP
  - Проверка: путь от создания класса до ежедневного использования "Что завтра?" проходит без учителя
  - Уровень: 2
  - Артефакт: `docs/mvp_scope.md`
  - Комментарий: сценарий описывает путь от создания класса до вечернего "Что завтра" и утренней отметки выполненного

- [x] Сформулировать North Star Metric
  - Проверка: метрика связана с регулярным использованием "Что завтра?" или дайджеста
  - Уровень: 2
  - Артефакт: `docs/mvp_scope.md`
  - Комментарий: North Star Metric: доля активных семей, которые используют "Что завтра" или дайджест 4+ раза в неделю

## 2. Роли и права

- [~] Родитель
  - Проверка: может читать класс, видеть ДЗ, события, сборы, приглашать семью, добавлять личные задачи
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/More/MoreView.swift`, `SchoolApp/Features/ClassRoom/ClassRoomView.swift`, `.build/screenshots/access-family-final.png`, `.build/screenshots/access-class-members-final.png`
  - Комментарий: роль отображается в профиле, семье и участниках класса; серверная проверка прав еще не реализована

- [~] Учитель / классный руководитель
  - Проверка: может публиковать объявления, добавлять ДЗ, видеть прочтения, ограничивать обсуждения
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/ClassRoom/ClassRoomView.swift`, `.build/screenshots/access-class-members-final.png`, `.build/screenshots/access-member-invite-final.png`
  - Комментарий: роль учителя видна в участниках и приглашениях; ограничения обсуждений и реальные права будут после backend/API

- [~] Родкомитет
  - Проверка: может создавать сборы, отмечать оплаты, добавлять чеки, отчеты, события и организационные объявления
  - Уровень: 3
  - Артефакт: `.build/screenshots/access-class-members-final.png`, `.build/screenshots/access-member-invite-final.png`, `.build/screenshots/collections-main-final.png`
  - Комментарий: роль родкомитета есть в UI участников, чатах и сборах; финансовые права ограничены в интерфейсе, но еще не защищены backend-логикой

- [~] Разные роли в разных классах
  - Проверка: один аккаунт может быть родителем в одном классе и родкомитетом/учителем в другом; выбор ребенка переключает контекст класса
  - Уровень: 3
  - Артефакт: `.build/screenshots/more-multi-role-profile.png`, `.build/screenshots/more-multi-role-children.png`, `.build/screenshots/more-multi-role-classes.png`, `.build/screenshots/qa-smoke/more-profile.png`, `.build/screenshots/qa-smoke/more-children.png`, `.build/screenshots/qa-smoke/more-classes.png`, `SchoolApp/Features/More/MoreView.swift`, `scripts/qa_smoke.sh`
  - Комментарий: профиль родителя показывает роли по каждому ребенку/классу, в детских профилях роль можно изменить точечно, а раздел классов строится из тех же профилей; серверная проверка прав и синхронизация ролей остаются backend-слоем

- [~] Администратор класса
  - Проверка: управляет участниками, ролями, приглашениями и доступом
  - Уровень: 3
  - Артефакт: `.build/screenshots/access-classes-final.png`, `.build/screenshots/access-class-members-final.png`, `.build/screenshots/access-member-invite-final.png`, `.build/screenshots/member-management-actions.png`, `.build/screenshots/qa-smoke/class-member-management.png`
  - Комментарий: показаны админ класса, код приглашения и локальное меню управления участниками: смена роли, отключение доступа, удаление и передача админа; серверная проверка и неизменяемый аудит еще не реализованы

- [~] Ребенок, опционально
  - Проверка: видит только ДЗ, расписание и чеклист рюкзака, не видит сборы и родительские обсуждения
  - Уровень: 3
  - Артефакт: `SchoolApp/App/AppView.swift`, `SchoolApp/App/AppTab.swift`, `SchoolApp/Features/Onboarding/OnboardingView.swift`, `SchoolApp/Features/Today/TodayView.swift`, `SchoolApp/Features/More/MoreView.swift`, `.build/screenshots/access-children-final.png`, `.build/screenshots/child-mode-today.png`, `.build/screenshots/qa-smoke/child-mode.png`
  - Комментарий: добавлены профили детей, роль "Ребенок", укороченная навигация `Сегодня / ДЗ / Календарь` и детский главный экран с ДЗ, расписанием, прогрессом и рюкзаком без сборов и родительских чатов; отдельный серверный детский аккаунт и backend-ограничения еще не реализованы

- [~] Матрица прав доступа
  - Проверка: для каждой роли понятно, какие действия разрешены, запрещены и требуют настройки админом
  - Уровень: 3
  - Артефакт: `SchoolApp/Models/SampleData.swift`, `.build/screenshots/access-class-members-final.png`, `.build/screenshots/access-member-invite-final.png`, `.build/screenshots/child-mode-today.png`
  - Комментарий: локальная модель ролей и статусов показана в интерфейсе, включая детский режим без доступа к классу, сборам и родительским обсуждениям; полноценная серверная матрица прав нужна до backend/API

## 3. Дизайн и UX

- [x] Информационная архитектура
  - Проверка: есть нижняя навигация `Сегодня`, `Класс`, `ДЗ`, `Календарь`, `Еще`
  - Уровень: 3
  - Артефакт: `SchoolApp/App/AppTab.swift`, `SchoolApp/App/AppView.swift`
  - Комментарий: навигация реализована кастомной нижней панелью, чтобы дизайн не зависел от стеклянного Tab Bar iOS 26

- [~] Визуальный стиль
  - Проверка: интерфейс выглядит как спокойный семейный помощник для взрослого родителя, не как детская игра
  - Уровень: 3
  - Артефакт: `docs/design/today-dashboard-reference.png`, `SchoolApp/App/SchoolTheme.swift`
  - Комментарий: первый дизайн выбран как основной; в Simulator исправлены проблемы таббара, нижних отступов и обрезания разделов

- [~] Onboarding
  - Проверка: создание класса, присоединение, авторизация, роль, ребенок, уведомления
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/Onboarding/OnboardingView.swift`, `.build/screenshots/onboarding-account-first.png`, `.build/screenshots/qa-smoke/onboarding-phone.png`
  - Комментарий: первый запуск перестроен по шагам: сначала локальный вход в аккаунт, затем выбор статуса/роли, создание класса или вход по коду, данные ребенка/класса, уведомления и обязательное согласие; настоящая авторизация и backend-сохранение еще не подключены

- [~] Экран "Сегодня / Что завтра"
  - Проверка: за 10 секунд отвечает, что сделать ребенку и родителю
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/Today/TodayView.swift`, `.build/screenshots/schedule-today-final.png`, `.build/screenshots/schedule-planner-final.png`
  - Комментарий: реализованы ребенок, "Что завтра", план дня, срочное, ДЗ, расписание, чаты и быстрые действия; проверено скриншотами на iPhone 17 Pro Simulator

- [~] Экран "ДЗ по фото"
  - Проверка: есть съемка, предпросмотр, распознанный текст, правка, сохранение
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/Homework/HomeworkView.swift`, `.build/screenshots/homework-ai-parse-final.png`, `.build/screenshots/homework-attachments-parse.png`, `.build/screenshots/homework-photo-dialog.png`, `.build/screenshots/homework-file-importer.png`
  - Комментарий: показан поток фото/скрина/голоса/файла с системным выбором фото/галереи/файла и локальным распознанным текстом; настоящий OCR/AI/backend будет отдельным этапом

- [~] Экран результата AI-распознавания
  - Проверка: результат разбит по предметам, дедлайнам и задачам; пользователь может исправить
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/Homework/HomeworkView.swift`, `.build/screenshots/homework-ai-parse-final.png`
  - Комментарий: результат парсится в предметы и editable-поля; сохранение добавляет задания в локальный список

- [~] Экран "Класс / Лента"
  - Проверка: объявления, события, сборы, фотоальбомы, закрепленные материалы
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/ClassRoom/ClassRoomView.swift`, `.build/screenshots/regression-class-after-chats.png`, `.build/screenshots/chats-main-final.png`
  - Комментарий: реализованы вкладки ленты, чатов, сборов, фото и участников; лента, чаты и переключатель разделов проверены в Simulator

- [~] Экран "Тихий чат / Важное за день"
  - Проверка: есть дайджест, важное, даты, задачи, платежи и пропущенное
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/ClassRoom/ClassRoomView.swift`, `.build/screenshots/chats-main-final.png`, `.build/screenshots/chat-digest-final.png`
  - Комментарий: реализован локальный тихий дайджест с важными пунктами и действиями; настоящий AI-разбор сообщений и синхронизация будут отдельным этапом

- [~] Экран "Сборы родкомитета"
  - Проверка: видны цель, сумма, дедлайн, кто сдал, кто не сдал, чеки и отчет
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/ClassRoom/ClassRoomView.swift`, `.build/screenshots/collections-main-final.png`, `.build/screenshots/collections-add-final.png`, `.build/screenshots/collections-detail-final.png`
  - Комментарий: реализованы локальные сборы без приема денег: создание, прогресс оплат, подтверждение, расходы и отчет

- [~] Экран "Календарь / событие"
  - Проверка: события, кружки, дедлайны, участники, напоминания
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/Calendar/CalendarView.swift`, `.build/screenshots/calendar-main-interactive-final.png`, `.build/screenshots/calendar-linked-main-final.png`, `.build/screenshots/calendar-linked-detail-final.png`
  - Комментарий: реализованы ближайшие события, неделя, личные кружки, создание события, ответ семьи и связанный сбор в локальном состоянии экрана

- [~] Состояния интерфейса
  - Проверка: пусто, загрузка, ошибка сети, нет прав, нет подписки, нет класса, нет ребенка, успех, отмена
  - Уровень: 3
  - Артефакт: `.build/screenshots/more-qa-states.png`
  - Комментарий: добавлен локальный QA-экран состояний: без учителя, нет класса, нет ребенка, нет ДЗ, нет прав, нет подписки, ошибка сети и отмена действия; загрузка и настоящие backend/offline-состояния еще требуют серверной интеграции

## 4. Техническая архитектура

- [~] Выбрать архитектуру данных
  - Проверка: принято решение между SwiftData/CoreData, backend-first или гибридом
  - Уровень: 1
  - Артефакт: `SchoolApp/Features/ClassRoom/ClassRoomView.swift`
  - Комментарий: для MVP раздел "Класс" сохраняется локально JSON-снимком в `UserDefaults`; финальная архитектура backend/синхронизации еще не выбрана

- [~] Локальное хранение MVP
  - Проверка: объявления, подтверждения прочтения, сборы, статусы, расходы, дайджесты, участники класса, ДЗ, события календаря, дети, семья, классы, подписка, настройки уведомлений, память класса, файлы и состояние главного экрана не сбрасываются при перезапуске приложения
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/ClassRoom/ClassRoomView.swift`, `SchoolApp/Features/Homework/HomeworkView.swift`, `SchoolApp/Features/Calendar/CalendarView.swift`, `SchoolApp/Features/More/MoreView.swift`, `SchoolApp/Features/Today/TodayView.swift`, `SchoolApp/Models/SampleData.swift`
  - Комментарий: временное хранение подходит для проверки UX, но не заменяет аккаунт, серверную синхронизацию, аудит прав и хранение файлов

- [~] Описать основные сущности
  - Проверка: покрыты User, Child, FamilyMember, ClassRoom, ClassMember, Role, Chat, Message, Announcement, Homework, ScheduleItem, Event, Reminder, Collection, Album, Photo, Task, AIParseResult, Subscription, NotificationSetting, AuditLog
  - Уровень: 1
  - Артефакт: `docs/backend_contracts.md`
  - Комментарий: описана целевая доменная модель и связь с текущими локальными MVP-моделями; требуется перенести модели из sample/local state в полноценный слой данных и backend-схему

- [~] Спроектировать API / контракты синхронизации
  - Проверка: понятно, какие данные создаются локально, какие уходят в backend, как решаются конфликты
  - Уровень: 3
  - Артефакт: `docs/backend_contracts.md`, `docs/openapi_mvp.yaml`, `docs/supabase/test_backend_plan.md`, `supabase/migrations/20260704190000_initial_school_schema.sql`, `SchoolApp/Features/More/MoreView.swift`, `.build/screenshots/more-sync-center.png`, `.build/screenshots/more-sync-api-dry-run.png`, `.build/screenshots/qa-smoke/more-sync.png`, `.build/screenshots/qa-smoke/more-sync-supabase.png`, `.build/SchoolAppUITests/summary.txt`
  - Комментарий: зафиксированы формат мутаций, подтверждения сервера, optimistic state, offline-очередь и правила конфликтов; в приложении добавлен локальный центр синхронизации с очередью операций, выбором dev/staging/prod, типизированным каталогом endpoint-ов, dry-run разбором готовности, превью backend-мутаций, batch request preview, typed SyncClient dry-run, auth context, readiness-контроль API, Supabase readiness card для тестового project ref `tlhjwfauddueioatkahm`, Auth session gate для `SUPABASE_ACCESS_TOKEN` / `SUPABASE_REFRESH_TOKEN` / `SUPABASE_USER_ID`, RLS-smoke seed, publishable-key gate, Auth refresh probe, password sign-in probe для `SUPABASE_TEST_EMAIL` / `SUPABASE_TEST_PASSWORD`, Keychain-first seed session store, signed profile probe, signed class scope probe, signed children probe, class/child context mapper preview, local bridge для сохранения Supabase class/child context, QA-gated Supabase child source preview, управляемый из sync-центра переключатель Supabase child source для выбора ребенка/класса с проверкой сохранения после перезапуска и live REST probe `GET /class_rooms?select=id,title,invite_code&limit=3`; первый OpenAPI draft покрывает ключевые MVP endpoint-ы; в Supabase test project применена начальная Postgres-схема с RLS и storage bucket, следующий шаг - production Auth flow и перенос остальных разделов с local store на live-данные

- [~] Подготовить модель ролей на backend
  - Проверка: права проверяются не только в интерфейсе, но и на сервере
  - Уровень: 2
  - Артефакт: `docs/backend_contracts.md`, `SchoolApp/Features/More/MoreView.swift`, `.build/screenshots/more-sync-permissions.png`, `.build/screenshots/qa-smoke/more-sync.png`
  - Комментарий: описана серверная матрица прав для родителей, родкомитета, учителя и администратора класса; в центре синхронизации добавлен локальный policy-аудит действий объявлений, сборов, оплат, фото и приглашений по ролям; фактические backend-проверки еще не подключены, это критично для приватности детей и финансовых сборов

- [~] Настроить окружения
  - Проверка: dev, staging, production разделены
  - Уровень: 1
  - Артефакт: `docs/backend_contracts.md`
  - Комментарий: описаны dev, staging и production с раздельными ключами, базами, файлами, AI, StoreKit и мониторингом; реальные конфигурации окружений еще не созданы

## 5. Авторизация и аккаунт

- [~] Вход по номеру телефона
  - Проверка: отправка кода, повторная отправка, неверный код, ошибка сети
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/Onboarding/OnboardingView.swift`, `.build/screenshots/onboarding-auth-phone-verified.png`, `scripts/qa_smoke.sh`
  - Комментарий: в онбординг добавлен локальный вход по телефону: номер, код `1234`, повторная отправка, статус неверного/неотправленного кода и сохранение выбранного контакта; настоящая SMS-отправка, backend-сессия, rate limit и network errors еще не подключены

- [~] Sign in with Apple
  - Проверка: вход, повторный вход, привязка к существующему аккаунту
  - Уровень: 2
  - Артефакт: `SchoolApp/Features/Onboarding/OnboardingView.swift`, `.build/screenshots/onboarding-auth-apple.png`, `scripts/qa_smoke.sh`
  - Комментарий: добавлена локальная привязка Apple ID/email в онбординге и сохранение способа входа; настоящий Sign in with Apple через entitlement, nonce, credential state и backend-связку аккаунта еще не подключен, желательно для iOS-релиза

- [~] Профиль родителя
  - Проверка: имя, телефон/Apple ID, роли в классах, семейные участники
  - Уровень: 3
  - Артефакт: `.build/screenshots/more-parent-profile.png`
  - Комментарий: добавлен локальный профиль родителя с именем, телефоном, Apple ID/email, ролями в классах и семейными участниками; настоящий вход и верификация контактов еще не подключены

- [~] Удаление аккаунта и данных
  - Проверка: пользователь может удалить аккаунт, ребенка и связанные личные данные
  - Уровень: 3
  - Артефакт: `.build/screenshots/more-account-deletion.png`, `.build/screenshots/security-local-delete-export.png`, `SchoolApp/Features/More/MoreView.swift`
  - Комментарий: в безопасности добавлен локальный сценарий: экспорт-сводка перед удалением, выбор объема, подтверждение словом `УДАЛИТЬ`, локальная очистка выбранных данных, requestId, 7-дневный grace period, re-auth код `1234`, отмена заявки и AuditLog; реальное удаление/восстановление на сервере еще не подключено

## 6. Ребенок, семья и классы

- [~] Добавление ребенка
  - Проверка: имя, класс, школа, смена; можно добавить нескольких детей
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/Onboarding/OnboardingView.swift`, `SchoolApp/Features/More/MoreView.swift`, `SchoolApp/Features/Today/TodayView.swift`, `SchoolAppUITests/SchoolAppUITests.swift`, `.build/screenshots/access-children-final.png`, `.build/screenshots/today-add-child-class-code.png`, `.build/SelectedChildUITest-3.xcresult`
  - Комментарий: добавлен общий локальный список детей: ребенка можно добавить из `Еще` и прямо из выбора ребенка на главной, указав класс, школу, код класса и роль родителя в этом классе; выбранный ребенок сохраняется между вкладками, а UI-тест подтверждает переключение контекста с 3Б на 4А и роль родкомитета; backend-связи детей и классов еще не подключены

- [~] Создание класса
  - Проверка: название класса, школа, город, учебный год, тип организации
  - Уровень: 3
  - Артефакт: `.build/screenshots/onboarding-create-final.png`, `.build/screenshots/onboarding-ready-final.png`
  - Комментарий: локальный UI-сценарий создает комнату и показывает код приглашения; город, учебный год и backend пока не подключены

- [~] Присоединение к классу
  - Проверка: код приглашения, ссылка, QR-код, ошибки доступа
  - Уровень: 3
  - Артефакт: `.build/screenshots/onboarding-join-final.png`, `.build/screenshots/invite-link-qr-class.png`, `.build/screenshots/qa-smoke/class-member-invite.png`
  - Комментарий: реализован UI входа по коду, в приглашении класса добавлены локальная deep link-ссылка и QR; backend-проверка доступа, истечение invite-token и обработка ошибок ссылки еще не подключены

- [~] Приглашение участников
  - Проверка: можно пригласить родителей, учителя, родкомитет и семейных участников
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/ClassRoom/ClassRoomView.swift`, `SchoolApp/Features/More/MoreView.swift`, `.build/screenshots/invite-link-qr-class.png`, `.build/screenshots/invite-link-qr-family.png`, `.build/screenshots/qa-smoke/class-member-invite.png`, `.build/screenshots/qa-smoke/more-family.png`
  - Комментарий: реализованы локальные формы приглашения в класс и семью, deep link-ссылки, QR-коды, обновление кода и системная отправка через ShareLink; реальные backend invite-token, отзыв ссылок и доставка участникам еще не подключены

- [~] Управление участниками
  - Проверка: роли можно изменить, участника можно удалить, права админа можно передать
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/ClassRoom/ClassRoomView.swift`, `.build/screenshots/access-class-members-final.png`, `.build/screenshots/member-management-actions.png`, `.build/screenshots/qa-smoke/class-member-management.png`
  - Комментарий: список участников, роли, статусы и админские бейджи реализованы локально; из меню участника можно сменить роль, отключить или вернуть доступ, удалить участника и передать админа с защитой последнего администратора; backend-аудит и серверные права еще не подключены

- [~] Семейный доступ
  - Проверка: второй родитель, бабушка, няня получают только нужные задачи и напоминания
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/More/MoreView.swift`, `.build/screenshots/access-family-final.png`, `.build/screenshots/more-persistence-family.png`, `.build/screenshots/invite-link-qr-family.png`
  - Комментарий: есть роли семьи, статусы доступа, форма приглашения, семейная ссылка, QR и системная отправка; состояние сохраняется локально, адресные уведомления и реальные ограничения данных еще не подключены

## 7. Главный экран "Сегодня / Что завтра"

- [~] Карточка "Что завтра?"
  - Проверка: показывает уроки, ДЗ, форму, что принести, что оплатить, кружки, события и важные объявления
  - Уровень: 3
  - Артефакт: `.build/screenshots/schedule-today-final.png`, `.build/screenshots/today-state-main.png`, `.build/screenshots/child-mode-today.png`, `.build/screenshots/today-child-profile-switch.png`, `.build/SelectedChildUITest-3.xcresult`
  - Комментарий: показывает уроки на завтра, форму и личный кружок; выбор ребенка сохраняется в общем локальном store и используется в `Сегодня` и `Класс`; UI-тест проверяет, что выбор "Аня, 4А" переносит родителя в "Класс 4А" с ролью родкомитета; для ребенка дополнительно есть безопасный рюкзак и прогресс ДЗ без оплат/чатов; единый backend-дайджест еще не подключен

- [~] Срочное сегодня
  - Проверка: просроченные и срочные задачи не теряются
  - Уровень: 3
  - Артефакт: `.build/screenshots/today-state-main.png`, `.build/screenshots/qa-smoke/today-urgent.png`
  - Комментарий: срочные семейные задачи отображаются отдельным блоком и теперь открываются в отдельный лист со списком; отметки выполнения сохраняются локально, реальные push-напоминания еще не подключены

- [~] Блок ДЗ
  - Проверка: задания сгруппированы по ребенку, предмету и сроку
  - Уровень: 3
  - Артефакт: `.build/screenshots/today-state-main.png`, `.build/screenshots/today-add-homework.png`, `.build/screenshots/today-homework-sheet.png`
  - Комментарий: ДЗ на главном экране теперь открывается в отдельный лист с заданиями и галочками; добавить ДЗ можно через быстрый лист, состояние сохраняется локально

- [~] Блок "Принести / оплатить / подписать"
  - Проверка: задачи для родителя отделены от задач ребенка
  - Уровень: 3
  - Артефакт: `.build/screenshots/today-add-task-payment.png`, `.build/screenshots/today-state-main.png`
  - Комментарий: семейные задачи отделены от ДЗ, имеют тип, срок, исполнителя и локальный статус выполнения; адресные push-напоминания еще не подключены

- [~] Расписание и кружки
  - Проверка: видно школьное расписание и личные занятия ребенка
  - Уровень: 3
  - Артефакт: `.build/screenshots/schedule-planner-final.png`
  - Комментарий: есть выбор дня, список уроков, кабинеты, учителя, форма, замены и личные кружки; пока локальное состояние без синхронизации

- [~] Важное из чата
  - Проверка: важное показывается без необходимости читать весь чат
  - Уровень: 3
  - Артефакт: `.build/screenshots/today-important-chat.png`, `.build/screenshots/today-chats-sheet.png`
  - Комментарий: важные сообщения показываются отдельной карточкой, их можно закрыть или превратить в семейную задачу; карточка чатов на главной теперь открывает лист чатов; реальный AI-дайджест чата еще не подключен

- [~] Быстрые действия
  - Проверка: доступны "Разобрать", "Добавить ДЗ", "Добавить задачу", "Добавить кружок", "Открыть чат"
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/Today/TodayView.swift`, `.build/screenshots/today-global-parse.png`, `.build/screenshots/today-add-homework.png`, `.build/screenshots/today-add-task-payment.png`, `.build/screenshots/today-important-chat.png`
  - Комментарий: быстрые кнопки открывают глобальный разбор, добавление ДЗ, семейную задачу, оплату, расписание и важное из чата; переход в полноценное создание события еще остается за вкладкой календаря

## 8. Домашние задания

- [~] Ручное добавление ДЗ
  - Проверка: предмет, текст, дедлайн, вложения, автор, статус
  - Уровень: 3
  - Артефакт: `.build/screenshots/homework-add-final.png`, `.build/screenshots/homework-persistence-add.png`, `.build/screenshots/homework-add-attachments.png`
  - Комментарий: ручное добавление работает и сохраняется локально; можно прикрепить фото или файл как локальную пометку исходника, хранение бинарных файлов еще не подключено

- [~] Список ДЗ
  - Проверка: вкладки Сегодня, Завтра, Неделя, Выполнено; фильтры по ребенку, предмету, статусу и источнику
  - Уровень: 3
  - Артефакт: `.build/screenshots/homework-main-final.png`, `.build/screenshots/homework-persistence-main.png`, `.build/screenshots/homework-filters.png`, `.build/screenshots/homework-width-fixed.png`, `.build/screenshots/qa-smoke/homework-filters.png`
  - Комментарий: есть вкладки по сроку, счетчики, локальное хранение между перезапусками и отдельные фильтры по ребенку, предмету, статусу и источнику; ширина экрана зафиксирована по viewport, длинные строки карточек ДЗ адаптивно переносятся без горизонтального смещения; серверная синхронизация и общий поиск по истории еще не подключены

- [~] Отметка выполнения
  - Проверка: родитель/ребенок может отметить ДЗ выполненным, статус сохраняется
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/Homework/HomeworkView.swift`
  - Комментарий: статус меняется и сохраняется локально между перезапусками; серверная синхронизация еще не подключена

- [~] Вложения и фото
  - Проверка: можно прикрепить фото доски, дневника, тетради или файл
  - Уровень: 3
  - Артефакт: `.build/screenshots/homework-attachments-parse.png`, `.build/screenshots/homework-photo-dialog.png`, `.build/screenshots/homework-file-importer.png`, `.build/screenshots/homework-add-attachments.png`, `.build/screenshots/homework-add-photo-dialog.png`, `.build/screenshots/homework-add-file-importer.png`
  - Комментарий: в разборе и ручном добавлении ДЗ есть системный выбор фото/галереи и файла; выбранный исходник сохраняется как локальная пометка, хранение бинарных вложений и OCR еще не подключены

- [~] История ДЗ
  - Проверка: старые задания доступны и не теряются после срока
  - Уровень: 3
  - Артефакт: `.build/screenshots/homework-persistence-main.png`, `.build/screenshots/homework-add-attachments.png`, `.build/screenshots/qa-smoke/homework-archive.png`
  - Комментарий: выполненные задания остаются во вкладке "Выполнено", локальное хранилище не сбрасывает ДЗ между перезапусками, а отдельный экран "Архив ДЗ" группирует готовые задания по срокам и детям; серверная история по календарным датам еще не подключена

- [~] ДЗ по фото
  - Проверка: съемка, распознавание, правка текста, разбиение по предметам, сохранение
  - Уровень: 3
  - Артефакт: `.build/screenshots/homework-ai-parse-final.png`
  - Комментарий: одна из главных AI-функций MVP; сейчас реализован UX и локальный парсер, не реальный OCR

- [~] Ошибки AI-распознавания
  - Проверка: пользователь может исправить результат и сообщить об ошибке
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/Homework/HomeworkView.swift`, `SchoolApp/Models/SampleData.swift`, `.build/screenshots/homework-ai-report.png`, `.build/screenshots/more-ai-quality-after-report.png`, `.build/screenshots/qa-smoke/homework-ai-report.png`, `.build/screenshots/qa-smoke/more-ai-quality.png`
  - Комментарий: пользователь может исправить распознанный текст и поля результата, а также отправить ошибку в локальный журнал качества AI; backend-датасет ошибок и обучение модели еще не подключены

## 9. Чат и объявления

- [~] Общий чат класса
  - Проверка: сообщения, вложения, фото, документы, голосовые, реакции
  - Уровень: 3
  - Артефакт: `.build/screenshots/chats-main-final.png`, `.build/screenshots/chat-detail-final.png`, `.build/screenshots/qa-smoke/class-chat-detail.png`
  - Комментарий: есть локальные ветки чатов, сообщения, непрочитанные, быстрый ответ, системный выбор файла, фото-пометка, отображение вложений, voice-note с длительностью, действия из важных сообщений, закрепленные сообщения и реакции со счетчиками; реальная запись аудио, хранение бинарных файлов и backend не подключены

- [~] Объявления учителя
  - Проверка: отдельный канал объявлений, важные объявления, закрепление
  - Уровень: 3
  - Артефакт: `.build/screenshots/announcement-add-final.png`, `.build/screenshots/announcement-detail-final.png`, `.build/screenshots/bugfix-parent-announcement-blocked.png`, `.build/screenshots/announcement-comments-create.png`, `.build/screenshots/qa-smoke/class-chat-detail.png`
  - Комментарий: есть создание объявления, канал, подтверждение прочтения с сохранением состояния, детальный просмотр, настройка обсуждения и локальное закрепление сообщений в канале; родителю публикация заблокирована локально, доставка участникам еще не реализована

- [~] Чат родкомитета
  - Проверка: доступен нужным ролям, не смешивается с общим чатом
  - Уровень: 3
  - Артефакт: `.build/screenshots/chats-main-final.png`
  - Комментарий: отдельная локальная ветка родкомитета видна рядом с общим чатом и учительскими объявлениями; часть прав проверяется в UI, серверная проверка еще не реализована

- [~] Комментарии под объявлениями
  - Проверка: можно включить/выключить обсуждение
  - Уровень: 3
  - Артефакт: `.build/screenshots/announcement-comments-detail.png`, `.build/screenshots/announcement-comments-create.png`
  - Комментарий: у объявления есть локальные комментарии, быстрый ответ и переключатель обсуждения при создании/редактировании автором; модерация, жалобы и серверная синхронизация еще не реализованы

- [~] Индикатор прочтения
  - Проверка: автор важного объявления видит, кто прочитал и кто подтвердил
  - Уровень: 3
  - Артефакт: `.build/screenshots/announcement-detail-final.png`
  - Комментарий: в UI есть счетчик прочтений и подтверждение семьи; список конкретных родителей и серверная фиксация прочтения еще не реализованы

- [~] AI-дайджест чата
  - Проверка: показывает важное за день, пропущенное, даты, платежи, задачи и файлы
  - Уровень: 3
  - Артефакт: `.build/screenshots/chats-main-final.png`, `.build/screenshots/chat-digest-final.png`
  - Комментарий: UX тихого дайджеста реализован локально; настоящего AI-суммаризатора, источников сообщений и файлов пока нет

- [~] Создание задач из чата
  - Проверка: дата, ДЗ, сбор или "принести" превращаются в структурированный объект
  - Уровень: 3
  - Артефакт: `.build/screenshots/chat-detail-final.png`, `.build/screenshots/chat-digest-final.png`
  - Комментарий: важные сообщения и пункты дайджеста имеют действия "создать задачу", "добавить к ДЗ" и "добавить в календарь"; пока это локальная отметка без записи в общие ДЗ/календарь

## 10. Календарь и события

- [~] Список и календарь событий
  - Проверка: режимы день, неделя, месяц, список
  - Уровень: 3
  - Артефакт: `.build/screenshots/calendar-main-interactive-final.png`
  - Комментарий: есть переключатель режимов и список событий; режимы день/неделя/месяц пока используют общий визуальный слой без отдельной логики

- [~] Создание события
  - Проверка: название, дата, место, описание, участники, ответственные, документы, напоминания
  - Уровень: 3
  - Артефакт: `.build/screenshots/calendar-add-event-final.png`, `.build/screenshots/calendar-participants-documents.png`, `.build/screenshots/qa-smoke/calendar-add.png`, `.build/screenshots/qa-smoke/calendar-detail.png`
  - Комментарий: локально создается событие с названием, датой, типом, местом, описанием, ответственным, участниками, документами, связкой со сбором и настройкой напоминания; системные уведомления и серверная доставка участникам еще не подключены

- [~] Типы событий
  - Проверка: контрольная, экскурсия, собрание, праздник, дедлайн оплаты, проект, медосмотр, кружок, репетитор, личное дело
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/Calendar/CalendarView.swift`
  - Комментарий: в UI есть экскурсия, контрольная, собрание, праздник, сбор, кружок и личное дело; полный список типов из ТЗ еще нужно расширить

- [~] Подтверждение участия
  - Проверка: участник может подтвердить, отказаться или задать вопрос
  - Уровень: 3
  - Артефакт: `.build/screenshots/calendar-event-detail-final.png`, `.build/screenshots/calendar-persistence-detail.png`, `.build/screenshots/calendar-participants-documents.png`, `.build/screenshots/qa-smoke/calendar-detail.png`
  - Комментарий: ответ семьи меняется между "Жду ответа", "Идем", "Не сможем" и "Есть вопрос" и сохраняется локально; в деталях видны участники, документы и связанный сбор; серверное сохранение и уведомление организатора еще не реализованы

- [~] Связь события со сбором
  - Проверка: экскурсия или праздник могут иметь связанный сбор
  - Уровень: 3
  - Артефакт: `.build/screenshots/calendar-linked-main-final.png`, `.build/screenshots/calendar-linked-detail-final.png`, `.build/screenshots/calendar-linked-add-final.png`
  - Комментарий: событие может показывать связанный сбор и сумму; создание события сохраняет связку локально, но пока без общего backend-объекта между календарем и разделом сборов

## 11. Сборы и родкомитет

- [~] Создание сбора
  - Проверка: название, сумма, дедлайн, кому сдавать, описание, участники, напоминания, публикация
  - Уровень: 3
  - Артефакт: `.build/screenshots/collections-add-final.png`, `.build/screenshots/bugfix-parent-collections.png`
  - Комментарий: сбор создается и сохраняется локально с названием, суммой, дедлайном, ответственным, описанием, участниками и переключателем напоминания; родителю создание заблокировано, реальная публикация и backend еще не подключены

- [~] Статусы оплат
  - Проверка: "сдал / не сдал", подтверждение получения родкомитетом
  - Уровень: 3
  - Артефакт: `.build/screenshots/collections-detail-final.png`, `.build/screenshots/bugfix-parent-collection-detail.png`, `.build/screenshots/bugfix-committee-collection-detail.png`
  - Комментарий: родитель может отметить только оплату своей семьи; общий счетчик и статус сбора меняет родкомитет, запрет родителю менять счетчик/статус закреплен UI-тестом; изменения сохраняются локально между перезапусками, backend еще не подключен

- [~] Карточка сбора
  - Проверка: цель, сумма с человека, общая сумма, дедлайн, статус, сколько сдали, сколько осталось
  - Уровень: 3
  - Артефакт: `.build/screenshots/collections-main-final.png`
  - Комментарий: карточка показывает цель, сумму с семьи, дедлайн, статус, прогресс и остаток; общий бюджет еще нужно считать отдельно после финансовой модели

- [~] Чеки и расходы
  - Проверка: можно добавить чек, расход и отчет
  - Уровень: 3
  - Артефакт: `.build/screenshots/collections-detail-final.png`, `.build/screenshots/bugfix-committee-collection-detail.png`, `.build/screenshots/receipt-attachments-form-final.png`, `.build/screenshots/receipt-photo-dialog.png`, `.build/screenshots/receipt-file-importer.png`, `.build/screenshots/class-collection-report.png`, `.build/screenshots/qa-smoke/class-collection-report.png`
  - Комментарий: в детальном листе есть список расходов, локальное добавление расхода, системный выбор фото/камеры и файла с сохранением имени вложения, финансовая сводка и системная отправка текстового отчета; полноценное копирование файлов в хранилище и backend еще не подключены

- [~] Напоминания по сбору
  - Проверка: мягкие напоминания не оплатившим и дедлайны
  - Уровень: 3
  - Артефакт: `.build/screenshots/collections-add-final.png`
  - Комментарий: есть настройка напоминания в UI; системные уведомления и адресная рассылка не оплатившим пока не реализованы

- [~] Закрытие сбора и отчет
  - Проверка: сбор можно завершить, скачать или показать отчет
  - Уровень: 3
  - Артефакт: `.build/screenshots/collections-detail-final.png`, `.build/screenshots/class-collection-report.png`, `.build/screenshots/qa-smoke/class-collection-report.png`
  - Комментарий: статус можно перевести в "Закрыт", отчет виден в карточке, состояние сохраняется локально, а текстовый отчет можно отправить через системное меню; PDF/Excel-выгрузка будет отдельным этапом

## 12. Расписание

- [~] Недельное расписание уроков
  - Проверка: дни недели, уроки, кабинеты, учителя, форма для физкультуры
  - Уровень: 3
  - Артефакт: `.build/screenshots/schedule-planner-final.png`
  - Комментарий: реализовано локальное недельное расписание с выбором дня, временем, кабинетом, учителем и пометкой формы

- [~] Замены
  - Проверка: можно добавить замену, она видна в "Сегодня / Что завтра"
  - Уровень: 3
  - Артефакт: `.build/screenshots/schedule-planner-final.png`, `.build/screenshots/schedule-add-final.png`
  - Комментарий: замены отображаются бейджем и могут быть добавлены через форму урока; сохранение пока только в состоянии экрана

- [~] Личные кружки и секции
  - Проверка: повторяющиеся занятия ребенка отображаются в календаре и главном экране
  - Уровень: 3
  - Артефакт: `.build/screenshots/schedule-today-final.png`, `.build/screenshots/schedule-planner-final.png`
  - Комментарий: личные кружки отображаются в "Что завтра" и плане дня; связь с календарем и повторяемостью еще нужно довести до единой модели

- [~] Расписание по фото
  - Проверка: фото расписания распознается, приводится к таблице и подтверждается пользователем
  - Уровень: 3
  - Артефакт: `.build/screenshots/schedule-import-final.png`
  - Комментарий: реализован локальный UX распознанного текста и подтверждения добавляемых уроков; настоящие камера, OCR и AI/backend еще не подключены

## 13. Фотоальбом

- [~] Память класса
  - Проверка: поиск по важным объявлениям, событиям, файлам и ручным заметкам класса
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/More/MoreView.swift`, `.build/screenshots/more-memory-screen.png`
  - Комментарий: реализован локальный экран памяти класса с поиском, типами записей и добавлением заметки; настоящий поиск по backend, фото и сообщениям еще не подключен

- [~] Файлы класса
  - Проверка: согласия, чеки и материалы видны по категориям, можно открыть системный выбор файла
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/More/MoreView.swift`, `.build/screenshots/more-files-screen.png`, `.build/screenshots/more-files-importer.png`
  - Комментарий: реализован локальный каталог файлов с фильтрами, поиском, ручным добавлением и document picker; бинарное хранение файлов, права доступа и синхронизация еще не подключены

- [~] Альбомы класса
  - Проверка: можно создать новый альбом, открыть альбом события, загрузить фото и смотреть снимки крупно с перелистыванием
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/ClassRoom/ClassRoomView.swift`, `scripts/qa_smoke.sh`, `.build/screenshots/class-photos-main.png`, `.build/screenshots/class-photo-album.png`, `.build/screenshots/class-photo-album-create.png`, `.build/screenshots/class-photo-viewer.png`, `.build/screenshots/class-photo-dialog.png`, `.build/screenshots/class-photo-file-importer.png`, `.build/screenshots/qa-smoke/class-photo-album-create.png`
  - Комментарий: добавлены локальные альбомы, создание нового альбома для учителя/родкомитета, детальный экран альбома, горизонтальная лента, крупный просмотр фото с перелистыванием и добавление фото/файла; облачное хранение еще не реализовано

- [~] Доступ только участникам класса
  - Проверка: фото недоступны публично и без авторизации
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/ClassRoom/ClassRoomView.swift`, `.build/screenshots/class-photos-main.png`, `.build/screenshots/class-photo-album.png`
  - Комментарий: в UI явно показан закрытый доступ и отсутствие публичной ссылки; настоящая серверная авторизация и приватное файловое хранилище обязательны до релиза

- [~] Действия с фото
  - Проверка: загрузить, скачать, поделиться, пожаловаться, удалить
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/ClassRoom/ClassRoomView.swift`, `.build/screenshots/class-photo-album.png`, `.build/screenshots/class-photo-viewer.png`, `.build/screenshots/class-photo-dialog.png`, `.build/screenshots/class-photo-file-importer.png`
  - Комментарий: добавлены локальные действия загрузить, скачать, поделиться, пожаловаться и удалить; удаление показывается только учителю и родкомитету, запрет удаления для родителя закреплен UI-тестом; реальные share/download/moderation API еще не подключены

- [x] Ограничить будущие функции
  - Проверка: поиск ребенка по фото, фотокниги и скрытие лиц не попали в первый MVP без отдельного решения
  - Уровень: 2
  - Артефакт: `docs/mvp_scope.md`
  - Комментарий: поиск ребенка по фото, печать фотокниг и выпускные альбомы вынесены из первого MVP

## 14. Семейный диспетчер

- [~] Члены семьи
  - Проверка: можно добавить второго родителя, бабушку, няню
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/More/MoreView.swift`, `.build/screenshots/access-family-final.png`
  - Комментарий: локально добавляются и отображаются члены семьи с ролью и объемом доступа; синхронизация и реальные приглашения еще не реализованы

- [~] Назначение задач
  - Проверка: задача может быть назначена конкретному члену семьи
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/More/MoreView.swift`, `.build/screenshots/more-family-tasks.png`
  - Комментарий: добавлен локальный экран "Задачи семьи" с выбором исполнителя и сохранением в `UserDefaults`; реальная синхронизация семьи еще не подключена

- [~] Персональные напоминания
  - Проверка: исполнитель получает только свои напоминания
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/More/MoreView.swift`, `.build/screenshots/more-family-tasks.png`
  - Комментарий: у каждой семейной задачи есть исполнитель и текст персонального времени напоминания; реальные push-уведомления и адресная доставка требуют backend/APNs

- [~] Передача задачи
  - Проверка: "Передать папе/бабушке", "Я сделаю", "Готово" работают понятно
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/More/MoreView.swift`, `.build/screenshots/more-family-tasks.png`
  - Комментарий: на задаче есть действия "Я сделаю", "Передать" и "Готово"; визуально проверено в Simulator, программные автотапы пока не заведены

## 15. AI-помощник "Разобрать"

- [~] Глобальная кнопка "Разобрать"
  - Проверка: доступна из нужных экранов и принимает фото, скрин, текст, голосовое или документ
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/Today/TodayView.swift`, `.build/screenshots/today-global-parse.png`, `.build/screenshots/today-global-parse-photo-dialog.png`, `.build/screenshots/today-global-parse-file-importer.png`
  - Комментарий: добавлен глобальный лист "Разобрать" на главном экране с источниками фото, скрин, файл, голос и текст; системные фото/файл проверены в Simulator

- [~] Разбор ДЗ
  - Проверка: из текста вроде "мат стр 45 N 6,7,8; рус упр 123 правило" получается структурированное ДЗ
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/Today/TodayView.swift`, `.build/screenshots/today-global-parse.png`
  - Комментарий: локальный parser выделяет предмет, задание и срок, а сохранение добавляет результат в Today-ДЗ со статусом "Проверить"; настоящий OCR/AI еще не подключен

- [~] Выделение дат и событий
  - Проверка: AI предлагает создать событие с датой, временем и описанием
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/Today/TodayView.swift`, `.build/screenshots/today-global-parse.png`
  - Комментарий: локальный parser распознает события вроде театр/музей/экскурсия и предлагает их как отдельный результат; пока сохраняется в семейные задачи Today, не в полноценный календарь

- [~] Выделение платежей
  - Проверка: AI находит сумму, дедлайн и назначение сбора
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/Today/TodayView.swift`, `.build/screenshots/today-global-parse.png`
  - Комментарий: локальный parser выделяет сборы/оплаты/рубли и сохраняет их как задачи оплаты; создание полноценного сбора родкомитета из AI еще не подключено

- [~] Выделение "принести / подписать / купить"
  - Проверка: результат превращается в задачу родителя или ребенка
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/Today/TodayView.swift`, `.build/screenshots/today-global-parse.png`
  - Комментарий: локальный parser выделяет принести/подписать/купить и сохраняет как семейные задачи в Today-состояние

- [~] Пользовательское подтверждение AI
  - Проверка: ничего важного не сохраняется автоматически без подтверждения пользователя
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/Today/TodayView.swift`, `.build/screenshots/today-global-parse.png`
  - Комментарий: результаты показываются в редактируемых строках, пользователь может поменять тип/текст/срок/исполнителя и только потом нажать "Сохранить результат"; это снижает риск ошибок AI

- [~] Логи и качество AI
  - Проверка: есть способ оценивать ошибки, повторять запрос и улучшать промпты/модель
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/More/MoreView.swift`, `SchoolApp/Models/SampleData.swift`, `.build/screenshots/more-ai-quality.png`, `.build/screenshots/more-ai-quality-after-report.png`, `scripts/qa_smoke.sh`
  - Комментарий: добавлен общий локальный журнал качества AI с источником разбора, уверенностью, статусом, версией промпта, количеством попыток, действиями принять/повторить/улучшить промпт и записями ошибок из ДЗ; реальные backend-логи, датасет ошибок и обучение модели еще не подключены

## 16. Уведомления

- [~] Разрешение на уведомления
  - Проверка: onboarding объясняет пользу и корректно обрабатывает отказ
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/Onboarding/OnboardingView.swift`, `SchoolApp/Features/More/MoreView.swift`, `docs/openapi_mvp.yaml`, `.build/screenshots/notifications-ios-local.png`, `.build/screenshots/qa-smoke/more-notifications.png`
  - Комментарий: в онбординге есть объяснение и переключатель, в настройках добавлен системный запрос `UNUserNotificationCenter.requestAuthorization`; обработка отказа видна в статусе; экран показывает APNs readiness для `POST /devices/push-token`, настоящий push-сервер еще не подключен

- [~] Вечерний дайджест
  - Проверка: вечером пользователь получает "что завтра"
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/More/MoreView.swift`, `.build/screenshots/notifications-ios-local.png`
  - Комментарий: есть локальный переключатель, выбор времени и планирование повторяющегося `UNCalendarNotificationTrigger`; контент пока локальный, серверный дайджест будет отдельным этапом

- [~] Утренний дайджест
  - Проверка: утром пользователь видит расписание, форму, срочные задачи
  - Уровень: 3
  - Артефакт: `.build/screenshots/notifications-ios-local.png`
  - Комментарий: есть локальный переключатель, выбор времени и планирование повторяющегося утреннего уведомления; контент пока собирается из локальных экранов, не из backend

- [~] Срочные объявления
  - Проверка: важные объявления доставляются отдельно и заметно
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/More/MoreView.swift`, `.build/screenshots/notifications-ios-local.png`, `.build/screenshots/notifications-scheduled-local.png`, `.build/screenshots/qa-smoke/more-notifications.png`
  - Комментарий: настройка срочных объявлений есть в UI, локальный MVP планирует отдельное time-sensitive iOS-уведомление; backend-контракт фиксирует `time_sensitive`, dispatch preview и обход тихих часов для срочного, реальная APNs-доставка еще не подключена

- [~] Дедлайны оплат
  - Проверка: напоминания приходят до срока и при просрочке
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/More/MoreView.swift`, `.build/screenshots/notifications-ios-local.png`, `.build/screenshots/notifications-scheduled-local.png`, `.build/screenshots/qa-smoke/more-notifications.png`
  - Комментарий: есть локальная настройка напоминаний по сборам и планирование отдельного локального iOS-уведомления с учетом тихих часов; адресные напоминания не оплатившим требуют backend

- [~] Настройки уведомлений
  - Проверка: тихие часы, время дайджестов, настройки по ребенку и классу
  - Уровень: 3
  - Артефакт: `.build/screenshots/notification-settings-final.png`, `.build/screenshots/more-persistence-notifications-final.png`, `.build/screenshots/notifications-ios-local.png`
  - Комментарий: реализованы и локально сохраняются переключатели, вечер/утро, тихие часы, статус разрешения iOS, счетчик ожидающих уведомлений, тест через 5 секунд и пересборка расписания; настройки по конкретному ребенку/классу еще не детализированы

## 17. Подписка и монетизация

- [~] Модель тарифов
  - Проверка: базовая цена 149 руб./мес за первого ребенка и 59 руб./мес за дополнительного ребенка подтверждена или изменена
  - Уровень: 3
  - Артефакт: `SchoolApp/Models/SampleData.swift`, `.build/screenshots/subscription-settings-final.png`
  - Комментарий: в UI зафиксированы trial, 149 руб./мес за первого ребенка и +59 руб./мес за дополнительного; финальная коммерческая модель еще требует подтверждения

- [~] Paywall
  - Проверка: показывает конкретную ценность: "Что завтра", ДЗ по фото, напоминания, кружки, семейный доступ, AI-разбор
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/More/MoreView.swift`, `.build/screenshots/subscription-settings-final.png`, `.build/screenshots/more-persistence-subscription.png`
  - Комментарий: реализован локальный экран подписки с ценностью trial и функций; выбранный тариф сохраняется локально, полноценный paywall перед ограниченными действиями еще не внедрен

- [~] StoreKit 2
  - Проверка: покупка, trial, восстановление покупок, истекшая подписка, ошибка оплаты
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/More/MoreView.swift`, `docs/storekit_mvp_plan.md`, `.build/screenshots/subscription-storekit-local.png`, `.build/screenshots/subscription-storekit-products.png`, `.build/screenshots/qa-smoke/more-subscription.png`
  - Комментарий: добавлены product id, локальная проверка покупки, восстановления, истекшей подписки и ошибки оплаты; экран подписки теперь запрашивает StoreKit 2 каталог через `Product.products(for:)`, показывает пустой/ошибочный каталог и fallback-цены; App Store Connect продукты, `product.purchase()`, подпись транзакций и серверная проверка entitlement еще не подключены

- [~] Ограничения без подписки
  - Проверка: базовые данные не исчезают, но AI и расширенные функции ограничиваются понятно и честно
  - Уровень: 3
  - Артефакт: `.build/screenshots/today-paywall.png`, `.build/screenshots/homework-paywall.png`, `.build/screenshots/qa-smoke/today-paywall.png`, `.build/screenshots/qa-smoke/homework-paywall.png`, `SchoolApp/Models/SampleData.swift`, `SchoolApp/Features/Today/TodayView.swift`, `SchoolApp/Features/Homework/HomeworkView.swift`, `SchoolApp/Features/More/MoreView.swift`, `scripts/qa_smoke.sh`
  - Комментарий: добавлен локальный статус доступа к подписке; при отсутствии подписки AI-разбор на главной и в ДЗ открывает понятный paywall, а ручные данные, списки, расписание и фильтры остаются доступны; серверная entitlement-проверка еще не подключена

## 18. Безопасность и приватность

- [~] Закрытые классы
  - Проверка: доступ только по приглашению, бывших участников можно удалить
  - Уровень: 3
  - Артефакт: `.build/screenshots/access-classes-final.png`, `.build/screenshots/access-member-invite-final.png`, `.build/screenshots/member-management-actions.png`, `.build/screenshots/more-security-screen.png`
  - Комментарий: в UI показаны закрытый код класса, приглашения, переключатель "Только участники класса" и локальное отключение/удаление участников; настоящее закрытие доступа и проверка на сервере еще не реализованы

- [~] Минимизация данных детей
  - Проверка: собираются только нужные данные, нет лишней персональной информации
  - Уровень: 3
  - Артефакт: `.build/screenshots/more-privacy-screen.png`, `.build/screenshots/privacy-consent-settings.png`
  - Комментарий: добавлен локальный экран приватности с принципом минимального профиля ребенка; согласие из онбординга подтягивается в настройки; требуется серверная модель данных, ревизия всех полей и юридическая проверка

- [~] Согласие на обработку данных ребенка
  - Проверка: согласие есть в нужном месте и сохраняется
  - Уровень: 3
  - Артефакт: `.build/screenshots/privacy-consent-settings.png`, `.build/screenshots/qa-smoke/more-privacy.png`, `SchoolApp/Features/Onboarding/OnboardingView.swift`, `SchoolApp/Models/SampleData.swift`
  - Комментарий: согласие родителя и принятие политики обязательны в онбординге, сохраняются локально с временем и отображаются в настройках приватности; требуется финальный юридический текст, версия согласия и серверное хранение факта согласия

- [~] Хранение данных
  - Проверка: если запуск в РФ, данные хранятся в РФ или есть юридически проверенная схема
  - Уровень: 3
  - Артефакт: `.build/screenshots/more-security-screen.png`, `.build/screenshots/security-local-delete-export.png`
  - Комментарий: добавлен локальный экран безопасности с экспортом и очисткой локальных данных по выбранному объему; юридически важный пункт, серверная схема хранения и документы еще не готовы

- [~] Фотоальбомы защищены
  - Проверка: нет публичных ссылок без авторизации, контент не индексируется
  - Уровень: 3
  - Артефакт: `.build/screenshots/class-photos-main.png`, `.build/screenshots/class-photo-album.png`
  - Комментарий: в локальном UI фотоальбомы показаны как закрытая зона класса без публичных ссылок; серверная авторизация, запрет индексации и политики хранения еще не подключены

- [~] Жалобы и модерация
  - Проверка: можно пожаловаться на сообщение, фото или участника
  - Уровень: 3
  - Артефакт: `.build/screenshots/class-photo-album.png`, `.build/screenshots/qa-smoke/more-moderation.png`
  - Комментарий: добавлен локальный центр модерации с очередью жалоб на фото, сообщение и участника, статусами "Новая / На проверке / Закрыта" и правилами безопасности; серверная очередь, аудит решения и уведомления еще не подключены

- [~] Политика конфиденциальности
  - Проверка: документ готов, доступен в onboarding и настройках
  - Уровень: 3
  - Артефакт: `.build/screenshots/more-privacy-screen.png`, `.build/screenshots/qa-smoke/more-legal.png`
  - Комментарий: в настройках добавлен краткий центр приватности и отдельный юридический центр с черновиками политики, условий, согласием родителя, App Store-блокерами и статусом публикации; финальный юридический обзор и публичная HTTPS-ссылка еще не готовы

- [~] Аудит действий
  - Проверка: важные действия ролей пишутся в AuditLog
  - Уровень: 3
  - Артефакт: `.build/screenshots/more-audit-log.png`
  - Комментарий: добавлен локальный журнал действий в разделе "Еще": роли, доступы, файлы, подписка, уведомления, безопасность и семейные задачи фиксируются на устройстве; серверный неизменяемый AuditLog еще не подключен

## 19. Аналитика

- [~] События установки и аккаунта
  - Проверка: app_installed, account_created, child_added
  - Уровень: 3
  - Артефакт: `.build/screenshots/more-mvp-metrics.png`
  - Комментарий: добавлены локальные события app_installed, account_created и child_added в экран MVP-метрик; реальная отправка и дедупликация событий еще не подключены

- [~] События класса
  - Проверка: class_created, class_joined, parent_invited, teacher_invited, class_activated
  - Уровень: 3
  - Артефакт: `.build/screenshots/more-mvp-metrics.png`
  - Комментарий: локально заведены class_created и parent_invited, а активация класса показана в главной метрике; class_joined, teacher_invited и серверная class_activated-логика еще не реализованы

- [~] События ДЗ и AI
  - Проверка: homework_created, homework_photo_scanned, ai_result_saved
  - Уровень: 3
  - Артефакт: `.build/screenshots/more-mvp-metrics.png`
  - Комментарий: локально заведены события создания ДЗ, разбора фото/файла и сохранения AI-результата; настоящая аналитика по каждому действию еще не отправляется

- [~] События календаря и сборов
  - Проверка: event_created, collection_created, reminder_triggered
  - Уровень: 3
  - Артефакт: `.build/screenshots/more-mvp-metrics.png`
  - Комментарий: локально заведены event_created и collection_created; reminder_triggered потребует настоящих уведомлений

- [~] События подписки
  - Проверка: paywall_viewed, trial_started, subscription_started, subscription_cancelled
  - Уровень: 3
  - Артефакт: `.build/screenshots/more-mvp-metrics.png`
  - Комментарий: локально заведены paywall_viewed и trial_started; subscription_started/subscription_cancelled требуют StoreKit 2

- [~] Дашборд MVP-метрик
  - Проверка: видны активация класса, 3+ ДЗ в неделю, 1+ событие/сбор, retention 30 дней, конверсия в подписку
  - Уровень: 4
  - Артефакт: `.build/screenshots/more-mvp-metrics.png`, `.build/screenshots/qa-smoke/more-metrics.png`, `.build/SchoolAppUITests/summary.txt`, `SchoolAppUITests/SchoolAppUITests.swift`
  - Комментарий: добавлен локальный экран MVP-метрик с активацией класса, ДЗ в неделю, событиями/сборами, retention 30 дней и trial/подпиской; UI-тест добавляет событие `qa_smoke_passed` и проверяет его сохранение после перезапуска приложения, smoke снимает отдельный кадр `more-metrics`; backend-дашборд и реальные cohort-метрики еще не готовы

## 20. QA и приемка

- [~] Smoke-тест основного сценария
  - Проверка: создать класс, пригласить родителя, добавить ДЗ, добавить событие/сбор, получить напоминание
  - Уровень: 3
  - Артефакт: `.build/screenshots/onboarding-create-final.png`, `.build/screenshots/access-member-invite-final.png`, `.build/screenshots/homework-add-final.png`, `.build/screenshots/calendar-add-event-final.png`, `.build/screenshots/collections-add-final.png`
  - Комментарий: ключевые части сценария пройдены локально в Simulator; непрерывный end-to-end поток с аккаунтом, backend и уведомлениями еще не готов

- [~] Проверка без учителя
  - Проверка: родитель или родкомитет может запустить пользу продукта самостоятельно
  - Уровень: 3
  - Артефакт: `.build/screenshots/more-qa-states.png`, `docs/mvp_scope.md`
  - Комментарий: в продуктовой рамке и QA-экране зафиксирован сценарий запуска без учителя: родитель/родкомитет может вести ДЗ, события, сборы, семью и приглашения; реальный multi-user тест с родителями еще нужен

- [~] Проверка ролей и прав
  - Проверка: пользователь не может делать действия вне своей роли
  - Уровень: 3
  - Артефакт: `.build/screenshots/access-class-members-final.png`, `.build/screenshots/access-member-invite-final.png`, `.build/screenshots/bugfix-parent-collections.png`, `.build/screenshots/bugfix-parent-collection-detail.png`, `.build/screenshots/bugfix-parent-announcement-blocked.png`, `.build/screenshots/child-mode-today.png`
  - Комментарий: в UI добавлены локальные запреты для родителя на создание объявлений, сборов, приглашений, изменение статусов, общего счетчика и чеков; роль родителя может отличаться по классам выбранных детей, детская роль не видит вкладки `Класс` и `Еще`; backend-проверка прав все еще обязательна до релиза

- [~] Проверка пустых состояний
  - Проверка: нет класса, нет ребенка, нет ДЗ, нет событий, нет подписки, нет прав
  - Уровень: 3
  - Артефакт: `.build/screenshots/more-qa-states.png`, `.build/screenshots/homework-main-final.png`, `.build/screenshots/homework-empty-state.png`, `.build/screenshots/qa-smoke/homework-empty.png`
  - Комментарий: добавлен централизованный QA-экран и отдельный smoke-сценарий пустого списка ДЗ; пустые состояния уже реализованы в ДЗ, Today, фотоальбомах, памяти и файлах; надо еще пройти реальные пустые stores по всем вкладкам

- [~] Проверка ошибок сети
  - Проверка: данные не теряются, пользователь понимает, что произошло
  - Уровень: 4
  - Артефакт: `.build/screenshots/more-qa-states.png`, `.build/screenshots/more-sync-offline-state.png`, `.build/screenshots/qa-smoke/more-sync-offline.png`, `.build/screenshots/qa-smoke/more-sync-network-error.png`, `SchoolAppUITests/SchoolAppUITests.swift`
  - Комментарий: offline/error-состояние зафиксировано в QA-сценариях, smoke-сценариях и UI-тесте `testSyncNetworkErrorKeepsQueuedMutation`: операция получает `Retry 1/5`, остается в очереди, пользователь видит, что данные сохранены локально; настоящий URLSession/live backend остается следующим слоем

- [~] Проверка на iPhone Simulator
  - Проверка: основные экраны открываются, верстка не ломается, сценарии проходят
  - Уровень: 3
  - Артефакт: `xcodebuild ... iPhone 17 Pro`, `.build/screenshots/final-verified-*.png`, `.build/screenshots/regression-*-after-calendar.png`, `.build/screenshots/regression-*-after-collections.png`, `.build/screenshots/regression-*-after-schedule.png`, `.build/screenshots/regression-*-after-chats.png`, `.build/screenshots/regression-*-after-access.png`, `.build/screenshots/regression-*-after-settings.png`, `.build/screenshots/regression-*-after-bugfixes.png`
  - Комментарий: сборка проходит; пять вкладок запускались в booted Simulator через QA-параметр `-qa-tab`, для вкладки `Класс` используется внутреннее имя `classRoom`

- [~] Проверка на реальном iPhone
  - Проверка: камера, уведомления, авторизация, подписка и производительность работают на устройстве
  - Уровень: 2
  - Артефакт: `.build/screenshots/qa-smoke/more-real-device.png`
  - Комментарий: в приложении добавлен ручной gate-чеклист для реального iPhone: подпись и запуск, камера/фото, файлы/Share Sheet, уведомления, роли/приватность и производительность; фактический прогон на физическом устройстве еще не выполнен

- [~] Автоматические тесты критичных сценариев
  - Проверка: покрыты модели, права, парсинг AI-результата, создание ДЗ/событий/сборов
  - Уровень: 4
  - Артефакт: `scripts/qa_smoke.sh`, `scripts/qa_ui_tests.sh`, `SchoolAppUITests/SchoolAppUITests.swift`, `.build/screenshots/qa-smoke/summary.txt`, `.build/SchoolAppUITests/summary.txt`
  - Комментарий: добавлен запускаемый smoke-скрипт: сборка, установка в Simulator, перезапуск приложения между сценариями и снимки ключевых экранов; каждый снимок проверяется на наличие, PNG-размеры и минимальный вес файла, а прогон пишет summary. Добавлен XCTest/UI target: тесты кликают/запускают приложение с QA-аргументами и проверяют детский режим, запрет родителю создавать сбор, запрет родителю менять общий счетчик/статус сбора и добавлять чеки, запрет родителю публиковать объявление, запрет родителю приглашать участников класса, запрет родителю удалять фото класса, Behavior QA gate, MVP-метрики с сохранением события после перезапуска, сохранение подтверждения "Я прочитал", сохранение расхода сбора, сохранение вручную созданного ДЗ, сохранение созданного события календаря после перезапуска приложения и переключение выбранного ребенка между классами/ролями. `scripts/qa_ui_tests.sh` запускает 13 сценариев отдельными короткими XCTest-сессиями и пишет общий summary; последний прогон прошел: 13 тестов, 0 failures. Полный smoke прошел: 48 сценариев, включая `more-metrics`; перед релизом нужно расширить XCTest на серверные права.

## 21. Релиз

- [~] Название приложения
  - Проверка: выбрано, свободно, понятно родителям
  - Уровень: 1
  - Артефакт: `docs/release_materials.md`, `SchoolApp.xcodeproj/project.pbxproj`
  - Комментарий: рабочее название `Школьный класс` выбрано и прописано как display name; доступность в App Store Connect и товарные знаки еще нужно проверить перед релизом

- [~] Иконка
  - Проверка: выглядит аккуратно, не слишком детская, читается в маленьком размере
  - Уровень: 2
  - Артефакт: `SchoolApp/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png`
  - Комментарий: добавлена MVP-иконка в asset catalog и подключена как AppIcon; `xcodebuild` успешно компилирует ассеты, перед релизом нужен просмотр на реальном iPhone и дизайнерский полиш

- [~] App Store материалы
  - Проверка: скриншоты, описание, ключевые преимущества, политика приватности
  - Уровень: 1
  - Артефакт: `docs/release_materials.md`
  - Комментарий: подготовлены черновики названия, короткого и полного описания, преимуществ, ключевых слов и списка скриншотов; политика приватности и финальные App Store Connect материалы еще не готовы

- [~] Юридические документы
  - Проверка: пользовательское соглашение, политика обработки персональных данных, согласие на данные ребенка
  - Уровень: 1
  - Артефакт: `docs/legal/privacy_policy_draft.md`, `docs/legal/terms_draft.md`
  - Комментарий: подготовлены рабочие черновики политики приватности и пользовательского соглашения с разделами про детей, файлы, чеки, AI, роли, сборы и удаление данных; перед публикацией нужен юридический обзор и фактические данные владельца/провайдеров

- [~] Поддержка
  - Проверка: есть способ написать в поддержку и сообщить о проблеме
  - Уровень: 3
  - Артефакт: `.build/screenshots/more-support-screen.png`, `.build/screenshots/more-problem-screen.png`, `.build/screenshots/more-support-history.png`, `.build/screenshots/more-problem-history.png`, `.build/screenshots/qa-smoke/more-support.png`, `.build/screenshots/qa-smoke/more-problem.png`, `.build/screenshots/more-logout-screen.png`
  - Комментарий: добавлены локальные формы поддержки, отчета о проблеме, история последних обращений, системная отправка текста через iOS Share Sheet и экран выхода/подготовки переноса; backend helpdesk еще не подключен

- [~] Beta / TestFlight
  - Проверка: собрана тестовая версия, есть список тестеров и сценарии проверки
  - Уровень: 3
  - Артефакт: `SchoolApp/Features/More/MoreView.swift`, `docs/release_materials.md`, `.build/screenshots/qa-smoke/more-beta.png`
  - Комментарий: добавлен локальный экран beta/TestFlight readiness: release gate, блокеры, группы тестеров и сценарии приемки; smoke-сценарий проверяет экран в Simulator. Настоящая Archive/TestFlight-загрузка еще не выполнена, нужна проверка на реальном iPhone и App Store Connect setup

- [ ] Первый публичный релиз
  - Проверка: критичные сценарии пройдены, юридические документы готовы, аналитика работает
  - Уровень: 0
  - Артефакт:
  - Комментарий:

## 22. Будущие функции, не тащить в первый MVP без решения

- [~] Прием платежей внутри приложения
  - Проверка: есть юридическая и платежная схема
  - Уровень: 1
  - Артефакт: `docs/storekit_mvp_plan.md`
  - Комментарий: схема подписки приложения описана через StoreKit-продукты; сборы класса остаются учетными записями и чеками, без перевода денег внутри MVP

- [ ] Поиск ребенка по фото
  - Проверка: решены приватность, согласия и точность распознавания
  - Уровень: 0
  - Артефакт:
  - Комментарий:

- [ ] Фотокниги и печать
  - Проверка: есть партнер или производственный процесс
  - Уровень: 0
  - Артефакт:
  - Комментарий:

- [ ] Интеграции с электронными дневниками
  - Проверка: понятны API, легальность и поддержка регионов
  - Уровень: 0
  - Артефакт:
  - Комментарий:

- [ ] Android
  - Проверка: принято решение о сроках после iOS MVP
  - Уровень: 0
  - Артефакт:
  - Комментарий: Android есть в общей концепции, но первый продукт ориентирован на iPhone

- [ ] Сложная модерация
  - Проверка: есть реальные кейсы и понятные правила
  - Уровень: 0
  - Артефакт:
  - Комментарий:

## 23. Журнал решений

| Дата | Решение | Почему | Кто подтвердил |
| --- | --- | --- | --- |
| 2026-07-02 | Создан общий чеклист контроля проекта | Чтобы отслеживать готовность, проверку и риски по ТЗ | Codex |
| 2026-07-03 | Первый клиентский каркас делаем на SwiftUI, iOS 17+ | Это соответствует ТЗ и позволяет быстро собирать MVP под iPhone | Codex |
| 2026-07-03 | Основным визуальным направлением выбран первый дизайн "Сегодня" | Он лучше всего соответствует принципу взрослого семейного помощника | Пользователь |

## 24. Журнал проверок

| Дата | Что проверяли | Результат | Уровень | Артефакт | Комментарий |
| --- | --- | --- | --- | --- | --- |
| 2026-07-02 | ТЗ прочитано и разложено в чеклист | Пройдено | 1 | `school_class_app_checklist.md` | Требуется дальше зафиксировать границу MVP |
| 2026-07-03 | Xcode и iOS Simulator runtime | Пройдено | 3 | Xcode 26.5, iOS 26.5 Simulator | Первый runtime скачался с duplicate-ошибкой, после очистки повторная установка прошла успешно |
| 2026-07-03 | Первый SwiftUI-каркас приложения | Пройдено | 3 | `SchoolApp.xcodeproj` | Сборка `SchoolApp` проходит на iPhone 17 Simulator |
| 2026-07-03 | Перенос первого дизайна в SwiftUI | Пройдено | 3 | `SchoolApp/Features/Today/TodayView.swift`, `docs/design/today-dashboard-reference.png` | `xcodebuild` проходит; симулятор не был запущен для визуального прогона |
| 2026-07-03 | Визуальный QA пяти вкладок в Simulator | Пройдено | 3 | `.build/screenshots/final-verified-today.png`, `.build/screenshots/final-verified-class.png` | Исправлены прозрачный Tab Bar iOS 26, нижние отступы, перенос бейджа `На неделю` и обрезание `Участники` |
| 2026-07-03 | Первый запуск и вход в класс | Пройдено | 3 | `.build/screenshots/onboarding-create-final.png`, `.build/screenshots/onboarding-join-final.png`, `.build/screenshots/onboarding-ready-final.png`, `.build/screenshots/post-onboarding-today-final.png` | Проверены создание комнаты, вход по коду, готовое состояние с кодом приглашения и запуск главного экрана после онбординга |
| 2026-07-03 | Интерактивный раздел ДЗ | Пройдено | 3 | `.build/screenshots/homework-main-final.png`, `.build/screenshots/homework-add-final.png`, `.build/screenshots/homework-ai-parse-final.png` | Проверены список ДЗ, ручное добавление, локальный AI-разбор фото/текста и сборка `xcodebuild` |
| 2026-07-03 | Регрессия основных вкладок после ДЗ | Пройдено | 3 | `.build/screenshots/regression-today-after-homework.png`, `.build/screenshots/regression-class-after-homework.png`, `.build/screenshots/regression-calendar-after-homework.png`, `.build/screenshots/regression-more-after-homework.png` | После изменения модели ДЗ проверены запуск и первичная верстка вкладок `Сегодня`, `Класс`, `Календарь`, `Еще` |
| 2026-07-03 | Интерактивный календарь и события | Пройдено | 3 | `.build/screenshots/calendar-main-interactive-final.png`, `.build/screenshots/calendar-add-event-final.png`, `.build/screenshots/calendar-event-detail-final.png` | Проверены список событий, создание события, типы событий и ответ семьи |
| 2026-07-03 | Регрессия основных вкладок после календаря | Пройдено | 3 | `.build/screenshots/regression-today-after-calendar.png`, `.build/screenshots/regression-class-after-calendar.png`, `.build/screenshots/regression-homework-after-calendar.png`, `.build/screenshots/regression-calendar-after-calendar.png`, `.build/screenshots/regression-more-after-calendar.png` | После изменения модели событий проверены запуск и первичная верстка вкладок `Сегодня`, `Класс`, `ДЗ`, `Календарь`, `Еще`; ошибочный первый параметр `class` заменен на `classRoom` |
| 2026-07-03 | Интерактивные сборы родкомитета | Пройдено | 3 | `.build/screenshots/collections-main-final.png`, `.build/screenshots/collections-add-final.png`, `.build/screenshots/collections-detail-final.png` | Проверены список сборов, создание сбора, статусы оплат, расходы и отчет без реального приема денег |
| 2026-07-03 | Регрессия основных вкладок после сборов | Пройдено | 3 | `.build/screenshots/regression-today-after-collections.png`, `.build/screenshots/regression-class-after-collections.png`, `.build/screenshots/regression-homework-after-collections.png`, `.build/screenshots/regression-calendar-after-collections.png`, `.build/screenshots/regression-more-after-collections.png` | После изменения модели сборов проверены запуск и первичная верстка вкладок `Сегодня`, `Класс`, `ДЗ`, `Календарь`, `Еще` |
| 2026-07-03 | Связь события календаря со сбором | Пройдено | 3 | `.build/screenshots/calendar-linked-main-final.png`, `.build/screenshots/calendar-linked-detail-final.png`, `.build/screenshots/calendar-linked-add-final.png` | Проверены бейдж связанного сбора в списке, блок сбора в деталях события и поля связки при создании события |
| 2026-07-03 | Регрессия основных вкладок после связки события со сбором | Пройдено | 3 | `.build/screenshots/regression-today-after-linked-collections.png`, `.build/screenshots/regression-class-after-linked-collections.png`, `.build/screenshots/regression-homework-after-linked-collections.png`, `.build/screenshots/regression-calendar-after-linked-collections.png`, `.build/screenshots/regression-more-after-linked-collections.png` | После изменения модели события проверены запуск и первичная верстка вкладок `Сегодня`, `Класс`, `ДЗ`, `Календарь`, `Еще` |
| 2026-07-03 | Интерактивное расписание и план дня | Пройдено | 3 | `.build/screenshots/schedule-today-final.png`, `.build/screenshots/schedule-planner-final.png`, `.build/screenshots/schedule-add-final.png`, `.build/screenshots/schedule-import-final.png` | Проверены план дня, недельное расписание, форма урока/замены, личные кружки и локальный импорт расписания из распознанного текста |
| 2026-07-03 | Регрессия основных вкладок после расписания | Пройдено | 3 | `.build/screenshots/regression-today-after-schedule.png`, `.build/screenshots/regression-class-after-schedule.png`, `.build/screenshots/regression-homework-after-schedule.png`, `.build/screenshots/regression-calendar-after-schedule.png`, `.build/screenshots/regression-more-after-schedule.png` | После изменения модели расписания проверены запуск и первичная верстка вкладок `Сегодня`, `Класс`, `ДЗ`, `Календарь`, `Еще` |
| 2026-07-03 | Интерактивные чаты, объявления и тихий дайджест | Пройдено | 3 | `.build/screenshots/chats-main-final.png`, `.build/screenshots/chat-detail-final.png`, `.build/screenshots/chat-digest-final.png`, `.build/screenshots/announcement-add-final.png`, `.build/screenshots/announcement-detail-final.png` | Проверены список чатов, детальный чат, действия из важных сообщений, тихий дайджест, создание объявления и подтверждение прочтения |
| 2026-07-03 | Регрессия основных вкладок после чатов | Пройдено | 3 | `.build/screenshots/regression-today-after-chats.png`, `.build/screenshots/regression-class-after-chats.png`, `.build/screenshots/regression-homework-after-chats.png`, `.build/screenshots/regression-calendar-after-chats.png`, `.build/screenshots/regression-more-after-chats.png` | После изменения модели чатов и ленты проверены запуск и первичная верстка вкладок `Сегодня`, `Класс`, `ДЗ`, `Календарь`, `Еще` |
| 2026-07-03 | Семейный доступ, роли и приглашения | Пройдено | 3 | `.build/screenshots/access-more-main-final.png`, `.build/screenshots/access-children-final.png`, `.build/screenshots/access-family-final.png`, `.build/screenshots/access-classes-final.png`, `.build/screenshots/access-class-members-final.png`, `.build/screenshots/access-member-invite-final.png` | Проверены профили детей, семейный доступ, коды классов, роли участников и локальное приглашение в класс |
| 2026-07-03 | Регрессия основных вкладок после доступа | Пройдено | 3 | `.build/screenshots/regression-today-after-access.png`, `.build/screenshots/regression-class-after-access.png`, `.build/screenshots/regression-homework-after-access.png`, `.build/screenshots/regression-calendar-after-access.png`, `.build/screenshots/regression-more-after-access.png` | После изменения моделей семьи и участников проверены запуск и первичная верстка вкладок `Сегодня`, `Класс`, `ДЗ`, `Календарь`, `Еще` |
| 2026-07-03 | Подписка и настройки уведомлений | Пройдено | 3 | `.build/screenshots/subscription-settings-final.png`, `.build/screenshots/notification-settings-final.png` | Проверены локальный экран trial/тарифов, восстановление покупок как UI-сценарий, дайджесты, дедлайны, срочное и тихие часы |
| 2026-07-03 | Регрессия основных вкладок после подписки и уведомлений | Пройдено | 3 | `.build/screenshots/regression-today-after-settings.png`, `.build/screenshots/regression-class-after-settings.png`, `.build/screenshots/regression-homework-after-settings.png`, `.build/screenshots/regression-calendar-after-settings.png`, `.build/screenshots/regression-more-after-settings.png` | После изменения раздела `Еще` и моделей настроек проверены запуск и первичная верстка вкладок `Сегодня`, `Класс`, `ДЗ`, `Календарь`, `Еще` |
| 2026-07-03 | Багфикс онбординга, ролей, сборов и объявлений | Пройдено | 3 | `.build/screenshots/bugfix-onboarding-reset.png`, `.build/screenshots/bugfix-parent-collections.png`, `.build/screenshots/bugfix-parent-collection-detail.png`, `.build/screenshots/bugfix-parent-announcement-blocked.png`, `.build/screenshots/bugfix-committee-collection-detail.png` | Исправлены повторный показ онбординга при новой версии, роль родителя по умолчанию, сохранение прочтения объявления, запрет родителю менять сборы/статусы/чеки и локальные вложения чеков/файлов |
| 2026-07-03 | Регрессия основных вкладок после багфиксов | Пройдено | 3 | `.build/screenshots/regression-today-after-bugfixes.png`, `.build/screenshots/regression-class-after-bugfixes.png`, `.build/screenshots/regression-homework-after-bugfixes.png`, `.build/screenshots/regression-calendar-after-bugfixes.png`, `.build/screenshots/regression-more-after-bugfixes.png` | После правок AppView, Onboarding, ролей и ClassRoom проверены запуск и первичная верстка вкладок `Сегодня`, `Класс`, `ДЗ`, `Календарь`, `Еще` |
| 2026-07-03 | Локальное постоянное хранение раздела Класс | Пройдено | 3 | `.build/screenshots/persistence-collections-reset.png`, `.build/screenshots/persistence-collection-detail.png` | Добавлен JSON-снимок в `UserDefaults` для объявлений, сборов, чатов, дайджестов и участников; сборка `xcodebuild` проходит |
| 2026-07-03 | Фото и файлы чеков в расходах сбора | Пройдено | 3 | `.build/screenshots/receipt-attachments-form-final.png`, `.build/screenshots/receipt-photo-dialog.png`, `.build/screenshots/receipt-file-importer.png` | Проверены форма расхода, системное меню фото/галереи и системный выбор файла; на Simulator камера недоступна, на iPhone появится вариант съемки |
| 2026-07-03 | Локальное хранение ДЗ и календаря | Пройдено | 3 | `.build/screenshots/homework-persistence-main.png`, `.build/screenshots/homework-persistence-add.png`, `.build/screenshots/homework-persistence-parse.png`, `.build/screenshots/calendar-persistence-main.png`, `.build/screenshots/calendar-persistence-add.png`, `.build/screenshots/calendar-persistence-detail.png` | Добавлено сохранение ДЗ, AI-результатов, отметок выполнения, событий и ответов семьи в `UserDefaults`; сборка `xcodebuild` проходит |
| 2026-07-03 | Регрессия основных вкладок после хранения ДЗ и календаря | Пройдено | 3 | `.build/screenshots/regression-today-after-homework-calendar-persistence.png`, `.build/screenshots/regression-class-after-homework-calendar-persistence.png`, `.build/screenshots/regression-homework-after-homework-calendar-persistence.png`, `.build/screenshots/regression-calendar-after-homework-calendar-persistence.png`, `.build/screenshots/regression-more-after-homework-calendar-persistence.png` | После изменения `HomeworkView`, `CalendarView` и моделей проверены запуск и первичная верстка вкладок `Сегодня`, `Класс`, `ДЗ`, `Календарь`, `Еще` |
| 2026-07-03 | Системные фото и файлы для разбора ДЗ | Пройдено | 3 | `.build/screenshots/homework-attachments-parse.png`, `.build/screenshots/homework-photo-dialog.png`, `.build/screenshots/homework-file-importer.png` | Добавлены image picker и document picker для исходников ДЗ; на Simulator камера недоступна, на iPhone будет вариант съемки |
| 2026-07-03 | Локальное хранение раздела Еще | Пройдено | 3 | `.build/screenshots/more-persistence-main.png`, `.build/screenshots/more-persistence-children.png`, `.build/screenshots/more-persistence-family.png`, `.build/screenshots/more-persistence-classes.png`, `.build/screenshots/more-persistence-subscription.png`, `.build/screenshots/more-persistence-notifications-final.png` | Добавлено сохранение детей, семейного доступа, классов, выбранного тарифа, переключателей уведомлений, времени дайджестов и тихих часов в `UserDefaults`; сборка `xcodebuild` проходит |
| 2026-07-03 | Память класса и файлы | Пройдено | 3 | `.build/screenshots/more-main-after-memory-files.png`, `.build/screenshots/more-memory-screen.png`, `.build/screenshots/more-files-screen.png`, `.build/screenshots/more-files-importer.png` | Добавлены локальные экраны памяти класса и файлов с поиском, категориями, добавлением записей и системным document picker; на Simulator Files может показывать недоступный контент, но системный выбор открывается |
| 2026-07-03 | Регрессия основных вкладок после памяти и файлов | Пройдено | 3 | `.build/screenshots/regression-today-after-memory-files.png`, `.build/screenshots/regression-class-after-memory-files.png`, `.build/screenshots/regression-homework-after-memory-files.png`, `.build/screenshots/regression-calendar-after-memory-files.png`, `.build/screenshots/regression-more-after-memory-files.png` | После изменения `MoreView` и моделей проверены запуск и первичная верстка вкладок `Сегодня`, `Класс`, `ДЗ`, `Календарь`, `Еще`; для `Класс` использован корректный QA-таб `classRoom` |
| 2026-07-03 | Закрытие клавиатуры в формах | Пройдено | 3 | `.build/screenshots/keyboard-homework-add.png`, `.build/screenshots/keyboard-calendar-add.png`, `.build/screenshots/keyboard-announcement-add.png`, `.build/screenshots/keyboard-more-children.png` | Добавлена общая кнопка `Готово` над клавиатурой и интерактивное скрытие при прокрутке для форм ДЗ, календаря, объявления и раздела `Еще`; сборка `xcodebuild` проходит |
| 2026-07-03 | Безопасность, поддержка и выход | Пройдено | 3 | `.build/screenshots/more-security-screen.png`, `.build/screenshots/more-support-screen.png`, `.build/screenshots/more-problem-screen.png`, `.build/screenshots/more-logout-screen.png` | Добавлены рабочие листы для безопасности, поддержки, отчета о проблеме и выхода; настройки безопасности сохраняются локально; сборка `xcodebuild` проходит |
| 2026-07-03 | Живое состояние главного экрана Сегодня | Пройдено | 3 | `.build/screenshots/today-state-main.png`, `.build/screenshots/today-add-homework.png`, `.build/screenshots/today-add-task-payment.png`, `.build/screenshots/today-important-chat.png` | Добавлено локальное хранение Today-состояния, отметки ДЗ и семейных задач, быстрые листы ДЗ/задач и отдельное важное из чата; сборка `xcodebuild` проходит |
| 2026-07-03 | Комментарии под объявлениями | Пройдено | 3 | `.build/screenshots/announcement-comments-detail.png`, `.build/screenshots/announcement-comments-create.png` | Добавлены комментарии к объявлениям, поле быстрого ответа и переключатель обсуждения для автора; сборка `xcodebuild` проходит |
| 2026-07-03 | Вложения в ручном ДЗ | Пройдено | 3 | `.build/screenshots/homework-add-attachments.png`, `.build/screenshots/homework-add-photo-dialog.png`, `.build/screenshots/homework-add-file-importer.png` | Добавлен блок фото/файла в ручное добавление ДЗ; системные picker-ы открываются, выбранный исходник сохраняется как локальная пометка; сборка `xcodebuild` проходит |
| 2026-07-03 | Профиль родителя | Пройдено | 3 | `.build/screenshots/more-parent-profile.png` | Карточка профиля в `Еще` открывает локальный профиль с контактом, Apple ID/email, ролями в классах и семейными участниками; сборка `xcodebuild` проходит |
| 2026-07-03 | Семейные задачи | Пройдено | 3 | `.build/screenshots/more-family-tasks.png` | Добавлен локальный экран семейных задач с назначением, персональным напоминанием, передачей и завершением; сборка `xcodebuild` проходит |
| 2026-07-03 | Глобальный помощник Разобрать | Пройдено | 3 | `.build/screenshots/today-global-parse.png`, `.build/screenshots/today-global-parse-photo-dialog.png`, `.build/screenshots/today-global-parse-file-importer.png` | Добавлен локальный разбор фото/скрина/файла/голоса/текста в ДЗ, события, оплаты и семейные задачи с обязательным подтверждением; сборка `xcodebuild` проходит |
| 2026-07-03 | Продуктовая рамка MVP | Пройдено | 2 | `docs/mvp_scope.md` | Зафиксированы главный оффер, граница MVP / позже / не делать, главный сценарий без учителя и North Star Metric |
| 2026-07-03 | Фотоальбомы класса | Пройдено | 3 | `.build/screenshots/class-photos-main.png`, `.build/screenshots/class-photo-album.png`, `.build/screenshots/class-photo-dialog.png`, `.build/screenshots/class-photo-file-importer.png` | Добавлены локальные альбомы класса, закрытый доступ, добавление фото/файла и действия скачать/поделиться/жалоба/удалить; сборка `xcodebuild` проходит |
| 2026-07-03 | Журнал действий и аудит | Пройдено | 3 | `.build/screenshots/more-audit-log.png` | Добавлен локальный AuditLog в разделе `Еще`: фиксируются изменения профиля, детей, семьи, классов, подписки, уведомлений, файлов, безопасности и семейных задач; сборка `xcodebuild` проходит |
| 2026-07-03 | Приватность и согласие | Пройдено | 3 | `.build/screenshots/more-privacy-screen.png` | Добавлен локальный центр приватности: минимизация данных ребенка, согласие родителя, принятие политики и краткое объяснение категорий данных; сборка `xcodebuild` проходит |
| 2026-07-03 | MVP-метрики и события | Пройдено | 3 | `.build/screenshots/more-mvp-metrics.png` | Добавлен локальный экран продуктовых метрик и событий: аккаунт, класс, ДЗ/AI, календарь/сборы, подписка и QA smoke; сборка `xcodebuild` проходит |
| 2026-07-03 | QA-состояния MVP | Пройдено | 3 | `.build/screenshots/more-qa-states.png` | Добавлен локальный экран приемки состояний: без учителя, пустой класс, пустая семья, нет ДЗ, нет прав, нет подписки, offline и отмена действия; сборка `xcodebuild` проходит |
| 2026-07-03 | Удаление аккаунта и данных | Пройдено | 3 | `.build/screenshots/more-account-deletion.png` | Экран безопасности дополнен экспортом перед удалением, выбором объема удаления, подтверждением словом `УДАЛИТЬ` и локальным статусом заявки; сборка `xcodebuild` проходит |
| 2026-07-03 | Backend-контракты MVP | Пройдено | 1 | `docs/backend_contracts.md` | Описаны основные сущности, серверная матрица ролей, формат мутаций, offline-синхронизация, конфликты и окружения dev/staging/production; реализация backend и OpenAPI остаются следующими этапами |
| 2026-07-03 | Smoke-проверки критичных сценариев | Пройдено | 2 | `scripts/qa_smoke.sh`, `.build/screenshots/qa-smoke/` | Добавлен и прогнан скрипт сборки/установки/запуска ключевых QA-сценариев в Simulator; исправлены перезапуск приложения между кейсами и аргумент вкладки `classRoom`; сборка `xcodebuild` проходит |
| 2026-07-03 | Релизные материалы MVP | Пройдено | 2 | `SchoolApp/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png`, `docs/release_materials.md` | Добавлены рабочая AppIcon, display name `Школьный класс`, черновики описания, преимуществ, ключевых слов и списка скриншотов; `xcodebuild` успешно компилирует asset catalog |
| 2026-07-03 | Юридические черновики | Пройдено | 1 | `docs/legal/privacy_policy_draft.md`, `docs/legal/terms_draft.md` | Подготовлены черновики политики приватности и пользовательского соглашения с учетом детей, файлов, чеков, AI, ролей, сборов и удаления данных; требуется юридическая проверка перед публикацией |
| 2026-07-03 | Логи и качество AI | Пройдено | 3 | `.build/screenshots/more-ai-quality.png`, `scripts/qa_smoke.sh` | Добавлен локальный экран контроля AI-разборов: источник, уверенность, статус, версия промпта, попытки и действия принять/повторить/улучшить промпт; сценарий добавлен в smoke-проверку |
| 2026-07-03 | Локальный вход в аккаунт | Пройдено | 3 | `.build/screenshots/onboarding-auth-phone-verified.png`, `.build/screenshots/onboarding-auth-apple.png`, `scripts/qa_smoke.sh` | В онбординг добавлены локальные сценарии входа по телефону с кодом `1234` и Apple ID/email, сохранение способа входа и QA-флаги; оба сценария добавлены в smoke-проверку |
| 2026-07-03 | StoreKit и платежная схема MVP | Пройдено | 2 | `.build/screenshots/subscription-storekit-local.png`, `.build/screenshots/qa-smoke/more-subscription.png`, `docs/storekit_mvp_plan.md`, `scripts/qa_smoke.sh` | На экране подписки добавлены product id, локальные сценарии покупки, восстановления, истечения и ошибки оплаты; сценарий добавлен в smoke-проверку, настоящий StoreKit 2 и App Store Connect остаются следующим этапом |
| 2026-07-03 | Центр синхронизации MVP | Пройдено | 2 | `.build/screenshots/more-sync-center.png`, `.build/screenshots/qa-smoke/more-sync.png`, `SchoolApp/Features/More/MoreView.swift`, `scripts/qa_smoke.sh` | Добавлен локальный экран очереди синхронизации: API-контракты, offline, storage, retry и конфликтные операции; сценарий добавлен в smoke-проверку, настоящий backend/API-клиент еще не подключены |
| 2026-07-03 | Локальные iOS-уведомления | Пройдено | 3 | `.build/screenshots/notifications-ios-local.png`, `.build/screenshots/qa-smoke/more-notifications.png`, `SchoolApp/Features/More/MoreView.swift`, `scripts/qa_smoke.sh` | Экран уведомлений дополнен `UserNotifications`: системный запрос разрешения, статус iOS, тестовое уведомление через 5 секунд и локальное расписание вечернего/утреннего дайджеста и дедлайна оплаты; APNs/backend-доставка остаются следующим этапом |
| 2026-07-03 | Приглашения по ссылке и QR | Пройдено | 3 | `.build/screenshots/invite-link-qr-class.png`, `.build/screenshots/invite-link-qr-family.png`, `.build/screenshots/qa-smoke/class-member-invite.png`, `.build/screenshots/qa-smoke/more-family.png`, `scripts/qa_smoke.sh` | В приглашения класса и семьи добавлены deep link-ссылки, QR-коды, системный ShareLink и обновление локального кода; сценарии добавлены в smoke-проверку, backend invite-token и отзыв ссылок остаются следующим этапом |
| 2026-07-03 | Управление участниками класса | Пройдено | 3 | `.build/screenshots/member-management-actions.png`, `.build/screenshots/qa-smoke/class-member-management.png`, `SchoolApp/Features/ClassRoom/ClassRoomView.swift`, `scripts/qa_smoke.sh` | Добавлено локальное меню участника: смена роли, отключение/возврат доступа, удаление и передача админа с защитой последнего администратора; сценарий добавлен в smoke-проверку, backend-аудит и серверные права остаются следующим этапом |
| 2026-07-03 | Детский режим MVP | Пройдено | 3 | `.build/screenshots/child-mode-today.png`, `.build/screenshots/qa-smoke/child-mode.png`, `SchoolApp/App/AppView.swift`, `SchoolApp/App/AppTab.swift`, `SchoolApp/Features/Onboarding/OnboardingView.swift`, `SchoolApp/Features/Today/TodayView.swift`, `scripts/qa_smoke.sh` | Добавлена роль "Ребенок": видит только `Сегодня`, `ДЗ`, `Календарь`; онбординг использует детскую форму имени; на главном экране показаны ДЗ, расписание, прогресс и рюкзак, а сборы/класс/родительские чаты и создание новых сущностей скрыты; серверные ограничения остаются следующим этапом |
| 2026-07-03 | Фильтры списка ДЗ | Пройдено | 3 | `.build/screenshots/homework-filters.png`, `.build/screenshots/qa-smoke/homework-filters.png`, `SchoolApp/Features/Homework/HomeworkView.swift`, `SchoolApp/Models/SampleData.swift`, `scripts/qa_smoke.sh` | В список ДЗ добавлены фильтры по ребенку, предмету, статусу и источнику, счетчик результатов и сброс фильтров; модель ДЗ получила совместимое поле ребенка; сценарий добавлен в smoke-проверку |
| 2026-07-03 | Участники и документы событий | Пройдено | 3 | `.build/screenshots/calendar-participants-documents.png`, `.build/screenshots/qa-smoke/calendar-detail.png`, `SchoolApp/Features/Calendar/CalendarView.swift`, `SchoolApp/Models/SampleData.swift`, `scripts/qa_smoke.sh` | События календаря получили локальные участников и документы: форма создания сохраняет список участников и файл, карточка/детали показывают участников, документы и связанный сбор; сценарий деталей события добавлен в smoke-проверку |
| 2026-07-03 | Согласие и локальное удаление данных | Пройдено | 3 | `.build/screenshots/privacy-consent-settings.png`, `.build/screenshots/security-local-delete-export.png`, `.build/screenshots/qa-smoke/more-privacy.png`, `SchoolApp/Features/Onboarding/OnboardingView.swift`, `SchoolApp/Features/More/MoreView.swift`, `SchoolApp/Models/SampleData.swift`, `scripts/qa_smoke.sh` | Онбординг требует локальное согласие на обработку данных ребенка и принятие политики, настройки приватности показывают сохраненный статус, а безопасность получила экспорт-сводку и очистку выбранных локальных данных; сценарий приватности добавлен в smoke-проверку |
| 2026-07-03 | Навигация главной и мультидети | Пройдено | 3 | `.build/screenshots/onboarding-account-first.png`, `.build/screenshots/today-child-profile-switch.png`, `.build/screenshots/today-add-child-class-code.png`, `.build/screenshots/today-homework-sheet.png`, `.build/screenshots/today-chats-sheet.png`, `.build/screenshots/qa-smoke/today-notifications.png`, `.build/screenshots/qa-smoke/today-urgent.png`, `SchoolApp/Features/Today/TodayView.swift`, `SchoolApp/Features/ClassRoom/ClassRoomView.swift`, `SchoolApp/Features/Homework/HomeworkView.swift`, `SchoolApp/Models/SampleData.swift`, `scripts/qa_smoke.sh` | Первый вход перестроен по шагам аккаунт -> статус -> класс, выбранный ребенок сохраняется между вкладками и задает контекст класса/роли, добавление ребенка требует код класса, колокольчик/профиль/срочное/домашка/чаты на главной открывают листы; smoke расширен и пройден |
| 2026-07-03 | Просмотр фотоальбомов и права удаления | Пройдено | 3 | `.build/screenshots/class-photo-viewer.png`, `.build/screenshots/qa-smoke/class-photo-viewer.png`, `SchoolApp/Features/ClassRoom/ClassRoomView.swift`, `scripts/qa_smoke.sh` | Альбомы получили крупный просмотр с перелистыванием, быстрые действия скачать/поделиться/пожаловаться и удаление только для учителя или родкомитета; `xcodebuild` и полный smoke-прогон проходят |
| 2026-07-03 | API dry-run центра синхронизации | Пройдено | 3 | `.build/screenshots/more-sync-api-dry-run.png`, `.build/screenshots/qa-smoke/more-sync.png`, `SchoolApp/Features/More/MoreView.swift`, `scripts/qa_smoke.sh` | Центр синхронизации получил dev/staging/prod, типизированный каталог endpoint-ов, request id dry-run и подсчет готовых/ожидающих/заблокированных операций; реальный backend и OpenAPI-клиент остаются следующим слоем |
| 2026-07-03 | Backend policy-аудит ролей | Пройдено | 2 | `.build/screenshots/more-sync-permissions.png`, `.build/screenshots/qa-smoke/more-sync.png`, `SchoolApp/Features/More/MoreView.swift` | В центр синхронизации добавлена матрица серверных прав: объявления, сборы, оплата своей семьи, удаление фото и приглашения проверяются по ролям родитель/родкомитет/учитель/ребенок; настоящий backend enforcement остается следующим слоем |
| 2026-07-03 | StoreKit 2 каталог подписки | Пройдено | 3 | `.build/screenshots/subscription-storekit-products.png`, `.build/screenshots/qa-smoke/more-subscription.png`, `SchoolApp/Features/More/MoreView.swift`, `docs/storekit_mvp_plan.md` | Экран подписки подключен к `Product.products(for:)`, проверяет два product id, показывает найдено/не найдено/ошибка и fallback-цены; реальные покупки, App Store Connect и entitlement-проверка остаются следующим слоем |
| 2026-07-03 | Ограничения AI без подписки | Пройдено | 3 | `.build/screenshots/today-paywall.png`, `.build/screenshots/homework-paywall.png`, `.build/screenshots/qa-smoke/today-paywall.png`, `.build/screenshots/qa-smoke/homework-paywall.png`, `SchoolApp/Models/SampleData.swift`, `SchoolApp/Features/Today/TodayView.swift`, `SchoolApp/Features/Homework/HomeworkView.swift`, `SchoolApp/Features/More/MoreView.swift`, `scripts/qa_smoke.sh` | Добавлен локальный entitlement-статус подписки; AI-разбор в Today и ДЗ закрывается понятным paywall при `-qa-no-subscription`, базовые данные остаются доступны; `xcodebuild` и полный smoke-прогон проходят |
| 2026-07-03 | Фикс ширины экрана ДЗ | Пройдено | 3 | `.build/screenshots/homework-width-fixed.png`, `.build/screenshots/qa-smoke/homework-filters.png`, `SchoolApp/Features/Homework/HomeworkView.swift` | Экран ДЗ зафиксирован по ширине viewport, метаданные и кнопки карточек используют адаптивный перенос вместо расширения страницы; `xcodebuild` и полный smoke-прогон проходят |
| 2026-07-03 | Мультипрофили и роли по классам | Пройдено | 3 | `.build/screenshots/more-multi-role-profile.png`, `.build/screenshots/more-multi-role-children.png`, `.build/screenshots/more-multi-role-classes.png`, `.build/screenshots/qa-smoke/more-profile.png`, `.build/screenshots/qa-smoke/more-children.png`, `.build/screenshots/qa-smoke/more-classes.png`, `SchoolApp/Features/More/MoreView.swift`, `scripts/qa_smoke.sh` | Профиль показывает роли отдельно по детям/классам, экран детей позволяет менять роль конкретного профиля, а классы синхронизированы с детскими профилями; `xcodebuild` и полный smoke-прогон проходят |
| 2026-07-03 | Создание фотоальбомов класса | Пройдено | 3 | `.build/screenshots/class-photo-album-create.png`, `.build/screenshots/qa-smoke/class-photo-album-create.png`, `SchoolApp/Features/ClassRoom/ClassRoomView.swift`, `scripts/qa_smoke.sh` | Родкомитет или учитель может создать закрытый альбом класса с типом, названием и описанием; `xcodebuild` и полный smoke-прогон проходят |
| 2026-07-03 | Отчет по сбору | Пройдено | 3 | `.build/screenshots/class-collection-report.png`, `.build/screenshots/qa-smoke/class-collection-report.png`, `SchoolApp/Features/ClassRoom/ClassRoomView.swift`, `scripts/qa_smoke.sh` | Детальный экран сбора получил финансовую сводку, список расходов и системную отправку текстового отчета; `xcodebuild` и полный smoke-прогон проходят |
| 2026-07-03 | Локальная очередь уведомлений | Пройдено | 3 | `.build/screenshots/notifications-scheduled-local.png`, `.build/screenshots/qa-smoke/more-notifications.png`, `SchoolApp/Features/More/MoreView.swift`, `scripts/qa_smoke.sh` | Настройки уведомлений планируют вечерний/утренний дайджест, срочное объявление и дедлайн оплаты в iOS Notification Center; `xcodebuild` и полный smoke-прогон проходят |
| 2026-07-03 | Поддержка и отчеты о проблеме | Пройдено | 3 | `.build/screenshots/more-support-history.png`, `.build/screenshots/more-problem-history.png`, `.build/screenshots/qa-smoke/more-support.png`, `.build/screenshots/qa-smoke/more-problem.png`, `SchoolApp/Features/More/MoreView.swift`, `scripts/qa_smoke.sh` | Формы поддержки сохраняют историю обращений локально и готовят текст для системной отправки через iOS Share Sheet; `xcodebuild` и полный smoke-прогон проходят |
| 2026-07-03 | Ошибки AI из ДЗ | Пройдено | 3 | `.build/screenshots/homework-ai-report.png`, `.build/screenshots/more-ai-quality-after-report.png`, `.build/screenshots/qa-smoke/homework-ai-report.png`, `.build/screenshots/qa-smoke/more-ai-quality.png`, `SchoolApp/Features/Homework/HomeworkView.swift`, `SchoolApp/Features/More/MoreView.swift`, `SchoolApp/Models/SampleData.swift`, `scripts/qa_smoke.sh` | Результат ДЗ по фото может отправить ошибку в общий локальный журнал качества AI, а экран `Качество AI` показывает эту запись; `xcodebuild` и полный smoke-прогон проходят |
| 2026-07-03 | QA пустого ДЗ и offline | Пройдено | 3 | `.build/screenshots/homework-empty-state.png`, `.build/screenshots/more-sync-offline-state.png`, `.build/screenshots/qa-smoke/homework-empty.png`, `.build/screenshots/qa-smoke/more-sync-offline.png`, `SchoolApp/Features/Homework/HomeworkView.swift`, `SchoolApp/Features/More/MoreView.swift`, `scripts/qa_smoke.sh` | Добавлены smoke-сценарии пустого списка ДЗ и offline-очереди синхронизации; QA-сценарии `Нет подписки` и `Ошибка сети` отмечены как пройденные локально; `xcodebuild` и полный smoke-прогон проходят |
| 2026-07-03 | Dry-run backend-мутаций | Пройдено | 3 | `docs/backend_contracts.md`, `SchoolApp/Features/More/MoreView.swift`, `.build/screenshots/qa-smoke/more-sync.png`, `.build/screenshots/qa-smoke/more-sync-offline.png` | Центр синхронизации готовит локальные mutation preview с `mutationId`, endpoint, operation, baseVersion, payloadPreview и статусами accepted/queued/blocked; `xcodebuild` и полный smoke-прогон проходят |
| 2026-07-03 | OpenAPI draft MVP | Пройдено | 3 | `docs/openapi_mvp.yaml`, `docs/backend_contracts.md`, `SchoolApp/Features/More/MoreView.swift`, `.build/screenshots/qa-smoke/more-sync.png`, `.build/screenshots/qa-smoke/more-sync-offline.png` | Добавлен первый OpenAPI-контракт для batch-мутаций, класса, ДЗ, прочтения объявления, чеков, приглашений и фото; `xcodebuild`, YAML-проверка и полный smoke-прогон проходят |
| 2026-07-03 | Readiness-контроль API | Пройдено | 3 | `SchoolApp/Features/More/MoreView.swift`, `docs/backend_contracts.md`, `.build/screenshots/qa-smoke/more-sync.png`, `.build/screenshots/qa-smoke/more-sync-offline.png` | Центр синхронизации показывает готовые API-артефакты, следующие слои и блокеры: Swift API client, server roles/auth и private storage; `xcodebuild`, визуальная проверка sync-скрина и полный smoke-прогон проходят |
| 2026-07-03 | Batch request preview | Пройдено | 3 | `SchoolApp/Features/More/MoreView.swift`, `docs/backend_contracts.md`, `.build/screenshots/qa-smoke/more-sync.png`, `.build/screenshots/qa-smoke/more-sync-offline.png` | Dry-run синхронизации собирает preview будущего `POST /sync/mutations`: URL окружения, auth-заглушку, idempotency key и компактное тело batch-запроса; `xcodebuild`, визуальная проверка sync-скрина и полный smoke-прогон проходят |
| 2026-07-03 | SyncClient scaffold | Пройдено | 3 | `SchoolApp/Features/More/MoreView.swift`, `docs/backend_contracts.md`, `.build/screenshots/qa-smoke/more-sync.png`, `.build/screenshots/qa-smoke/more-sync-offline.png` | Dry-run фиксирует scaffold будущего Swift-клиента: URLSession transport, result mapping, retry-план, server version persistence и обработку storage/conflict/auth блокеров; `xcodebuild` и полный smoke-прогон прошли, sync-экран проверен визуально |
| 2026-07-03 | Typed SyncClient dry-run | Пройдено | 3 | `SchoolApp/Features/More/MoreView.swift`, `docs/backend_contracts.md`, `scripts/qa_smoke.sh`, `.build/screenshots/qa-smoke/more-sync.png`, `.build/screenshots/qa-smoke/more-sync-offline.png` | Sync dry-run переведен на Codable request/response модели, mock `MutationBatchResponse` decode и mapping accepted/queued/blocked; `xcodebuild clean build`, полный smoke-прогон и визуальная проверка sync-экрана прошли |
| 2026-07-04 | Sync auth context | Пройдено | 3 | `SchoolApp/Features/More/MoreView.swift`, `docs/backend_contracts.md`, `.build/screenshots/qa-smoke/more-sync.png`, `.build/screenshots/qa-smoke/more-sync-offline.png` | Sync dry-run добавляет typed auth context: actor user id, class role claim, bearer preview и refresh-план; `xcodebuild clean build`, полный smoke-прогон и визуальная проверка sync-экрана прошли |
| 2026-07-04 | Storage preflight sync | Пройдено | 3 | `SchoolApp/Features/More/MoreView.swift`, `docs/backend_contracts.md`, `.build/screenshots/qa-smoke/more-sync.png`, `.build/screenshots/qa-smoke/more-sync-offline.png` | Sync dry-run готовит private bucket, pending uploads и список мутаций, которые ждут `fileId` перед отправкой метаданных; `xcodebuild clean build`, полный smoke-прогон и визуальная проверка sync-экрана прошли |
| 2026-07-04 | Signed upload API contract | Пройдено | 3 | `docs/openapi_mvp.yaml`, `docs/backend_contracts.md`, `SchoolApp/Features/More/MoreView.swift`, `.build/screenshots/qa-smoke/more-sync.png`, `.build/screenshots/qa-smoke/more-sync-offline.png` | OpenAPI draft получил `POST /files/upload-url`, схемы signed upload и storage preflight в batch request; YAML-проверка, `xcodebuild clean build`, полный smoke-прогон и визуальная проверка sync-экрана прошли |
| 2026-07-04 | Upload-intent dry-run | Пройдено | 3 | `SchoolApp/Features/More/MoreView.swift`, `docs/openapi_mvp.yaml`, `docs/backend_contracts.md`, `.build/screenshots/qa-smoke/more-sync.png`, `.build/screenshots/qa-smoke/more-sync-offline.png` | Sync dry-run показывает upload-intent preview для signed URL: kind, fileName, mimeType, sizeBytes, checksum и metadata-plan; YAML-проверка, `xcodebuild clean build`, полный smoke-прогон и визуальная проверка верхней части sync-экрана прошли |
| 2026-07-04 | Signed upload response dry-run | Пройдено | 3 | `SchoolApp/Features/More/MoreView.swift`, `docs/openapi_mvp.yaml`, `docs/backend_contracts.md`, `.build/screenshots/qa-smoke/more-sync.png`, `.build/screenshots/qa-smoke/more-sync-offline.png` | Sync dry-run показывает mock signed upload response: fileId, uploadUrl, TTL, required header, private bucket и storage key; YAML-проверка, `xcodebuild clean build`, полный smoke-прогон и визуальная проверка верхней части sync-экрана прошли |
| 2026-07-04 | File scan gate dry-run | Пройдено | 3 | `SchoolApp/Features/More/MoreView.swift`, `docs/openapi_mvp.yaml`, `docs/backend_contracts.md`, `.build/screenshots/qa-smoke/more-sync.png`, `.build/screenshots/qa-smoke/more-sync-offline.png` | Sync dry-run показывает scan/moderation gate: pending_scan блокирует metadata-мутацию до clean-статуса; YAML-проверка, `xcodebuild clean build`, полный smoke-прогон и визуальная проверка верхней части sync-экрана прошли |
| 2026-07-04 | Metadata release dry-run | Пройдено | 3 | `SchoolApp/Features/More/MoreView.swift`, `docs/openapi_mvp.yaml`, `docs/backend_contracts.md`, `.build/screenshots/qa-smoke/more-sync.png`, `.build/screenshots/qa-smoke/more-sync-offline.png` | Sync dry-run показывает metadata release: после clean scan заменяет `pending-upload` на `fileId` и разблокирует metadata-мутацию; YAML-проверка, `xcodebuild clean build`, полный smoke-прогон и визуальная проверка sync-экрана прошли |
| 2026-07-04 | Network readiness gate | Пройдено | 3 | `SchoolApp/Features/More/MoreView.swift`, `docs/openapi_mvp.yaml`, `docs/backend_contracts.md`, `.build/screenshots/qa-smoke/more-sync.png`, `.build/screenshots/qa-smoke/more-sync-offline.png` | Sync center показывает live-mode gate: `GET /health`, timeout/retry policy, auth refresh, 403 role blocker и TestFlight release gate; OpenAPI получил `/health`; YAML-проверка, `xcodebuild clean build`, полный smoke-прогон и визуальная проверка sync-экрана прошли |
| 2026-07-04 | StoreKit entitlement readiness | Пройдено | 3 | `SchoolApp/Features/More/MoreView.swift`, `docs/openapi_mvp.yaml`, `docs/storekit_mvp_plan.md`, `docs/backend_contracts.md`, `.build/screenshots/qa-smoke/more-subscription.png` | Экран подписки показывает entitlement state, AI-доступ, источник проверки, будущий `GET /subscriptions/entitlement` и правила active/expired/failed; OpenAPI получил entitlement schema; YAML-проверка, `xcodebuild clean build`, полный smoke-прогон и визуальная проверка экрана подписки прошли |
| 2026-07-04 | Server deletion readiness | Пройдено | 3 | `SchoolApp/Features/More/MoreView.swift`, `docs/openapi_mvp.yaml`, `docs/backend_contracts.md`, `docs/release_materials.md`, `.build/screenshots/qa-smoke/more-security.png` | Экран безопасности показывает будущий server deletion gate: `GET /me/export`, `POST /me/deletion-requests`, AuditLog, scope и 7-day grace period; OpenAPI получил export/deletion schemas; YAML-проверка, `xcodebuild clean build`, полный smoke-прогон и визуальная проверка экрана безопасности прошли |
| 2026-07-04 | Deletion status and cancel readiness | Пройдено | 3 | `SchoolApp/Features/More/MoreView.swift`, `docs/openapi_mvp.yaml`, `docs/backend_contracts.md`, `docs/release_materials.md`, `.build/screenshots/qa-smoke/more-security.png` | Экран безопасности и backend-контракт показывают жизненный цикл заявки удаления: `GET /me/deletion-requests/{requestId}`, `POST /me/deletion-requests/{requestId}/cancel`, `canCancel`, re-auth и AuditLog для отмены; YAML-проверка, `xcodebuild clean build`, полный smoke-прогон и визуальная проверка экрана безопасности прошли |
| 2026-07-04 | Local deletion lifecycle UX | Пройдено | 3 | `SchoolApp/Features/More/MoreView.swift`, `scripts/qa_smoke.sh`, `.build/screenshots/qa-smoke/more-security-lifecycle.png`, `docs/project_checklist.md` | Экран безопасности хранит локальный requestId, grace period, статус `canCancel`, re-auth код `1234`, кнопку отмены и AuditLog-события создания/отмены заявки; smoke получил отдельный кадр нижнего lifecycle-блока; YAML-проверка, `xcodebuild clean build`, полный smoke-прогон и визуальная проверка экрана безопасности прошли |
| 2026-07-04 | APNs backend readiness | Пройдено | 3 | `SchoolApp/Features/More/MoreView.swift`, `docs/openapi_mvp.yaml`, `docs/backend_contracts.md`, `.build/screenshots/qa-smoke/more-notifications.png` | Экран уведомлений показывает APNs readiness gate: `POST /devices/push-token`, `POST /notifications/dispatch-preview`, quiet hours, time-sensitive urgent и role/child/class routing; OpenAPI получил push token и dispatch preview schemas; YAML-проверка, `xcodebuild clean build`, полный smoke-прогон и визуальная проверка экрана уведомлений прошли |
| 2026-07-04 | Закрепления и реакции в чатах | Пройдено | 3 | `SchoolApp/Features/ClassRoom/ClassRoomView.swift`, `SchoolApp/Models/SampleData.swift`, `scripts/qa_smoke.sh`, `.build/screenshots/qa-smoke/class-chat-detail.png` | Детальный экран чата получил блок закрепленных сообщений, счетчики закреплений/реакций, локальные кнопки закрепить/открепить и реакции с сохранением в `ClassRoomLocalStore`; `ClassChatMessage` читает старые сохраненные данные без новых полей; `xcodebuild clean build`, полный smoke-прогон и визуальная проверка экрана чата прошли |
| 2026-07-04 | Локальные вложения в чатах | Пройдено | 3 | `SchoolApp/Features/ClassRoom/ClassRoomView.swift`, `SchoolApp/Models/SampleData.swift`, `.build/screenshots/qa-smoke/class-chat-detail.png` | `ClassChatMessage` получил совместимое поле `attachment`; детальный экран чата показывает вложения в сообщениях, счетчик файлов, кнопки `Фото` и `Файл`, системный file picker и очистку выбранного вложения перед отправкой; `xcodebuild clean build`, полный smoke-прогон и визуальная проверка экрана чата прошли |
| 2026-07-04 | Локальные голосовые в чатах | Пройдено | 3 | `SchoolApp/Features/ClassRoom/ClassRoomView.swift`, `SchoolApp/Models/SampleData.swift`, `.build/screenshots/qa-smoke/class-chat-detail.png` | `ClassChatMessage` получил совместимое поле `voiceDuration`; детальный экран чата показывает voice-note с waveform, длительность, кнопку `Голос`, очистку выбранного voice-note и общий счетчик медиа; `xcodebuild clean build`, полный smoke-прогон и визуальная проверка экрана чата прошли |
| 2026-07-04 | Beta/TestFlight readiness | Пройдено | 3 | `SchoolApp/Features/More/MoreView.swift`, `docs/release_materials.md`, `.build/screenshots/qa-smoke/more-beta.png` | В разделе `Еще` добавлен экран подготовки к бете: готовые пункты, блокеры, группы тестеров, сценарии приемки и следующий шаг с реальным iPhone; smoke получил отдельный кадр beta readiness; `xcodebuild clean build`, полный smoke-прогон и визуальная проверка экрана прошли |
| 2026-07-04 | Assert-валидация smoke-скриншотов | Пройдено | 3 | `scripts/qa_smoke.sh`, `.build/screenshots/qa-smoke/` | Smoke-прогон теперь проверяет каждый снятый экран: файл должен существовать, быть непустым PNG с валидной шириной/высотой и не быть подозрительно маленьким; полный `xcodebuild clean build` и smoke-прогон проходят |
| 2026-07-04 | Smoke summary manifest | Пройдено | 3 | `scripts/qa_smoke.sh`, `.build/screenshots/qa-smoke/summary.txt` | Smoke-сценарии перенесены в единый manifest внутри скрипта, после успешного прогона создается summary с проектом, схемой, Simulator ID, числом прошедших сценариев и списком PNG-артефактов; `bash -n`, `xcodebuild clean build` и полный smoke-прогон проходят |
| 2026-07-04 | Архив выполненных ДЗ | Пройдено | 3 | `SchoolApp/Features/Homework/HomeworkView.swift`, `SchoolApp/Models/SampleData.swift`, `.build/screenshots/qa-smoke/homework-archive.png` | В шапке ДЗ добавлена кнопка архива; экран показывает число выполненных заданий, количество сроков и детей, группирует готовые ДЗ по срокам и отображает предмет, задание и ребенка; smoke получил отдельный сценарий `homework-archive`; `xcodebuild clean build`, полный smoke-прогон и визуальная проверка экрана прошли |
| 2026-07-04 | Локальный центр модерации | Пройдено | 3 | `SchoolApp/Features/More/MoreView.swift`, `scripts/qa_smoke.sh`, `.build/screenshots/qa-smoke/more-moderation.png` | В разделе `Еще` добавлен экран модерации: очередь жалоб на фото, чат и участника, счетчики новых/на проверке/закрытых, локальные действия смены статуса и правила безопасности; серверная очередь и аудит решений еще не подключены |
| 2026-07-04 | Юридический центр MVP | Пройдено | 3 | `SchoolApp/Features/More/MoreView.swift`, `scripts/qa_smoke.sh`, `.build/screenshots/qa-smoke/more-legal.png` | В разделе `Еще` добавлен экран юридической готовности: черновики политики/условий, статус согласия родителя, блокеры App Store, публичной ссылки, владельца приложения и фактических провайдеров; финальный юридический обзор еще не выполнен |
| 2026-07-04 | Gate проверки на iPhone | Пройдено | 2 | `SchoolApp/Features/More/MoreView.swift`, `scripts/qa_smoke.sh`, `.build/screenshots/qa-smoke/more-real-device.png` | В разделе `Еще` добавлен экран ручной проверки физического iPhone: подпись, камера, фото, файлы, системный шаринг, уведомления, роли, приватность и производительность; smoke проверяет доступность экрана, фактическая проверка на устройстве остается отдельным ручным шагом |
| 2026-07-04 | Behavior QA gate | Пройдено | 3 | `SchoolApp/Features/More/MoreView.swift`, `scripts/qa_smoke.sh`, `.build/screenshots/qa-smoke/more-behavior.png` | В разделе `Еще` добавлен экран behavioral-инвариантов: родительские права, сохранение состояния, детский режим, offline-очередь, paywall и медиа; smoke проверяет доступность gate, настоящие XCTest/UI assert-ы остаются следующим слоем |
| 2026-07-04 | Первый XCTest/UI набор | Пройдено | 4 | `SchoolAppUITests/SchoolAppUITests.swift`, `scripts/qa_ui_tests.sh`, `.build/SchoolAppUITests.xcresult` | В Xcode-проект добавлен target `SchoolAppUITests`: 3 UI-теста проверяют Behavior QA gate, детский режим с укороченными вкладками и запрет родителю создавать сбор; `scripts/qa_ui_tests.sh` прошел: 3 теста, 0 failures |
| 2026-07-04 | XCTest сохранения прочтения | Пройдено | 4 | `SchoolAppUITests/SchoolAppUITests.swift`, `SchoolApp/Features/ClassRoom/ClassRoomView.swift`, `.build/SchoolAppUITests.xcresult`, `.build/screenshots/qa-smoke/summary.txt` | QA deep-links переведены на локально сохраненные данные, добавлен UI-тест "Я прочитал" -> перезапуск -> "Прочитано"; `scripts/qa_ui_tests.sh` прошел: 4 теста, 0 failures; полный smoke прошел: 47 сценариев |
| 2026-07-04 | XCTest сохранения расхода сбора | Пройдено | 4 | `SchoolAppUITests/SchoolAppUITests.swift`, `SchoolApp/Features/ClassRoom/ClassRoomView.swift`, `.build/SchoolAppUITests.xcresult`, `.build/screenshots/qa-smoke/summary.txt` | Добавлен UI-тест родкомитета: открыть сбор, нажать "Добавить расход", увидеть "Чек за автобус", перезапустить приложение и снова увидеть расход; `scripts/qa_ui_tests.sh` прошел: 5 тестов, 0 failures; полный smoke прошел: 47 сценариев |
| 2026-07-04 | XCTest сохранения ручного ДЗ | Пройдено | 4 | `SchoolAppUITests/SchoolAppUITests.swift`, `SchoolApp/Features/Homework/HomeworkView.swift`, `.build/SchoolAppUITests.xcresult`, `.build/screenshots/qa-smoke/summary.txt` | Добавлен UI-тест: открыть форму ДЗ, сохранить предзаполненное задание, увидеть карточку, перезапустить приложение и снова увидеть предмет/задание; `scripts/qa_ui_tests.sh` прошел: 6 тестов, 0 failures; полный smoke прошел: 47 сценариев |
| 2026-07-04 | XCTest сохранения события календаря | Пройдено | 4 | `SchoolAppUITests/SchoolAppUITests.swift`, `SchoolApp/Features/Calendar/CalendarView.swift`, `.build/SchoolAppUITests.xcresult`, `.build/screenshots/qa-smoke/summary.txt` | Добавлен UI-тест: открыть форму события, прокрутить до публикации, сохранить предзаполненную экскурсию, увидеть дату в календаре, перезапустить приложение и снова увидеть название/дату; `scripts/qa_ui_tests.sh` прошел: 7 тестов, 0 failures; полный smoke прошел: 47 сценариев |
| 2026-07-04 | XCTest запрета объявлений родителю | Пройдено | 4 | `SchoolAppUITests/SchoolAppUITests.swift`, `.build/SchoolAppUITests.xcresult`, `.build/screenshots/qa-smoke/summary.txt` | Добавлен UI-тест: родитель открывает прямой QA-вход в создание объявления и получает экран "Нет прав" с текстом "Публикация закрыта", без кнопки "Опубликовать"; тест подтверждения прочтения стабилизирован ожиданием состояния "Прочитано" перед перезапуском; `scripts/qa_ui_tests.sh` прошел: 8 тестов, 0 failures; полный smoke прошел: 47 сценариев |
| 2026-07-04 | XCTest запрета приглашений родителю | Пройдено | 4 | `SchoolAppUITests/SchoolAppUITests.swift`, `.build/SchoolAppUITests.xcresult`, `.build/screenshots/qa-smoke/summary.txt` | Добавлен UI-тест: родитель открывает прямой QA-вход в приглашение участников и получает экран "Нет прав" с текстом "Приглашения закрыты", без кнопки "Добавить приглашение"; `scripts/qa_ui_tests.sh` прошел: 9 тестов, 0 failures; полный smoke прошел: 47 сценариев |
| 2026-07-04 | XCTest запрета удаления фото родителю | Пройдено | 4 | `SchoolAppUITests/SchoolAppUITests.swift`, `.build/SchoolAppUITests.xcresult`, `.build/screenshots/qa-smoke/summary.txt` | Добавлен UI-тест: родитель открывает просмотр фото класса, видит действия "Скачать", "Поделиться", "Жалоба" и подсказку "Удаляет учитель или родкомитет", но не видит кнопку "Удалить"; `scripts/qa_ui_tests.sh` прошел: 10 тестов, 0 failures; полный smoke прошел: 47 сценариев |
| 2026-07-04 | XCTest запрета управления сбором родителю | Пройдено | 4 | `SchoolAppUITests/SchoolAppUITests.swift`, `.build/SchoolAppUITests.xcresult`, `.build/screenshots/qa-smoke/summary.txt` | Добавлен UI-тест: родитель открывает сбор, видит закрытый общий счетчик и кнопку "Сохранить мою оплату", но не видит степпер, блок "Подтверждено родкомитетом", добавление расхода, фото чека и файл; `scripts/qa_ui_tests.sh` прошел: 11 тестов, 0 failures; полный smoke прошел: 47 сценариев |
| 2026-07-04 | XCTest выбранного ребенка и контекста класса | Пройдено | 4 | `SchoolAppUITests/SchoolAppUITests.swift`, `SchoolApp/Features/Today/TodayView.swift`, `SchoolApp/App/AppView.swift`, `.build/SelectedChildUITest-3.xcresult`, `.build/screenshots/qa-smoke/summary.txt` | Добавлен UI-тест: выбор второго ребенка "Аня, 4А" на главной сохраняется, вкладка "Класс" открывается в контексте "Класс 4А" с ролью "родкомитет" и доступной кнопкой "Создать сбор"; точечный XCTest прошел: 1 тест, 0 failures; полный smoke прошел: 47 сценариев |
| 2026-07-04 | Стабилизация общего XCTest-прогона | Пройдено | 4 | `scripts/qa_ui_tests.sh`, `.build/SchoolAppUITests/summary.txt`, `.build/SchoolAppUITests/*.xcresult` | `scripts/qa_ui_tests.sh` разбит на 12 отдельных коротких XCTest-сессий с отдельными result bundle и общей summary, чтобы общий набор не упирался в лимит одной длинной сессии Xcode; полный прогон прошел: 12 тестов, 0 failures |
| 2026-07-04 | XCTest MVP-метрик и стабильный выбор ребенка | Пройдено | 4 | `SchoolAppUITests/SchoolAppUITests.swift`, `SchoolApp/Features/Today/TodayView.swift`, `scripts/qa_ui_tests.sh`, `scripts/qa_smoke.sh`, `.build/SchoolAppUITests/summary.txt`, `.build/screenshots/qa-smoke/summary.txt`, `.build/screenshots/qa-smoke/more-metrics.png` | Добавлен UI-тест MVP-метрик: экран "Метрики", событие `qa_smoke_passed` и сохранение после перезапуска; выбор ребенка переведен со SwiftUI Menu на системный нижний выбор, чтобы сценарий "Аня, 4А" стабильно проверял переход в класс 4А; полный `scripts/qa_ui_tests.sh` прошел: 13 тестов, 0 failures; полный smoke прошел: 48 сценариев |
| 2026-07-04 | XCTest ошибки сети в sync queue | Пройдено | 4 | `SchoolApp/Features/More/MoreView.swift`, `SchoolAppUITests/SchoolAppUITests.swift`, `scripts/qa_ui_tests.sh`, `scripts/qa_smoke.sh`, `.build/SyncNetworkErrorUITest-3.xcresult`, `.build/SchoolAppUITests/summary.txt`, `.build/screenshots/qa-smoke/more-sync-network-error.png`, `.build/screenshots/qa-smoke/summary.txt` | В центр синхронизации добавлен блок "Ошибки сети и повтор" с timeout/offline/5xx сценариями, статусом `Retry 1/5`, сохранением операции в очереди и кнопкой симуляции сбоя; точечный UI-тест прошел, полный `scripts/qa_ui_tests.sh` прошел: 14 тестов, 0 failures; полный smoke прошел: 49 сценариев |
| 2026-07-04 | Supabase test backend schema | Пройдено | 3 | `supabase/migrations/20260704190000_initial_school_schema.sql`, `docs/supabase/test_backend_plan.md`, Supabase project `tlhjwfauddueioatkahm` | В тестовом Supabase-проекте создана начальная схема: `profiles`, классы, участники, дети, объявления/прочтения, ДЗ, события, сборы, оплаты, файлы, расходы, фото и `sync_mutations`; RLS включен на public-таблицах, создан private storage bucket `class-files`; live iOS-клиент и seed/test users еще не подключены |
| 2026-07-09 | Supabase readiness в iOS | Пройдено | 4 | `SchoolApp/Features/More/MoreView.swift`, `SchoolAppUITests/SchoolAppUITests.swift`, `scripts/qa_ui_tests.sh`, `scripts/qa_smoke.sh`, `.build/SchoolAppUITests/summary.txt`, `.build/screenshots/qa-smoke/more-sync-supabase.png`, `.build/screenshots/qa-smoke/summary.txt` | В центр синхронизации добавлена карточка Supabase test backend: project ref, REST/Auth/Storage URL, 14 таблиц, 44 политики, private bucket и gate до `SUPABASE_ANON_KEY`; `scripts/qa_ui_tests.sh` прошел: 15 тестов, 0 failures; `scripts/qa_smoke.sh` прошел: 50 сценариев |
| 2026-07-09 | Supabase live REST probe в iOS | Пройдено | 4 | `SchoolApp/Features/More/MoreView.swift`, `SchoolAppUITests/SchoolAppUITests.swift`, `.build/SupabaseLiveProbeUITest-2.xcresult`, `.build/SchoolAppUITests/summary.txt`, `.build/screenshots/qa-smoke/more-sync-supabase.png`, `.build/screenshots/qa-smoke/summary.txt` | В центр синхронизации добавлен live probe через `URLSession`: `GET /class_rooms?select=id,title,invite_code&limit=3` с `apikey` и `Authorization` headers; без `SUPABASE_ANON_KEY` запрос намеренно блокируется и показывает следующий шаг; точечный UI-тест прошел после перезапуска зависшего runner, полный UI-набор прошел: 15 тестов, 0 failures; полный smoke прошел: 50 сценариев |
| 2026-07-09 | Supabase Auth session gate в iOS | Пройдено | 4 | `SchoolApp/Features/More/MoreView.swift`, `SchoolAppUITests/SchoolAppUITests.swift`, `.build/SupabaseAuthSessionUITest.xcresult`, `.build/MvpMetricsUITest-3.xcresult`, `.build/SchoolAppUITests/summary.txt`, `.build/screenshots/qa-smoke/more-sync-supabase.png`, `.build/screenshots/qa-smoke/summary.txt` | В центр синхронизации добавлен отдельный gate пользовательской Supabase-сессии: `SUPABASE_ACCESS_TOKEN`, `SUPABASE_REFRESH_TOKEN`, `SUPABASE_USER_ID`, статус RLS и следующий шаг для seed membership; live `class_rooms` probe теперь использует user bearer token, если он передан, иначе остается на anon bearer; стабилизирована кнопка добавления MVP-события и видимый блок последнего события; точечные UI-тесты Supabase Auth и MVP-метрик прошли, полный UI-набор прошел: 15 тестов, 0 failures; полный smoke прошел: 50 сценариев |
| 2026-07-10 | Supabase RLS helper hardening и smoke seed | Пройдено | 4 | `supabase/migrations/20260710003000_harden_rls_helpers.sql`, `supabase/seeds/rls_smoke_seed.sql`, `supabase/tests/rls_smoke.sql`, `supabase/tests/rls_write_smoke.sql`, `SchoolApp/Features/More/MoreView.swift`, `SchoolAppUITests/SchoolAppUITests.swift`, `.build/SupabaseRlsSmokeUITest.xcresult`, `.build/AnnouncementAckRetryUITest.xcresult`, `.build/CollectionExpenseRetryUITest.xcresult`, `.build/ManualHomeworkRetryUITest.xcresult`, `.build/CalendarEventRetryUITest.xcresult`, `.build/screenshots/qa-smoke/more-sync-supabase.png`, `.build/screenshots/qa-smoke/summary.txt` | RLS helper-функции перенесены в non-exposed schema `private`, `SECURITY DEFINER` RPC warnings закрыты; в тестовую Supabase-базу добавлены seed parent/teacher, классы `QA-3B-2026` и `QA-4A-2026`, ребенок `Smoke Child` и smoke-сбор; SQL RLS-smoke доказал: anon видит 0 классов, parent видит только `QA-3B-2026`, teacher видит оба класса; SQL write-smoke доказал: parent заблокирован на создание объявления/сбора/расхода, teacher может создавать эти записи; iOS sync-экран теперь показывает RLS smoke seed, write gate, publishable-key gate и live probe использует реальное поле `title`; точечный Supabase UI-тест прошел, полный UI-набор был прерван Xcode launch timeout на одном тесте, после чего этот и оставшиеся persistence-тесты прошли отдельно; полный smoke прошел: 50 сценариев |
| 2026-07-10 | Supabase Auth refresh probe в iOS | Пройдено | 4 | `SchoolApp/Features/More/MoreView.swift`, `SchoolAppUITests/SchoolAppUITests.swift`, `docs/supabase/test_backend_plan.md`, `.build/SupabaseAuthRefreshProbeUITest.xcresult`, `.build/screenshots/qa-smoke/more-sync-supabase.png`, `.build/screenshots/qa-smoke/summary.txt` | В центр синхронизации добавлена отдельная проверка refresh-сессии: `POST /auth/v1/token?grant_type=refresh_token`, `apikey` берется из `SUPABASE_PUBLISHABLE_KEY` или legacy `SUPABASE_ANON_KEY`, `SUPABASE_REFRESH_TOKEN` отправляется в JSON body; без client key/refresh token probe безопасно блокируется, успешным считается любой 2xx ответ Supabase Auth; точечный UI-тест прошел, полный smoke прошел: 50 сценариев; Supabase security advisor без новых schema warnings, остался только `auth_leaked_password_protection` |
| 2026-07-10 | Supabase signed profile probe в iOS | Пройдено | 4 | `SchoolApp/Features/More/MoreView.swift`, `SchoolAppUITests/SchoolAppUITests.swift`, `docs/supabase/test_backend_plan.md`, `.build/SupabaseSignedProfileUITest.xcresult`, `.build/screenshots/qa-smoke/more-sync-supabase.png`, `.build/screenshots/qa-smoke/summary.txt` | В центр синхронизации добавлена signed-проверка профиля: `GET /profiles?id=eq.<SUPABASE_USER_ID>&select=id,display_name,phone` с client `apikey` и user bearer token; без `SUPABASE_PUBLISHABLE_KEY`/`SUPABASE_ANON_KEY`, `SUPABASE_ACCESS_TOKEN` или `SUPABASE_USER_ID` запрос безопасно блокируется до сети; успешный signed probe требует ровно одну RLS-отфильтрованную строку профиля перед маппингом аккаунта в локальное состояние |
| 2026-07-10 | Supabase signed class scope probe в iOS | Пройдено | 4 | `SchoolApp/Features/More/MoreView.swift`, `SchoolAppUITests/SchoolAppUITests.swift`, `docs/supabase/test_backend_plan.md`, `.build/SupabaseSignedClassScopeUITest-3.xcresult`, `.build/screenshots/qa-smoke/more-sync-supabase.png`, `.build/screenshots/qa-smoke/summary.txt` | В центр синхронизации добавлена signed-проверка членства в классах: `GET /class_members?user_id=eq.<SUPABASE_USER_ID>&select=id,class_id,role,status,class_rooms(id,title,invite_code)` с client `apikey`, user bearer token и embedded `class_rooms`; без client key, `SUPABASE_ACCESS_TOKEN` или `SUPABASE_USER_ID` запрос безопасно блокируется до сети; успешный signed probe требует активные membership-строки под RLS перед маппингом классов и ролей в локальный репозиторий |
| 2026-07-10 | Supabase class context mapper preview | Пройдено | 4 | `SchoolApp/Features/More/MoreView.swift`, `SchoolAppUITests/SchoolAppUITests.swift`, `docs/supabase/test_backend_plan.md`, `.build/SupabaseClassContextMapperUITest-3.xcresult`, `.build/screenshots/qa-smoke/more-sync-supabase.png`, `.build/screenshots/qa-smoke/summary.txt` | Signed class scope probe теперь не только декодирует `class_members`, но и строит preview будущего локального class context: активные membership-строки превращаются в `classID`, название класса, роль и invite code; без signed rows mapper остается заблокированным и не заменяет локальные данные; это промежуточный слой перед подключением Supabase context к выбору ребенка/класса |
| 2026-07-10 | Supabase class context local bridge | Пройдено | 4 | `SchoolApp/Models/SampleData.swift`, `SchoolApp/Features/More/MoreView.swift`, `SchoolAppUITests/SchoolAppUITests.swift`, `docs/supabase/test_backend_plan.md`, `.build/SupabaseClassContextBridgeUITest.xcresult`, `.build/screenshots/qa-smoke/summary.txt` | Добавлен отдельный локальный bridge `AppSupabaseClassContextBridge`: signed class scope probe сохраняет активные Supabase class context rows в отдельный `UserDefaults`-буфер только после успешного signed mapper, а локальный список детей/выбранный ребенок остаются untouched; точечный UI-тест Supabase bridge прошел, полный smoke прошел 50 сценариев; это безопасный слой перед реальным переключением классов по Supabase-профилям |
| 2026-07-10 | Supabase bridge handoff preview | Пройдено | 4 | `SchoolApp/App/AppView.swift`, `SchoolApp/Models/SampleData.swift`, `SchoolApp/Features/Today/TodayView.swift`, `SchoolApp/Features/ClassRoom/ClassRoomView.swift`, `SchoolApp/Features/More/MoreView.swift`, `SchoolAppUITests/SchoolAppUITests.swift`, `.build/SupabaseClassBridgeHandoffUITest-2.xcresult`, `.build/screenshots/qa-smoke/summary.txt` | Supabase bridge context теперь имеет русские подписи ролей и виден как отдельная handoff-подсказка на главной, в классе и в профиле; QA-seed подтверждает, что `QA-3B-2026` показывается как готовый Supabase-контекст, но выбранный локальный ребенок остается `Миша, 3Б`; точечный UI-тест прошел после исправления порядка seed до первого рендера, полный smoke прошел 50 сценариев |
| 2026-07-10 | Supabase signed children и child bridge | Пройдено | 4 | `SchoolApp/Features/More/MoreView.swift`, `SchoolApp/Models/SampleData.swift`, `SchoolApp/App/AppView.swift`, `SchoolApp/Features/Today/TodayView.swift`, `SchoolApp/Features/ClassRoom/ClassRoomView.swift`, `SchoolAppUITests/SchoolAppUITests.swift`, `scripts/qa_ui_tests.sh`, `.build/SupabaseSignedChildrenUITest.xcresult`, `.build/SupabaseChildBridgeUITest.xcresult`, `.build/SchoolAppUITests/summary.txt`, `.build/screenshots/qa-smoke/summary.txt` | В центр синхронизации добавлена signed-проверка детей: `GET /children?parent_user_id=eq.<SUPABASE_USER_ID>&select=id,class_id,display_name,grade_title,class_rooms(id,title,invite_code)` с client `apikey` и user bearer token; без ключей/tokens probe безопасно блокируется до сети, успешные строки маппятся в отдельный `AppSupabaseChildContextBridge`; QA seed показывает `Smoke Child -> QA-3B-2026` на главной и в классе, но локальный выбранный ребенок остается `Миша, 3Б`; точечные UI-тесты, полный UI-набор 16/16 и smoke 50/50 прошли |
| 2026-07-10 | Supabase child source preview | Пройдено | 4 | `SchoolApp/Models/SampleData.swift`, `SchoolApp/App/AppView.swift`, `SchoolApp/Features/Today/TodayView.swift`, `SchoolApp/Features/ClassRoom/ClassRoomView.swift`, `SchoolAppUITests/SchoolAppUITests.swift`, `scripts/qa_ui_tests.sh`, `.build/SupabaseChildSourcePreviewUITest.xcresult`, `.build/SupabaseChildBridgeDefaultRetest.xcresult`, `.build/SchoolAppUITests/summary.txt`, `.build/screenshots/qa-smoke/summary.txt` | Добавлен QA-gated режим `-qa-use-supabase-child-source`: выбор ребенка и экран класса могут брать child/class context из `AppSupabaseChildContextBridge`, показывая `Smoke Child, 3Б` и класс `QA-3B-2026`; обычный режим отдельно проверен и сохраняет локального `Миша, 3Б`; точечные UI-тесты прошли, полный UI-набор 17/17 и smoke 50/50 прошли; Supabase security advisor без новых schema warnings, остался только `auth_leaked_password_protection` |
| 2026-07-10 | Supabase child source sync toggle | Пройдено | 4 | `SchoolApp/Features/More/MoreView.swift`, `SchoolAppUITests/SchoolAppUITests.swift`, `scripts/qa_ui_tests.sh`, `docs/supabase/test_backend_plan.md`, `.build/SupabaseChildSourceSyncToggleUITest.xcresult`, `.build/SchoolAppUITests/summary.txt`, `.build/screenshots/qa-smoke/summary.txt` | В sync-центре добавлен управляемый переключатель источника ребенка: при готовом child bridge кнопка "Включить источник" переводит Today/Class на `Smoke Child, 3Б` и `QA-3B-2026`, кнопка "Локальные дети" возвращает local source; точечный UI-тест прошел, полный UI-набор 18/18 и smoke 50/50 прошли; Supabase advisor без новых schema warnings, остался `auth_leaked_password_protection` |
| 2026-07-10 | Supabase child source persistence toggle | Пройдено | 4 | `SchoolAppUITests/SchoolAppUITests.swift`, `scripts/qa_ui_tests.sh`, `docs/supabase/test_backend_plan.md`, `.build/SupabaseChildSourcePersistenceToggleUITest.xcresult`, `.build/SupabaseChildSourceEnableAndPersistRetest.xcresult`, `.build/SchoolAppUITests/summary.txt`, `.build/screenshots/qa-smoke/summary.txt` | Добавлен UI-тест полного жизненного цикла Supabase child source: включение из sync-центра сохраняется после перезапуска и Today показывает `Smoke Child, 3Б` / `QA-3B-2026`; выключение через "Локальные дети" также сохраняется после перезапуска и возвращает `Миша, 3Б` / `3B-1254`; стабилизирована проверка sync-toggle без зависимости от промежуточной видимости текста в длинном sync-экране; точечные UI-тесты прошли, полный UI-набор 19/19 и smoke 50/50 прошли |
| 2026-07-10 | Supabase password sign-in probe | Пройдено | 4 | `SchoolApp/Features/More/MoreView.swift`, `SchoolAppUITests/SchoolAppUITests.swift`, `docs/supabase/test_backend_plan.md`, `.build/SupabasePasswordSignInGateUITest-2.xcresult`, `.build/SchoolAppUITests/summary.txt`, `.build/screenshots/qa-smoke/summary.txt` | В Sync Center добавлен password sign-in probe для seed Auth user: `POST /auth/v1/token?grant_type=password` с client `apikey`, `SUPABASE_TEST_EMAIL` и `SUPABASE_TEST_PASSWORD`; без client key/seed credentials запрос блокируется до сети, а при успешной сессии результат на этом шаге передавался в signed profile/classes/children probes без замены локального входа; последующий шаг перевел seed session store на Keychain-first хранение; targeted UI-тест прошел после стабилизации viewport-проверки, полный UI-набор 19/19 и smoke 50/50 прошли |
| 2026-07-10 | Supabase QA seed session store | Пройдено | 4 | `SchoolApp/Features/More/MoreView.swift`, `SchoolAppUITests/SchoolAppUITests.swift`, `scripts/qa_ui_tests.sh`, `docs/supabase/test_backend_plan.md`, `.build/SupabaseStoredSeedSessionUITest.xcresult` | После успешного password sign-in приложение сохраняет seed Auth session во временный QA/UserDefaults store, показывает источник `stored seed session`, preview access token, user id и expiry в Sync Center, использует сохраненную сессию как fallback для auth/signed probes и дает кнопку очистки; добавлен relaunch UI-тест `testSupabaseStoredSeedSessionCanBeClearedAfterRelaunch`, который проверяет seed, auth-card, clear и отсутствие сессии после перезапуска; Keychain остается обязательным следующим шагом перед production auth |
| 2026-07-10 | Supabase Keychain seed session store | Пройдено | 4 | `SchoolApp/Features/More/MoreView.swift`, `SchoolAppUITests/SchoolAppUITests.swift`, `docs/supabase/test_backend_plan.md`, `.build/SupabaseKeychainSeedSessionUITest.xcresult` | Seed Auth session store переведен на Keychain-first хранение: `SupabaseSeedSessionStore` читает Keychain как primary source, удаляет legacy UserDefaults после успешной записи, оставляет legacy QA/UserDefaults только fallback для старых тестовых сессий и очищает оба хранилища одной кнопкой; UI-тест `testSupabaseStoredSeedSessionCanBeClearedAfterRelaunch` обновлен на источник `keychain seed session` и прошел точечно; production Auth flow остается отдельным следующим шагом |
| 2026-07-10 | Supabase email auth в онбординге | Пройдено | 4 | `SchoolApp/Features/Onboarding/OnboardingView.swift`, `SchoolApp/Features/More/MoreView.swift`, `SchoolAppUITests/SchoolAppUITests.swift`, `docs/supabase/test_backend_plan.md`, `.build/SupabaseOnboardingEmailGateUITest.xcresult` | В первый шаг онбординга добавлен реальный email/password вход через Supabase Auth `POST /auth/v1/token?grant_type=password`: при успешном ответе сессия сохраняется в общий Keychain seed session store, после чего открывается выбор роли и класса; телефон и Apple-заглушка остаются совместимыми локальными путями; UI-тест `testOnboardingSupabaseEmailRequiresSuccessfulAuthBeforeRoleStep` подтверждает, что без успешного Supabase Auth входа роль/класс не открываются |
| 2026-07-10 | Supabase onboarding handoff | Пройдено | 4 | `SchoolApp/Features/Onboarding/OnboardingView.swift`, `SchoolApp/Features/More/MoreView.swift`, `SchoolAppUITests/SchoolAppUITests.swift`, `docs/supabase/test_backend_plan.md`, `.build/SupabaseOnboardingHandoffUITest.xcresult` | После успешного Supabase email/password входа онбординг запускает signed class/children handoff, сохраняет найденные классы и детей в bridge-контекст, включает Supabase child source preview и показывает выбранного ребенка/класс перед выбором статуса; UI-тесты `testOnboardingSupabaseEmailRequiresSuccessfulAuthBeforeRoleStep` и `testOnboardingSupabaseHandoffUnlocksRoleAndClassStep` прошли точечно, без повторного полного smoke на 50 сценариев для этого узкого backend-шага |
| 2026-07-10 | Supabase profile handoff в онбординге | Пройдено | 4 | `SchoolApp/Models/SampleData.swift`, `SchoolApp/Features/Onboarding/OnboardingView.swift`, `SchoolApp/Features/More/MoreView.swift`, `SchoolAppUITests/SchoolAppUITests.swift`, `docs/supabase/test_backend_plan.md`, `.build/SupabaseOnboardingProfileHandoffUITest.xcresult` | Post-auth handoff теперь параллельно загружает signed `profiles`, `class_members` и `children`: профиль сохраняется в отдельный `AppSupabaseAccountProfileBridge`, дети/классы остаются в своих bridge, а онбординг показывает `Smoke Parent`, `Smoke Child` и `QA-3B-2026` перед выбором статуса; `xcodebuild build` прошел, точечный UI-тест `testOnboardingSupabaseHandoffUnlocksRoleAndClassStep` прошел |
| 2026-07-10 | Supabase signed announcements bridge | Пройдено | 4 | `SchoolApp/Models/SampleData.swift`, `SchoolApp/App/AppView.swift`, `SchoolApp/Features/ClassRoom/ClassRoomView.swift`, `SchoolApp/Features/More/MoreView.swift`, `SchoolAppUITests/SchoolAppUITests.swift`, `docs/supabase/test_backend_plan.md`, `.build/SupabaseAnnouncementBridgeUITest-2.xcresult` | Добавлен signed probe `GET /announcements` по сохраненным Supabase-классам с preview `announcement_reads`; результат маппится в отдельный bridge и показывается в ленте класса как безопасное превью, не заменяя локальные объявления; `xcodebuild build` прошел, точечный UI-тест `testSupabaseAnnouncementBridgeShowsInClassFeedPreview` прошел |
| 2026-07-10 | Supabase announcement read ack gate | Пройдено | 4 | `SchoolApp/Models/SampleData.swift`, `SchoolApp/Features/More/MoreView.swift`, `SchoolAppUITests/SchoolAppUITests.swift`, `supabase/migrations/20260710143000_tighten_announcement_reads_insert_rls.sql`, `supabase/tests/rls_write_smoke.sql`, `docs/supabase/test_backend_plan.md`, `.build/SupabaseAnnouncementReadAckOnlyUITest.xcresult` | Добавлен signed `POST /announcement_reads` gate в Sync Center: без client key/session действие блокируется до сети, успешный или duplicate ответ помечает Supabase announcement bridge прочитанным; RLS ужесточен так, что родитель может отметить прочитанным только объявление своего класса, SQL-smoke в тестовом Supabase прошел |
| 2026-07-10 | Supabase signed homework bridge | Пройдено | 4 | `SchoolApp/Models/SampleData.swift`, `SchoolApp/App/AppView.swift`, `SchoolApp/Features/Homework/HomeworkView.swift`, `SchoolApp/Features/More/MoreView.swift`, `SchoolAppUITests/SchoolAppUITests.swift`, `docs/supabase/test_backend_plan.md`, `.build/SupabaseHomeworkBridgeUITest.xcresult` | Добавлен отдельный bridge для Supabase-ДЗ и signed probe `GET /homework_items` по сохраненному class bridge; экран ДЗ показывает Supabase-preview отдельно от локального списка, чтобы не заменить рабочие локальные ДЗ до полного repository switch; `xcodebuild build` прошел, точечный UI-тест `testSupabaseHomeworkBridgeShowsWithoutReplacingLocalHomework` прошел |
| 2026-07-10 | Supabase signed calendar bridge | Пройдено | 4 | `SchoolApp/Models/SampleData.swift`, `SchoolApp/App/AppView.swift`, `SchoolApp/Features/Calendar/CalendarView.swift`, `SchoolApp/Features/More/MoreView.swift`, `SchoolAppUITests/SchoolAppUITests.swift`, `docs/supabase/test_backend_plan.md`, `.build/SupabaseCalendarBridgeUITest.xcresult` | Добавлен отдельный bridge для Supabase-событий и signed probe `GET /calendar_events` по сохраненному class bridge; экран календаря показывает Supabase-preview отдельно от локального списка, чтобы не заменить рабочие локальные события до полного repository switch; `xcodebuild build` прошел, точечный UI-тест `testSupabaseCalendarBridgeShowsWithoutReplacingLocalEvents` прошел |
| 2026-07-10 | Supabase signed collections bridge | Пройдено | 4 | `SchoolApp/Models/SampleData.swift`, `SchoolApp/App/AppView.swift`, `SchoolApp/Features/ClassRoom/ClassRoomView.swift`, `SchoolApp/Features/More/MoreView.swift`, `SchoolAppUITests/SchoolAppUITests.swift`, `docs/supabase/test_backend_plan.md`, `.build/SupabaseCollectionsBridgeUITest.xcresult` | Добавлен отдельный bridge для Supabase-сборов и signed probe `GET /collections` по сохраненному class bridge; раздел сборов показывает Supabase-preview отдельно от локального списка, а родителю не выдает права создавать сборы; `xcodebuild build` прошел, точечный UI-тест `testSupabaseCollectionBridgeShowsWithoutGrantingParentManageRights` прошел |
| 2026-07-10 | Supabase signed photos bridge | Пройдено | 4 | `SchoolApp/Models/SampleData.swift`, `SchoolApp/App/AppView.swift`, `SchoolApp/Features/ClassRoom/ClassRoomView.swift`, `SchoolApp/Features/More/MoreView.swift`, `SchoolAppUITests/SchoolAppUITests.swift`, `docs/supabase/test_backend_plan.md`, `.build/SupabasePhotosBridgeUITest.xcresult` | Добавлен отдельный bridge для Supabase-фото и signed probe `GET /class_photos` по сохраненному class bridge; раздел фото показывает Supabase-preview отдельно от локальных альбомов, а родителю не выдает права создавать альбомы или удалять фото; `xcodebuild build` прошел, точечный UI-тест `testSupabasePhotoBridgeShowsWithoutGrantingParentDeleteRights` прошел |
| 2026-07-10 | Supabase signed sync_mutations write gate | Пройдено | 4 | `SchoolApp/Features/More/MoreView.swift`, `SchoolAppUITests/SchoolAppUITests.swift`, `docs/project_checklist.md`, `docs/supabase/test_backend_plan.md`, `.build/SupabaseSyncMutationWriteUITest-4.xcresult` | В Sync Center добавлен signed `POST /sync_mutations` gate: приложение строит idempotent `mutation_id` для QA-мутации, пишет только с client key, user bearer, user id и class bridge, а RLS должен подтвердить `user_id = auth.uid()` плюс class membership; без ключей/сессии запрос блокируется до сети; кнопка перенесена внутрь карточки проверки; `xcodebuild build` прошел, точечный UI-тест `testSupabaseSyncMutationWriteBlocksBeforeClientKey` прошел |
| 2026-07-10 | Supabase collection payment write gate | Пройдено | 4 | `SchoolApp/Features/More/MoreView.swift`, `SchoolAppUITests/SchoolAppUITests.swift`, `docs/project_checklist.md`, `docs/supabase/test_backend_plan.md`, `.build/SupabaseCollectionPaymentWriteUITest.xcresult` | В Sync Center добавлен signed `POST /collection_payments` gate для родительской оплаты сбора: запись требует client key, user bearer, user id, child bridge и collection bridge; `is_confirmed` остается `false`, чтобы родитель не получал права родкомитета; сумма из UI приводится к numeric payload; без ключей/сессии запрос блокируется до сети; `xcodebuild build` прошел, точечный UI-тест `testSupabaseCollectionPaymentWriteBlocksBeforeClientKey` прошел |
| 2026-07-10 | Supabase collection expense write gate | Пройдено | 4 | `SchoolApp/Features/More/MoreView.swift`, `SchoolAppUITests/SchoolAppUITests.swift`, `docs/project_checklist.md`, `docs/supabase/test_backend_plan.md`, `.build/SupabaseCollectionExpenseWriteUITest.xcresult` | В Sync Center добавлен signed `POST /collection_expenses` gate для расхода сбора: тело содержит `collection_id`, `author_user_id`, title и amount, а право записи остается за RLS `can_manage_class`; родительский сценарий не получает этот доступ, receipt file metadata остается за отдельным signed upload/class_files шагом; без client key/session запрос блокируется до сети; `xcodebuild build` прошел, точечный UI-тест `testSupabaseCollectionExpenseWriteBlocksBeforeClientKey` прошел |
| 2026-07-10 | Supabase class_files metadata write gate | Пройдено | 4 | `SchoolApp/Features/More/MoreView.swift`, `SchoolAppUITests/SchoolAppUITests.swift`, `docs/project_checklist.md`, `docs/supabase/test_backend_plan.md`, `.build/SupabaseClassFileMetadataWriteUITest-2.xcresult` | В Sync Center добавлен signed `POST /class_files` gate для метаданных будущего чека или фото: тело содержит `class_id`, `owner_user_id`, `kind`, private bucket/object path, имя, MIME type и размер, а RLS проверяет signed class membership; без client key/session/user id/class bridge запрос блокируется до сети; `xcodebuild build` прошел, точечный UI-тест `testSupabaseClassFileMetadataWriteBlocksBeforeClientKey` прошел |
| 2026-07-10 | Supabase class_photos metadata write gate | Пройдено | 4 | `SchoolApp/Models/SampleData.swift`, `SchoolApp/App/AppView.swift`, `SchoolApp/Features/More/MoreView.swift`, `SchoolAppUITests/SchoolAppUITests.swift`, `docs/project_checklist.md`, `docs/supabase/test_backend_plan.md`, `.build/SupabaseClassPhotoMetadataWriteUITest.xcresult` | В Sync Center добавлен signed `POST /class_photos` gate: приложение связывает существующий `class_files.id` с фотоальбомом через `class_id`, `author_user_id`, `file_id` и caption, а RLS проверяет signed class membership; добавлен отдельный local bridge/QA-seed для Supabase `class_files`, чтобы фото-запись не зависела от локального UI; без client key/session/user id/class bridge/file bridge запрос блокируется до сети; `xcodebuild build` прошел, точечный UI-тест `testSupabaseClassPhotoMetadataWriteBlocksBeforeClientKey` прошел |
