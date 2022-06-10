//
//  AddFavouritesTableViewController.swift
//  All-NBA
//
//  Created by Samir Gupta on 28/5/2022.
//

import UIKit

/// Custom class used to add user favourites.
class AddFavouritesTableViewController: UITableViewController, UISearchBarDelegate {
    /// The segment that is used to add players.
    private let PLAYER_SEGMENT = 0
    /// The segment that is used to add teams.
    private let TEAM_SEGMENT = 1
    /// The identifier of the result cell.
    private let CELL_IDENTIFIER = "resultCell"
    /// The default title of the 'Add' button.
    private let DEFAULT_ADD_BUTTON_TITLE = NSLocalizedString("Add", comment: "add")
    /// The collection of players returned by the search.
    private var players: [Player] = []
    /// The collection of all teams to choose from.
    private var teams: [Team] = []
    /// The current season to search teams for.
    private let season = Season2021_2022.self
    
    /// Outlet to the segmented control that controls whether to add players or teams.
    @IBOutlet weak private var favouriteType: UISegmentedControl!
    /// The outlet to the button that saves (adds) the players / teams to the favourites.
    @IBOutlet weak private var saveButtonOutlet: UIBarButtonItem!
    
    /// Indicator to indicate when an asynchronous task is active.
    private lazy var indicator: UIActivityIndicatorView = {
        var indicator = UIActivityIndicatorView()
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([ indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor), indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor) ])
        return indicator
    }()
    
    /// Search controller used to search for specific players.
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("Search players", comment: "search_players")
        searchController.searchBar.showsCancelButton = false
        return searchController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButtonOutlet.isEnabled = false
        self.tableView.allowsMultipleSelection = true // select mutliple favourites at a time
        navigationItem.searchController = searchController // set up search bar
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    /// Check if the player segmenet is selected.
    /// - Returns: boolean determining whether the player segment is selected.
    private func isPlayerSelected() -> Bool {
        return favouriteType.selectedSegmentIndex == PLAYER_SEGMENT
    }
    
    /// Action when the user changes the type of favourite they want to add.
    ///  - Parameters:
    ///     - sender: The triggerer of this action.
    @IBAction private func changeFavouriteType(_ sender: Any) {
        updateSaveButton(selectedCount: 0) // reset save button title
        saveButtonOutlet.isEnabled = false
        if isPlayerSelected() {
            teams.removeAll() // if user has selected player, remove all teams and update
            navigationItem.searchController = searchController
            tableView.reloadData()
        }
        else { // otherwise get all teams and remove players
            navigationItem.searchController = nil
            players.removeAll()
            
            // find if file exists
            let fileName = season.YEAR.rawValue + FileManagerFiles.all_teams_suffix.rawValue
            if doesFileExist(name: fileName) {
                if let data = getFileData(name: fileName) {
                    return decodeTeams(data: data)
                }
                return displaySimpleMessage(title: FILE_MANAGER_DATA_ERROR_TITLE, message: FILE_MANAGER_DATA_ERROR_MESSAGE)
            }
            // otherwise use API to get data
            indicator.startAnimating()
            Task {
                let (data, error) = await requestData(path: .teams, queries: []) // get data
                guard let data = data else {
                    displaySimpleMessage(title: error!.title, message: error!.message)
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
    
    /// Decode the teams data.
    /// - Parameters:
    ///     - data: The data to decode.
    private func decodeTeams(data: Data) {
        do {
            let decoder = JSONDecoder()
            let collection = try decoder.decode(TeamCollection.self, from: data) // decode data
            if let decodedTeams = collection.teams {
                teams.append(contentsOf: decodedTeams) // add teams to container
                tableView.reloadData()
            }
        }
        catch let error {
            displaySimpleMessage(title: JSON_DECODER_ERROR_TITLE, message: error.localizedDescription)
        }
    }
    
    /// Action when the user wants to save the favourites they have selected.
    ///  - Parameters:
    ///     - sender: The triggerer of this action.
    @IBAction private func addFavourites(_ sender: Any) {
        for path in tableView.indexPathsForSelectedRows! { // for each of the selected rows
            if isPlayerSelected() {
                let player = players[path.row]
                if !appDelegate.favouritePlayers.contains(where: { element in return element.id == player.id}) {
                    appDelegate.favouritePlayers.append(player) // only add player if they aren't already in the favourites
                }
            }
            else {
                let team = teams[path.row]
                if !appDelegate.favouriteTeams.contains(where: { element in return element.id == team.id}) {
                    appDelegate.favouriteTeams.append(team) // only add team if they aren't already in the favourites
                }
            }
        }
        updateFavourites() // update user favourites
        navigationController?.popViewController(animated: true) // go back to favourites page
    }
    
    /// Using search text, get player data matching the search text.
    /// - Parameters:
    ///     - searchText: The text to match player names to.
    private func getPlayerData(_ searchText: String) {
        Task {
            let (data, error) = await requestData(path: .players, queries: [(.search, searchText)]) // get players based on search text
            guard let data = data else {
                displaySimpleMessage(title: error!.title, message: error!.message)
                indicator.stopAnimating()
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let collection = try decoder.decode(PlayerCollection.self, from: data) // decode players
                if let searchedPlayers = collection.players {
                    self.players.append(contentsOf: searchedPlayers) // add the players to the container
                    self.tableView.reloadData()
                }
                
            }
            catch let error {
                self.displaySimpleMessage(title: JSON_DECODER_ERROR_TITLE, message: error.localizedDescription)
            }
            indicator.stopAnimating()
        }
    }
    
    /// Action to get player data once the search bar text has been finalised.
    /// - Parameters:
    ///     - searchBar: The searchbar that triggered this function.
    internal func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if isPlayerSelected() { players.removeAll() } // clear all players first
        tableView.reloadData()
        
        guard let searchText = searchBar.text else { return } // make sure there is text
        
        navigationItem.searchController?.dismiss(animated: true) // dismiss search bar
        indicator.startAnimating()
        getPlayerData(searchText) // get the player data from the search text
    }
    
    /// Update the save (add) button title to show the user how many items they have selected to add.
    /// - Parameters:
    ///     - selectedCount: The amount of rows selected by the user.
    private func updateSaveButton(selectedCount: Int) {
        var newTitle = DEFAULT_ADD_BUTTON_TITLE
        if selectedCount > 1 {
            newTitle += " (\(selectedCount))"
        }
        saveButtonOutlet.title = newTitle
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isPlayerSelected() {
            return players.count
        }
        return teams.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_IDENTIFIER, for: indexPath)
        var content = cell.defaultContentConfiguration()

        if isPlayerSelected() { // player cell
            let player = players[indexPath.row]
            content.text = player.firstName + " " + player.lastName
            content.secondaryText = player.team.fullName
        }
        else { // team cell
            let team = teams[indexPath.row]
            content.text = team.fullName
            content.secondaryText = NSLocalizedString(team.conference, comment: "")
        }
        
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        saveButtonOutlet.isEnabled = true
        updateSaveButton(selectedCount: tableView.indexPathsForSelectedRows?.count ?? 0) // update save button
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let selected_rows = tableView.indexPathsForSelectedRows
        if selected_rows?.count ?? 0 < 1 {
            saveButtonOutlet.isEnabled = false
        }
        updateSaveButton(selectedCount: selected_rows?.count ?? 0) // update save button
    }
}
