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
    request.sortDescriptors = [
      NSSortDescriptor(keyPath: \RoutineTask.orderIndex, ascending: true)
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
      ForEach(tasks) { task in
        // TODO: Move to own view
        Button(action: {
          toggleTaskChecked(task: task)
        }) {
          HStack {
            Text("\(task.checked ? "☑️" : "")")
            Text("\(task.orderIndex) - \(task.name)")
          }
        }
      }
      .onDelete(perform: deleteTasks)
      .onMove(perform: moveTask)
    }
    .listRowBackground(Ellipse()
      .background(Color.clear)
      .foregroundColor(.purple)
      .opacity(0.3))
    .environment(\.defaultMinListRowHeight, 65)
    .toolbar {
      #if os(iOS)
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: uncheckAllTasks) {
            Label("Uncheck All", systemImage: "arrow.counterclockwise.circle")
          }
        }
      
        ToolbarItem(placement: .navigationBarTrailing) {
          EditButton()
        }
      #endif

      ToolbarItem() {
        Button(action: showAddTask) {
          Label("Add Task", systemImage: "plus")
        }
        .keyboardShortcut("n")
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
  
  private func reorderAllTasks() {
    for (index, task) in tasks.enumerated() {
      task.orderIndex = Int64(index)
    }
  }
  
  private func uncheckAllTasks() {
    for task in tasks {
      task.checked = false
    }
    list.tasksUpdatedDate = Date.now
    
    do {
      try viewContext.save()
    } catch {
      // Replace this implementation with code to handle the error appropriately.
      // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      let nsError = error as NSError
      fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    }
  }
  
  private func moveTask(sets: IndexSet, destination: Int) {
    // TODO: ensure ordering works with hidden/filtered tasks.

    // First, reorder all tasks in case they somehow lost valid ordering.
    reorderAllTasks()

    enum Direction {
      case down
      case up
      case unmoved
    }
    
    let movedTaskIndex = sets.first!
    
    let direction: Direction

    if (movedTaskIndex == destination) {
      direction = .unmoved
    } else if (movedTaskIndex < destination) {
      direction = .down
    } else if (movedTaskIndex > destination) {
      direction = .up
    } else {
      fatalError("Impossible move")
    }
    
    if direction == .unmoved {
      return
    }
    
    let movedTask = tasks[movedTaskIndex]
    let destinationForMovedTask = direction == .down
      ? Int64(destination) - 1
      : Int64(destination)
    
    // Move moved task
    movedTask.orderIndex = destinationForMovedTask
    
    /// First index in other tasks to reorder
    let startIndex = direction == .down
      ? movedTaskIndex + 1
      : destination
    /// Last index in other tasks to reorder
    let endIndex = direction == .down
      ? destination - 1
      : movedTaskIndex - 1

    let adjustment: Int64 = direction == .down ? -1 : 1
    
    // Move other tasks
    for indexInList in startIndex...endIndex {
      let currentTask = tasks[indexInList]
      let newOrderIndex = currentTask.orderIndex + adjustment
      currentTask.orderIndex = newOrderIndex
    }
    
    list.tasksUpdatedDate = Date.now
    
    do {
      try viewContext.save()
    } catch {
      // Replace this implementation with code to handle the error appropriately.
      // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      let nsError = error as NSError
      fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    }
  }
  
  private func deleteTasks(offsets: IndexSet) {
    withAnimation {
      offsets.map { tasks[$0] }.forEach(viewContext.delete)
      list.tasksUpdatedDate = Date.now
      
      do {
        try viewContext.save()
        reorderAllTasks()
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
      list.tasksUpdatedDate = Date.now
      
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
