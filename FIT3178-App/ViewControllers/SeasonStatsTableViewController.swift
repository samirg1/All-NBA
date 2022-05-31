//
//  SeasonStatsTableViewController.swift
//  FIT3178-App
//
//  Created by Samir Gupta on 16/5/2022.
//

private enum SegmentedItems: String {
    case points = "Points"
    case rebounds = "Rebounds"
    case assists = "Assists"
    case steals = "Steals"
    case blocks = "Blocks"
    case minutes = "Minutes"
    case turnovers = "Turnovers"
    case fouls = "Fouls"
    case three_pm = "3PM"
    case three_pct = "3P%"
    case fg_pct = "FG%"
    case ft_pct = "FT%"
    static var allItems = [points, rebounds, assists, steals, blocks, minutes, turnovers, fouls, three_pm, three_pct, fg_pct, ft_pct]
}

import UIKit

class ScrollableSegmentedControl: UISegmentedControl { // makes the segmented control able to be scrolled, src: https://developer.apple.com/forums/thread/123759
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

class SeasonStatsTableViewController: UITableViewController {
    
    
    @IBOutlet weak private var segmentCon: UISegmentedControl!
    @IBOutlet weak private var sectionScrollView: UIScrollView!

    private let segmentedControlFont = 20.0
    private let playerCell = "playerCell"
    private let currenSeason = "2021"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var scrollViewWidth:Float = 0.0 // set scroll view width to match size of segmented control, src: https://stackoverflow.com/questions/46519573/scroll-dynamic-uisegmentedcontrol-in-swift-3
        for (i, val) in SegmentedItems.allItems.enumerated() {
            let size = val.rawValue.size(withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: segmentedControlFont)])
            segmentCon.setWidth(size.width, forSegmentAt: i)
            scrollViewWidth = scrollViewWidth + Float(size.width)
        }
        sectionScrollView.contentSize = CGSize(width: CGFloat(scrollViewWidth) + segmentedControlFont, height: sectionScrollView.contentSize.height)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: playerCell, for: indexPath)

        // Configure the cell...

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
