import SwiftUI

struct PreviewContainer<Content: View>: View {
  let content: Content
  
  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }
  
  var body: some View {
    content
      .environment(
        \.managedObjectContext,
        PersistenceController.preview.container.viewContext
      )
      .environmentObject(SettingsManager())
  }
}
