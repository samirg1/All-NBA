//
//  GamesTableViewController.swift
//  FIT3178-App
//
//  Created by Samir Gupta on 19/4/22.
//
//  The initial view controller which allows users to view the games on the current (or any) day.
//  The scores are limited by the API as not up-to-date as the API only updates every 10 or so minutes.

import UIKit

/// Dealing with how to change the date once a gesture is recognised
///
/// The raw value of this enumeration represents the amount of days to add to the current date when the gesture is recognised.
/// - Case `left` = 1
/// - Case `right` = -1
private enum GestureDateChanges: Int {
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
    
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // variables to check whether the view needs to be updated based on what has happened on other views
    public var reloaded = false
    public var toBeReloaded = false
    
    private var selectedDate = String()
    private var selectedDateGames = [GameData]()
    private var selectedGame : GameData?
    private var selectedGameTitle : String?
    private var selectedGameSegue = "gameSelectSegue"
    
    private let GAME_CELL_IDENTIFIER = "gamesCell"
    private let INFO_CELL_IDENTIFIER = "infoCell"
    private let GAMES_SECTION = 0
    private let INFO_SECTION = 1
    
    @IBOutlet weak private var menuButton: UIButton!
    @IBOutlet weak private var todayButtonOutlet: UIBarButtonItem!
    @IBOutlet weak private var dateLabel: UILabel!
    @IBOutlet weak private var refreshToolbar: UIToolbar!
    
    // displays the indicator when data is loading from API in the centre of the toolbar
    private lazy var indicator: UIActivityIndicatorView = {
        var indicator = UIActivityIndicatorView()
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.refreshToolbar.addSubview(indicator)
        NSLayoutConstraint.activate([ indicator.centerXAnchor.constraint(equalTo: refreshToolbar.centerXAnchor), indicator.centerYAnchor.constraint(equalTo: refreshToolbar.centerYAnchor) ])
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        todayButtonOutlet.isEnabled = false // as initial screen is "Today", disable the button
        resetToday(self) // retrieve the required data from today
    }
    
    // MARK: Notificatino Handling
    private func addNotifications() {
        guard appDelegate.notificationsEnabled == true else { return }
        
        for game in selectedDateGames {
            guard let status = game.status else { continue }
            if !status.hasSuffix("ET") { continue }
            let timeString = convertTo24HourTime(string: status)
            let time = convertTimeZones(string: timeString, from: TimeZoneIdentifiers.usa_nyk.rawValue, to: appDelegate.currentTimeZoneIdentifier, format: .time24hr)
            let formatter = DateFormatter()
            formatter.dateFormat = DateFormats.API.rawValue
            let date = formatter.date(from: selectedDate)!
            
            var dateComponents = DateComponents()
            dateComponents.year = formatter.calendar.component(.year, from: date)
            dateComponents.month = formatter.calendar.component(.month, from: date)
            dateComponents.day = formatter.calendar.component(.day, from: date)
            dateComponents.hour = formatter.calendar.component(.hour, from: time)
            dateComponents.minute = formatter.calendar.component(.minute, from: time)
            
            let title = "\(game.homeTeam.abbreviation!) vs \(game.awayTeam.abbreviation!)"
            
            createGameNotification(date: dateComponents, title: title)
        }
    }
    
