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

    private func launchApp(arguments: [String]) -> XCUIApplication {
        let app = XCUIApplication(bundleIdentifier: bundleIdentifier)
        app.launchArguments = arguments + ["-qa-skip-onboarding"]
        app.launch()
        return app
    }
}
