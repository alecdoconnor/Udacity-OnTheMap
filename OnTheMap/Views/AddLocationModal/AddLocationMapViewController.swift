//
//  AddLocationMapViewController.swift
//  OnTheMap
//
//  Created by Alec O'Connor on 11/30/17.
//  Copyright © 2017 Alec O'Connor. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class AddLocationMapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    var website: String?
    var location: String?
    var coordinate: CLLocationCoordinate2D?
    var objectId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        objectId = ProfileManager.shared.objectId
        setUpActivityIndicator()
        roundCorners(finishButton)
        if location != nil {
            geocodeAddress()
        }
    }
    
    func setUpActivityIndicator() {
        loadingActivityIndicator.stopAnimating()
        loadingActivityIndicator.hidesWhenStopped = true
    }

    @IBAction func finishButtonPressed(_ sender: Any) {
        guard let profile = ProfileManager.shared.profile,
            let location = location,
            let mediaURL = URL(string: website ?? "") else {
                return
        }
        let latitude = Float(coordinate?.latitude ?? 0)
        let longitude = Float(coordinate?.longitude ?? 0)
        NetworkingRequests.shared.putPostStudent(objectId: objectId, profile: profile, mapString: location, mediaURL: mediaURL, latitude: latitude, longitude: longitude) { (success) in
            if success {
                NotificationCenter.default.post(name: Notification.Name("forceStudentRefresh"), object: nil)
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                self.presentErrorAlert()
            }
        }
    }
    
    func geocodeAddress() {
        self.loadingActivityIndicator.startAnimating()
        let geoCoder = CLGeocoder()
        guard let location = location else { return }
        geoCoder.geocodeAddressString(location, completionHandler: { (placemarks, error) -> Void in
            DispatchQueue.main.async {
                guard error == nil else {
                        self.loadingActivityIndicator.stopAnimating()
                        self.presentErrorAlert("There was a problem searching that location")
                    return
                }
                if let placemark = placemarks?.first, let location = placemark.location {
                    self.coordinate = location.coordinate
                    
                    let mark = MKPlacemark(placemark: placemark)
                    var region = self.mapView.region
                    region.center = location.coordinate
                    region.span.longitudeDelta /= 200
                    region.span.latitudeDelta /= 200
                    self.mapView.setRegion(region, animated: true)
                    self.mapView.addAnnotation(mark)
                    
                    self.loadingActivityIndicator.stopAnimating()
                }
            }
        })
    }

}
