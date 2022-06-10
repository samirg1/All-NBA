//
//  Team.swift
//  FIT3178-App
//
//  Created by Samir Gupta on 19/4/22.
//

import UIKit

/// Class representing an NBA team.
class Team: NSObject, Codable {
    /// The ID of the team.
    var id : Int
    /// The 3 character abbreviation of the team.
    var abbreviation : String
    /// The team's full name.
    var fullName : String
    /// The team's conference.
    var conference : String
    /// The team's division.
    var division : String
    
    /// The coding keys required for decoding and encoding.
    private enum CodingKeys: String, CodingKey {
        case id
        case abbreviation
        case fullName = "full_name"
        case conference
        case division
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        abbreviation = try container.decode(String.self, forKey: .abbreviation)
        fullName = try container.decode(String.self, forKey: .fullName)
        conference = try container.decode(String.self, forKey: .conference)
        division = try container.decode(String.self, forKey: .division)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(abbreviation, forKey: .abbreviation)
        try container.encode(fullName, forKey: .fullName)
        try container.encode(conference, forKey: .conference)
        try container.encode(division, forKey: .division)
    }
}

/// Class to store a collection of teams
class TeamCollection: NSObject, Decodable {
    /// The teams housed by this collection.
    var teams: [Team]?
    
    /// Coding keys required for decoding.
    private enum CodingKeys: String, CodingKey {
        case teams = "data"
    }
}
