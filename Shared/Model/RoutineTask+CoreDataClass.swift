import Foundation
import CoreData

@objc(RoutineTask)
public class RoutineTask: NSManagedObject, Identifiable {
  @nonobjc public class func fetchRequest() -> NSFetchRequest<RoutineTask> {
    return NSFetchRequest<RoutineTask>(entityName: "RoutineTask")
  }
  
  // MARK: Core Data properties

  @NSManaged public private(set) var createdDate: Date
  @NSManaged public private(set) var id: String
  
  @NSManaged public var checked: Bool
  @NSManaged public var completed: Bool
  @NSManaged public var name: String
  @NSManaged public var orderIndex: Int64
  /// Matches createdDate on creation
  @NSManaged public var updatedDate: Date
  @NSManaged public var list: RoutineList
  
  // MARK: Init override

  public init(
    context: NSManagedObjectContext,
    id: String = UUID().uuidString,
    checked: Bool = false,
    createdDate: Date = Date.now,
    list: RoutineList,
    name: String,
    orderIndex: Int64
  ) {
    let entity = NSEntityDescription.entity(forEntityName: "RoutineTask", in: context)!
    super.init(entity: entity, insertInto: context)
    self.id = id
    self.checked = checked
    self.createdDate = createdDate
    self.name = name
    self.orderIndex = orderIndex
    self.list = list
    self.updatedDate = createdDate
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
