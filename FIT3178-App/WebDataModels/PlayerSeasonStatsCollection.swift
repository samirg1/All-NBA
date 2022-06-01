//
//  PlayerSeasonStatsCollection.swift
//  All-NBA
//
//  Created by Samir Gupta on 31/5/2022.
//

import Foundation

class PlayerSeasonStatCollection: NSObject, Decodable { // used to store a collection of teams from API
    var players: [PlayerSeasonStats]?
    
    private enum CodingKeys: String, CodingKey {
        case players = "data"
    }
}
