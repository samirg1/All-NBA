//
//  TeamAbbreviations.swift
//  All-NBA
//
//  Created by Samir Gupta on 1/6/2022.
//

/// A dictionary mapping the integer values of a team's ID to their respective official abbreviations.
///
/// This is used due to the fact that when game summary needs to be shown after retrieving a player's stats from the game, the API doesn't pass in the team abbreviations.
/// The API only passes in the IDs of the teams, therefore to display the team abbreviations this dictionary would need to be used.
public let teamIdToAbbreviations: [Int:String] = [
    01: "ATL", 02: "BOS", 03: "BKN", 04: "CHA", 05: "CHI",
    06: "CLE", 07: "DAL", 08: "DEN", 09: "DET", 10: "GSW",
    11: "HOU", 12: "IND", 13: "LAC", 14: "LAL", 15: "MEM",
    16: "MIA", 17: "MIL", 18: "MIN", 19: "NOP", 20: "NYK",
    21: "OKC", 22: "ORL", 23: "PHI", 24: "PHX", 25: "POR",
    26: "SAC", 27: "SAS", 28: "TOR", 29: "UTA", 30: "WAS"
]
