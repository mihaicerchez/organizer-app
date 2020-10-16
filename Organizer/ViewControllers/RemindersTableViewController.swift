//
//  ReminderTableViewController.swift
//  Organizer
//
//  Created by Mihai Cerchez on 01/10/2020.
//  Copyright © 2020 Mihai Cerchez. All rights reserved.
//
import CoreData
import UIKit



class RemindersTableViewController: DataTableViewController, NSFetchedResultsControllerDelegate {
    
   
    
    enum Sections: Int {
        case ActionSection = 0
        case RemindersSection = 1
    }

    let NewReminderRow = "Task Nou"
    var actionSectionRows = [String]()

    lazy var fetchedResultsController: NSFetchedResultsController = { () -> NSFetchedResultsController<NSFetchRequestResult> in
        let remindersFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Reminder")
        let primarySortDescriptor = NSSortDescriptor(key: "dueDate", ascending: true)
        let secondarySortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        remindersFetchRequest.sortDescriptors = [primarySortDescriptor, secondarySortDescriptor]

        let frc = NSFetchedResultsController(
            fetchRequest: remindersFetchRequest,
            managedObjectContext: self.moc(),
            sectionNameKeyPath: nil,
            cacheName: nil)

        frc.delegate = self

        return frc
    }()
    
    func fetchData() {
        do {
            try self.fetchedResultsController.performFetch()
        } catch {
            print("error at fetchedResultsController.performFetch()")
        }
    }
    
    
    
    // MARK: - View lifecycle
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        self.fetchData()
        self.actionSectionRows = [NewReminderRow]
        
    }
    
    func presentReminderEditionView(with reminder: Reminder?) {
        let reminderEditionVC = self.storyboard?.instantiateViewController(withIdentifier: "ReminderEditionViewController") as! ReminderEditionViewController
        if let rem = reminder {
            reminderEditionVC.setReminder(reminder: rem)
        }
        let navController = UINavigationController(rootViewController: reminderEditionVC)
        self.present(navController, animated: true, completion: nil)
    }

    // MARK: - TableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == Sections.ActionSection.rawValue {
            return self.actionSectionRows.count
        } else {
            if let sectionobjects = self.fetchedResultsController.sections?[0].objects {
                return sectionobjects.count
            }
            return 0
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == Sections.ActionSection.rawValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ActionCell")!
            cell.textLabel?.text = actionSectionRows[indexPath.row]
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderCell")!

            let reminder = self.fetchedResultsController.object(at: fetchedResultControllerIndexPathFromTableViewIndexPath(indexPath)) as! Reminder

            cell.textLabel?.text = reminder.title

            var subtitle = ""
            if let dueDate = reminder.dueDate {
                subtitle += (dueDate as Date).toFormattedString()
            }
            if let location = reminder.location {
                subtitle += subtitle.isEmpty ? location.name! : " - " + location.name!
            }
            cell.detailTextLabel?.text = subtitle

            if reminder.done {
                cell.accessoryType = .checkmark
                cell.detailTextLabel?.font = UIFont.italicSystemFont(ofSize: 12)
            } else {
                cell.accessoryType = .none
                cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
            }

            return cell
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == Sections.ActionSection.rawValue, self.actionSectionRows[indexPath.row] == self.NewReminderRow {
            self.presentReminderEditionView(with: nil)
        } else {
            let reminder = self.fetchedResultsController.object(at: fetchedResultControllerIndexPathFromTableViewIndexPath(indexPath)) as! Reminder
            reminder.done = !reminder.done
            DataHandler.saveData(onContext:self.moc())
            if (reminder.done){
                NotificationHandler.removeReminderNotification(reminder: reminder)
            }
            else {
                NotificationHandler.addNotificationFromReminder(reminder)
            }
        }
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return (indexPath.section == Sections.RemindersSection.rawValue)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if (indexPath.section == Sections.RemindersSection.rawValue) {
            return [UITableViewRowAction.init(style: .destructive, title: "Delete", handler: editReminderAtIndexPath),
                    UITableViewRowAction.init(style: .normal, title: "Edit", handler: editReminderAtIndexPath)]
        }
        return []
    }
    
    func editReminderAtIndexPath(action :UITableViewRowAction, indexPath :IndexPath){
        let reminder = self.fetchedResultsController.object(at: fetchedResultControllerIndexPathFromTableViewIndexPath(indexPath)) as! Reminder
        if (action.style == .destructive){
            NotificationHandler.removeReminderNotification(reminder: reminder)
            DataHandler.deleteObject(reminder, onContext: self.moc(), andCommit: true)
        }
        else {
            self.presentReminderEditionView(with: reminder)
        }
    }
    
    // MARK: - NSFetchedResultsControllerDelegate methods

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            if let deletedIndexPath = indexPath {
                self.tableView.deleteRows(at: [tableViewIndexPathFromFetchedResultControllerIndexPath(deletedIndexPath)], with: .automatic)
            }
        case .insert:
            if let insertedIndexPath = newIndexPath {
                self.tableView.insertRows(at: [tableViewIndexPathFromFetchedResultControllerIndexPath(insertedIndexPath)], with: .automatic)
            } case .move:
            if let deletedIndexPath = indexPath {
                self.tableView.deleteRows(at: [tableViewIndexPathFromFetchedResultControllerIndexPath(deletedIndexPath)], with: .automatic)
            }
            if let insertedIndexPath = newIndexPath {
                self.tableView.insertRows(at: [tableViewIndexPathFromFetchedResultControllerIndexPath(insertedIndexPath)], with: .automatic)
            }
        case .update:
            if let updatedIndexPath = indexPath {
                self.tableView.reloadRows(at: [tableViewIndexPathFromFetchedResultControllerIndexPath(updatedIndexPath)], with: .automatic)
            }
        default:
            return
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }

    func tableViewIndexPathFromFetchedResultControllerIndexPath(_ indexPath: IndexPath) -> IndexPath {
        return IndexPath(row: indexPath.row, section: Sections.RemindersSection.rawValue)
    }
    func fetchedResultControllerIndexPathFromTableViewIndexPath(_ indexPath: IndexPath) -> IndexPath {
        return IndexPath(row: indexPath.row, section: 0)
    }
}

/*class TableViewController: UITableViewController, UISearchResultsUpdating {
    let tableData = ["One", "Two", "Three","Twenty-One"]
    var filteredTableData = [String]()
    var resultSearchController = UISearchController()
    
 
    func updateSearchResults(for searchController: UISearchController) {
        filteredTableData.removeAll(keepingCapacity: false)
        
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
        let array = (tableData as NSArray).filtered(using: searchPredicate)
        filteredTableData = array as! [String]
        
        self.tableView.reloadData()
    }
 
 
    override func viewDidLoad() {
        super.viewDidLoad()

        resultSearchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            
            tableView.tableHeaderView = controller.searchBar
            
            return controller
        })()
        
        // Reload the table
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows
        if  (resultSearchController.isActive) {
            return filteredTableData.count
        } else {
            return tableData.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if (resultSearchController.isActive) {
            cell.textLabel?.text = filteredTableData[indexPath.row]
            
            return cell
        }
        else {
            cell.textLabel?.text = tableData[indexPath.row]
            print(tableData[indexPath.row])
            return cell
        }
    }
    
}

*/
