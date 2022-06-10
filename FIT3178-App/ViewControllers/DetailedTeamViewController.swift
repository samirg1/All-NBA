//
//  DetailedTeamViewController.swift
//  FIT3178-App
//
//  Created by Samir Gupta on 6/5/22.
//
//  This page shows a detailed view of a selected team from StandingsTableViewController

import UIKit

/// Custom view controller to display a more detailed and easier to read view of a particular team.
class DetailedTeamViewController: UIViewController {

    /// The selected team to display.
    public var selectedTeam: TeamSeasonStats?
    /// The position of the team in the subsections of the league.
    public var positions: [TeamFilter: Int]?
    
    /// The image of the team's logo.
    @IBOutlet weak private var teamImage: UIImageView!
    /// The label for the team's name.
    @IBOutlet weak private var teamName: UILabel!
    /// The label for the team's conference position.
    @IBOutlet weak private var conferenceLabel: UILabel!
    /// The label for the team's record.
    @IBOutlet weak private var recordLabel: UILabel!
    /// The label for the team's league position.
    @IBOutlet weak private var leagueLabel: UILabel!
    /// The label for the team's division position.
    @IBOutlet weak private var divisionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildViewController()
    }
    
    /// Build the view controller when this view loads.
    private func buildViewController() {
        guard let selectedTeam = selectedTeam, let positions = positions else {
            return
        }
        let confPos = positions[TeamFilter.CONFERENCE]!
        let divPos = positions[TeamFilter.DIVISION]!
        let leaguePos = positions[TeamFilter.LEAGUE]!

        teamImage.image = UIImage(named: selectedTeam.team.abbreviation)
        teamName.text = selectedTeam.team.fullName
        conferenceLabel.text = "\n\(confPos.ordinal) \(NSLocalizedString("in", comment: "")) \(NSLocalizedString(selectedTeam.team.conference + "ern", comment: "")) \(TeamFilter.CONFERENCE.localizedString())"
        divisionLabel.text =  "\(divPos.ordinal) \(NSLocalizedString("in", comment: "")) \(NSLocalizedString(selectedTeam.team.division, comment: "")) \(TeamFilter.DIVISION.localizedString())"
        leagueLabel.text = "\(leaguePos.ordinal) \(NSLocalizedString("in", comment: "")) \(TeamFilter.LEAGUE.localizedString())"
        recordLabel.text = NSLocalizedString("Record", comment: "record") + "\n\(selectedTeam.wins)-\(selectedTeam.losses)\n"+NSLocalizedString("At Home", comment: "at_home")+"\n\(selectedTeam.homeWins)-\(selectedTeam.homeLosses)\n"+NSLocalizedString("Away", comment: "away")+"\n\(selectedTeam.awayWins)-\(selectedTeam.awayLosses)"
    }
}

fileprivate extension Int {
    /// Get ordinal values from integers (1st, 2nd, 3rd .. etc).   [Source found here.]( https://stackoverflow.com/questions/3312935/nsnumberformatter-and-th-st-nd-rd-ordinal-number-endings)
    var ordinal: String {
        var suffix = ""
        let ones: Int = self % 10
        let tens: Int = (self/10) % 10
        if tens == 1 { suffix += "th" }
        else if ones == 1 { suffix += "st" }
        else if ones == 2 { suffix += "nd" }
        else if ones == 3 { suffix += "rd" }
        else { suffix += "th" }
        return "\(self)\(suffix)"
    }
}
