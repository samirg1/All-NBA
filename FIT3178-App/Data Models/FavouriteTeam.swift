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
    /// The most recent game of the team.
    var recentGame: Game?
    
    /// Constructor to initialise the favourite team with a team ID.
    /// - Parameters:
    ///     - id: The ID of the team.
    init(_ id: Int) {
        self.id = id
    }
}
