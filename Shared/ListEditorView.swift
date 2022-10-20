import SwiftUI
import CoreData

struct ListEditorView: View {
  @Environment(\.managedObjectContext) private var viewContext
  @Environment(\.presentationMode) var presentationMode
  
  @FocusState var nameFieldFocused: Bool

  @State private var name = ""
  
  var body: some View {
    NavigationView {
      Form {
        Section {
          TextField("Name", text: $name)
            .focused($nameFieldFocused, equals: true)
            .onAppear {
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.nameFieldFocused = true
              }
            }
            .onSubmit { // Used for enter key support.
              self.addList(name: self.name)
            }
        }
        
        Button("Add List") {
          self.addList(name: self.name)
        }
        .keyboardShortcut(.defaultAction)
      }
      #if os(iOS)
        .navigationBarTitle("New List")
      #endif
    }
  }
  
  private func addList(name: String) {
    withAnimation {
      let _ = RoutineList(
        context: viewContext,
        name: name,
        orderIndex: 0
      )
      
      do {
        try viewContext.save()
        presentationMode.wrappedValue.dismiss()
      } catch {
        // TODO: Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nsError = error as NSError
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
      }
    }
  }
}

struct ListEditorView_Previews: PreviewProvider {
  static var previews: some View {
    ListEditorView().environment(
      \.managedObjectContext,
       PersistenceController.preview.container.viewContext
    ).previewInterfaceOrientation(.portraitUpsideDown)
  }
}
