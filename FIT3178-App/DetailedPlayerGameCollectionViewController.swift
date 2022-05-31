//
//  DetailedPlayerGameCollectionViewController.swift
//  All-NBA
//
//  Created by Samir Gupta on 17/5/2022.
//

import UIKit

private enum PlayerStatSections: String {
    case points = "Points"
    case rebounds = "Rebounds"
    case assists = "Assists"
    case steals = "Steals"
    case blocks = "Blocks"
    case minutes = "Minutes"
    case turnovers = "Turnovers"
    case fouls = "Fouls"
    case twos = "2-Pointers"
    case threes = "3-Pointers"
    case fg = "Field Goals"
    case ft = "Free Throws"
    static var allItems = [points, rebounds, assists, steals, blocks, minutes, turnovers, fouls, twos, threes, fg, ft]
}

class PlayerHeaderCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var firstImage: UIImageView!
    @IBOutlet weak var secondImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
}

class PlayerStatCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var statTitleLabel: UILabel!
    @IBOutlet weak var statDetailLabel: UILabel!
}

class DetailedPlayerGameCollectionViewController: UICollectionViewController {
    
    private let HEADER_SECTION = 0
    private let headerCell = "headerCell"
    private let statCell = "statCell"
    public var player: PlayerGameStatsData?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.setCollectionViewLayout(configureLayout(), animated: false)
        collectionView.backgroundColor = .systemGray3
    }

    // MARK: UICollectionViewDataSource
    
    private func configureLayout() -> UICollectionViewLayout {
        let contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
        
        // headerItem
        let headerItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1/8))
        let headerItem = NSCollectionLayoutItem(layoutSize: headerItemSize)
        headerItem.contentInsets = contentInsets
        
        // stats item (amount of stats in enum)
        let statSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/2), heightDimension: .fractionalHeight(1))
        let statItem = NSCollectionLayoutItem(layoutSize: statSize)
        statItem.contentInsets = contentInsets
        let statsGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let statsGroup = NSCollectionLayoutGroup.horizontal(layoutSize: statsGroupSize, subitem: statItem, count: 2)
        
        let rowGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(7/8))
        let rowGroup = NSCollectionLayoutGroup.vertical(layoutSize: rowGroupSize, subitem: statsGroup, count: 6)

        // vertical group containing the header item and the stats item
        let sectionSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(3/2))
        let sectionLayoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: sectionSize, subitems: [headerItem, rowGroup])
        sectionLayoutGroup.contentInsets = contentInsets
        let section = NSCollectionLayoutSection(group: sectionLayoutGroup)
        section.orthogonalScrollingBehavior = .continuous
        return UICollectionViewCompositionalLayout(section: section)
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PlayerStatSections.allItems.count + 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let player = player else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: statCell, for: indexPath)
        }

        if indexPath.item == HEADER_SECTION {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: headerCell, for: indexPath) as! PlayerHeaderCollectionViewCell
            cell.nameLabel.text = player.playerFirstName + " " + player.playerLastName
            cell.firstImage.image = UIImage(named: player.teamAbbreviation)
            cell.secondImage.image = UIImage(named: player.teamAbbreviation)
            cell.backgroundColor = .systemBackground
            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: statCell, for: indexPath) as! PlayerStatCollectionViewCell
        cell.backgroundColor = .systemBackground
        let header = PlayerStatSections.allItems[indexPath.item-1]
        cell.statTitleLabel.text = header.rawValue
        switch header {
        case .points:
            cell.numberLabel.text = "\(player.pts)"
            cell.statDetailLabel.text = ""
        case .rebounds:
            cell.numberLabel.text = "\(player.reb)"
            cell.statDetailLabel.text = "\(player.oreb)off \(player.dreb)def"
        case .assists:
            cell.numberLabel.text = "\(player.ast)"
            cell.statDetailLabel.text = ""
        case .steals:
            cell.numberLabel.text = "\(player.stl)"
            cell.statDetailLabel.text = ""
        case .blocks:
            cell.numberLabel.text = "\(player.blk)"
            cell.statDetailLabel.text = ""
        case .minutes:
            cell.numberLabel.text = player.min
            cell.statDetailLabel.text = ""
        case .turnovers:
            cell.numberLabel.text = "\(player.turnover)"
            cell.statDetailLabel.text = ""
        case .fouls:
            cell.numberLabel.text = "\(player.pf)"
            cell.statDetailLabel.text = ""
        case .twos:
            cell.numberLabel.text = "\(player.fgm - player.fgm3)/\(player.fga-player.fga3)"
            cell.statDetailLabel.text = get2PointFieldGoalPercentage(fgm: player.fgm, fga: player.fga, fgm3: player.fgm3, fga3: player.fga3)
        case .threes:
            cell.numberLabel.text = "\(player.fgm3)/\(player.fga3)"
            cell.statDetailLabel.text = "\(player.pct3)%"
        case .fg:
            cell.numberLabel.text = "\(player.fgm)/\(player.fga)"
            cell.statDetailLabel.text = "\(player.pct)%"
        case .ft:
            cell.numberLabel.text = "\(player.ftm)/\(player.fta)"
            cell.statDetailLabel.text = "\(player.pct1)%"
        }
    
        return cell
    }
    
    private func get2PointFieldGoalPercentage(fgm: Int, fga: Int, fgm3: Int, fga3: Int) -> String {
        if fga - fga3 == 0 {
            return "0.0%"
        }
        let pct = Float(fgm - fgm3)/Float(fga - fga3)*100
        let rounded_pct = Float(Int(pct * 10)) / Float(10)
        return "\(rounded_pct)%"
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
