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

    func testBehaviorQAGateListsCriticalInvariants() {
        let app = launchApp(arguments: ["-qa-tab", "more", "-qa-more-behavior"])

        XCTAssertTrue(app.navigationBars["Behavior QA"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["Критичные инварианты"].exists)
        XCTAssertTrue(app.staticTexts["Родительские права"].exists)
        XCTAssertTrue(app.staticTexts["Детский режим"].exists)
        XCTAssertTrue(app.staticTexts["Следующий уровень автоматизации"].exists)
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
        XCTAssertTrue(firstLaunch.buttons["announcement.acknowledged"].waitForExistence(timeout: 4))

        firstLaunch.terminate()

        let secondLaunch = launchApp(arguments: [
            "-qa-role", "parent",
            "-qa-tab", "classRoom",
            "-qa-announcement-detail"
        ])

        XCTAssertTrue(secondLaunch.navigationBars["Объявление"].waitForExistence(timeout: 4))
        XCTAssertTrue(secondLaunch.staticTexts["Прочтение подтверждено"].exists)
        XCTAssertTrue(secondLaunch.buttons["announcement.acknowledged"].exists)
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
}
