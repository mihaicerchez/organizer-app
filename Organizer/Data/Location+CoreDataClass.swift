//
//  Location+CoreDataClass.swift
//  Organizer
//
//  Created by Mihai Cerchez on 01/10/2020.
//  Copyright © 2020 Mihai Cerchez. All rights reserved.
//

import Foundation
import CoreData

@objc(Location)
public class Location: NSManagedObject {
    
    func titleString() -> String {
        return String(format: "%@ - %.0fm radius", (self.name ?? ""), self.radius)
    }
    
    func remindersCountString() -> String {
        let count = self.reminders?.count
        let reminderString = count! < 2 ? "reminder" : "reminders"
        return "\(count ?? 0) \(reminderString)"
    }
}
