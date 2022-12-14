//
//  FavouritesTableViewController.swift
//  All-NBA
//
//  Created by Samir Gupta on 31/5/2022.
//

import UIKit

/// Custom table cell that provides framework to display one of the user's favourite players.
class FavouritePlayerTableCell: UITableViewCell {
    /// The label of the name of the player.
    @IBOutlet weak fileprivate var nameLabel: UILabel!
    /// The label describing the player's season stats.
    @IBOutlet weak fileprivate var seasonStatsLabel: UILabel!
    /// The label describing the outcome of the player's most recent game.
    @IBOutlet weak fileprivate var recentGameScoreLabel: UILabel!
    /// The label describing the player's statistics in their most recent game.
    @IBOutlet weak fileprivate var recentGameLabel: UILabel!
}

/// Custome table cell that provides framework to display one of the user's favourite teams.
class FavouriteTeamTableCell: UITableViewCell {
    /// The label housing the name of the team.
    @IBOutlet weak fileprivate var teamNameLabel: UILabel!
    /// The label describing the outcome of the team's most recent game.
    @IBOutlet weak fileprivate var recentGameScoreLabel: UILabel!
    /// The label describing the status of the team's most recent game.
    @IBOutlet weak fileprivate var recentGameStatusLabel: UILabel!
    /// The label describing the time of the game ('Recent Game', 'Next Game')
    @IBOutlet weak var recentGameLabel: UILabel!
}

/// Custom Table View Controller for the 'Favourites' page of the App.
///
/// This table view currently contains two sections, one for the users favourite players, and another for their favourite team.
/// The players and teams are presented in a way that simplistically summarises the current status of the team or player.
/// This page was created to allow the user to have easy access to the information that they want to know.
class FavouritesTableViewController: UITableViewController {
    /// The cell identifier for the favourite player cell.
    private let PLAYER_CELL_IDENTIFIER = "playerCell"
    /// The cell identifier for the favourite team cell.
    private let TEAM_CELL_IDENTIFIER = "teamCell"
    /// The cell identifier for the info cell.
    private let INFO_CELL_IDENTIFIER = "infoCell"
    /// The section of the table that houses the players.
    private let PLAYER_SECTION = 0
    /// The section of the table that houses the teams.
    private let TEAM_SECTION = 1
    /// The sections of the table that houses other information.
    private let INFO_SECTION = 2
    /// The section headers of the table.
    private let TABLE_SECTION_HEADERS = [NSLocalizedString("PLAYERS", comment: "players_header"), NSLocalizedString("TEAMS", comment: "teams_header"), ""]
    
    /// The current player data that has been retrieved.
    private var playerData: [FavouritePlayer] = []
    /// The current team data that has been retrieved.
    private var teamData: [FavouriteTeam] = []
    
    /// The indicator used to indicate when an async task is in progress.
    private lazy var indicator: UIActivityIndicatorView = {
        var indicator = UIActivityIndicatorView()
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.addSubview(indicator) // add indicator to center of tableview
        NSLayoutConstraint.activate([ indicator.centerXAnchor.constraint(equalTo: tableView.centerXAnchor), indicator.centerYAnchor.constraint(equalTo: tableView.centerYAnchor) ])
        return indicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getFavourites() // update the favourites each time user enters the page, ensures up-to-date info
        updateFavouriteContainers()
    }
    
    /// Update the containers that house the user's favourite teams and players data.
    private func updateFavouriteContainers() {
        playerData.removeAll() // clear current containers
        teamData.removeAll()
        
        for player in appDelegate.favouritePlayers { // for each player in the user's favourite players, create a new class for them
            let newPlayer = FavouritePlayer(player.id, player.firstName, player.lastName)
            playerData.append(newPlayer)
            getPlayerSeasonStats(player: newPlayer)
            getPlayersLastGame(player: newPlayer)
        }
        for team in appDelegate.favouriteTeams { // for each team in the user's favourite teams, create a new class for them
            let newTeam = FavouriteTeam(team.id, team.fullName)
            teamData.append(newTeam)
            getTeamsLastGame(team: newTeam)
        }
        tableView.reloadData()
    }
    
