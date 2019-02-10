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
    var link: String
    var thumbnail: UIImage?
    
    init(id: String, data: [String: Any]){
        self.id = id
        title = data["title"] as? String ?? ""
        link = data["link"] as? String ?? ""
        thumbnail = data["image"] as? UIImage
    }
}
