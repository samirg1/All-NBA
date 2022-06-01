//
//  TeamSeasonData.swift
//  FIT3178-App
//
//  Created by Samir Gupta on 4/5/22.
//

import Foundation

/// Class used to represent a team's season stats.
///
/// This class works by first getting initialised with a ``Team``, then each ``Game`` that the ``Team`` has played in gets added
/// and the result is determined and used to update the season stats.
class TeamSeasonStats {
    /// The team which stats this class holds.
    let team: Team
    /// The amount of games the team has played.
    var played = 0
    /// The amount of games the team has won.
    var wins = 0
    /// The amount of games the team has lost.
    var losses = 0
    /// The amount of games the team has won at home.
    var homeWins = 0
    /// The amount of games the team has lost at home.
    var homeLosses = 0
    /// The amount of games the team has won away from home.
    var awayWins = 0
    /// The amount of games the team has lost away from home.
    var awayLosses = 0
    /// The total season score of the team.
    ///
    /// Season score = wins * 0.5 - losses*0.5.
    var seasonScore = 0.0
    /// The percentage of games this team has won.
    var pct = 0.0
    
    /// Constructor to intialise the team's season stats with a team.
    /// - Parameters:
    ///     - withTeam: The team to collect stats for.
    init(withTeam: Team){
        self.team = withTeam
    }
    
    /// Add a particular game to this teams season stats.
    /// - Parameters:
    ///     - game: The game to add.
    func addGame(game: Game?){
        guard let game = game else {
            fatalError("Game is invalid")
        }
        
        if game.homeTeam.abbreviation == team.abbreviation {
            if game.homeScore > game.awayScore {
                wins += 1
                homeWins += 1
                seasonScore += 0.5
            }
            else {
                losses += 1
                homeLosses += 1
                seasonScore -= 0.5
            }
        }
        else if game.awayTeam.abbreviation == team.abbreviation {
            if game.awayScore > game.homeScore {
                wins += 1
                awayWins += 1
                seasonScore += 0.5
            }
            else {
                losses += 1
                awayLosses += 1
                seasonScore -= 0.5
            }
        }
        else {
            fatalError("Team was not found")
        }
        
        played += 1
        let rawPct = Double(wins)/Double(played)
        pct = round(rawPct * 1000) / 1000.0 // round to 3 d.p.
    }
}
