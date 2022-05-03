//
//  DetailedGameTableViewController.swift
//  FIT3178-App
//
//  Created by Samir Gupta on 20/4/22.
//

import UIKit

class ScoreTableViewCell: UITableViewCell {
    @IBOutlet weak var homeImage: UIImageView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var awayImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
}

class StatsTableViewCell: UITableViewCell {
    @IBOutlet weak var awayTeamData: UILabel!
    @IBOutlet weak var homeTeamData: UILabel!
    @IBOutlet weak var baseLineAlignment: NSLayoutConstraint!
}

class DetailedGameTableViewController: UITableViewController {
    
    var gameTitle : String?
    var game : GameData?
    var teamsGameData: Dictionary<String, Dictionary<String, Int>>?
    
    let SECTION_SCORES = 0
    let SECTION_STATS = 1
    let SCORES_CELL_IDENTIFIER = "scoresCell"
    let STATS_CELL_IDENTIFIER = "statsCell"
    
    var players = [PlayerGameStatsData]()
    
    let maxAmountOfPlayers = "40"
    
    let teamGameDataKeys = [
        ["pts"], ["reb", "dreb", "oreb"], ["fgm3", "fga3"], ["fgm", "fga"], ["ftm", "fta"],
        ["ast"], ["blk"], ["stl"], ["turnover"], ["fls"]
    ]
    let statsSectionHeaders = ["points", "rebounds", "3-pt field goals", "field goals", "free throws", "assists", "blocks", "steals", "turnovers", "fouls"]
    
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
        gamesURL.queryItems = [
            URLQueryItem(name: "game_ids[]", value: "\(String(describing: game!.id))"),
            URLQueryItem(name: "per_page", value: maxAmountOfPlayers)
        ]
        
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
                        self.getTeamsGameData()
                        self.tableView.reloadData()
                    }
                }
                catch let error { print(error) }
            }
        }
        catch let error { print(error) }
    }
    
    func getTeamsGameData() {
        guard let game = game, let awayTeam = game.awayTeam else {
            return
        }
        let awayTeamId = awayTeam.id
        var awayTeamDict = [
            "pts": 0, "reb": 0, "dreb": 0, "oreb": 0, "ast": 0, "blk": 0, "stl": 0,
            "turnover": 0, "fgm3": 0, "fga3": 0, "fgm": 0, "fga": 0,
            "ftm": 0, "fta": 0, "fls": 0,
        ] as [String : Int]
        var homeTeamDict = [
            "pts": 0, "reb": 0, "dreb": 0, "oreb": 0, "ast": 0, "blk": 0, "stl": 0,
            "turnover": 0, "fgm3": 0, "fga3": 0, "fgm": 0, "fga": 0,
            "ftm": 0, "fta": 0, "fls": 0,
        ] as [String : Int]
        
        for player in players {
            var playerTeam = player.teamId == awayTeamId ? awayTeamDict : homeTeamDict
            playerTeam["pts"]! += player.pts
            playerTeam["reb"]! += player.reb
            playerTeam["dreb"]! += player.dreb
            playerTeam["oreb"]! += player.oreb
            playerTeam["ast"]! += player.ast
            playerTeam["blk"]! += player.blk
            playerTeam["stl"]! += player.stl
            playerTeam["turnover"]! += player.turnover
            playerTeam["fgm3"]! += player.fgm3
            playerTeam["fga3"]! += player.fga3
            playerTeam["fgm"]! += player.fgm
            playerTeam["fga"]! += player.fga
            playerTeam["ftm"]! += player.ftm
            playerTeam["fta"]! += player.fta
            playerTeam["fls"]! += player.pf
            
            if player.teamId == awayTeamId {
                awayTeamDict = playerTeam
            }
            else {
                homeTeamDict = playerTeam
            }
        }
        teamsGameData = ["awayTeam": awayTeamDict, "homeTeam": homeTeamDict]
    }
    
    @IBAction func playerGameStatsSelection(_ sender: Any) {
        performSegue(withIdentifier: "playersGameStatsSegue", sender: self)
    }
    
    
    @IBAction func returnToGamesSwipeAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if let game = game, let status = game.status {
            if status.hasSuffix("ET") {
                return 1
            }
            else {
                return teamGameDataKeys.count + 1
            }
        }
        return 1
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
            cell.awayImage.image = UIImage(named: awayAbbr)
            cell.homeImage.image = UIImage(named: homeAbbr)
            cell.scoreLabel.text = "\(awayScore) - \(homeScore)"
            cell.timeLabel.text = time
            cell.statusLabel.text = status
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: STATS_CELL_IDENTIFIER, for: indexPath) as! StatsTableViewCell
            
            let keys = teamGameDataKeys[indexPath.section-1]
            guard let teamData = teamsGameData, let awayTeamData = teamData["awayTeam"], let homeTeamData = teamData["homeTeam"] else {
                return cell
            }
            
            if keys.count == 1 {
                cell.awayTeamData.text = String(describing: awayTeamData[keys[0]]!)
                cell.homeTeamData.text = String(describing: homeTeamData[keys[0]]!)
            }
            else if keys.count == 2 {
                let a_made = awayTeamData[keys[0]]!
                let a_missed = awayTeamData[keys[1]]!
                let a_pct = (a_made*100)/a_missed
                let h_made = homeTeamData[keys[0]]!
                let h_missed = homeTeamData[keys[1]]!
                let h_pct = (h_made*100)/h_missed
                
                cell.awayTeamData.text = "\(a_made) / \(a_missed) - \(a_pct)%"
                cell.homeTeamData.text = "\(h_pct)% - \(h_made) / \(h_missed)"
            }
            else if keys.count == 3 {
                cell.awayTeamData.text = "\(awayTeamData[keys[1]]!) / \(awayTeamData[keys[2]]!) - \(awayTeamData[keys[0]]!)"
                cell.homeTeamData.text = "\(homeTeamData[keys[0]]!) - \(homeTeamData[keys[1]]!) / \(homeTeamData[keys[2]]!)"
            }
            

            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == SECTION_SCORES {
            return .none
        }
        return statsSectionHeaders[section-1]
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textAlignment = NSTextAlignment.center
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! PlayersGameStatsCollectionViewController
        destination.playerGameStats = players
    }
}
