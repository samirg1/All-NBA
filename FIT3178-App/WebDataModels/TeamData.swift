//
//  TeamData.swift
//  FIT3178-App
//
//  Created by Samir Gupta on 19/4/22.
//

import UIKit

class TeamData: NSObject, Codable { // stores the data for a specific team from API
    var id : Int
    
    var abbreviation : String?
    var fullName : String?
    var nickname : String?
    
    var conference : String?
    var division : String?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case abbreviation
        case fullName = "full_name"
        case nickname = "name"
        case conference
        case division
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        abbreviation = try container.decode(String?.self, forKey: .abbreviation)
        fullName = try container.decode(String?.self, forKey: .fullName)
        nickname = try container.decode(String?.self, forKey: .nickname)
        conference = try container.decode(String?.self, forKey: .conference)
        division = try container.decode(String?.self, forKey: .division)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(abbreviation, forKey: .abbreviation)
        try container.encode(fullName, forKey: .fullName)
        try container.encode(nickname, forKey: .nickname)
        try container.encode(conference, forKey: .conference)
        try container.encode(division, forKey: .division)
    }
}
