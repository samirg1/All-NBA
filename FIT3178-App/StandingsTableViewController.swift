//
//  StandingsTableViewController.swift
//  FIT3178-App
//
//  Created by Samir Gupta on 3/5/22.
//

import UIKit

enum TeamFilter: String {
    case CONFERENCE = "Conference"
    case DIVISION = "Division"
    case LEAGUE = "League"
}

enum Conferences: String {
    case EAST = "East"
    case WEST = "West"
}

enum Divisions: String {
    case ATLANTIC = "Atlantic"
    case CENTRAL = "Central"
    case SOUTHEAST = "Southeast"
    case NORTHWEST = "Northwest"
    case PACIFIC = "Pacific"
    case SOUTHWEST = "Southwest"
}

enum Season2021_2022: String {
    case YEAR = "2021"
    case START = "2021-10-19"
    case END = "2022-04-10"
}

enum Season2020_2021: String {
    case YEAR = "2020"
    case START = "2020-12-22"
    case END = "2020-05-16"
}

class StandingsTeamCell: UITableViewCell {
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
    
    let MAX_GAMES_IN_SEASON = "82"
    var season = Season2021_2022.self
    var teamFilter: TeamFilter = TeamFilter.LEAGUE
    var teamsData: [TeamSeasonData] = []
    
    var divisionTeams: [String: [TeamSeasonData]] = [
        Divisions.ATLANTIC.rawValue: [],
        Divisions.CENTRAL.rawValue: [],
        Divisions.SOUTHEAST.rawValue: [],
        Divisions.NORTHWEST.rawValue: [],
        Divisions.PACIFIC.rawValue: [],
        Divisions.SOUTHWEST.rawValue: []
    ]
    
    var conferenceTeams: [String: [TeamSeasonData]] = [
        Conferences.EAST.rawValue: [],
        Conferences.WEST.rawValue: []
    ]
    
    var selectedTeam: TeamSeasonData?
    
    let gamesFileManagerExtension = "-seasonGamesData"
    let allTeamsFileManagerExtension = "-all_teams"
    lazy var cacheDirectoryPath: URL = {
        let cacheDirectoryPaths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return cacheDirectoryPaths[0]
    }()
    
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
        buildFilterMenu()
        getTeams(reload: false)
    }

    @IBOutlet weak var teamFilterMenu: UIButton!
    func buildFilterMenu() { // build the team filter menu
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
    
    func requestTeamGames(team: TeamData) async { //
        var gamesURL = URLComponents()
        gamesURL.scheme = "https"
        gamesURL.host = "www.balldontlie.io"
        gamesURL.path = "/api/v1/games"
        gamesURL.queryItems = [
            URLQueryItem(name: "team_ids[]", value: "\(team.id)"),
            URLQueryItem(name: "seasons[]", value: season.YEAR.rawValue),
            URLQueryItem(name: "per_page", value: MAX_GAMES_IN_SEASON),
            URLQueryItem(name: "start_date", value: season.START.rawValue),
            URLQueryItem(name: "end_date", value: season.END.rawValue)
        ]
        
        guard let requestURL = gamesURL.url else {
            print("Invalid URL")
            return
        }
        
        let urlRequest = URLRequest(url: requestURL)
        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            DispatchQueue.main.async {
                self.decodeTeamGames(data: data, team: team)
                let fileName = "\(team.id)" + self.gamesFileManagerExtension
                let localURL = self.cacheDirectoryPath.appendingPathComponent(fileName)
                FileManager.default.createFile(atPath: localURL.path, contents: data, attributes: [:])
            }
        }
        catch let error { print(error) }
    }
                            
    func getAllTeams(reload: Bool) async {
        var gamesURL = URLComponents()
        gamesURL.scheme = "https"
        gamesURL.host = "www.balldontlie.io"
        gamesURL.path = "/api/v1/teams"
        
        guard let requestURL = gamesURL.url else {
            print("Invalid URL")
            return
        }
        
        let urlRequest = URLRequest(url: requestURL)
        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            DispatchQueue.main.async {
                self.decodeTeams(data: data, reload: reload)
                let fileName = self.season.YEAR.rawValue + self.allTeamsFileManagerExtension
                let localURL = self.cacheDirectoryPath.appendingPathComponent(fileName)
                FileManager.default.createFile(atPath: localURL.path, contents: data, attributes: [:])
            }
        }
        catch let error { print(error) }
    }
    
    func getTeams(reload: Bool) {
        teamsData.removeAll()
        for (_, var teams) in divisionTeams {
            teams.removeAll()
        }
        for (_, var teams) in conferenceTeams {
            teams.removeAll()
        }
        
        let fileName = season.YEAR.rawValue + allTeamsFileManagerExtension
        let localURL = cacheDirectoryPath.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: localURL.path) && !reload {
            let data = FileManager.default.contents(atPath: localURL.path)
            if let data = data {
                self.decodeTeams(data: data, reload: reload)
            }
            else {
                displayMessage_sgup0027(title: "An error occured fetching teams", message: "FileManager data is invalid")
            }
        }
        else {
            indicator.startAnimating()
            Task {
                await getAllTeams(reload: reload)
                indicator.stopAnimating()
            }
        }
        
        
    }
    
    func decodeTeams(data: Data, reload: Bool) {
        do {
            let decoder = JSONDecoder()
            let collection = try decoder.decode(TeamCollection.self, from: data)
            if let teams = collection.teams {
                for team in teams {
                    getTeamsGames(team: team, reload: reload)
                }
            }
        }
        catch let error { print(error) }
    }
    
    func getTeamsGames(team: TeamData, reload: Bool){
        let fileName = "\(team.id)" + gamesFileManagerExtension
        let localURL = cacheDirectoryPath.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: localURL.path) && !reload {
            let data = FileManager.default.contents(atPath: localURL.path)
            if let data = data {
                self.decodeTeamGames(data: data, team: team)
            }
            else {
                displayMessage_sgup0027(title: "An error occured fetching team games", message: "FileManager data is invalid")
            }
        }
        else {
            Task {
                await self.requestTeamGames(team: team)
            }
        }
        
    }
    
    func decodeTeamGames(data: Data, team: TeamData) {
        guard let division = team.division, let conference = team.conference else {
            print("Couldn't find team division and/or conference")
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
                self.divisionTeams[division]!.append(teamData)
                self.conferenceTeams[conference]!.append(teamData)
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
        catch let error { print(error) }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "teamCell", for: indexPath) as! StandingsTeamCell
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
            return Array(conferenceTeams.keys)[section]
        }
        else if teamFilter == TeamFilter.DIVISION {
            return Array(divisionTeams.keys)[section]
        }
        else {
            return "League"
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
    
    func findPositions(teamToFind: TeamSeasonData) -> [String: Int]{
        var div = 0
        var conf = 0
        var league = 0
        for i in 0..<teamsData.count {
            if teamsData[i].team.abbreviation == teamToFind.team.abbreviation {
                league = i+1
                break
            }
        }
        for (_, divTeam) in divisionTeams {
            for i in 0..<divTeam.count {
                if divTeam[i].team.abbreviation == teamToFind.team.abbreviation {
                    div = i+1
                    break
                }
            }
        }
        for (_, confTeam) in conferenceTeams {
            for i in 0..<confTeam.count {
                if confTeam[i].team.abbreviation == teamToFind.team.abbreviation {
                    conf = i+1
                    break
                }
            }
        }
        return [TeamFilter.DIVISION.rawValue: div, TeamFilter.CONFERENCE.rawValue: conf, TeamFilter.LEAGUE.rawValue: league]
    }
}
