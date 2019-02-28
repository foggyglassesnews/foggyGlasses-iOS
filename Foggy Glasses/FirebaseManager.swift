//
//  FirebaseManager.swift
//  Foggy Glasses
//
//  Created by Ryan Temple on 2/19/19.
//  Copyright © 2019 Foggy Glasses. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseFirestore

//MARK: Create User
class FirebaseManager {
    static let global = FirebaseManager()
    
    //Completions
    typealias CreateUserCompletion = (Error?)->()
    typealias GetGroupsCompletion = ([FoggyGroup]?)->()
    
    ///Create user initally
    func createUser(uid: String, data: [String: Any], completion: @escaping CreateUserCompletion) {
        
        Firestore.firestore().collection("users").document(uid).setData(data) { (err) in
            if let err = err {
                completion(err)
                return
            }
            
            let userName = data["userName"] as? String ?? ""
            self.storeUsername(uid: uid, username: userName, completion: completion)
        }
    }
    
    ///Stores username in DB
    private func storeUsername(uid:String, username: String, completion:@escaping CreateUserCompletion) {
        let data = [username:uid]
        Database.database().reference().child("unames").updateChildValues(data, withCompletionBlock: { (err, ref) in
            if let err = err {
                completion(err)
                return
            }
            completion(nil)
        })
    }
}

//MARK: Group
extension FirebaseManager {
    ///Gets all groups for user (pending and valid)
    func getGroups(uid: String, completion:@escaping GetGroupsCompletion) {
        var returnGroup = [FoggyGroup]()
        Database.database().reference().child("userGroups").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                if let groups = snapshot.value as? [String: Any] {
                    for groupData in groups {
                        self.getGroup(groupId: groupData.key, completion: { (optionalGroup) in
                            if let group = optionalGroup {
                                returnGroup.append(group)
                            }
                            if returnGroup.count == groups.count {
                                print("Returning Groups:", returnGroup)
                                completion(returnGroup)
                            }
                        })
                    }
                }
            } else {
                completion(nil)
            }
        }
    }
    
    func getGroup(groupId: String, completion: @escaping (FoggyGroup?)->()){
        Firestore.firestore().collection("pendingGroups").document(groupId).getDocument { (snapshot, err) in
            if let err = err {
                print("Error getting group:", err.localizedDescription)
                completion(nil)
                return
            }
            if let snap = snapshot {
                if snap.exists {
                    print(snap, snap.exists.description)
                }
            }
            
            if let data = snapshot?.data() {
                let group = FoggyGroup(id: groupId, data: data)
                completion(group)
            } else {
                completion(nil)
            }
            
        }
    }
}
