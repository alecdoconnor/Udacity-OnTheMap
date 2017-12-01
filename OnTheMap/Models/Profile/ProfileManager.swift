//
//  ProfileManager.swift
//  OnTheMap
//
//  Created by Alec O'Connor on 11/30/17.
//  Copyright © 2017 Alec O'Connor. All rights reserved.
//

import Foundation

class ProfileManager {
    
    static let shared = ProfileManager()
    var profile: Profile? {
        didSet {
            let profileDate = (try? JSONEncoder().encode(profile)) ?? Data()
            UserDefaults.standard.set(profileDate, forKey: "userProfile")
        }
    }
    var objectId: String?
    var locationString: String?
    var websiteString: String?
    
    private init() {
        let profileData = UserDefaults.standard.data(forKey: "userProfile") ?? Data()
        let profile = (try? JSONDecoder().decode(Profile.self, from: profileData))
        self.profile = profile
    }
    
    func getProfile(byKey key: String, callback: @escaping SuccessCallback) {
        NetworkingRequests.shared.getProfile(key) { (profile, error) in
            if let profile = profile {
                self.profile = profile
                callback(true)
            }
            callback(false)
        }
    }
    
    func login(email: String, password: String, callback: @escaping SuccessCallback) {
        NetworkingRequests.shared.postUdacitySession(username: email, password: password) { (key) in
            if let key = key {
                //Logged in, now grab profile
                self.getProfile(byKey: key, callback: { (success) in
                    callback(success)
                })
            } else {
                callback(false)
            }
        }
    }
    
    func logout(callback: @escaping SuccessCallback) {
        NetworkingRequests.shared.deleteUdacitySession { (success) in
            if success {
                self.profile = nil
                callback(true)
            } else {
                callback(false)
            }
        }
    }
    
}
