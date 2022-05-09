//
//  TeamSeasonData.swift
//  FIT3178-App
//
//  Created by Samir Gupta on 4/5/22.
//

import Foundation

class TeamSeasonData { // used to calculate a teams season data
    let team: TeamData
    var played = 0
    var wins = 0
    var losses = 0
    var homeWins = 0
    var homeLosses = 0
    var awayWins = 0
    var awayLosses = 0
    var seasonScore = 0.0
    var pct = 0.0
    
    init(withTeam: TeamData){
        self.team = withTeam
    }
    
    func addGame(game: GameData?){ // get each game and determine if the game was a win or not and update statistics
        guard let game = game else {
            fatalError("Game passed into TeamSeasonData is invalid")
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
