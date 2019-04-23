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
    private var isPostsUpdating = false
    private var isCommentUpdating = false
    
    ///Used for Group new posts lookup
    private var groupSyncDictionary = [String: Double]() {
        didSet {
//            print("Fetched Groups with Synced At \(groupSyncDictionary.count)")
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
    func getUserData() {
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
//        print("DEBUG: Update Group \(groupId) Synced At \(syncedAt)")
    }
    
    ///Helper function returning groups lastSyncedAt
    func getGroupSyncedAt(groupId: String)->Double {
        let groupSyncedAt = groupSyncDictionary[groupId] ?? Date().timeIntervalSince1970
//        print("DEBUG: Got Group \(groupId) Synced At ", groupSyncedAt)
        return groupSyncedAt
    }
    
    ///Main update function, call this preferrably in ViewWillAppear of FeedController
    func update() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if !isUpdating {
            isUpdating = true
            print("DEBUG: Notification Manager Update Begin")
            FirebaseManager.global.getGroups(uid: uid) { (groupData) in
                if let data = groupData {
                    if let groups = data["groups"] {
                        print("DEBUG: Notification Manager Update Recieved \(groups.count) groups")
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
//        print("DEBUG: Fetching feed \(feedId) data \(lastSyncedAt)")
        FirebaseManager.global.fetchPostsAfterSyncedAt(feedId: feedId, syncedAt: lastSyncedAt) { (postsDictionary) in
            FirebaseManager.global.fetchCommentsAfterSyncedAt(feedId: feedId, syncedAt: lastSyncedAt, completion: { (commentsDictionary) in
//                print("DEBUG: Recieved \(postsDictionary.count) posts, \(commentsDictionary.count) comments for \(feedId)")
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
        if data.isEmpty {
            return
        }
        
        if var prev = postData[groupId] {
            prev.merge(data, uniquingKeysWith: { (_, first) in first })
            postData[groupId] = prev
        } else {
            postData[groupId] = data
        }
        
        
        let postsKey = uid + "-postData"
        //Update default
        defaults.set(postData, forKey: postsKey)
        defaults.synchronize()
//        print("Synchronized \(postsKey) \with postData \(postData.count)")
    }
    
    ///Helper function updating local data with new data
    private func updateCommentData(groupId: String, data: [String: Bool]) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if data.isEmpty {
            return
        }
        
        if var prev = commentData[groupId] {
            prev.merge(data, uniquingKeysWith: { (_, first) in first })
            commentData[groupId] = prev
        } else {
            commentData[groupId] = data
        }
        
        let commentsKey = uid + "-commentData"
        //Update default
        defaults.set(commentData, forKey: commentsKey)
        defaults.synchronize()
        
        //Update Collection View
//        NotificationCenter.default.post(name: FeedController.newNotificationData, object: nil)
//        print("Synchronized \(commentsKey) with commentData \(commentData.count)")
    }
}

///Public API
extension NotificationManager {
    ///Checks if Group has any unseen posts
    func hasNotification(groupId: String)->Bool{
        if let postsDictionary = postData[groupId] {
            //iterate through all posts, if one is true then there is pending!
            for p in postsDictionary {
                if p.value {
                    return true
                }
            }
            
            //Then iterate through all comments, if one is true then there is pending!
            if let commentDictionary = commentData[groupId] {
                for c in commentDictionary {
                    if c.value {
                        return true
                    }
                }
            } else {
                return false
            }
            
            //None returned true so their is no pending
            return false
        } else {
            return false
        }
    }
    
    ///Check if post has any unseen comments
    func hasNotification(groupId: String, postId: String)->Bool{
//        print("DEBUG: Checking for notification: ", groupId)
        if let postsDictionary = commentData[groupId] {
            if let hasNotification = postsDictionary[postId] {
                return hasNotification
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    ///Removes TRUE from unseen notifications
    func seen(groupId: String, postId: String) {
        self.updatePostData(groupId: groupId, data: [postId: false])
    }
    
    ///Triggered when they opened comments
    func openedComments(groupId: String, postId: String) {
        self.updateCommentData(groupId: groupId, data: [postId: false])
    }
    
    ///Call when adding a new comment
    func updateAfterNewComment(groupId: String, postId: String, completion: @escaping ()->()){
        if !isCommentUpdating {
            isCommentUpdating = true
            let groupSyncedAt = self.getGroupSyncedAt(groupId: groupId)
            FirebaseManager.global.fetchCommentsAfterSyncedAt(feedId: groupId, syncedAt: groupSyncedAt) { (commentsDictionary) in
                
                //Update the post value to be seen
                var updatedCommentsDictionary = commentsDictionary
                updatedCommentsDictionary[postId] = false
                
                self.updateCommentData(groupId: groupId, data: updatedCommentsDictionary)
                self.updateGroupSyncedAt(groupId: groupId)
                self.isCommentUpdating = false
                completion()
            }
        }
    }
    
    ///Call when sharing a new post
    func updateAterNewPost(groupId: String, postId: String, completion: @escaping () -> ()) {
        if !isPostsUpdating {
            isPostsUpdating = true
            let groupSyncedAt = self.getGroupSyncedAt(groupId: groupId)
            FirebaseManager.global.fetchPostsAfterSyncedAt(feedId: groupId, syncedAt: groupSyncedAt) { (postDictionary) in
                
                //Update the post value to be seen
                var updatedPostsDictionary = postDictionary
                updatedPostsDictionary[postId] = false
                
                self.updatePostData(groupId: groupId, data: updatedPostsDictionary)
                self.updateGroupSyncedAt(groupId: groupId)
                self.isPostsUpdating = false
                completion()
            }
        }
    }
}
