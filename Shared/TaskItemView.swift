import SwiftUI
import CoreData

struct TaskItemView: View {
  @Environment(\.managedObjectContext) private var viewContext
  
  @ObservedObject var task: RoutineTask
  
  init(task: RoutineTask) {
    self.task = task
  }
  
  
  var body: some View {
    Button(action: {
      toggleTaskChecked(task: task)
    }) {
      HStack {
        Text("\(task.checked ? "☑️" : "")")
        Text("\(task.orderIndex) - \(task.name)")
      }
    }
  }
  
  private func toggleTaskChecked(task: RoutineTask) {
    withAnimation {
      task.checked = !task.checked
      task.list.tasksUpdatedDate = Date.now
      
      do {
        try viewContext.save()
      } catch {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nsError = error as NSError
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
      }
    }
  }
}

struct TaskItemView_Previews: PreviewProvider {
  // TODO: use mock data from Persistence.swift
  static let list = RoutineList(
    context: PersistenceController.preview.container.viewContext,
    name: "Test List",
    orderIndex: 0
  )
  
  static var previews: some View {
    let _ = RoutineTask(
      context: PersistenceController.preview.container.viewContext,
      list: list,
      name: "Test Task",
      orderIndex: 0
    )
    
    TasksView(list: list).environment(
      \.managedObjectContext,
       PersistenceController.preview.container.viewContext
    ).previewInterfaceOrientation(.portraitUpsideDown)
  }
}
