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

/// Storage of major statistical categories of NBA games to be displayed by this view controller.
private enum StatSections: String {
    /// The amount of points scored.
    case pts = "Points"
    /// The amount of rebounds secured.
    case reb = "Rebounds"
    /// The amount of 3-pointers shot.
    case fg3 = "3-pt field goals"
    /// The amount of shots taken.
    case fg = "Field Goals"
    /// The amount of free throws taken.
    case ft = "Free Throws"
    /// The amount of assists acured.
    case assists = "Assists"
    /// The amount of blocks.
    case blocks = "Blocks"
    /// The amount of steals.
    case steals = "Steals"
    /// The amount of turnovers.
    case turnovers = "Turnovers"
    /// The amount of fouls.
    case fouls = "Fouls"
    /// A collection of the main statistical categories of NBA games.
    static let mainVals = [pts, reb, fg3, fg, ft, assists, blocks, steals, turnovers, fouls]
    
    /// Function to return a localised string of the enum raw value.
    /// - Returns: The localised string.
    ///
    /// Source found [here.](https://stackoverflow.com/questions/28213693/enum-with-localized-string-in-swift)
    fileprivate func localizedString() -> String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}

/// Custom table cell to show a summary of the game.
class ScoreTableViewCell: UITableViewCell {
    /// The logo of the home team.
    @IBOutlet weak var homeImage: UIImageView!
    /// The label describing the current score of the game.
    @IBOutlet weak var scoreLabel: UILabel!
    /// The logo of the away team.
    @IBOutlet weak var awayImage: UIImageView!
    /// The label describing the current time left in the game.
    @IBOutlet weak var timeLabel: UILabel!
    /// The label describing the current status of the game.
    @IBOutlet weak var statusLabel: UILabel!
}

/// Custom table cell to show game stats of each team.
class StatsTableViewCell: UITableViewCell {
    /// The label for the away team's stats.
    @IBOutlet weak var awayTeamData: UILabel!
    /// The label for the home team's stats.
    @IBOutlet weak var homeTeamData: UILabel!
}

/// Custom table class to display a detailed view of a game the user has selected from ``GamesTableViewController``.
///
/// This class displays the teams statistics side by side for a simplistic and easily readable analysis of the game.
class DetailedGameTableViewController: UITableViewController {
    
    /// The game title of the game being displayed.
    public var gameTitle : String?
    /// The game being displayed.
    public var game : Game?
    /// The away team's stats from the game.
    private var awayTeamGameData = TeamGameStats()
    /// The home team's stats from the game.
    private var homeTeamGameData = TeamGameStats()
    /// The players stats for each player that played in the game.
    private var players = [PlayerGameStats]()
    
    /// The section that houses the summary of the game and score.
    private let SECTION_SCORES = 0
    /// The section that houses the stats.
    private let SECTION_STATS = 1
    /// The cell identifier of the cell used to provide a summary of the game.
    private let SCORES_CELL_IDENTIFIER = "scoresCell"
    /// The cell identifier of the cell used to house stats.
    private let STATS_CELL_IDENTIFIER = "statsCell"
    /// The maximum amount of players deemed to play in a particular game.
    private let maxAmountOfPlayers = "40"
    /// The segue identifier for the segue to view the player's detailed breakdown in ``PlayersGameStatsCollectionViewController``.
    private let playerGameStatsSegue = "playersGameStatsSegue"
    
