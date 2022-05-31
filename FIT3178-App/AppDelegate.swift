//
//  AppDelegate.swift
//  FIT3178-App
//
//  Created by Samir Gupta on 21/3/22.
//

import UIKit

/// Stores the HTTP error codes that come as a response to calling the API.
public enum HTTP_ERROR_CODES: Int {
    
    /// API response code when the request is successful.
    case success = 200
    
    /// API response when the request is invalid.
    case bad_request = 400
    
    /// API response when response requested is not found.
    case not_found = 404
    
    /// API response code when the format requested is invalid.
    case not_acceptable = 406
    
    /// API response code when there have been too many requests.
    case too_many_requests = 429
    
    /// API response code when there is an error in the API's internal server.
    case server_error = 500
    
    /// API response code when the API's server is down or under maintainence.
    case service_unavailable = 503
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    /// The scheme of the API URL used for retrieving data.
    public let API_URL_SCHEME = "https"
    
    /// The host of the API URL used for retrieving data.
    public let API_URL_HOST = "www.balldontlie.io"
    
    /// The current path of the API's URL.
    public let API_URL_PATH = "/api/v1/"
    
    /// The path of the API to access player's stats.
    public let API_URL_PATH_STATS = "stats"
    
    /// The path of the API to access games.
    public let API_URL_PATH_GAMES = "games"
    
    /// The path of the API to access teams.
    public let API_URL_PATH_TEAMS = "teams"
    
    /// The path of the API to access players.
    public let API_URL_PATH_PLAYERS = "players"
    
    /// The query of the API to search for specific players.
    public let API_QUERY_PLAYER_SEARCH = "search"
    
    /// The query of the API to specify game IDs.
    public let API_QUERY_GAME_ID = "game_ids[]"
    
    /// The query of the API to change the amount of results retrieved in one page.
    public let API_QUERY_PER_PAGE = "per_page"
    
    /// The query of the API to specify certain dates.
    public let API_QUERY_DATES = "dates[]"
    
    /// The query of the API to specify a start date for results.
    public let API_QUERY_START_DATE = "start_date"
    
    /// The query of the API to specify an end date for results.
    public let API_QUERY_END_DATE = "end_date"
    
    /// The query of the API to specify specific seasons to search results for.
    public let API_QUERY_SEASONS = "seasons[]"
    
    /// The query of the API to specify team IDs to find results for.
    public let API_QUERY_TEAM_ID = "team_ids[]"
    
    /// A dictionary storing key value pairs of the error codes returned by the API, and appropriate error messages to display to the user in response to the error code.
    public let API_ERROR_CODE_MESSAGES = [
        HTTP_ERROR_CODES.bad_request.rawValue: "Invalid server request.",
        HTTP_ERROR_CODES.not_found.rawValue: "Server request was not found.",
        HTTP_ERROR_CODES.not_acceptable.rawValue: "Invalid server request format.",
        HTTP_ERROR_CODES.too_many_requests.rawValue: "Too many server requests.",
        HTTP_ERROR_CODES.server_error.rawValue: "Internal server error.",
        HTTP_ERROR_CODES.service_unavailable.rawValue: "Server currently unavailable."
    ]
    
    /// Error message title used when the built URL was unable to be converted into a URL.
    public let URL_CONVERSION_ERROR_TITLE = "Unable to retrieve information"
    
    /// Error message when the built URL was unable to be converted into a URL.
    public let URL_CONVERSION_ERROR_MESSAGE = "Invalid URL."
    
    /// Error title when an unexpected error occurs when retrieving API data.
    public let API_ERROR_TITLE = "An error occured whilst retrieving data"
    
    /// Error title used when the data stored in `FileManager` is invalid.
    public let FILE_MANAGER_DATA_ERROR_TITLE = "An error occured fetching data"
    
    /// Error message used when the data stored in `FileManager` is invalid
    public let FILE_MANAGER_DATA_ERROR_MESSAGE = "Stored file data is invalid."
    
    /// Error message used when there is an error decoding data
    public let JSON_DECODER_ERROR_TITLE = "Error decoding API data"
    
    /// Variable to access the cache directory path for the `FileManager` of the App.
    public lazy var cacheDirectoryPath: URL = {
        let cacheDirectoryPaths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return cacheDirectoryPaths[0]
    }()
    
    /// Variable that determines whether the notifications have been enabled on the current device.
    public var notificationsEnabled: Bool = false
    
    /// Variable that determines the identifier of the timezone that the App will show times and dates in.
    public var currentTimeZoneIdentifier = TimeZone.current.identifier
    
    public let FAVOURITE_TEAMS_FILE = "user_favourite_teams"
    public let FAVOURITE_PLAYERS_FILE = "user_favourite_players"
    public var favouriteTeams: [TeamData] = []
    public var favouritePlayers: [PlayerData] = []
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.getNotificationSettings { notificationSettings in
            if notificationSettings.authorizationStatus == .notDetermined {
                
                notificationCenter.requestAuthorization(options: [.alert]) { granted, error in
                    self.notificationsEnabled = granted
                    if granted {
                        let notificationCenter = UNUserNotificationCenter.current()
                        notificationCenter.delegate = self
                    }
                }
            }
            else if notificationSettings.authorizationStatus == .authorized {
                self.notificationsEnabled = true
                let notificationCenter = UNUserNotificationCenter.current()
                notificationCenter.delegate = self
            }
        }
        
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // Function required when registering as a delegate. We can process notifications if they are in the foreground!
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Print some information to console saying we have recieved the notification
        // We could do some automatic processing here if we didnt want the user's response
        print("Notification triggered while app running")
        
        // By default iOS will silence a notification if the application is in the foreground. We can over-ride this with the following
        completionHandler([.banner])
    }
    
    func getFavourites() {
        let favourile_teams_URL = cacheDirectoryPath.appendingPathComponent(FAVOURITE_TEAMS_FILE)
        if FileManager.default.fileExists(atPath: favourile_teams_URL.path)
        {
            let data = FileManager.default.contents(atPath: favourile_teams_URL.path)
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let collection = try decoder.decode([TeamData].self, from: data)
                    favouriteTeams = collection
                }
                catch let error {
                    print(error.localizedDescription)
                }
            }
        }
        let favourile_players_URL = cacheDirectoryPath.appendingPathComponent(FAVOURITE_PLAYERS_FILE)
        if FileManager.default.fileExists(atPath: favourile_players_URL.path)
        {
            let data = FileManager.default.contents(atPath: favourile_players_URL.path)
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let collection = try decoder.decode([PlayerData].self, from: data)
                    favouritePlayers = collection
                }
                catch let error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func updateFavourites() {
        let encoder = JSONEncoder()
        guard let team_data = try? encoder.encode(favouriteTeams), let player_data = try? encoder.encode(favouritePlayers) else {
            return
        }
    
        let team_localURL = cacheDirectoryPath.appendingPathComponent(FAVOURITE_TEAMS_FILE)
        let player_localURL = cacheDirectoryPath.appendingPathComponent(FAVOURITE_PLAYERS_FILE)
        
        FileManager.default.createFile(atPath: team_localURL.path, contents: team_data, attributes: [:])
        FileManager.default.createFile(atPath: player_localURL.path, contents: player_data, attributes: [:])
    }
}

