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

public enum TeamFilter: String { // stores the team filters for standings
    case CONFERENCE = "Conference"
    case DIVISION = "Division"
    case LEAGUE = "League"
}

private enum Conferences: String { // stores the conferences of the NBA
    case EAST = "East"
    case WEST = "West"
}

private enum Divisions: String { // stores the divisions of the NBA
    case ATLANTIC = "Atlantic"
    case CENTRAL = "Central"
    case SOUTHEAST = "Southeast"
    case NORTHWEST = "Northwest"
    case PACIFIC = "Pacific"
    case SOUTHWEST = "Southwest"
}

private enum Season2021_2022: String { // stores the 2021/22 season info
    case YEAR = "2021"
    case START = "2021-10-19"
    case END = "2022-04-10"
}

private enum Season2020_2021: String { // stores the 2020/21 season info
    case YEAR = "2020"
    case START = "2020-12-22"
    case END = "2020-05-16"
}

class StandingsTeamCell: UITableViewCell { // cell depicting a team's info
    @IBOutlet weak var teamImage: UIImageView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var abbreviationLabel: UILabel!
    @IBOutlet weak var seasonRecordLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    @IBOutlet weak var homeRecordLabel: UILabel!
    @IBOutlet weak var awayRecordLabel: UILabel!
    @IBOutlet weak var gamesBehindLabel: UILabel!
}

class StandingsTableViewController: UITableViewController {
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    public let gamesFileManagerExtension = "-seasonGamesData"
    public let allTeamsFileManagerExtension = "-all_teams"
    
    private let MAX_GAMES_IN_SEASON = "82"
    private var season = Season2021_2022.self
    private var teamFilter: TeamFilter = TeamFilter.LEAGUE
    private var teamsData: [TeamSeasonData] = []
    private let teamCellIdentifier = "teamCell"
    private var selectedTeam: TeamSeasonData?
    
    private var divisionTeams: [Divisions: [TeamSeasonData]] = [
        Divisions.ATLANTIC: [],
        Divisions.CENTRAL: [],
        Divisions.SOUTHEAST: [],
        Divisions.NORTHWEST: [],
        Divisions.PACIFIC: [],
        Divisions.SOUTHWEST: []
    ]
    
