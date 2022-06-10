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
private enum GestureDateChanges: Int {
    /// The date change on a left swipe.
    case left = 1
    /// The date change on a right swipe.
    case right = -1
}

/// Custom table cell class to house the main game information.
class GamesTableViewCell: UITableViewCell {
    /// The logo of the away team.
    @IBOutlet weak var awayTeamImage: UIImageView!
    /// The score of the away team.
    @IBOutlet weak var awayTeamScore: UILabel!
    /// The logo of the home team.
    @IBOutlet weak var homeTeamImage: UIImageView!
    /// The score of the home team.
    @IBOutlet weak var homeTeamScore: UILabel!
    /// The time label of the game.
    @IBOutlet weak var timeLabel: UILabel!
    /// The status label of the game.
    @IBOutlet weak var statusLabel: UILabel!
}

/// Custom table class to display a date's live, past and future games to the user.
class GamesTableViewController: UITableViewController {
    /// Variable to access the ``AppDelegate`` of this App.
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    /// The selected date to show games for.
    private var selectedDate = String()
    /// The games on the selected data.
    private var selectedDateGames = [Game]()
    /// List of dates with available games.
    private var availableGameDates = [String:Bool]()
    /// The amount of days to check each side of the `selectedDate` for games.
    private let gamesToCheck = 14
    /// The game that the user has selected.
    private var selectedGame : Game?
    /// The segue identifer of the segue to perform once a game is selected.
    private var selectedGameSegue = "gameSelectSegue"
    
    /// The cell identifer of the game cell.
    private let GAME_CELL_IDENTIFIER = "gamesCell"
    /// The cell identifier of the info cell.
    private let INFO_CELL_IDENTIFIER = "infoCell"
    /// The section that houses the games.
    private let GAMES_SECTION = 0
    /// The section that houses extra info.
    private let INFO_SECTION = 1
    
    /// The button used to revert the date back to today's date.
    @IBOutlet weak private var todayButtonOutlet: UIBarButtonItem!
    /// The label that describes the current date.
    @IBOutlet weak private var dateLabel: UILabel!
    
    /// Indicator used to indicate when an asynchronous task is active.
    private lazy var indicator: UIActivityIndicatorView = {
        var indicator = UIActivityIndicatorView()
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.addSubview(indicator) // set indicator in middle of the toolbar
        NSLayoutConstraint.activate([ indicator.centerXAnchor.constraint(equalTo: tableView.centerXAnchor), indicator.centerYAnchor.constraint(equalTo: tableView.centerYAnchor) ])
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        todayButtonOutlet.isEnabled = false // as initial screen is "Today", disable the button
        resetToday(self) // retrieve the required data from today
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getGameData(reload: false) // reload the games quietly in the background each time user enters this page
    }
    
    // MARK: Notification Handling
    
    /// Add local notifications of upcoming games once the user has seen them.
    private func addNotifications() {
        if !appDelegate.notificationsEnabled || !appDelegate.gameAlertNotifcations {
            return // user needs to have notifications enabled and have game alert notification activated
        }
        
        for game in selectedDateGames {
            if appDelegate.favouritesOnlyNotifications { // if user has selected to only get favourite team notifications
                if !appDelegate.favouriteTeams.contains(where: { team in team.id == game.homeTeam.id || team.id == game.awayTeam.id}) {
                    if !appDelegate.favouritePlayers.contains(where: { player in player.team.id == game.homeTeam.id || player.team.id == game.awayTeam.id }) {
                        continue
                    }
                }
            }
            
            if !game.status.hasSuffix("ET") { continue }  // if game is not in the future skip over it
            
            let timeString = convertTo24HourTime(string: game.status) // get the date of the game in local time in order to create notification
            let time = convertTimeZones(string: timeString, from: TimeZoneIdentifiers.usa_nyk.rawValue, to: appDelegate.currentTimeZoneIdentifier, format: .time24hr)
            let formatter = DateFormatter()
            formatter.dateFormat = DateFormats.API.rawValue
            let date = formatter.date(from: selectedDate)!
            
            var dateComponents = DateComponents() // use the date to create date components to pass into notification
            dateComponents.year = formatter.calendar.component(.year, from: date)
            dateComponents.month = formatter.calendar.component(.month, from: date)
            dateComponents.day = formatter.calendar.component(.day, from: date)
            dateComponents.hour = formatter.calendar.component(.hour, from: time)
            dateComponents.minute = formatter.calendar.component(.minute, from: time)
            
            // title for the notification
            let title = "\(game.homeTeam.abbreviation) vs \(game.awayTeam.abbreviation)"
            
            createGameNotification(date: dateComponents, title: title)
        }
    }
    
