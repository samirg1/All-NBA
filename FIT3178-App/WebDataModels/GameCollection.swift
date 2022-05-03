//
//  GamesData.swift
//  FIT3178-App
//
//  Created by Samir Gupta on 19/4/22.
//

import UIKit

class GameCollection: NSObject, Decodable {
    var games: [GameData]?
    
    private enum CodingKeys: String, CodingKey {
        case games = "data"
    }
}
