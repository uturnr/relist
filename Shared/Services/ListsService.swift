import SwiftUI
import CoreData

class ListsService {
  private static var viewContext: NSManagedObjectContext {
    PersistenceController.current.container.viewContext
  }
  
  // Initializing fetch request this way prevents preview crash
  static var routineListsFetchRequest: NSFetchRequest<RoutineList> {
    let request: NSFetchRequest<RoutineList> = RoutineList.fetchRequest()
    request.sortDescriptors = [
      NSSortDescriptor(keyPath: \RoutineList.createdDate, ascending: true)
    ]
    
    return request
  }

  static func deleteLists(_ lists: [RoutineList]) {
    // Register undo operation before deletion
    viewContext.undoManager?.registerUndo(withTarget: viewContext) { context in
      lists.forEach { list in
        context.insert(list)
      }
      try? context.save()
    }
    
    let actionNamePrefix = "Delete “\(lists[0].name)”"

    /// Examples:
    /// - Delete “Groceries” list
    /// - Delete “Groceries” and 1 more list
    /// - Delete “Groceries” and 2 more lists
    let actionName = lists.count == 1 
      ? "\(actionNamePrefix) list"
      : {
          let moreCount = lists.count - 1
          let listsPluralized = String.pluralize(moreCount, "list")
          return "\(actionNamePrefix) and \(moreCount) more \(listsPluralized)"
        }()
    viewContext.undoManager?.setActionName(actionName)
    
    withAnimation {
      lists.forEach { list in
        viewContext.delete(list)
      }
      
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
