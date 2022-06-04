//
//  TasksView.swift
//  Shared
//
//  Created by uturnr on 2022-05-05.
//

import SwiftUI
import CoreData

struct TasksView: View {
  @Environment(\.managedObjectContext) private var viewContext
  
  @State private var addTaskViewOpen: Bool = false

  var list: RoutineList
  
  static func getRoutineTasksFetchRequest(
    list: RoutineList
  ) -> NSFetchRequest<RoutineTask> {
    let request: NSFetchRequest<RoutineTask> = RoutineTask.fetchRequest()
    request.predicate = NSPredicate(format: "list == %@", list)
    // TODO: sort by order weight
    request.sortDescriptors = [
      NSSortDescriptor(keyPath: \RoutineTask.createdDate, ascending: true)
    ]
    
    return request
  }
  
  @FetchRequest private var tasks: FetchedResults<RoutineTask>
  
  init(list: RoutineList) {
    self.list = list

    _tasks = FetchRequest(
      fetchRequest: TasksView.getRoutineTasksFetchRequest(list: list),
      animation: .default
    )
  }
  
  var body: some View {
    List {
      Text(list.name)

      ForEach(tasks) { task in
        // TODO: Move to own view
        Button(action: {
          toggleTaskChecked(task: task)
        }) {
          HStack {
            Text("\(task.checked ? "☑️" : "")")
            Text("\(task.createdDate, formatter: itemFormatter) - \(task.name)")
          }
        }
      }
      .onDelete(perform: deleteTasks)
    }
    .listRowBackground(Ellipse()
      .background(Color.clear)
      .foregroundColor(.purple)
      .opacity(0.3))
    .environment(\.defaultMinListRowHeight, 65)
    .toolbar {
      #if os(iOS)
        ToolbarItem(placement: .navigationBarTrailing) {
          EditButton()
        }
      #endif
      ToolbarItem {
        Button(action: showAddTask) {
          Label("Add Task", systemImage: "plus")
        }
        .sheet(isPresented: $addTaskViewOpen) {
          TaskEditorView(list: list)
            .environment(\.managedObjectContext, self.viewContext)
        }
      }
    }
  }
  
  private func showAddTask() {
    addTaskViewOpen = true
  }
  
  private func deleteTasks(offsets: IndexSet) {
    withAnimation {
      offsets.map { tasks[$0] }.forEach(viewContext.delete)
      
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
  
  private func toggleTaskChecked(task: RoutineTask) {
    withAnimation {
      task.checked = !task.checked
      
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

private let itemFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateStyle = .short
  formatter.timeStyle = .medium
  return formatter
}()

struct TasksView_Previews: PreviewProvider {
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
