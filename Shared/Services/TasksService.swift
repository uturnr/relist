import SwiftUI
import CoreData

class TasksService {
  private static var viewContext: NSManagedObjectContext {
    PersistenceController.current.container.viewContext
  }

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
  
  static func getRoutineTasks(
    in list: RoutineList
  ) -> [RoutineTask] {
    let request = getRoutineTasksFetchRequest(list: list)
    return (try? viewContext.fetch(request)) ?? []
  }

  private static func getCommonList(_ tasks: [RoutineTask]) -> RoutineList? {
    guard let firstList = tasks.first?.list else { return nil }
    guard tasks.allSatisfy({ $0.list == firstList }) else {
      // TODO: Proper error handling
      fatalError("All tasks must belong to the same list")
    }
    return firstList
  }

  static func deleteTasks(_ tasks: [RoutineTask]) {
    guard let list = getCommonList(tasks) else { return }
    
    withAnimation {
      tasks.forEach { task in
        viewContext.delete(task)
      }
      list.tasksUpdatedDate = Date.now
      
      do {
        try viewContext.save()
        reorderAllTasks(in: list)
      } catch {
        // TODO: Proper error handling
        let nsError = error as NSError
        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
      }
    }
  }

  static func moveTask(task: RoutineTask, destination: Int) {
    guard let list = getCommonList([task]) else { return }

    let tasks = getRoutineTasks(in: list)
    guard let sourceIndex = tasks.firstIndex(of: task) else { return }
    
    // Remove task from source and insert at destination
    var reorderedTasks = tasks
    reorderedTasks.remove(at: sourceIndex)
    reorderedTasks.insert(task, at: destination)
    
    // Update CoreData order to match new array order
    reorderAllTasks(in: list, orderedTasks: reorderedTasks)
  }
  
  /// Updates the stored orderIndex values for all tasks based on a given
  /// array of tasks. If no array is provided, all tasks are updated based on
  /// the current list order.
  static func reorderAllTasks(
    in list: RoutineList, orderedTasks: [RoutineTask]? = nil
  ) {
    let existingTasks = getRoutineTasks(in: list)
    let tasksToOrder = orderedTasks ?? existingTasks
    
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

  static func uncheckAllTasks(in list: RoutineList) {
    let tasks = getRoutineTasks(in: list)
    
    for task in tasks {
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
} 