    /// Get a player's current season stat averages.
    /// - Parameters:
    ///     - player: The player to find the stats for.
    private func getPlayerSeasonStats(player: FavouritePlayer) {
        indicator.startAnimating()
        Task {
            let (data, error) = await requestData(path: .averages, queries: [(.player_ids, "\(player.id)")]) // request data
            guard let data = data else { // if data is not found an error is present
                displaySimpleMessage(title: error!.title, message: error!.message)
                indicator.stopAnimating()
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let collection = try decoder.decode(PlayerSeasonStatCollection.self, from: data) // decode data
                if let players = collection.players {
                    if !players.isEmpty { player.seasonStats = players[0] } // add the player's season stats to the FavouritePlayer object
                }
                tableView.reloadData()
                indicator.stopAnimating()
            }
            catch let error { // catch any errors
                displaySimpleMessage(title: JSON_DECODER_ERROR_TITLE, message: error.localizedDescription)
                indicator.stopAnimating()
            }
        }
    }
    
    /// Get a specific player's most recent game.
    /// - Parameters:
    ///     - player: The player to find the game for.
    private func getPlayersLastGame(player: FavouritePlayer) {
        indicator.startAnimating()
        Task {
            let date = getStartAndEnd()
            let (data, error) = await requestData(path: .stats, queries: [(.player_ids, "\(player.id)"), (.start_date, date.start), (.end_date, date.end), (.per_page, "100")]) // request data
            guard let data = data else { // if no data present then there was an error
                displaySimpleMessage(title: error!.title, message: error!.message)
                indicator.stopAnimating()
                return
            }
            do {
                let decoder = JSONDecoder()
                let collection = try decoder.decode(PlayerGameStatsCollection.self, from: data) // decode data
                if let playerStats = collection.playersGameStats {
                    let sortedGames = playerStats.sorted { p1, p2 in return p1.gameDate < p2.gameDate } // sort games returned by date
                    player.recentGame = sortedGames.last // add the most recent game to the FavouritePlayer object
                }
                tableView.reloadData()
                indicator.stopAnimating()
            }
            catch let error { // catch any errors
                displaySimpleMessage(title: JSON_DECODER_ERROR_TITLE, message: error.localizedDescription)
                indicator.stopAnimating()
            }
        }
    }
    
    /// Get a specifc team's most recent game.
    /// - Parameters:
    ///     - team: The team to find the game for.
    private func getTeamsLastGame(team: FavouriteTeam) {
        indicator.startAnimating()
        Task {
            let date = getStartAndEnd()
            let (data, error) = await requestData(path: .games, queries: [(.team_ids, "\(team.id)"), (.start_date, date.start), (.end_date, date.end), (.per_page, "100")]) // get data
            guard let data = data else { // if no data is present there was an error
                displaySimpleMessage(title: error!.title, message: error!.message)
                indicator.stopAnimating()
                return
            }
            do {
                let decoder = JSONDecoder()
                let collection = try decoder.decode(GameCollection.self, from: data) // decode data
                if let games = collection.games {
                    let sortedGames = games.sorted { p1, p2 in return p1.date < p2.date } // sort the games by date
                    team.recentGame = sortedGames.last // add the most recent game to the FavouriteTeam object
                }
                tableView.reloadData()
                indicator.stopAnimating()
            }
            catch let error { // catch any error
                displaySimpleMessage(title: JSON_DECODER_ERROR_TITLE, message: error.localizedDescription)
                indicator.stopAnimating()
            }
        }
    }
    
