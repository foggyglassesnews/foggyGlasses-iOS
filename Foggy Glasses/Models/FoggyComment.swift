//
//  FoggyComment.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 3/12/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit

struct FoggyComment {
    var id: String
    var uid: String
    var text: String
    var timestamp: Date
    init(id:String, data:[String:Any]) {
        self.id = id
        self.uid = data["uid"] as? String ?? ""
        self.text = data["text"] as? String ?? ""
        let time = data["timestamp"] as? Double ?? 0
        self.timestamp = Date(timeIntervalSince1970: time)
    }
    
    static func fakeComments() -> [FoggyComment] {
        let one = FoggyComment(id: "one", data: [:])
        let two = FoggyComment(id: "two", data: [:])
        let three = FoggyComment(id: "3", data: [:])
        return [one, two, three]
    }
    
    
    func webData()->[String: Any] {
        return ["uid":uid,
                    "text": text,
                    "timestamp":timestamp.timeIntervalSince1970]
    }
}
