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
        setUpTextFields()
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
    
    func setUpTextFields() {
        for textfield in [locationTextField, websiteTextField] {
            textfield?.delegate = self
        }
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
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mapViewController = segue.destination as? AddLocationMapViewController {
            mapViewController.website = websiteTextField?.text ?? ""
            mapViewController.location = locationTextField?.text ?? ""
        }
    }
}
extension AddLocationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
