//
//  FavouritesTableViewController.swift
//  All-NBA
//
//  Created by Samir Gupta on 31/5/2022.
//

import UIKit

/// Custom table cell that provides framework to display one of the user's favourite players.
public class FavouritePlayerTableCell: UITableViewCell {
    /// The label of the name of the player.
    @IBOutlet weak var nameLabel: UILabel!
    /// The label describing the player's season stats.
    @IBOutlet weak var seasonStatsLabel: UILabel!
    /// The label describing the outcome of the player's most recent game.
    @IBOutlet weak var recentGameScoreLabel: UILabel!
    /// The label describing the player's statistics in their most recent game.
    @IBOutlet weak var recentGameLabel: UILabel!
}

/// Custome table cell that provides framework to display one of the user's favourite teams.
class FavouriteTeamTableCell: UITableViewCell {
    /// The label housing the name of the team.
    @IBOutlet weak var teamNameLabel: UILabel!
    /// The label describing the outcome of the team's most recent game.
    @IBOutlet weak var recentGameScoreLabel: UILabel!
    /// The label describing the status of the team's most recent game.
    @IBOutlet weak var recentGameStatusLabel: UILabel!
}

/// Custom Table View Controller for the 'Favourites' page of the App.
///
/// This table view currently contains two sections, one for the users favourite players, and another for their favourite team.
/// The players and teams are presented in a way that simplistically summarises the current status of the team or player.
/// This page was created to allow the user to have easy access to the information that they want to know.
class FavouritesTableViewController: UITableViewController {
    
    /// Variable for accessing the ``AppDelegate``.
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    /// The cell identifier for the favourite player cell.
    private let playerCellIdentifier = "playerCell"
    /// The cell identifier for the favourite team cell.
    private let teamCellIdentifier = "teamCell"
    /// The cell identifier for the info cell.
    private let infoCellIdentifier = "infoCell"
    /// The section of the table that houses the players.
    private let playerSection = 0
    /// The section of the table that houses the teams.
    private let teamSection = 1
    /// The sections of the table that houses other information.
    private let infoSection = 2
    /// The section headers of the table.
    private let sectionHeaders = ["PLAYERS", "TEAMS", ""]
    
    /// The current player data that has been retrieved.
    private var playerData: [FavouritePlayer] = []
    /// The current team data that has been retrieved.
    private var teamData: [FavouriteTeam] = []
    
    /// The indicator used to indicate when an async task is in progress.
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
        updateFavouriteContainers()
    }
    
    /// Update the containers that house the user's favourite teams and players data.
    private func updateFavouriteContainers() {
        playerData.removeAll()
        teamData.removeAll()
        
        for player in appDelegate.favouritePlayers {
            let newPlayer = FavouritePlayer(player.id)
            getPlayerSeasonStats(player: newPlayer)
            getPlayersLastGame(player: newPlayer)
        }
        for team in appDelegate.favouriteTeams {
            let newTeam = FavouriteTeam(team.id)
            getTeamsLastGame(team: newTeam)
        }
    }
    
    /// Get a player's current season stat averages.
    /// - Parameters:
    ///     - player: The player to find the stats for.
    private func getPlayerSeasonStats(player: FavouritePlayer) {
        indicator.startAnimating()
        Task {
            let (data, error) = await requestData(path: .averages, queries: [.player_ids : "\(player.id)"])
            guard let data = data else {
                displaySimpleMessage(title: error!.title, message: error!.message)
                indicator.stopAnimating()
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let collection = try decoder.decode(PlayerSeasonStatCollection.self, from: data)
                if let players = collection.players {
                    player.seasonStats = players[0]
                    if !player.isNil(){ playerData.append(player) }
                }
                tableView.reloadData()
                indicator.stopAnimating()
            }
            catch let error {
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
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY"
            let year = formatter.string(from: Date())
            
            let (data, error) = await requestData(path: .stats, queries: [.player_ids: "\(player.id)", .start_date: year+"-01-01", .per_page: "100"])
            guard let data = data else {
                displaySimpleMessage(title: error!.title, message: error!.message)
                indicator.stopAnimating()
                return
            }
            do {
                let decoder = JSONDecoder()
                let collection = try decoder.decode(PlayerGameStatsCollection.self, from: data)
                if let playerStats = collection.playersGameStats {
                    let sortedGames = playerStats.sorted { p1, p2 in return p1.gameDate < p2.gameDate }
                    player.recentGame = sortedGames.last!
                    if !player.isNil(){ playerData.append(player) }
                }
                tableView.reloadData()
                indicator.stopAnimating()
            }
            catch let error {
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
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY"
            let year = formatter.string(from: Date())
            
            let (data, error) = await requestData(path: .games, queries: [.team_ids: "\(team.id)", .start_date: year+"-01-01", .per_page: "100"])
            guard let data = data else {
                displaySimpleMessage(title: error!.title, message: error!.message)
                indicator.stopAnimating()
                return
            }
            do {
                let decoder = JSONDecoder()
                let collection = try decoder.decode(GameCollection.self, from: data)
                if let games = collection.games {
                    let sortedGames = games.sorted { p1, p2 in return p1.date < p2.date }
                    team.recentGame = sortedGames.last!
                    teamData.append(team)
                }
                tableView.reloadData()
                indicator.stopAnimating()
            }
            catch let error {
                displaySimpleMessage(title: JSON_DECODER_ERROR_TITLE, message: error.localizedDescription)
                indicator.stopAnimating()
            }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == playerSection {
            return playerData.count
        }
        else if section == teamSection {
            return teamData.count
        }
        if playerData.isEmpty && teamData.isEmpty {
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: teamCellIdentifier, for: indexPath) as! FavouriteTeamTableCell
        let team = teamData[indexPath.row]
        guard let game = team.recentGame else {
            return cell
        }
        cell.teamNameLabel.text = team.id == game.homeTeam.id ? game.homeTeam.fullName : game.awayTeam.fullName
        cell.recentGameScoreLabel.text = "\(game.homeTeam.abbreviation!) \(game.homeScore) vs \(game.awayScore) \(game.awayTeam.abbreviation!)"
        cell.recentGameStatusLabel.text = game.status
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == playerSection && playerData.isEmpty {
            return nil
        }
        if section == teamSection && teamData.isEmpty {
            return nil
        }
        return sectionHeaders[section]
    }
}
