//
//  DetailedGameTableViewController.swift
//  FIT3178-App
//
//  Created by Samir Gupta on 20/4/22.
//

import UIKit

class ScoreTableViewCell: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
}

class DetailedGameTableViewController: UITableViewController {
    
    var gameTitle : String?
    var game : GameData?
    
    let SECTION_SCORES = 0
    let SECTION_STATS = 1
    let SCORES_CELL_IDENTIFIER = "scoresCell"
    let STATS_CELL_IDENTIFIER = "statsCell"
    
    var players = [PlayerGameStatsData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = gameTitle
        
        Task {
            URLSession.shared.invalidateAndCancel()
            await requestPlayerStatsInGame()
        }
    }

    func requestPlayerStatsInGame() async {
        var gamesURL = URLComponents()
        gamesURL.scheme = "https"
        gamesURL.host = "www.balldontlie.io"
        gamesURL.path = "/api/v1/stats"
        gamesURL.queryItems = [URLQueryItem(name: "game_ids[]", value: "\(String(describing: game!.id))")]
        
        guard let requestURL = gamesURL.url else {
            print("Invalid URL")
            return
        }
        
        let urlRequest = URLRequest(url: requestURL)
        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            DispatchQueue.main.async {
                do {
                    let decoder = JSONDecoder()
                    let collection = try decoder.decode(PlayerGameStatsCollectionData.self, from: data)
                    if let playersStats = collection.playersGameStats {
                        self.players.append(contentsOf: playersStats)
                        self.tableView.reloadData()
                    }
                }
                catch let error { print(error) }
            }
        }
        catch let error { print(error) }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let game = game, let homeScore = game.homeScore, let awayScore = game.awayScore, let awayTeam = game.awayTeam, let homeTeam = game.homeTeam, let homeAbbr = homeTeam.abbreviation, let awayAbbr = awayTeam.abbreviation, let status = game.status, let time = game.time else {
            return tableView.dequeueReusableCell(withIdentifier: SCORES_CELL_IDENTIFIER, for: indexPath)
        }
        if indexPath.section == SECTION_SCORES {
            let cell = tableView.dequeueReusableCell(withIdentifier: SCORES_CELL_IDENTIFIER, for: indexPath) as! ScoreTableViewCell
            //cell.awayTeamImage.image = UIImage(named: awayAbbr)
            //cell.homeTeamImage.image = UIImage(named: homeAbbr)
            //cell.scoreLabel.text = "\(awayScore) - \(homeScore)"
            //cell.timeLabel.text = time
            //cell.statusLabel.text = status
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: STATS_CELL_IDENTIFIER, for: indexPath)

            // Configure the cell...

            return cell
        }
        
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
