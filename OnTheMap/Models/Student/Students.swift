//
//  Students.swift
//  OnTheMap
//
//  Created by Alec O'Connor on 11/30/17.
//  Copyright © 2017 Alec O'Connor. All rights reserved.
//

import Foundation

class Students {
    
    static var shared = Students()
    
    var all = [Student]()
    
    private init() {  }
    
    func refreshStudents(callback: @escaping StudentCallback) {
        NetworkingRequests.shared.getStudents({ (students, error) in
            if let students = students {
                self.all = students
            }
            callback(self.all, error)
        })
    }
    
}
