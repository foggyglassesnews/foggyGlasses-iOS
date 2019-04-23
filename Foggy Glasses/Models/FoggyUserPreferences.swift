//
//  FoggyUserPreferences.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 3/23/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseMessaging

class FoggyUserPreferences {
    static let shared = FoggyUserPreferences()
    var notificationsEnabled = false
    
    var groupInvites = false {
        didSet {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let topic = "userPendingGroups-"+uid
            
            if groupInvites {
                Messaging.messaging().subscribe(toTopic: topic) { error in
                    print("Subscribed to topic", topic)
                }
            } else {
                Messaging.messaging().unsubscribe(fromTopic: topic) { error in
                    print("Unsubscribed from topic", topic)
                }
            }
        }
    }
    
    ///GroupID: Bool
    var newComment = [String: Bool]() {
        didSet{
            for x in newComment {
                let topic = "comment-"+x.key
                
                if x.value {
                    Messaging.messaging().subscribe(toTopic: topic) { error in
                        print("Subscribed to topic", topic)
                    }
                } else {
                    Messaging.messaging().unsubscribe(fromTopic: topic) { error in
                        print("Unsubscribed from topic", topic)
                    }
                }
            }
        }
    }
    var newArticles = [String: Bool]() {
        didSet {
            for x in newComment {
                let topic = "feed-"+x.key
                
                if x.value {
                    Messaging.messaging().subscribe(toTopic: topic) { error in
                        print("Subscribed to topic", topic)
                    }
                } else {
                    Messaging.messaging().unsubscribe(fromTopic: topic) { error in
                        print("Unsubscribed from topic", topic)
                    }
                }
            }
        }
    }
    
    var user: FoggyUser? {
        didSet {
            FirebaseManager.global.getUserPreferences(uid: user?.uid ?? "")
        }
    }
    
    ///Stores Group info
    private var groupData = [String: Int]() {
        didSet{
            print("Set Group Data", groupData)
        }
    }
}

//Extensiof for handing group data for loading screens
extension FoggyUserPreferences {
    
    private func pullData() {
        if let uid = Auth.auth().currentUser?.uid  {
            let shared = UserDefaults.standard
            if let data = shared.dictionary(forKey: "GroupData-"+uid) as? [String: Int] {
                print("Pulling Dat")
                groupData = data
            }
        }
    }
    
    func shouldShowEmptyGroupLoading(id: String)->Bool {
        if groupData.isEmpty {
            pullData()
        }
        if let value = groupData[id]{
            print("Got Group Value", value, id)
            if value == 0 {
                return true
            } else {
                return false
            }
        } else {
            print("Got nothing", id)
            return true
        }
    }
    
    func update(groupId: String, count: Int) {
        if let uid = Auth.auth().currentUser?.uid  {
            
            let shared = UserDefaults.standard
            if let initial = shared.object(forKey: "GroupData-"+uid) as? [String: Any] {
                
            } else {
                shared.set([String: Int](), forKey: "GroupData-"+uid)// dictionary(forKey: "GroupData-"+uid)
                shared.synchronize()
            }
            if var data = shared.dictionary(forKey: "GroupData-"+uid) as? [String: Int] {
                if var previousValue = data[groupId] {
                    previousValue += count
                    data[groupId] = previousValue
                    shared.set(data, forKey: "GroupData-"+uid)
                    shared.synchronize()
                } else {
                    data[groupId] = count
                    shared.set(data, forKey: "GroupData-"+uid)
                    shared.synchronize()
                }
                
            }
        }
    }
}
