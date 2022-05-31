//
//  PlayerDataCollection.swift
//  All-NBA
//
//  Created by Samir Gupta on 31/5/2022.
//

import Foundation

class PlayerDataCollection: NSObject, Decodable { // used to store a collection of players from API
    var players: [PlayerData]?
    
    private enum CodingKeys: String, CodingKey {
        case players = "data"
    }
}
