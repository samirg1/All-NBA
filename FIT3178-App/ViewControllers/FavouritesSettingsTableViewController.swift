//
//  FavouritesSettingsTableViewController.swift
//  All-NBA
//
//  Created by Samir Gupta on 28/5/2022.
//

import UIKit

/// Custom class to edit the user's favourites.
class FavouritesSettingsTableViewController: UITableViewController {
    /// The section headers of the table view.
    private let SECTION_HEADERS = [NSLocalizedString("PLAYERS", comment: "players"), NSLocalizedString("TEAMS", comment: "teams"), ""]
    /// The section that houses the user's favourite players.
    private let PLAYERS_SECTION = 0
    /// The section that houses the user's favourite teams.
    private let TEAMS_SECTION = 1
    /// The section that houses any additional info.
    private let INFO_SECTION = 2
    /// The identifier of the default cell.
    private let CELL_IDENTIFIER = "favouriteCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getFavourites()
        tableView.reloadData() // reload the favourites each time user enters this page
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == PLAYERS_SECTION {
            return appDelegate.favouritePlayers.count
        }
        else if section == TEAMS_SECTION {
            return appDelegate.favouriteTeams.count
        }
        if appDelegate.favouritePlayers.isEmpty && appDelegate.favouriteTeams.isEmpty {
            return 1
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER, for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        switch indexPath.section {
        case PLAYERS_SECTION:
            let player = appDelegate.favouritePlayers[indexPath.row]
            content.text = player.firstName + " " + player.lastName
            content.secondaryText = player.team.fullName
        case TEAMS_SECTION:
            let team = appDelegate.favouriteTeams[indexPath.row]
            content.text = team.fullName
            content.secondaryText = NSLocalizedString(team.conference, comment: "")
        default:
            content.text = NSLocalizedString("No favourites yet.", comment: "no_favs_yet")
            content.secondaryText = NSLocalizedString("Click the '+' to add some.", comment: "click_+_to_add")
        }
        
        cell.contentConfiguration = content
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section != INFO_SECTION
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.section == PLAYERS_SECTION {
                appDelegate.favouritePlayers.remove(at: indexPath.row)
            }
            else {
                appDelegate.favouriteTeams.remove(at: indexPath.row)
            }
            updateFavourites()
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == PLAYERS_SECTION && appDelegate.favouritePlayers.isEmpty {
            return nil
        }
        if section == TEAMS_SECTION && appDelegate.favouriteTeams.isEmpty {
            return nil
        }
        return SECTION_HEADERS[section]
    }
}
