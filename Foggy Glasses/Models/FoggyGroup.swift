//
//  FoggyGroup.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/10/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

class FoggyGroup {
    var id: String!
    var friendGroup = false
    var name: String = "Foggy Group"
    var adminId: String
    var adminUsername: String
    var members:[FoggyUser]?
    var membersStringArray:[String]
    var curationCategories:[String]?
    var curationFrequency:Int?
    init(id: String, data: [String: Any]) {
        self.id = id
        friendGroup = data["friendGroup"] as? Bool ?? false
        name = data["name"] as? String ?? "Foggy Group"
        adminId = data["adminId"] as? String ?? ""
        adminUsername = data["adminUsername"] as? String ?? "Foggy User"
        membersStringArray = data["members"] as? [String] ?? []
        curationCategories = data["curationCategories"] as? [String] ?? []
        curationFrequency = data["curationFrequency"] as? Int ?? 3
    }
    
    static func mockGroups()->[FoggyGroup] {
        let group1 = FoggyGroup(id: "1", data: ["name":"Family"])
        let group2 = FoggyGroup(id: "2", data: ["name":"Squad"])
        let group3 = FoggyGroup(id: "3", data: ["name":"School Friends"])
        let group4 = FoggyGroup(id: "4", data: ["name":"Gym Buddies"])
        return [group1, group2, group3, group4]
    }
    
    func userDefaultData() -> [String: String] {
        return ["id": id,
                "name":name]
    }
    
    func getFriendName(completion: @escaping (String?)->()){
        if let uid = Auth.auth().currentUser?.uid {
            for id in membersStringArray{
                //Find other user id, not uid since there only 2 members
                if uid != id {
                    FirebaseManager.global.getFoggyUser(uid: id) { (user) in
                        completion(user?.name)
                    }
                }
            }
        } else {
            completion("Foggy Friend")
        }
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let id = aDecoder.decodeObject(forKey: "id") as! String
        let friendGroup = aDecoder.decodeBool(forKey: "friendGroup")
        let name = aDecoder.decodeObject(forKey: "name") as? String ?? "Foggy Group"
        let members = aDecoder.decodeObject(forKey: "members") as? [String] ?? []
        self.init(id: id, data: ["friendGroup": friendGroup, "name": name, "members": members])
    }
    
//    init(from decoder: Decoder) throws {
//        let id = decoder.decodeObject(forKey: "id") as! String
//        let friendGroup = decoder.decodeBool(forKey: "friendGroup")
//        let name = decoder.decodeObject(forKey: "name") as? String ?? "Foggy Group"
//        let members = decoder.decodeObject(forKey: "members") as? [String] ?? []
//        self.init(id: id, data: ["friendGroup": friendGroup, "name": name, "members": members])
//    }
    
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(id, forKey: "id")
        aCoder.encode(friendGroup, forKey: "friendGroup")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(membersStringArray, forKey: "members")
    }

}

struct UserDefaultGroup: Codable {
    let name: String
    let id: String
    var members: [String]
}
