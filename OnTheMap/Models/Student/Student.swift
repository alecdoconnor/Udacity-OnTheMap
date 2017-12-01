//
//  Student.swift
//  OnTheMap
//
//  Created by Alec O'Connor on 11/30/17.
//  Copyright © 2017 Alec O'Connor. All rights reserved.
//

import Foundation

struct Student: Codable {
    
    var id: String
    var firstName: String
    var lastName: String
    var location: String
    var mediaURL: URL?
    var latitude: Float
    var longitude: Float
    
    private enum CodingKeys: String, CodingKey {
        case firstName, lastName, mediaURL, latitude, longitude
        case id = "objectId"
        case location = "mapString"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id          =  try values.decode(String.self, forKey: .id)
        firstName   = (try? values.decode(String.self, forKey: .firstName)) ?? ""
        lastName    = (try? values.decode(String.self, forKey: .lastName)) ?? ""
        location    = (try? values.decode(String.self, forKey: .location)) ?? ""
        mediaURL    = (try? values.decode(URL.self, forKey: .mediaURL)) ?? nil
        latitude    = (try? values.decode(Float.self, forKey: .latitude)) ?? 0
        longitude   = (try? values.decode(Float.self, forKey: .longitude)) ?? 0
    }
    
}
