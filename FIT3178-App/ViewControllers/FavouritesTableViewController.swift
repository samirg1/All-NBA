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
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var recentGameScoreLabel: UILabel!
    @IBOutlet weak var recentGameStatusLabel: UILabel!
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
    private let sectionHeaders = ["PLAYERS", "TEAMS", ""]
    
    private var playerData: [FavouritePlayerDetails] = []
    private var teamData: [FavouriteTeamDetails] = []
    
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
        updateFavouriteContainers()
    }
    
    func updateFavouriteContainers() {
        playerData.removeAll()
        teamData.removeAll()
        
        for player in appDelegate.favouritePlayers {
            let newPlayer = FavouritePlayerDetails(player.id)
            getPlayerSeasonStats(player: newPlayer)
            getPlayersLastGame(player: newPlayer)
        }
        for team in appDelegate.favouriteTeams {
            let newTeam = FavouriteTeamDetails(team.id)
            getTeamsLastGame(team: newTeam)
        }
    }
    
    func getPlayerSeasonStats(player: FavouritePlayerDetails) {
        indicator.startAnimating()
        Task {
            let (data, error) = await requestData(path: .averages, queries: [.player_ids : "\(player.id)"])
            guard let data = data else {
                displayMessage_sgup0027(title: error!.title, message: error!.message)
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
            }
            catch let error {
                displayMessage_sgup0027(title: JSON_DECODER_ERROR_TITLE, message: error.localizedDescription)
            }
            indicator.stopAnimating()
        }
    }
    
    func getPlayersLastGame(player: FavouritePlayerDetails) {
        indicator.startAnimating()
        Task {
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY"
            let year = formatter.string(from: Date())
            
            let (data, error) = await requestData(path: .stats, queries: [.player_ids: "\(player.id)", .start_date: year+"-01-01", .per_page: "100"])
            guard let data = data else {
                displayMessage_sgup0027(title: error!.title, message: error!.message)
                indicator.stopAnimating()
                return
            }
            do {
                let decoder = JSONDecoder()
                let collection = try decoder.decode(PlayerGameStatsCollectionData.self, from: data)
                if let playerStats = collection.playersGameStats {
                    let sortedGames = playerStats.sorted { p1, p2 in return p1.gameDate < p2.gameDate }
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
    
    func getTeamsLastGame(team: FavouriteTeamDetails) {
        indicator.startAnimating()
        Task {
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY"
            let year = formatter.string(from: Date())
            
            let (data, error) = await requestData(path: .games, queries: [.team_ids: "\(team.id)", .start_date: year+"-01-01", .per_page: "100"])
            guard let data = data else {
                displayMessage_sgup0027(title: error!.title, message: error!.message)
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
            return teamData.count
        }
        if c == 0 && teamData.count == 0 {
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
