//
//  NetworkingRequests.swift
//  OnTheMap
//
//  Created by Alec O'Connor on 11/30/17.
//  Copyright © 2017 Alec O'Connor. All rights reserved.
//

import Foundation

typealias StudentCallback = (([Student]?, Error?) -> Void)
typealias ProfileCallback = ((Profile?, Error?)-> Void)
typealias SuccessCallback = ((Bool) -> Void)
typealias StringCallback = ((String?)-> Void)

class NetworkingRequests {
    
    static let shared = NetworkingRequests()
    private init() {  }
    
    fileprivate func generateRequest(url: String, method: String) -> URLRequest {
        var request = URLRequest(url: URL(string: url)!)
        request.addValue(NetworkingConstants.appID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(NetworkingConstants.apiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.httpMethod = method
        return request
    }
    
    // MARK: Session Data
    
    func postUdacitySession(username: String, password: String, callback: @escaping StringCallback) {
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\":{\"username\":\"\(username)\", \"password\": \"\(password)\"}}".data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                callback(nil)
                return
            }
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range)
            let sessionContainer = try? JSONDecoder().decode(SessionContainer.self, from: newData ?? Data())
            print(sessionContainer ?? "")
            if (sessionContainer?.account?.registered ?? false) {
                callback(sessionContainer?.account?.key)
            } else {
                callback(nil)
            }
        }
        task.resume()
    }
    
    func deleteUdacitySession(_ callback: @escaping SuccessCallback) {
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                callback(false)
                return
            }
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range)
            let sessionContainer = try? JSONDecoder().decode(SessionContainer.self, from: newData ?? Data())
            print(sessionContainer ?? "")
            if (sessionContainer?.account == nil) {
                print("Success")
                callback(true)
            } else {
                print("Failure")
                callback(false)
            }
        }
        task.resume()
    }
    
    // MARK: Profile Data
    
    func getProfile(_ id: String, callback: @escaping ProfileCallback) {
        let request = URLRequest(url: URL(string: "https://www.udacity.com/api/users/\(id)")!)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                callback(nil, NetworkingError.NetworkError(error!))
                return
            }
            guard let data = data else {
                callback(nil, NetworkingError.DataIsEmpty)
                return
            }
            let range = Range(5..<data.count)
            let newData = data.subdata(in: range)
            do {
                let user = try JSONDecoder().decode(User.self, from: newData)
                let profile = user.profile
                callback(profile, nil)
            } catch {
                callback(nil, NetworkingError.UnableToParseData(error))
            }
            
        }
        task.resume()
    }
    
    // MARK: Student Data
    
    func getStudents(byKey key: String? = nil, _ callback: @escaping StudentCallback) {
        var limits = "limit=200&order=-updatedAt"
        if let key = key {
            limits = "where=%7B%22uniqueKey%22%3A%22\(key)%22%7D"
        }
        let request = generateRequest(url: "https://parse.udacity.com/parse/classes/StudentLocation?\(limits)", method: "GET")
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard error == nil else {
                callback(nil, NetworkingError.NetworkError(error!))
                return
            }
            guard let data = data else {
                callback(nil, NetworkingError.DataIsEmpty)
                return
            }
            do {
                let studentResults = try JSONDecoder().decode(StudentResults.self, from: data)
                let students = studentResults.results
                callback(students, nil)
            } catch {
                callback(nil, NetworkingError.UnableToParseData(error))
            }
        }
        task.resume()
    }
    
    func deleteStudent(objectId: String, callback: @escaping SuccessCallback) {
        var request = generateRequest(url: "https://parse.udacity.com/parse/classes/StudentLocation/\(objectId)", method: "DELETE")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 else {
                    callback(false)
                    return
            }
            callback(true)
        }
        task.resume()

    }
    
    func putPostStudent(objectId: String? = nil, profile: Profile, mapString: String, mediaURL: URL, latitude: Float, longitude: Float, _ callback: @escaping SuccessCallback) {
        var method = "POST"
        var URLString = "https://parse.udacity.com/parse/classes/StudentLocation"
        if let objectId = objectId {
            method = "PUT"
            URLString += "/\(objectId)"
        }
        var request = generateRequest(url: URLString, method: method)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody =
        """
        {\"uniqueKey\": \"\(profile.key)\",
        \"firstName\": \"\(profile.firstName)\",
        \"lastName\": \"\(profile.lastName)\",
        \"mapString\": \"\(mapString)\",
        \"mediaURL\": \"\(mediaURL.absoluteString)\",
        \"latitude\": \(latitude),
        \"longitude\": \(longitude)}
        """.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil,
                let data = data,
                let response = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                (response?["updatedAt"] as? String != nil || response?["createdAt"] as? String != nil) else {
                    callback(false)
                    return
            }
            callback(true)
        }
        task.resume()
    }
    
}
