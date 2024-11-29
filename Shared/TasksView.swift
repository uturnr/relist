import SwiftUI
import CoreData

struct TasksView: View {
  @Environment(\.managedObjectContext) private var viewContext
  
  @State private var addTaskViewOpen: Bool = false
  /// The tasks currently displaying the completion animation (if completed
  /// tasks are currently hidden)
  @State private var completingTaskIDs: [String] = []
  
  @State private var animationStarted = NSDate().timeIntervalSince1970
  @State private var showCompleted = false

  var list: RoutineList
  
  private static func getRoutineTasksFetchRequest(
    list: RoutineList
  ) -> NSFetchRequest<RoutineTask> {
    let request: NSFetchRequest<RoutineTask> = RoutineTask.fetchRequest()
    request.predicate = NSPredicate(format: "list == %@", list)
    request.sortDescriptors = [
      NSSortDescriptor(keyPath: \RoutineTask.orderIndex, ascending: true)
    ]
    
    return request
  }
  
  @FetchRequest private var tasksFetchedResults: FetchedResults<RoutineTask>
  
  init(list: RoutineList) {
    self.list = list

    _tasksFetchedResults = FetchRequest(
      fetchRequest: TasksView.getRoutineTasksFetchRequest(list: list),
      animation: .default
    )
  }
  
  private func getFilteredTasks(
    tasks: [RoutineTask],
    completingTaskIDs: [String]
  ) -> [RoutineTask] {
    let filteredTasks = tasks.filter { task in
      let isChecked = task.checked
      let isCompleting = completingTaskIDs.contains(task.id)
      return showCompleted || !isChecked || isCompleting
    }
    return filteredTasks
  }
  
  var body: some View {
    VStack(spacing: 0) {
      let showRemovingAnimation = (
        completingTaskIDs.count > 0
        && !showCompleted
      )

      AnimatedSeparatorView(
        style: .navBar,
        key: animationStarted,
        show: showRemovingAnimation
      ) { key in
        let isLastAnimation = key == animationStarted
        if (isLastAnimation) {
          withAnimation {
            completingTaskIDs = []
          }
        }
      }
      .id(animationStarted)
      List {
        let filteredTasks = getFilteredTasks(
          tasks: Array(tasksFetchedResults),
          completingTaskIDs: completingTaskIDs
        )

        ForEach(filteredTasks) { task in
          TaskItemView(
            task: task,
            completingTaskIDs: $completingTaskIDs,
            animationStarted: $animationStarted,
            showCompleted: showCompleted
          )
        }
        .onDelete { indexSet in
          let tasksToDelete = indexSet.map { filteredTasks[$0] }
          deleteTasks(tasks: tasksToDelete)
        }
        .onMove { indexSet, destination in
          let movedTask = filteredTasks[indexSet[indexSet.startIndex]]
          let destinationTask = filteredTasks[
            destination > indexSet[indexSet.startIndex]
            ? destination - 1
            : destination
          ]
          // The user may be viewing a filtered list, but we need to re-order
          // the tasks in the full list.
          let actualDestination = tasksFetchedResults
            .firstIndex(of: destinationTask) ?? destination
          
          moveTask(task: movedTask, destination: actualDestination)
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        .listRowSeparator(.hidden)
      }
      .accessibilityIdentifier("tasksList")
      .listStyle(PlainListStyle())
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: toggleShowCompleted) {
            Label(
              "Toggle Show Done",
              systemImage: showCompleted ? "eye" : "eye.slash"
            )
          }
        }

        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: uncheckAllTasks) {
            Label("Uncheck All", systemImage: "arrow.counterclockwise.circle")
          }
        }
        #if os(iOS)
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
  }
  
  private func showAddTask() {
    addTaskViewOpen = true
  }
  
  /// Updates the stored orderIndex values for all tasks based on a given
  /// array of tasks. If no array is provided, all tasks are updated based on
  /// the current list order.
  private func reorderAllTasks(orderedTasks: [RoutineTask]? = nil) {
    let tasksToOrder = orderedTasks ?? Array(tasksFetchedResults)
    
    for (index, task) in tasksToOrder.enumerated() {
      task.orderIndex = Int64(index)
    }
    
    list.tasksUpdatedDate = Date.now
    
    do {
      try viewContext.save()
    } catch {
      // TODO: Proper error handling
      let nsError = error as NSError
      fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    }
  }
  
  private func toggleShowCompleted() {
    withAnimation {
      showCompleted = !showCompleted
    }
  }
  
  private func uncheckAllTasks() {
    // TODO: Determine a way to uncheck all tasks in a single update to
    // see if it helps to prevent animation from showing checked state briefly
    // when unchecked tasks re-appear
    for task in tasksFetchedResults {
      task.checked = false
    }
    list.tasksUpdatedDate = Date.now
    
    do {
      try viewContext.save()
    } catch {
      // TODO: Proper error handling
      let nsError = error as NSError
      fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    }
  }
  
  private func moveTask(task: RoutineTask, destination: Int) {
    // Get array of all tasks
    let tasks = Array(tasksFetchedResults)
    guard let sourceIndex = tasks.firstIndex(of: task) else { return }
    
    // Remove task from source and insert at destination
    var reorderedTasks = tasks
    reorderedTasks.remove(at: sourceIndex)
    reorderedTasks.insert(task, at: destination)
    
    // Update CoreData order to match new array order
    reorderAllTasks(orderedTasks: reorderedTasks)
  }
  
  private func deleteTasks(tasks: [RoutineTask]) {
    withAnimation {
      tasks.forEach { task in
        viewContext.delete(task)
      }
      list.tasksUpdatedDate = Date.now
      
      do {
        // Saving the deletion prior to reordering ensures accurate reordering
        try viewContext.save()
        reorderAllTasks()
      } catch {
        // TODO: Proper error handling
        let nsError = error as NSError
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
      }
    }
  }
}

/// Note: List show/hide, add/remove animations not working in preview.
struct TasksView_Previews: PreviewProvider {
  static var previews: some View {
    let list = PersistenceController.getPreviewList(
      PersistenceController.preview.container.viewContext
    )

    if #available(iOS 16.0, *) {
      NavigationStack {
        TasksView(list: list).environment(
          \.managedObjectContext,
          PersistenceController.preview.container.viewContext
        )
      }.previewInterfaceOrientation(.portraitUpsideDown)
    } else {
      Text("Preview requires iOS 16")
    }
  }
}
