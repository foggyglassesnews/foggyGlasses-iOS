//
//  HomeFeedPost.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 3/6/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation

struct HomeFeedPost {
    var id: String
    var feedId: String
    var timestamp: Date
    var postId: String
    init(key: String, data: [String: Any]) {
        id = key
        feedId = data["feedId"] as! String
        let seconds = data["timestamp"] as? Double ?? 0
        timestamp = Date(timeIntervalSince1970: seconds)
        postId = data["postId"] as! String
    }
}
