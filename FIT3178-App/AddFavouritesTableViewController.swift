//
//  AddFavouritesTableViewController.swift
//  All-NBA
//
//  Created by Samir Gupta on 28/5/2022.
//

import UIKit

class AddFavouritesTableViewController: UITableViewController, UISearchBarDelegate {


    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let playerSegment = 0
    let teamSegment = 1
    let cellIdentifier = "resultCell"
    let DEFAULT_ADD_BUTTON_TITLE = "Add"
    
    var players: [PlayerData] = []
    var teams: [TeamData] = []
    
    @IBOutlet weak var favouriteType: UISegmentedControl!
    @IBOutlet weak var saveButtonOutlet: UIBarButtonItem!
    
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
            indicator.startAnimating()
            Task {
                await getTeams()
            }
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
        appDelegate.updateFavourites()
        navigationController?.popViewController(animated: true)
    }
    
    
    internal func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if isPlayerSelected() {
            players.removeAll()
        }
        tableView.reloadData()
        
        guard let searchText = searchBar.text else {
            return
        }
        
        navigationItem.searchController?.dismiss(animated: true)
        indicator.startAnimating()
        Task {
            URLSession.shared.invalidateAndCancel()
            await getPlayers(text: searchText)
        }
    }
    
    private func getTeams() async {
        var gamesURL = URLComponents()
        gamesURL.scheme = appDelegate.API_URL_SCHEME
        gamesURL.host = appDelegate.API_URL_HOST
        gamesURL.path = appDelegate.API_URL_PATH + appDelegate.API_URL_PATH_TEAMS
        
        guard let requestURL = gamesURL.url else {
            displayMessage_sgup0027(title: appDelegate.URL_CONVERSION_ERROR_TITLE, message: appDelegate.URL_CONVERSION_ERROR_MESSAGE)
            indicator.stopAnimating()
            return
        }
        
        let urlRequest = URLRequest(url: requestURL)
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            if let response = response as? HTTPURLResponse, response.statusCode != HTTP_ERROR_CODES.success.rawValue  {
                displayMessage_sgup0027(title: appDelegate.API_ERROR_TITLE, message: appDelegate.API_ERROR_CODE_MESSAGES[response.statusCode]!)
                indicator.stopAnimating()
                return
            }
            DispatchQueue.main.async {
                do {
                    let decoder = JSONDecoder()
                    let collection = try decoder.decode(TeamCollection.self, from: data)
                    if let decodedTeams = collection.teams {
                        self.teams.append(contentsOf: decodedTeams)
                        self.tableView.reloadData()
                    }
                }
                catch let error {
                    self.displayMessage_sgup0027(title: self.appDelegate.JSON_DECODER_ERROR_TITLE, message: error.localizedDescription)
                }
            }
        }
        catch let error {
            displayMessage_sgup0027(title: appDelegate.API_ERROR_TITLE, message: error.localizedDescription)
        }
        indicator.stopAnimating()
    }
    
    private func getPlayers(text: String) async {
        var playerSearchURL = URLComponents()
        playerSearchURL.scheme = appDelegate.API_URL_SCHEME
        playerSearchURL.host = appDelegate.API_URL_HOST
        playerSearchURL.path = appDelegate.API_URL_PATH + appDelegate.API_URL_PATH_PLAYERS
        playerSearchURL.queryItems = [ URLQueryItem(name: appDelegate.API_QUERY_PLAYER_SEARCH, value: text) ]
        
        guard let requestURL = playerSearchURL.url else {
            displayMessage_sgup0027(title: appDelegate.URL_CONVERSION_ERROR_TITLE, message: appDelegate.URL_CONVERSION_ERROR_MESSAGE)
            indicator.stopAnimating()
            return
        }
        let urlRequest = URLRequest(url: requestURL)
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            if let response = response as? HTTPURLResponse, response.statusCode != HTTP_ERROR_CODES.success.rawValue  {
                displayMessage_sgup0027(title: appDelegate.API_ERROR_TITLE, message: appDelegate.API_ERROR_CODE_MESSAGES[response.statusCode]!)
                indicator.stopAnimating()
                return
            }
            DispatchQueue.main.async {
                do {
                    let decoder = JSONDecoder()
                    let collection = try decoder.decode(PlayerDataCollection.self, from: data)
                    if let searchedPlayers = collection.players {
                        self.players.append(contentsOf: searchedPlayers)
                        self.tableView.reloadData()
                    }
                    
                }
                catch let error {
                    self.displayMessage_sgup0027(title: self.appDelegate.JSON_DECODER_ERROR_TITLE, message: error.localizedDescription)
                }
            }
        }
        catch let error {
            displayMessage_sgup0027(title: appDelegate.API_ERROR_TITLE, message: error.localizedDescription)
        }
        indicator.stopAnimating()
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
    
    private func updateSaveButton(selectedCount: Int) {
        var newTitle = DEFAULT_ADD_BUTTON_TITLE
        if selectedCount > 1 {
            newTitle += " (\(selectedCount))"
        }
        saveButtonOutlet.title = newTitle
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
