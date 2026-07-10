import XCTest

final class SchoolAppUITests: XCTestCase {
    private let bundleIdentifier = "ru.codex.schoolclass"

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testChildModeShowsOnlyChildTabs() {
        let app = launchApp(arguments: ["-qa-role", "child", "-qa-tab", "today"])

        XCTAssertTrue(app.buttons["tab.today"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.buttons["tab.homework"].exists)
        XCTAssertTrue(app.buttons["tab.calendar"].exists)
        XCTAssertFalse(app.buttons["tab.classRoom"].exists)
        XCTAssertFalse(app.buttons["tab.more"].exists)
    }

    func testParentCannotCreateClassCollection() {
        let app = launchApp(arguments: ["-qa-role", "parent", "-qa-tab", "classRoom"])

        XCTAssertTrue(app.buttons["class.section.collections"].waitForExistence(timeout: 4))
        app.buttons["class.section.collections"].tap()

        XCTAssertTrue(app.staticTexts["Вы вошли как родитель"].waitForExistence(timeout: 4))
        XCTAssertFalse(app.buttons["Создать сбор"].exists)
    }

    func testParentCannotManageCollectionStatusOrReceipts() {
        let app = launchApp(arguments: [
            "-qa-role", "parent",
            "-qa-tab", "classRoom",
            "-qa-collection-detail"
        ])

        XCTAssertTrue(app.navigationBars["Сбор"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["Общий счетчик закрыт"].exists)
        XCTAssertTrue(app.staticTexts["Его меняет родкомитет после подтверждения оплаты"].exists)
        XCTAssertTrue(app.buttons["Сохранить мою оплату"].exists)
        XCTAssertFalse(app.steppers.element.exists)
        XCTAssertFalse(app.staticTexts["Подтверждено родкомитетом"].exists)
        XCTAssertFalse(app.buttons["Добавить расход"].exists)
        XCTAssertFalse(app.buttons["Фото чека"].exists)
        XCTAssertFalse(app.buttons["Файл"].exists)
    }

    func testParentCannotPublishAnnouncement() {
        let app = launchApp(arguments: [
            "-qa-role", "parent",
            "-qa-tab", "classRoom",
            "-qa-announcement-add"
        ])

        XCTAssertTrue(app.navigationBars["Нет прав"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["Публикация закрыта"].exists)
        XCTAssertTrue(app.staticTexts["Доступ ограничен"].exists)
        XCTAssertFalse(app.buttons["Опубликовать"].exists)
    }

    func testParentCannotInviteClassMembers() {
        let app = launchApp(arguments: [
            "-qa-role", "parent",
            "-qa-tab", "classRoom",
            "-qa-member-invite"
        ])

        XCTAssertTrue(app.navigationBars["Нет прав"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["Приглашения закрыты"].exists)
        XCTAssertTrue(app.staticTexts["Доступ ограничен"].exists)
        XCTAssertFalse(app.buttons["Добавить приглашение"].exists)
    }

    func testParentCannotDeleteClassPhotos() {
        let app = launchApp(arguments: [
            "-qa-role", "parent",
            "-qa-tab", "classRoom",
            "-qa-photo-viewer"
        ])

        XCTAssertTrue(app.buttons["Скачать"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Поделиться"].exists)
        XCTAssertTrue(app.buttons["Жалоба"].exists)
        XCTAssertTrue(app.staticTexts["Удаляет учитель или родкомитет"].exists)
        XCTAssertFalse(app.buttons["Удалить"].exists)
    }

    func testBehaviorQAGateListsCriticalInvariants() {
        let app = launchApp(arguments: ["-qa-tab", "more", "-qa-more-behavior"])

        XCTAssertTrue(app.navigationBars["Behavior QA"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["Критичные инварианты"].exists)
        XCTAssertTrue(app.staticTexts["Родительские права"].exists)
        XCTAssertTrue(app.staticTexts["Детский режим"].exists)
        XCTAssertTrue(app.staticTexts["Следующий уровень автоматизации"].exists)
    }

    func testOnboardingSupabaseEmailRequiresSuccessfulAuthBeforeRoleStep() {
        let app = XCUIApplication(bundleIdentifier: bundleIdentifier)
        app.launchArguments = [
            "-qa-reset-onboarding",
            "-qa-onboarding",
            "-qa-onboarding-supabase-email"
        ]
        app.launch()

        XCTAssertTrue(app.staticTexts["Вход"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["Email"].exists)
        XCTAssertTrue(findStaticText("Войдите через Supabase Auth, чтобы связать аккаунт с backend.", in: app))
        XCTAssertTrue(app.buttons["Войти через Supabase"].exists)
        XCTAssertTrue(app.staticTexts["Сначала войдите в аккаунт"].exists)
        XCTAssertFalse(app.staticTexts["Ваш статус"].exists)
        XCTAssertTrue(app.buttons["Сначала подтвердите аккаунт"].exists)
    }

    func testOnboardingSupabaseHandoffUnlocksRoleAndClassStep() {
        let app = XCUIApplication(bundleIdentifier: bundleIdentifier)
        app.launchArguments = [
            "-qa-reset-onboarding",
            "-qa-reset-children-store",
            "-qa-onboarding",
            "-qa-onboarding-supabase-email",
            "-qa-onboarding-supabase-handoff-ready"
        ]
        app.launch()

        XCTAssertTrue(app.staticTexts["Вход"].waitForExistence(timeout: 4))
        XCTAssertTrue(findStaticText(containing: "Supabase Auth подключен, профиль: Smoke Parent", in: app))
        XCTAssertTrue(findStaticText(containing: "детей: 1, классов: 1", in: app))
        XCTAssertTrue(findStaticText(containing: "Smoke Child, 3Б -> QA-3B-2026", in: app))
        XCTAssertTrue(app.staticTexts["Ваш статус"].exists)
        XCTAssertTrue(app.staticTexts["Создать комнату класса"].exists || app.buttons["Создать комнату класса"].exists)
        XCTAssertFalse(app.buttons["Сначала подтвердите аккаунт"].exists)
    }

    func testMvpMetricsEventPersistsAfterRelaunch() {
        let firstLaunch = launchApp(arguments: [
            "-qa-reset-more-store",
            "-qa-tab", "more",
            "-qa-more-metrics"
        ])

        XCTAssertTrue(firstLaunch.navigationBars["Метрики"].waitForExistence(timeout: 4))
        XCTAssertTrue(firstLaunch.staticTexts["Главные метрики"].exists)
        XCTAssertTrue(firstLaunch.staticTexts["Активация класса"].exists)
        XCTAssertTrue(firstLaunch.staticTexts["Retention 30 дней"].exists)

        firstLaunch.buttons["metrics.add-test-event"].tap()
        XCTAssertTrue(firstLaunch.staticTexts["metrics.latest-event.qa_smoke_passed"].waitForExistence(timeout: 4))
        firstLaunch.navigationBars["Метрики"].buttons["Закрыть"].tap()
        firstLaunch.terminate()

        let secondLaunch = launchApp(arguments: [
            "-qa-tab", "more",
            "-qa-more-metrics"
        ])

        XCTAssertTrue(secondLaunch.navigationBars["Метрики"].waitForExistence(timeout: 4))
        XCTAssertTrue(findStaticText("metrics.latest-event.qa_smoke_passed", in: secondLaunch, attempts: 6))
        XCTAssertTrue(findStaticText("Локальная проверка ключевого сценария", in: secondLaunch, attempts: 3))
    }

    func testSyncNetworkErrorKeepsQueuedMutation() {
        let app = launchApp(arguments: [
            "-qa-tab", "more",
            "-qa-more-sync",
            "-qa-more-sync-network-error"
        ])

        XCTAssertTrue(app.navigationBars["Синхронизация"].waitForExistence(timeout: 4))
        XCTAssertTrue(findStaticText("Ошибки сети и повтор", in: app))
        XCTAssertTrue(findStaticText(containing: "Пользовательские данные не теряются", in: app))
        XCTAssertTrue(findStaticText("Retry 1/5", in: app))
        XCTAssertTrue(findStaticText(containing: "Timeout-сценарий", in: app))

        let networkErrorButton = app.buttons["sync.simulate-network-error"]
        scrollUntilVisible(networkErrorButton, in: app)
        XCTAssertTrue(networkErrorButton.waitForExistence(timeout: 4))
        networkErrorButton.tap()

        XCTAssertTrue(findStaticText("Retry 1/5", in: app))
        XCTAssertTrue(findStaticText(containing: "данные сохранены локально", in: app))
    }

    func testSupabaseReadinessShowsSchemaAndMissingKeyGate() {
        let app = launchApp(arguments: [
            "-qa-tab", "more",
            "-qa-more-sync",
            "-qa-more-sync-supabase"
        ])

        XCTAssertTrue(app.navigationBars["Синхронизация"].waitForExistence(timeout: 4))
        XCTAssertTrue(findStaticText("Supabase test backend", in: app))
        XCTAssertTrue(findStaticText("key missing", in: app))
        XCTAssertTrue(findStaticText(containing: "tlhjwfauddueioatkahm", in: app))

        let readinessButton = app.buttons["sync.supabase-readiness"]
        scrollUntilVisible(readinessButton, in: app)
        XCTAssertTrue(readinessButton.waitForExistence(timeout: 4))
        readinessButton.tap()

        XCTAssertTrue(findStaticText(containing: "SUPABASE_PUBLISHABLE_KEY", in: app))
        XCTAssertTrue(findStaticText(containing: "SUPABASE_ANON_KEY", in: app))

        let authSessionButton = app.buttons["sync.supabase-auth-session"]
        scrollUntilVisible(authSessionButton, in: app)
        XCTAssertTrue(authSessionButton.waitForExistence(timeout: 4))
        authSessionButton.tap()

        XCTAssertTrue(findStaticText(containing: "SUPABASE_ACCESS_TOKEN", in: app))

        XCTAssertTrue(findStaticText("Password sign-in probe", in: app))
        let passwordSignInButton = app.buttons["sync.supabase-password-sign-in"]
        scrollUntilVisible(passwordSignInButton, in: app)
        XCTAssertTrue(passwordSignInButton.waitForExistence(timeout: 4))
        passwordSignInButton.tap()

        XCTAssertTrue(findStaticText(containing: "network skipped before credentials", in: app))

        let refreshSessionButton = app.buttons["sync.supabase-refresh-session"]
        scrollUntilVisible(refreshSessionButton, in: app)
        XCTAssertTrue(refreshSessionButton.waitForExistence(timeout: 4))
        refreshSessionButton.tap()

        XCTAssertTrue(findStaticText(containing: "client key и SUPABASE_REFRESH_TOKEN", in: app))
        XCTAssertTrue(findStaticText(containing: "missing SUPABASE_PUBLISHABLE_KEY", in: app))

        let signedProfileButton = app.buttons["sync.supabase-signed-profile"]
        scrollUntilVisible(signedProfileButton, in: app)
        XCTAssertTrue(signedProfileButton.waitForExistence(timeout: 4))
        signedProfileButton.tap()

        XCTAssertTrue(findStaticText(containing: "client key, SUPABASE_ACCESS_TOKEN", in: app))
        XCTAssertTrue(findStaticText(containing: "Signed REST request is blocked", in: app))

        XCTAssertTrue(findStaticText("Signed class scope probe", in: app))
        XCTAssertTrue(findStaticText(containing: "/class_members", in: app))
        XCTAssertTrue(findStaticText(containing: "class_rooms", in: app))
        XCTAssertTrue(findStaticText(containing: "Mapped context", in: app))
        XCTAssertTrue(findStaticText(containing: "local children untouched", in: app))

        let signedClassScopeButton = app.buttons["sync.supabase-signed-class-scope"]
        scrollUntilVisible(signedClassScopeButton, in: app, attempts: 8)
        XCTAssertTrue(signedClassScopeButton.waitForExistence(timeout: 4))
        signedClassScopeButton.tap()

        XCTAssertTrue(findStaticText(containing: "signed classes заблокирован", in: app))
        XCTAssertTrue(findStaticText(containing: "Signed class scope request is blocked", in: app))
        XCTAssertTrue(findStaticText(containing: "blocked before mapper", in: app))
        XCTAssertTrue(findStaticText(containing: "Bridge waiting", in: app))

        XCTAssertTrue(findStaticText("Signed children probe", in: app))
        XCTAssertTrue(findStaticText(containing: "/children", in: app))
        XCTAssertTrue(findStaticText(containing: "parent_user_id", in: app))
        XCTAssertTrue(findStaticText(containing: "Mapped child", in: app))
        XCTAssertTrue(findStaticText(containing: "local selected child untouched", in: app))

        let signedChildrenButton = app.buttons["sync.supabase-signed-children"]
        scrollUntilVisible(signedChildrenButton, in: app, attempts: 8)
        XCTAssertTrue(signedChildrenButton.waitForExistence(timeout: 4))
        signedChildrenButton.tap()

        XCTAssertTrue(findStaticText(containing: "signed children заблокирован", in: app))
        XCTAssertTrue(findStaticText(containing: "Signed children request is blocked", in: app))
        XCTAssertTrue(findStaticText(containing: "blocked before child mapper", in: app))
        XCTAssertTrue(findStaticText(containing: "Child bridge waiting", in: app))

        let liveProbeButton = app.buttons["sync.supabase-live-probe"]
        scrollUntilVisible(liveProbeButton, in: app)
        XCTAssertTrue(liveProbeButton.waitForExistence(timeout: 4))
        liveProbeButton.tap()

        XCTAssertTrue(findStaticText(containing: "Live URLSession request is intentionally blocked", in: app))
    }

    func testSupabaseAnnouncementReadAckBlocksBeforeClientKey() {
        let app = launchApp(arguments: [
            "-qa-seed-supabase-announcement-bridge",
            "-qa-tab", "more",
            "-qa-more-sync",
            "-qa-more-sync-supabase"
        ])

        XCTAssertTrue(app.navigationBars["Синхронизация"].waitForExistence(timeout: 4))
        XCTAssertTrue(findStaticText("Announcement read ack", in: app, attempts: 8))
        XCTAssertTrue(findStaticText(containing: "/announcement_reads", in: app, attempts: 8))
        XCTAssertTrue(findStaticText(containing: "Signed announcement read ack is blocked", in: app, attempts: 8))
        XCTAssertTrue(findStaticText(containing: "Supabase: форма на физкультуру", in: app, attempts: 8))

        let announcementReadAckButton = app.buttons["sync.supabase-announcement-read-ack"]
        scrollUntilVisible(announcementReadAckButton, in: app, attempts: 8)
        XCTAssertTrue(announcementReadAckButton.waitForExistence(timeout: 4))
    }

    func testSupabaseSyncMutationWriteBlocksBeforeClientKey() {
        let app = launchApp(arguments: [
            "-qa-seed-supabase-class-bridge",
            "-qa-tab", "more",
            "-qa-more-sync",
            "-qa-more-sync-supabase"
        ])

        XCTAssertTrue(findStaticText("Sync mutation write", in: app, attempts: 10))
        XCTAssertTrue(findStaticText(containing: "/sync_mutations", in: app, attempts: 10))
        XCTAssertTrue(findStaticText(containing: "Signed sync mutation write is blocked", in: app, attempts: 10))

        let writeButton = app.buttons["sync.supabase-sync-mutation-write"]
        scrollUntilVisible(writeButton, in: app, attempts: 10)
        XCTAssertTrue(writeButton.waitForExistence(timeout: 4))
        writeButton.tap()

        XCTAssertTrue(findStaticText(containing: "sync mutation заблокирована", in: app, attempts: 6))
        XCTAssertTrue(findStaticText(containing: "no mutation built", in: app, attempts: 6))
    }

    func testSupabaseCollectionPaymentWriteBlocksBeforeClientKey() {
        let app = launchApp(arguments: [
            "-qa-seed-supabase-child-bridge",
            "-qa-seed-supabase-collection-bridge",
            "-qa-tab", "more",
            "-qa-more-sync",
            "-qa-more-sync-supabase"
        ])

        XCTAssertTrue(findStaticText("Collection payment write", in: app, attempts: 10))
        XCTAssertTrue(findStaticText(containing: "/collection_payments", in: app, attempts: 10))
        XCTAssertTrue(findStaticText(containing: "Signed collection payment write is blocked", in: app, attempts: 10))
        XCTAssertTrue(findStaticText(containing: "Supabase: сбор на театр", in: app, attempts: 6))
        XCTAssertTrue(findStaticText(containing: "Smoke Child", in: app, attempts: 6))

        let writeButton = app.buttons["sync.supabase-collection-payment-write"]
        scrollUntilVisible(writeButton, in: app, attempts: 10)
        XCTAssertTrue(writeButton.waitForExistence(timeout: 4))
        writeButton.tap()

        XCTAssertTrue(findStaticText(containing: "collection payment заблокирован", in: app, attempts: 6))
    }

    func testSupabaseCollectionExpenseWriteBlocksBeforeClientKey() {
        let app = launchApp(arguments: [
            "-qa-seed-supabase-collection-bridge",
            "-qa-tab", "more",
            "-qa-more-sync",
            "-qa-more-sync-supabase"
        ])

        XCTAssertTrue(findStaticText("Collection expense write", in: app, attempts: 10))
        XCTAssertTrue(findStaticText(containing: "/collection_expenses", in: app, attempts: 10))
        XCTAssertTrue(findStaticText(containing: "Signed collection expense write is blocked", in: app, attempts: 10))
        XCTAssertTrue(findStaticText(containing: "Supabase: сбор на театр", in: app, attempts: 6))

        let writeButton = app.buttons["sync.supabase-collection-expense-write"]
        scrollUntilVisible(writeButton, in: app, attempts: 10)
        XCTAssertTrue(writeButton.waitForExistence(timeout: 4))
        writeButton.tap()

        XCTAssertTrue(findStaticText(containing: "collection expense заблокирован", in: app, attempts: 6))
    }

    func testSupabaseClassFileMetadataWriteBlocksBeforeClientKey() {
        let app = launchApp(arguments: [
            "-qa-seed-supabase-class-bridge",
            "-qa-tab", "more",
            "-qa-more-sync",
            "-qa-more-sync-supabase"
        ])

        XCTAssertTrue(findStaticText("Class file metadata write", in: app, attempts: 10))
        XCTAssertTrue(findStaticText(containing: "/class_files", in: app, attempts: 10))
        XCTAssertTrue(findStaticText(containing: "Signed class file metadata write is blocked", in: app, attempts: 10))

        let writeButton = app.buttons["sync.supabase-class-file-metadata-write"]
        scrollUntilVisible(writeButton, in: app, attempts: 10)
        XCTAssertTrue(writeButton.waitForExistence(timeout: 4))
        writeButton.tap()

        XCTAssertTrue(findStaticText(containing: "class file metadata заблокирован", in: app, attempts: 6))
    }

    func testSupabaseStoredSeedSessionCanBeClearedAfterRelaunch() {
        let firstLaunch = launchApp(arguments: [
            "-qa-reset-supabase-session-store",
            "-qa-seed-supabase-session-store",
            "-qa-tab", "more",
            "-qa-more-sync",
            "-qa-more-sync-supabase"
        ])

        XCTAssertTrue(firstLaunch.navigationBars["Синхронизация"].waitForExistence(timeout: 4))
        XCTAssertTrue(findStaticText("Stored seed session", in: firstLaunch))
        XCTAssertTrue(findStaticText(containing: "source: keychain seed session", in: firstLaunch))
        XCTAssertTrue(findStaticText(containing: "access qa-acc...0000", in: firstLaunch))
        XCTAssertTrue(findStaticText(containing: "user qa-user-0000", in: firstLaunch))

        let authSessionButton = firstLaunch.buttons["sync.supabase-auth-session"]
        scrollUntilVisible(authSessionButton, in: firstLaunch, attempts: 8)
        XCTAssertTrue(authSessionButton.waitForExistence(timeout: 4))
        authSessionButton.tap()
        XCTAssertTrue(findStaticText(containing: "Bearer qa-acc...0000", in: firstLaunch))

        let clearButton = firstLaunch.buttons["sync.supabase-session-clear"]
        scrollUntilVisible(clearButton, in: firstLaunch, attempts: 8)
        XCTAssertTrue(clearButton.waitForExistence(timeout: 4))
        clearButton.tap()

        XCTAssertTrue(findStaticText(containing: "Stored seed session очищена", in: firstLaunch))
        XCTAssertTrue(findStaticText(containing: "Keychain session store empty", in: firstLaunch))
        firstLaunch.terminate()

        let secondLaunch = launchApp(arguments: [
            "-qa-tab", "more",
            "-qa-more-sync",
            "-qa-more-sync-supabase"
        ])

        XCTAssertTrue(secondLaunch.navigationBars["Синхронизация"].waitForExistence(timeout: 4))
        XCTAssertTrue(findStaticText(containing: "Keychain session store empty", in: secondLaunch))
        XCTAssertTrue(findStaticText(containing: "missing SUPABASE_ACCESS_TOKEN", in: secondLaunch))
    }

    func testSelectedChildPersistsAcrossTabsAndChangesClassContext() {
        let app = launchApp(arguments: [
            "-qa-reset-children-store",
            "-qa-role", "parent",
            "-qa-tab", "today"
        ])

        XCTAssertTrue(app.staticTexts["Миша, 3Б"].waitForExistence(timeout: 4))
        selectChild(named: "Аня", className: "4А", in: app)

        app.buttons["tab.classRoom"].tap()

        XCTAssertTrue(app.staticTexts["Класс 4А"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["Аня: родкомитет, код 4A-1254"].exists)
        XCTAssertTrue(app.buttons["class.section.collections"].exists)
        app.buttons["class.section.collections"].tap()
        XCTAssertTrue(app.buttons["Создать сбор"].waitForExistence(timeout: 4))
    }

    func testSupabaseClassBridgeShowsWithoutReplacingSelectedChild() {
        let app = launchApp(arguments: [
            "-qa-reset-children-store",
            "-qa-seed-supabase-class-bridge",
            "-qa-role", "parent",
            "-qa-tab", "today"
        ])

        XCTAssertTrue(app.staticTexts["Миша, 3Б"].waitForExistence(timeout: 4))
        XCTAssertTrue(findStaticText(containing: "Supabase готов: QA-3B-2026", in: app))
        XCTAssertTrue(findStaticText(containing: "роль Родитель", in: app))

        app.buttons["tab.classRoom"].tap()

        XCTAssertTrue(app.staticTexts["Класс 3Б"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["Миша: родитель, код 3B-1254"].exists)
        XCTAssertTrue(findStaticText(containing: "Supabase готов: QA-3B-2026", in: app))
    }

    func testSupabaseChildBridgeShowsWithoutReplacingSelectedChild() {
        let app = launchApp(arguments: [
            "-qa-reset-children-store",
            "-qa-seed-supabase-child-bridge",
            "-qa-role", "parent",
            "-qa-tab", "today"
        ])

        XCTAssertTrue(app.staticTexts["Миша, 3Б"].waitForExistence(timeout: 4))
        XCTAssertTrue(findStaticText(containing: "Supabase ребенок готов: Smoke Child", in: app))
        XCTAssertTrue(findStaticText(containing: "QA-3B-2026", in: app))

        app.buttons["tab.classRoom"].tap()

        XCTAssertTrue(app.staticTexts["Класс 3Б"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["Миша: родитель, код 3B-1254"].exists)
        XCTAssertTrue(findStaticText(containing: "Supabase ребенок готов: Smoke Child", in: app))
    }

    func testSupabaseAnnouncementBridgeShowsInClassFeedPreview() {
        let app = launchApp(arguments: [
            "-qa-reset-children-store",
            "-qa-seed-supabase-class-bridge",
            "-qa-seed-supabase-announcement-bridge",
            "-qa-role", "parent",
            "-qa-tab", "classRoom"
        ])

        XCTAssertTrue(app.staticTexts["Класс 3Б"].waitForExistence(timeout: 4))
        XCTAssertTrue(findStaticText(containing: "Supabase объявление: Supabase: форма на физкультуру", in: app))
        XCTAssertTrue(findStaticText("Supabase объявления", in: app))
        XCTAssertTrue(findStaticText(containing: "Announcement bridge ready: 1 item", in: app))
        XCTAssertTrue(findStaticText("Supabase: форма на физкультуру", in: app))
        XCTAssertTrue(findStaticText("Не прочитано", in: app))
    }

    func testSupabaseHomeworkBridgeShowsWithoutReplacingLocalHomework() {
        let app = launchApp(arguments: [
            "-qa-reset-children-store",
            "-qa-reset-homework-store",
            "-qa-seed-supabase-class-bridge",
            "-qa-seed-supabase-homework-bridge",
            "-qa-role", "parent",
            "-qa-tab", "homework"
        ])

        XCTAssertTrue(app.staticTexts["Домашка"].waitForExistence(timeout: 4))
        XCTAssertTrue(findStaticText("Supabase ДЗ", in: app))
        XCTAssertTrue(findStaticText(containing: "Supabase ДЗ: Математика: Supabase: страница 45", in: app))
        XCTAssertTrue(findStaticText(containing: "Homework bridge ready: 1 item", in: app))
        XCTAssertTrue(app.staticTexts["homework.subject.Математика"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["homework.title.№ 47, 48 (с. 78)"].exists)
    }

    func testSupabaseCalendarBridgeShowsWithoutReplacingLocalEvents() {
        let app = launchApp(arguments: [
            "-qa-reset-children-store",
            "-qa-reset-calendar-store",
            "-qa-seed-supabase-class-bridge",
            "-qa-seed-supabase-calendar-event-bridge",
            "-qa-role", "parent",
            "-qa-tab", "calendar"
        ])

        XCTAssertTrue(app.staticTexts["Календарь"].waitForExistence(timeout: 4))
        XCTAssertTrue(findStaticText("Supabase события", in: app))
        XCTAssertTrue(findStaticText(containing: "Supabase событие: Supabase: экскурсия в планетарий", in: app))
        XCTAssertTrue(findStaticText(containing: "Calendar bridge ready: 1 event", in: app))
        XCTAssertTrue(app.staticTexts["calendar.event.title.Экскурсия в музей"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["calendar.event.date.Чт, 9 июля"].exists)
    }

    func testSupabaseCollectionBridgeShowsWithoutGrantingParentManageRights() {
        let app = launchApp(arguments: [
            "-qa-reset-children-store",
            "-qa-seed-supabase-class-bridge",
            "-qa-seed-supabase-collection-bridge",
            "-qa-role", "parent",
            "-qa-tab", "classRoom"
        ])

        XCTAssertTrue(app.buttons["class.section.collections"].waitForExistence(timeout: 4))
        app.buttons["class.section.collections"].tap()

        XCTAssertTrue(findStaticText("Supabase сборы", in: app))
        XCTAssertTrue(findStaticText(containing: "Supabase сбор: Supabase: сбор на театр", in: app))
        XCTAssertTrue(findStaticText(containing: "Collection bridge ready: 1 collection", in: app))
        XCTAssertTrue(findStaticText("Вы вошли как родитель", in: app))
        XCTAssertFalse(app.buttons["Создать сбор"].exists)
        XCTAssertTrue(findStaticText("Театр", in: app))
    }

    func testSupabasePhotoBridgeShowsWithoutGrantingParentDeleteRights() {
        let app = launchApp(arguments: [
            "-qa-reset-children-store",
            "-qa-seed-supabase-class-bridge",
            "-qa-seed-supabase-photo-bridge",
            "-qa-role", "parent",
            "-qa-tab", "classRoom"
        ])

        XCTAssertTrue(app.buttons["class.section.photos"].waitForExistence(timeout: 4))
        app.buttons["class.section.photos"].tap()

        XCTAssertTrue(findStaticText("Supabase фото", in: app))
        XCTAssertTrue(findStaticText(containing: "Supabase фото: Supabase: фото с экскурсии", in: app))
        XCTAssertTrue(findStaticText(containing: "Photo bridge ready: 1 photo", in: app))
        XCTAssertTrue(findStaticText(containing: "Родителю доступны просмотр, скачивание и жалоба", in: app))
        XCTAssertFalse(app.buttons["Создать альбом"].exists)
        XCTAssertTrue(findStaticText("Экскурсии", in: app))
    }

    func testSupabaseChildSourcePreviewSwitchesSelectedChildContext() {
        let app = launchApp(arguments: [
            "-qa-reset-children-store",
            "-qa-seed-supabase-class-bridge",
            "-qa-seed-supabase-child-bridge",
            "-qa-use-supabase-child-source",
            "-qa-role", "parent",
            "-qa-tab", "today"
        ])

        XCTAssertTrue(app.staticTexts["Smoke Child, 3Б"].waitForExistence(timeout: 4))
        XCTAssertTrue(findStaticText(containing: "Источник: Supabase child bridge preview", in: app))
        XCTAssertTrue(findStaticText(containing: "код QA-3B-2026", in: app))

        app.buttons["tab.classRoom"].tap()

        XCTAssertTrue(app.staticTexts["Класс 3Б"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["Smoke Child: родитель, код QA-3B-2026"].exists)
        XCTAssertTrue(findStaticText(containing: "Источник: Supabase child bridge preview", in: app))
        XCTAssertTrue(findStaticText(containing: "Supabase ребенок готов: Smoke Child", in: app))
    }

    func testSupabaseChildSourceCanBeEnabledFromSyncCenter() {
        let app = launchApp(arguments: [
            "-qa-reset-children-store",
            "-qa-seed-supabase-class-bridge",
            "-qa-seed-supabase-child-bridge",
            "-qa-role", "parent",
            "-qa-tab", "more",
            "-qa-more-sync",
            "-qa-more-sync-supabase"
        ])

        XCTAssertTrue(app.navigationBars["Синхронизация"].waitForExistence(timeout: 4))
        XCTAssertTrue(findStaticText("Supabase child source", in: app, attempts: 8))

        let enableButton = app.buttons["sync.supabase-child-source-enable"]
        scrollUntilVisible(enableButton, in: app, attempts: 8)
        XCTAssertTrue(enableButton.waitForExistence(timeout: 4))
        enableButton.tap()

        app.buttons["Закрыть"].tap()
        app.buttons["tab.today"].tap()

        XCTAssertTrue(app.staticTexts["Smoke Child, 3Б"].waitForExistence(timeout: 4))
        XCTAssertTrue(findStaticText(containing: "код QA-3B-2026", in: app))

        app.buttons["tab.classRoom"].tap()

        XCTAssertTrue(app.staticTexts["Класс 3Б"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["Smoke Child: родитель, код QA-3B-2026"].exists)
    }

    func testSupabaseChildSourcePersistsAndCanReturnLocalAfterRelaunch() {
        let firstLaunch = launchApp(arguments: [
            "-qa-reset-children-store",
            "-qa-seed-supabase-class-bridge",
            "-qa-seed-supabase-child-bridge",
            "-qa-role", "parent",
            "-qa-tab", "more",
            "-qa-more-sync",
            "-qa-more-sync-supabase"
        ])

        XCTAssertTrue(firstLaunch.navigationBars["Синхронизация"].waitForExistence(timeout: 4))
        let enableButton = firstLaunch.buttons["sync.supabase-child-source-enable"]
        scrollUntilVisible(enableButton, in: firstLaunch, attempts: 8)
        XCTAssertTrue(enableButton.waitForExistence(timeout: 4))
        enableButton.tap()
        firstLaunch.terminate()

        let secondLaunch = launchApp(arguments: [
            "-qa-role", "parent",
            "-qa-tab", "today"
        ])

        XCTAssertTrue(secondLaunch.staticTexts["Smoke Child, 3Б"].waitForExistence(timeout: 4))
        XCTAssertTrue(findStaticText(containing: "код QA-3B-2026", in: secondLaunch))
        XCTAssertTrue(findStaticText(containing: "Источник: Supabase child bridge preview", in: secondLaunch))
        secondLaunch.terminate()

        let thirdLaunch = launchApp(arguments: [
            "-qa-role", "parent",
            "-qa-tab", "more",
            "-qa-more-sync",
            "-qa-more-sync-supabase"
        ])

        XCTAssertTrue(thirdLaunch.navigationBars["Синхронизация"].waitForExistence(timeout: 4))
        XCTAssertTrue(findStaticText(containing: "Источник: Supabase child bridge preview", in: thirdLaunch))
        let disableButton = thirdLaunch.buttons["sync.supabase-child-source-disable"]
        scrollUntilVisible(disableButton, in: thirdLaunch, attempts: 8)
        XCTAssertTrue(disableButton.waitForExistence(timeout: 4))
        disableButton.tap()
        thirdLaunch.terminate()

        let fourthLaunch = launchApp(arguments: [
            "-qa-role", "parent",
            "-qa-tab", "today"
        ])

        XCTAssertTrue(fourthLaunch.staticTexts["Миша, 3Б"].waitForExistence(timeout: 4))
        XCTAssertTrue(findStaticText(containing: "код 3B-1254", in: fourthLaunch))
        XCTAssertTrue(findStaticText(containing: "Источник: локальные дети", in: fourthLaunch))
    }

    func testAnnouncementAcknowledgementPersistsAfterRelaunch() {
        let firstLaunch = launchApp(arguments: [
            "-qa-reset-class-store",
            "-qa-role", "parent",
            "-qa-tab", "classRoom",
            "-qa-announcement-detail"
        ])

        XCTAssertTrue(firstLaunch.navigationBars["Объявление"].waitForExistence(timeout: 4))
        XCTAssertTrue(firstLaunch.buttons["announcement.acknowledge"].waitForExistence(timeout: 4))
        firstLaunch.buttons["announcement.acknowledge"].tap()
        XCTAssertTrue(firstLaunch.staticTexts["Прочитано"].waitForExistence(timeout: 4))
        XCTAssertFalse(firstLaunch.buttons["announcement.acknowledge"].exists)

        firstLaunch.terminate()

        let secondLaunch = launchApp(arguments: [
            "-qa-role", "parent",
            "-qa-tab", "classRoom",
            "-qa-announcement-detail"
        ])

        XCTAssertTrue(secondLaunch.navigationBars["Объявление"].waitForExistence(timeout: 4))
        XCTAssertTrue(findStaticText("Прочтение подтверждено", in: secondLaunch))
        XCTAssertTrue(findStaticText("Прочитано", in: secondLaunch))
        XCTAssertFalse(secondLaunch.buttons["announcement.acknowledge"].exists)
    }

    func testCollectionExpensePersistsAfterRelaunch() {
        let firstLaunch = launchApp(arguments: [
            "-qa-reset-class-store",
            "-qa-role", "parentCommittee",
            "-qa-tab", "classRoom",
            "-qa-collection-detail",
            "-qa-scroll-expenses"
        ])

        XCTAssertTrue(firstLaunch.navigationBars["Сбор"].waitForExistence(timeout: 4))
        let addExpenseButton = firstLaunch.buttons["collection.add-expense"]
        XCTAssertTrue(addExpenseButton.waitForExistence(timeout: 5))
        addExpenseButton.tap()
        XCTAssertTrue(firstLaunch.staticTexts["collection.expense.title.Чек за автобус"].waitForExistence(timeout: 4))

        firstLaunch.terminate()

        let secondLaunch = launchApp(arguments: [
            "-qa-role", "parentCommittee",
            "-qa-tab", "classRoom",
            "-qa-collection-detail",
            "-qa-scroll-expenses"
        ])

        XCTAssertTrue(secondLaunch.navigationBars["Сбор"].waitForExistence(timeout: 4))
        XCTAssertTrue(secondLaunch.staticTexts["collection.expense.title.Чек за автобус"].waitForExistence(timeout: 4))
    }

    func testManualHomeworkPersistsAfterRelaunch() {
        let firstLaunch = launchApp(arguments: [
            "-qa-reset-homework-store",
            "-qa-tab", "homework",
            "-qa-homework-add"
        ])

        XCTAssertTrue(firstLaunch.navigationBars["Новое ДЗ"].waitForExistence(timeout: 4))
        XCTAssertTrue(firstLaunch.buttons["homework.save"].waitForExistence(timeout: 4))
        firstLaunch.buttons["homework.save"].tap()
        XCTAssertTrue(firstLaunch.staticTexts["homework.title.Страница 45, номера 6, 7, 8"].waitForExistence(timeout: 4))

        firstLaunch.terminate()

        let secondLaunch = launchApp(arguments: [
            "-qa-tab", "homework"
        ])

        XCTAssertTrue(secondLaunch.staticTexts["Домашка"].waitForExistence(timeout: 4))
        XCTAssertTrue(secondLaunch.staticTexts["homework.subject.Математика"].waitForExistence(timeout: 4))
        XCTAssertTrue(secondLaunch.staticTexts["homework.title.Страница 45, номера 6, 7, 8"].exists)
    }

    func testCalendarEventPersistsAfterRelaunch() {
        let firstLaunch = launchApp(arguments: [
            "-qa-reset-calendar-store",
            "-qa-tab", "calendar",
            "-qa-calendar-add"
        ])

        XCTAssertTrue(firstLaunch.navigationBars["Новое событие"].waitForExistence(timeout: 4))
        let saveButton = firstLaunch.buttons["calendar.event.save"]
        scrollUntilVisible(saveButton, in: firstLaunch)
        XCTAssertTrue(saveButton.waitForExistence(timeout: 4))
        saveButton.tap()
        XCTAssertTrue(firstLaunch.staticTexts["calendar.event.date.Пт, 17 июля, 09:10"].waitForExistence(timeout: 4))

        firstLaunch.terminate()

        let secondLaunch = launchApp(arguments: [
            "-qa-tab", "calendar"
        ])

        XCTAssertTrue(secondLaunch.staticTexts["Календарь"].waitForExistence(timeout: 4))
        XCTAssertTrue(secondLaunch.staticTexts["calendar.event.title.Экскурсия в музей"].waitForExistence(timeout: 4))
        XCTAssertTrue(secondLaunch.staticTexts["calendar.event.date.Пт, 17 июля, 09:10"].exists)
    }

    private func launchApp(arguments: [String]) -> XCUIApplication {
        let app = XCUIApplication(bundleIdentifier: bundleIdentifier)
        app.launchArguments = arguments + ["-qa-skip-onboarding"]
        app.launch()
        return app
    }

    private func scrollUntilVisible(_ element: XCUIElement, in app: XCUIApplication, attempts: Int = 6) {
        for _ in 0..<attempts where !element.isHittable {
            app.swipeUp()
        }
    }

    private func findStaticText(_ label: String, in app: XCUIApplication, attempts: Int = 4) -> Bool {
        let text = app.staticTexts[label]
        if text.exists {
            return true
        }

        for _ in 0..<attempts {
            app.swipeUp()
            if text.exists {
                return true
            }
        }

        return false
    }

    private func findStaticText(containing text: String, in app: XCUIApplication, attempts: Int = 4) -> Bool {
        let predicate = NSPredicate(format: "label CONTAINS[c] %@", text)
        if app.staticTexts.containing(predicate).firstMatch.exists {
            return true
        }

        for _ in 0..<attempts {
            app.swipeUp()
            if app.staticTexts.containing(predicate).firstMatch.exists {
                return true
            }
        }

        return false
    }

    private func selectChild(named name: String, className: String, in app: XCUIApplication) {
        let selector = app.buttons["today.child.selector"]
        let option = app.buttons["today.child.option.\(name).\(className)"].firstMatch

        XCTAssertTrue(selector.waitForExistence(timeout: 4))
        selector.tap()

        if !option.waitForExistence(timeout: 2) {
            selector.tap()
        }

        XCTAssertTrue(option.waitForExistence(timeout: 4))
        option.tap()
    }
}
