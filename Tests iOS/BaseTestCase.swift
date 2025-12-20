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

  func openTestList(named testListName: String) {
    let sidebarCollectionView = app.collectionViews["Sidebar"]

    // Wait for the list to appear in the sidebar
    let testListCell = sidebarCollectionView.cells
      .containing(.staticText, identifier: testListName)

    // Wait for at least one matching cell to exist
    let exists = testListCell.firstMatch.waitForExistence(timeout: 5)
    XCTAssertTrue(exists, "List '\(testListName)' should exist in sidebar")

    // Get the last matching cell (in case there are duplicates)
    let matchingCells = testListCell.allElementsBoundByIndex
    guard let cellToTap = matchingCells.last else {
      XCTFail("Could not find list cell with name '\(testListName)'")
      return
    }

    cellToTap.tap()
  }

  func deleteTestList(named testListName: String) {
    let sidebarCollectionView = app.collectionViews["Sidebar"]
    let testListCell = sidebarCollectionView.cells
      .containing(.staticText, identifier: testListName)

    // Wait for the list to appear in the sidebar
    let exists = testListCell.firstMatch.waitForExistence(timeout: 5)
    XCTAssertTrue(exists, "List '\(testListName)' should exist in sidebar")

    // Get the last matching cell (in case there are duplicates)
    let matchingCells = testListCell.allElementsBoundByIndex
    guard let cellToDelete = matchingCells.last else {
      XCTFail("Could not find list cell with name '\(testListName)'")
      return
    }

    cellToDelete.swipeLeft()
    sidebarCollectionView.buttons["Delete"].tap()
  }
}
