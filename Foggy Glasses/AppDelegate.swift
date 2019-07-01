//
//  AppDelegate.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 1/27/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SideMenu

import FacebookCore
//import FacebookLogin
import FirebaseMessaging
import FBSDKCoreKit
import FBSDKLoginKit
import UserNotifications
import Fabric
import SwiftyDrop

var sharedGroup = "group.posttogroups.foggyglassesnews.com"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    //Necessary for displaying deeplink content
    var mainNav: UINavigationController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        FirebaseApp.configure()
        
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
                
        Fabric.sharedSDK().debug = true
        
        Messaging.messaging().delegate = self
        
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        UNUserNotificationCenter.current().delegate = self
        UIApplication.shared.applicationIconBadgeNumber = 0
        
//        if #available(iOS 10.0, *) {
//            // For iOS 10 display notification (sent via APNS)
//
//            UNUserNotificationCenter.current().delegate = self
//
//            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//            UNUserNotificationCenter.current().requestAuthorization(
//                options: authOptions,
//                completionHandler: {_, _ in })
//        } else {
//            let settings: UIUserNotificationSettings =
//                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
//            application.registerUserNotificationSettings(settings)
//        }
//
//        application.registerForRemoteNotifications()
        
        //Check to see if signed in or not
        if let _ = Auth.auth().currentUser {
            FirebaseManager.global.getCurrentUser()
            FirebaseManager.global.getFriends()
            let feed = FeedController(collectionViewLayout: UICollectionViewFlowLayout())
            let nav = UINavigationController(rootViewController: feed)
            mainNav = nav
            self.window = UIWindow()
            self.window?.rootViewController = nav
            
        } else {
            let join = WelcomeController()
            let nav = UINavigationController(rootViewController: join)
            mainNav = nav
            self.window = UIWindow()
            self.window?.rootViewController = nav
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        Messaging.messaging().apnsToken = deviceToken//deviceToken.map { String(format: "%02.2hhx", $0) }.joined()//deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

   
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if let scheme = url.scheme, scheme.localizedCaseInsensitiveCompare("createGroup") == .orderedSame, let _ = url.host {
            
            var parameters: [String: String] = [:]
            URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.forEach {
                parameters[$0.name] = $0.value
            }
            print(parameters)
            redirect(parameters: parameters)
            return true
        }
        
        if DynamicLinks.dynamicLinks().shouldHandleDynamicLink(fromCustomSchemeURL: url) {
            let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url)
            return handleDynamicLink(dynamicLink)
        }
        
        return SDKApplicationDelegate.shared.application(app, open: url, options: options)
    }
    
    func handleDynamicLink(_ dynamicLink: DynamicLink?) -> Bool {
        guard let dynamicLink = dynamicLink else { return false }
        guard let deepLink = dynamicLink.url else { return false }
        let queryItems = URLComponents(url: deepLink, resolvingAgainstBaseURL: true)?.queryItems
        guard let invitedByIdGroupId = queryItems?.filter({(item) in item.name == "invitedByIdGroupId"}).first?.value else { return false }
        
        var invitedBy: String!
        var groupId: String!
        for (idx, component) in invitedByIdGroupId.components(separatedBy: "-").enumerated() {
            if idx == 0 {
                invitedBy = component
            } else {
                groupId = component
            }
        }
        
        if dynamicLink.matchType == .weak {
            // If the Dynamic Link has a weak match confidence, it is possible
            // that the current device isn't the same device on which the invitation
            // link was originally opened. The way you handle this situation
            // depends on your app, but in general, you should avoid exposing
            // personal information, such as the referrer's email address, to
            // the user.
        } else {
            print("Setting Defaults:", invitedBy, groupId)
            UserDefaults.standard.set(invitedBy, forKey: "invitedby")
            UserDefaults.standard.set(groupId, forKey: "groupId")
        }
        
        
        return true
    }
    
    func redirect(parameters: [String: String]){
        let link = parameters["link"] ?? ""
        let article = Article(id: link, data: ["url": link])
        globalSelectedSavedArticle = article
        
        let quickshare = CreateGroupController(collectionViewLayout: UICollectionViewFlowLayout())
        quickshare.isFromExtensionQuickshare = true
        if let mainNav = mainNav {
            mainNav.pushViewController(quickshare, animated: true)
        } else {
            print("Main Nav nil")
            DeepLinkManager.shared.openCreateGroupFromExtension = true
        }
//        mainNav?.pushViewController(quickshare, animated: true)
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
    
    private func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
            // ...
        }
        
        return handled
    }
    
}

