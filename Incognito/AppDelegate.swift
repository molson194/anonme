//
//  AppDelegate.swift
//  Incognito
//
//  Created by Matthew Olson on 6/8/16.
//  Copyright © 2016 Molson. All rights reserved.
//

import UIKit
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        self.window = UIWindow()
        
        let parseConfiguration = ParseClientConfiguration { (ParseMutableClientConfiguration) in
            ParseMutableClientConfiguration.applicationId = "molsonINCOG1423"
            ParseMutableClientConfiguration.clientKey = "kingDUKEcheetah1029"
            ParseMutableClientConfiguration.server = "https://in-cog.herokuapp.com/parse"
        }
        
        Parse.initializeWithConfiguration(parseConfiguration)
        let rootView: UIViewController
        if PFUser.currentUser() != nil {
            rootView = MessagesViewController()
        } else {
            rootView = LoginViewController()
        }
        
        if let window = self.window {
            window.rootViewController = rootView
            window.makeKeyAndVisible()
        }
        
        return true
    }

}

