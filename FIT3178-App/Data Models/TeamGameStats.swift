//
//  TeamGameStats.swift
//  FIT3178-App
//
//  Created by Samir Gupta on 9/5/22.
//

import Foundation

/// Class used to represent a team's game stats.
///
/// This class works by having every stat be initialised to zero, then each ``Player`` that played in the particular ``Game`` for this ``Team``
/// is added one by one, and the stats of the ``Player`` is added to the total ``Team`` stats.
class TeamGameStats {
    /// The amount of points the team has in the game.
    var pts = 0
    /// The amount of rebounds the team has in the game.
    var reb = 0
    /// The amount of defensive rebounds the team has in the game.
    var dreb = 0
    /// The amount of offensive rebounds the team has in the game.
    var oreb = 0
    /// The amount of assists the team has in the game.
    var ast = 0
    /// The amount of blocks the team has in the game.
    var blk = 0
    /// The amount of steals the team has in the game.
    var stl = 0
    /// The amount of turnovers the team has in the game.
    var turnover = 0
    /// The amount of 3-pointers the team has made in the game.
    var fgm3 = 0
    /// The amount of 3-pointers the team has attempted in the game.
    var fga3 = 0
    /// The amount of field goals the team has made in the game.
    var fgm = 0
    /// The amount of field goals the team has attempted in the game.
    var fga = 0
    /// The amount of free throws the team has made in the game.
    var ftm = 0
    /// The amount of free throws the team has attempted in the game.
    var fta = 0
    /// The amount of fould the team has in the game.
    var fls = 0
    
    /// Add a player's statistics in the game to the overall team's statistics.
    /// - Parameters:
    ///     - player: The player to add.
    func addPlayerGameStats(player: PlayerGameStats) {
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
