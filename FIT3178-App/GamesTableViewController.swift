//
//  GamesTableViewController.swift
//  FIT3178-App
//
//  Created by Samir Gupta on 19/4/22.
//

import UIKit

class GamesTableViewCell: UITableViewCell {
    @IBOutlet weak var awayTeamImage: UIImageView!
    @IBOutlet weak var awayTeamScore: UILabel!
    @IBOutlet weak var homeTeamImage: UIImageView!
    @IBOutlet weak var homeTeamScore: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
}

class GamesTableViewController: UITableViewController {
    var selectedDate : String?
    var selectedDateGames = [GameData]()
    
    var selectedGame : GameData?
    var selectedGameTitle : String?
    
    let GAME_CELL_IDENTIFIER = "gamesCell"
    let INFO_CELL_IDENTIFIER = "infoCell"
    let GAMES_SECTION = 0
    let INFO_SECTION = 1
    
    let USTimeZoneAbbreviation = "MDT"
    let defaultDateFormat = "yyyy-MM-dd"
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var todayButtonOutlet: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        todayButtonOutlet.isEnabled = false
        resetToday(self)
    }
    
    // MARK: - Retrieving Data
    
    func requestGamesOnDate() async {
        var gamesURL = URLComponents()
        gamesURL.scheme = "https"
        gamesURL.host = "www.balldontlie.io"
        gamesURL.path = "/api/v1/games"
        gamesURL.queryItems = [URLQueryItem(name: "dates[]", value: selectedDate)]
        
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
                    let collection = try decoder.decode(GameCollection.self, from: data)
                    if let games = collection.games {
                        self.selectedDateGames.append(contentsOf: games)
                        self.tableView.reloadData()
                        self.changeBadgeNumber()
                    }
                }
                catch let error { print(error) }
            }
        }
        catch let error { print(error) }
    }
    
    func getGames() {
        navigationItem.title = getNewNavTitle(date: selectedDate!)
        selectedDateGames.removeAll()
        Task {
            URLSession.shared.invalidateAndCancel()
            await requestGamesOnDate()
        }
    }
    
    // MARK: - Dates, Titles and Menus
    
    @IBAction func changeDateButton(_ sender: Any) {
        var change = 0
        if let sender = sender as? UIBarButtonItem {
            change = sender.tag
        }
        if let sender = sender as? UISwipeGestureRecognizer {
            let directionRaw = Int(sender.direction.rawValue)
            change = directionRaw == 1 ? -1 : 1
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = defaultDateFormat
        dateFormatter.timeZone = TimeZone.init(abbreviation: USTimeZoneAbbreviation)
        let oldDate = dateFormatter.date(from: selectedDate!)!
        let newDate = Calendar.current.date(byAdding: .day, value: change, to: oldDate)
        selectedDate = dateFormatter.string(from: newDate!)
        getGames()
    }
    
    
    func getNewNavTitle(date: String) -> String {
        let todaysDate = getTodaysDate()
        if todaysDate == date {
            todayButtonOutlet.isEnabled = false
            return "Today"
        }
        todayButtonOutlet.isEnabled = true
        return date
    }
    
    @IBOutlet weak var initialSeasonMenuItem: UICommand!
    @IBOutlet weak var previousSeasonMenuItem: UICommand!
    @IBAction func resetToday(_ sender: Any) {
        selectedDate = getTodaysDate()
        defaultMenuBuild()
        getGames()
    }
    
    func defaultMenuBuild() {
        let optionsClosure = { (action: UIAction) in
            let year = Int.init(action.title.split(separator: "/")[0])! + 1
            let selectedDateSplit = self.selectedDate?.split(separator: "-")
            let oldYear = Int.init(selectedDateSplit![0])
            if year != oldYear {
                self.selectedDate = "\(year)-\(selectedDateSplit![1])-\(selectedDateSplit![2])"
                self.selectedDateGames.removeAll()
                self.navigationItem.title = self.getNewNavTitle(date: self.selectedDate!)
                Task {
                    URLSession.shared.invalidateAndCancel()
                    await self.requestGamesOnDate()
                }
            }
        }
        
        menuButton.menu = UIMenu(children: [
             UIAction(title: "2021/22", state: .on, handler: optionsClosure),
             UIAction(title: "2020/21", handler: optionsClosure)
        ])
    }
    
    func getTodaysDate() -> String {
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = defaultDateFormat
        dateFormatter.timeZone = TimeZone.init(abbreviation: USTimeZoneAbbreviation)
        return dateFormatter.string(from: today)
    }
    
    func changeBadgeNumber() {
        var numberOfLiveGames = 0
        if selectedDate == getTodaysDate() {
            for game in selectedDateGames {
                if game.status! != "Final", !game.status!.hasSuffix("ET") { numberOfLiveGames += 1 }
            }
            
            if numberOfLiveGames != 0 { navigationController?.tabBarItem.badgeValue = String(describing: numberOfLiveGames) }
            else { navigationController?.tabBarItem.badgeValue = .none }
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == GAMES_SECTION {
            return selectedDateGames.count
        }
        if selectedDateGames.count == 0 {
            return 1
        }
        else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == GAMES_SECTION {
            let cell = tableView.dequeueReusableCell(withIdentifier: GAME_CELL_IDENTIFIER, for: indexPath) as! GamesTableViewCell
            let game = selectedDateGames[indexPath.row]
            
            guard let time = game.time, let status = game.status, let awayScore = game.awayScore, let homeScore = game.homeScore else { return cell }
            guard let homeTeam = game.homeTeam, let awayTeam = game.awayTeam, let awayAbb = awayTeam.abbreviation, let homeAbb = homeTeam.abbreviation else { return cell }
            
            if time == "" && status.hasSuffix("T"){
                cell.awayTeamScore.text = awayAbb
                cell.homeTeamScore.text = homeAbb
                cell.timeLabel.text = "@"
                cell.statusLabel.text = status
                cell.timeLabel.backgroundColor = UIColor.white
                cell.homeTeamScore.textColor = UIColor.black
                cell.awayTeamScore.textColor = UIColor.black
                cell.awayTeamScore.font = UIFont.systemFont(ofSize: cell.awayTeamScore.font.pointSize)
                cell.homeTeamScore.font = UIFont.systemFont(ofSize: cell.homeTeamScore.font.pointSize)
            }
            else {
                cell.awayTeamScore.text = "\(awayAbb) - \(awayScore)"
                cell.homeTeamScore.text = "\(homeScore) - \(homeAbb)"
                if homeScore > awayScore {
                    cell.homeTeamScore.font = UIFont.boldSystemFont(ofSize: cell.homeTeamScore.font.pointSize)
                    cell.homeTeamScore.textColor = UIColor.systemBlue
                    cell.awayTeamScore.font = UIFont.systemFont(ofSize: cell.awayTeamScore.font.pointSize)
                    cell.awayTeamScore.textColor = UIColor.black
                }
                else if awayScore > homeScore {
                    cell.awayTeamScore.font = UIFont.boldSystemFont(ofSize: cell.homeTeamScore.font.pointSize)
                    cell.awayTeamScore.textColor = UIColor.systemBlue
                    cell.homeTeamScore.font = UIFont.systemFont(ofSize: cell.homeTeamScore.font.pointSize)
                    cell.homeTeamScore.textColor = UIColor.black
                }
                else {
                    cell.awayTeamScore.font = UIFont.systemFont(ofSize: cell.awayTeamScore.font.pointSize)
                    cell.homeTeamScore.font = UIFont.systemFont(ofSize: cell.homeTeamScore.font.pointSize)
                    cell.homeTeamScore.textColor = UIColor.black
                    cell.awayTeamScore.textColor = UIColor.black
                }
                if time == "" && status.hasSuffix("Qtr") {
                    if awayScore == 0 && homeScore == 0 {
                        cell.timeLabel.text = "Start"
                    }
                    else {
                        cell.timeLabel.text = "End"
                    }
                    
                } else {
                    cell.timeLabel.text = time
                    cell.timeLabel.backgroundColor = UIColor.systemGreen
                }
                cell.statusLabel.text = status
            }
            
            cell.awayTeamImage.image = UIImage(named: awayAbb)
            cell.homeTeamImage.image = UIImage(named: homeAbb)
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: INFO_CELL_IDENTIFIER, for: indexPath)
            if selectedDateGames.count == 0 {
                cell.textLabel?.text = "No games on this date"
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let game = selectedDateGames[indexPath.row]
        selectedGame = game
        selectedGameTitle = game.awayTeam!.abbreviation! + " vs " + game.homeTeam!.abbreviation!
        performSegue(withIdentifier: "gameSelectSegue", sender: self)
    }
    

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gameSelectSegue" {
            let destination = segue.destination as! DetailedGameTableViewController
            destination.game = selectedGame
            destination.gameTitle = selectedGameTitle
        }
    }
}
