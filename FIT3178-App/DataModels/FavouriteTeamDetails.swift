//
//  FavouriteTeamDetails.swift
//  All-NBA
//
//  Created by Samir Gupta on 1/6/2022.
//

import Foundation

class FavouriteTeamDetails {
    var id: Int
    var recentGame: GameData?
    
    init(_ id: Int) {
        self.id = id
    }
}
