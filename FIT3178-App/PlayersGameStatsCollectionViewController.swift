//
//  PlayersGameStatsCollectionViewController.swift
//  FIT3178-App
//
//  Created by Samir Gupta on 28/4/22.
//
//  This view shows a detailed summary of each player and their major statistical categories from a particular game

import UIKit

private let cellHeaders = ["NAME", "PTS", "REB", "AST", "STL", "BLK", "TOV", "FG%"]
private let reuseIdentifier = "statCell"

class PlayerGameStatsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var label: UILabel!
}

class PlayersGameStatsCollectionViewController: UICollectionViewController {
    
    var playerGameStats: [PlayerGameStatsData]?
    var sortingKey = "pts"
    
    private lazy var compositionalLayout: UICollectionViewCompositionalLayout = { () -> UICollectionViewCompositionalLayout in
        let layout = UICollectionViewCompositionalLayout { [weak self] (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection in
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 4.0,
                                                             leading: 0.0,
                                                             bottom: 4.0,
                                                             trailing: 0.0)
            let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .estimated(136), heightDimension: .absolute(44)), subitem: item, count: self?.playerGameStats?.count ?? 1)
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuous
            section.contentInsets = NSDirectionalEdgeInsets(top: 16.0,
                                                                leading: 0.0,
                                                                bottom: 16.0,
                                                                trailing: 0.0)
            return section
        }
        return layout
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.collectionViewLayout = compositionalLayout
    }
    
    func sortPlayerGameStats() {
        
    }
    
    @IBAction func backToGameSwipeAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let playerGameStats = playerGameStats {
            return (playerGameStats.count + 1) * cellHeaders.count
        }
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PlayerGameStatsCollectionViewCell
        cell.backgroundColor = .systemBlue
        cell.label.text = "\(indexPath.item)"
        // Configure the cell
    
        return cell
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
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
}
