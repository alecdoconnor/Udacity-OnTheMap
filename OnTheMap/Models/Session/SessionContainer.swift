//
//  SessionContainer.swift
//  OnTheMap
//
//  Created by Alec O'Connor on 11/30/17.
//  Copyright © 2017 Alec O'Connor. All rights reserved.
//

import Foundation

struct SessionContainer: Codable {
    var account: Account?
    var session: Session
    
    struct Account: Codable {
        var registered: Bool
        var key: String
    }
    
    struct Session: Codable {
        var id: String
        var expiration: Date?
        
        enum CodingKeys: String, CodingKey {
            case id, expiration
        }
        
        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            
            id = try values.decode(String.self, forKey: .id)
            
            let expirationString = try values.decode(String.self, forKey: .expiration)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            expiration = formatter.date(from: expirationString)
        }
    }
}




