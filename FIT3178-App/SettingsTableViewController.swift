//
//  SettingsTableViewController.swift
//  All-NBA
//
//  Created by Samir Gupta on 25/5/2022.
//

import UIKit

private enum SettingSections: String {
    case favourties = "Favourites"
    case notifications = "Notifications"
    static var all = [favourties, notifications]
}

class SettingsTableViewController: UITableViewController {
    
    let sectionCellIdentifier =  "sectionCell"
    let favouritesSectionSegue = "favouritesSegue"
    let notificationsSectionSegue = "notificationsSegue"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return SettingSections.all.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: sectionCellIdentifier, for: indexPath)

        var content = cell.defaultContentConfiguration()
        content.text = SettingSections.all[indexPath.row].rawValue
        content.secondaryText = ">"
        cell.contentConfiguration = content

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let segue = SettingSections.all[indexPath.row].rawValue.lowercased() + "Segue"
        performSegue(withIdentifier: segue, sender: self)
    }

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
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
