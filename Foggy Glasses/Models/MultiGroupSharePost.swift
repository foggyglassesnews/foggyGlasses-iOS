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
    var groupIds: [String]
    
    override init(id: String, data: [String: Any]) {
        groupIds = data["groupIds"] as? [String] ?? []
        
        super.init(id: id, data: data)
        self.id = id
        senderId = data["senderId"] as? String ?? ""
        articleId = data["articleId"] as? String ?? ""
        let secondsFrom1970 = data["timestamp"] as? Double ?? 0
        timestamp = Date(timeIntervalSince1970: secondsFrom1970)
    }
}
