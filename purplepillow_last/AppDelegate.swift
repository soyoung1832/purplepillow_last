//
//  AppDelegate.swift
//  purplepillow_last
//
//  Created by kim yeon kyung on 2023/08/08.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
    
        if UserDefaults.standard.bool(forKey: "isLoggedIn") {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let mainVC = storyboard.instantiateInitialViewController() {
                mainVC.modalPresentationStyle = .fullScreen
                window?.rootViewController = mainVC
            
                Unity.shared.setHostMainWindow(window)
            }
            
        }
        
        return true
    }


        // MARK: UISceneSession Lifecycle

        func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
            return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

