//
//  DataViewController.swift
//  Organizer
//
//  Created by Mihai Cerchez on 01/10/2020.
//  Copyright © 2020 Mihai Cerchez. All rights reserved.
//
import UIKit
import CoreData

protocol MOCHolderProtocol {
    var context: NSManagedObjectContext! {get set}
}
extension MOCHolderProtocol {
    mutating func setupContext(context: NSManagedObjectContext) {
        self.context = context
    }
    func moc() -> NSManagedObjectContext {
        if (self.context == nil) {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            return appDelegate.persistentContainer.viewContext
        }
        return self.context
    }
}

class DataTableViewController : UITableViewController, MOCHolderProtocol {
    var context: NSManagedObjectContext!
}
class DataViewController : UIViewController, MOCHolderProtocol {
    var context: NSManagedObjectContext!
}