extension AppDelegate: MessagingDelegate{
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("FCM Token", fcmToken)
        FirebaseManager.global.updateToken(token: fcmToken)
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Recieved remote", remoteMessage.appData)
    }
}


extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("Will present remote notification")
        
        print("Notification", notification)
        if let dict = userInfo["aps"] as? [String: Any], let alert = dict["alert"] as? [String: String] {
            print(dict)
            if let body = alert["body"] {
                Drop.down(body, state: .default, duration: 3) {
                    self.handleData(userInfo: userInfo)
                }
            }
            
//            if let badgeCount = dict["badge"] as? Int {
//                UIApplication.shared.applicationIconBadgeNumber += badgeCount
//            }
            
        }
        
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
//        if let messageID = userInfo[gcmMessageIDKey] {
//            print("Message ID: \(messageID)")
//        }
        print("USER CLICKED TO NOTIFICATION")
        
        //RESET BADGE WHEN NOTIFICATION OPENED
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        print("Response", response)
        print(userInfo)
        
        self.handleData(userInfo: userInfo)
        
        completionHandler()
    }
    
    func handleData(userInfo: [AnyHashable: Any]) {
        if let articleId = userInfo["articleId"] as? String, let groupId = userInfo["groupId"] as? String {
            
            //Handle presenting article view
            FirebaseManager.global.getPost(postId: articleId, groupId: groupId) { (pst) in
                let article = ArticleController(collectionViewLayout: UICollectionViewFlowLayout())
                article.post = pst
                
                //Clears the notification for this post comments
                NotificationManager.shared.openedComments(groupId: pst.groupId ?? "", postId: pst.id)
                
                DispatchQueue.main.async {
                    self.mainNav?.pushViewController(article, animated: true)
                }
            }
        } else if let groupId = userInfo["groupId"] as? String {
            
            //Handle presenting join group
            FirebaseManager.global.getGroup(groupId: groupId, completion: { (group) in
                DispatchQueue.main.async {
                    let feed = PendingGroupController()
                    feed.groupFeed = group
                    self.mainNav?.pushViewController(feed, animated: true)
                }
            })
        }
    }
    
    
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
//                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        // If you are receiving a notification message while your app is in the background,
//        // this callback will not be fired till the user taps on the notification launching the application.
//        // TODO: Handle data of notification
//        // With swizzling disabled you must let Messaging know about the message, for Analytics
//        // Messaging.messaging().appDidReceiveMessage(userInfo)
//        // Print message ID.
////        if let messageID = userInfo[gcmMessageIDKey] {
////            print("Message ID: \(messageID)")
////        }
//        print("DID RECEIVE REMOTE NOTIFICATION WITH HANDLER")
//        // Print full message.
//        print(userInfo)
//
////        if let aps = userInfo["aps"] as? NSDictionary{
////            handleBadgeCount(userInfo: aps)
////        }
//
//
////        handleData(userInfo: userInfo)
//
//        if let dict = userInfo["aps"] as? [String: Any], let alert = dict["alert"] as? [String: String] {
//            if let body = alert["body"], let title = alert["title"] {
//                Drop.down(body, state: .default, duration: 2) {
//                    self.handleData(userInfo: userInfo)
//                }
//            }
//        }
//        completionHandler(UIBackgroundFetchResult.newData)
//    }
    
    
    
}
