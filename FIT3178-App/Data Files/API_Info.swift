//
//  InfoAPI.swift
//  All-NBA
//
//  Created by Samir Gupta on 31/5/2022.
//
import UIKit

// MARK: - API URL Building

/// Stores the currently used API URL paths.
public enum API_URL_PATHS: String {
    /// The path of the API to access player's stats.
    case stats = "stats"
    /// The path of the API to access games.
    case games = "games"
    /// The path of the API to access teams.
    case teams = "teams"
    /// The path of the API to access players.
    case players = "players"
    /// The path of the API to access player's season stats.
    case averages = "season_averages"
}

/// Stores the currently used API queries.
public enum API_QUERIES: String {
    /// The query of the API to search for specific players.
    case search = "search"
    /// The query of the API to specify game IDs.
    case game_ids = "game_ids[]"
    /// The query of the API to change the amount of results retrieved in one page.
    case per_page = "per_page"
    /// The query of the API to specify certain dates.
    case dates = "dates[]"
    /// The query of the API to specify a start date for results.
    case start_date = "start_date"
    /// The query of the API to specify an end date for results.
    case end_date = "end_date"
    /// The query of the API to specify specific seasons to search results for.
    case seasons = "seasons[]"
    /// The query of the API to specify team IDs to find results for.
    case team_ids = "team_ids[]"
    /// The query of the API to specify specifc players to find results for.
    case player_ids = "player_ids[]"
    /// The query of the API to specify the required page number of the results to find.
    case page = "page"
}

// MARK: - API Error Handling

/// Stores the HTTP error codes that come as a response to calling the API.
public enum HTTP_ERROR_CODES: Int {
    /// API response code when the request is successful.
    case success = 200
    /// API response when the request is invalid.
    case bad_request = 400
    /// API response when response requested is not found.
    case not_found = 404
    /// API response code when the format requested is invalid.
    case not_acceptable = 406
    /// API response code when there have been too many requests.
    case too_many_requests = 429
    /// API response code when there is an error in the API's internal server.
    case server_error = 500
    /// API response code when the API's server is down or under maintainence.
    case service_unavailable = 503
}

/// A dictionary storing key value pairs of the error codes returned by the API, and appropriate error messages to display to the user in response to the error code.
public let API_ERROR_CODE_MESSAGES = [
    HTTP_ERROR_CODES.bad_request.rawValue: NSLocalizedString("Invalid server request.", comment: "bad_request"),
    HTTP_ERROR_CODES.not_found.rawValue: NSLocalizedString("Server request was not found.", comment: "not_found" ),
    HTTP_ERROR_CODES.not_acceptable.rawValue: NSLocalizedString("Invalid server request format.", comment: "not_acceptable"),
    HTTP_ERROR_CODES.too_many_requests.rawValue: NSLocalizedString("Too many server requests.", comment: "too_many_requests"),
    HTTP_ERROR_CODES.server_error.rawValue: NSLocalizedString("Internal server error.", comment: "server_error"),
    HTTP_ERROR_CODES.service_unavailable.rawValue: NSLocalizedString("Server currently unavailable.", comment: "service_unavailable")
]

/// Error message used when there is an error decoding data.
public let JSON_DECODER_ERROR_TITLE = NSLocalizedString("Error decoding API data.", comment: "error_decoding_data")

// MARK: Requesting Data

/// Request specific data from the API.
/// - Parameters:
///     - path: The path of the URL.
///     - queries: A list of tuple pairs containing the query and the value.
/// - Returns: A tuple containing the data (if any), and the error title and message (if any).
public func requestData(path: API_URL_PATHS, queries: [(API_QUERIES,String)]) async -> (Data?, (title: String, message: String)?) {
    var gamesURL = URLComponents()
    gamesURL.scheme = "https"
    gamesURL.host = "www.balldontlie.io"
    gamesURL.path = "/api/v1/" + path.rawValue
    
    var query_items: [URLQueryItem] = [] // build query items
    for q in queries { query_items.append(URLQueryItem(name: q.0.rawValue, value: q.1)) }
    gamesURL.queryItems = query_items
    
    guard let requestURL = gamesURL.url else { // make sure URL is valid
        return (nil, (NSLocalizedString("Unable to retrieve information", comment: "unable_to_retrieve"), NSLocalizedString("Invalid URL.", comment: "invalid_url")))
    }
    
    let urlRequest = URLRequest(url: requestURL) // create request
    do {
        let (data, response) = try await URLSession.shared.data(for: urlRequest) // wait for response
        if let response = response as? HTTPURLResponse, response.statusCode != HTTP_ERROR_CODES.success.rawValue  { // if response is not successful
            return (nil, (NSLocalizedString("An error occured whilst retrieving data", comment: "error_retrieving_data"), API_ERROR_CODE_MESSAGES[response.statusCode]!))
        }
        
        return (data, nil) // if response is successful, return data
    }
    catch let error { // catch any errors
        return (nil, (NSLocalizedString("An error occured whilst retrieving data", comment: "error_retrieving_data"), error.localizedDescription))
    }
}
