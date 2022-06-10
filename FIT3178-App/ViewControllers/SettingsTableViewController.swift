//
//  SettingsTableViewController.swift
//  All-NBA
//
//  Created by Samir Gupta on 25/5/2022.
//

import UIKit

/// Sections of setting to be displayed.
fileprivate enum SettingSections: String {
    /// The favourites section.
    case favourties = "Favourites"
    /// The notifications section.
    case notifications = "Notifications"
    /// The about section.
    case about = "About"
    /// The help section.
    case help = "Help"
    /// Variable to hold all the rows in the 'Settings' section.
    static let settings = [favourties, notifications]
    /// Variable to hold all the rows in the 'Other' section.
    static let other = [about, help]
    /// Variable to hold each section.
    static let all = [settings, other]
    
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
    private let CELL_IDENTIFIER =  "sectionCell"
    /// The segue identifier to segue to ``FavouritesSettingsTableViewController``.
    private let FAVOURITES_SEGUE = "favouritesSegue"
    /// The segue identifier to segue to ``NotificationSettingTableViewController``.
    private let NOTIFICATION_SEGUE = "notificationsSegue"
    /// The segue identifer to segue to ``AboutTableViewController``.
    private let ABOUT_SEGUE = "aboutSegue"
    /// The section headers.
    private let TABLE_SECTION_HEADERS = [NSLocalizedString("Settings", comment: ""), NSLocalizedString("Other", comment: "")]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return SettingSections.all.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SettingSections.all[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER, for: indexPath)

        var content = cell.defaultContentConfiguration()
        content.text = SettingSections.all[indexPath.section][indexPath.row].localizedString()
        cell.contentConfiguration = content

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch SettingSections.all[indexPath.section][indexPath.row] {
        case .favourties:
            performSegue(withIdentifier: FAVOURITES_SEGUE, sender: self)
        case .notifications:
            performSegue(withIdentifier: NOTIFICATION_SEGUE, sender: self)
        case .about:
            performSegue(withIdentifier: ABOUT_SEGUE, sender: self)
        case .help: // go to app's website
            if let url = URL(string: "https://all-nba-app.com/") {
                UIApplication.shared.open(url)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return TABLE_SECTION_HEADERS[section]
    }
}
