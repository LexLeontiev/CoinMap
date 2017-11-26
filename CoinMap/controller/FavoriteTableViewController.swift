//
//  FavoriteTableViewController.swift
//  CoinMap
//
//  Created by Lex Leontiev on 03/11/2017.
//  Copyright © 2017 Mikhail. All rights reserved.
//

import UIKit
import CoreData

class FavoriteTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var placeManager: DataManagerProtocol!
    fileprivate var fetchedController: NSFetchedResultsController<CorePlace>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load core data place manager
        self.placeManager = CoreDataManager(context: context)
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem
        
        // init core data controller integration
        let fetchRequest = NSFetchRequest<CorePlace>(entityName: "CorePlace")
        let sortDescriptor = NSSortDescriptor(key: "placeName", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedController = NSFetchedResultsController(
            fetchRequest: fetchRequest
            , managedObjectContext: context
            , sectionNameKeyPath: nil
            , cacheName: nil)
        fetchedController?.delegate = self
        try! fetchedController?.performFetch()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteTableViewCell", for: indexPath)
            as? FavoriteTableViewCell else {
                fatalError("The dequeued cell is not an instance of FavoriteTableViewCell.")
        }
         // Configure the cell...
        if let place = fetchedController?.object(at: indexPath) {
            cell.placeNameLabel.text = place.placeName
            cell.categoryNameLabel.text = place.categoryName
            cell.descriptionLabel.text = place.desc
        }
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let place = fetchedController?.object(at: indexPath) {
                self.placeManager.removePlace(id: Int(place.placeId))
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedController?.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        
        return 0
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let sections = fetchedController?.sections {
            return sections.count
        }
        
        return 0
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView?.insertRows(at: [indexPath], with: .fade)
            }
            
        case .delete:
            if let indexPath = indexPath {
                tableView?.deleteRows(at: [indexPath], with: .fade)
            }
            
        case .update:
            if let indexPath = indexPath {
                tableView?.reloadRows(at: [indexPath], with: .none)
            }
            
        case .move:
            if let indexPath = indexPath {
                tableView?.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView?.insertRows(at: [newIndexPath], with: .fade)
            }
        }
    }
    
    @IBAction func addPlace(_ sender: Any) {
        let alert = UIAlertController(title: "New place",message: "Add a new place", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save place",style: .default) {
                                        [unowned self] action in
                                        guard let textField = alert.textFields?.first,
                                            let nameToSave = textField.text else {
                                                return
                                        }
                                        let generatedPlace : Place = TestData.createRandomPlace()
                                        let newPlace = Place(id: generatedPlace.id, placeName: nameToSave, categoryName: generatedPlace.categoryName, desc: generatedPlace.desc)
                                        self.placeManager.savePlace(place: newPlace)
        }
        let cancelAction = UIAlertAction(title: "Cancel",style: .default)
        
        alert.addTextField()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}
