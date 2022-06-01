//
//  Player.swift
//  FIT3178-App
//
//  Created by Samir Gupta on 20/4/22.
//

import UIKit

/// Class representing an NBA player.
class Player: NSObject, Codable { // stores the data for a specific player from API
    /// The ID of the player.
    var id: Int
    /// The player's first name.
    var firstName : String
    /// The player's last name.
    var lastName : String
    /// The player's position.
    var position : String?
    /// The player's height in feet.
    var heightFeet : Int?
    /// The player's height in inches.
    var heightInches : Int?
    /// The player's weight in pounds.
    var weightPounds : Int?
    /// The team the player belongs to,
    var team : Team
    
    /// Coding keys required for encoding and decoding.
    private enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case position
        case heightFeet = "height_feet"
        case heightInches = "height_inches"
        case weightPounds = "weight_pounds"
        case team
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        position = try container.decode(String?.self, forKey: .position)
        heightFeet = try container.decode(Int?.self, forKey: .heightFeet)
        heightInches = try container.decode(Int?.self, forKey: .heightInches)
        weightPounds = try container.decode(Int?.self, forKey: .weightPounds)
        team = try container.decode(Team.self, forKey: .team)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(position, forKey: .position)
        try container.encode(heightFeet, forKey: .heightFeet)
        try container.encode(heightInches, forKey: .heightInches)
        try container.encode(weightPounds, forKey: .weightPounds)
        try container.encode(team, forKey: .team)
    }
}

/// Class to store a collection of Players.
class PlayerCollection: NSObject, Decodable {
    /// The players in this collection.
    var players: [Player]?
    
    /// The coding keys required for decoding.
    private enum CodingKeys: String, CodingKey {
        case players = "data"
    }
}
