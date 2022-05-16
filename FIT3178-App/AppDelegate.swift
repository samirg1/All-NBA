//
//  AppDelegate.swift
//  FIT3178-App
//
//  Created by Samir Gupta on 21/3/22.
//

import UIKit

public enum HTTP_ERROR_CODES: Int {
    case success = 200
    case bad_request = 400
    case not_found = 404
    case not_acceptable = 406
    case too_many_requests = 429
    case server_error = 500
    case service_unavailable = 503
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    public let API_URL_SCHEME = "https"
    public let API_URL_HOST = "www.balldontlie.io"
    public let API_URL_PATH = "/api/v1/"
    public let API_URL_PATH_STATS = "stats"
    public let API_URL_PATH_GAMES = "games"
    public let API_URL_PATH_TEAMS = "teams"
    public let API_QUERY_GAME_ID = "game_ids[]"
    public let API_QUERY_PER_PAGE = "per_page"
    public let API_QUERY_DATES = "dates[]"
    public let API_QUERY_START_DATE = "start_date"
    public let API_QUERY_END_DATE = "end_date"
    public let API_QUERY_SEASONS = "seasons[]"
    public let API_QUERY_TEAM_ID = "team_ids[]"
    public let API_ERROR_CODE_MESSAGES = [
        HTTP_ERROR_CODES.bad_request.rawValue: "Invalid server request",
        HTTP_ERROR_CODES.not_found.rawValue: "Server request was not found",
        HTTP_ERROR_CODES.not_acceptable.rawValue: "Invalid server request format",
        HTTP_ERROR_CODES.too_many_requests.rawValue: "Too many server requests",
        HTTP_ERROR_CODES.server_error.rawValue: "Internal server error",
        HTTP_ERROR_CODES.service_unavailable.rawValue: "Server currently unavailable"
    ]
    
    public let URL_CONVERSION_ERROR_TITLE = "Unable to retrieve information"
    public let URL_CONVERSION_ERROR_MESSAGE = "Invalid URL"
    public let API_ERROR_TITLE = "An error occured whilst retrieving data"
    public let FILE_MANAGER_DATA_ERROR_TITLE = "An error occured fetching data"
    public let FILE_MANAGER_DATA_ERROR_MESSAGE = "Stored file data is invalid"
    public let JSON_DECODER_ERROR_TITLE = "Error decoding API data"
    
    public lazy var cacheDirectoryPath: URL = {
        let cacheDirectoryPaths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        return cacheDirectoryPaths[0]
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
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


}

