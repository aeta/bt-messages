//
//  Alerts.swift
//  Consequat
//
//  Created by Alan Chu on 12/26/15.
//  Copyright © 2015 Team Auxiliary. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func showError(_ message: String) {
        let title = "Error"
        let alertButton = "OK"
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertView.addAction(UIAlertAction(title: alertButton, style: .default, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }
    
    func showFatalError(_ message: String) {
        let title = "Fatal Error"
        let alertButton = "OK"
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertView.addAction(UIAlertAction(title: alertButton, style: .destructive, handler: nil))
        self.present(alertView, animated: true, completion: nil)
    }
    
}
