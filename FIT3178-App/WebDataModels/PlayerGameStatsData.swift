//
//  PlayerGameStatsData.swift
//  FIT3178-App
//
//  Created by Samir Gupta on 20/4/22.
//

import UIKit

class PlayerGameStatsData : NSObject, Decodable { // used to store all player stats from a specific game from the API
    var id: Int
    
    var pts: Int
    var reb: Int
    var ast: Int
    var blk: Int
    var stl: Int
    var turnover: Int
    
    var dreb: Int
    var oreb: Int
    
    var pct3: Float
    var fgm3: Int
    var fga3: Int
    var pct: Float
    var fgm: Int
    var fga: Int
    var pct1: Float
    var fta: Int
    var ftm: Int
    
    var min: String
    var pf: Int
    
    var playerId : Int
    var playerFirstName : String
    var playerLastName : String
    var teamId : Int
    var teamAbbreviation : String
    
    var gameId: Int
    var gameHomeTeamId: Int
    var gameAwayTeamId: Int
    var gameHomeScore: Int
    var gameAwayScore: Int
    var gameDate: String
    
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
    
    private enum TeamKeys: String, CodingKey {
        case teamId = "id"
        case teamAbbreviation = "abbreviation"
    }
    
    private enum PlayerKeys: String, CodingKey {
        case playerId = "id"
        case playerFirstName = "first_name"
        case playerLastName = "last_name"
    }
    
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
        pct3 = try container.decode(Float.self, forKey: .pct3)
        fgm3 = try container.decode(Int.self, forKey: .fgm3)
        fga3 = try container.decode(Int.self, forKey: .fga3)
        pct = try container.decode(Float.self, forKey: .pct)
        fgm = try container.decode(Int.self, forKey: .fgm)
        fga = try container.decode(Int.self, forKey: .fga)
        pct1 = try container.decode(Float.self, forKey: .pct1)
        fta = try container.decode(Int.self, forKey: .fta)
        ftm = try container.decode(Int.self, forKey: .ftm)
        min = try container.decode(String.self, forKey: .min)
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
