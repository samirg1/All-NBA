//
//  FileManager.swift
//  All-NBA
//
//  Created by Samir Gupta on 31/5/2022.
//

import Foundation
import UIKit

/// Variable to access the ``AppDelegate-swift.class`` of this app.
let appDelegate = UIApplication.shared.delegate as! AppDelegate

/// Variable to access the cache directory path for the `FileManager` of the App.
fileprivate var cacheDirectoryPath: URL = {
    let cacheDirectoryPaths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
    return cacheDirectoryPaths[0]
}()

/// Error title used when the data stored in `FileManager` is invalid.
public let FILE_MANAGER_DATA_ERROR_TITLE = NSLocalizedString("An error occured fetching data", comment: "error_fetching_data")
/// Error message used when the data stored in `FileManager` is invalid.
public let FILE_MANAGER_DATA_ERROR_MESSAGE = NSLocalizedString("Stored file data is invalid.", comment: "invalid_file_data")


/// Stores the currently used FileManager file names/suffixes.
public enum FileManagerFiles: String {
    /// Suffix for the files that store a collection of games on a particular date.
    case date_game_collection_suffix = "-gameCollection"
    /// Suffix for the files that store a team's stats from a particular game.
    case team_game_stats_suffix = "-teamStats"
    /// Suffix for the files that store a collection of a particular team's  season games.
    case team_season_games_suffix = "-seasonGamesData"
    /// Suffix for the files that store all of the teams in a  season.
    case all_teams_suffix = "-all_teams"
    /// Suffix for files that store the season stats of a particular player.
    case player_season_stats_suffix = "-seasonStats"
    /// File name for where the storage of the user's favourite teams are.
    case favourite_teams = "user_favourite_teams"
    /// File name for where the storage of the user's favourite players are.
    case favourite_players = "user_favourite_players"
    /// File name for the users preferences on game alerts.
    case game_alert_notifications = "game_alert_notifications"
}

/// Check if a particular file exists.
/// - Parameters:
///     - name: The name of the file.
/// - Returns: If the files exists, `true`, otherwise `false`.
public func doesFileExist(name: String) -> Bool {
    let localURL = cacheDirectoryPath.appendingPathComponent(name)
    return FileManager.default.fileExists(atPath: localURL.path)
}

/// Get the data of a particular file.
/// - Parameters:
///     - name: The name of the file.
/// - Returns: The data (if any) that the file contains.
public func getFileData(name: String) -> Data? {
    if doesFileExist(name: name) {
        let localURL = cacheDirectoryPath.appendingPathComponent(name)
        return FileManager.default.contents(atPath: localURL.path)
    }
    return nil
}

/// Create or update a file's data.
/// - Parameters:
///     - name: The name of the file to update or create.
///     - data: The updated or new data to store in this file.
public func setFileData(name: String, data: Data) {
    let localURL = cacheDirectoryPath.appendingPathComponent(name)
    FileManager.default.createFile(atPath: localURL.path, contents: data, attributes: [:])
}

/// Update the ``AppDelegate-swift.class`` to have the current versions of user favourites.
public func getFavourites() {
    let teamFileName = FileManagerFiles.favourite_teams.rawValue
    if doesFileExist(name: teamFileName)
    {
        if let data = getFileData(name: teamFileName) {
            do {
                let decoder = JSONDecoder()
                let collection = try decoder.decode([Team].self, from: data) // decode file data
                appDelegate.favouriteTeams = collection // update app delegate
            }
            catch let error {
                print(error.localizedDescription)
            }
        }
    }
    let playerFileName = FileManagerFiles.favourite_players.rawValue
    if doesFileExist(name: playerFileName)
    {
        if let data = getFileData(name: playerFileName) {
            do {
                let decoder = JSONDecoder()
                let collection = try decoder.decode([Player].self, from: data) // decode file data
                appDelegate.favouritePlayers = collection // update app delegate
            }
            catch let error {
                print(error.localizedDescription)
            }
        }
    }
}

/// Update the user favourites in stored files to match the ``AppDelegate-swift.class``.
public func updateFavourites() {
    let encoder = JSONEncoder()
    guard let team_data = try? encoder.encode(appDelegate.favouriteTeams), let player_data = try? encoder.encode(appDelegate.favouritePlayers) else {
        return
    }
    
    setFileData(name: FileManagerFiles.favourite_teams.rawValue, data: team_data) // store updated user data
    setFileData(name: FileManagerFiles.favourite_players.rawValue, data: player_data)
}

/// Update or retrieve the current status of the user's notification settings.
///
/// If an update on these settings has occured, the files will be updated, otherwise the current data is checked to ensure up to date settings.
/// The notifcation setting are stored as an array of 0s or 1s, where a 0 indicates false and 1 indicates true. Currently the data is stored as
/// [game alerts, favourites only].
/// - Parameters:
///     - update: Boolean value determining whether an update has occured or not.
public func getNotificationSettings(update: Bool) {
    let fileName = FileManagerFiles.game_alert_notifications.rawValue
    if doesFileExist(name: fileName) && !update {
        if let data = getFileData(name: fileName) { // get notification settings
            appDelegate.gameAlertNotifcations = Bool(exactly: data[0] as NSNumber)!
            appDelegate.favouritesOnlyNotifications = Bool(exactly: data[1] as NSNumber)!
        }
    }
    else {
        let gameAlert = UInt8(exactly: NSNumber(booleanLiteral: appDelegate.gameAlertNotifcations))!
        let favOnly = UInt8(exactly: NSNumber(booleanLiteral: appDelegate.favouritesOnlyNotifications))!
        let data = Data([gameAlert, favOnly])
        setFileData(name: fileName, data: data)
    }
}
