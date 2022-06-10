//
//  StandingsTableViewController.swift
//  FIT3178-App
//
//  Created by Samir Gupta on 3/5/22.
//
//  This view displays the NBA's current standings.
//  This page is limited by the API, as the API does not provide standings information
//  Instead separate API calls to each of the teams' games from the season is made to determine their win-loss record

import UIKit

/// Stores the team filters for standings.
public enum TeamFilter: String {
    /// The conference filter.
    case CONFERENCE = "Conference"
    /// The division filter.
    case DIVISION = "Division"
    /// The league filter (i.e. no filter).
    case LEAGUE = "League"
    
    /// Function to return a localised string of the enum raw value.
    /// - Returns: The localised string.
    ///
    /// Source found [here.](https://stackoverflow.com/questions/28213693/enum-with-localized-string-in-swift)
    public func localizedString() -> String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}

/// Stores the conferences of the NBA.
private enum Conferences: String {
    /// The eastern conference.
    case EAST = "East"
    /// The western conference.
    case WEST = "West"
    
    /// Function to return a localised string of the enum raw value.
    /// - Returns: The localised string.
    ///
    /// Source found [here.](https://stackoverflow.com/questions/28213693/enum-with-localized-string-in-swift)
    public func localizedString() -> String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}

/// Stores the divisions of the NBA.
private enum Divisions: String {
    /// The Atlantic division.
    case ATLANTIC = "Atlantic"
    /// The Central division.
    case CENTRAL = "Central"
    /// The Southeast division.
    case SOUTHEAST = "Southeast"
    /// The Northwest division.
    case NORTHWEST = "Northwest"
    /// The Pacific division.
    case PACIFIC = "Pacific"
    /// The Southwest division.
    case SOUTHWEST = "Southwest"
    
    /// Function to return a localised string of the enum raw value.
    /// - Returns: The localised string.
    ///
    /// Source found [here.](https://stackoverflow.com/questions/28213693/enum-with-localized-string-in-swift)
    public func localizedString() -> String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}

/// Stores the 2021/22 season info
public enum Season2021_2022: String {
    /// The year this season started.
    case YEAR = "2021"
    /// The start date of this season.
    case START = "2021-10-19"
    /// The end date of this season.
    case END = "2022-04-10"
}

/// Custom cell depicting a team's main information.
class StandingsTeamCell: UITableViewCell {
    /// The team's logo.
    @IBOutlet weak var teamImage: UIImageView!
    /// The position of the team.
    @IBOutlet weak var numberLabel: UILabel!
    /// The abbreviation of the team.
    @IBOutlet weak var abbreviationLabel: UILabel!
    /// The season record of the team.
    @IBOutlet weak var seasonRecordLabel: UILabel!
    /// The percentage wins of the team.
    @IBOutlet weak var percentageLabel: UILabel!
    /// The home record of the team.
    @IBOutlet weak var homeRecordLabel: UILabel!
    /// The away record of the team.
    @IBOutlet weak var awayRecordLabel: UILabel!
    /// The label of how many games behind the front the team is.
    @IBOutlet weak var gamesBehindLabel: UILabel!
}

