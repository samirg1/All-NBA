//
//  AddFavouritesTableViewController.swift
//  All-NBA
//
//  Created by Samir Gupta on 28/5/2022.
//

import UIKit

class AddFavouritesTableViewController: UITableViewController, UISearchBarDelegate {


    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let playerSegment = 0
    private let teamSegment = 1
    private let cellIdentifier = "resultCell"
    private let DEFAULT_ADD_BUTTON_TITLE = "Add"
    
    private var players: [PlayerData] = []
    private var teams: [TeamData] = []
    private let season = Season2021_2022.self
    
    @IBOutlet weak private var favouriteType: UISegmentedControl!
    @IBOutlet weak private var saveButtonOutlet: UIBarButtonItem!
    
    private lazy var indicator: UIActivityIndicatorView = {
        var indicator = UIActivityIndicatorView()
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([ indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor), indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor) ])
        return indicator
    }()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.showsCancelButton = false
        return searchController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButtonOutlet.isEnabled = false
        self.tableView.allowsMultipleSelection = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func isPlayerSelected() -> Bool {
        return favouriteType.selectedSegmentIndex == playerSegment
    }
    
    
    @IBAction func changeFavouriteType(_ sender: Any) {
        updateSaveButton(selectedCount: 0)
        saveButtonOutlet.isEnabled = false
        if isPlayerSelected() {
            teams.removeAll()
            navigationItem.searchController = searchController
            tableView.reloadData()
        }
        else {
            navigationItem.searchController = nil
            players.removeAll()
            
            let fileName = season.YEAR.rawValue + FileManagerFiles.all_teams_suffix.rawValue
            if doesFileExist(name: fileName) {
                if let data = getFileData(name: fileName) {
                    return decodeTeams(data: data)
                }
                return displayMessage_sgup0027(title: FILE_MANAGER_DATA_ERROR_TITLE, message: FILE_MANAGER_DATA_ERROR_MESSAGE)
            }
            
            indicator.startAnimating()
            Task {
                let (data, error) = await requestData(path: .teams, queries: [:])
                guard let data = data else {
                    displayMessage_sgup0027(title: error!.title, message: error!.message)
                    indicator.stopAnimating()
                    return
                }
                
                // update/create a file to persistently store the data retrieved
                setFileData(name: fileName, data: data)
                decodeTeams(data: data)
                indicator.stopAnimating()
            }
        }
    }
    
    private func decodeTeams(data: Data) {
        do {
            let decoder = JSONDecoder()
            let collection = try decoder.decode(TeamCollection.self, from: data)
            if let decodedTeams = collection.teams {
                teams.append(contentsOf: decodedTeams)
                tableView.reloadData()
            }
        }
        catch let error {
            displayMessage_sgup0027(title: JSON_DECODER_ERROR_TITLE, message: error.localizedDescription)
        }
    }
    
    @IBAction func addFavourites(_ sender: Any) {
        for path in tableView.indexPathsForSelectedRows! {
            if isPlayerSelected() {
                let player = players[path.row]
                if !appDelegate.favouritePlayers.contains(where: { element in
                    return element.id == player.id
                }) {
                    appDelegate.favouritePlayers.append(player)
                }
            }
            else {
                let team = teams[path.row]
                if !appDelegate.favouriteTeams.contains(where: { element in
                    return element.id == team.id
                }) {
                    appDelegate.favouriteTeams.append(team)
                }
            }
        }
        updateFavourites()
        navigationController?.popViewController(animated: true)
    }
    
    
    private func getPlayerData(_ searchText: String) {
        Task {
            let (data, error) = await requestData(path: .players, queries: [.search: searchText])
            guard let data = data else {
                displayMessage_sgup0027(title: error!.title, message: error!.message)
                indicator.stopAnimating()
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let collection = try decoder.decode(PlayerDataCollection.self, from: data)
                if let searchedPlayers = collection.players {
                    self.players.append(contentsOf: searchedPlayers)
                    self.tableView.reloadData()
                }
                
            }
            catch let error {
                self.displayMessage_sgup0027(title: JSON_DECODER_ERROR_TITLE, message: error.localizedDescription)
            }
            indicator.stopAnimating()
        }
    }
    
    internal func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if isPlayerSelected() { players.removeAll() }
        tableView.reloadData()
        
        guard let searchText = searchBar.text else { return }
        
        navigationItem.searchController?.dismiss(animated: true)
        indicator.startAnimating()
        getPlayerData(searchText)
    }
    
    private func updateSaveButton(selectedCount: Int) {
        var newTitle = DEFAULT_ADD_BUTTON_TITLE
        if selectedCount > 1 {
            newTitle += " (\(selectedCount))"
        }
        saveButtonOutlet.title = newTitle
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isPlayerSelected() {
            return players.count
        }
        return teams.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        var content = cell.defaultContentConfiguration()

        if isPlayerSelected() {
            let player = players[indexPath.row]
            content.text = player.firstName + " " + player.lastName
            content.secondaryText = player.team.fullName
        }
        else {
            let team = teams[indexPath.row]
            content.text = team.fullName
            content.secondaryText = team.conference
        }
        
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        saveButtonOutlet.isEnabled = true
        updateSaveButton(selectedCount: tableView.indexPathsForSelectedRows?.count ?? 0)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let selected_rows = tableView.indexPathsForSelectedRows
        if selected_rows?.count ?? 0 < 1 {
            saveButtonOutlet.isEnabled = false
        }
        updateSaveButton(selectedCount: selected_rows?.count ?? 0)
    }
}
