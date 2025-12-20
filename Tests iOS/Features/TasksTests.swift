import XCTest

class TasksTests: BaseTestCase {
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

    navBar.buttons.firstMatch.tap()
    deleteTestList(named: testListName)
  }
  
  /// Given some tasks are completed and hidden, ensures that:
  /// - Task deletion results in the correct task being deleted
  /// - Task reordering results in the correct task order
  func testDeletingAndReorderingCorrectTask() throws {
    let testListName = "Test List 1"
    let navBar = app.navigationBars.firstMatch
    let collectionViewsQuery = app.collectionViews
    var expectedVisibleTasks
      = ["Task 1", "Task 2", "Task 3", "Task 4", "Task 5"]
    
    // Open the test list and validate the initial order
    XCTContext.runActivity(named: "Open test list") { _ in
      openTestList(named: testListName)

      assertVisibleTasksMatch(expectedVisibleTasks)
    }
    
    // Check off a task and validate remaining visible task order
    XCTContext.runActivity(named: "Check off a task") { _ in
      let taskToComplete = collectionViewsQuery.cells.firstMatch
      taskToComplete.tap()
      taskToComplete.waitForNonExistence(timeout: 2)
    
      expectedVisibleTasks.removeFirst() // 2, 3, 4, 5
      assertVisibleTasksMatch(expectedVisibleTasks)
    }

    // Delete a task and validate remaining visible task order
    XCTContext.runActivity(named: "Delete a task") { _ in
      let taskToDelete = collectionViewsQuery.cells.firstMatch
      taskToDelete.swipeLeft()
      app.buttons["Delete"].tap()
      
      expectedVisibleTasks.removeFirst() // 3, 4, 5
      assertVisibleTasksMatch(expectedVisibleTasks)
    }
    
    // Move the first visible task to the position of the last visible task
    // and validate the remaining visible task order
    XCTContext.runActivity(named: "Move first visible task to last") { _ in
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
    
      // Wait for the moved task label to appear in the last position
      let movedCell = collectionViewsQuery.cells
        .element(boundBy: expectedVisibleTasks.count - 1)
        .staticTexts["taskName"]
      let predicate = NSPredicate(format: "label CONTAINS %@", "Task 3")
      expectation(for: predicate, evaluatedWith: movedCell, handler: nil)
      waitForExpectations(timeout: 2)
      
      let movedTask = expectedVisibleTasks.removeFirst()
      expectedVisibleTasks.append(movedTask) // 4, 5, 3
      assertVisibleTasksMatch(expectedVisibleTasks)
    }

    navBar.buttons.firstMatch.tap()
    deleteTestList(named: testListName)
  }

  func testEditingTask() throws {
    let testListName = "Test List 1"
    let navBar = app.navigationBars.firstMatch
    let collectionViewsQuery = app.collectionViews
    var expectedVisibleTasks = ["Task 1", "Task 2", "Task 3", "Task 4", "Task 5"]
    
    // Open the test list and validate the initial order
    XCTContext.runActivity(named: "Open test list") { _ in
      openTestList(named: testListName)
      assertVisibleTasksMatch(expectedVisibleTasks)
    }
    
    // Edit the second task and verify the change
    XCTContext.runActivity(named: "Edit task") { _ in
      let taskToEdit = collectionViewsQuery.cells.element(boundBy: 1)
      taskToEdit.press(forDuration: 0.5)
      app.buttons["editTask"].tap()
      
      let nameTextField = collectionViewsQuery.textFields["Name"]
      nameTextField.tap()
      nameTextField.typeText(" - Edited")
      app.collectionViews.buttons["Save Task"].tap()
      
      expectedVisibleTasks[1] = "Task 2 - Edited"
      assertVisibleTasksMatch(expectedVisibleTasks)
    }
    
    navBar.buttons.firstMatch.tap()
    deleteTestList(named: testListName)
  }
} 