    private func createGameNotification(date: DateComponents, title: String) {
        let content = UNMutableNotificationContent()
        content.title = "Game Alert"
        content.body = title + " starting soon"
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
        
        let identifier = "\(title) - \(selectedDate)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    // MARK: - Retrieving and Decoding Data
    private func getGameData(reload: Bool) { // gets data of all games on date
        dateLabel.text = getNewDateText(date: selectedDate)
        selectedDateGames.removeAll()
        
        // determines whether file exists or whether the user has selected to reload
        let fileName = selectedDate + FileManagerFiles.date_game_collection_suffix.rawValue
        if doesFileExist(name: fileName) && !reload {
            // if file exists (and user hasn't reloaded) retrieve data, decode it and update views
            if let data = getFileData(name: fileName) {
                return decodeGameData(data: data)
            }
            return displayMessage_sgup0027(title: FILE_MANAGER_DATA_ERROR_TITLE, message: FILE_MANAGER_DATA_ERROR_MESSAGE)
        }
        else {
            
            // otherwise start the indicator and call the API
            indicator.startAnimating()
            
            reloaded = !toBeReloaded
            toBeReloaded = false
            
            // get the date to search games for in the correct timezone and format
            let API_date = convertTimeZones(string: selectedDate, from: TimeZoneIdentifiers.aus_melb.rawValue, to: TimeZoneIdentifiers.usa_nyk.rawValue, format: DateFormats.API)
            let formatter = DateFormatter()
            formatter.dateFormat = DateFormats.API.rawValue
            let API_date_string = formatter.string(from: API_date)
            
            
            Task {
                URLSession.shared.invalidateAndCancel()
                
                let (data, error) = await requestData(path: .games, queries: [.dates : API_date_string])
                guard let data = data else {
                    displayMessage_sgup0027(title: error!.title, message: error!.message)
                    indicator.stopAnimating()
                    return
                }
                
                // update/create a file to persistently store the data retrieved
                setFileData(name: fileName, data: data)
                decodeGameData(data: data)
            }
        }
    }
    
    private func decodeGameData(data: Data){ // decodes data of all games and updates view
        do {
            let decoder = JSONDecoder()
            let collection = try decoder.decode(GameCollection.self, from: data)
            if let games = collection.games {
                selectedDateGames.append(contentsOf: games)
                tableView.reloadData()
                changeBadgeNumber()
                indicator.stopAnimating() // stop the indicator if it is active
                addNotifications()
            }
        }
        catch let error {
            displayMessage_sgup0027(title: JSON_DECODER_ERROR_TITLE, message: error.localizedDescription)
            indicator.stopAnimating()
        }
    }
    
    @IBAction private func manualRefreshGames(_ sender: Any) { // manually refresh the current games
        getGameData(reload: true)
    }
    
    @IBAction private func resetToday(_ sender: Any) { // resets the view to the current day
        selectedDate = getTodaysDate()
        defaultMenuBuild()
        getGameData(reload: toBeReloaded)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if toBeReloaded {
            manualRefreshGames(self)
        }
        else {
            reloaded = false
        }
    }
    
    // MARK: - Dates, Titles and Menus
    
    @IBAction private func changeDateButton(_ sender: Any) { // changes the sepcific date of viewable games
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
        let oldDate = DateFormatter().stringToDate(string: selectedDate, format: DateFormats.API, timezone: appDelegate.currentTimeZoneIdentifier)
        let newDate = Calendar.current.date(byAdding: .day, value: change, to: oldDate)!
        selectedDate = DateFormatter().dateToString(date: newDate, format: DateFormats.API, timezone: appDelegate.currentTimeZoneIdentifier)
        getGameData(reload: false)
    }
    
    private func getNewDateText(date: String) -> String { // gets the new navigation title of the view based on the 'selectedDate'
        todayButtonOutlet.isEnabled = getTodaysDate() != date
        let currentDate = DateFormatter().stringToDate(string: date, format: DateFormats.API, timezone: appDelegate.currentTimeZoneIdentifier)
        return DateFormatter().dateToString(date: currentDate, format: DateFormats.display, timezone: appDelegate.currentTimeZoneIdentifier)
    }
    
    private func defaultMenuBuild() { // builds the menu for changing the season
        let optionsClosure = { (action: UIAction) in
            let year = Int.init(action.title.split(separator: "/")[0])! + 1
            let selectedDateSplit = self.selectedDate.split(separator: "-")
            let oldYear = Int.init(selectedDateSplit[0])
            if year != oldYear {
                self.selectedDate = "\(year)-\(selectedDateSplit[1])-\(selectedDateSplit[2])"
                self.getGameData(reload: false)
            }
        }
        
        menuButton.menu = UIMenu(children: [
             UIAction(title: "2021/22", state: .on, handler: optionsClosure),
             UIAction(title: "2020/21", handler: optionsClosure)
        ])
    }
    
    private func getTodaysDate() -> String { // gets todays date as a string
        return DateFormatter().dateToString(date: Date(), format: DateFormats.API, timezone: appDelegate.currentTimeZoneIdentifier)
    }
    
    private func changeBadgeNumber() { // changes the badge number of the tab to represent how many live games there are
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
                cell.statusLabel.text = APItoCurrentTimeZoneDisplay(string: status)
                cell.timeLabel.backgroundColor = UIColor.secondarySystemBackground
                cell.homeTeamScore.textColor = UILabel().textColor
                cell.awayTeamScore.textColor = UILabel().textColor
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
                    cell.awayTeamScore.textColor = UILabel().textColor
                }
                else if game.awayScore > game.homeScore { // if away team is winning
                    cell.awayTeamScore.font = UIFont.boldSystemFont(ofSize: cell.homeTeamScore.font.pointSize)
                    cell.awayTeamScore.textColor = UIColor.systemBlue
                    cell.homeTeamScore.font = UIFont.systemFont(ofSize: cell.homeTeamScore.font.pointSize)
                    cell.homeTeamScore.textColor = UILabel().textColor
                }
                else { // if it is currently a draw
                    cell.awayTeamScore.font = UIFont.systemFont(ofSize: cell.awayTeamScore.font.pointSize)
                    cell.homeTeamScore.font = UIFont.systemFont(ofSize: cell.homeTeamScore.font.pointSize)
                    cell.homeTeamScore.textColor = UILabel().textColor
                    cell.awayTeamScore.textColor = UILabel().textColor
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
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: selectedGameSegue , sender: self)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == selectedGameSegue {
            let destination = segue.destination as! DetailedGameTableViewController
            destination.game = selectedGame
            destination.gameTitle = selectedGameTitle
            destination.toBeReloaded = reloaded
        }
    }
}
