//
//  FoggyGroup.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/10/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation

struct FoggyGroup {
    var id: String?
    var name: String?
    var members:[FoggyUser]?
    init(id: String, data: [String: Any]) {
        self.id = id
        name = data["name"] as? String
    }
}
