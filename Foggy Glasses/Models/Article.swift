//
//  Article.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/6/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import UIKit

struct Article {
    var id: String
    var title: String
    var description: String?
    var link: String
    var imageUrlString: String?
    var shareUserId: String?
    var canonicalUrl: String?
    
    init(id: String, data: [String: Any]){
        self.id = id
        title = data["title"] as? String ?? ""
        link = data["url"] as? String ?? ""
        description = data["description"] as? String
        imageUrlString = data["imageUrlString"] as? String
        shareUserId = data["shareUserId"] as? String
        canonicalUrl = data["canonicalUrl"] as? String
    }
    
    func webData()->[String: Any] {
        var data = ["title":title,
                    "url": link]
        if let desc = description {
            data["description"] = desc
        }
        if let image = imageUrlString {
            data["imageUrlString"] = image
        }
        if let uid = shareUserId {
            data["shareUserId"] = uid
        }
        if let canonical = canonicalUrl {
            data["canonicalUrl"] = canonical
        }
        return data
    }
}
