//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Alec O'Connor on 11/30/17.
//  Copyright © 2017 Alec O'Connor. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    // Login View
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    // Loading View
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    
    // MARK: View Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        verifyUserIsLoggedIn()
    }
    
    func setUpView() {
        roundCorners(loginButton)
        displayLoadingView(false)
    }
    
    func roundCorners(_ item: UIView) {
        item.layer.masksToBounds = true
        item.layer.cornerRadius = 5.0
    }
    
    // MARK: Profile
    
    func verifyUserIsLoggedIn() {
        if isUserLoggedIn() {
            presentMainView()
        }
    }
    
    func isUserLoggedIn() -> Bool {
        return ProfileManager.shared.profile != nil
    }
    
    func attemptLogin() {
        guard let email = emailTextField.text, !email.isEmpty,
            let password = passwordTextField.text, !password.isEmpty else {
                presentErrorAlert("Empty Email or Password")
                return
        }
        displayLoadingView(true)
        enableForm(false)
        ProfileManager.shared.login(email: email, password: password) { (success) in
            self.displayLoadingView(false)
            self.enableForm(true)
            if success {
                self.presentMainView()
            } else {
                self.presentErrorAlert("Unable to login, please try again")
            }
        }
    }
    
    
    // MARK: View Actions
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        attemptLogin()
    }
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        let signUpURL = URL(string: "https://www.udacity.com/account/auth#!/signup")!
        UIApplication.shared.open(signUpURL, options: [:], completionHandler: nil)
    }
    
    func presentMainView() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let tabBarViewController = storyboard.instantiateViewController(withIdentifier: "tabBarControllerID") as! UITabBarController
            self.present(tabBarViewController, animated: true)
            self.emailTextField.text = ""
            self.passwordTextField.text = ""
        }
    }
    
    
    // MARK: Helper Functions
    
    func enableForm(_ isEnabled: Bool) {
        DispatchQueue.main.async {
            self.emailTextField.isEnabled = isEnabled
            self.passwordTextField.isEnabled = isEnabled
            self.loginButton.isEnabled = isEnabled
            self.signUpButton.isEnabled = isEnabled
        }
    }
    
    func displayLoadingView(_ isLoading: Bool) {
        DispatchQueue.main.async {
            self.loadingView.isHidden = !isLoading
            if isLoading {
                self.loadingActivityIndicator.startAnimating()
            } else {
                self.loadingActivityIndicator.stopAnimating()
            }
        }
    }
    
    func presentErrorAlert(_ message: String = "There was a problem performing that action.") {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }

}
