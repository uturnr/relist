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
  
  // MARK: Init override
  public init(
    context: NSManagedObjectContext,
    id: String = UUID().uuidString,
    createdDate: Date = Date.now,
    name: String,
    orderIndex: Int64,
    updatedDate: Date = Date.now,
    tasks: NSSet = NSSet()
  ) {
    let entity = NSEntityDescription.entity(forEntityName: "RoutineList", in: context)!
    super.init(entity: entity, insertInto: context)
    self.id = id
    self.createdDate = createdDate
    self.name = name
    self.orderIndex = orderIndex
    // TODO: Not sure if this is a valid way to init tasks
    self.tasks = tasks
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
