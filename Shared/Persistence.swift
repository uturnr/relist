import CoreData
import SwiftUI

struct PersistenceController {
  static let shared = PersistenceController()
  
  static func setupMockList(_ viewContext: NSManagedObjectContext) {
    let list = RoutineList(
      context: viewContext,
      name: "Test List 1",
      orderIndex: 0
    )
    
    let _ = RoutineTask(
      context: viewContext,
      checked: false,
      list: list,
      name: "Test Task 1",
      orderIndex: 0
    )
    
    let _ = RoutineTask(
      context: viewContext,
      checked: false,
      list: list,
      name: "Test Task 2",
      orderIndex: 1
    )
    
    let _ = RoutineTask(
      context: viewContext,
      checked: false,
      list: list,
      name: "Test Task 3",
      orderIndex: 2
    )
    
    let _ = RoutineTask(
      context: viewContext,
      checked: false,
      list: list,
      name: "Test Task 4",
      orderIndex: 3
    )
    
    let _ = RoutineTask(
      context: viewContext,
      checked: false,
      list: list,
      name: "Test Task 5",
      orderIndex: 4
    )
    
    do {
      try viewContext.save()
    } catch {
      // Replace this implementation with code to handle the error appropriately.
      // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      let nsError = error as NSError
      fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
    }
  }
  
  static func getPreviewList(_ viewContext: NSManagedObjectContext) -> RoutineList {
    let request: NSFetchRequest<RoutineList> = RoutineList.fetchRequest()

    let lists = try! viewContext.fetch(request)
    return lists[0]
  }
  
  static var preview: PersistenceController = {
    let result = PersistenceController(inMemory: true)
    let viewContext = result.container.viewContext
    
    setupMockList(viewContext)

    return result
  }()
  
  let container: NSPersistentCloudKitContainer
  
  init(inMemory: Bool = false) {
    container = NSPersistentCloudKitContainer(name: "Relist")
    if inMemory {
      container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
    }
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        
        /*
         Typical reasons for an error here include:
         * The parent directory does not exist, cannot be created, or disallows writing.
         * The persistent store is not accessible, due to permissions or data protection when the device is locked.
         * The device is out of space.
         * The store could not be migrated to the current model version.
         Check the error message to determine what the actual problem was.
         */
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    container.viewContext.automaticallyMergesChangesFromParent = true
    container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
  }
}
