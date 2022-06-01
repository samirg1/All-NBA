//
//  FileManager.swift
//  All-NBA
//
//  Created by Samir Gupta on 31/5/2022.
//

import Foundation
import UIKit

private let appDelegate = UIApplication.shared.delegate as! AppDelegate

/// Error title used when the data stored in `FileManager` is invalid.
public let FILE_MANAGER_DATA_ERROR_TITLE = "An error occured fetching data"

/// Error message used when the data stored in `FileManager` is invalid.
public let FILE_MANAGER_DATA_ERROR_MESSAGE = "Stored file data is invalid."

/// File name for where the storage of the user's favourite teams are.
public let FAVOURITE_TEAMS_FILE = "user_favourite_teams"

/// File name for where the storage of the user's favourite players are.
public let FAVOURITE_PLAYERS_FILE = "user_favourite_players"

/// Variable to access the cache directory path for the `FileManager` of the App.
public var cacheDirectoryPath: URL = {
    let cacheDirectoryPaths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
    return cacheDirectoryPaths[0]
}()

public enum FileManagerFiles: String {
    case date_game_collection_suffix = "-gameCollection"
    case team_game_stats_suffix = "-teamStats"
    case team_season_games_suffix = "-seasonGamesData"
    case all_teams_suffix = "-all_teams"
    case player_season_stats_suffix = "-seasonStats"
}

public func doesFileExist(name: String) -> Bool {
    let localURL = cacheDirectoryPath.appendingPathComponent(name)
    return FileManager.default.fileExists(atPath: localURL.path)
}

public func getFileData(name: String) -> Data? {
    if doesFileExist(name: name) {
        let localURL = cacheDirectoryPath.appendingPathComponent(name)
        return FileManager.default.contents(atPath: localURL.path)
    }
    return nil
}

public func setFileData(name: String, data: Data) {
    let localURL = cacheDirectoryPath.appendingPathComponent(name)
    FileManager.default.createFile(atPath: localURL.path, contents: data, attributes: [:])
}

public func getFavourites() {
    let favourile_teams_URL = cacheDirectoryPath.appendingPathComponent(FAVOURITE_TEAMS_FILE)
    if FileManager.default.fileExists(atPath: favourile_teams_URL.path)
    {
        let data = FileManager.default.contents(atPath: favourile_teams_URL.path)
        if let data = data {
            do {
                let decoder = JSONDecoder()
                let collection = try decoder.decode([TeamData].self, from: data)
                appDelegate.favouriteTeams = collection
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
                appDelegate.favouritePlayers = collection
            }
            catch let error {
                print(error.localizedDescription)
            }
        }
    }
}

public func updateFavourites() {
    let encoder = JSONEncoder()
    guard let team_data = try? encoder.encode(appDelegate.favouriteTeams), let player_data = try? encoder.encode(appDelegate.favouritePlayers) else {
        return
    }

    let team_localURL = cacheDirectoryPath.appendingPathComponent(FAVOURITE_TEAMS_FILE)
    let player_localURL = cacheDirectoryPath.appendingPathComponent(FAVOURITE_PLAYERS_FILE)
    
    FileManager.default.createFile(atPath: team_localURL.path, contents: team_data, attributes: [:])
    FileManager.default.createFile(atPath: player_localURL.path, contents: player_data, attributes: [:])
}
