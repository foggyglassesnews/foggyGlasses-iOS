//
//  MultiGroupSharePost.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 3/23/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit

class MultiGroupSharePost: SharePost {
    var groupIds = [String]()
    var groupData = [String: String]()
    
    override init(id: String, data: [String: Any]) {
        let groupsData = data["data"] as? [String: String] ?? [:]
        self.groupData = groupsData
        
        for g in groupsData {
            groupIds.append(g.key)
        }
        
        super.init(id: id, data: data)
        self.id = id
        senderId = data["senderId"] as? String ?? ""
        articleId = data["articleId"] as? String ?? ""
        let secondsFrom1970 = data["timestamp"] as? Double ?? 0
        timestamp = Date(timeIntervalSince1970: secondsFrom1970)
        curated = data["curated"] as? Bool ?? false
    }
}
