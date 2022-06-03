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
    /// The about section.
    case about = "About"
    /// The help section.
    case help = "Help"
    /// Variable to hold all the rows in the 'Settings' section.
    static var settings = [favourties, notifications]
    /// Variable to hold all the rows in the 'Other' section.
    static var other = [about, help]
    static var all = [settings, other]
    
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
    /// The segue identifer to segue to ``AboutTableViewController``.
    private let aboutSectionSegue = "aboutSegue"
    /// The section headers.
    private let sectionHeaders = [NSLocalizedString("Settings", comment: ""), NSLocalizedString("Other", comment: "")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return SettingSections.all.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return SettingSections.all[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: sectionCellIdentifier, for: indexPath)

        var content = cell.defaultContentConfiguration()
        content.text = SettingSections.all[indexPath.section][indexPath.row].localizedString()
        cell.contentConfiguration = content

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch SettingSections.all[indexPath.section][indexPath.row] {
        case .favourties:
            performSegue(withIdentifier: favouritesSectionSegue, sender: self)
        case .notifications:
            performSegue(withIdentifier: notificationsSectionSegue, sender: self)
        case .about:
            performSegue(withIdentifier: aboutSectionSegue, sender: self)
        case .help:
            if let url = URL(string: "https://all-nba-app.com/") {
                UIApplication.shared.open(url)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionHeaders[section]
    }
}
