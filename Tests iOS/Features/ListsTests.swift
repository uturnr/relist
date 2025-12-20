import XCTest

class ListsTests: BaseTestCase {
  func testEditingList() throws {
    let testListName = "Test List 1"
    let navBar = app.navigationBars.firstMatch
    let collectionViewsQuery = app.collectionViews

    // Edit the list and verify the change
    XCTContext.runActivity(named: "Edit list") { _ in
      let listToEdit = findListCell(named: testListName)
      listToEdit.press(forDuration: 0.5)
      app.buttons["editList"].tap()

      let nameTextField = collectionViewsQuery.textFields["Name"]
      nameTextField.tap()
      nameTextField.typeText(" - Edited")
      app.collectionViews.buttons["Save List"].tap()

      let editedListName = "\(testListName) - Edited"
      // Verify the edited list appears
      _ = findListCell(named: editedListName)
    }

    deleteTestList(named: "\(testListName) - Edited")
  }
}
