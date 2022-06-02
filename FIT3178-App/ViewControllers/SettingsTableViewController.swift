//
//  SettingsTableViewController.swift
//  All-NBA
//
//  Created by Samir Gupta on 25/5/2022.
//

import UIKit

/// Sections of setting to be displayed.
private enum SettingSections: String {
    /// The favourites section.
    case favourties = "Favourites"
    /// The notifications section.
    case notifications = "Notifications"
    /// Variable to hold all sections.
    static var all = [favourties, notifications]
    
    /// Function to return a localised string of the enum raw value.
    /// - Returns: The localised string.
    ///
    /// Source found [here.](https://stackoverflow.com/questions/28213693/enum-with-localized-string-in-swift)
    fileprivate func localizedString() -> String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}

/// Custom class to allow user to change their experience with the app.
class SettingsTableViewController: UITableViewController {
    /// The cell identifier of the section.
    private let sectionCellIdentifier =  "sectionCell"
    /// The segue identifier to segue to ``FavouritesSettingsTableViewController``.
    private let favouritesSectionSegue = "favouritesSegue"
    /// The segue identifier to segue to ``NotificationSettingTableViewController``.
    private let notificationsSectionSegue = "notificationsSegue"

    override func viewDidLoad() {
        super.viewDidLoad()
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
        content.text = SettingSections.all[indexPath.row].localizedString()
        cell.contentConfiguration = content

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let segue = SettingSections.all[indexPath.row].rawValue.lowercased() + "Segue"
        performSegue(withIdentifier: segue, sender: self)
    }
}
