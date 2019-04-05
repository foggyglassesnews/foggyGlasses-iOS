//
//  NotificationManager.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 4/5/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class NotificationManager {
    static let shared = NotificationManager()
    private let defaults = UserDefaults.standard
    
    //Type Defs for readability
    typealias GroupId = String
    typealias PostId = String
    typealias HasNotification = Bool
    
    ///Only have one update operation going at once.
    private var isUpdating = false
    
    ///Used for Group new posts lookup
    private var groupSyncDictionary = [String: Double]() {
        didSet {
            print("Fetched Groups with Synced At \(groupSyncDictionary.count)")
        }
    }
    
    ///Post Data to determine if Group Has New Posts
    private var postData = [GroupId: [PostId: HasNotification]]()
    
    ///Comment Data to determine if Post has new comments
    private var commentData = [GroupId: [PostId: HasNotification]]()
    
    private init() {
        getUserData()
    }
    
    ///Gets user data from UserDefaults
    private func getUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let userGroupSyncKey = uid + "-groupSync"
        groupSyncDictionary = defaults.dictionary(forKey: userGroupSyncKey) as? [String: Double] ?? [:]
        
        let postsKey = uid + "-postData"
        postData = defaults.dictionary(forKey: postsKey) as? [GroupId: [PostId: HasNotification]] ?? [:]
        print("User Post Data: ", postData.count)
        
        let commentsKey = uid + "-commentData"
        commentData = defaults.dictionary(forKey: commentsKey) as? [GroupId: [PostId: HasNotification]] ?? [:]
        print("User Comment Data: ", commentData.count)
    }
    
    ///Helper function updating group lastSyncedAt
    func updateGroupSyncedAt(groupId: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        //Update local data
        let syncedAt = Date().timeIntervalSince1970
        groupSyncDictionary[groupId] = syncedAt
        
        let userGroupSyncKey = uid + "-groupSync"
        defaults.set(groupSyncDictionary, forKey: userGroupSyncKey)
        defaults.synchronize()
        print("Update Group \(groupId) Synced At \(syncedAt)")
    }
    
    ///Helper function returning groups lastSyncedAt
    func getGroupSyncedAt(groupId: String)->Double {
        let groupSyncedAt = groupSyncDictionary[groupId] ?? 0
        print("Got Group \(groupId) Synced At ", groupSyncedAt)
        return groupSyncedAt
    }
    
    ///Main update function, call this preferrably in ViewWillAppear of FeedController
    func update() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if !isUpdating {
            isUpdating = true
            print("Notification Manager Update Begin")
            FirebaseManager.global.getGroups(uid: uid) { (groupData) in
                if let data = groupData {
                    if let groups = data["groups"] {
                        print("Notification Manager Update Recieved \(groups.count) groups")
                        for group in groups {
                            let groupSyncedAt = self.getGroupSyncedAt(groupId: group.id)
                            self.fetchData(feedId: group.id, lastSyncedAt: groupSyncedAt)
                        }
                        self.isUpdating = false
                    }
                }
            }
        }
    }
    
    ///Fetch all new data for a group
    private func fetchData(feedId: String, lastSyncedAt: Double) {
        //Get all posts/comments
        //Update local data
        //Update Group Synced At + Save to defaults
        print("Fetching \(feedId) data \(lastSyncedAt)")
        FirebaseManager.global.fetchPostsAfterSyncedAt(feedId: feedId, syncedAt: lastSyncedAt) { (postsDictionary) in
            FirebaseManager.global.fetchCommentsAfterSyncedAt(feedId: feedId, syncedAt: lastSyncedAt, completion: { (commentsDictionary) in
                print("Recieved \(postsDictionary.count) posts, \(commentsDictionary.count) comments for \(feedId)")
                self.updatePostData(groupId: feedId, data: postsDictionary)
                self.updateCommentData(groupId: feedId, data: commentsDictionary)
                self.updateGroupSyncedAt(groupId: feedId)
            })
        }
    }
    
    ///Helper function updating local data with new data
    private func updatePostData(groupId: String, data: [String: Bool]) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        //Set local data
        postData[groupId] = data
        
        let postsKey = uid + "-postData"
        //Update default
        defaults.set(postData, forKey: postsKey)
        defaults.synchronize()
        print("Synchronized \(postsKey) with postData \(postData.count)")
    }
    
    ///Helper function updating local data with new data
    private func updateCommentData(groupId: String, data: [String: Bool]) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        //Set local data
        commentData[groupId] = data
        
        let commentsKey = uid + "-commentData"
        //Update default
        defaults.set(commentData, forKey: commentsKey)
        defaults.synchronize()
        print("Synchronized \(commentsKey) with commentData \(commentData.count)")
    }
}
