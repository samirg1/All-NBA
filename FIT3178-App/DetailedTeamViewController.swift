//
//  DetailedTeamViewController.swift
//  FIT3178-App
//
//  Created by Samir Gupta on 6/5/22.
//

import UIKit

class DetailedTeamViewController: UIViewController {

    var selectedTeam: TeamSeasonData?
    var positions: [String: Int]?
    
    @IBOutlet weak var teamImage: UIImageView!
    @IBOutlet weak var teamName: UILabel!
    @IBOutlet weak var conferenceLabel: UILabel!
    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var leagueLabel: UILabel!
    @IBOutlet weak var divisionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildViewController()
    }
    
    func buildViewController() {
        guard let selectedTeam = selectedTeam, let positions = positions else {
            return
        }
        let confPos = positions[TeamFilter.CONFERENCE.rawValue]!
        let divPos = positions[TeamFilter.DIVISION.rawValue]!
        let leaguePos = positions[TeamFilter.LEAGUE.rawValue]!

        teamImage.image = UIImage(named: selectedTeam.team.abbreviation!)
        teamName.text = selectedTeam.team.fullName
        conferenceLabel.text = "\n\(confPos.ordinal) in \(selectedTeam.team.conference!)ern \(TeamFilter.CONFERENCE.rawValue)"
        divisionLabel.text =  "\(divPos.ordinal) in \(selectedTeam.team.division!) \(TeamFilter.DIVISION.rawValue)"
        leagueLabel.text = "\(leaguePos.ordinal) in \(TeamFilter.LEAGUE.rawValue)"
        recordLabel.text = "Record\n\(selectedTeam.wins)-\(selectedTeam.losses)\nAt Home\n\(selectedTeam.homeWins)-\(selectedTeam.homeLosses)\nAway\n\(selectedTeam.awayWins)-\(selectedTeam.awayLosses)"
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

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
