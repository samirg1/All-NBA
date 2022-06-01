//
//  PlayerSeasonStats.swift
//  All-NBA
//
//  Created by Samir Gupta on 31/5/2022.
//

import UIKit

class PlayerSeasonStats: NSObject, Decodable {
    var id: Int
    var pts: Double
    var ast: Double
    var reb: Double
    
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
