//
//  DetailedGameTableViewController.swift
//  FIT3178-App
//
//  Created by Samir Gupta on 20/4/22.
//
//  This page is created to show a detailed look at a particular live game by showing the teams major statistics from the game
//  This page is limited by the free API used, and therefore instead of easily retrieving these stats, each individual player's stats is accumulated to provide the final team stats.
//  Another limitation of this page is its inability to produce completely up-to-date stats/scores as the API is only updated every 10 or so minutes

import UIKit

enum StatSections: String { // storage of major statistical categories
    case pts = "points", reb = "rebounds", fg3 = "3-pt field goals", fg = "field goals", ft = "free throws", assists = "assists", blocks = "blocks", steals = "steals", turnovers = "turnovers", fouls = "fouls"
    static let mainVals = [pts, reb, fg3, fg, ft, assists, blocks, steals, turnovers, fouls]
}

class ScoreTableViewCell: UITableViewCell { // cell that has the main scores and images
    @IBOutlet weak var homeImage: UIImageView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var awayImage: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
}

class StatsTableViewCell: UITableViewCell { // cell that houses the stats
    @IBOutlet weak var awayTeamData: UILabel!
    @IBOutlet weak var homeTeamData: UILabel!
}

class DetailedGameTableViewController: UITableViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let fileManagerExtension = "-teamStats"
    
    var gameTitle : String?
    var game : GameData?
    var awayTeamGameData = TeamGameData()
    var homeTeamGameData = TeamGameData()
    var players = [PlayerGameStatsData]()
    
    let SECTION_SCORES = 0
    let SECTION_STATS = 1
    let SCORES_CELL_IDENTIFIER = "scoresCell"
    let STATS_CELL_IDENTIFIER = "statsCell"
    let maxAmountOfPlayers = "40"
    let playerGameStatsSegue = "playersGameStatsSegue"
    
    // indicator to be running whilst calling API in the middle of the tableView
    lazy var indicator: UIActivityIndicatorView = {
        var indicator = UIActivityIndicatorView()
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: tableView.centerYAnchor)
        ])
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = gameTitle
        getTeamsStats(reload: false)
    }
    
    // MARK: Retrieving and Decoding Data
    
    func getTeamsStats(reload: Bool) { // gets the teams stats
        guard let game = game else {
            return // don't do anything if game does not exist
        }

        // check if data has been stored previously
        let fileName = "\(game.id)" + fileManagerExtension
        let localURL = appDelegate.cacheDirectoryPath.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: localURL.path) && !reload {
            
            // if so, decode and update the view
            let data = FileManager.default.contents(atPath: localURL.path)
            if let data = data {
                self.decodePlayersStats(data: data, game: game)
            }
            else {
                displayMessage_sgup0027(title: appDelegate.FILE_MANAGER_DATA_ERROR_TITLE, message: appDelegate.FILE_MANAGER_DATA_ERROR_MESSAGE)
            }
        }
        else {
            
            // otherwise call the API
            indicator.startAnimating()
            Task {
                URLSession.shared.invalidateAndCancel()
                await requestPlayerStatsInGame(game: game)
            }
        }
    }
    
    func decodePlayersStats(data: Data, game: GameData) { // decodes that teams stats data
        do {
            let decoder = JSONDecoder()
            let collection = try decoder.decode(PlayerGameStatsCollectionData.self, from: data)
            if let playersStats = collection.playersGameStats {
                awayTeamGameData = TeamGameData()
                homeTeamGameData = TeamGameData()
                
                // for each player retrieved, add their stats to their team
                for player in playersStats {
                    self.players.append(player)
                    if player.teamId == game.awayTeam.id {
                        awayTeamGameData.addPlayerGameStats(player: player)
                    }
                    else {
                        homeTeamGameData.addPlayerGameStats(player: player)
                    }
                }
                self.tableView.reloadData()
                indicator.stopAnimating()
            }
        }
        catch let error { displayMessage_sgup0027(title: appDelegate.JSON_DECODER_ERROR_TITLE, message: error.localizedDescription) }
    }
    
    @IBAction func refreshCurrentGame(_ sender: Any) { // manual refresh of the current game
        getTeamsStats(reload: true)
    }
    
    func requestPlayerStatsInGame(game: GameData) async { // API call to teams stats data
        var gamesURL = URLComponents()
        gamesURL.scheme = appDelegate.API_URL_SCHEME
        gamesURL.host = appDelegate.API_URL_HOST
        gamesURL.path = appDelegate.API_URL_PATH + appDelegate.API_URL_PATH_STATS
        gamesURL.queryItems = [
            URLQueryItem(name: appDelegate.API_QUERY_GAME_ID, value: "\(game.id)"),
            URLQueryItem(name: appDelegate.API_QUERY_PER_PAGE, value: maxAmountOfPlayers)
        ]
        
        guard let requestURL = gamesURL.url else {
            displayMessage_sgup0027(title: appDelegate.URL_CONVERSION_ERROR_TITLE, message: appDelegate.URL_CONVERSION_ERROR_MESSAGE)
            return
        }
        
        let urlRequest = URLRequest(url: requestURL)
        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            DispatchQueue.main.async {
                self.decodePlayersStats(data: data, game: game)
                let fileName = "\(game.id)" + self.fileManagerExtension
                let localURL = self.appDelegate.cacheDirectoryPath.appendingPathComponent(fileName)
                FileManager.default.createFile(atPath: localURL.path, contents: data, attributes: [:])
            }
        }
        catch let error { displayMessage_sgup0027(title: appDelegate.API_ERROR_TITLE, message: error.localizedDescription) }
    }
    
    // MARK: Gesture Actions
    @IBAction func playerGameStatsSelection(_ sender: Any) { performSegue(withIdentifier: playerGameStatsSegue, sender: self) }
    @IBAction func returnToGamesSwipeAction(_ sender: Any) { navigationController?.popViewController(animated: true) }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if let game = game, let status = game.status {
            if status.hasSuffix("ET") {
                return 1
            }
            else {
                return StatSections.mainVals.count
            }
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let game = game, let homeAbbr = game.homeTeam.abbreviation, let awayAbbr = game.awayTeam.abbreviation, let status = game.status, let time = game.time else {
            return tableView.dequeueReusableCell(withIdentifier: SCORES_CELL_IDENTIFIER, for: indexPath)
        }
        if indexPath.section == SECTION_SCORES {
            let cell = tableView.dequeueReusableCell(withIdentifier: SCORES_CELL_IDENTIFIER, for: indexPath) as! ScoreTableViewCell
            cell.awayImage.image = UIImage(named: awayAbbr)
            cell.homeImage.image = UIImage(named: homeAbbr)
            cell.scoreLabel.text = "\(game.awayScore) - \(game.homeScore)"
            cell.timeLabel.text = time
            cell.statusLabel.text = status
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: STATS_CELL_IDENTIFIER, for: indexPath) as! StatsTableViewCell
            
            let statSection = StatSections.mainVals[indexPath.section-1]
            switch statSection {
            case .pts:
                cell.awayTeamData.text = "\(awayTeamGameData.pts)"
                cell.homeTeamData.text = "\(homeTeamGameData.pts)"
            case .reb:
                cell.awayTeamData.text = "\(awayTeamGameData.dreb) / \(awayTeamGameData.oreb) - \(awayTeamGameData.reb)"
                cell.homeTeamData.text = "\(awayTeamGameData.reb) - \(awayTeamGameData.dreb) / \(awayTeamGameData.oreb)"
            case .assists:
                cell.awayTeamData.text = "\(awayTeamGameData.ast)"
                cell.homeTeamData.text = "\(homeTeamGameData.ast)"
            case .fouls:
                cell.awayTeamData.text = "\(awayTeamGameData.fls)"
                cell.homeTeamData.text = "\(homeTeamGameData.fls)"
            case .turnovers:
                cell.awayTeamData.text = "\(awayTeamGameData.turnover)"
                cell.homeTeamData.text = "\(homeTeamGameData.turnover)"
            case .steals:
                cell.awayTeamData.text = "\(awayTeamGameData.stl)"
                cell.homeTeamData.text = "\(homeTeamGameData.stl)"
            case .blocks:
                cell.awayTeamData.text = "\(awayTeamGameData.blk)"
                cell.homeTeamData.text = "\(homeTeamGameData.blk)"
            case .ft:
                cell.awayTeamData.text = "\(awayTeamGameData.ftm) / \(awayTeamGameData.fta) - \(getPctForStat(made: awayTeamGameData.ftm, attempted: awayTeamGameData.fta))%"
                cell.homeTeamData.text = "\(getPctForStat(made: homeTeamGameData.ftm, attempted: homeTeamGameData.fta))% - \(homeTeamGameData.ftm) / \(homeTeamGameData.fta)"
            case .fg:
                cell.awayTeamData.text = "\(awayTeamGameData.fgm) / \(awayTeamGameData.fga) - \(getPctForStat(made: awayTeamGameData.fgm, attempted: awayTeamGameData.fga))%"
                cell.homeTeamData.text = "\(getPctForStat(made: homeTeamGameData.fgm, attempted: homeTeamGameData.fga))% - \(homeTeamGameData.fgm) / \(homeTeamGameData.fga)"
            case .fg3:
                cell.awayTeamData.text = "\(awayTeamGameData.fgm3) / \(awayTeamGameData.fga3) - \(getPctForStat(made: awayTeamGameData.fgm3, attempted: awayTeamGameData.fga3))%"
                cell.homeTeamData.text = "\(getPctForStat(made: homeTeamGameData.fgm3, attempted: homeTeamGameData.fga3))% - \(homeTeamGameData.fgm3) / \(homeTeamGameData.fga3)"
            }

            return cell
        }
    }
    
    func getPctForStat(made: Int, attempted: Int) -> Int { // gets a percentage of made shots vs attempted shots
        if attempted == 0 {
            return 0
        }
        else {
            return (made*100)/attempted
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == SECTION_SCORES {
            return .none
        }
        return StatSections.mainVals[section-1].rawValue
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textAlignment = NSTextAlignment.center
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == playerGameStatsSegue {
            let destination = segue.destination as! PlayersGameStatsCollectionViewController
            destination.playerGameStats = players
        }
    }
}
