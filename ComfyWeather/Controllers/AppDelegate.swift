//
//  AppDelegate.swift
//  ComfyWeather
//
//  Created by Stephen Wong on 9/26/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import UIKit
import FacebookCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)

        ClothingCategoryRequest().fetchCategories()

        let frame = UIScreen.main.bounds
        window = UIWindow(frame: frame)

        let navigationViewController = UINavigationController(rootViewController: LoginViewController())

        window?.rootViewController = navigationViewController
        window?.makeKeyAndVisible()

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        AppEventsLogger.activate()

        if let _ = AccessToken.current {
            AccessToken.refreshCurrentToken()
        }
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return SDKApplicationDelegate.shared.application(app, open: url, options: options)
    }

}