    /// Get a stringed date of the period of time to search for a game in.
    /// - Returns: Two dates, the start and end in the format  "YYYY-MM-DD".
    private func getStartAndEnd() -> (start: String, end: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let start = formatter.string(from: Date()-14)
        let end = formatter.string(from: Date())
        return (start, end)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == PLAYER_SECTION {
            return playerData.count
        }
        else if section == TEAM_SECTION {
            return teamData.count
        }
        if playerData.isEmpty && teamData.isEmpty {
            return 1
        }
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == INFO_SECTION { // if no favourites are available yet
            let cell = tableView.dequeueReusableCell(withIdentifier: INFO_CELL_IDENTIFIER, for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = NSLocalizedString("No favourites yet.", comment: "no_favourites_yet")
            content.secondaryText = NSLocalizedString("Click 'Edit' to add some.", comment: "edit_to_add_favourites")
            cell.contentConfiguration = content
            return cell
        }
        else if indexPath.section == PLAYER_SECTION { // favourite players
            let player = playerData[indexPath.row]
            if player.isNil() {
                let cell = tableView.dequeueReusableCell(withIdentifier: INFO_CELL_IDENTIFIER, for: indexPath)
                var content = cell.defaultContentConfiguration()
                content.text = "\(player.firstName) \(player.lastName)"
                content.secondaryText = NSLocalizedString("Stats are unavailable", comment: "unavailable stats")
                cell.contentConfiguration = content
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: PLAYER_CELL_IDENTIFIER, for: indexPath) as! FavouritePlayerTableCell
            
            let stats = player.seasonStats!
            let lastGame = player.recentGame!
            cell.nameLabel.text = player.firstName + " " + player.lastName
            cell.seasonStatsLabel.text = "\(stats.pts) PPG - \(stats.ast) APG - \(stats.reb) RPG"
            cell.recentGameScoreLabel.text = "\(teamIdToAbbreviations[lastGame.gameHomeTeamId]!) \(lastGame.gameHomeScore) vs \(lastGame.gameAwayScore) \(teamIdToAbbreviations[lastGame.gameAwayTeamId]!)"
            cell.recentGameLabel.text = "\(lastGame.pts) PTS - \(lastGame.ast) AST - \(lastGame.reb) REB"
            return cell
        }
        // otherwise favourite teams
        let team = teamData[indexPath.row]
        if team.isNil() {
            let cell = tableView.dequeueReusableCell(withIdentifier: INFO_CELL_IDENTIFIER, for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = team.fullName
            content.secondaryText = NSLocalizedString("Stats are unavailable", comment: "unavailable stats")
            cell.contentConfiguration = content
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: TEAM_CELL_IDENTIFIER, for: indexPath) as! FavouriteTeamTableCell
        
        guard let game = team.recentGame else {
            return cell
        }
        cell.teamNameLabel.text = team.id == game.homeTeam.id ? game.homeTeam.fullName : game.awayTeam.fullName
        
        let localDate = convertTimeZones(string: game.date, from: TimeZoneIdentifiers.usa_nyk.rawValue, to: appDelegate.currentTimeZoneIdentifier, format: .fullAPI)
        let formatter = DateFormatter()
        formatter.dateFormat = DateFormats.shortenedDate.rawValue
        let localDateString = formatter.string(from: localDate)
        if game.status.hasSuffix("T") {
            cell.recentGameStatusLabel.text = "\(localDateString) \(APItoCurrentTimeZoneDisplay(string: game.status))"
            cell.recentGameLabel.text = NSLocalizedString("Next Game", comment: "")
            cell.recentGameScoreLabel.text = "\(game.homeTeam.abbreviation) vs \(game.awayTeam.abbreviation)"
        }
        else {
            cell.recentGameStatusLabel.text = NSLocalizedString(game.status, comment: "")
            cell.recentGameLabel.text = NSLocalizedString("Recent Game", comment: "")
            cell.recentGameScoreLabel.text = "\(game.homeTeam.abbreviation) \(game.homeScore) vs \(game.awayScore) \(game.awayTeam.abbreviation)"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == PLAYER_SECTION && playerData.isEmpty {
            return nil
        }
        if section == TEAM_SECTION && teamData.isEmpty {
            return nil
        }
        return TABLE_SECTION_HEADERS[section]
    }
}
