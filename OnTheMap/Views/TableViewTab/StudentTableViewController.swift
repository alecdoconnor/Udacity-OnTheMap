//
//  StudentTableViewController.swift
//  OnTheMap
//
//  Created by Alec O'Connor on 11/30/17.
//  Copyright © 2017 Alec O'Connor. All rights reserved.
//

import UIKit

class StudentTableViewController: UITableViewController {
    
    var students = [Student]()

    override func viewDidLoad() {
        super.viewDidLoad()
        refreshStudents()
        populateNavigationBarButtonItems()
        setUpPullToRefresh()
        setUpNotifications()
    }
    
    deinit {
        removeNotifications()
    }
    
    // MARK: View Controller Setup
    
    func setUpPullToRefresh() {
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(refreshStudents), for: UIControlEvents.valueChanged)
    }
    func setUpNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshStudents), name: Notification.Name("forceStudentRefresh"), object: nil)
    }
    func removeNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Navigation Bar Functionality
    
    func populateNavigationBarButtonItems() {
        let logoutButton = UIBarButtonItem(title: "LOGOUT", style: .done, target: self, action: #selector(logout))
        navigationItem.leftBarButtonItem = logoutButton
        
        let refreshImage = UIImage(named: "icon_refresh") ?? UIImage()
        let refreshButton = UIBarButtonItem(image: refreshImage, style: .plain, target: self, action: #selector(refreshStudents))
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addStudent))
        navigationItem.rightBarButtonItems = [addButton, refreshButton]
    }
    
    @objc func logout() {
        ProfileManager.shared.logout { (success) in
            if success {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.presentErrorAlert("Unable to logout, please try again")
            }
        }
    }
    
    @objc func refreshStudents() {
        DispatchQueue.main.async {
            self.refreshControl?.beginRefreshing()
        }
        getStudents()
    }
    
    @objc func addStudent() {
        func presentAddLocation() {
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let addLocationNavigationController = storyboard.instantiateViewController(withIdentifier: "addLocationNavigationController") as! UINavigationController
                self.present(addLocationNavigationController, animated: true, completion: nil)
            }
        }
        func deleteUserLocation(objectId: String) {
            NetworkingRequests.shared.deleteStudent(objectId: objectId) { (success) in
                if success {
                    NotificationCenter.default.post(name: Notification.Name("forceStudentRefresh"), object: nil)
                } else {
                    self.presentErrorAlert()
                }
            }
        }
        func verifyAddLocation(studentName: String, objectId: String) {
            let alert = UIAlertController(title: nil, message: "User \"\(studentName)\" has already posted a Student Location. Would you like to overwrite it?", preferredStyle: .alert)
            let overwriteAction = UIAlertAction(title: "Overwrite", style: .default, handler: { (_) in
                presentAddLocation()
            })
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
                deleteUserLocation(objectId: objectId)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(overwriteAction)
            alert.addAction(cancelAction)
            alert.addAction(deleteAction)
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
        guard let key = ProfileManager.shared.profile?.key else { return }
        NetworkingRequests.shared.getStudents(byKey: key) { (students, error) in
            guard let students = students else {
                return
            }
            if students.count > 0 {
                let objectId = students.first?.id ?? ""
                ProfileManager.shared.objectId = objectId
                ProfileManager.shared.locationString = students.first?.location
                ProfileManager.shared.websiteString = students.first?.mediaURL?.absoluteString
                let name = "\(students.first?.firstName ?? "") \(students.first?.lastName ?? "")"
                verifyAddLocation(studentName: name, objectId: objectId)
            } else {
                ProfileManager.shared.objectId = nil
                ProfileManager.shared.locationString = nil
                ProfileManager.shared.websiteString = nil
                presentAddLocation()
            }
        }
    }
    
    // MARK: Data Control
    
    func getStudents(forceReload: Bool = true) {
        if forceReload {
            Students.shared.refreshStudents { (students, error) in
                DispatchQueue.main.async {
                    guard error == nil,
                        let students = students else {
                            self.presentErrorAlert()
                            print(error ?? "")
                            return
                    }
                    self.students = students
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                }
            }
        } else {
            students = Students.shared.all
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    // MARK: View Functions
    
    func presentErrorAlert(_ message: String = "There was a problem performing that action.") {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentTableViewCell", for: indexPath) as? StudentTableViewCell

        cell?.nameLabel.text = "\(students[indexPath.row].firstName) \(students[indexPath.row].lastName)"
        cell?.mapStringLabel.text = students[indexPath.row].mediaURL?.baseURL?.absoluteString ?? students[indexPath.row].location

        return cell ?? UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let url = students[indexPath.row].mediaURL {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}
