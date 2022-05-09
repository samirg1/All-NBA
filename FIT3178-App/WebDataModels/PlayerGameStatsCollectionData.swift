//
//  PlayerGameStatsCollection.swift
//  FIT3178-App
//
//  Created by Samir Gupta on 20/4/22.
//

import UIKit

class PlayerGameStatsCollectionData: NSObject, Decodable { // used to store a collection of players' game stats from API
    var playersGameStats : [PlayerGameStatsData]?
    
    private enum CodingKeys: String, CodingKey {
        case playersGameStats = "data"
    }
}
 
