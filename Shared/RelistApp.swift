import SwiftUI

@main
struct RelistApp: App {
  let persistenceController: PersistenceController
  
  init() {
    // Handle UI test automation settings
    if UserDefaults.standard.bool(forKey: "DISABLE_ANIMATIONS") {
      UIView.setAnimationsEnabled(false)
      let scenes = UIApplication.shared.connectedScenes
      let windowScene = scenes.first as? UIWindowScene
      windowScene?.windows.first?.layer.speed = 100
    }

    // Initialize persistenceController based on settings
    persistenceController = UserDefaults.standard.bool(
      forKey: "USE_PREVIEW_DATA"
    ) 
      ? .preview 
      : .shared
  }
  
  var body: some Scene {
    WindowGroup {
      ListsView().environment(
        \.managedObjectContext,
         persistenceController.container.viewContext
      )
    }
  }
}
