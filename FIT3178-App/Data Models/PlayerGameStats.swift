//
//  PlayerGameStats.swift
//  FIT3178-App
//
//  Created by Samir Gupta on 20/4/22.
//

import UIKit

/// Class to store a player's game stats.
class PlayerGameStats : NSObject, Decodable {
    /// The ID of this particular set of stats.
    var id: Int
    /// The amount of points the player has scored in the game.
    var pts: Int
    /// The amount of rebounds the player has secured in the game.
    var reb: Int
    /// The amount of assists the player has in the game
    var ast: Int
    /// The amount of blocks the player has in the game.
    var blk: Int
    /// The amount of steals the player has in the game.
    var stl: Int
    /// The amount of turnovers the player has in the game.
    var turnover: Int
    /// The amount of defensive rebounds the player has in the game.
    var dreb: Int
    /// The amount of offensive rebounds the player has in the game.
    var oreb: Int
    /// The player's 3-point percentage.
    var pct3: Float
    /// The amount of 3-point shots the player has made in the game.
    var fgm3: Int
    /// The amount of 3-point shots the player has attempted in the game.
    var fga3: Int
    /// The player's overall shot percentage.
    var pct: Float
    /// The amount of shots the player has made in the game.
    var fgm: Int
    /// The amount of shots the player has attempted in the game.
    var fga: Int
    /// The player's free throw percentage.
    var pct1: Float
    /// The amount of free throws the player has attempted in the game.
    var fta: Int
    /// The amount of free throws the player has made in the game.
    var ftm: Int
    /// The amount of minutes the player has played in the game.
    var min: Int
    /// The amount of fouls the player has in the game.
    var pf: Int
    /// The player's ID
    var playerId : Int
    /// The player's first name.
    var playerFirstName : String
    /// The player's last name.
    var playerLastName : String
    /// The player's team's ID.
    var teamId : Int
    /// The player's team's abbreviated name.
    var teamAbbreviation : String
    /// The ID of the game.
    var gameId: Int
    /// The ID of the home team of the game.
    var gameHomeTeamId: Int
    /// The ID of the away team of the game.
    var gameAwayTeamId: Int
    /// The home team's score in the game.
    var gameHomeScore: Int
    /// The away team's score in the game.
    var gameAwayScore: Int
    /// The date of the game.
    var gameDate: String
    
    /// The coding keys required for decoding the root level.
    private enum CodingKeys: String, CodingKey {
        case id
        case pts
        case reb
        case ast
        case blk
        case stl
        case turnover
        case dreb
        case oreb
        case pct3 = "fg3_pct"
        case fgm3 = "fg3m"
        case fga3 = "fg3a"
        case pct = "fg_pct"
        case fgm
        case fga
        case pct1 = "ft_pct"
        case fta
        case ftm
        case min
        case pf
        case player
        case team
        case game
    }
    
    /// The coding keys required for decoding the team level.
    private enum TeamKeys: String, CodingKey {
        case teamId = "id"
        case teamAbbreviation = "abbreviation"
    }
    
    /// The coding keys required for decoding the player level.
    private enum PlayerKeys: String, CodingKey {
        case playerId = "id"
        case playerFirstName = "first_name"
        case playerLastName = "last_name"
    }
    
    /// The coding keys required for decoding the game level.
    private enum GameKeys: String, CodingKey {
        case gameId = "id"
        case gameHomeTeamId = "home_team_id"
        case gameAwayTeamId = "visitor_team_id"
        case gameHomeScore = "home_team_score"
        case gameAwayScore = "visitor_team_score"
        case gameDate = "date"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let teamContainer = try container.nestedContainer(keyedBy: TeamKeys.self, forKey: .team)
        let playerContainer = try container.nestedContainer(keyedBy: PlayerKeys.self, forKey: .player)
        let gameContainer = try container.nestedContainer(keyedBy: GameKeys.self, forKey: .game)
        
        id = try container.decode(Int.self, forKey: .id)
        pts = try container.decode(Int.self, forKey: .pts)
        reb = try container.decode(Int.self, forKey: .reb)
        ast = try container.decode(Int.self, forKey: .ast)
        blk = try container.decode(Int.self, forKey: .blk)
        stl = try container.decode(Int.self, forKey: .stl)
        turnover = try container.decode(Int.self, forKey: .turnover)
        dreb = try container.decode(Int.self, forKey: .dreb)
        oreb = try container.decode(Int.self, forKey: .oreb)
        pct3 = decimalToPercentageConversion(try container.decode(Float.self, forKey: .pct3))
        fgm3 = try container.decode(Int.self, forKey: .fgm3)
        fga3 = try container.decode(Int.self, forKey: .fga3)
        pct = decimalToPercentageConversion(try container.decode(Float.self, forKey: .pct))
        fgm = try container.decode(Int.self, forKey: .fgm)
        fga = try container.decode(Int.self, forKey: .fga)
        pct1 = decimalToPercentageConversion(try container.decode(Float.self, forKey: .pct1))
        fta = try container.decode(Int.self, forKey: .fta)
        ftm = try container.decode(Int.self, forKey: .ftm)
        min = Int(try container.decode(String.self, forKey: .min))!
        pf = try container.decode(Int.self, forKey: .pf)
        playerId = try playerContainer.decode(Int.self, forKey: .playerId)
        playerFirstName = try playerContainer.decode(String.self, forKey: .playerFirstName)
        playerLastName = try playerContainer.decode(String.self, forKey: .playerLastName)
        teamId = try teamContainer.decode(Int.self, forKey: .teamId)
        teamAbbreviation = try teamContainer.decode(String.self, forKey: .teamAbbreviation)
        gameId = try gameContainer.decode(Int.self, forKey: .gameId)
        gameHomeScore = try gameContainer.decode(Int.self, forKey: .gameHomeScore)
        gameAwayScore = try gameContainer.decode(Int.self, forKey: .gameAwayScore)
        gameAwayTeamId = try gameContainer.decode(Int.self, forKey: .gameAwayTeamId)
        gameHomeTeamId = try gameContainer.decode(Int.self, forKey: .gameHomeTeamId)
        gameDate = try gameContainer.decode(String.self, forKey: .gameDate)
    }
}

/// Class to store a collection of player's game stats.
class PlayerGameStatsCollection: NSObject, Decodable {
    /// The collection of player's game stats.
    var playersGameStats : [PlayerGameStats]?
    
    /// The coding keys required for decoding.
    private enum CodingKeys: String, CodingKey {
        case playersGameStats = "data"
    }
}
