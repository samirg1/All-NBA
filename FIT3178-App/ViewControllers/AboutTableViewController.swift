//
//  AboutTableViewController.swift
//  All-NBA
//
//  Created by Samir Gupta on 3/6/2022.
//

import UIKit

/// Class to show the user the about information, credits and contact information.
class AboutTableViewController: UITableViewController {
    
    /// The row titles to show in this view controller.
    private let TABLE_ROWS = [
        NSLocalizedString("About", comment: "about"),
        NSLocalizedString("Credits", comment: "credits"),
        NSLocalizedString("Contact", comment: "contact")
    ]
    /// The details of each row to show in this view controller.
    let TABLE_DETAILS = [
        NSLocalizedString("All-NBA was designed as part of a University project to deliver a personalised and effective way to keep up to date in the NBA. Live scores and stats with options for personalisations to enable a quick and easy use of the App to find the information you desire.", comment: "about_info"),
        NSLocalizedString( "- Monash University", comment: "credit_info"),
        NSLocalizedString("For any feedback and enquires feel free to make contact.\nEmail: srgupta@bigpond.com\nSocials: samir.g1", comment: "contact_info")
    ]
    /// The cell identifer.
    let CELL_IDENTIFIER = "aboutCell"

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TABLE_ROWS.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER, for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = TABLE_ROWS[indexPath.row]
        content.secondaryText = TABLE_DETAILS[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }
}