    private var conferenceTeams: [Conferences: [TeamSeasonData]] = [
        Conferences.EAST: [],
        Conferences.WEST: []
    ]
    
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
        getTeams(reload: false)
    }
    
    @IBOutlet weak private var teamFilterMenu: UIButton!
    private func buildFilterMenu() { // build the team filter menu
        let optionsClosure = { (action: UIAction) in
            self.teamFilter = TeamFilter(rawValue: action.title)!
            self.tableView.reloadData()
        }
        
        teamFilterMenu.menu = UIMenu(children: [
            UIAction(title: TeamFilter.LEAGUE.rawValue, state: .on, handler: optionsClosure),
            UIAction(title: TeamFilter.CONFERENCE.rawValue, handler: optionsClosure),
            UIAction(title: TeamFilter.DIVISION.rawValue, handler: optionsClosure)
        ])
    }
    
    
    // MARK: Retrieving Data from API
    
    private func getTeams(reload: Bool) { // retrieves the teams data
        teamsData.removeAll()
        for (_, var teams) in divisionTeams {
            teams.removeAll()
        }
        for (_, var teams) in conferenceTeams {
            teams.removeAll()
        }
        
        let fileName = season.YEAR.rawValue + allTeamsFileManagerExtension
        let localURL = appDelegate.cacheDirectoryPath.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: localURL.path) && !reload {
            let data = FileManager.default.contents(atPath: localURL.path)
            if let data = data {
                self.decodeTeams(data: data, reload: reload)
            }
            else {
                displayMessage_sgup0027(title: appDelegate.FILE_MANAGER_DATA_ERROR_TITLE, message: appDelegate.FILE_MANAGER_DATA_ERROR_MESSAGE)
            }
        }
        else {
            indicator.startAnimating()
            teamFilterMenu.isEnabled = false
            Task {
                await getAllTeams(reload: reload)
                print("done!")
                indicator.stopAnimating()
                teamFilterMenu.isEnabled = true
            }
        }
        
        
    }
    
    private func getTeamsGames(team: TeamData, reload: Bool){ // retrieves the teams games data
        let fileName = "\(team.id)" + gamesFileManagerExtension
        let localURL = appDelegate.cacheDirectoryPath.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: localURL.path) && !reload {
            let data = FileManager.default.contents(atPath: localURL.path)
            if let data = data {
                self.decodeTeamGames(data: data, team: team)
            }
            else {
                displayMessage_sgup0027(title: appDelegate.FILE_MANAGER_DATA_ERROR_TITLE, message: appDelegate.FILE_MANAGER_DATA_ERROR_MESSAGE)
            }
        }
        else {
            Task {
                await self.requestTeamGames(team: team)
            }
        }
        
    }
    
    private func getAllTeams(reload: Bool) async { // gets all teams from API
        var gamesURL = URLComponents()
        gamesURL.scheme = appDelegate.API_URL_SCHEME
        gamesURL.host = appDelegate.API_URL_HOST
        gamesURL.path = appDelegate.API_URL_PATH + appDelegate.API_URL_PATH_TEAMS
        
        guard let requestURL = gamesURL.url else {
            displayMessage_sgup0027(title: appDelegate.URL_CONVERSION_ERROR_TITLE, message: appDelegate.URL_CONVERSION_ERROR_MESSAGE)
            indicator.stopAnimating()
            return
        }
        
        let urlRequest = URLRequest(url: requestURL)
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            if let response = response as? HTTPURLResponse, response.statusCode != HTTP_ERROR_CODES.success.rawValue  {
                displayMessage_sgup0027(title: appDelegate.API_ERROR_TITLE, message: appDelegate.API_ERROR_CODE_MESSAGES[response.statusCode]!)
                indicator.stopAnimating()
                return
            }
            self.decodeTeams(data: data, reload: reload)
            DispatchQueue.main.async {
                
                let fileName = self.season.YEAR.rawValue + self.allTeamsFileManagerExtension
                let localURL = self.appDelegate.cacheDirectoryPath.appendingPathComponent(fileName)
                FileManager.default.createFile(atPath: localURL.path, contents: data, attributes: [:])
            }
        }
        catch let error {
            displayMessage_sgup0027(title: appDelegate.API_ERROR_TITLE, message: error.localizedDescription)
            indicator.stopAnimating()
        }
    }
    
    private func requestTeamGames(team: TeamData) async { // gets a specifc teams season games from API
        var gamesURL = URLComponents()
        gamesURL.scheme = appDelegate.API_URL_SCHEME
        gamesURL.host = appDelegate.API_URL_HOST
        gamesURL.path = appDelegate.API_URL_PATH + appDelegate.API_URL_PATH_GAMES
        gamesURL.queryItems = [
            URLQueryItem(name: appDelegate.API_QUERY_TEAM_ID, value: "\(team.id)"),
            URLQueryItem(name: appDelegate.API_QUERY_SEASONS, value: season.YEAR.rawValue),
            URLQueryItem(name: appDelegate.API_QUERY_PER_PAGE, value: MAX_GAMES_IN_SEASON),
            URLQueryItem(name: appDelegate.API_QUERY_START_DATE, value: season.START.rawValue),
            URLQueryItem(name: appDelegate.API_QUERY_END_DATE, value: season.END.rawValue)
        ]
        
        guard let requestURL = gamesURL.url else {
            displayMessage_sgup0027(title: appDelegate.URL_CONVERSION_ERROR_TITLE, message: appDelegate.URL_CONVERSION_ERROR_MESSAGE)
            indicator.stopAnimating()
            return
        }
        
        let urlRequest = URLRequest(url: requestURL)
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            if let response = response as? HTTPURLResponse, response.statusCode != HTTP_ERROR_CODES.success.rawValue  {
                displayMessage_sgup0027(title: appDelegate.API_ERROR_TITLE, message: appDelegate.API_ERROR_CODE_MESSAGES[response.statusCode]!)
                indicator.stopAnimating()
                return
            }
            DispatchQueue.main.async {
                self.decodeTeamGames(data: data, team: team)
                let fileName = "\(team.id)" + self.gamesFileManagerExtension
                let localURL = self.appDelegate.cacheDirectoryPath.appendingPathComponent(fileName)
                FileManager.default.createFile(atPath: localURL.path, contents: data, attributes: [:])
            }
        }
        catch let error {
            displayMessage_sgup0027(title: appDelegate.API_ERROR_TITLE, message: error.localizedDescription)
            indicator.stopAnimating()
        }
    }
    
    private func decodeTeams(data: Data, reload: Bool) { // decodes the teams data
        do {
            let decoder = JSONDecoder()
            let collection = try decoder.decode(TeamCollection.self, from: data)
            if let teams = collection.teams {
                    for team in teams {
                        getTeamsGames(team: team, reload: reload)
                    }
            }
        }
        catch let error {
            displayMessage_sgup0027(title: appDelegate.JSON_DECODER_ERROR_TITLE, message: error.localizedDescription)
            indicator.stopAnimating()
        }
    }
    
    private func decodeTeamGames(data: Data, team: TeamData) { // decodes the teams games data
        guard let division = team.division, let conference = team.conference else {
            return
        }
        do {
            let decoder = JSONDecoder()
            let collection = try decoder.decode(GameCollection.self, from: data)
            if let games = collection.games {
                let teamData = TeamSeasonData(withTeam: team)
                for game in games {
                    teamData.addGame(game: game)
                }
                self.divisionTeams[Divisions.init(rawValue: division)!]!.append(teamData)
                self.conferenceTeams[Conferences.init(rawValue: conference)!]!.append(teamData)
                self.teamsData.append(teamData)
                self.teamsData.sort(){ $0.pct > $1.pct }
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
            displayMessage_sgup0027(title: appDelegate.JSON_DECODER_ERROR_TITLE, message: error.localizedDescription)
            indicator.stopAnimating()
        }
    }
    
    @IBAction private func manualRefresh(_ sender: Any) {
        getTeams(reload: true)
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
        let team: TeamSeasonData
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
        
        cell.teamImage.image = UIImage(named: team.team.abbreviation!)
        cell.numberLabel.text = "\(indexPath.row + 1)"
        cell.abbreviationLabel.text = team.team.abbreviation!
        cell.seasonRecordLabel.text = "\(team.wins)-\(team.losses)"
        cell.percentageLabel.text = "\(pct)"
        cell.homeRecordLabel.text = "H\(team.homeWins)-\(team.homeLosses)"
        cell.awayRecordLabel.text = "A\(team.awayWins)-\(team.awayLosses)"
        cell.gamesBehindLabel.text = "GB: \(gamesBehind)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if teamFilter == TeamFilter.CONFERENCE {
            return Array(conferenceTeams.keys)[section].rawValue
        }
        else if teamFilter == TeamFilter.DIVISION {
            return Array(divisionTeams.keys)[section].rawValue
        }
        else {
            return TeamFilter.LEAGUE.rawValue
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
    
    private func findPositions(teamToFind: TeamSeasonData) -> [TeamFilter: Int]{ // find the positions in the league, division and conference for display
        let div = divisionTeams[Divisions.init(rawValue: teamToFind.team.division!)!]!.firstIndex { team in
            team.team.abbreviation == teamToFind.team.abbreviation
        }! + 1
        let conf = conferenceTeams[Conferences.init(rawValue: teamToFind.team.conference!)!]!.firstIndex { team in
            team.team.abbreviation == teamToFind.team.abbreviation
        }! + 1
        let league = teamsData.firstIndex { team in team.team.abbreviation == teamToFind.team.abbreviation }! + 1
        
        return [TeamFilter.DIVISION: div, TeamFilter.CONFERENCE: conf, TeamFilter.LEAGUE: league]
    }
}
