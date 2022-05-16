//
//  TeamData.swift
//  FIT3178-App
//
//  Created by Samir Gupta on 19/4/22.
//

import UIKit

class TeamData: NSObject, Decodable {
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
        abbreviation = try container.decode(String.self, forKey: .abbreviation)
        fullName = try container.decode(String.self, forKey: .fullName)
        nickname = try container.decode(String.self, forKey: .nickname)
        conference = try container.decode(String.self, forKey: .conference)
        division = try container.decode(String.self, forKey: .division)
    }
}
