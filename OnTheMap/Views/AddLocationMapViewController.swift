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
    
    var website: String?
    var location: String? {
        didSet {
            if location != nil {
                geocodeAddress()
            }
        }
    }
    var coordinate: CLLocationCoordinate2D?
    var objectId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        objectId = ProfileManager.shared.objectId
        roundCorners(finishButton)
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
        let geoCoder = CLGeocoder()
        guard let location = location else { return }
        geoCoder.geocodeAddressString(location, completionHandler: { (placemarks, error) -> Void in
            if let placemark = placemarks?.first, let location = placemark.location {
                self.coordinate = location.coordinate
                
                let mark = MKPlacemark(placemark: placemark)
                var region = self.mapView.region
                region.center = location.coordinate
                region.span.longitudeDelta /= 200
                region.span.latitudeDelta /= 200
                self.mapView.setRegion(region, animated: true)
                self.mapView.addAnnotation(mark)
            }
        })
    }
    
    func roundCorners(_ item: UIView) {
        item.layer.masksToBounds = true
        item.layer.cornerRadius = 5.0
    }
    
    func presentErrorAlert(_ message: String = "There was a problem performing that action.") {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
