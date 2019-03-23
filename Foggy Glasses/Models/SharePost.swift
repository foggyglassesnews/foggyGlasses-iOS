//
//  SharePost.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/6/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit

class SharePost {
    var id: String
    var senderId: String
    var articleId: String
    var timestamp: Date
    
    var groupId: String?
    var recieptientId: String?
    
    var sender: FoggyUser?
    var article: Article?
    var group: FoggyGroup?
    
    var comments: Int = 0
    
    init(id: String, data: [String: Any]) {
        self.id = id
        senderId = data["senderId"] as? String ?? ""
        articleId = data["articleId"] as? String ?? ""
        let secondsFrom1970 = data["timestamp"] as? Double ?? 0
        timestamp = Date(timeIntervalSince1970: secondsFrom1970)
        groupId = data["groupId"] as? String
        comments = data["commentCount"] as? Int ?? 0
    }
    
    func getPost(homeFeedPost: HomeFeedPost, completion: @escaping (SharePost)->()){
        
    }
    
    static func mockFeed() -> [SharePost] {
        return []
    }
}
