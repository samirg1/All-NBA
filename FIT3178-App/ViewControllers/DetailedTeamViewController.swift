//
//  DetailedTeamViewController.swift
//  FIT3178-App
//
//  Created by Samir Gupta on 6/5/22.
//
//  This page shows a detailed view of a selected team from StandingsTableViewController

import UIKit

class DetailedTeamViewController: UIViewController {

    public var selectedTeam: TeamSeasonData?
    public var positions: [TeamFilter: Int]?
    
    @IBOutlet weak private var teamImage: UIImageView!
    @IBOutlet weak private var teamName: UILabel!
    @IBOutlet weak private var conferenceLabel: UILabel!
    @IBOutlet weak private var recordLabel: UILabel!
    @IBOutlet weak private var leagueLabel: UILabel!
    @IBOutlet weak private var divisionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildViewController()
    }
    
    private func buildViewController() {
        guard let selectedTeam = selectedTeam, let positions = positions else {
            return
        }
        let confPos = positions[TeamFilter.CONFERENCE]!
        let divPos = positions[TeamFilter.DIVISION]!
        let leaguePos = positions[TeamFilter.LEAGUE]!

        teamImage.image = UIImage(named: selectedTeam.team.abbreviation!)
        teamName.text = selectedTeam.team.fullName
        conferenceLabel.text = "\n\(confPos.ordinal) in \(selectedTeam.team.conference!)ern \(TeamFilter.CONFERENCE.rawValue)"
        divisionLabel.text =  "\(divPos.ordinal) in \(selectedTeam.team.division!) \(TeamFilter.DIVISION.rawValue)"
        leagueLabel.text = "\(leaguePos.ordinal) in \(TeamFilter.LEAGUE.rawValue)"
        recordLabel.text = "Record\n\(selectedTeam.wins)-\(selectedTeam.losses)\nAt Home\n\(selectedTeam.homeWins)-\(selectedTeam.homeLosses)\nAway\n\(selectedTeam.awayWins)-\(selectedTeam.awayLosses)"
    }
}

extension Int { // get ordinal values from integers (1st, 2nd, 3rd .. etc) src: https://stackoverflow.com/questions/3312935/nsnumberformatter-and-th-st-nd-rd-ordinal-number-endings
    var ordinal: String {
        var suffix = ""
        let ones: Int = self % 10
        let tens: Int = (self/10) % 10
        if tens == 1 {
            suffix += "th"
        }
        else if ones == 1 {
            suffix += "st"
        }
        else if ones == 2 {
            suffix += "nd"
        }
        else if ones == 3 {
            suffix += "rd"
        }
        else {
            suffix += "th"
        }
        return "\(self)\(suffix)"
    }
}
