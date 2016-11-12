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
    func showError(message: String) {
        let title = "Error"
        let alertButton = "OK"
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        alertView.addAction(UIAlertAction(title: alertButton, style: .Default, handler: nil))
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
    func showFatalError(message: String) {
        let title = "Fatal Error"
        let alertButton = "OK"
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        alertView.addAction(UIAlertAction(title: alertButton, style: .Destructive, handler: nil))
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
}