    /// Create and queue a local notification of an upcoming game.
    /// - Parameters:
    ///     - date: The specific date to get the notification.
    ///     - title: The title game to add to the notification.
    private func createGameNotification(date: DateComponents, title: String) {
        let content = UNMutableNotificationContent() // create notification content
        content.title = NSLocalizedString("Game Alert", comment: "game_alert")
        content.body = title + NSLocalizedString(" starting soon", comment: "starting_soon")
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false) // set notification date trigger
        
        let identifier = "\(title) - \(selectedDate)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier]) // remove any requests with the same identifier
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil) // add the new request
    }
    
    // MARK: - Dealing with Dates
    
    /// Outlet for the rewind button.
    @IBOutlet weak private var rewindOutlet: UIBarButtonItem!
    /// Outlet for the rewind gesture.
    @IBOutlet private var rewindGestureOutlet: UISwipeGestureRecognizer!
    /// Outlet for the forward button.
    @IBOutlet private weak var forwardOutlet: UIBarButtonItem!
    /// Outlet for the forward gesture.
    @IBOutlet private var forwardGestureOutlet: UISwipeGestureRecognizer!
    
    /// Function to update the UI elements that control the dates 'isEnabled' feature based on the games available.
    private func updateDateChangers(){
        rewindOutlet.isEnabled = false // set all to false as default
        rewindGestureOutlet.isEnabled = false
        forwardOutlet.isEnabled = false
        forwardGestureOutlet.isEnabled = false
        for (date, available) in availableGameDates {
            // if games are not available on date, and the date isn't today continue
            if !available && date != getTodaysDate() { continue }
            if date > selectedDate { // found a game in the future
                forwardOutlet.isEnabled = true
                forwardGestureOutlet.isEnabled = true
            }
            else if date < selectedDate { // found a game in the past
                rewindOutlet.isEnabled = true
                rewindGestureOutlet.isEnabled = true
            }
        }
    }
    
    /// Change a stringed date in the API format by adding a certain amount of days to it.
    /// - Parameters:
    ///     - date: The stringed date to change.
    ///     - change: The amount of days to change by.
    private func changeDateByDays(date: String, change: Int) -> String {
        let oldDate = DateFormatter().stringToDate(string: date, format: DateFormats.API, timezone: appDelegate.currentTimeZoneIdentifier)
        let newDate = Calendar.current.date(byAdding: .day, value: change, to: oldDate)!
        return  DateFormatter().dateToString(date: newDate, format: DateFormats.API, timezone: appDelegate.currentTimeZoneIdentifier)
    }
    
    // MARK: - Retrieving and Decoding Data
    
    /// Get all the games on the selected date.
    /// - Parameters:
    ///     - reload: Whether or not data should be reloaded regardless of whether a file exists or not.
    private func getGameData(reload: Bool) {
        dateLabel.text = getNewDateText(date: selectedDate)
        availableGameDates.removeAll()
        
        var queries: [(API_QUERIES, String)] = []
        for change in -gamesToCheck...gamesToCheck { // find available games
            let API_date = convertTimeZones(string: changeDateByDays(date: selectedDate, change: change), from: appDelegate.currentTimeZoneIdentifier, to: TimeZoneIdentifiers.usa_nyk.rawValue, format: DateFormats.API)
            let formatter = DateFormatter()
            formatter.dateFormat = DateFormats.API.rawValue
            let API_date_string = formatter.string(from: API_date)
            
            queries.append((.dates, API_date_string)) // add to dates to search for
            availableGameDates[API_date_string] = false // initialise the availability as false
        }
        
        // determines whether file exists, display information (might be outdated quickly)
        let fileName = selectedDate + FileManagerFiles.date_game_collection_suffix.rawValue
        if doesFileExist(name: fileName) {
            // if file exists retrieve data, decode it and update views
            guard let data = getFileData(name: fileName) else {
                return displaySimpleMessage(title: FILE_MANAGER_DATA_ERROR_TITLE, message: FILE_MANAGER_DATA_ERROR_MESSAGE)
            }
            decodeGameData(data: data)
        }
        else {
            indicator.startAnimating() // call noisily if no file exists
        }
        
        // now update/create the data that either didn't exist or could be outdated
        // call silently if user hasn't selected to reload
        if reload { indicator.startAnimating() }
        
        Task {
            let (data, error) = await requestData(path: .games, queries: queries) // get data
            guard let data = data else { // deal with any errors
                displaySimpleMessage(title: error!.title, message: error!.message)
                indicator.stopAnimating()
                return
            }
            
            // update/create a file to persistently store the data retrieved
            setFileData(name: fileName, data: data)
            decodeGameData(data: data)
        }
    }
    
    /// Decode the game data retrieved from the API.
    /// - Parameters:
    ///     - data: The data to decode.
    private func decodeGameData(data: Data){
        selectedDateGames.removeAll() // clear the current games found
        do {
            let decoder = JSONDecoder()
            let collection = try decoder.decode(GameCollection.self, from: data) // decode data
            if let games = collection.games {
                for game in games {
                    let localDate = convertTimeZones(string: game.date, from: TimeZoneIdentifiers.usa_nyk.rawValue, to: appDelegate.currentTimeZoneIdentifier, format: DateFormats.fullAPI)
                    let formatter = DateFormatter()
                    formatter.dateFormat = DateFormats.API.rawValue
                    let localDateString = formatter.string(from: localDate)
                    if localDateString == selectedDate {
                        selectedDateGames.append(game) // add game if game is on current day
                    }
                    availableGameDates[localDateString] = true // we know now that there are available games on this date
                }
                updateDateChangers()
                tableView.reloadData()
                changeBadgeNumber()
                indicator.stopAnimating()
                addNotifications()
            }
        }
        catch let error { // catch any errors
            displaySimpleMessage(title: JSON_DECODER_ERROR_TITLE, message: error.localizedDescription)
            indicator.stopAnimating()
        }
    }
    
    // MARK: Triggered Actions
    
    /// Action to manually refresh the games.
    /// - Parameters:
    ///     - sender: The triggerer of this action.
    @IBAction private func manualRefreshGames(_ sender: Any) {
        getGameData(reload: true)
    }
    
    /// Action to reset the view controller to show the games on the current date.
    /// - Parameters:
    ///     - sender: The triggerer of this action.
    @IBAction private func resetToday(_ sender: Any) {
        selectedDate = getTodaysDate()
        getGameData(reload: false)
    }
    
    // MARK: Dates, Titles and Menus
    
    /// Action to change the selected date in view.
    /// - Parameters:
    ///     - sender: The triggerer of this action.
    @IBAction private func changeDateButton(_ sender: Any) {
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
        
        // get the current date and edit it
        var newDateString = changeDateByDays(date: selectedDate, change: change)
        
        while true { // keep going to find an date with a game
            if let available = availableGameDates[newDateString] {
                if available || newDateString == getTodaysDate() { break }
                newDateString = changeDateByDays(date: newDateString, change: change)
            }
            else { // shouldn't get to here, so if it does an exepected error has occured
                return displaySimpleMessage(title: NSLocalizedString("Unexpected error occurred", comment: ""), message: NSLocalizedString("No games found past/before this date.", comment: ""))
            }
        }
        
        selectedDate = newDateString
        getGameData(reload: false)
    }
    
    /// Function to get the new text to be displayed to show the user the current date.
    /// - Parameters:
    ///     - date: The stringed current date.
    /// - Returns: A string displaying a pretty printed version of the current date.
    private func getNewDateText(date: String) -> String {
        todayButtonOutlet.isEnabled = getTodaysDate() != date
        let currentDate = DateFormatter().stringToDate(string: date, format: DateFormats.API, timezone: appDelegate.currentTimeZoneIdentifier)
        return DateFormatter().dateToString(date: currentDate, format: DateFormats.display, timezone: appDelegate.currentTimeZoneIdentifier)
    }
    
    /// Gets today's date as a string in API format.
    /// - Returns: Today's date as a string.
    private func getTodaysDate() -> String { // gets todays date as a string
        return DateFormatter().dateToString(date: Date(), format: DateFormats.API, timezone: appDelegate.currentTimeZoneIdentifier)
    }
    
    /// Changes the badge number shown on this view's tab bar item to match the amount of live games there are.
    private func changeBadgeNumber() {
        var numberOfLiveGames = 0
        if selectedDate == getTodaysDate() {
            for game in selectedDateGames {
                if game.status != "Final", !game.status.hasSuffix("ET") { // check if game is live
                    numberOfLiveGames += 1
                }
            }
            
            if numberOfLiveGames != 0 { // display the number of live games on the badge of the tab item
                navigationController?.tabBarItem.badgeValue = String(describing: numberOfLiveGames)
            }
            else { // if there are no live games, don't display anything on badge
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
        if selectedDateGames.isEmpty {
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
            
            if game.time == "" && game.status.hasSuffix("T"){ // if game has not started yet, set everything to default
                cell.awayTeamScore.text = game.awayTeam.abbreviation
                cell.homeTeamScore.text = game.homeTeam.abbreviation
                cell.timeLabel.text = "@"
                cell.statusLabel.text = APItoCurrentTimeZoneDisplay(string: game.status)
                cell.timeLabel.backgroundColor = UIColor.secondarySystemBackground
                cell.homeTeamScore.textColor = UILabel().textColor
                cell.awayTeamScore.textColor = UILabel().textColor
                cell.awayTeamScore.font = UIFont.systemFont(ofSize: cell.awayTeamScore.font.pointSize)
                cell.homeTeamScore.font = UIFont.systemFont(ofSize: cell.homeTeamScore.font.pointSize)
            }
            else { // winning team has bolded and system blue colour to their score
                cell.awayTeamScore.text = "\(game.awayTeam.abbreviation) - \(game.awayScore)"
                cell.homeTeamScore.text = "\(game.homeScore) - \(game.homeTeam.abbreviation)"
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
                
                if game.time == "" && game.status.hasSuffix("Qtr") { // if the game is at the start/end of a quarter
                    if game.awayScore == 0 && game.homeScore == 0 { // if game is at start of first quarter
                        cell.timeLabel.text = NSLocalizedString("Start", comment: "Start")
                    }
                    else { // otherwise game is at end of quarter
                        cell.timeLabel.text = NSLocalizedString("End", comment: "End")
                    }
                    
                }
                else { // if game is live, show the time with a systemGreen background
                    cell.timeLabel.text = game.time
                    cell.timeLabel.backgroundColor = UIColor.systemGreen
                }
                cell.statusLabel.text = NSLocalizedString(game.status, comment: "")
            }
            
            cell.awayTeamImage.image = UIImage(named: game.awayTeam.abbreviation)
            cell.homeTeamImage.image = UIImage(named: game.homeTeam.abbreviation)
            
            return cell
        }
        
        // otherwise there are no games, so display a cell accordingly
        let cell = tableView.dequeueReusableCell(withIdentifier: INFO_CELL_IDENTIFIER, for: indexPath)
        cell.textLabel?.text = NSLocalizedString("No games on this date", comment: "no_games")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let game = selectedDateGames[indexPath.row]
        selectedGame = game
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: selectedGameSegue , sender: self) // segue to show detailed information about game
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == selectedGameSegue {
            let destination = segue.destination as! DetailedGameTableViewController
            destination.game = selectedGame // give destination some information about the game
        }
    }
}
