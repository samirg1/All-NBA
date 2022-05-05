//
//  TeamSeasonData.swift
//  FIT3178-App
//
//  Created by Samir Gupta on 4/5/22.
//

import Foundation

class TeamSeasonData {
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
    
    func addGame(game: GameData?){
        guard let game = game, let homeTeam = game.homeTeam, let awayTeam = game.awayTeam, let homeScore = game.homeScore, let awayScore = game.awayScore else {
            fatalError("Game passed into TeamSeasonData is invalid")
        }
        
        if homeTeam.abbreviation == team.abbreviation {
            if homeScore > awayScore {
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
        else if awayTeam.abbreviation == team.abbreviation {
            if awayScore > homeScore {
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
        pct = round(rawPct * 1000) / 1000.0
    }
}
