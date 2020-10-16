//
//  Reminder+CoreDataProperties.swift
//  Organizer
//
//  Created by Mihai Cerchez on 01/10/2020.
//  Copyright © 2020 Mihai Cerchez. All rights reserved.
//

import Foundation
import CoreData


extension Reminder {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Reminder> {
        return NSFetchRequest<Reminder>(entityName: "Reminder")
    }

    @NSManaged public var done: Bool
    @NSManaged public var dueDate: NSDate?
    @NSManaged public var geofenceOption: Int16
    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var location: Location?

}
