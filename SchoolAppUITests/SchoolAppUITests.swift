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

        firstLaunch.buttons["Добавить тестовое событие"].tap()
        XCTAssertTrue(firstLaunch.staticTexts["qa_smoke_passed"].waitForExistence(timeout: 4))
        firstLaunch.navigationBars["Метрики"].buttons["Закрыть"].tap()
        firstLaunch.terminate()

        let secondLaunch = launchApp(arguments: [
            "-qa-tab", "more",
            "-qa-more-metrics"
        ])

        XCTAssertTrue(secondLaunch.navigationBars["Метрики"].waitForExistence(timeout: 4))
        XCTAssertTrue(secondLaunch.staticTexts["qa_smoke_passed"].waitForExistence(timeout: 4))
        XCTAssertTrue(secondLaunch.staticTexts["Локальная проверка ключевого сценария"].exists)
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
        XCTAssertTrue(findStaticText("verified", in: app))
        XCTAssertTrue(findStaticText("private", in: app))
        XCTAssertTrue(findStaticText(containing: "tlhjwfauddueioatkahm", in: app))
        XCTAssertTrue(findStaticText("Live REST probe", in: app))
        XCTAssertTrue(findStaticText(containing: "GET /class_rooms", in: app))

        let readinessButton = app.buttons["sync.supabase-readiness"]
        scrollUntilVisible(readinessButton, in: app)
        XCTAssertTrue(readinessButton.waitForExistence(timeout: 4))
        readinessButton.tap()

        XCTAssertTrue(findStaticText(containing: "SUPABASE_ANON_KEY", in: app))

        let liveProbeButton = app.buttons["sync.supabase-live-probe"]
        scrollUntilVisible(liveProbeButton, in: app)
        XCTAssertTrue(liveProbeButton.waitForExistence(timeout: 4))
        liveProbeButton.tap()

        XCTAssertTrue(findStaticText(containing: "Live URLSession request is intentionally blocked", in: app))
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
