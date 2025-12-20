import XCTest

class BaseTestCase: XCTestCase {
  let app = XCUIApplication()

  override func setUpWithError() throws {
    continueAfterFailure = false

    app.launchArguments = [
      "-DISABLE_ANIMATIONS", "YES",
      "-USE_PREVIEW_DATA", "YES",
    ]
    app.launch()
  }

  /// Compares expected array of strings to visible cell contents. As indices
  /// shows in debug mode, and our test data includes longer names, the strings
  /// in the second array must only contain the string in the first. (Note:
  /// debug mode doesn't exist yet so we are always in debug mode)
  /// ["Task 1", "Task 2"], ["0 - Test Task 1", "1 - Test Task 2"] => true
  func assertVisibleTasksMatch(_ expectedTaskLabels: [String]) {
    let visibleTaskLabels = app.collectionViews["tasksList"].cells
    .allElementsBoundByIndex
    .compactMap { cell in
      cell.staticTexts["taskName"].label
    }
    guard expectedTaskLabels.count == visibleTaskLabels.count else {
      XCTFail("""
        Array counts don't match: expected \(expectedTaskLabels.count), \
        got \(visibleTaskLabels.count)
      """)
      return
    }

    for (index, expectedTask) in expectedTaskLabels.enumerated() {
      XCTAssert(
        visibleTaskLabels[index].contains(expectedTask),
        """
        Task at index \(index) should contain '\(expectedTask)' \
        but got '\(visibleTaskLabels[index])'
        """
      )
    }
  }

  /// Finds a list cell in the sidebar by name, waiting for it to appear.
  /// Returns the last matching cell if duplicates exist.
  func findListCell(named listName: String, timeout: TimeInterval = 5) -> XCUIElement {
    let sidebarCollectionView = app.collectionViews["Sidebar"]
    let listCellQuery = sidebarCollectionView.cells
      .containing(.staticText, identifier: listName)

    let exists = listCellQuery.firstMatch.waitForExistence(timeout: timeout)
    XCTAssertTrue(exists, "List '\(listName)' should exist in sidebar")

    let matchingCells = listCellQuery.allElementsBoundByIndex
    guard let cell = matchingCells.last else {
      XCTFail("Could not find list cell with name '\(listName)'")
      // Return firstMatch as fallback to prevent crash
      return listCellQuery.firstMatch
    }

    return cell
  }

  func openTestList(named testListName: String) {
    let cell = findListCell(named: testListName)
    cell.tap()
  }

  func deleteTestList(named testListName: String) {
    let sidebarCollectionView = app.collectionViews["Sidebar"]
    let cell = findListCell(named: testListName)
    cell.swipeLeft()
    sidebarCollectionView.buttons["Delete"].tap()
  }
}
