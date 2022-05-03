//
//  TeamsGameData.swift
//  FIT3178-App
//
//  Created by Samir Gupta on 27/4/22.
//

import Foundation

class TeamsGameData {
    var teamsGameData: Dictionary<String, Dictionary<String, Int>>
    
    init(teamPlayers: [PlayerGameStatsData], awayTeamId: Int){
        var awayTeamDict = [
            "pts": 0, "reb": 0, "dreb": 0, "oreb": 0, "ast": 0, "blk": 0, "stl": 0,
            "turnover": 0, "fgm3": 0, "fga3": 0, "fgm": 0, "fga": 0,
            "ftm": 0, "fta": 0, "fls": 0,
        ] as [String : Int]
        var homeTeamDict = [
            "pts": 0, "reb": 0, "dreb": 0, "oreb": 0, "ast": 0, "blk": 0, "stl": 0,
            "turnover": 0, "fgm3": 0, "fga3": 0, "fgm": 0, "fga": 0,
            "ftm": 0, "fta": 0, "fls": 0,
        ] as [String : Int]
        
        for player in teamPlayers {
            var playerTeam = player.teamId == awayTeamId ? awayTeamDict : homeTeamDict
            playerTeam["pts"]! += player.pts
            playerTeam["reb"]! += player.reb
            playerTeam["dreb"]! += player.dreb
            playerTeam["oreb"]! += player.oreb
            playerTeam["ast"]! += player.ast
            playerTeam["blk"]! += player.blk
            playerTeam["stl"]! += player.stl
            playerTeam["turnover"]! += player.turnover
            playerTeam["fgm3"]! += player.fgm3
            playerTeam["fga3"]! += player.fga3
            playerTeam["fgm"]! += player.fgm
            playerTeam["fga"]! += player.fga
            playerTeam["ftm"]! += player.ftm
            playerTeam["fta"]! += player.fta
            playerTeam["fls"]! += player.pf
            
            if player.teamId == awayTeamId {
                awayTeamDict = playerTeam
            }
            else {
                homeTeamDict = playerTeam
            }
        }
        teamsGameData = ["awayTeam": awayTeamDict, "homeTeam": homeTeamDict]
    }
}
/*
 var pts: Int
 var reb: Int
 var ast: Int
 var blk: Int
 var stl: Int
 var turnover: Int
 
 var dreb: Int
 var oreb: Int
 
 var pct3: Float
 var fgm3: Int
 var fga3: Int
 var pct: Float
 var fgm: Int
 var fga: Int
 var pct1: Float
 var fta: Int
 var ftm: Int
 
 var min: String
 var pf: Int
 */
