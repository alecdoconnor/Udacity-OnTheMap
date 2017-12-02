//
//  UIViewControllerExtension.swift
//  OnTheMap
//
//  Created by Alec O'Connor on 12/2/17.
//  Copyright © 2017 Alec O'Connor. All rights reserved.
//

import UIKit

extension UIViewController {
    
    // MARK: View Functions
    
    func presentErrorAlert(_ message: String = "There was a problem performing that action.") {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func roundCorners(_ item: UIView) {
        item.layer.masksToBounds = true
        item.layer.cornerRadius = 5.0
    }
}
