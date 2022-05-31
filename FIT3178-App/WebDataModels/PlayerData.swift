//
//  PlayerData.swift
//  FIT3178-App
//
//  Created by Samir Gupta on 20/4/22.
//

import UIKit

class PlayerData: NSObject, Codable { // stores the data for a specific player from API
    var id: Int
    var firstName : String
    var lastName : String
    var position : String?
    var heightFeet : Int?
    var heightInches : Int?
    var weightPounds : Int?
    var team : TeamData
    
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
        team = try container.decode(TeamData.self, forKey: .team)
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
