//
//  FavouritePlayerDetails.swift
//  All-NBA
//
//  Created by Samir Gupta on 1/6/2022.
//

import Foundation

class FavouritePlayerDetails {
    var id: Int
    var seasonStats: PlayerSeasonStats? = nil
    var recentGame: PlayerGameStatsData? = nil
    
    func isNil() -> Bool {
        if let _ = seasonStats, let _ = recentGame {
            return false
        }
        return true
    }
    
    init(_ id: Int){
        self.id = id
    }
}
