//
//  TeamGameData.swift
//  FIT3178-App
//
//  Created by Samir Gupta on 9/5/22.
//

import Foundation

class TeamGameData {
    var pts = 0
    var reb = 0
    var dreb = 0
    var oreb = 0
    var ast = 0
    var blk = 0
    var stl = 0
    var turnover = 0
    var fgm3 = 0
    var fga3 = 0
    var fgm = 0
    var fga = 0
    var ftm = 0
    var fta = 0
    var fls = 0
    
    func addPlayerGameStats(player: PlayerGameStatsData) {
        pts += player.pts
        reb += player.reb
        dreb += player.dreb
        oreb += player.oreb
        ast += player.ast
        blk += player.blk
        stl += player.stl
        turnover += player.turnover
        fgm3 += player.fgm3
        fga3 += player.fga3
        fgm += player.fgm
        fga += player.fga
        ftm += player.ftm
        fta += player.fta
        fls += player.pf
    }
}
