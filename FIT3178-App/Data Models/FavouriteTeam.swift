//
//  FavouriteTeam.swift
//  All-NBA
//
//  Created by Samir Gupta on 1/6/2022.
//

import Foundation

/// Class representing one of the user's favourite teams.
///
/// This class stores the information the user might want to access when accessing their favourite teams.
class FavouriteTeam {
    /// The ID of the team.
    var id: Int
    /// The team's full name.
    var fullName : String
    /// The most recent game of the team.
    var recentGame: Game?
    
    /// Determine if a part of the section of this team is not yet determined.
    ///
    /// Allows a quick check to make sure no 'nil' data will try to be used or displayed.
    /// - Returns: Boolean determining whether or not this player has been properly initialised.
    func isNil() -> Bool {
        if let _ = recentGame {
            return false
        }
        return true
    }
    
    /// Constructor to initialise the favourite team with a team ID.
    /// - Parameters:
    ///     - id: The ID of the team.
    init(_ id: Int, _ name: String) {
        self.id = id
        self.fullName = name
    }
}
