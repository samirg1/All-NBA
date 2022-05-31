//
//  GameData.swift
//  FIT3178-App
//
//  Created by Samir Gupta on 19/4/22.
//

import UIKit

class GameData: NSObject, Decodable { // used to store a specific game's data from the API
    var id: Int
    
    var homeTeam : TeamData
    var awayTeam : TeamData
    var homeScore : Int
    var awayScore : Int
   
    var period : Int?
    var time : String?
    var status : String?
    
    private enum DataKeys: String, CodingKey {
        case id
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
        homeTeam = try container.decode(TeamData.self, forKey: .homeTeam)
        awayTeam = try container.decode(TeamData.self, forKey: .awayTeam)
        homeScore = try container.decode(Int.self, forKey: .homeScore)
        awayScore = try container.decode(Int.self, forKey: .awayScore)
        period = try container.decode(Int?.self, forKey: .period)
        time = try container.decode(String?.self, forKey: .time)
        status = try container.decode(String?.self, forKey: .status)
    }
}
