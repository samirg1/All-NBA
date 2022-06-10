//
//  Game.swift
//  FIT3178-App
//
//  Created by Samir Gupta on 19/4/22.
//

import UIKit

/// Class used to represent a particular NBA game.
class Game: NSObject, Decodable {
    /// The ID of the game.
    var id: Int
    /// The date of the game.
    var date: String
    /// The hosting team in the game.
    var homeTeam : Team
    /// The visiting team in the game.
    var awayTeam : Team
    /// The hosting team's score.
    var homeScore : Int
    /// The visiting team's score.
    var awayScore : Int
    /// The current period of the game.
    var period : Int
    /// The current time left in the current period of the game.
    var time : String
    /// The status of the game.
    var status : String
    
    /// The coding keys required to decode.
    private enum DataKeys: String, CodingKey {
        case id
        case date
        case homeTeam = "home_team"
        case awayTeam = "visitor_team"
        case homeScore = "home_team_score"
        case awayScore = "visitor_team_score"
        case period
        case time
        case status
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DataKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        homeTeam = try container.decode(Team.self, forKey: .homeTeam)
        awayTeam = try container.decode(Team.self, forKey: .awayTeam)
        homeScore = try container.decode(Int.self, forKey: .homeScore)
        awayScore = try container.decode(Int.self, forKey: .awayScore)
        period = try container.decode(Int.self, forKey: .period)
        time = try container.decode(String.self, forKey: .time)
        status = try container.decode(String.self, forKey: .status)
        date = try container.decode(String.self, forKey: .date)
    }
}

/// Class used to house a collection of games.
class GameCollection: NSObject, Decodable {
    /// The stored games.
    var games: [Game]?
    
    /// The coding keys that enable decoding.
    private enum CodingKeys: String, CodingKey {
        case games = "data"
    }
}
