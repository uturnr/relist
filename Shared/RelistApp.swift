import SwiftUI

@main
struct RelistApp: App {
  let persistenceController = PersistenceController.shared
  
  var body: some Scene {
    WindowGroup {
      ListsView().environment(
        \.managedObjectContext,
         persistenceController.container.viewContext
      )
    }
  }
}
