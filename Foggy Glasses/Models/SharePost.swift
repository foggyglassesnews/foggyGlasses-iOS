//
//  SharePost.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/6/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit

struct SharePost {
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
    
    static func mockFeed() -> [SharePost] {
        let articleOne = Article(id: "1", data: ["title":"Denver is so expensive that teachers have to get creative to make ends meet",
                                                 "link":"https://www.cnn.com/2019/02/10/us/denver-teacher-strike-multiple-jobs/index.html",
                                                 "image": UIImage(named: "Image1")])
        let groupOne = FoggyGroup(id: "1", data: ["name":"Group 1"])
        let senderOne = FoggyUser(data: ["name":"you", "username":"emma123"])
        let oneData: [String: Any] = ["groupId":"1",
                                      "article":articleOne,
                                      "group":groupOne,
                                      "sender":senderOne,
                                      "comments":3]
        let one = SharePost(id: "1", data: oneData)
        
        let articleTwo = Article(id: "2", data: ["title":"Lawyer for National Enquirer's CEO denies the tabloid extorted Jeff Bezos",
                                                 "link":"https://www.cnn.com/2019/02/10/media/national-enquirer-david-pecker-attorney-jeff-bezos/index.html",
                                                 "image": UIImage(named: "Image2")])
        let senderTwo = FoggyUser(data: ["name":"Camille", "username":"emma123"])
        let twoData: [String: Any] = ["groupId":"1",
                                      "article":articleTwo,
                                      "sender":senderTwo,
                                      "comments":1]
        let two = SharePost(id: "2", data: twoData)
        return [one, two]
    }
}
