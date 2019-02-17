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
    
    static func mockGroups()->[FoggyGroup] {
        let group1 = FoggyGroup(id: "1", data: ["name":"Family"])
        let group2 = FoggyGroup(id: "2", data: ["name":"Squad"])
        let group3 = FoggyGroup(id: "3", data: ["name":"School Friends"])
        let group4 = FoggyGroup(id: "4", data: ["name":"Gym Buddies"])
        return [group1, group2, group3, group4]
    }
}
