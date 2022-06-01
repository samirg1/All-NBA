//
//  PlayerData.swift
//  FIT3178-App
//
//  Created by Samir Gupta on 20/4/22.
//

import UIKit

class PlayerData: NSObject, Decodable {
    var id: Int
    var firstName : String?
    var lastName : String?
    var position : String?
    var heightFeet : Int?
    var heightInches : Int?
    var weightPounds : Int?
    var team : TeamData?
    
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
        position = try container.decode(String.self, forKey: .position)
        heightFeet = try container.decode(Int.self, forKey: .heightFeet)
        heightInches = try container.decode(Int.self, forKey: .heightInches)
        weightPounds = try container.decode(Int.self, forKey: .weightPounds)
        team = try container.decode(TeamData.self, forKey: .team)
    }
}
