import SwiftUI
import CoreData

struct TasksView: View {
  @Environment(\.managedObjectContext) private var viewContext
  
  // @State private var taskEditorViewOpen: Bool = false
  // @State private var selectedTaskForEdit: RoutineTask? = nil
  /// The tasks currently displaying the completion animation (if completed
  /// tasks are currently hidden)
  @State private var completingTaskIDs: [String] = []
  
  @State private var animationStarted = NSDate().timeIntervalSince1970
  @State private var showCompleted = false

  var list: RoutineList
  
  // private static func getRoutineTasksFetchRequest(
  //   list: RoutineList
  // ) -> NSFetchRequest<RoutineTask> {
  //   let request: NSFetchRequest<RoutineTask> = RoutineTask.fetchRequest()
  //   request.predicate = NSPredicate(format: "list == %@", list)
  //   request.sortDescriptors = [
  //     NSSortDescriptor(keyPath: \RoutineTask.orderIndex, ascending: true)
  //   ]
    
  //   return request
  // }
  
  @FetchRequest private var tasksFetchedResults: FetchedResults<RoutineTask>

  struct EditedTask: Identifiable {
    var id: String { taskId ?? "new" }
    var isNew: Bool = false
    var taskId: String? = nil
  }

  @State private var editedTask: EditedTask? = nil
  
  init(list: RoutineList) {
    self.list = list

    _tasksFetchedResults = FetchRequest(
      fetchRequest: TasksService.getRoutineTasksFetchRequest(list: list),
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
            showCompleted: showCompleted,
            editTask: { showEditTask(task) }
          )
        }
        .onDelete { indexSet in
          let tasksToDelete = indexSet.map { filteredTasks[$0] }
          TasksService.deleteTasks(tasksToDelete)
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
          
          TasksService
            .moveTask(task: movedTask, destination: actualDestination)
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
          Button(action: {
            TasksService.uncheckAllTasks(in: list)
          }) {
            Label("Uncheck All", systemImage: "arrow.counterclockwise.circle")
          }
        }

        #if os(iOS)
        ToolbarItem(placement: .navigationBarTrailing) {
          EditButton()
        }
        #endif
        
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: showAddTask) {
            Label("Add Task", systemImage: "plus")
          }
          .keyboardShortcut("n")
        }
      }
    }
    .sheet(item: $editedTask) { editedTask in
      TaskEditorView(
        list: list,
        task: editedTask.taskId.flatMap { id in
          tasksFetchedResults.first { $0.id == id }
        }
      )
    }
  }
  
  private func showAddTask() {
    editedTask = EditedTask(isNew: true)
  }
  
  private func showEditTask(_ task: RoutineTask) {
    editedTask = EditedTask(taskId: task.id)
  }
  
  private func toggleShowCompleted() {
    withAnimation {
      showCompleted = !showCompleted
    }
  }
}

/// Note: List show/hide, add/remove animations not working in preview.
struct TasksView_Previews: PreviewProvider {
  static var previews: some View {
    if #available(iOS 16.0, *) {
      PreviewContainer {
        NavigationStack {
          TasksView(list: PersistenceController.getPreviewList())
        }
      }
    } else {
      Text("Preview requires iOS 16")
    }
  }
}
