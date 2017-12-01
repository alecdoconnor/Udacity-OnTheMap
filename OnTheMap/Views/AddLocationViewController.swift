//
//  AddLocationViewController.swift
//  OnTheMap
//
//  Created by Alec O'Connor on 11/30/17.
//  Copyright © 2017 Alec O'Connor. All rights reserved.
//

import UIKit

class AddLocationViewController: UIViewController {

    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var locationButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fillTextFieldValues()
        roundCorners(locationButton)
        setUpNavigationBarButtons()
    }

    @IBAction func locationButtonPressed(_ sender: Any) {
        findLocation()
    }
    
    func setUpNavigationBarButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "CANCEL", style: .done, target: self, action: #selector(dismissView))
    }
    
    @objc func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func fillTextFieldValues() {
        locationTextField.text = ProfileManager.shared.locationString ?? ""
        websiteTextField.text = ProfileManager.shared.websiteString ?? ""
    }
    
    func findLocation() {
        guard let location = locationTextField.text,
            let website = websiteTextField.text,
            !location.isEmpty && !website.isEmpty else {
            presentErrorAlert("Enter both a location and a website")
            return
        }
        guard let _ = URL(string: website) else {
            presentErrorAlert("Enter a valid URL")
            return
        }
        performSegue(withIdentifier: "AddLocationMapViewController", sender: self)
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
    
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mapViewController = segue.destination as? AddLocationMapViewController {
            mapViewController.website = websiteTextField?.text ?? ""
            mapViewController.location = locationTextField?.text ?? ""
        }
    }
}
