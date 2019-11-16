//
//  AppDelegate.swift
//  MusicalJournal
//
//  Created by Philip Tam on 2019-11-15.
//  Copyright © 2019 musicaljournal. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
   var window: UIWindow?
   lazy var rootViewController = UINavigationController()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
            let window = UIWindow(frame: UIScreen.main.bounds)
            self.window = window
            let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            self.rootViewController = mainstoryboard.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
            window.rootViewController = rootViewController
        
        return true
    }

   func applicationWillResignActive(_ application: UIApplication) {
    if (SpotifyManager.shared.appRemote.isConnected) {
            SpotifyManager.shared.appRemote.disconnect()
        }
   }

   func applicationDidBecomeActive(_ application: UIApplication) {
       if let _ = SpotifyManager.shared.appRemote.connectionParameters.accessToken {
           SpotifyManager.shared.appRemote.connect()
       }
   }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let parameters = SpotifyManager.shared.appRemote.authorizationParameters(from: url);

        if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
            SpotifyManager.shared.appRemote.connectionParameters.accessToken = access_token
            SpotifyManager.shared.accessToken = access_token
        } else if let error_description = parameters?[SPTAppRemoteErrorDescriptionKey] {
            print(error_description)
        }
        return true
    }

}