    /// Indicator used to indicate if there are any asynchronous tasks active.
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getTeamsStats(reload: false)
    }
    
    // MARK: Retrieving and Decoding Data
    
    /// Gets teams stats of each team involved in the game.
    /// - Parameters:
    ///     - reload: Whether or not the data should be updated noisily (with indicator) or not.
    private func getTeamsStats(reload: Bool) { // gets the teams stats
        guard let game = game else {
            return // don't do anything if game does not exist
        }

        // check if data has been stored previously
        let fileName = "\(game.id)" + FileManagerFiles.team_game_stats_suffix.rawValue
        if doesFileExist(name: fileName) {
            // if so, decode and update the view
           guard let data = getFileData(name: fileName) else {
               return displaySimpleMessage(title: FILE_MANAGER_DATA_ERROR_TITLE, message: FILE_MANAGER_DATA_ERROR_MESSAGE)
            }
            decodePlayersStats(data: data, game: game)
        }
        else {
            indicator.startAnimating() // noisily update view if no file exists yet
        }
        
        // silently update view if user has not selected to reload
        if reload { indicator.startAnimating() }
            
            // otherwise call the API
            Task {
                let (data, error) = await requestData(path: .stats, queries: [.game_ids : "\(game.id)", .per_page: maxAmountOfPlayers])
                guard let data = data else {
                    displaySimpleMessage(title: error!.title, message: error!.message)
                    indicator.stopAnimating()
                    return
                }
                
                // update/create a file to persistently store the data retrieved
                setFileData(name: fileName, data: data)
                decodePlayersStats(data: data, game: game)
            }
    }
    
    /// Decoding the player's stats after retrieval of data from the API.
    /// - Parameters:
    ///     - data: The data to decode.
    ///     - game: The game the player is in.
    private func decodePlayersStats(data: Data, game: Game) {
        do {
            let decoder = JSONDecoder()
            let collection = try decoder.decode(PlayerGameStatsCollection.self, from: data)
            if let playersStats = collection.playersGameStats {
                awayTeamGameData = TeamGameStats()
                homeTeamGameData = TeamGameStats()
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
            displaySimpleMessage(title: JSON_DECODER_ERROR_TITLE, message: error.localizedDescription)
            indicator.stopAnimating()
        }
    }
    
    /// Action to manually refresh the current game.
    /// - Parameters:
    ///     - sender: The triggerer of this action.
    @IBAction private func refreshCurrentGame(_ sender: Any) { // manual refresh of the current game
        getTeamsStats(reload: true)
    }
    
    // MARK: Miscellaneous
    
    /// Determine if the current game is in the future or not.
    /// - Returns: Whether or not the game is in the future.
    private func isGameInFuture() -> Bool {
        if let game = game, let status = game.status {
            return !status.hasSuffix("ET")
        }
        return false
    }
    
    /// The button that segues to  ``PlayersGameStatsCollectionViewController``.
    @IBOutlet weak var playersButton: UIButton!
    /// The gesture outlet to segue to ``PlayersGameStatsCollectionViewController``.
    @IBOutlet var playersGestureAction: UISwipeGestureRecognizer!
    
    /// Check if the game being displayed is in the future and make necessary changes.
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
    
    /// Get the percentage of made shots vs attempted.
    /// - Parameters:
    ///     - made: The amount of shots made.
    ///     - attempted: The amount of shots attempted.
    /// - Returns: The integer percentage of made shots.
    private func getPercentageFromShots(made: Int, attempted: Int) -> Int {
        if attempted == 0 {
            return 0
        }
        else {
            return (made*100)/attempted
        }
    }
    
    // MARK: Gesture Actions
    
    /// Gesture action to segue to ``PlayersGameStatsCollectionViewController``.
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
                cell.statusLabel.text = NSLocalizedString(status, comment: "")
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
                cell.awayTeamData.text = "\(awayTeamGameData.ftm) / \(awayTeamGameData.fta) - \(getPercentageFromShots(made: awayTeamGameData.ftm, attempted: awayTeamGameData.fta))%"
                cell.homeTeamData.text = "\(getPercentageFromShots(made: homeTeamGameData.ftm, attempted: homeTeamGameData.fta))% - \(homeTeamGameData.ftm) / \(homeTeamGameData.fta)"
            case .fg:
                cell.awayTeamData.text = "\(awayTeamGameData.fgm) / \(awayTeamGameData.fga) - \(getPercentageFromShots(made: awayTeamGameData.fgm, attempted: awayTeamGameData.fga))%"
                cell.homeTeamData.text = "\(getPercentageFromShots(made: homeTeamGameData.fgm, attempted: homeTeamGameData.fga))% - \(homeTeamGameData.fgm) / \(homeTeamGameData.fga)"
            case .fg3:
                cell.awayTeamData.text = "\(awayTeamGameData.fgm3) / \(awayTeamGameData.fga3) - \(getPercentageFromShots(made: awayTeamGameData.fgm3, attempted: awayTeamGameData.fga3))%"
                cell.homeTeamData.text = "\(getPercentageFromShots(made: homeTeamGameData.fgm3, attempted: homeTeamGameData.fga3))% - \(homeTeamGameData.fgm3) / \(homeTeamGameData.fga3)"
            }

            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == SECTION_SCORES {
            return .none
        }
        return StatSections.mainVals[section-1].localizedString()
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
