//
//  AppDelegate.swift
//  Outstagram
//
//  Created by Beavean on 09.01.2023.
//

import UIKit
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        window?.overrideUserInterfaceStyle = .light
        window?.backgroundColor = .systemBackground
//        window?.rootViewController = UINavigationController(rootViewController: MainTabController())
        window?.rootViewController = MainTabViewController()
        return true
    }
}
