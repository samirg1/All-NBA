//
//  FavouritesSettingsTableViewController.swift
//  All-NBA
//
//  Created by Samir Gupta on 28/5/2022.
//

import UIKit

class FavouritesSettingsTableViewController: UITableViewController {
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let sectionHeaders = ["PLAYERS", "TEAMS", ""]
    private let playersSection = 0
    private let teamSection = 1
    private let infoSection = 2
    private let cellIdentifier = "favouriteCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        appDelegate.getFavourites()
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == playersSection {
            return appDelegate.favouritePlayers.count
        }
        else if section == teamSection {
            return appDelegate.favouriteTeams.count
        }
        if appDelegate.favouritePlayers.count > 0 || appDelegate.favouriteTeams.count > 0 {
            return 0
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        var content = cell.defaultContentConfiguration()
        
        switch indexPath.section {
        case playersSection:
            let player = appDelegate.favouritePlayers[indexPath.row]
            content.text = player.firstName + " " + player.lastName
            content.secondaryText = player.team.fullName
        case teamSection:
            let team = appDelegate.favouriteTeams[indexPath.row]
            content.text = team.fullName
            content.secondaryText = team.conference
        default:
            content.text = "No favourites yet"
            content.secondaryText = "Click the '+' to add some"
        }
        
        cell.contentConfiguration = content
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section != infoSection
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.section == playersSection {
                appDelegate.favouritePlayers.remove(at: indexPath.row)
            }
            else {
                appDelegate.favouriteTeams.remove(at: indexPath.row)
            }
            appDelegate.updateFavourites()
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == playersSection && appDelegate.favouritePlayers.isEmpty {
            return nil
        }
        if section == teamSection && appDelegate.favouriteTeams.isEmpty {
            return nil
        }
        return sectionHeaders[section]
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}