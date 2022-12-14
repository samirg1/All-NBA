//
//  PlayersGameStatsCollectionViewController.swift
//  FIT3178-App
//
//  Created by Samir Gupta on 28/4/22.
//

import UIKit

/// The different sorting filters to be applied to the players.
fileprivate enum SortFilters: String {
    /// No sorting mechanism (initial value).
    case none = "none"
    /// Sorting by points scored.
    case points = "pts"
    /// Sorting by rebounds acquired.
    case rebounds = "reb"
    /// Sorting by assists acquired.
    case assists = "ast"
    /// Sorting by amount of steals.
    case steals = "stl"
    /// Sorting by amount of blocks.
    case blocks = "blk"
    /// Sorting by amount of turnovers.
    case turnovers = "tov"
    /// Sorting by field goal percentage.
    case percentage = "pct"
}

/// Custom cell to display a statstic or header for the major statistics.
class PlayerGameStatsCollectionViewCell: UICollectionViewCell {
    /// The label housing a statistic or header.
    @IBOutlet weak fileprivate var label: UILabel!
}

/// Custom cell to display the names of the players and the header for this column.
class PlayerGameNameCollectionViewCell: UICollectionViewCell {
    /// The label housing the name or header for names.
    @IBOutlet weak fileprivate var nameLabel: UILabel!
}

/// Custom collection view to display a simplistic overview of the players statistics from a particular game.
class PlayersGameStatsCollectionViewController: UICollectionViewController {
    /// The column headers of the view.
    private let CELL_HEADERS = [NSLocalizedString("NAME", comment: "name"), "PTS", "REB", "AST", "STL", "BLK", "TOV", "PCT"]
    /// The cell identifier of the cell that houses a stat.
    private let STAT_CELL_IDENTIFIER = "statCell"
    /// The cell identifier of the cell that houses a name.
    private let NAME_CELL_IDENTIFIER = "nameCell"
    /// The section housing the headers.
    private let HEADER_SECTION = 0
    /// The items that house the names.
    private let NAME_ITEM = 0
    
