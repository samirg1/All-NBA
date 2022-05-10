//
//  GamesTableViewController.swift
//  FIT3178-App
//
//  Created by Samir Gupta on 19/4/22.
//
//  The initial view controller which allows users to view the games on the current (or any) day.
//  The scores are limited by the API as not up-to-date as the API only updates every 10 or so minutes.

import UIKit

enum GestureDateChanges: Int { // deals with how much to change the date (in days) once a gesture is recognised
    case left = 1
    case right = -1
}

class GamesTableViewCell: UITableViewCell { // cell that shows the main game info
    @IBOutlet weak var awayTeamImage: UIImageView!
    @IBOutlet weak var awayTeamScore: UILabel!
    @IBOutlet weak var homeTeamImage: UIImageView!
    @IBOutlet weak var homeTeamScore: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
}

class GamesTableViewController: UITableViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let fileManagerNamingExtension = "-gameCollection"
    
    var selectedDate = String()
    var selectedDateGames = [GameData]()
    var selectedGame : GameData?
    var selectedGameTitle : String?
    var selectedGameSegue = "gameSelectSegue"
    
    let GAME_CELL_IDENTIFIER = "gamesCell"
    let INFO_CELL_IDENTIFIER = "infoCell"
    let GAMES_SECTION = 0
    let INFO_SECTION = 1
    
    let USTimeZoneAbbreviation = "MDT"
    let defaultDateFormat = "yyyy-MM-dd"
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var todayButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var refreshToolbar: UIToolbar!
    
    // displays the indicator when data is loading from API in the centre of the toolbar
    lazy var indicator: UIActivityIndicatorView = {
        var indicator = UIActivityIndicatorView()
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.refreshToolbar.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: refreshToolbar.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: refreshToolbar.centerYAnchor)
        ])
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        todayButtonOutlet.isEnabled = false // as initial screen is "Today", disable the button
        resetToday(self) // retrieve the required data from today
    }
    
    // MARK: - Retrieving and Decoding Data
    
    func requestGamesOnDate() async { // API call to get all games on specific date stored in 'selectedDate'
        var gamesURL = URLComponents()
        gamesURL.scheme = appDelegate.API_URL_SCHEME
        gamesURL.host = appDelegate.API_URL_HOST
        gamesURL.path = appDelegate.API_URL_PATH + appDelegate.API_URL_PATH_GAMES
        gamesURL.queryItems = [
            URLQueryItem(name: appDelegate.API_QUERY_DATES, value: selectedDate)
        ]
        
        guard let requestURL = gamesURL.url else {
            displayMessage_sgup0027(title: appDelegate.URL_CONVERSION_ERROR_TITLE, message: appDelegate.URL_CONVERSION_ERROR_MESSAGE)
            return
        }
        
        let urlRequest = URLRequest(url: requestURL)
        do {
            let (data, _) = try await URLSession.shared.data(for: urlRequest)
            DispatchQueue.main.async {
                
                // decode the data and update view(s)
                self.decodeJSONforSelectedDateGames(data: data)
                
                // update/create a file to persistently store the data retrieved
                let fileName = self.selectedDate + self.fileManagerNamingExtension
                let localURL = self.appDelegate.cacheDirectoryPath.appendingPathComponent(fileName)
                FileManager.default.createFile(atPath: localURL.path, contents: data, attributes: [:])
            }
        }
        catch let error { displayMessage_sgup0027(title: appDelegate.API_ERROR_TITLE, message: error.localizedDescription) }
    }
    
    func getGames(reload: Bool) { // gets data of all games on date
        navigationItem.title = getNewNavTitle(date: selectedDate)
        selectedDateGames.removeAll()
        
        // determines whether file exists or whether the user has selected to reload
        let fileName = selectedDate + fileManagerNamingExtension
        let localURL = appDelegate.cacheDirectoryPath.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: localURL.path) && !reload
        {
            // if file exists (and user hasn't reloaded) retrieve data, decode it and update views
            let data = FileManager.default.contents(atPath: localURL.path)
            if let data = data {
                self.decodeJSONforSelectedDateGames(data: data)
            }
            else {
                displayMessage_sgup0027(title: appDelegate.FILE_MANAGER_DATA_ERROR_TITLE, message: appDelegate.FILE_MANAGER_DATA_ERROR_MESSAGE)
            }
        }
        else {
            
            // otherwise start the indicator and call the API
            indicator.startAnimating()
            Task {
                URLSession.shared.invalidateAndCancel()
                await requestGamesOnDate()
            }
        }
    }
    
    func decodeJSONforSelectedDateGames(data: Data){ // decodes data of all games and updates view
        do {
            let decoder = JSONDecoder()
            let collection = try decoder.decode(GameCollection.self, from: data)
            if let games = collection.games {
                self.selectedDateGames.append(contentsOf: games)
                self.tableView.reloadData()
                self.changeBadgeNumber()
                indicator.stopAnimating() // stop the indicator if it is active
            }
        }
        catch let error { displayMessage_sgup0027(title: appDelegate.JSON_DECODER_ERROR_TITLE, message: error.localizedDescription) }
    }
    
    @IBAction func manualRefreshGames(_ sender: Any) { // manually refresh the current games
        getGames(reload: true)
    }
    
    @IBAction func resetToday(_ sender: Any) { // resets the view to the current day
        selectedDate = getTodaysDate()
        defaultMenuBuild()
        getGames(reload: false)
    }
    
    // MARK: - Dates, Titles and Menus
    
    @IBAction func changeDateButton(_ sender: Any) { // changes the sepcific date of viewable games
        var change = 0
        if let sender = sender as? UIBarButtonItem { // if user changes date using the buttons
            change = sender.tag
        }
        else if let sender = sender as? UISwipeGestureRecognizer { // if user changes date using gestures
            if sender.direction == .left {
                change = GestureDateChanges.left.rawValue
            }
            else if sender.direction == .right {
                change = GestureDateChanges.right.rawValue
            }
        }
        
        // get the current date, edit it and update the view accordingly
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = defaultDateFormat
        dateFormatter.timeZone = TimeZone.init(abbreviation: USTimeZoneAbbreviation)
        let oldDate = dateFormatter.date(from: selectedDate)!
        let newDate = Calendar.current.date(byAdding: .day, value: change, to: oldDate)
        selectedDate = dateFormatter.string(from: newDate!)
        getGames(reload: false)
    }
    
    func getNewNavTitle(date: String) -> String { // gets the new navigation title of the view based on the 'selectedDate'
        let todaysDate = getTodaysDate()
        if todaysDate == date {
            todayButtonOutlet.isEnabled = false
            return "Today"
        }
        todayButtonOutlet.isEnabled = true
        return date
    }
    
    func defaultMenuBuild() { // builds the menu for changing the season
        let optionsClosure = { (action: UIAction) in
            let year = Int.init(action.title.split(separator: "/")[0])! + 1
            let selectedDateSplit = self.selectedDate.split(separator: "-")
            let oldYear = Int.init(selectedDateSplit[0])
            if year != oldYear {
                self.selectedDate = "\(year)-\(selectedDateSplit[1])-\(selectedDateSplit[2])"
                self.getGames(reload: false)
            }
        }
        
        menuButton.menu = UIMenu(children: [
             UIAction(title: "2021/22", state: .on, handler: optionsClosure),
             UIAction(title: "2020/21", handler: optionsClosure)
        ])
    }
    
    func getTodaysDate() -> String { // gets todays date as a string
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = defaultDateFormat
        dateFormatter.timeZone = TimeZone.init(abbreviation: USTimeZoneAbbreviation)
        return dateFormatter.string(from: today)
    }
    
    func changeBadgeNumber() { // changes the badge number of the tab to represent how many live games there are
        var numberOfLiveGames = 0
        if selectedDate == getTodaysDate() {
            for game in selectedDateGames {
                if game.status! != "Final", !game.status!.hasSuffix("ET") { numberOfLiveGames += 1 }
            }
            
            if numberOfLiveGames != 0 {
                navigationController?.tabBarItem.badgeValue = String(describing: numberOfLiveGames)
            }
            else {
                navigationController?.tabBarItem.badgeValue = .none
            }
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
            
            guard let time = game.time, let status = game.status  else { return cell }
            guard let awayAbb = game.awayTeam.abbreviation, let homeAbb = game.homeTeam.abbreviation else { return cell }
            
            if time == "" && status.hasSuffix("T"){ // if game has not started yet
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
                cell.awayTeamScore.text = "\(awayAbb) - \(game.awayScore)"
                cell.homeTeamScore.text = "\(game.homeScore) - \(homeAbb)"
                if game.homeScore > game.awayScore { // if home team is winnning
                    cell.homeTeamScore.font = UIFont.boldSystemFont(ofSize: cell.homeTeamScore.font.pointSize)
                    cell.homeTeamScore.textColor = UIColor.systemBlue
                    cell.awayTeamScore.font = UIFont.systemFont(ofSize: cell.awayTeamScore.font.pointSize)
                    cell.awayTeamScore.textColor = UIColor.black
                }
                else if game.awayScore > game.homeScore { // if away team is winning
                    cell.awayTeamScore.font = UIFont.boldSystemFont(ofSize: cell.homeTeamScore.font.pointSize)
                    cell.awayTeamScore.textColor = UIColor.systemBlue
                    cell.homeTeamScore.font = UIFont.systemFont(ofSize: cell.homeTeamScore.font.pointSize)
                    cell.homeTeamScore.textColor = UIColor.black
                }
                else { // if it is currently a draw
                    cell.awayTeamScore.font = UIFont.systemFont(ofSize: cell.awayTeamScore.font.pointSize)
                    cell.homeTeamScore.font = UIFont.systemFont(ofSize: cell.homeTeamScore.font.pointSize)
                    cell.homeTeamScore.textColor = UIColor.black
                    cell.awayTeamScore.textColor = UIColor.black
                }
                if time == "" && status.hasSuffix("Qtr") { // if the game is at the start/end of a quarter
                    if game.awayScore == 0 && game.homeScore == 0 { // if game is at start of first quarter
                        cell.timeLabel.text = "Start"
                    }
                    else { // otherwise game is at end of quater
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
        selectedGameTitle = game.awayTeam.abbreviation! + " vs " + game.homeTeam.abbreviation!
        performSegue(withIdentifier: selectedGameSegue , sender: self)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == selectedGameSegue {
            let destination = segue.destination as! DetailedGameTableViewController
            destination.game = selectedGame
            destination.gameTitle = selectedGameTitle
        }
    }
}
