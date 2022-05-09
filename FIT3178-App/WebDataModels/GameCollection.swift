//
//  GamesData.swift
//  FIT3178-App
//
//  Created by Samir Gupta on 19/4/22.
//

import UIKit

class GameCollection: NSObject, Decodable { // used to store a collection of games from API
    var games: [GameData]?
    
    private enum CodingKeys: String, CodingKey {
        case games = "data"
    }
}
