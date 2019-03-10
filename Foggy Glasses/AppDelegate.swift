//
//  AppDelegate.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 1/27/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit
import Firebase
import SideMenu
import FacebookLogin
import FacebookCore
import Fabric

var sharedGroup = "group.posttogroups.foggyglassesnews.com"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        FirebaseApp.configure()
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
                
        Fabric.sharedSDK().debug = true
        
        //Check to see if signed in or not
        if let user = Auth.auth().currentUser {
            FirebaseManager.global.getFriends()
            
            let facebook: String? = "facebook.com"
            if user.providerData.first?.providerID == facebook {
                let feed = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
                let nav = UINavigationController(rootViewController: feed)
                self.window = UIWindow()
                self.window?.rootViewController = nav
            } else {
                if !user.isEmailVerified {
                    let valid = EmailVerificationController()
                    let nav = UINavigationController(rootViewController: valid)
                    self.window = UIWindow()
                    self.window?.rootViewController = nav
                } else {
                    let feed = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
                    let nav = UINavigationController(rootViewController: feed)
                    self.window = UIWindow()
                    self.window?.rootViewController = nav
                }
            }
            
        } else {
            let join = WelcomeController()
            let nav = UINavigationController(rootViewController: join)
            self.window = UIWindow()
            self.window?.rootViewController = nav
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

   
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if let scheme = url.scheme,
            scheme.localizedCaseInsensitiveCompare("createGroup") == .orderedSame,
            let view = url.host {
            
            var parameters: [String: String] = [:]
            URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {
                parameters[$0.name] = $0.value
            }
            print(parameters)
            redirect(parameters: parameters)
            return true
//            redirect(to: view, with: parameters)
        }
        return SDKApplicationDelegate.shared.application(app, open: url, options: options)
    }
    
    func redirect(parameters: [String: String]){
        if let link = parameters["link"] {
            print("Link")
            let quickshare = QuickshareController(collectionViewLayout: UICollectionViewFlowLayout())
            let article = Article(id: link, data: ["url": link])
            globalSelectedSavedArticle = article
            NotificationCenter.default.post(name: FeedController.openGroupCreate, object: nil)
//            self.window?.rootViewController?.present(quickshare, animated: true, completion: nil)
//                .navigationController?.pushViewController(), animated: true)
        }
    }
    
    @objc func openURL(_ url: URL) -> Bool {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                return application.perform(#selector(openURL(_:)), with: url) != nil
            }
            responder = responder?.next
        }
        return false
    }
    
}

