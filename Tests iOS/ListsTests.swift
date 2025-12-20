import XCTest

class ListsTests: BaseTestCase {
  func testEditingList() throws {
    let testListName = "Test List 1"
    let navBar = app.navigationBars.firstMatch
    let collectionViewsQuery = app.collectionViews
    
    // Edit the list and verify the change
    XCTContext.runActivity(named: "Edit list") { _ in
      let listToEdit = collectionViewsQuery.cells.staticTexts[testListName]
      listToEdit.press(forDuration: 0.5)
      app.buttons["editList"].tap()
      
      let nameTextField = collectionViewsQuery.textFields["Name"]
      nameTextField.tap()
      nameTextField.typeText(" - Edited")
      app.collectionViews.buttons["Save List"].tap()
      
      let editedListName = "\(testListName) - Edited"
      XCTAssertTrue(collectionViewsQuery.cells.staticTexts[editedListName].exists)
    }
    
    deleteTestList(named: "\(testListName) - Edited")
  }
}
