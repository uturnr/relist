import XCTest

class Tests_iOS: XCTestCase {
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
  private func assertVisibleTasksMatch(_ expectedTaskLabels: [String]) {
    let visibleTaskLabels = app.collectionViews.cells.allElementsBoundByIndex
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
  
  private func openTestList(named testListName: String) {
    let sidebarCollectionView = app.collectionViews["Sidebar"]
    let testListCell = sidebarCollectionView.cells
      .containing(.staticText, identifier: testListName)
      .allElementsBoundByIndex.last!
    testListCell.tap()
  }
  
  private func deleteTestList(named testListName: String) {
    let sidebarCollectionView = app.collectionViews["Sidebar"]
    let testListCell = sidebarCollectionView.cells
      .containing(.staticText, identifier: testListName)
      .allElementsBoundByIndex.last!
    
    testListCell.swipeLeft()
    sidebarCollectionView.buttons["Delete"].tap()
  }

  func testManuallyCreatingListAndTasks() throws {
    let testListName = "Test List"
    
    let navBar = app.navigationBars.firstMatch
    navBar.buttons["Add List"].tap()
    app.textFields["Name"].typeText(testListName)
    app.collectionViews.buttons["Add List"].tap()
    
    openTestList(named: testListName)
    
    let collectionViewsQuery = app.collectionViews
    
    // Add multiple tasks
    for i in 1...5 {
      navBar.buttons["Add Task"].tap()
      let nameTextField = collectionViewsQuery.textFields["Name"]
      nameTextField.typeText("Task \(i)")
      app.collectionViews.buttons["Add Task"].tap()
    }
    
    // Each new task currently gets added to the top of the list
    let expectedVisibleTasks
      = ["Task 5", "Task 4", "Task 3", "Task 2", "Task 1"]
    assertVisibleTasksMatch(expectedVisibleTasks)

    navBar.buttons["Back"].tap()
    deleteTestList(named: testListName)
  }
  
  /// Given some tasks are completed and hidden, ensures that:
  /// - Task deletion results in the correct task being deleted
  /// - Task reordering results in the correct task order
  func testDeletingAndReorderingCorrectTask() throws {
    let testListName = "Test List 1"
    let navBar = app.navigationBars.firstMatch
    
    // Open the test list and validate the initial order
    openTestList(named: testListName)
    
    let collectionViewsQuery = app.collectionViews
    var expectedVisibleTasks
      = ["Task 1", "Task 2", "Task 3", "Task 4", "Task 5"]
    assertVisibleTasksMatch(expectedVisibleTasks)
    
    // Check off a task and validate remaining visible task order
    let taskToComplete = collectionViewsQuery.cells.firstMatch
    taskToComplete.tap()
    taskToComplete.waitForNonExistence(timeout: 2)
    
    expectedVisibleTasks.removeFirst() // 2, 3, 4, 5
    assertVisibleTasksMatch(expectedVisibleTasks)

    // Delete a task and validate remaining visible task order
    let taskToDelete = collectionViewsQuery.cells.firstMatch
    taskToDelete.swipeLeft()
    app.buttons["Delete"].tap()
    
    expectedVisibleTasks.removeFirst() // 3, 4, 5
    assertVisibleTasksMatch(expectedVisibleTasks)
    
    // Move the first visible task to the position of the last visible task
    // and validate the remaining visible task order
    let firstCell = collectionViewsQuery.cells.firstMatch
    let lastCell = collectionViewsQuery.cells.element(
      boundBy: expectedVisibleTasks.count - 1
    )
    
    let start = firstCell
      .coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
    let finish = lastCell
      .coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
    start.press(
      forDuration: 0.5,
      thenDragTo: finish,
      withVelocity: .slow,
      thenHoldForDuration: 0.5
    )
    
    let movedTask = expectedVisibleTasks.removeFirst()
    expectedVisibleTasks.append(movedTask) // 4, 5, 3
    assertVisibleTasksMatch(expectedVisibleTasks)
    
    navBar.buttons["Back"].tap()
    deleteTestList(named: testListName)
  }
  
  func testLaunchPerformance() throws {
    if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
      // This measures how long it takes to launch your application.
      measure(metrics: [XCTApplicationLaunchMetric()]) {
        XCUIApplication().launch()
      }
    }
  }
}
