//
//  SharePost.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/6/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation

struct SharePost {
    var id: String
    var senderId: String
    var articleId: String
    var timestamp: Date
    
    var groupId: String?
    var recieptientId: String?
    var article: Article?
    
    var comments: Int = 0
    init(id: String, data: [String: Any]) {
        self.id = id
        senderId = ""
        articleId = ""
        timestamp = Date()
    }
}
