//
//  AppDelegate.swift
//  FIT3178-App
//
//  Created by Samir Gupta on 21/3/22.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let API_URL_SCHEME = "https"
    let API_URL_HOST = "www.balldontlie.io"
    let API_URL_PATH = "/api/v1/"
    let API_URL_PATH_STATS = "stats"
    let API_URL_PATH_GAMES = "games"
    let API_URL_PATH_TEAMS = "teams"
    let API_QUERY_GAME_ID = "game_ids[]"
    let API_QUERY_PER_PAGE = "per_page"
    let API_QUERY_DATES = "dates[]"
    let API_QUERY_START_DATE = "start_date"
    let API_QUERY_END_DATE = "end_date"
    let API_QUERY_SEASONS = "seasons[]"
    let API_QUERY_TEAM_ID = "team_ids[]"
    
    let URL_CONVERSION_ERROR_TITLE = "Unable to retrieve information"
    let URL_CONVERSION_ERROR_MESSAGE = "Invalid URL"
    let API_ERROR_TITLE = "An error occured whilst retrieving data"
    let FILE_MANAGER_DATA_ERROR_TITLE = "An error occured fetching data"
    let FILE_MANAGER_DATA_ERROR_MESSAGE = "Stored file data is invalid"
    let JSON_DECODER_ERROR_TITLE = "Error decoding API data"
    
    lazy var cacheDirectoryPath: URL = {
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

