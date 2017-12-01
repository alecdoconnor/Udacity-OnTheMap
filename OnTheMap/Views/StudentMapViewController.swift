//
//  StudentMapViewController.swift
//  OnTheMap
//
//  Created by Alec O'Connor on 11/30/17.
//  Copyright © 2017 Alec O'Connor. All rights reserved.
//

import UIKit
import MapKit

class StudentMapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var students = [Student]() {
        didSet {
            populateMap()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        activityIndicator.hidesWhenStopped = true
        refreshStudents()
        populateNavigationBarButtonItems()
        setUpNotifications()
        populateMap()
    }
    
    deinit {
        removeNotifications()
    }
    
    // MARK: View Controller Setup
    
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
        presentActivityIndicator(isVisible: true)
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
                self.presentActivityIndicator(isVisible: false)
                DispatchQueue.main.async {
                    guard error == nil,
                        let students = students else {
                            self.presentErrorAlert()
                            print(error ?? "")
                            return
                    }
                    self.students = students
                }
            }
        } else {
            students = Students.shared.all
            presentActivityIndicator(isVisible: false)
        }
    }
    
    // MARK: Map Control
    
    func populateMap() {
        var annotations = [MKPointAnnotation]()
        for student in students {
            let latitude = Double(student.latitude)
            let longitude = Double(student.longitude)
            
            // If invalid latitude/longitude
            //      0 is default value
            if latitude == 0.0 || longitude == 0.0 { continue }
            
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            let firstName = student.firstName
            let lastName = student.lastName
            let mediaURL = student.mediaURL
            
            // If invalid student, do not display on map
            if firstName == "" || lastName == "" || mediaURL == nil { continue }
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(firstName) \(lastName)"
            annotation.subtitle = mediaURL?.absoluteString ?? ""
            
            // Finally we place the annotation in an array of annotations.
            annotations.append(annotation)
        }
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotations(annotations)
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
    
    func presentActivityIndicator(isVisible: Bool) {
        DispatchQueue.main.async {
            if isVisible {
                self.activityIndicator.startAnimating()
            } else {
                self.activityIndicator.stopAnimating()
            }
        }
    }
}

extension StudentMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor(red: 30/256, green: 180/256, blue: 226/256, alpha: 1)
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }

        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            if let toOpen = view.annotation?.subtitle, let urlToOpen = URL(string: toOpen!) {
                UIApplication.shared.open(urlToOpen, options: [:], completionHandler: nil)
            }
        }
    }
}
