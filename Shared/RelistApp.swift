import SwiftUI

@main
struct RelistApp: App {
  @StateObject private var settingsManager = SettingsManager()
  
  init() {
    // Handle UI test automation settings
    #if os(iOS)
      if UserDefaults.standard.bool(forKey: "DISABLE_ANIMATIONS") {
        UIView.setAnimationsEnabled(false)
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        windowScene?.windows.first?.layer.speed = 100
      }
    #endif

    // Initialize persistenceController based on settings
    PersistenceController.current = UserDefaults.standard.bool(
      forKey: "USE_PREVIEW_DATA"
    ) 
      ? .preview 
      : .persistent
  }
  
  var body: some Scene {
    WindowGroup {
      #if os(iOS)
        ListsView()
          .environment(
            \.managedObjectContext,
             PersistenceController.current.container.viewContext
          )
          .environmentObject(settingsManager)
          .accentColor(.blue)
      #else
        ListsViewMac()
          .environment(
            \.managedObjectContext,
             PersistenceController.current.container.viewContext
          )
          .environmentObject(settingsManager)
          .accentColor(.blue)
      #endif
    }
  }
}
