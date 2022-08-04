//
//  RoutineList+CoreDataClass.swift
//  Relist
//
//  Created by uturnr on 2022-05-29.
//
//

import Foundation
import CoreData

@objc(RoutineList)
public class RoutineList: NSManagedObject, Identifiable {
  @nonobjc public class func fetchRequest() -> NSFetchRequest<RoutineList> {
    return NSFetchRequest<RoutineList>(entityName: "RoutineList")
  }
  
  // MARK: Core Data properties

  @NSManaged public private(set) var id: String
  @NSManaged public private(set) var createdDate: Date
  
  @NSManaged public var name: String
  @NSManaged public var orderIndex: Int64
  /// Matches createdDate on creation
  @NSManaged public var updatedDate: Date
  @NSManaged public var tasks: NSSet
  /// Matches createdDate on creation. Manually updating every time a change is
  /// made to child tasks ensures all views render the latest computed data.
  @NSManaged public var tasksUpdatedDate: Date

  // MARK: Computed Core Data properties
  // `tasksUpdatedDate` must be updated to ensure all views render the latest
  // computed data.

  /// The proportion of completed tasks.
  /// Example: 1 of 2 tasks completed => 0.5
  @objc dynamic public var taskCompletion: Double {
    guard let tasks = tasks as? Set<RoutineTask> else {
      return 0
    }

    let tasksCount = tasks.count
    let completedTasksCount = tasks.reduce(0, { total, task in
      total + (task.checked ? 1 : 0)
    })

    return Double(completedTasksCount) / Double(tasksCount)
  }
  
  // MARK: Init override

  public init(
    context: NSManagedObjectContext,
    id: String = UUID().uuidString,
    createdDate: Date = Date.now,
    name: String,
    orderIndex: Int64,
    tasks: NSSet = NSSet()
  ) {
    let entity = NSEntityDescription.entity(forEntityName: "RoutineList", in: context)!
    super.init(entity: entity, insertInto: context)
    self.id = id
    self.createdDate = createdDate
    self.name = name
    self.orderIndex = orderIndex
    self.tasks = tasks
    self.updatedDate = createdDate
    self.tasksUpdatedDate = createdDate
  }
  
  @objc
  override private init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
    super.init(entity: entity, insertInto: context)
  }
  
  @available(*, unavailable)
  public init() {
    fatalError("\(#function) not implemented")
  }
  
  @available(*, unavailable)
  public convenience init(context: NSManagedObjectContext) {
    fatalError("\(#function) not implemented")
  }
}
