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
    typealias SucessFailCompletion = (Bool)->()
    typealias CreateUserCompletion = (Error?)->()
    typealias GetGroupsCompletion = ([String: [FoggyGroup]]?)->()
    typealias CreateGroupCompletion = (Bool, String?)->()
    
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
        self.groupData(uid: uid) { (groupData) in
            self.groupData(uid: uid, pending: true, completion: { (pendingData) in
                completion(["groups":groupData, "pending":pendingData])
            })
        }
    }
    
    ///Gets data for groups list
    private func groupData(uid: String, pending: Bool = false, completion: @escaping(([FoggyGroup])->())){
        let title = pending ? "pendingGroups" : "userGroups"
        var returnGroup = [FoggyGroup]()
        Database.database().reference().child(title).child(uid).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                if let groups = snapshot.value as? [String: Any] {
                    for groupData in groups {
                        self.getGroup(groupId: groupData.key, completion: { (optionalGroup) in
                            if let group = optionalGroup {
                                returnGroup.append(group)
                            }
                            if returnGroup.count == groups.count {
                                completion(returnGroup)
                            }
                        })
                    }
                }
            } else {
                completion(returnGroup)
            }
        }
    }
    
    ///Get data for group
    private func getGroup(groupId: String, completion: @escaping (FoggyGroup?)->()){
        Firestore.firestore().collection("groups").document(groupId).getDocument { (snapshot, err) in
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
    
    ///Create group
    func createGroup(name: String, members: [SearchMember], completion: @escaping CreateGroupCompletion) {
        let data = ["name": name]
        let ref = Firestore.firestore().collection("groups").document()
        ref.setData(data) { (err) in
            if let err = err {
                print("Error creating group:", err.localizedDescription)
                completion(false, nil)
                return
            }
            completion(true, ref.documentID)
        }
    }
    
    ///Adds group Id to users groups
    func addGroupToUsersGroups(uid: String, groupId: String, completion: @escaping SucessFailCompletion) {
        Database.database().reference().child("userGroups").child(uid).child(groupId).setValue(1) { (err, ref) in
            if let err = err {
                print("Error saving group to users groups", err.localizedDescription)
                completion(false)
                return
            }
            completion(true)
        }
    }
}
