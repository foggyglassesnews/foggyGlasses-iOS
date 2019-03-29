//
//  FoggyUser.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/9/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation

struct FoggyUser {
    var uid: String
    var name: String
    var email: String?
    var username: String
    var friends: [String]
    init(key: String, data: [String: Any]) {
        uid = key
        if let firstName = data["firstName"] as? String, let lastName = data["lastName"] as? String {
            name = firstName + " " + lastName
        } else {
            name = ""
        }
//        name = data["name"] as? String ?? "User"
        username = data["userName"] as? String ?? "Username"
        friends = data["friends"] as? [String] ?? []
    }
    
    static func createMockUsers()->[FoggyUser] {
//        let user1 = FoggyUser(iddata: ["name":"Emma", "username":"emma123"])
//        let user2 = FoggyUser(data: ["name":"John", "username":"johnny123"])
//        let user3 = FoggyUser(data: ["name":"Thomas", "username":"tommy1"])
        return []
    }
}
