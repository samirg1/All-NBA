//
//  FavouritesTableViewController.swift
//  All-NBA
//
//  Created by Samir Gupta on 31/5/2022.
//

import UIKit

class FavouritePlayerTableCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var seasonStatsLabel: UILabel!
    @IBOutlet weak var recentGameScoreLabel: UILabel!
    @IBOutlet weak var recentGameLabel: UILabel!
}

class FavouriteTeamTableCell: UITableViewCell {
    
}


class FavouritesTableViewController: UITableViewController {
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    private let currentSeason = "2021"
    private let playerCellIdentifier = "playerCell"
    private let teamCellIdentifier = "teamCell"
    private let infoCellIdentifier = "infoCell"
    private let playerSection = 0
    private let teamSection = 1
    private let infoSection = 2
    
    private var playerData: [FavouritePlayerDetails] = []
    private var recentTeamGames: [GameData] = []
    
    private lazy var indicator: UIActivityIndicatorView = {
        var indicator = UIActivityIndicatorView()
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.addSubview(indicator)
        NSLayoutConstraint.activate([ indicator.centerXAnchor.constraint(equalTo: tableView.centerXAnchor), indicator.centerYAnchor.constraint(equalTo: tableView.centerYAnchor) ])
        return indicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getFavourites()
        indicator.startAnimating()
        playerData.removeAll()
        recentTeamGames.removeAll()
        updatePlayerContainers()
    }
    
    func updatePlayerContainers() {
        for player in appDelegate.favouritePlayers {
            let newPlayer = FavouritePlayerDetails(player.id)
            getPlayerSeasonStats(player: newPlayer)
            getPlayersLastGame(player: newPlayer)
        }
    }
    
    func getPlayerSeasonStats(player: FavouritePlayerDetails) {
        let fileName = "\(player.id)" + FileManagerFiles.player_season_stats_suffix.rawValue
        if doesFileExist(name: fileName) {
            if let data = getFileData(name: fileName) {
                return decodePlayerSeasonStats(data: data, player: player)
            }
            return displayMessage_sgup0027(title: FILE_MANAGER_DATA_ERROR_TITLE, message: FILE_MANAGER_DATA_ERROR_MESSAGE)
        }
        else {
            indicator.startAnimating()
            Task {
                URLSession.shared.invalidateAndCancel()
                let (data, error) = await requestData(path: .averages, queries: [.player_ids : "\(player.id)"])
                guard let data = data else {
                    displayMessage_sgup0027(title: error!.title, message: error!.message)
                    indicator.stopAnimating()
                    return
                }
                
                // update/create a file to persistently store the data retrieved
                setFileData(name: fileName, data: data)
                decodePlayerSeasonStats(data: data, player: player)
                indicator.stopAnimating()
            }
        }
    }
    
    func decodePlayerSeasonStats(data: Data, player: FavouritePlayerDetails) {
        do {
            let decoder = JSONDecoder()
            let collection = try decoder.decode(PlayerSeasonStatCollection.self, from: data)
            if let players = collection.players {
                player.seasonStats = players[0]
                if !player.isNil(){ playerData.append(player) }
            }
            tableView.reloadData()
        }
        catch let error {
            displayMessage_sgup0027(title: JSON_DECODER_ERROR_TITLE, message: error.localizedDescription)
        }
    }
    
    func getPlayersLastGame(player: FavouritePlayerDetails) {
        indicator.startAnimating()
        Task {
            URLSession.shared.invalidateAndCancel()
            let (data, error) = await requestData(path: .stats, queries: [.player_ids: "\(player.id)", .seasons: currentSeason, .per_page: "82"])
            guard let data = data else {
                displayMessage_sgup0027(title: error!.title, message: error!.message)
                indicator.stopAnimating()
                return
            }
            do {
                let decoder = JSONDecoder()
                let collection = try decoder.decode(PlayerGameStatsCollectionData.self, from: data)
                if let playerStats = collection.playersGameStats {
                    let sortedGames = playerStats.sorted { p1, p2 in
                        return p1.gameDate < p2.gameDate
                    }
                    player.recentGame = sortedGames.last!
                    if !player.isNil(){ playerData.append(player) }
                }
                tableView.reloadData()
                indicator.stopAnimating()
            }
            catch let error {
                displayMessage_sgup0027(title: JSON_DECODER_ERROR_TITLE, message: error.localizedDescription)
            }
        }
    }
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var c = 0
        for p in playerData {
            if !p.isNil() {
                c+=1
            }
        }
        
        if section == playerSection {
            return c
        }
        else if section == teamSection {
            return recentTeamGames.count
        }
        if c == 0 && recentTeamGames.count == 0 {
            return 1
        }
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == infoSection {
            let cell = tableView.dequeueReusableCell(withIdentifier: infoCellIdentifier, for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = "No favourites yet."
            content.secondaryText = "Click 'Edit' to add some."
            cell.contentConfiguration = content
            return cell
        }
        else if indexPath.section == playerSection {
            let cell = tableView.dequeueReusableCell(withIdentifier: playerCellIdentifier, for: indexPath) as! FavouritePlayerTableCell
            
            let stats = playerData[indexPath.row].seasonStats!
            let lastGame = playerData[indexPath.row].recentGame!
            cell.nameLabel.text = lastGame.playerFirstName + " " + lastGame.playerLastName
            cell.seasonStatsLabel.text = "\(stats.pts) PPG - \(stats.ast) APG - \(stats.reb) RPG"
            cell.recentGameScoreLabel.text = "\(teamIdToAbbreviations[lastGame.gameHomeTeamId]!) \(lastGame.gameHomeScore) vs \(lastGame.gameAwayScore) \(teamIdToAbbreviations[lastGame.gameAwayTeamId]!)"
            cell.recentGameLabel.text = "\(lastGame.pts) PTS - \(lastGame.ast) AST - \(lastGame.reb) REB"
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: playerCellIdentifier, for: indexPath)
        // Configure the cell...

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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
