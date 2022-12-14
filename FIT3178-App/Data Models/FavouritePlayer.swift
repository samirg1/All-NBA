//
//  FavouritePlayer.swift
//  All-NBA
//
//  Created by Samir Gupta on 1/6/2022.
//

import Foundation

/// Class representing one of the user's favourite players.
///
/// This class houses any information that the user might want to see displayed about one of the favourite players.
class FavouritePlayer {
    /// The ID of the player.
    var id: Int
    /// The player's first name.
    var firstName : String
    /// The player's last name.
    var lastName : String
    /// The season stat averages of the player.
    var seasonStats: PlayerSeasonStats?
    /// The most recent game of the player.
    var recentGame: PlayerGameStats?
    
    /// Determine if any part of the section of this player is not yet determined.
    ///
    /// Allows a quick check to make sure no 'nil' data will try to be used or displayed.
    /// - Returns: Boolean determining whether or not this player has been properly initialised.
    func isNil() -> Bool {
        if let _ = seasonStats, let _ = recentGame {
            return false
        }
        return true
    }
    
    /// Constructor for the favourite player.
    /// - Parameters:
    ///     - id: The ID of the player.
    init(_ id: Int, _ fname: String, _ lname: String){
        self.id = id
        self.firstName = fname
        self.lastName = lname
    }
}
