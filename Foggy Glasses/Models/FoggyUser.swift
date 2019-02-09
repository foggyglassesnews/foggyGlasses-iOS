//
//  FoggyUser.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/9/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation

struct FoggyUser {
    var name: String
    var username: String
    init(data: [String: Any]) {
        name = data["name"] as? String ?? "User"
        username = data["username"] as? String ?? "Username"
    }
    
    static func createMockUsers()->[FoggyUser] {
        let user1 = FoggyUser(data: ["name":"Emma", "username":"emma123"])
        let user2 = FoggyUser(data: ["name":"John", "username":"johnny123"])
        let user3 = FoggyUser(data: ["name":"Thomas", "username":"tommy1"])
        return [user1, user2, user3]
    }
}
