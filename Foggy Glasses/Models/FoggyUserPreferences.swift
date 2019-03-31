//
//  FoggyUserPreferences.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 3/23/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation

class FoggyUserPreferences {
    static let shared = FoggyUserPreferences()
    var notificationsEnabled = false
    var groupInvites = false
    
    var user: FoggyUser? {
        didSet {
            FirebaseManager.global.getUserPreferences(uid: user?.uid ?? "")
        }
    }
}
