//
//  AppDelegate.swift
//  bt-messages
//
//  Created by alanchu on 5/21/16.
//  Copyright © 2016 Team Auxiliary. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mcManager: MCManager!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        mcManager = MCManager()
        mcManager.setupPeerAndSessionWithDisplayName(UIDevice.current.name)
        mcManager.advertiseSelf(true)

        return true
    }

}

