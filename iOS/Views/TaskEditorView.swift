import SwiftUI
import CoreData

// TODO: broaden support (set due to @FocusState)
@available(iOS 15, *)
struct TaskEditorView: View {
  @Environment(\.managedObjectContext) private var viewContext
  @Environment(\.presentationMode) var presentationMode
  
  @FocusState var nameFieldFocused: Bool
  
  var list: RoutineList
  var task: RoutineTask?
  
  @State private var name: String
  
  init(list: RoutineList, task: RoutineTask? = nil) {
    self.list = list
    self.task = task

    _name = State(initialValue: task?.name ?? "")
  }
  
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
              self.saveTask()
            }
        }
        
        Button(task == nil ? "Add Task" : "Save Task") {
          self.saveTask()
        }
        .keyboardShortcut(.defaultAction)
        
      }
      #if os(iOS)
        .navigationBarTitle(task == nil ? "New Task" : "Edit Task")
      #endif
    }
  }
  
  private func saveTask() {
    withAnimation {
      if let existingTask = task {
        // Update existing task
        existingTask.name = name
      } else {
        // Bump all other tasks' orderIndex
        for case let task as RoutineTask in list.tasks {
          task.orderIndex += 1
        }
        
        // Create new task with orderIndex 0
        let _ = RoutineTask(
          context: viewContext,
          list: list,
          name: self.name,
          orderIndex: 0
        )
      }
      
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
  static var previews: some View {
    PreviewContainer {
      TaskEditorView(list: PersistenceController.getPreviewList())
      // Optionally, you can comment/uncomment this to preview edit mode:
      // TaskEditorView(list: PersistenceController.getPreviewList(), task: PersistenceController.getPreviewTask())
    }
  }
}
