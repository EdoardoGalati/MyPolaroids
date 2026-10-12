import XCTest

/// Drives the app through its main screens and writes PNGs to /tmp/ib-shots.
/// Run: xcodebuild test -scheme MyPolaroids -only-testing:MyPolaroidsUITests/ScreenshotTour
final class ScreenshotTour: XCTestCase {
    let dir = "/tmp/ib-shots"

    @MainActor
    func testTour() throws {
        continueAfterFailure = true
        try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)
        let app = XCUIApplication()
        app.launch()
        sleep(2)
        shot(app, "01-cameras")

        // Camera detail
        let row = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Red Now'")).firstMatch
        if row.waitForExistence(timeout: 5) { row.tap() } else { app.cells.firstMatch.tap() }
        sleep(1)
        shot(app, "02-camera-detail")

        let take = app.buttons["Take Shots"]
        if take.waitForExistence(timeout: 3) {
            take.tap(); sleep(1); shot(app, "03-take-shots")
            closeSheet(app)
        }
        let menu = app.navigationBars.firstMatch.buttons.allElementsBoundByIndex.last
        if let menu, menu.exists { menu.tap(); sleep(1); shot(app, "04-detail-menu"); app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.9)).tap(); sleep(1) }
        app.navigationBars.firstMatch.buttons.firstMatch.tap(); sleep(1)

        // Add camera
        tapNavButton(app, index: -1); sleep(1); shot(app, "05-add-camera")
        let model = app.cells.element(boundBy: 0)
        if model.waitForExistence(timeout: 3) { model.tap(); sleep(1); shot(app, "06-add-camera-customize") }
        closeSheet(app)

        // Settings
        tapNavButton(app, index: 0); sleep(1); shot(app, "07-settings")
        closeSheet(app)

        // Film tab
        app.tabBars.firstMatch.buttons["Film"].tap(); sleep(1); shot(app, "08-film")
        let filmRow = app.cells.firstMatch
        if filmRow.waitForExistence(timeout: 3) { filmRow.tap(); sleep(1); shot(app, "09-film-detail") }
        let quick = app.buttons.matching(NSPredicate(format: "label CONTAINS 'shots'")).firstMatch
        if quick.exists { quick.tap(); sleep(1); shot(app, "10-quick-edit"); closeSheet(app) }
        app.navigationBars.firstMatch.buttons.firstMatch.tap(); sleep(1)

        // Add film
        tapNavButton(app, index: -1); sleep(1); shot(app, "11-add-film")
        let fmt = app.cells.firstMatch
        if fmt.waitForExistence(timeout: 3) { fmt.tap(); sleep(1); shot(app, "12-add-film-details") }
        closeSheet(app)
    }

    @MainActor
    private func tapNavButton(_ app: XCUIApplication, index: Int) {
        let buttons = app.navigationBars.firstMatch.buttons.allElementsBoundByIndex
        guard !buttons.isEmpty else { return }
        (index < 0 ? buttons.last! : buttons[index]).tap()
    }

    @MainActor
    private func closeSheet(_ app: XCUIApplication) {
        let close = app.buttons["Close"].firstMatch
        if close.waitForExistence(timeout: 2), close.isHittable {
            close.tap()
        } else {
            app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.08)).press(forDuration: 0.1, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.95)))
        }
        sleep(1)
    }

    @MainActor
    private func shot(_ app: XCUIApplication, _ name: String) {
        let png = XCUIScreen.main.screenshot().pngRepresentation
        try? png.write(to: URL(fileURLWithPath: "\(dir)/\(name).png"))
    }
}
