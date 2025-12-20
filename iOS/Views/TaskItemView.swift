import SwiftUI
import CoreData

struct TaskItemButtonStyle: ButtonStyle {
  func makeBody(configuration: Self.Configuration) -> some View {
    configuration.label
      // Darken the button when tapped. This doesn't happen
      // fast enough to make the button feel like it has been
      // tapped, so we will add an additional animation.
      .background(
        configuration.isPressed ? Color.systemGray3 : Color.systemBackground
      )
  }
}

struct TaskItemView: View {
  @Environment(\.managedObjectContext) private var viewContext
  @EnvironmentObject private var settings: SettingsManager
  
  @ObservedObject var task: RoutineTask
  
  // Completion animation vars
  /// All tasks currently displaying completion animation
  @Binding var completingTaskIDs: [String]
  /// Whether this task is currently displaying completion animation
  private var isCompleting: Bool {
    get {
      completingTaskIDs.contains(task.id)
    }
  }
  /// Whether this task is completed. This is immediately true, even while
  /// the task is displaying completion animation.
  private var isCompleted: Bool {
    get {
      task.checked
    }
  }

  let tapBgOpacity = 0.8
  let animateAwayBgOpacity = 0.125
  /// Used to simulate faster tap (isPressed) and darkened view
  /// when animating away.
  @State private var bgOpacity = 1.0
  
  @Binding var animationStarted: TimeInterval
  var showCompleted: Bool
  
  var editTask: () -> Void
  
  init(
    task: RoutineTask,
    completingTaskIDs: Binding<[String]>,
    animationStarted: Binding<TimeInterval>,
    showCompleted: Bool,
    editTask: @escaping () -> Void
  ) {
    self.task = task
    self._completingTaskIDs = completingTaskIDs
    self._animationStarted = animationStarted
    self.showCompleted = showCompleted
    self.editTask = editTask
  }
  
  var body: some View {
    Button(action: {
      toggleTaskChecked(task: task)
    }) {
      ZStack {
        // Fill background with light grey for completed tasks and simulate a
        // tap. TODO: Fix flickering when scrolling through completed tasks
        if (task.checked) {
          Color(uiColor: .systemGray4)
            .opacity(bgOpacity)
            .ignoresSafeArea()
            .onAppear {
              withAnimation(.none) {
                bgOpacity = tapBgOpacity
              }

              DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.linear(duration: 0.2)) {
                  bgOpacity = animateAwayBgOpacity
                }
              }
            }
        }

        // Button content
        HStack {
          Text("\(task.checked ? "☑️" : "")")

          let taskPrefix = settings.showTaskIndices
            ? "\(task.orderIndex) - "
            : ""
          Text(taskPrefix + task.name)
            .accessibilityIdentifier("taskName")
            .opacity(isCompleted ? 0.5 : 1.0)

          Spacer()
        }
        .animation(.linear, value: task.checked)
        .padding([.leading], 10)

        // Completed task animation
        VStack {
          Spacer()
          
          AnimatedSeparatorView(
            style: .taskItem,
            key: animationStarted,
            show: isCompleting && !showCompleted
          )
          .id(animationStarted)
        }
      }
      // Make entire button area clickable
      .contentShape(Rectangle())
    }
    .buttonStyle(TaskItemButtonStyle())
    .frame(minHeight: 65)
    .transaction { transaction in
      transaction.animation = nil
    }
    .contextMenu {
      Button(action: editTask) {
        Label("Edit", systemImage: "pencil")
      }
      .accessibilityIdentifier("editTask")

      Button(role: .destructive, action: {
        TasksService.deleteTasks([task])
      }) {
        Label("Delete", systemImage: "trash")
      }
    }
  }
  
  private func toggleTaskChecked(task: RoutineTask) {
    // https://developer.apple.com/forums/thread/682779
    DispatchQueue.main.async {
      task.checked = !task.checked
      if task.checked && !showCompleted {
        animationStarted = NSDate().timeIntervalSince1970
        completingTaskIDs.append(task.id)
      }

      task.list.tasksUpdatedDate = Date.now
      
      do {
        try viewContext.save()
      } catch {
        // TODO: Proper error handling
        let nsError = error as NSError
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
      }
    }
  }
}

/// Entire list previewed for a more accurate preview.
struct TaskItemView_Previews: PreviewProvider {
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
