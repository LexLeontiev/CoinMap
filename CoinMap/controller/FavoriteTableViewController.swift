//
//  FavoriteTableViewController.swift
//  CoinMap
//
//  Created by Lex Leontiev on 03/11/2017.
//  Copyright © 2017 Mikhail. All rights reserved.
//

import UIKit

class FavoriteTableViewController: UITableViewController {
    
    //MARK: Properties
    
    var favorites = [Place]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // load test data
        loadTestFavorites()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteTableViewCell", for: indexPath)
            as? FavoriteTableViewCell else {
                fatalError("The dequeued cell is not an instance of FavoriteTableViewCell.")
        }
        // Configure the cell...
        let place = favorites[indexPath.row]
        cell.placeNameLabel.text = place.placeName
        cell.categoryNameLabel.text = place.categoryName
        cell.descriptionLabel.text = place.description

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func loadTestFavorites() {
        // create test objects
        let favorite1 = Place(placeName: "Place 1", categoryName: "Shop", description: "Some info here");
        let favorite2 = Place(placeName: "Place 2", categoryName: "Products", description: "Some info here");
        let favorite3 = Place(placeName: "Place 3", categoryName: "Cinema", description: "Some info here");
        
        // add objects to collection
        favorites += [favorite1, favorite2, favorite3]
    }
}
