//
//  RoutineList+CoreDataProperties.swift
//  Relist
//
//  Created by uturnr on 2022-05-29.
//
//

import Foundation
import CoreData

// MARK: Generated accessors for tasks
extension RoutineList {

    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: RoutineTask)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: RoutineTask)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSSet)

}