    /// The collection of player's game stats.
    public var playerGameStats: [PlayerGameStats] = []
    /// The sorted collection of the player's game stats.
    private var sortedGameStats: [PlayerGameStats] = []
    /// The selected player (if any).
    private var selectedPlayer: PlayerGameStats?
    /// The current sorting key.
    private var sortingKey : SortFilters = SortFilters.none
    /// The segue identifier to segue to ``DetailedPlayerGameCollectionViewController``.
    private let DETAILED_SEGUE = "playerGameDetail"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sortPlayerGameStats(clicked: SortFilters.points) // initially sort by points
        collectionView.setCollectionViewLayout(configureLayout(), animated: false) // configure the layout
        collectionView.backgroundColor = .systemGray3 // default background colours
        navigationController?.navigationBar.backgroundColor = .systemBackground
    }
    
    /// Configure the layout of this collection view.
    private func configureLayout() -> UICollectionViewLayout {
        let contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
        
        // name item
        let nameItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(3/9), heightDimension: .fractionalHeight(1))
        let nameItem = NSCollectionLayoutItem(layoutSize: nameItemSize)
        nameItem.contentInsets = contentInsets
        
        // stats item (7 of them)
        let statsSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/7), heightDimension: .fractionalHeight(1))
        let statsLayout = NSCollectionLayoutItem(layoutSize: statsSize)
        statsLayout.contentInsets = contentInsets
        let statsGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(6/9), heightDimension: .fractionalHeight(1))
        let statGroup = NSCollectionLayoutGroup.horizontal(layoutSize: statsGroupSize, subitem: statsLayout, count: 7)

        // horizontal group containing the name item and the 7 stats items
        let sectionSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let sectionLayoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: sectionSize, subitems: [nameItem, statGroup])
        statsLayout.contentInsets = contentInsets
        
        // vertical group containing a horizontal group for each player (+1 for the cell headers)
        let entireSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(4/3), heightDimension: .fractionalHeight(3/2))
        let entireGroup = NSCollectionLayoutGroup.vertical(layoutSize: entireSize, subitem: sectionLayoutGroup, count: playerGameStats.count+1)
        entireGroup.contentInsets = contentInsets
        
        let entire = NSCollectionLayoutSection(group: entireGroup)
        entire.orthogonalScrollingBehavior = .continuous
        return UICollectionViewCompositionalLayout(section: entire)
    }
    
    /// Sort the players.
    /// - Parameters:
    ///     - clicked: The sort filter that was clicked.
    private func sortPlayerGameStats(clicked: SortFilters) {
        if sortingKey == clicked { // if user reclicks a sorter, reverse the order
            sortedGameStats.reverse()
        }
        else { // otherwise sort the data container
            switch clicked {
            case .points, .none:
                sortedGameStats = playerGameStats.sorted(){ $0.pts > $1.pts }
            case .rebounds:
                sortedGameStats = playerGameStats.sorted(){ $0.reb > $1.reb }
            case .assists:
                sortedGameStats = playerGameStats.sorted(){ $0.ast > $1.ast }
            case .steals:
                sortedGameStats = playerGameStats.sorted(){ $0.stl > $1.stl }
            case .blocks:
                sortedGameStats = playerGameStats.sorted(){ $0.blk > $1.blk }
            case .turnovers:
                sortedGameStats = playerGameStats.sorted(){ $0.turnover > $1.turnover }
            case .percentage:
                sortedGameStats = playerGameStats.sorted(){ $0.pct > $1.pct }
            }
            sortingKey = clicked
        }
        collectionView.reloadData()
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CELL_HEADERS.count * (playerGameStats.count + 1)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: STAT_CELL_IDENTIFIER, for: indexPath) as! PlayerGameStatsCollectionViewCell
        cell.label.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 5).isActive = false
        if indexPath.item / CELL_HEADERS.count == HEADER_SECTION {
            cell.backgroundColor = .systemGray4 // cell headers have different background colour
            
            if let sort = SortFilters(rawValue: CELL_HEADERS[indexPath.item].lowercased()), sort == sortingKey {
                cell.label.attributedText =  NSAttributedString(string: CELL_HEADERS[indexPath.item], attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue, .font: UIFont.boldSystemFont(ofSize: cell.label.font.pointSize)])
            } // underline cell header if it is currently the sorting filter
            else {
                cell.label.attributedText =  NSAttributedString(string: CELL_HEADERS[indexPath.item], attributes: [.font: UIFont.systemFont(ofSize: cell.label.font.pointSize)])
            }
                
        }
        else {
            cell.backgroundColor = .systemBackground
            
            let player = sortedGameStats[(indexPath.item / CELL_HEADERS.count) - 1]
            var text = ""
            switch indexPath.item % CELL_HEADERS.count {
            case NAME_ITEM:
                let nameCell = collectionView.dequeueReusableCell(withReuseIdentifier: NAME_CELL_IDENTIFIER, for: indexPath) as! PlayerGameNameCollectionViewCell
                nameCell.backgroundColor = .systemBackground
                let fname = player.playerFirstName
                let stringFname = "\(fname[fname.startIndex])"
                nameCell.nameLabel.attributedText = NSAttributedString(string: stringFname + ". " + player.playerLastName, attributes: [.font: UIFont.systemFont(ofSize: nameCell.nameLabel.font.pointSize)])
                return nameCell
            case 1:
                text = "\(player.pts)"
            case 2:
                text = "\(player.reb)"
            case 3:
                text = "\(player.ast)"
            case 4:
                text = "\(player.stl)"
            case 5:
                text = "\(player.blk)"
            case 6:
                text = "\(player.turnover)"
            case 7:
                text = "\(player.pct)"
            default:
                text = ""
            }
            cell.label.attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: cell.label.font.pointSize)])
        }
    
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item / CELL_HEADERS.count == HEADER_SECTION {
            let selectedSort = SortFilters(rawValue: CELL_HEADERS[indexPath.item % CELL_HEADERS.count].lowercased())
            if let selectedSort = selectedSort {
                sortPlayerGameStats(clicked: selectedSort) // sort when user clicks on header section
            }
        }
        else { // otherwise take user to a detailed player summary
            let player = sortedGameStats[(indexPath.item / CELL_HEADERS.count) - 1]
            print(player.playerFirstName + " " + player.playerLastName)
            selectedPlayer = player
            performSegue(withIdentifier: DETAILED_SEGUE, sender: self)
        }
    }

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return indexPath.item != NAME_ITEM
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == DETAILED_SEGUE {
            let destination = segue.destination as! DetailedPlayerGameCollectionViewController
            destination.player = selectedPlayer
        }
    }
}