class StandingsTableViewController: UITableViewController {
    /// The maximum amount of games in a regular season.
    private let MAX_GAMES_IN_SEASON = "82"
    /// The current season.
    private var season = Season2021_2022.self
    /// The current team filter.
    private var teamFilter: TeamFilter = TeamFilter.LEAGUE
    /// The collection of teams.
    private var teamsData: [TeamSeasonStats] = []
    /// The cell identifier of the cell that houses the team's stats.
    private let teamCellIdentifier = "teamCell"
    /// The selected team (if any).
    private var selectedTeam: TeamSeasonStats?
    /// The collection of teams, split up by division.
    private var divisionTeams: [Divisions: [TeamSeasonStats]] = [
        Divisions.ATLANTIC: [],
        Divisions.CENTRAL: [],
        Divisions.SOUTHEAST: [],
        Divisions.NORTHWEST: [],
        Divisions.PACIFIC: [],
        Divisions.SOUTHWEST: []
    ]
    /// The collection of teams, split up by conference.
    private var conferenceTeams: [Conferences: [TeamSeasonStats]] = [
        Conferences.EAST: [],
        Conferences.WEST: []
    ]
    /// The indicator used to indicate when an asynchronous task is active.
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
        buildFilterMenu()
        getTeamsData(reload: false)
    }
    
    /// Outlet to the team filter button.
    @IBOutlet weak private var teamFilterMenu: UIButton!
    
    /// Build the team filter menu.
    ///
    /// Code source [here.](https://developer.apple.com/forums/thread/683700)
    private func buildFilterMenu() {
        let optionsClosure = { (action: UIAction) in
            self.teamFilter = TeamFilter(rawValue: action.title)! // change team filter
            self.tableView.reloadData()
        }
        
        teamFilterMenu.menu = UIMenu(children: [ // build menu
            UIAction(title: TeamFilter.LEAGUE.localizedString(), state: .on, handler: optionsClosure),
            UIAction(title: TeamFilter.CONFERENCE.localizedString(), handler: optionsClosure),
            UIAction(title: TeamFilter.DIVISION.localizedString(), handler: optionsClosure)
        ])
    }
    
    
    // MARK: Retrieving Data from API
    
    /// Retrieve all teams.
    /// - Parameters:
    ///     - reload: Whether to reload the data from the API regardless of whether a file exists or not.
    private func getTeamsData(reload: Bool) {
        teamsData.removeAll() // clear all data containers
        for (div, _) in divisionTeams {
            divisionTeams[div]?.removeAll()
        }
        for (conf, _) in conferenceTeams {
            conferenceTeams[conf]?.removeAll()
        }
        
        // check if file exists
        let fileName = season.YEAR.rawValue + FileManagerFiles.all_teams_suffix.rawValue
        if doesFileExist(name: fileName) && !reload {
            if let data = getFileData(name: fileName) {
               return decodeTeams(data: data, reload: reload)
            }
            return displaySimpleMessage(title: FILE_MANAGER_DATA_ERROR_TITLE, message: FILE_MANAGER_DATA_ERROR_MESSAGE)
        }
        else { // if not get data from API
            indicator.startAnimating()
            teamFilterMenu.isEnabled = false
            Task {
                let (data, error) = await requestData(path: .teams, queries: []) // get data
                guard let data = data else {
                    displaySimpleMessage(title: error!.title, message: error!.message)
                    indicator.stopAnimating()
                    return
                }
                
                // update/create a file to persistently store the data retrieved
                setFileData(name: fileName, data: data)
                decodeTeams(data: data, reload: reload)
                indicator.stopAnimating()
                teamFilterMenu.isEnabled = true
            }
        }
    }
    
    /// Decode the team data.
    /// - Parameters:
    ///     - data: The data to decode.
    ///     - reload: Whether to reload the data from the API regardless of whether a file exists or not.
    private func decodeTeams(data: Data, reload: Bool) {
        do {
            let decoder = JSONDecoder()
            let collection = try decoder.decode(TeamCollection.self, from: data) // decode data
            if let teams = collection.teams {
                for team in teams {
                    getTeamSeasonGameData(team: team, reload: reload) // for each team get their season data
                }
            }
        }
        catch let error { // catch any errors
            displaySimpleMessage(title: JSON_DECODER_ERROR_TITLE, message: error.localizedDescription)
            indicator.stopAnimating()
        }
    }
    
    /// Get a team's season data.
    /// - Parameters:
    ///     - team: The team to find data for.
    ///     - reload: Whether to reload the data from the API regardless of whether a file exists or not.
    private func getTeamSeasonGameData(team: Team, reload: Bool){
        let fileName = "\(team.id)" + FileManagerFiles.team_season_games_suffix.rawValue // check if file exists
        if doesFileExist(name: fileName) && !reload {
            if let data = getFileData(name: fileName) {
                return decodeTeamGames(data: data, team: team)
            }
            return displaySimpleMessage(title: FILE_MANAGER_DATA_ERROR_TITLE, message: FILE_MANAGER_DATA_ERROR_MESSAGE)
        }
        else { // otherwise call API
            Task {
                let queries: [(API_QUERIES, String)] = [
                    (.team_ids, "\(team.id)"),
                    (.seasons, season.YEAR.rawValue),
                    (.per_page, MAX_GAMES_IN_SEASON),
                    (.start_date, season.START.rawValue),
                    (.end_date, season.END.rawValue)
                ]
                
                let (data, error) = await requestData(path: .games, queries: queries) // get data
                guard let data = data else {
                    displaySimpleMessage(title: error!.title, message: error!.message)
                    indicator.stopAnimating()
                    return
                }
                
                // update/create a file to persistently store the data retrieved
                setFileData(name: fileName, data: data)
                decodeTeamGames(data: data, team: team)
            }
        }
    }
    
    /// Decode a team's season data.
    /// - Parameters:
    ///     - data: The data to decode
    ///     - team: The team that's data is being decoded.
    private func decodeTeamGames(data: Data, team: Team) {
        do {
            let decoder = JSONDecoder()
            let collection = try decoder.decode(GameCollection.self, from: data) // decode data
            if let games = collection.games {
                let teamData = TeamSeasonStats(withTeam: team)
                for game in games {
                    teamData.addGame(game: game)
                }
                self.divisionTeams[Divisions.init(rawValue: team.division)!]!.append(teamData)
                self.conferenceTeams[Conferences.init(rawValue: team.conference)!]!.append(teamData)
                self.teamsData.append(teamData) // add the team to the containers
                self.teamsData.sort(){ $0.pct > $1.pct } // sort the teams based on their win percentage
                for (divi, div_teams) in self.divisionTeams {
                    self.divisionTeams[divi] = div_teams.sorted() { $0.pct > $1.pct }
                }
                for (conf, conf_teams) in self.conferenceTeams {
                    self.conferenceTeams[conf] = conf_teams.sorted() { $0.pct > $1.pct }
                }
                self.tableView.reloadData()
                
            }
        }
        catch let error {
            displaySimpleMessage(title: JSON_DECODER_ERROR_TITLE, message: error.localizedDescription)
            indicator.stopAnimating()
        }
    }
    
    /// Action to manually refresh data.
    @IBAction private func manualRefresh(_ sender: Any) {
        getTeamsData(reload: true)
    }
    
    /// Find and return the positions of a particular team in their conference, division and league.
    /// - Parameters:
    ///     - teamToFind: The team to find positions for.
    /// - Returns: Key/value pairs matching the team filter to the position the team is in this subsection of the league.
    private func findPositions(teamToFind: TeamSeasonStats) -> [TeamFilter: Int]{ // find the positions in the league, division and conference for display
        let div = divisionTeams[Divisions.init(rawValue: teamToFind.team.division)!]!.firstIndex { team in
            team.team.abbreviation == teamToFind.team.abbreviation
        }! + 1
        let conf = conferenceTeams[Conferences.init(rawValue: teamToFind.team.conference)!]!.firstIndex { team in
            team.team.abbreviation == teamToFind.team.abbreviation
        }! + 1
        let league = teamsData.firstIndex { team in team.team.abbreviation == teamToFind.team.abbreviation }! + 1
        
        return [TeamFilter.DIVISION: div, TeamFilter.CONFERENCE: conf, TeamFilter.LEAGUE: league]
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if teamFilter == TeamFilter.CONFERENCE && !teamsData.isEmpty {
            return conferenceTeams.count
        }
        else if teamFilter == TeamFilter.DIVISION && !teamsData.isEmpty {
            return divisionTeams.count
        }
        else if teamFilter == TeamFilter.LEAGUE && !teamsData.isEmpty {
            return 1
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if teamFilter == TeamFilter.CONFERENCE {
            return conferenceTeams[Array(conferenceTeams.keys)[section]]!.count
        }
        else if teamFilter == TeamFilter.DIVISION {
            return divisionTeams[Array(divisionTeams.keys)[section]]!.count
        }
        else if teamFilter == TeamFilter.LEAGUE {
            return teamsData.count
        }
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: teamCellIdentifier, for: indexPath) as! StandingsTeamCell
        let team: TeamSeasonStats
        if teamFilter == TeamFilter.CONFERENCE {
            team = conferenceTeams[Array(conferenceTeams.keys)[indexPath.section]]![indexPath.row]
        }
        else if teamFilter == TeamFilter.DIVISION {
            team = divisionTeams[Array(divisionTeams.keys)[indexPath.section]]![indexPath.row]
        }
        else {
            team = teamsData[indexPath.row]
        }
        
        let gamesBehind: Double
        if indexPath.row == 0 {
            gamesBehind = 0.0
        }
        else {
            if teamFilter == TeamFilter.CONFERENCE {
                gamesBehind = conferenceTeams[Array(conferenceTeams.keys)[indexPath.section]]![0].seasonScore - team.seasonScore
            }
            else if teamFilter == TeamFilter.DIVISION {
                gamesBehind = divisionTeams[Array(divisionTeams.keys)[indexPath.section]]![0].seasonScore - team.seasonScore
            }
            else {
                gamesBehind = teamsData[0].seasonScore - team.seasonScore
            }
        }
        
        let string_pct = "\(team.pct)"
        var pct = "\(team.pct)"
        for _ in 0..<(5-string_pct.count) { pct += "0" }
        
        cell.teamImage.image = UIImage(named: team.team.abbreviation)
        cell.numberLabel.text = "\(indexPath.row + 1)"
        cell.abbreviationLabel.text = team.team.abbreviation
        cell.seasonRecordLabel.text = "\(team.wins)-\(team.losses)"
        cell.percentageLabel.text = "\(pct)"
        cell.homeRecordLabel.text = "H\(team.homeWins)-\(team.homeLosses)"
        cell.awayRecordLabel.text = "A\(team.awayWins)-\(team.awayLosses)"
        cell.gamesBehindLabel.text = "GB: \(gamesBehind)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if teamFilter == TeamFilter.CONFERENCE {
            return Array(conferenceTeams.keys)[section].localizedString()
        }
        else if teamFilter == TeamFilter.DIVISION {
            return Array(divisionTeams.keys)[section].localizedString()
        }
        else {
            return TeamFilter.LEAGUE.localizedString()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if teamFilter == TeamFilter.CONFERENCE {
            selectedTeam = conferenceTeams[Array(conferenceTeams.keys)[indexPath.section]]![indexPath.row]
        }
        else if teamFilter == TeamFilter.DIVISION {
            selectedTeam = divisionTeams[Array(divisionTeams.keys)[indexPath.section]]![indexPath.row]
        }
        else if teamFilter == TeamFilter.LEAGUE {
            selectedTeam = teamsData[indexPath.row]
        }
        performSegue(withIdentifier: "detailedTeamSegue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailedTeamSegue" {
            let destination = segue.destination as! DetailedTeamViewController
            destination.selectedTeam = selectedTeam
            destination.positions = findPositions(teamToFind: selectedTeam!)
        }
    }
}
