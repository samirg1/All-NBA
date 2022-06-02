//
//  DetailedPlayerGameCollectionViewController.swift
//  All-NBA
//
//  Created by Samir Gupta on 17/5/2022.
//

import UIKit

/// The stat sections to display in this view.
private enum PlayerStatSections: String {
    /// The points scored.
    case points = "Points"
    /// The amounts of rebounds secured.
    case rebounds = "Rebounds"
    /// The amount of assists acquired.
    case assists = "Assists"
    /// The amount of steals.
    case steals = "Steals"
    /// The amount of blocks.
    case blocks = "Blocks"
    /// The amount of minutes.
    case minutes = "Minutes"
    /// The amount turnovers.
    case turnovers = "Turnovers"
    /// The amount of fouls.
    case fouls = "Fouls"
    /// The amount of two pointers shot.
    case twos = "2-Pointers"
    /// The amount of three pointers shot.
    case threes = "3-Pointers"
    /// The amount of field goals shot.
    case fg = "Field Goals"
    /// The amount of free throws shot.
    case ft = "Free Throws"
    /// Collection of all of the statistical categories to display.
    static var allItems = [points, rebounds, assists, steals, blocks, minutes, turnovers, fouls, twos, threes, fg, ft]
    
    /// Function to return a localised string of the enum raw value.
    /// - Returns: The localised string.
    ///
    /// Source found [here.](https://stackoverflow.com/questions/28213693/enum-with-localized-string-in-swift)
    fileprivate func localizedString() -> String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}

/// Custom class to provide a header for this page.
class PlayerHeaderCollectionViewCell: UICollectionViewCell {
    /// The first image of the player's team's logo.
    @IBOutlet weak var firstImage: UIImageView!
    /// The second image of the player's team's logo.
    @IBOutlet weak var secondImage: UIImageView!
    /// The name label of the player.
    @IBOutlet weak var nameLabel: UILabel!
}

/// Custom class representing a cell for each major statistical category.
class PlayerStatCollectionViewCell: UICollectionViewCell {
    /// The label for the numerical value of the stat.
    @IBOutlet weak var numberLabel: UILabel!
    /// The title of this stat.
    @IBOutlet weak var statTitleLabel: UILabel!
    /// Label for any extra detail of this stat.
    @IBOutlet weak var statDetailLabel: UILabel!
}

/// Class to display a detailed look at a single player's performance in a game.
class DetailedPlayerGameCollectionViewController: UICollectionViewController {
    /// The section housing the header of this view.
    private let HEADER_SECTION = 0
    /// The cell identifier of the header cell.
    private let headerCell = "headerCell"
    /// The cell identifier of the stat cell.
    private let statCell = "statCell"
    /// The player to display the performance of.
    public var player: PlayerGameStats?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.setCollectionViewLayout(configureLayout(), animated: false)
        collectionView.backgroundColor = .systemGray3
    }
    
    /// Given the total made and attempted shots and the total 3 point made and attempted shots, calculate the 2 point field goal percentage.
    /// - Parameters:
    ///     - fgm: The amount of field goals made.
    ///     - fga: The amount of field goals attempted.
    ///     - fgm3: The amount of 3-point field goals made.
    ///     - fga3: The amount of 3-point field goals attempted.
    /// - Returns: A stringed version of the 2-point percentage.
    private func get2PointFieldGoalPercentage(fgm: Int, fga: Int, fgm3: Int, fga3: Int) -> String {
        if fga - fga3 == 0 {
            return "0.0%"
        }
        let pct = Float(fgm - fgm3)/Float(fga - fga3)*100
        let rounded_pct = Float(Int(pct * 10)) / Float(10)
        return "\(rounded_pct)%"
    }

    // MARK: UICollectionViewDataSource
    
    /// Configure the layout of the collection view.
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
        cell.statTitleLabel.text = header.localizedString()
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
}
