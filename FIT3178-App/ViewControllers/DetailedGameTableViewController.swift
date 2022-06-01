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

private enum StatSections: String { // storage of major statistical categories
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
    
    // variables to check whether the view needs to be updated based on what has happened on other views
    public var reloaded = false
    public var toBeReloaded = false
    
    public var gameTitle : String?
    public var game : GameData?
    private var awayTeamGameData = TeamGameData()
    private var homeTeamGameData = TeamGameData()
    private var players = [PlayerGameStatsData]()
    
    private let SECTION_SCORES = 0
    private let SECTION_STATS = 1
    private let SCORES_CELL_IDENTIFIER = "scoresCell"
    private let STATS_CELL_IDENTIFIER = "statsCell"
    private let maxAmountOfPlayers = "40"
    private let playerGameStatsSegue = "playersGameStatsSegue"
    
    // indicator to be running whilst calling API in the middle of the tableView
    private lazy var indicator: UIActivityIndicatorView = {
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
        futureGameCheck()
        getTeamsStats(reload: toBeReloaded)
    }
    
    // MARK: Retrieving and Decoding Data
    
    private func getTeamsStats(reload: Bool) { // gets the teams stats
        guard let game = game else {
            return // don't do anything if game does not exist
        }

        // check if data has been stored previously
        let fileName = "\(game.id)" + FileManagerFiles.team_game_stats_suffix.rawValue
        if doesFileExist(name: fileName) && !reload {
            // if so, decode and update the view
            if let data = getFileData(name: fileName) {
                return decodePlayersStats(data: data, game: game)
            }
            return displayMessage_sgup0027(title: FILE_MANAGER_DATA_ERROR_TITLE, message: FILE_MANAGER_DATA_ERROR_MESSAGE)
        }
        else {
            
            // otherwise call the API
            indicator.startAnimating()
            reloaded = !toBeReloaded
            toBeReloaded = false
            Task {
                let (data, error) = await requestData(path: .stats, queries: [.game_ids : "\(game.id)", .per_page: maxAmountOfPlayers])
                guard let data = data else {
                    displayMessage_sgup0027(title: error!.title, message: error!.message)
                    indicator.stopAnimating()
                    return
                }
                
                // update/create a file to persistently store the data retrieved
                setFileData(name: fileName, data: data)
                decodePlayersStats(data: data, game: game)
            }
        }
    }
    
    private func decodePlayersStats(data: Data, game: GameData) { // decodes that teams stats data
        do {
            let decoder = JSONDecoder()
            let collection = try decoder.decode(PlayerGameStatsCollectionData.self, from: data)
            if let playersStats = collection.playersGameStats {
                awayTeamGameData = TeamGameData()
                homeTeamGameData = TeamGameData()
                players.removeAll()
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
        catch let error {
            displayMessage_sgup0027(title: JSON_DECODER_ERROR_TITLE, message: error.localizedDescription)
            indicator.stopAnimating()
        }
    }
    
    @IBAction public func refreshCurrentGame(_ sender: Any) { // manual refresh of the current game
        getTeamsStats(reload: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let gameViewController = navigationController?.topViewController as? GamesTableViewController {
            gameViewController.toBeReloaded = reloaded
        }
    }
    
    private func isGameInFuture() -> Bool {
        if let game = game, let status = game.status {
            return !status.hasSuffix("ET")
        }
        return false
    }
    
    @IBOutlet weak var playersButton: UIButton!
    @IBOutlet var playersGestureAction: UISwipeGestureRecognizer!
    private func futureGameCheck() {
        if isGameInFuture() {
            playersButton.isEnabled = true
            playersGestureAction.isEnabled = true
        }
        else {
            playersButton.isEnabled = false
            playersGestureAction.isEnabled = false
        }
    }
    
    // MARK: Gesture Actions
    @IBAction private func playerGameStatsSelection(_ sender: Any) { performSegue(withIdentifier: playerGameStatsSegue, sender: self) }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return isGameInFuture() ? StatSections.mainVals.count : 1
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
            
            if status.hasSuffix("T"){
                cell.statusLabel.text = APItoCurrentTimeZoneDisplay(string: status)
            }
            else {
                cell.statusLabel.text = status
            }
            
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
                cell.homeTeamData.text = "\(homeTeamGameData.reb) - \(homeTeamGameData.dreb) / \(homeTeamGameData.oreb)"
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
    
    private func getPctForStat(made: Int, attempted: Int) -> Int { // gets a percentage of made shots vs attempted shots
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
