//
//  FeedHideManager.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 3/20/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

class FeedHideManager {
    static let global = FeedHideManager()
    
    private var userKey: String?
    private var hiddenPosts = [String](){
        didSet {
            updateUserData()
        }
    }//[String:Bool]()
    
    private init() {
        getUserData()
    }
    
    //Called when user signs out
    func refreshUser() {
        getUserData()
    }
    
    private func getUserData() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("No current user id.")
            return }
        let defaults = UserDefaults.standard
        userKey = uid + "-hiddenPosts"
        hiddenPosts = defaults.stringArray(forKey: userKey!) ?? [String]()
    }
    
    private func updateUserData() {
        let defaults = UserDefaults.standard
        if let userKey = userKey {
            defaults.set(hiddenPosts, forKey: userKey)
        }
    }
    
    //Method for hiding
    func hide(id: String) {
        for (idx, post) in hiddenPosts.enumerated() {
            if post == id {
                hiddenPosts.remove(at: idx)
                return
            }
        }
        hiddenPosts.append(id)
        
//        if let hidden = hiddenPosts[id] {
//            hiddenPosts[id] = !hidden
//        } else {
//            hiddenPosts[id] = true
//        }
    }
    
    func isHidden(id: String)->Bool {
        for post in hiddenPosts {
            if post == id {
                return true
            }
        }
//        if let hidden = hiddenPosts[id] {
//            return hidden
//        }
        return false
    }
}
