//
//  PlayersGameStatsCollectionViewController.swift
//  FIT3178-App
//
//  Created by Samir Gupta on 28/4/22.
//
//  This view shows a detailed summary of each player and their major statistical categories from a particular game

import UIKit

private enum SortFilters: String {
    case none = "none"
    case points = "pts"
    case rebounds = "reb"
    case assists = "ast"
    case steals = "stl"
    case blocks = "blk"
    case turnovers = "tov"
    case percentage = "pct"
}

class PlayerGameStatsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
}

class PlayerGameNameCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
}

class PlayersGameStatsCollectionViewController: UICollectionViewController {
    
    private let cellHeaders = ["NAME", "PTS", "REB", "AST", "STL", "BLK", "TOV", "PCT"]
    private let statIdentifier = "statCell"
    private let nameIdentifier = "nameCell"
    public var playerGameStats: [PlayerGameStatsData] = [PlayerGameStatsData]()
    private var sortingKey : SortFilters = SortFilters.none
    private let HEADER_SECTION = 0
    private let NAME_ITEM = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sortPlayerGameStats(clicked: SortFilters.points)
        collectionView.setCollectionViewLayout(configureLayout(), animated: false)
        collectionView.backgroundColor = .systemGray3
        navigationController?.navigationBar.backgroundColor = .systemBackground
    }
    
    private func configureLayout() -> UICollectionViewLayout {
        let nameItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(3/9), heightDimension: .fractionalHeight(1))
        let nameItem = NSCollectionLayoutItem(layoutSize: nameItemSize)
        nameItem.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
        
        let statsSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/7), heightDimension: .fractionalHeight(1))
        let statsLayout = NSCollectionLayoutItem(layoutSize: statsSize)
        statsLayout.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
        let statsGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(6/9), heightDimension: .fractionalHeight(1))
        let statGroup = NSCollectionLayoutGroup.horizontal(layoutSize: statsGroupSize, subitem: statsLayout, count: 7)

        let sectionSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(4/3), heightDimension: .fractionalWidth(1/8))
        let sectionLayoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: sectionSize, subitems: [nameItem, statGroup])
        let sectionLayout = NSCollectionLayoutSection(group: sectionLayoutGroup)
        sectionLayout.orthogonalScrollingBehavior = .continuous
        return UICollectionViewCompositionalLayout(section: sectionLayout)
    }
    
    private func sortPlayerGameStats(clicked: SortFilters) {
        if sortingKey == clicked {
            playerGameStats.reverse()
        }
        else {
            switch clicked {
            case .points, .none:
                playerGameStats.sort(){ $0.pts > $1.pts }
            case .rebounds:
                playerGameStats.sort(){ $0.reb > $1.reb }
            case .assists:
                playerGameStats.sort(){ $0.ast > $1.ast }
            case .steals:
                playerGameStats.sort(){ $0.stl > $1.stl }
            case .blocks:
                playerGameStats.sort(){ $0.blk > $1.blk }
            case .turnovers:
                playerGameStats.sort(){ $0.turnover > $1.turnover }
            case .percentage:
                playerGameStats.sort(){ $0.pct > $1.pct }
            }
            sortingKey = clicked
        }
        collectionView.reloadData()
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return playerGameStats.count + 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellHeaders.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: statIdentifier, for: indexPath) as! PlayerGameStatsCollectionViewCell
        cell.label.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 5).isActive = false
        if indexPath.section == HEADER_SECTION {
            cell.backgroundColor = .systemGray4
            
            if let sort = SortFilters(rawValue: cellHeaders[indexPath.item].lowercased()), sort == sortingKey {
                cell.label.attributedText =  NSAttributedString(string: cellHeaders[indexPath.item], attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue, .font: UIFont.boldSystemFont(ofSize: cell.label.font.pointSize)])
            }
            else {
                cell.label.attributedText =  NSAttributedString(string: cellHeaders[indexPath.item], attributes: [.font: UIFont.systemFont(ofSize: cell.label.font.pointSize)])
            }
                
        }
        else {
            cell.backgroundColor = .systemBackground
            
            let player = playerGameStats[indexPath.section-1]
            var text = ""
            switch indexPath.item {
            case NAME_ITEM:
                let nameCell = collectionView.dequeueReusableCell(withReuseIdentifier: nameIdentifier, for: indexPath) as! PlayerGameNameCollectionViewCell
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
        if indexPath.section == HEADER_SECTION {
            let selectedSort = SortFilters(rawValue: cellHeaders[indexPath.item].lowercased())
            if let selectedSort = selectedSort {
                sortPlayerGameStats(clicked: selectedSort)
            }
        }
        else {
            let player = playerGameStats[indexPath.section-1]
            print(player.playerFirstName + " " + player.playerLastName)
        }
    }

    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return indexPath.section != HEADER_SECTION || indexPath.item != NAME_ITEM
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
}
