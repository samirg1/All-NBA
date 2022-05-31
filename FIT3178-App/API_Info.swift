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
    HTTP_ERROR_CODES.bad_request.rawValue: "Invalid server request.",
    HTTP_ERROR_CODES.not_found.rawValue: "Server request was not found.",
    HTTP_ERROR_CODES.not_acceptable.rawValue: "Invalid server request format.",
    HTTP_ERROR_CODES.too_many_requests.rawValue: "Too many server requests.",
    HTTP_ERROR_CODES.server_error.rawValue: "Internal server error.",
    HTTP_ERROR_CODES.service_unavailable.rawValue: "Server currently unavailable."
]

/// Error message used when there is an error decoding data.
public let JSON_DECODER_ERROR_TITLE = "Error decoding API data"


/// Request specific data from the API.
/// - Parameters:
///     - path: the path of the URL.
///     - queries: a dictionary of key/value pairs of API queries.
/// - Returns: A tuple containing the data (if any), and the error title and message (if any).
public func requestData(path: API_URL_PATHS, queries: [API_QUERIES:String]) async -> (Data?, (title: String, message: String)?) {
    var gamesURL = URLComponents()
    gamesURL.scheme = "https"
    gamesURL.host = "www.balldontlie.io"
    gamesURL.path = "/api/v1/" + path.rawValue
    
    var query_items: [URLQueryItem] = []
    for q in queries { query_items.append(URLQueryItem(name: q.key.rawValue, value: q.value)) }
    gamesURL.queryItems = query_items
    
    guard let requestURL = gamesURL.url else {
        return (nil, ("Unable to retrieve information", "Invalid URL."))
    }
    
    let urlRequest = URLRequest(url: requestURL)
    do {
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        if let response = response as? HTTPURLResponse, response.statusCode != HTTP_ERROR_CODES.success.rawValue  {
            return (nil, ("An error occured whilst retrieving data", API_ERROR_CODE_MESSAGES[response.statusCode]!))
        }
        
        return (data, nil)
    }
    catch let error {
        return (nil, ("An error occured whilst retrieving data", error.localizedDescription))
    }
}
