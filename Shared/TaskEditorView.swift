import SwiftUI
import CoreData

// TODO: broaden support (set due to @FocusState)
@available(iOS 15, *)
struct TaskEditorView: View {
  @Environment(\.managedObjectContext) private var viewContext
  @Environment(\.presentationMode) var presentationMode
  
  @FocusState var nameFieldFocused: Bool
  
  var list: RoutineList
  
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
              self.addTask()
            }
        }
        
        Button("Add Task") {
          self.addTask()
        }
        .keyboardShortcut(.defaultAction)
        
      }
      #if os(iOS)
        .navigationBarTitle("New Task")
      #endif
    }

  }
  
  private func addTask() {
    withAnimation {
      // Bump all tasks’ orderIndex
      for case let task as RoutineTask in list.tasks  {
        task.orderIndex += 1
      }
      
      // Place the new task at the first orderIndex
      let _ = RoutineTask(
        context: viewContext,
        list: list,
        name: self.name,
        orderIndex: 0
      )
      
      list.tasksUpdatedDate = Date.now
      
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

struct TaskEditorView_Previews: PreviewProvider {
  static let list = RoutineList(
    context: PersistenceController.preview.container.viewContext,
    name: "Test",
    orderIndex: 0
  )

  static var previews: some View {
    TaskEditorView(list: list).environment(
      \.managedObjectContext,
       PersistenceController.preview.container.viewContext
    ).previewInterfaceOrientation(.portraitUpsideDown)
  }
}
