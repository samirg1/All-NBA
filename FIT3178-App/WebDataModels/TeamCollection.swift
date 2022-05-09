//
//  TeamCollection.swift
//  FIT3178-App
//
//  Created by Samir Gupta on 4/5/22.
//

import Foundation

class TeamCollection: NSObject, Decodable { // used to store a collection of teams from API
    var teams: [TeamData]?
    
    private enum CodingKeys: String, CodingKey {
        case teams = "data"
    }
}
