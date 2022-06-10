//
//  PlayerSeasonStats.swift
//  All-NBA
//
//  Created by Samir Gupta on 31/5/2022.
//

import UIKit

/// Class to house a players season stat averages.
class PlayerSeasonStats: NSObject, Decodable {
    /// The ID of the player.
    var id: Int
    /// The average amount of points this player scores per game.
    var pts: Double
    /// The average amount of assists this player acquires per game.
    var ast: Double
    /// The average amount of rebounds this player secures per game.
    var reb: Double
    
    /// The coding keys required for decoding.
    private enum StatKeys: String, CodingKey {
        case id = "player_id"
        case pts
        case ast
        case reb
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: StatKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        pts = try container.decode(Double.self, forKey: .pts)
        ast = try container.decode(Double.self, forKey: .ast)
        reb = try container.decode(Double.self, forKey: .reb)
    }
    
}

/// Class used to house a collection of player's season stat averages.
class PlayerSeasonStatCollection: NSObject, Decodable {
    /// The collection of players' season stats.
    var players: [PlayerSeasonStats]?
    
    /// The coding keys required for decoding.
    private enum CodingKeys: String, CodingKey {
        case players = "data"
    }
}
