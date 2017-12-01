//
//  Profile.swift
//  OnTheMap
//
//  Created by Alec O'Connor on 11/30/17.
//  Copyright © 2017 Alec O'Connor. All rights reserved.
//

import Foundation

struct Profile: Codable {
    var firstName: String
    var lastName: String
    var key: String
    
    private enum CodingKeys: String, CodingKey {
        case key
        case firstName = "first_name"
        case lastName = "last_name"
    }
}

struct User: Codable {
    var profile: Profile
    private enum CodingKeys: String, CodingKey {
        case profile = "user"
    }
}
